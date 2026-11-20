# MiniApi 快速入门

`MiniApi` 面向轻量接口和微服务，使用 Minimal API、PostgreSQL、Request Delegate Generator 和 NativeAOT。它不包含内置 EF Core 迁移资源、AdminService 或默认 Angular 前端。

已发布的 `Perigon.templates` 模板包版本为 1.3.18。其 MiniApi 项目目标框架为 .NET 11，使用 Perigon.PostgreSQL 0.3.8。模板随附 Aspire 13.6.5 AppHost。运行前请安装 Aspire CLI。

模板仓库为当前 MiniApi 源码固定 SDK 11.0.100，构建生成项目需要安装 .NET 11 SDK。

## 创建项目

```powershell
dotnet new install Perigon.templates --version 1.3.18
dotnet new perigon-miniapi -n MyMiniApi --frontType None
cd MyMiniApi
```

使用 `--frontType Angular` 生成前端。AppHost 检测到前端的 `package.json` 后会把它加入资源图。

## 配置和运行

在 `src/AppHost/appsettings.Development.json` 或用户机密中设置 `ConnectionStrings:Default`，指向运行中的 PostgreSQL。同一处也可以选择缓存模式：

```json
{
  "Components": {
    "Cache": "Memory"
  }
}
```

AppHost 通过 `Components__Cache` 将缓存模式传给 ApiService。选择 `Redis` 或 `Hybrid` 时，将 `ConnectionStrings:Cache` 指向运行中的 Redis。生成的 AppHost 默认使用外部连接。

```powershell
aspire start --non-interactive
```

MiniApi 不需要执行 EF migration 脚本。新增实体时按项目中的 `DefaultDbContext` 约定补充模型，并使用项目选择的 PostgreSQL 数据访问方式。

## OpenAPI、AOT 和测试

OpenAPI JSON 默认位于：

```text
/openapi/v1.json
```

ApiService 默认启用 NativeAOT，可直接发布：

```powershell
dotnet publish src/Services/ApiService/ApiService.csproj -c Release
```

单元测试不启动 Aspire：

```powershell
dotnet test --project tests/UnitTest/UnitTest.csproj
```

需要验证 AppHost、PostgreSQL 或服务间契约时再运行集成测试：

```powershell
dotnet test --project tests/ApiTest/ApiTest.csproj --treenode-filter '/*/*/*/*[Category=Integration]'
```

发布和容器健康检查请参考[生产运维 Runbook](../教程/生产运维Runbook.md)。

关于分层、Native AOT 源生成和 CLI 命令，请参阅 [MiniApi 架构与工具](./MiniApi架构与工具.md)。
