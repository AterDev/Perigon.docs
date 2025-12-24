# Multi-language Support

Multi-language support is enabled by default. See `AddLocalizer` in `WebExtensions.cs` for the service configuration.

> [!NOTE]
> Built on ASP.NET Core globalization/localization. See: [ASP.NET Core Globalization and Localization](https://docs.microsoft.com/en-us/aspnet/core/fundamentals/localization/?view=aspnetcore-10.0).

## Using Localization

In the `Definition/Share` project you’ll find resource files (often nested under `Localizer.cs` in Visual Studio). Add or modify keys as needed.

`Perigon.AspNetCore.SourceGeneration` automatically generates constants in the `Localizer` partial class from these resources.

Inject `Localizer` wherever needed. It wraps `IStringLocalizer<Localizer>`:

```csharp
public partial class Localizer(IStringLocalizer<Localizer> localizer)
{
    public string Get(string key, params object[] arguments)
    {
        try
        {
            return localizer[key, arguments];
        }
        catch (Exception)
        {
            return key;
        }
    }
}
```

Controllers inherit `RestControllerBase` and inject `Localizer`. Common MVC responses like `BadRequest` and `NotFound` are overridden to support localization:

```csharp
return BadRequest(Localizer.UserNotFound);
```

In `Manager` classes, throw `BusinessException` to return localized content:

```csharp
throw new BusinessException(Localizer.UserNotFound);
```

`GlobalExceptionMiddleware` handles these exceptions and returns localized messages to clients.
