# ApiStandard Quick Start

`ApiStandard` targets conventional ASP.NET Core Web APIs and modular business systems. It includes EF Core, MigrationService, AdminService, and ApiService.

## Create a project

```powershell
dotnet new install Perigon.templates --version 1.3.12
dotnet new perigon-webapi -n MyWebApi --frontType None
cd MyWebApi
```

Use `--frontType Angular` when an Angular frontend is required, then run `pnpm install` in `src/ClientApp/WebApp`. The template does not generate or start the frontend by default; the optional frontend resource in AppHost must also be enabled.

## Configure database and cache

Configure the `Components` node in `src/AppHost/appsettings.Development.json`:

```json
{
  "Components": {
    "Cache": "Memory",
    "Database": "PostgreSQL"
  }
}
```

`Database` supports `PostgreSQL` and `SqlServer`. `Cache` supports `Memory`, `Redis`, and `Hybrid`. AppHost creates Redis only for `Redis` or `Hybrid` and passes the selected value to services through `Components__Cache`.

## Create migrations and run

Standard uses EF Core migrations. After creating a project or changing entities:

```powershell
.\scripts\EFMigrations.ps1 Init
aspire start --non-interactive
```

AppHost runs `MigrationService` first, then starts AdminService and ApiService. The default template does not include `SystemMod`, so it does not create a login-ready administrator account. If the module is installed, follow its initialization guide and never reuse example credentials in production.

## OpenAPI and tests

Standard uses Swashbuckle and exposes the OpenAPI JSON document at:

```text
/swagger/v1/swagger.json
```

Swagger UI is not enabled by default. Unit tests do not start Aspire:

```powershell
dotnet test --project tests/UnitTest/UnitTest.csproj
```

Run Aspire integration tests only when real infrastructure and multiple services are needed:

```powershell
dotnet test --project tests/ApiTest/ApiTest.csproj --treenode-filter '/*/*/*/*[Category=Integration]'
```

Integration tests require Docker/Podman. See the [Production Operations Runbook](../Tutorials/Production-Operations-Runbook.md) for migration failures, health checks, and log tracing.

The template does not create an administrator account by default. If `SystemMod` is installed and authenticated tests are enabled, provide the test account through `PERIGON_TEST_ADMIN_EMAIL` and `PERIGON_TEST_ADMIN_PASSWORD` environment variables.
