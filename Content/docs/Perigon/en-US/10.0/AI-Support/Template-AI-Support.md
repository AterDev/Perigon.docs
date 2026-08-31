# AI Support in the Template

Both `ApiStandard` and `MiniApi` provide an `AGENTS.md` file at the project root and reusable AI skills under `.agents/skills`. They share the iteration-documentation and delivery loop, but their backend constraints differ: ApiStandard targets Controllers and business modules, while MiniApi targets Minimal APIs, Native AOT, and trimming.

## File layout

The template's AI guidance is primarily organized as follows:

```text
AGENTS.md
.agents/
└── skills/
    ├── perigon/
    │   └── references/
    │       ├── angular.md
    │       ├── backend.md
    │       └── perigon-cli.md
    ├── aspire/
    │   └── references/
    ├── aspire-orchestration/
    │   └── references/
    ├── ux/
    │   └── references/
    │       ├── common.md
    │       ├── web.md
    │       ├── desktop.md
    │       └── phone.md
    ├── test/
    ├── native-aot/            # MiniApi
    ├── delivery-loop/
    ├── dotnet-inspect/
    ├── docs/
    │   └── references/
    │       ├── requirements.md
    │       ├── design.md
    │       └── plan-tasks.md
    ├── code-review/
    └── commit-message/
```

`SKILL.md` is the entry point for each skill. A skill loads its focused `references` only when the task needs them, so an agent does not have to paste the complete project policy into every conversation.

## Iteration documentation model

`Demand.md` and `Design.md` are project-wide requirement/design summaries and indexes; they do not contain every feature's details. Product design and development plans are organized by iteration and feature module:

```text
docs/
├── UserStory/
│   ├── Demand.md
│   ├── Design.md
│   └── Iter0-Initial/PD0001-Initial.md
└── Development/
    ├── ProjectTracking.md
    └── Iter0-Initial/PT0001-Initial.md
```

- Iteration directories use `Iter<number>-<Name>`.
- `PD####-Name.md` is a Product Design for one feature module in an iteration, including requirements, scenarios, and design.
- `PT####-Name.md` is a Plan Task linked to its source PD, including tasks, dependencies, progress, implementation results, and verification evidence.
- PD/PT numbers are four-digit, monotonically increasing, and not reused within an iteration. Each document focuses on one feature module.

Both templates include `Iter0-Initial/PD0001-Initial.md` and `Iter0-Initial/PT0001-Initial.md` as their initial product-design and plan-task templates. A MiniApi PT also records the AOT impact decision, publish/runtime evidence, or the reason that validation was not run.

## Project rules from `AGENTS.md`

The project-level guidance establishes these important rules:

- Prefer deterministic, accurate work: inspect facts and existing code before using a command, path, or project structure; do not guess.
- Validate code changes with a build, test, or another check appropriate to the change.
- The baseline is C# 14, Aspire 13+, ASP.NET Core 10, and EF Core 10; Angular is the default frontend technology.
- ApiStandard places business code under `src/Modules` and exposes it through Controllers. MiniApi uses `ApiService/Endpoints/Managers/Models/Services` and does not assume an AdminService, Controllers, a Modules layer, or a built-in migration resource.
- A MiniApi endpoint group derives from `RestEndpointBase` and is registered through a static `MapEndpoints` method and the generated `MapEndpointGroups()` call. Typed handlers, parameter binding, and JSON contracts must remain statically analyzable for AOT.
- Prefer Perigon for scaffolding, adding modules/services, code generation, OpenAPI clients, and MCP configuration. Prefer the Aspire CLI for AppHost startup, resource state, logs, traces, and distributed-app configuration.
- Before planning, implementing, or reviewing Perigon business code, read `perigon`; read `aspire` only when the task crosses AppHost or distributed-runtime boundaries. UI work also requires `ux` and the reference for the target platform.
- A checked task is only a progress index. Do not claim completion without implementation evidence and the required checks passing.
- After every AI coding run, update the active PT's checkboxes, progress, implementation record, and verification evidence, then synchronize `ProjectTracking.md`. Also update the source PD when observable behavior or design changed.

These rules provide AI workflow context; they do not replace the compiler, tests, or code review for the project.

## Available skills

| Skill | Use it for |
| --- | --- |
| `perigon` | Perigon CLI, scaffolding, adding modules/services, generating entities and DTOs/Managers/Controllers, OpenAPI request clients, module packages, and MCP/Studio; see `references/perigon-cli.md` for command details. |
| `aspire` | The top-level router for Aspire AppHost work, directing tasks to startup, orchestration, deployment, or monitoring workflows. |
| `aspire-orchestration` | `aspire start`, `wait`, `describe`, resource restarts, file locks, port conflicts, and isolated local runs. |
| `ux` | Page and interaction design for Angular Material + Bootstrap, WPF/Avalonia, and Android Material, including states, responsiveness, and accessibility. |
| `test` | TUnit, Microsoft.Testing.Platform, Aspire.Hosting.Testing, unit tests, API integration tests, and AppHost tests. |
| `native-aot` | MiniApi Request Delegate Generator and JSON metadata checks, reflection/dynamic-code and dependency review, trimming warnings, Native AOT publish, and runtime validation. |
| `dotnet-inspect` | Querying types, members, extension methods, implementors, dependencies, and version differences in NuGet, platform, and local assemblies. |
| `docs` | Iteration PD/PT documents, project indexes, implementation records, and change notes that trace requirements through tasks, code, and verification. |
| `delivery-loop` | Executing or read-only auditing PD/PT documents. Implementation mode verifies ready tasks and must synchronize documentation after every coding increment. |
| `code-review` | Read-only review of completeness, correctness, security, performance, architecture, and test evidence against requirements and project conventions. |
| `commit-message` | Generating Conventional Commits messages from the actual Git diff and the project's commit context. |

`perigon` and `aspire` are the primary entry skills. `aspire` routes distributed-app work, while `aspire-orchestration` handles concrete local lifecycle operations; ordinary builds and tests should not be delegated to the Aspire workflow.

## Recommended workflow

1. Read `AGENTS.md`, then load `perigon`, `aspire`, or another focused skill for the task.
2. Prefer Perigon CLI/MCP when creating solutions, modules, services, or generated code; inspect `perigon <command> -h` before running a command.
3. For Aspire runtime work, use commands such as `aspire start`, `aspire wait`, and `aspire describe` instead of substituting `dotnet run` for the AppHost workflow.
4. When generating DTOs or changing a module, check the directory, file granularity, type names, and all references together.
5. Run the appropriate build or tests after a change, and use the code-review skill for high-risk changes.
6. For every AI coding change, use `delivery-loop` for implement → verify → update PT/ProjectTracking/PD → converge. Even a small fix uses a concise PT implementation record.
7. In MiniApi, also use `native-aot` when changing endpoints, DTO/JSON behavior, reflection, dependencies, EF models, or publish settings. A normal build is not a substitute for Native AOT publish evidence.

See [MCP](./MCP.md) for Perigon Agent MCP setup and code-generation capabilities.
