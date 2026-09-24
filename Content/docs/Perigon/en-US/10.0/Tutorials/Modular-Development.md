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

Business modules should remain independent and must not directly reference one another. For cross-module reuse, put foundational content such as common types, constants, and utilities in the `Share` project. If the shared content is a feature implementation that does not belong in `Share`, put it in the shared `CommonMod` module and let dependent business modules reference it. Do not make one business module depend on another specific business module.

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

Modules to be packed must follow the dependency rules above. The current CLI packaging check inspects module namespaces in C# `using` directives: module source and entity directories may reference the current module and `Share`; the selected service's controller directory may also reference `CommonMod`. As a result, a direct `CommonMod` reference from module source is currently rejected by `module pack`.

Run the following command from the solution root:

```pwsh
perigon module pack <ModuleName> <ServiceName>
```

The generated zip file is placed under `package_modules`. The package contains module metadata and the module and entity directories; controller and frontend files are included when available. A typical layout is:

```text
metadata.json
Modules/<ModuleName>/...
Entity/<ModuleName>/...
Controllers/<ModuleName>/...        # optional
Frontend/<frontend-module-name>/...  # when --front-path is specified
Frontend/share/...                  # when the sibling share directory exists
```

- `metadata.json` records the module name, author, display name, description, version, and other package metadata. Set the version with `-v/--version`; the default is `1.0.0`.
- In the pack command, `<ServiceName>` identifies the **source service for controllers**. The CLI checks only `src/Services/<ServiceName>/Controllers/<ModuleName>` and recursively packages its files when that directory exists. If it does not exist, no controllers are added. The command does not scan other services or select files by C# controller type. Files under `bin` and `obj` directories are skipped.
- To include a frontend module, use `--front-path` to specify its directory. The CLI packages that directory and its sibling `share` directory as `Frontend/<module-directory-name>` and `Frontend/share`. See the [command-line documentation](../Code-Generation/Command-Line.md) for details.

### Installing a Module

Run the following command from the solution root:

```pwsh
perigon module install <ModulePackagePath> <ServiceName>
```

In the install command, `<ServiceName>` is the **target service**. The CLI copies module files to `src/Modules/<ModuleName>` and entity files to `src/Definition/Entity/<ModuleName>`. If the package contains `Controllers/<ModuleName>`, those files are copied to `src/Services/<ServiceName>/Controllers/<ModuleName>`. Existing files at matching backend paths are overwritten.

After copying files, the CLI adds the module to the solution, adds a project reference from the target service to the module, and updates the service's `GlobalUsings.cs`. If it finds `DefaultDbContext.cs`, it also adds `DbSet` properties for module entities and the related Entity Framework global using. Make sure the target service directory exists.

If the package contains frontend files, pass `--front-path` with the frontend project root to restore them under `src/app/modules`. Existing files in the module directory are overwritten. Existing same-name files in `share` are kept, and only missing files are added. Reload the solution after installation and check that the module builds. See the [command-line documentation](../Code-Generation/Command-Line.md) for frontend details.
