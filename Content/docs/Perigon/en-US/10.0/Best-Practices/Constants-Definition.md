# Constants Definition

In projects, we often define some constants or static variables to store immutable data. To improve code readability and maintainability, it is recommended to centrally manage these constants.

## Shared Constants

In the `Constants` directory of the `Share` assembly, it is specifically used to define shared constants or static variables, which may be referenced by other modules or services.

## Dedicated Constants

If some constants are only used in specific modules or services, they should be defined in the corresponding modules or services, not in the shared constants directory.

## Extension Methods

In the base class library `Perigon.AspNetCore`, constants are defined using `AppConst`. If you still want to use `AppConst`, you can implement it through extension methods.

In C# 14, we can create a new static class in the `Share/Constants` directory, such as `AppExtensions`, specifically used to extend application-level variables and methods, such as:

```csharp
public static class AppExtensions
{
    extension(Perigon.AspNetCore.Constants.AppConst)
    {
        public static string AIAgent => "AIAgent";
    }
}
```

Then we can directly use `AppConst.AIAgent` to access this variable in the code.

> [!TIP]
> If you are prompted that the defined variable or extension method cannot be found when using it, try manually adding the namespace reference.
