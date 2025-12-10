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

这里主要关注`Components`节点，它定义了应用所使用的组件类型，
- `Cache` 选项包括：`memory`（内存缓存）、`redis`（Redis缓存）或`hybrid`（混合缓存）；
- `Database`选项包括：`SqlServer`或`PostgreSQL`
- `IsMultiTenant`用于启用多租户功能

### 多租户配置

框架默认是兼容多租户模式的，你只需要在配置文件中将`IsMultiTenant`设置为`true`即可启用多租户功能。

如果你确定现在和未来都不需要多租户功能，可以修改`EntityBase`继承的接口，从`ITenantEntityBase`改为`IEntityBase`，这样不会包含`TenantId`字段。

> [!IMPORTANT]
> 当启用多租户时，务必继承`ITenantEntityBase`接口，以确保实体类包含`TenantId`字段，从而支持多租户数据隔离。

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

