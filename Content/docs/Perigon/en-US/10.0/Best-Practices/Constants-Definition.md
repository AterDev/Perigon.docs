# Constants Definition

In projects, we often define constants or static variables to store immutable data. To improve code readability and maintainability, it's recommended to centrally manage these constants.

## Shared Constants

In the `Constants` directory of the `Share` assembly, define shared constants or static variables that may be referenced by other modules or services.

## Module-Specific Constants

If constants are only used in specific modules or services, define them in the corresponding module or service, not in the shared constants directory.

## Extension Methods

In the base class library `Perigon.AspNetCore`, constants are defined using `AppConst`. If you want to extend `AppConst`, use extension methods.

In C# 14, you can create a new static class in the `Share/Constants` directory, such as `AppExtensions`, to extend application-level variables and methods:

```csharp
public static class AppExtensions
{
    extension(Perigon.AspNetCore.Constants.AppConst)
    {
        public static string AIAgent => "AIAgent";
    }
}
```

Then you can directly use `AppConst.AIAgent` in your code.

> [!TIP]
> If you can't find a defined variable or extension method, try manually adding the namespace reference.
