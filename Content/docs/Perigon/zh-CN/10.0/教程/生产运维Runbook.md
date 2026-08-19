# 生产运维 Runbook

本文用于 ApiStandard 和 MiniApi 的上线检查、故障定位和回滚。两套模板的能力边界不同，请先确认模板类型。

## 上线前检查表

- [ ] 已确认模板包版本、Aspire SDK 版本和运行时镜像版本与[版本兼容矩阵](../项目模板/版本特性.md)一致。
- [ ] `Authentication__Jwt__Sign` 通过环境变量、Secret Store 或密钥服务注入；未使用模板文件中的空值或示例值。
- [ ] 已配置 `Authentication__Jwt__ValidIssuer`、`Authentication__Jwt__ValidAudiences` 和生产 HTTPS 地址。
- [ ] OAuth 场景已启用 HTTPS 元数据校验；`RequireHttpsMetadata=false` 只允许 Development。
- [ ] 已配置生产 CORS 白名单，不使用 `AllowAnyOrigin`。
- [ ] 已配置数据库连接字符串、数据库迁移策略、备份和恢复点。
- [ ] 已设置 `OTEL_EXPORTER_OTLP_ENDPOINT`（如需要观测），没有依赖已移除的 `Otel` 或 `OpenTelemetry` 配置节点。
- [ ] 已为负载均衡器配置 `/health` 和 `/alive`，并确认数据库、缓存等依赖的 readiness 检查策略。
- [ ] 已确认容器运行架构、端口、证书、镜像标签和回滚镜像。

## 迁移失败

### ApiStandard

`ApiService-Migrations` 是一次性迁移资源。先查看迁移资源日志，确认失败发生在连接、迁移脚本还是初始化数据：

```powershell
aspire otel logs ApiService-Migrations
aspire describe ApiService-Migrations
```

处理顺序：

1. 停止应用发布流程，不要让 API 在半迁移状态下继续接收流量。
2. 校验目标数据库连接、权限和迁移历史表。
3. 修复迁移或初始化数据后，在测试数据库重新执行。
4. 生产环境优先恢复备份，再执行经过验证的迁移；不要直接删除迁移历史表。
5. 确认 `ApiService-Migrations` 成功退出后，再启动 API 和后台服务。

Kubernetes 发布时，检查 Job 是否成功：

```powershell
kubectl get jobs -n perigon -l app.kubernetes.io/component=ApiService-Migrations
kubectl describe job <migration-job-name> -n perigon
kubectl logs job/<migration-job-name> -n perigon
```

Job 成功后不应被重新部署为长期服务。若迁移失败，先停止放流量，修复迁移或初始化数据，再按发布流程重新执行；不要直接删除生产数据库的 EF 历史表。

### MiniApi

MiniApi 不包含 `ApiService-Migrations`，也不提供内置 EF migration 脚本。数据库 schema 由部署管线或独立数据库变更工具负责；发布管线必须在 API 启动前完成 schema 校验。

## 容器健康

开发环境使用 Aspire 查看资源状态：

```powershell
aspire ps
aspire describe
```

服务端 `/health` 用于 readiness，`/alive` 用于 liveness。若资源持续 `Unhealthy`：

1. 先查看应用日志和对应基础设施日志。
2. 检查连接字符串是否由 AppHost 注入，特别是 `Default` 和 `Cache`。
3. 检查 `Components__Cache` 是否为 `Memory`、`Redis` 或 `Hybrid`，并确认只有 Redis/Hybrid 才需要 Redis 资源。
4. 检查容器端口、卷权限、镜像架构和资源限额。

## Aspire 日志与链路追踪

```powershell
aspire otel logs ApiService
aspire otel traces ApiService
aspire otel spans ApiService
```

代码只使用标准 `OTEL_EXPORTER_OTLP_ENDPOINT` 环境变量发现 OTLP 导出端点。模板中的 `Otel`/`OpenTelemetry` 节点已移除，避免配置看似存在但实际不生效。

## 回滚

- 应用回滚：切换到上一个已验证镜像标签，并保留当前日志和部署描述。
- 数据库回滚：优先使用备份恢复；只有经过验证的可逆迁移才允许执行反向迁移。
- 配置回滚：同步恢复 JWT issuer/audience、CORS、连接字符串和 OTLP endpoint，避免应用和数据版本不匹配。
