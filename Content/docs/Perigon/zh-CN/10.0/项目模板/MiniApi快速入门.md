# MiniApi 快速入门

`MiniApi` 面向轻量接口和微服务，使用 Minimal API、PostgreSQL、Request Delegate Generator 和 NativeAOT。它不包含内置 EF Core 迁移资源、AdminService 或默认 Angular 前端。

## 创建项目

```powershell
dotnet new install Perigon.templates --version 1.3.12
dotnet new perigon-miniapi -n MyMiniApi --frontType None
cd MyMiniApi
```

需要 Angular 时使用 `--frontType Angular` 并执行 `pnpm install`；前端仍需在 AppHost 中按需启用。

## 配置和运行

MiniApi 固定使用 PostgreSQL。可以在 `src/AppHost/appsettings.Development.json` 中配置缓存：

```json
{
  "Components": {
    "Cache": "Memory"
  }
}
```

选择 `Redis` 或 `Hybrid` 时 AppHost 才创建 Redis，并通过 `Components__Cache` 传给 ApiService；默认使用内存缓存，不需要启动 Redis。

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
