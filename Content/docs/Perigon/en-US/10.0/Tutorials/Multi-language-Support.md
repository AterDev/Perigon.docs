# Multi-language Support

Multi-language support is the default implementation of the framework. You can find the related service configuration in `AddLocalizer` in `WebExtensions.cs`.

> [!NOTE]
> Multi-language support is based on the globalization and localization features of `ASP.NET Core`. For specific usage, please refer to [ASP.NET Core Globalization and Localization](https://docs.microsoft.com/en-us/aspnet/core/fundamentals/localization/?view=aspnetcore-10.0).

## Using Multi-language

In the `Definition/Share` project, you can see multi-language related resource files, which are usually collapsed under the `Localizer.cs` file in VS.

Open any resource file and add or modify the corresponding key-value pairs.

After adding, the `Perigon.AspNetCore.SourceGeneration` source code generator will automatically generate corresponding constants (partial class) in `Localizer`.

You can inject `Localizer localizer` anywhere you need to use multi-language. It is a wrapper of `IStringLocalizer<Localizer>`:

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

By default, controllers all inherit from `RestControllerBase` and need to inject `Localizer`. The base class has rewritten common MVC methods such as `BadRequest`, `NotFound`, etc. to support multi-language. You can call them very conveniently:

```csharp
return BadRequest(Localizer.UserNotFound);
```

In the `Manager` business implementation class, content can support multi-language by throwing `BusinessException`, such as:

```csharp
throw new BusinessException(Localizer.UserNotFound);
```

`GlobalExceptionMiddleware` will catch this exception and return the multi-language content to the client.
