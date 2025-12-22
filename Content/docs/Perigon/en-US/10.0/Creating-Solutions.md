# Creating Solutions

We provide two ways to create a solution quickly:

- Command line: `perigon new <name>`.
- Graphical UI: launch the panel with `perigon studio`.

Both options are interactive. This guide explains the key configuration choices.

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
> For HybridCache details, see the Microsoft docs: https://learn.microsoft.com/en-us/aspnet/core/performance/caching/hybrid?view=aspnetcore-9.0

## Message Queue

Not supported during creation.

## Authentication

Default: JWT. Other methods require manual integration.

## Frontend Framework

Currently supports an Angular template.
