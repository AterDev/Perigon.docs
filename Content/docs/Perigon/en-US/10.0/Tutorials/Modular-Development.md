# Modular Development

Modules are relatively independent business units, usually organized by business domain. Modular development improves maintainability and reuse.

> Modules must use the `Mod` suffix.

## Managing Modules

You can manage modules from Studio. The module management UI can create or remove modules and update cross-project references for you.

You can also use the CLI from the solution root:

```pwsh
perigon add module <ModuleName>
```

If you need to add a service project, use:

```pwsh
perigon add service <ServiceName>
```

## Module Structure

A module is an independent project under `src/Modules`. It usually contains:

- `Models`: DTO models.
- `Managers`: business logic.
- `Services`: services used only by this module.
- `ModuleExtensions.cs`: extension methods for registering module services.

> [!TIP]
> The source generator automatically calls module registration methods from service projects. You do not need to call them manually for normal service registration.

Module entities are defined in `src/Definition/Entity` and are separated by module folder names.

## Reusing Modules

Modules can be reused across solutions. For example, a customer module or an order module can be packaged and installed into another solution.

### Packing a Module

Before packing a module, check `ModuleExtensions.cs`. This file is created with the module and describes the module registration entry:

```csharp
public static class ModuleExtensions
{
    [DisplayName("Perigon::XXX")]
    [Description("Registers XXX module services")]
    public static IHostApplicationBuilder AddXXXMod(this IHostApplicationBuilder builder)
    {
        builder.AddModServices();
        return builder;
    }

    private static IHostApplicationBuilder AddModServices(this IHostApplicationBuilder builder)
    {
        return builder;
    }

}
```

- `[DisplayName]`: author and package display name, separated with `::`, for example `Perigon::File Management`.
- `[Description]`: describes the module.
- `AddXXXMod`: registers module services.

> [!NOTE]
> In most cases, `AddXXXMod` should only contain services specific to the module.

The module to be packed should keep code inside the module project, except entities and controllers. If it references unexpected project code, the packing command will report an error.

Run the following command from the solution root:

```pwsh
perigon module pack <ModuleName> <ServiceName>
```

The generated module package is placed under the `package_modules` directory. To package a frontend module, use `--front-path` to specify that module directory; see the [command-line documentation](../Code-Generation/Command-Line.md) for the complete rules.

### Installing a Module

Run the following command from the solution root:

```pwsh
perigon module install <ModulePackagePath> <ServiceName>
```

After installation, reload the solution and check whether the module references and generated code are correct.
