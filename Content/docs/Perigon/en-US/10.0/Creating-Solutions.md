# Creating Solutions

We provide two ways to create a solution quickly:

- Command line: `perigon new <name>`.
- Graphical UI: launch the panel with `perigon studio`.

Both options are interactive and guide you through solution initialization. This guide explains the key configuration choices.

## Select project type

There are currently two types of projects available:
-Standard: Complete MVC API+EF Core+Aspire support, suitable for the vast majority of scenarios.
-Light (AOT): In cases where AOT support is required, use MinimalAPI+Peripheral. Postgres+Aspire

## Choose a Database

Recommended options: `SqlServer` or `PostgreSql`.

## Using Other Databases

The template uses Entity Framework Core as the ORM. You can use any database with a supported EF Core provider, with a few changes:

- Update `ServiceDefaults/FrameworkExtensions.cs` → `AddDbContext` to use your provider.
- Update `Definition/EntityFramework` → `ContextBase` or `TenantDbFactory` to support your provider.

## Connection Strings

When using Aspire, you don’t need to configure connection strings manually—Aspire generates and injects them automatically. If you need to connect to an existing database, define the resource in `AppHost`.

See: [Configuring Dev Environment with Aspire](./Project-Templates/Configuring-Dev-Environment-with-Aspire.md).

## Caching

Options:

- Memory: in-memory only via `IMemoryCache`.
- Redis: distributed cache via `IDistributedCache`.
- Hybrid: combines both.

Caching is unified by `Microsoft.Extensions.Caching.Hybrid`, which dispatches to memory or distributed caches by policy. The framework provides a `CacheService` to simplify usage; prefer it for consistency.

Additional cache settings can be configured in `appsettings.json` after creation.

> [!TIP]
> For HybridCache details, see the [Microsoft docs](https://learn.microsoft.com/en-us/aspnet/core/performance/caching/hybrid?view=aspnetcore-9.0).

## Select Official Modules

During solution creation, you can select official modules directly. The tool reads the official module list from the `Perigon.Modules` repository, then automatically installs the selected modules into the target service after the solution is created.

The current metadata comes from `Perigon.Modules/modules.json`, for example:

- `Perigon.SystemMod`: base capabilities for system roles, users, and permissions.
- `Perigon.CMSMod`: content management capabilities.

If the current network environment cannot access the official module list, solution creation can still continue, but you will not be able to select official modules during that run.

> [!TIP]
> Official modules are still regular module packages underneath. If you skip them during creation, you can install them later with commands such as `perigon install Perigon.SystemMod <ServiceName>`.

## Message Queue

Not supported during creation.

## Authentication

Default: JWT. Other methods require manual integration.

## Frontend Framework

Currently supports an Angular template.

## Default Module Behavior

The latest templates no longer include example modules such as `SystemMod` by default. If you need them, select the official modules during creation or install them later after the solution is created.
