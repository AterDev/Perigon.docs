# Official Modules

Official Perigon modules are maintained in the [Perigon.Modules](https://github.com/AterDev/Perigon.Modules) repository. You can select them while creating a solution, or list and install them later:

```pwsh
perigon module list
perigon module install Perigon.SystemMod AdminService
```

Current templates do not add these modules by default. Each module is a separate assembly ending in `Mod`; business code and DTOs are under `src/Modules/{Name}Mod`, while entities are under `src/Definition/Entity/{Name}Mod`.

## Official module catalog

| Module | Use case | Main capabilities |
| --- | --- | --- |
| [`Perigon.SystemMod`](../Modules/SystemMod.md) | Administration and identity/authorization foundation | Users, roles, menus, system configuration and logs, data scopes, and group membership management. |
| [`Perigon.CMSMod`](../Modules/CMSMod.md) | Content management | Article categories, article editing, and article image uploads. |
| [`Perigon.ResourceMod`](../Modules/ResourceMod.md) | Tenant-aware general resource management | Environments, categories, definitions, dynamic properties, role-based access, personal-resource review, and favorites. |

Each module has a dedicated guide covering its workflows, administration pages, APIs, and boundaries. The official package catalog is maintained in `Perigon.Modules/modules.json`.

## Package contents and frontend

Official module packages always contain the backend entities, module assembly, controllers, and metadata required by the module. When packaging supplies `--front-path`, the package also contains the frontend module directory and its sibling `share` directory:

```text
Frontend/{module}/...
Frontend/share/...
```

When installing a package with frontend content, point `--front-path` to the target frontend `modules` root. The module and `share` are restored beneath that directory. Module files overwrite same-named files; same-named files already in `share` are preserved.

Module packages do not contain the frontend application shell, root dependency configuration, or npm/pnpm dependencies, and they do not modify the target service's `Program.cs`. See the [command-line documentation](../Code-Generation/Command-Line.md) for complete frontend packaging usage and limitations.

## CommonMod

`CommonMod` is a reserved module for reusable foundations shared by multiple modules. It is not an optional business module in the official module catalog.
