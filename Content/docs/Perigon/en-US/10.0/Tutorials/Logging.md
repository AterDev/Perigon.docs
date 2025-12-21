# Logging

Logging is an indispensable part of development. It can help us track the application's running status, debug problems, and record important events.

## Application Logs

ASP.NET Core provides built-in logging functionality that supports multiple logging providers. `Aspire` builds on this by exporting log information to log collectors through the `OpenTelemetry` standard. You can set the log collector address through the `OTEL_EXPORTER_OTLP_ENDPOINT` environment variable.

## Business Logs

Business logs are recorded based on actual business needs when operating on specific objects.

This is different from request log recording and cannot be uniformly intercepted and processed.

Such as the following requirement scenario:
User Zhang San deleted a blog "The Quality of Programmers", which needs to be recorded in the log: Zhang San deleted the blog: The Quality of Programmers.

And can filter logs according to user (Zhang San), operation (delete), module (blog), object (The Quality of Programmers).

To implement this kind of business requirement, we provide an implementation method.

## Using Background Queue to Execute Log Recording

Usually we will write business logs to the database for subsequent filtering and querying.

We will execute log writing operations through background queues to avoid blocking the execution of normal business code.

The `SystemLogTaskHostedService.cs` in the `Worker` directory of the `SystemMod` module provides an implementation example.

If you use it, add this service to dependency injection, such as:

```csharp
services.AddSingleton(typeof(EntityTaskQueue<SystemLogs>));
services.AddSingleton(typeof(SystemLogService));
services.AddHostedService<SystemLogTaskHostedService>();
```

Next, we can add log objects to the queue through `EntityTaskQueue` in other business code.

## Recording Logs on Demand

We can add a static method to the `SystemLogs.cs` entity, such as:

```csharp
public static SystemLogs NewLog(string userName, Guid userId, string targetName, ActionType actionType, string? route = null, string? description = null)
{
    return new SystemLogs
    {
        SystemUserId = userId,
        ActionUserName = userName,
        TargetName = targetName,
        Route = route ?? string.Empty,
        ActionType = actionType,
        Description = description,
    };
}
```

### Adding Log Recording Method in Manager

We can encapsulate the log recording method in `Manager` for calling in the controller, such as recording login logs:

```csharp
public async Task SaveLoginLogAsync(SystemUser user, string description)
{
    var log = SystemLogs.NewLog(user.UserName, user.Id, "Login", ActionType.Login, description: description);
    await _taskQueue.AddItemAsync(log);
}
```

### Encapsulating Business Log Service

We can encapsulate business logs into a service for use elsewhere. You can view `SystemLogService` in SystemMod.

```csharp
using Ater.Web.Extension;

namespace SystemMod;
/// <summary>
/// Business log service
/// </summary>
public class SystemLogService
{
    private readonly IServiceProvider _serviceProvider;
    private readonly EntityTaskQueue<SystemLogs> _taskQueue;
    private readonly IUserContext _context;

    /// <summary>
    /// 
    /// </summary>
    /// <param name="serviceProvider"></param>
    /// <param name="taskQueue"></param>
    public SystemLogService(IServiceProvider serviceProvider, EntityTaskQueue<SystemLogs> taskQueue)
    {
        _serviceProvider = serviceProvider;
        _taskQueue = taskQueue;
        _context = _serviceProvider.CreateScope().ServiceProvider.GetRequiredService<IUserContext>();
    }

    /// <summary>
    /// Record log, prioritize getting user information from UserContext
    /// For anonymous user access, need to pass userName and userId
    /// </summary>
    /// <param name="targetName"></param>
    /// <param name="actionType"></param>
    /// <param name="description"></param>
    /// <param name="userName"></param>
    /// <param name="userId"></param>
    /// <returns></returns>
    public async Task NewLog(string targetName, ActionType actionType, string description, string? userName = null, Guid? userId = null)
    {
        userId = _context.UserId == Guid.Empty ? userId : _context.UserId;
        userName = string.IsNullOrEmpty(_context.Username) ? userName : _context.Username;
        var route = _context!.GetHttpContext()?.Request.Path.Value;

        if (userId == null || userId.Equals(Guid.Empty))
        {
            return;
        }
        var log = SystemLogs.NewLog(userName ?? "", userId.Value, targetName, actionType, route, description);
        await _taskQueue.AddItemAsync(log);
    }
}

```

Then you can use this service to record business logs in other controllers or Managers.

> [!TIP]
> The above example can be found in `SystemMod`. You can refer to it to implement your own logging service.
