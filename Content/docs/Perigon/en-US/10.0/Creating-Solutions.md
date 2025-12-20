# Creating Solutions

We provide two methods to quickly create solutions:

- Command Line: Use `perigon new <name>`.
- Graphical Interface: Use `perigon studio` to launch the panel.

Both methods provide interactive operations to help users create solutions better. This document mainly explains the configuration and options during creation.

## Select Database

When creating a solution, you can choose `SqlServer` or `PostgreSQL`, which are the recommended databases.

## Using Other Databases

The template uses `EntityFramework Core` as the ORM framework, which means you can use any database that provides an EF Core Provider, but you need to perform some additional operations:

- Modify the `AddDbContext` method in `ServiceDefaults/FrameworkExtensions.cs` to support the database type you need.

- Modify `ContextBase` or `TenantDbFactory` in `Definition/EntityFramework` to support the database type you need.

## Database Connection String

When using `Aspire` to configure the development environment, there is no need to manually configure connection strings. `Aspire` will automatically generate and inject connection strings.

If you need to connect to an existing database, you can also define related resources in `AppHost`.

For detailed information, please refer to [Configuring Development Environment with Aspire](./Project-Templates/Configuring-Environment-with-Aspire.md).

## Select Caching

There are three caching options:

- Memory: Use only memory caching, available through the `IMemoryCache` interface.
- Redis: Use Redis caching, available through the `IDistributedCache` interface.
- Hybrid: Support both memory caching and Redis caching.

Caching operations are uniformly implemented using Microsoft's `Microsoft.Extensions.Caching.Hybrid` library, which internally calls either the `IMemoryCache` or `IDistributedCache` interface based on policy.

The framework encapsulates the `CacheService` service to simplify caching operations, and it is recommended to use this service uniformly.

For more caching-related configurations, after creating the solution, you can configure them in `appsettings.json`.

> [!TIP]
> For information about HybridCache, please refer to the [Microsoft official documentation](https://learn.microsoft.com/en-us/aspnet/core/performance/caching/hybrid?view=aspnetcore-9.0).

## Message Queue

Not currently supported during creation.

## Select Authentication Method

The default is `JWT` authentication. Other methods need to be manually integrated.

## Select Frontend Framework

Currently supports the `Angular` project template.
