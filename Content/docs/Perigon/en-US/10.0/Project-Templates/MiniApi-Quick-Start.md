# MiniApi Quick Start

`MiniApi` targets lightweight APIs and microservices. It uses Minimal API, PostgreSQL, the Request Delegate Generator, and NativeAOT. It does not include a built-in EF Core migration resource, AdminService, or a default Angular frontend.

The released `Perigon.templates` package is 1.3.18. Its MiniApi project targets .NET 11 and uses Perigon.PostgreSQL 0.3.8. The template ships an Aspire 13.6.5 AppHost. Install the Aspire CLI before running it.

The template repository pins SDK 11.0.100 for the current MiniApi source. Building a generated project therefore requires the .NET 11 SDK.

## Create a project

```powershell
dotnet new install Perigon.templates --version 1.3.18
dotnet new perigon-miniapi -n MyMiniApi --frontType None
cd MyMiniApi
```

Use `--frontType Angular` to generate the frontend. AppHost includes it when its `package.json` is present.

## Configure and run

Set `ConnectionStrings:Default` in `src/AppHost/appsettings.Development.json` or user secrets to point to a running PostgreSQL instance. Choose a cache mode in the same configuration:

```json
{
  "Components": {
    "Cache": "Memory"
  }
}
```

AppHost passes the cache mode to ApiService through `Components__Cache`. For `Redis` or `Hybrid`, set `ConnectionStrings:Cache` to a running Redis instance. The generated AppHost uses external connections by default.

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

For the layer boundaries, source-generated AOT workflow, and CLI commands, see [MiniApi Architecture and Tooling](./MiniApi-Architecture-and-Tooling.md).
