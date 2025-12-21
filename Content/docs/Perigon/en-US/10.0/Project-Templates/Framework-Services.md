# Service Injection

The template adds and injects services and options needed for application operation by default. These are all injected through extension methods.

## ServiceDefaults

In `ServiceDefaults`, some options and services commonly used by application services are defined. They can be roughly divided into three categories:

| File                   | Method                | Description                           |
| ---------------------- | --------------------- | ------------------------------------- |
| Extension.cs           | AddServiceDefaults    | Aspire related configuration and components |
| FrameworkExtensions.cs | AddFrameworkServices  | Basic services and options (database/cache, etc.) |
| WebExtensions.cs       | AddMiddlewareServices | Web middleware related services       |

You can add more shared services and options in the corresponding extension methods.

If you need customization, you can add and override in `Program.cs`.

```csharp
// Program.cs

// Shared basic services: health check, service discovery, opentelemetry, http retry etc.
builder.AddServiceDefaults();
// Framework dependency services: options, cache, dbContext
builder.AddFrameworkServices();
// Web middleware services: route, openapi, jwt, cors, auth, rateLimiter etc.
builder.AddMiddlewareServices();
// ...custom services
```

## Automatic Injection

All business implementation (inheriting `ManagerBase`) classes will generate injection code through the code generator;

If the module implements the `ModuleExtensions` extension class, injection code will be generated through the code generator;

You only need to call in the `Program.cs` of the API service:

```csharp
// Business Managers
builder.Services.AddManagers();

// Module services
builder.AddModules();
```
