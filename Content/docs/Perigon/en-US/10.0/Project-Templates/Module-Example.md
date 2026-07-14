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
| `Perigon.SystemMod` | Administration and identity/authorization foundation | Administrator users, roles, permissions, menus, organizations, system configuration, and logs; includes initialization and asynchronous log processing. |
| `Perigon.CMSMod` | Content management | Administrative management for articles and article categories. |
| `Perigon.ResourceMod` | Tenant-aware general resource management | Manages resource environments, categories, groups, tags, resource definitions, and dynamic properties, with resource access permissions by role, environment, and category. |

### SystemMod

`SystemMod` provides the foundation domain model for administration: users, roles, permissions, permission groups, menus, organizations, and system configuration. It also provides system logging and background processing. Install it first when the project needs administrative sign-in, role authorization, or another official module depends on role capabilities.

```pwsh
perigon module install Perigon.SystemMod AdminService
```

### CMSMod

`CMSMod` provides basic content management with article categories and articles. It is suitable for projects that manage articles, announcements, or other structured content in the administration application.

```pwsh
perigon module install Perigon.CMSMod AdminService
```

### ResourceMod

`ResourceMod` is the new general resource management module. It manages tenant-aware resources that can be categorized and configured with dynamic properties. Resource creation depends on environments, categories, and resource definitions, with optional groups and tags; a resource definition controls dynamic-property names, types, required flags, and length constraints.

The module also configures resource access by “role + environment + category”: administrators maintain resources and configuration, while non-administrators can read only resources returned by the server according to their permissions. It is suited to catalogs of internal services, assets, links, environments, or other resources that need categorization and access control.

```pwsh
perigon module install Perigon.ResourceMod AdminService
```

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
