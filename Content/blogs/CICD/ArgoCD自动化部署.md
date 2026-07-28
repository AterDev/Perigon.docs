# 从 GitLab CI 到 ArgoCD：搭建自动化 CI/CD 与 GitOps 流水线实战教程

> 适用场景：K3s + Kuboard + GitLab Runner (Docker)，从零搭建一套完整的 CI/CD + GitOps 自动化部署体系。本文基于实际落地经验，提供可直接复制的配置和常见问题解决方案。

## 一、理解 GitOps 与 CI/CD 分工

### 1.1 核心思想

GitOps 的核心思想是：**Git 仓库是集群的“唯一事实来源”**。集群里跑什么版本、多少副本、什么配置，全部写在 Git 里。想部署？改 Git。想回滚？`git revert`。想审计？`git log`。

### 1.2 工具分工

| 工具 | 职责 | 负责什么 |
|------|------|----------|
| **GitLab CI** | 持续集成（CI） | 编译代码、构建镜像、推送到镜像仓库、更新配置仓库 |
| **ArgoCD** | 持续交付（CD） | 监控 Git 仓库变化，自动同步到 Kubernetes 集群 |

关键设计：**CI 不直接操作集群**。CI 只负责改 Git 仓库，ArgoCD 负责把 Git 里的状态同步到集群。CI 不需要集群凭证，安全性大大提升。

### 1.3 仓库结构

推荐采用**双仓库模式**：

| 仓库 | 内容 | 谁在用 |
|------|------|--------|
| **应用仓库**（如 `my-app`） | 业务代码 + Dockerfile + `.gitlab-ci.yml` | 开发人员 |
| **配置仓库**（如 `gitops-config`） | K8s YAML + ArgoCD Application 定义 | ArgoCD 监控 |

## 二、环境准备

### 2.1 基础环境

- K3s 集群已部署
- Kuboard 已安装（用于可视化操作）
- GitLab Runner (Docker 执行器) 已注册
- 私有镜像仓库（如 Harbor / Nexus / GitLab Registry）已部署

### 2.2 约定示例地址

本教程使用以下示例地址，请替换为你自己的实际地址：

| 占位符 | 示例值 | 说明 |
| -------- | -------- | ------ |
| `{REGISTRY_HOST}` | `registry.example.com` | 镜像仓库地址 |
| `{REGISTRY_PORT}` | `5000` | 镜像仓库端口 |
| `{GITLAB_HOST}` | `gitlab.example.com` | GitLab 服务地址 |
| `{GITLAB_PORT}` | `8443` | GitLab 服务端口 |
| `{GROUP_NAME}` | `my-team` | GitLab 组名 |
| `{APP_NAME}` | `my-app` | 应用名称 |
| `{NAMESPACE}` | `production` | K8s 命名空间 |
| `{K3S_NODE_IP}` | `192.168.1.100` | K3s 节点 IP |

### 2.3 K3s 镜像加速配置（大陆网络必备）

在**每个 K3s 节点**上创建 `/etc/rancher/k3s/registries.yaml`：

```yaml
mirrors:
  docker.io:
    endpoint:
      - "https://docker.1panel.live"
      - "https://docker.1ms.run"
      - "https://docker.m.daocloud.io"
  ghcr.io:
    endpoint:
      - "https://ghcr.dockerproxy.cn"
```

重启 K3s：

```bash
systemctl restart k3s
```

> **注意**：`docker.io` 和 `ghcr.io` 都需要配置，ArgoCD 依赖的 Dex 镜像来自 ghcr.io。

## 三、安装 ArgoCD

### 3.1 安装（使用 Kuboard 部署）

1. 下载安装清单：

```bash
curl -L https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml > argocd-install.yaml
```

1. 在 Kuboard 中：**集群管理 → 自定义资源 → 从 YAML 创建**，粘贴内容
2. 命名空间建议：`argocd`

### 3.2 暴露访问入口（NodePort）

```bash
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort"}}'
kubectl get svc -n argocd
```

访问地址：`https://{K3S_NODE_IP}:{NODEPORT_PORT}`

### 3.3 获取初始密码

```bash
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

用户名：`admin`

## 四、配置仓库结构

### 4.1 推荐目录结构

```
gitops-config/                              # GitOps 配置仓库
├── apps/                                   # ArgoCD Application 定义（子应用）
│   ├── my-app-backend.yaml
│   ├── my-app-frontend.yaml
│   └── root-app.yaml                       # Root App（父应用，App of Apps）
└── manifests/                              # 实际的 K8s YAML
    ├── my-app-backend/
    │   ├── deployment.yaml
    │   └── service.yaml
    ├── my-app-frontend/
    │   ├── deployment.yaml
    │   └── service.yaml
    └── ingress.yaml
```

### 4.2 Deployment YAML（使用占位符）

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app-frontend
  namespace: production
spec:
  replicas: 2
  selector:
    matchLabels:
      app: my-app-frontend
  template:
    metadata:
      labels:
        app: my-app-frontend
    spec:
      containers:
      - name: nginx
        image: registry.example.com:5000/my-team/my-app-frontend:${IMAGE_TAG}
        ports:
        - containerPort: 80
```

### 4.3 Root App（父应用）

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: root-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: http://gitlab.example.com:8443/my-team/gitops-config.git
    targetRevision: main
    path: apps
    directory:
      recurse: true
  destination:
    server: https://kubernetes.default.svc
    namespace: production
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

### 4.4 子应用

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: my-app-backend
  namespace: argocd
spec:
  project: default
  source:
    repoURL: http://gitlab.example.com:8443/my-team/gitops-config.git
    targetRevision: main
    path: manifests/my-app-backend
  destination:
    server: https://kubernetes.default.svc
    namespace: production
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
```

## 五、GitLab CI 配置

### 5.1 `.gitlab-ci.yml` 完整配置

```yaml
variables:
  APP_NAME: "my-app-frontend"
  DOCKER_BUILDKIT: "1"
  DOCKER_REGISTRY: "registry.example.com:5000"
  DOCKER_REPO: "my-team"
  IMAGE_TAG: "$CI_COMMIT_SHORT_SHA"
  IMAGE_FULL: "$DOCKER_REGISTRY/$DOCKER_REPO/$APP_NAME:$IMAGE_TAG"

stages:
  - build
  - push
  - update-gitops

build:
  stage: build
  image: docker:24-dind
  services:
    - docker:24-dind
  script:
    - docker build -t ${IMAGE_FULL} .
  rules:
    - if: '$CI_COMMIT_BRANCH == "main"'

push:
  stage: push
  image: docker:24-dind
  services:
    - docker:24-dind
  script:
    - docker push ${IMAGE_FULL}
  rules:
    - if: '$CI_COMMIT_BRANCH == "main"'

update-gitops:
  stage: update-gitops
  image: alpine:3.20
  rules:
    - if: '$CI_PIPELINE_SOURCE == "push" && $CI_COMMIT_BRANCH == "main"'
      when: always
  before_script:
    - apk add --no-cache git sed
  script:
    # 克隆配置仓库
    - git clone "http://oauth2:${GITOPS_TOKEN}@gitlab.example.com:8443/my-team/gitops-config.git" /tmp/gitops-config
    - cd /tmp/gitops-config
    - git config user.email "ci@gitlab.com"
    - git config user.name "GitLab CI"
    
    # 替换占位符为真实 commit SHA
    - sed -i "s|\(image: registry.example.com:5000/my-team/my-app-frontend:\)[^ ]*|\1${CI_COMMIT_SHORT_SHA}|" manifests/my-app-frontend/deployment.yaml
    
    # 调试：确认替换结果
    - cat manifests/my-app-frontend/deployment.yaml | grep image
    
    - git add manifests/my-app-frontend/deployment.yaml
    - git commit -m "chore: update my-app-frontend to ${CI_COMMIT_SHORT_SHA} [skip ci]" || echo "No changes"
    - git push origin main
```

### 5.2 GitLab CI 变量配置

在 GitLab 项目 **Settings → CI/CD → Variables** 中添加：

| 变量名 | 值 | 说明 | 类型 |
|--------|-----|------|------|
| `GITOPS_TOKEN` | `glpat-xxxxxxxxxxxx` | GitLab Personal Access Token，需有 `write_repository` 权限 | Masked |

> **注意**：
>
> - `CI_JOB_TOKEN` 默认不支持跨项目 `git push`（GitLab < 18.4）。建议使用 **Personal Access Token**，确保有 `write_repository` 权限。
> - Token 权限：至少需要 `api` 或 `write_repository` 范围。

### 5.3 分支一致性问题

**确保 CI push 的分支与 ArgoCD 监控的分支一致！**

如果 CI 推送到 `dev`，但 ArgoCD 监控的是 `main`，ArgoCD 永远看不到更新。

解决方案：

- 方案一：CI 推送到 `main`（推荐）
- 方案二：ArgoCD Application 的 `targetRevision` 改为 `dev`

## 六、ArgoCD 权限配置

### 6.1 常见权限错误

ArgoCD 同步时常见错误：

```
Failed to load live state: ... cannot list resource "ingressclasses" ...
Failed to load target state: ... cannot list resource "clusterrolebindings" ...
Failed to load target state: ... cannot list resource "replicationcontrollers" ...
Failed to load target state: ... cannot list resource "ipaddresses.networking.k8s.io" ...
```

### 6.2 解决方案：授予 cluster-admin 权限

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: argocd-cluster-admin
subjects:
- kind: ServiceAccount
  name: argocd-application-controller
  namespace: argocd
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: rbac.authorization.k8s.io
```

应用后重启 Controller：

```bash
kubectl apply -f clusterrolebinding.yaml
kubectl delete pod -n argocd -l app.kubernetes.io/component=application-controller
```

> **验证权限**：

```bash
kubectl auth can-i list ipaddresses.networking.k8s.io \
  --as=system:serviceaccount:argocd:argocd-application-controller
```

返回 `yes` 说明权限生效。

> **安全提示**：`cluster-admin` 仅在测试环境使用，生产环境应按最小权限原则，逐步添加所需资源。

## 七、Secret 管理

### 7.1 在 Kuboard 中创建 Secret

1. 进入命名空间（如 `production`）
2. **配置管理 → Secret → 创建**
3. 名称：`my-app-secret`
4. 类型：`Opaque`（默认通用类型）
5. 数据：Key 为 `database-connection-string`，Value 为实际连接串

### 7.2 使用 YAML 创建（推荐使用 `stringData`）

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: my-app-secret
  namespace: production
type: Opaque
stringData:
  database-connection-string: "Server=db.example.com;Database=mydb;User=sa;Password=YourStrongPassword"
  api-key: "your-api-key-here"
```

> `stringData` 是明文字段，Kubernetes 会自动 Base64 编码，便于阅读和维护。

### 7.3 Deployment 中引用

```yaml
env:
- name: DATABASE_CONNECTION
  valueFrom:
    secretKeyRef:
      name: my-app-secret
      key: database-connection-string
- name: API_KEY
  valueFrom:
    secretKeyRef:
      name: my-app-secret
      key: api-key
```

## 八、常见问题排查清单

| 问题 | 原因 | 解决方案 |
| ------ | ------ | ---------- |
| `InvalidImageName` | YAML 中还有 `${IMAGE_TAG}` 占位符 | 检查 CI 中 `sed` 是否在 `git commit` **之前**执行 |
| ArgoCD 看不到更新 | CI push 分支与 ArgoCD `targetRevision` 不一致 | 统一使用 `main` 分支 |
| `git push` 返回 403 | `CI_JOB_TOKEN` 默认不支持跨项目 push | 使用 Personal Access Token |
| 权限错误不断 | ArgoCD ServiceAccount 权限不足 | 授予 `cluster-admin` 或逐一添加所需权限 |
| 镜像拉取超时 | 未配置镜像加速 | 配置 `registries.yaml` |
| `docker login` 失败 | 未配置镜像仓库认证 | 在 GitLab CI 中添加 `DOCKER_AUTH_CONFIG` 变量 |
| ArgoCD 同步卡住 | 资源冲突或依赖缺失 | 查看 ArgoCD UI 中的事件日志 |

## 九、完整自动化流程总结

```
开发者提交代码到 main
        ↓
GitLab CI 触发
        ↓
构建 Docker 镜像（tag = commit SHA）
        ↓
推送镜像到私有仓库
        ↓
克隆 gitops-config 仓库
        ↓
sed 替换 deployment.yaml 中的镜像 tag
        ↓
git commit + push 到 main
        ↓
ArgoCD 检测到 gitops-config 变化
        ↓
自动同步到 K3s 集群
        ↓
应用滚动更新完成 ✅
```

## 十、生产环境安全建议

| 阶段 | 建议 |
| ------ | ------ |
| **镜像构建** | 使用多阶段构建，最小化镜像体积 |
| **镜像版本** | 使用 commit SHA 或语义化版本，**不要使用 `latest`** |
| **镜像仓库** | 配置镜像清理策略，保留最近 N 个版本 |
| **Secret** | 使用 `stringData` 或 External Secrets Operator，避免明文 |
| **ArgoCD 权限** | 生产环境按需授权，使用自定义 ClusterRole |
| **Git 分支** | `main` 作为生产分支，配置分支保护规则 |
| **审批流程** | 配置 GitLab 合并请求审批 + ArgoCD Sync 审批 |

## 十一、参考资源

- [ArgoCD 官方文档](https://argo-cd.readthedocs.io/)
- [GitLab CI/CD 文档](https://docs.gitlab.com/ci/)
- [K3s 镜像仓库配置](https://docs.k3s.io/installation/private-registry)
- [Kuboard 官方文档](https://kuboard.cn/)
- [GitOps 最佳实践](https://www.weave.works/technologies/gitops/)
