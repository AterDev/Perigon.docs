# 搭建开发环境：K3s + Kuboard 完整指南

> 本文档记录了在 Ubuntu 24.04 上搭建基于 K3s + Kuboard 的 Kubernetes 开发环境的完整过程，涵盖安装、配置、网络问题处理及私有仓库集成。

## 1. 环境准备与 K3s 安装

### 1.1 卸载现有 Kubernetes 组件（如有）

```bash
# 重置 kubeadm
sudo kubeadm reset -f

# 卸载软件包
sudo apt-get purge -y kubeadm kubelet kubectl
sudo apt-get autoremove -y

# 清理残留文件
sudo rm -rf /etc/kubernetes ~/.kube /var/lib/kubelet /var/lib/etcd /var/lib/cni
sudo rm -rf /etc/cni

# 清理网络规则
sudo ipvsadm -C 2>/dev/null || true
sudo iptables -F && sudo iptables -t nat -F && sudo iptables -t mangle -F
sudo iptables -X

# 清理 systemd 残留
sudo systemctl daemon-reload
```

### 1.2 安装 K3s（国内网络优化版）

```bash
# 使用国内镜像源一键安装
curl -sfL https://rancher-mirror.rancher.cn/k3s/k3s-install.sh | INSTALL_K3S_MIRROR=cn sh -
```

### 1.3 配置 kubectl

```bash
# 创建 .kube 目录并复制配置文件
mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $USER:$USER ~/.kube/config
chmod 600 ~/.kube/config

# 验证安装
kubectl get nodes
```

**预期输出**：

```
NAME         STATUS   ROLES                  AGE   VERSION
k8s-master   Ready    control-plane,master   1m    v1.36.2+k3s1
```

### 1.4 K3s 常用管理命令

```bash
# 查看服务状态
sudo systemctl status k3s

# 查看日志
sudo journalctl -u k3s -f

# 重启 K3s
sudo systemctl restart k3s

# 停止 K3s
sudo systemctl stop k3s

# 卸载 K3s
sudo /usr/local/bin/k3s-uninstall.sh
```

---

## 2. Kuboard 部署

### 启动 Kuboard

```bash
# 先加入内部网络（与其他容器通信）
docker run -d \
  --name kuboard \
  --restart=unless-stopped \
  -v /root/kuboard-data:/data \
  eipwork/kuboard:latest

```

### 步骤5：访问 Kuboard

```link
http://你的服务器IP:8080
```

- **用户名**：`admin`
- **密码**：`kuboard123`

---

## 3. K3s 镜像加速配置

### 3.1 配置 registries.yaml

创建或编辑 `/etc/rancher/k3s/registries.yaml`：

```bash
sudo vim /etc/rancher/k3s/registries.yaml
```

```yaml
mirrors:
  docker.io:
    endpoint:
      - "https://docker.m.daocloud.io"
      - "https://dockerproxy.com"
      - "https://docker.nju.edu.cn"
  "172.16.xxx.xxx:8081":
    endpoint:
      - "http://172.16.xxx.xxx:8081"
```

### 3.2 重启 K3s 使配置生效

```bash
sudo systemctl restart k3s

# 验证配置
sudo systemctl status k3s
```

---

## 4. 私有仓库配置

### 4.1 仓库信息

| 项目 | 值 |
| ------ | ----- |
| 仓库地址 | `172.16.xxx.xxx:8081` |
| 协议 | HTTP（非 HTTPS） |
| 认证 | 需要用户名/密码 |

### 4.2 配置 K3s 允许 HTTP 访问

在 `/etc/rancher/k3s/registries.yaml` 中已配置：

```yaml
mirrors:
  "172.16.xxx.xxx:8081":
    endpoint:
      - "http://172.16.xxx.xxx:8081"

configs:
  "172.16.xxx.xxx:8081":
    tls:
      insecure_skip_verify: true
```

### 4.3 创建 imagePullSecrets（用于认证）

```bash
kubectl create secret docker-registry private-registry \
  --docker-server=172.16.xxx.xxx:8081 \
  --docker-username=<用户名> \
  --docker-password=<密码> \
  --docker-email=<邮箱>
```

### 4.4 在 Deployment 中使用

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  replicas: 1
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - name: myapp
        image: 172.16.xxx.xxx:8081/docker-hosted/lires:latest
      imagePullSecrets:
      - name: private-registry
```

### 4.5 常见错误排查

| 错误信息 | 原因 | 解决方案 |
| ---------- | ------ | ---------- |
| `http: server gave HTTP response to HTTPS client` | K3s 用 HTTPS 访问 HTTP 仓库 | 配置 `registries.yaml` 中的 HTTP endpoint |
| `unauthorized` | 认证失败 | 检查 `imagePullSecrets` 配置 |
| `ImagePullBackOff` | 拉取失败 | 用 `kubectl describe pod` 查看详细错误 |

---

## 5. Kuboard 添加 K3s 集群

### 5.1 获取 K3s 的 KubeConfig

```bash
cat /etc/rancher/k3s/k3s.yaml
```

### 5.2 修改配置文件

将 `server: https://127.0.0.1:6443` 中的 `127.0.0.1` 改为 K3s 服务器的真实 IP：

```yaml
server: https://172.16.xxx.xxx:6443
```

### 5.3 在 Kuboard 中添加集群

1. 登录 Kuboard
2. 点击 **添加集群** 或 **导入集群**
3. 粘贴修改后的 `kubeconfig` 内容
4. 填写集群名称（如 `k3s-dev`）

### 5.4 解决证书验证问题

**错误**：

```
x509: certificate signed by unknown authority
```

**解决方案**：在 Kuboard 中添加集群时，勾选 **跳过证书验证 (Skip TLS Verify)**

或在 `kubeconfig` 中修改：

```yaml
clusters:
- cluster:
    insecure-skip-tls-verify: true
    server: https://172.16.xxx.xxx:6443
  name: default
```

---

## 6. 部署应用与常见问题

### 6.1 部署测试应用

```bash
kubectl create deployment nginx --image=nginx:alpine
kubectl expose deployment nginx --port=80 --type=NodePort
kubectl get svc nginx
```

### 6.2 查看 Pod 状态

```bash
kubectl get pods
kubectl describe pod <pod名称>
kubectl logs <pod名称>
```

### 6.3 常见问题：ImagePullBackOff

**排查步骤**：

```bash
# 1. 查看详细错误
kubectl describe pod <pod名称>

# 2. 检查镜像地址是否正确
kubectl get pod <pod名称> -o yaml | grep image

# 3. 检查 imagePullSecrets 是否存在
kubectl get pod <pod名称> -o yaml | grep imagePullSecrets

# 4. 删除 Pod 让 Deployment 重建
kubectl delete pod <pod名称>
```

---

## 📚 附录：常用命令速查

| 用途 | 命令 |
| ------ | ------ |
| 查看节点状态 | `kubectl get nodes` |
| 查看所有 Pod | `kubectl get pods -A` |
| 查看 Pod 详情 | `kubectl describe pod <名称>` |
| 查看 Pod 日志 | `kubectl logs <名称>` |
| 重启 K3s | `sudo systemctl restart k3s` |
| 查看 K3s 日志 | `sudo journalctl -u k3s -f` |
| 查看 Docker 网络 | `docker network ls` |
| 查看 iptables 规则 | `sudo iptables -t nat -L -n` |
| 测试私有仓库拉取 | `docker pull 172.16.xxx.xxx:8081/镜像名:标签` |

---

## 🔗 参考链接

- [K3s 官方文档](https://docs.k3s.io/)
- [K3s 国内镜像安装](https://docs.rancher.cn/k3s/)
- [Kuboard 官方文档](https://kuboard.cn/)
- [Watchtower 文档](https://containrrr.dev/watchtower/)
