# Official Perigon Modules

Official Perigon modules are maintained in the [Perigon.Modules](https://github.com/AterDev/Perigon.Modules) repository and can be installed as needed. The catalog in the repository's `modules.json` is the source of truth.

| Package | Main use | Guide |
| --- | --- | --- |
| `Perigon.SystemMod` | Identity, administration, and authorization configuration | [SystemMod](./SystemMod.md) |
| `Perigon.CMSMod` | Article and category management | [CMSMod](./CMSMod.md) |
| `Perigon.ResourceMod` | Tenant-scoped resources, personal-resource review, and favorites | [ResourceMod](./ResourceMod.md) |

## Installation

Install a module in the solution containing the target service:

```pwsh
perigon module list
perigon module install Perigon.SystemMod AdminService
```

Modules are registered through the target service's `AddModules()` entry point and require the corresponding database migrations. If you use a module's Angular pages, restore its frontend files and menus as well. See the [module CLI guide](../Code-Generation/Command-Line.md) for command options, frontend packaging, and installation behavior.

Each guide covers current workflows, administration pages, API boundaries, and dependencies. Business modules are not included in the blank template by default.
