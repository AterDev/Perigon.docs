# Configuring Development Environment with Aspire

**AppHost** is the host project of `Aspire`, which provides developers with the ability to define infrastructure and services through code. It not only provides support for microservice development, but also meets the needs of traditional monolithic applications.

## Configuration Files

AppHost is a standard `.NET` application, so it supports configuration through the `appsettings.json` file.

Let's first look at an example of `appsettings.Development.json`:
```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "Components": {
    // memory/redis/hybrid
    "Cache": "Hybrid",
    // SqlServer/PostgreSQL
    "Database": "PostgreSQL",
    // enable multi-tenant features
    "IsMultiTenant": false,
    // message queue
    "Nats": false,
    "Qdrant": false
  }
}
```

Here we mainly focus on the `Components` node, which defines the component types used by the application:
- `Cache` options include: `memory` (memory cache), `redis` (Redis cache), or `hybrid` (hybrid cache);
- `Database` options include: `SqlServer` or `PostgreSQL`
- `IsMultiTenant` is used to enable multi-tenant functionality

### Multi-tenant Configuration

The framework is compatible with multi-tenant mode by default. You only need to set `IsMultiTenant` to `true` in the configuration file to enable multi-tenant functionality.

If you are sure that you do not need multi-tenant functionality now and in the future, you can modify the interface inherited by `EntityBase` from `ITenantEntityBase` to `IEntityBase`, so that the `TenantId` field will not be included.

> [!IMPORTANT]
> When multi-tenancy is enabled, be sure to inherit the `ITenantEntityBase` interface to ensure that entity classes contain the `TenantId` field, thereby supporting multi-tenant data isolation.

### Frontend Integration

Aspire supports integrating various other projects into AppHost, such as frontend projects, Python projects, etc. For example, adding a frontend project:
```csharp
var webApp = builder.AddNpmApp("frontend", "../ClientApp/WebApp")
    .WithUrl("http://localhost:4200")
    .WaitFor(adminService)
    .WithParentRelationship(serviceGroup);
```

> Note: AddNpmApp will execute the `npm run start` command to start the frontend project. Before this, you may need to manually run `pnpm install` to install dependency packages.

### Infrastructure Configuration

You can define various infrastructure in `AppHost.cs` through code. The default passwords and ports are defined in `AppSettingsHelper.cs`. You can modify them according to your needs.


## Custom Database Connection String

The template starts containers locally by default to support the development environment. In some cases, you may need to use a custom database connection string, which can be configured in `appsettings.json`:

```json
{
  "ConnectionStrings": {
    "Default": "Server=your_server;Database=your_database;User Id=your_user;Password=your_password;",
    "Cache":"your_cache_connection_string"
  }
}
```

Then use in `AppHost.cs`:

```csharp
var database = builder.AddConnectionString("Default");
var cache = builder.AddConnectionString("Cache");
```

Other services can automatically obtain these connection strings from environment variables, so that all service-dependent resources can be uniformly defined in AppHost and managed uniformly, without the need to repeatedly define in each service's configuration file.

This method is suitable for using public resources without starting database containers locally each time.

> [!TIP]
> You can obtain and manage these configurations through `AppSettingsHelper.cs`.

## Defining Infrastructure

The template includes database and cache by default. If you need to add other infrastructure, such as message queues, vector databases, etc., or add other projects, such as frontend/Python projects, etc., they can all be defined here.

In the [component library](https://aspire.dev/integrations/gallery/), you can find components that support Aspire integration. The official documentation provides detailed instructions for integrating each component.


## Service Configuration ServiceDefaults

`ServiceDefaults` is used to define the default configuration of services. It is in the `Definition/ServiceDefaults` directory, including:

- `Extensions`, used to configure `Aspire`'s observability, logging, health checks, service discovery and other functions.
- `FrameworkExtensions`, provides extension methods to configure framework-dependent options, user context, DbContext and cache and other infrastructure.
- `WebExtensions`, used to configure Web-related options, such as CORS, authentication and authorization, localization, Swagger, rate limiting and other middleware.

In services, you can apply default configurations by calling these extension methods:

```csharp
// Program.cs

var builder = WebApplication.CreateBuilder(args);
// Shared basic services: health check, service discovery, opentelemetry, http retry etc.
builder.AddServiceDefaults();
// Framework dependency services: options, cache, dbContext
builder.AddFrameworkServices();
// Web middleware services: route, openapi, jwt, default cors, auth, rateLimiter etc.
builder.AddMiddlewareServices();
// app services

// add Managers, auto generate by source generator
builder.Services.AddManagers();
// add modules, auto generate by source generator
builder.AddModules();

WebApplication app = builder.Build();
app.MapDefaultEndpoints();
app.UseMiddlewareServices();

app.Run();
```

Please modify these default configurations according to actual needs to meet your project requirements. Please note that configurations in `ServiceDefaults` are usually applied to all services.
If there are different configurations between services, please configure them separately in each service to override.

