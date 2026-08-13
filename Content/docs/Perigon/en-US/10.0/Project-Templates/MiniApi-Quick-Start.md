# MiniApi Quick Start

`MiniApi` targets lightweight APIs and microservices. It uses Minimal API, PostgreSQL, the Request Delegate Generator, and NativeAOT. It does not include `MigrationService`, AdminService, or a default Angular frontend.

## Create a project

```powershell
dotnet new install Perigon.templates --version 1.3.12
dotnet new perigon-miniapi -n MyMiniApi --frontType None
cd MyMiniApi
```

Use `--frontType Angular` when needed and run `pnpm install`; the frontend still must be enabled in AppHost explicitly.

## Configure and run

MiniApi uses PostgreSQL only. Configure the cache in `src/AppHost/appsettings.Development.json`:

```json
{
  "Components": {
    "Cache": "Memory"
  }
}
```

AppHost creates Redis only for `Redis` or `Hybrid` and passes the choice to ApiService through `Components__Cache`. The default is memory cache, so Redis is not required for the first run.

```powershell
aspire start --non-interactive
```

MiniApi does not use the EF migration script. When adding entities, follow the `DefaultDbContext` conventions and the PostgreSQL data-access approach already present in the project.

## OpenAPI, AOT, and tests

The default OpenAPI JSON document is available at:

```text
/openapi/v1.json
```

ApiService is configured for NativeAOT and can be published directly:

```powershell
dotnet publish src/Services/ApiService/ApiService.csproj -c Release
```

Unit tests do not start Aspire:

```powershell
dotnet test --project tests/UnitTest/UnitTest.csproj
```

Run integration tests when validating AppHost, PostgreSQL, or service contracts:

```powershell
dotnet test --project tests/ApiTest/ApiTest.csproj --treenode-filter '/*/*/*/*[Category=Integration]'
```

See the [Production Operations Runbook](../Tutorials/Production-Operations-Runbook.md) for publishing and container health checks.
