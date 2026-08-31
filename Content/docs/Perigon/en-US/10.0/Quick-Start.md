# Quick Start

Perigon provides two templates with different boundaries. Choose a template first, then follow its creation, run, test, and deployment guide.

| Template | Best for | Technical boundary | Quick start |
| --- | --- | --- | --- |
| `ApiStandard` | Conventional Web APIs, admin services, and modular business systems | EF Core, an Aspire migration resource, AdminService/ApiService, PostgreSQL or SQL Server | [ApiStandard quick start](./Project-Templates/ApiStandard-Quick-Start.md) |
| `MiniApi` | Lightweight APIs, microservices, and resource-sensitive workloads | Minimal API, PostgreSQL, NativeAOT, no built-in EF migration resource | [MiniApi quick start](./Project-Templates/MiniApi-Quick-Start.md) |

## Common prerequisites

1. Install the `.NET 10.0.103` SDK or a compatible .NET 10 SDK.
2. Install an Aspire CLI matching the template SDK (the current development version is 13.5.0) and prepare Docker or Podman.
3. Install `Perigon.CLI` and create a project with `dotnet new`, or use Studio to create a solution.

When using the templates directly, install the package version covered by this documentation:

```powershell
dotnet new install Perigon.templates --version 1.3.15
```

See the [version compatibility matrix](./Project-Templates/Version-Features.md) for the template package, Aspire SDK, and CLI mapping.

## Run and troubleshoot

Use the Aspire CLI to manage AppHost:

```powershell
aspire start --non-interactive
aspire ps
aspire otel logs
```

Stop the application:

```powershell
aspire stop --non-interactive
```

Before production deployment, read [Production Operations Runbook](./Tutorials/Production-Operations-Runbook.md) and [Deploying Applications](./Tutorials/Deploying-Applications.md).
