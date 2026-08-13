# ApiStandard 快速入门

`ApiStandard` 面向传统 ASP.NET Core Web API 和模块化业务系统，包含 EF Core、MigrationService、AdminService 和 ApiService。

## 创建项目

```powershell
dotnet new install Perigon.templates --version 1.3.11
dotnet new perigon-webapi -n MyWebApi --frontType None
cd MyWebApi
```

如果需要 Angular 前端，使用 `--frontType Angular`，然后在 `src/ClientApp/WebApp` 执行 `pnpm install`。模板默认不生成和启动前端，AppHost 中的前端资源也需要按需启用。

## 配置数据库和缓存

在 `src/AppHost/appsettings.Development.json` 的 `Components` 节点中配置：

```json
{
  "Components": {
    "Cache": "Memory",
    "Database": "PostgreSQL"
  }
}
```

`Database` 支持 `PostgreSQL` 和 `SqlServer`。`Cache` 支持 `Memory`、`Redis` 和 `Hybrid`；只有选择 `Redis` 或 `Hybrid` 时 AppHost 才创建 Redis，并通过 `Components__Cache` 将选择传给服务。

## 创建迁移并运行

Standard 使用 EF Core 迁移。首次创建项目或修改实体后，在项目根目录执行：

```powershell
.\scripts\EFMigrations.ps1 Init
aspire start --non-interactive
```

AppHost 会先运行 `MigrationService`，完成后再启动 AdminService 和 ApiService。默认模板不包含 `SystemMod`，因此不会自动创建可登录的管理员账号；安装该模块后请按模块文档初始化账号，不要把示例凭据带入生产环境。

## OpenAPI 和测试

Standard 使用 Swashbuckle，只默认暴露 OpenAPI JSON：

```text
/swagger/v1/swagger.json
```

模板不默认提供 Swagger UI。单元测试不会启动 Aspire：

```powershell
dotnet test --project tests/UnitTest/UnitTest.csproj
```

需要真实数据库和多服务环境时再运行 Aspire 集成测试：

```powershell
dotnet test --project tests/ApiTest/ApiTest.csproj --treenode-filter '/*/*/*/*[Category=Integration]'
```

集成测试需要 Docker/Podman；迁移失败、健康检查和日志追踪请参考[生产运维 Runbook](../教程/生产运维Runbook.md)。

模板默认不创建管理员账号。若已安装 `SystemMod` 并要运行需要登录的测试，请通过 `PERIGON_TEST_ADMIN_EMAIL` 和 `PERIGON_TEST_ADMIN_PASSWORD` 环境变量提供测试账号。
