# Logging

Logging tracks application state, aids debugging, and records key events.

## Application Logs

ASP.NET Core includes built-in logging with multiple providers. Aspire exports logs via OpenTelemetry to collectors. Configure via the `OTEL_EXPORTER_OTLP_ENDPOINT` environment variable.

## Business Logs

Business logs record operations on specific objects—distinct from request logs and not easily centralized.

Example: "User Alice deleted blog 'Code Quality'" requires filtering by user, action, module, and object.

The pattern below supports this:

## Background Queues for Log Writing

Write business logs to the database but use background queues to avoid blocking business code.

`SystemMod` includes `SystemLogTaskHostedService.cs` in the `Worker` directory as a reference. To use it:

```csharp
services.AddSingleton(typeof(EntityTaskQueue<SystemLogs>));
services.AddSingleton(typeof(SystemLogService));
services.AddHostedService<SystemLogTaskHostedService>();
```

Then enqueue log objects via `EntityTaskQueue` in business code.

## Log Factory Method

Add a factory method to `SystemLogs.cs`:

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

## Manager Logging Helper

Encapsulate log creation in a Manager method for controller use:

```csharp
public async Task SaveLoginLogAsync(SystemUser user, string description)
{
    var log = SystemLogs.NewLog(user.UserName, user.Id, "Login", ActionType.Login, description: description);
    await _taskQueue.AddItemAsync(log);
}
```

## Business Log Service

Wrap into a reusable service. See `SystemLogService` in SystemMod:

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
