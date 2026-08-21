# 使用Aspire配置开发环境

**AppHost**是`Aspire`的宿主项目，它提供给开发者通过代码来定义基础设施和服务的能力，它不仅仅针对微服务开发提供支持，还能满足传统单体应用的需求。

## 配置文件

AppHost是一个标准的`.NET`应用程序，因此它支持通过`appsettings.json`文件来进行配置。

我们先看一下`appsettings.Development.json`的示例：
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
    "Cache": "Memory",
    // SqlServer/PostgreSQL
    "Database": "PostgreSQL",
    // enable multi-tenant features
    "IsMultiTenant": false
  }
}
```

这里主要关注`Components`节点，它定义了应用所使用的组件类型，
- `Cache` 选项包括：`Memory`（内存缓存）、`Redis`（Redis缓存）或 `Hybrid`（混合缓存）；只有选择 `Redis` 或 `Hybrid` 时 AppHost 才会创建 Redis；
- `Database`选项包括：`SqlServer`或`PostgreSQL`
- `IsMultiTenant`是租户配置项；当前`ApiStandard`单租户和多租户都使用Tenant目录、TenantId字段和全局租户过滤。不同租户是否使用独立数据库连接由Tenant记录和`AppDbFactory`决定。

AppHost 会把 `Cache`、`Database` 和 `IsMultiTenant` 统一以 `Components__Cache`、`Components__Database` 和 `Components__IsMultiTenant` 环境变量传给服务，因此不需要在每个服务中重复修改基础设施选择。Aspire 通过 `OTEL_EXPORTER_OTLP_ENDPOINT` 注入 OTLP 导出地址。

服务自身的认证、登录安全策略、缓存过期时间、SMTP、SMS、S3 和 CORS 配置仍应放在服务配置中。完整字段、默认值和环境变量写法请参考[模板配置参考](./配置参考.md)。

### 多租户配置

框架默认始终使用租户感知的数据模型。单租户环境也会初始化默认Tenant，并在认证后的`UserContext`中提供TenantId；多租户环境可以进一步为不同Tenant配置独立数据库连接。`IsMultiTenant`不会关闭TenantId字段、全局过滤器或保存校验。

如果你确定现在和未来都不需要多租户功能，可以修改`EntityBase`继承的接口，从`ITenantEntityBase`改为`IEntityBase`，这样不会包含`TenantId`字段。

> [!IMPORTANT]
> 业务实体如果需要参与模板默认的数据访问，应继承`EntityBase`或实现`ITenantEntityBase`，以确保实体类包含`TenantId`字段并参与统一的租户数据隔离。该规则不依赖`IsMultiTenant`的值。

### 集成前端

Aspire支持将其他各种项目集成到AppHost中，例如前端项目、Python项目等。如以下添加一个前端项目：
```csharp
var webApp = builder.AddJavaScriptApp("frontend", "../ClientApp/WebApp", "start")
    .WithPnpm()
    .WithUrl("http://localhost:4200")
    .WaitFor(adminService)
    .WithParentRelationship(serviceGroup);
```

> 注意：模板默认不启动前端。只有在选择 Angular、运行 `pnpm install` 并在 AppHost 中启用该资源后，`AddJavaScriptApp(...).WithPnpm()` 才会执行前端的 `start` 脚本。

### 基础设施配置

你可以通过代码的方式在 `AppHost.cs`中定义各种基础设施，默认的密码和端口在`AppSettingsHelper.cs`中进行了定义，你可以根据你的需要进行修改。


## 自定义数据库连接字符串

模板默认在本地启动容器，以支持开发环境。有些情况，你可能需要使用自定义的数据库连接字符串，可以在`appsettings.json`中进行配置：

```json
{
  "ConnectionStrings": {
    "Default": "Server=your_server;Database=your_database;User Id=your_user;Password=your_password;",
    "Cache":"your_cache_connection_string"
  }
}
```

然后在`AppHost.cs`中使用:

```csharp
var database = builder.AddConnectionString("Default");
var cache = builder.AddConnectionString("Cache");
```

其他服务能够自动从环境变量中获取到这些连接字符串，这样可以在AppHost统一定义所有服务依赖的资源，统一管理，而不需要在每个服务的配置文件中重复定义。

这种方式适合使用公共的资源，而不需要每次在本地启动数据库容器。

> [!TIP]
> 你可以通过`AppSettingsHelper.cs`来获取和管理这些配置。

## EF Core 迁移与初始化数据

`ApiStandard` 在 `AppHost` 中使用 `AddEFMigrations` 创建迁移资源。本地运行通过 `RunDatabaseUpdateOnStart()` 更新数据库；发布到 Kubernetes 时生成一次性的迁移 Job。默认租户通过 EF Core `UseSeeding` 和 `UseAsyncSeeding` 幂等初始化。

详细流程请参阅[数据库迁移与初始化](../最佳实践/数据库.md)和[发布应用](../教程/发布应用.md)。

## 定义基础设施

模板默认包含了数据库和缓存，如果你需要添加其他基础设施，如消息队列，向量数据库等，或者添加其他的项目，如前端/python项目等，都可以在此处进行定义。

在[组件库中](https://aspire.dev/integrations/gallery/)，你可以查找支持Aspie集成的组件，官方文档提供了对每个组件集成的详细说明。


## 服务配置ServiceDefaults

`ServiceDefaults`用于定义服务的默认配置，它在`Definition/ServiceDefaults`目录下，包括：

- `Extensions`，用于配置`Aspire`的可监测性、日志、健康检查、服务发现等功能。
- `FrameworkExtensions`，提供扩展方法，用来配置框架依赖的选项、用户上下文、DbContext和缓存等基础设施。
- `WebExtensions`，用于配置Web相关的选项，如CORS、认证授权、本地化、Swagger、速率限制等中间件。

在服务中，可以通过调用这些扩展方法来应用默认配置：

```csharp
// Program.cs

var builder = WebApplication.CreateBuilder(args);
// 共享基础服务:health check, service discovery, opentelemetry, http retry etc.
builder.AddServiceDefaults();
// 框架依赖服务:options, cache, dbContext
builder.AddFrameworkServices();
// Web中间件服务:route, openapi, jwt, default cors, auth, rateLimiter etc.
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

请根据实际需求，修改这些默认配置，以满足你的项目需求。请注意，`ServiceDefaults`中的配置通常应用到所有服务。
如果是服务间不同的配置，请在各自服务中进行单独配置覆盖。

