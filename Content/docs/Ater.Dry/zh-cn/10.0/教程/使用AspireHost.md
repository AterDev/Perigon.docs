# 使用AspireHost

AspireHost基于.NET Aspire，提供了强大且简便的本地开发环境，它不仅仅针对微服务开发提供支持，还能满足传统单体应用的需求。

## 定义基础设施

通过C#代码，可以非常方便的定义应用所需要的基础设计，如数据库/缓存/消息队列等，模板已经内置了特定版本的数据库和缓存组件，如:

```csharp
IResourceBuilder<IResourceWithConnectionString>? database = null;
IResourceBuilder<IResourceWithConnectionString>? cache = null;

var devPassword = builder.AddParameter(
    "sql-password",
    value: aspireSetting.DbPassword,
    secret: true
);
var cachePassword = builder.AddParameter(
    "cache-password",
    value: aspireSetting.CachePassword,
    secret: true
);

_ = aspireSetting.DatabaseType?.ToLowerInvariant() switch
{
    "postgresql" => database = builder
        .AddPostgres(name: "db", password: devPassword, port: aspireSetting.DbPort)
        .WithImageTag("17.6-alpine")
        .WithDataVolume()
        .AddDatabase(AppConst.Database, databaseName: "MyProjectName_dev"),
    "sqlserver" => database = builder
        .AddSqlServer(name: "db", password: devPassword, port: aspireSetting.DbPort)
        .WithImageTag("2025-latest")
        .WithDataVolume()
        .AddDatabase(AppConst.Database, databaseName: "MyProjectName_dev"),
    _ => null,
};

_ = aspireSetting.CacheType?.ToLowerInvariant() switch
{
    "memory" => null,
    _ => cache = builder
        .AddRedis("Cache", password: cachePassword, port: aspireSetting.CachePort)
        .WithImageTag("8.2-alpine")
        .WithDataVolume()
        .WithPersistence(interval: TimeSpan.FromMinutes(5)),
};    
```

在`AppSettingsHelper.cs`中，你可以找到默认的密码和端口。

在运行时，它将以容器的方式启动这些基础设施，并且会自动配置网络和连接字符串，确保你的应用可以顺利连接到这些服务。

## 使用现有的服务

如果你已经有现成的数据库或缓存服务，如共用的开发环境，而不是本地环境，你可以直接进行配置，如：

```csharp
var database = builder.AddConnectionString("Default");
```

其中`Default`是你在`appsettings.json`中配置的连接字符串名称，如

```json
{
  "ConnectionStrings": {
    "Default": "Server=your_server;Database=your_database;User Id=your_user;Password=your_password;"
  }
}
```