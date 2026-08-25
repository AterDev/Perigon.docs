# AI Support in the Template

The `ApiStandard` template provides an `AGENTS.md` file at the project root and reusable AI skills under `.agents/skills`. Together they describe the project structure, technical constraints, code-generation entry points, and validation expectations. AI tools that support these files can use them to establish reliable project context before performing a task.

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
    ├── dotnet-inspect/
    ├── docs/
    │   └── references/
    │       ├── pm.md
    │       └── dev-plan.md
    ├── code-review/
    └── commit-message/
```

`SKILL.md` is the entry point for each skill. A skill loads its focused `references` only when the task needs them, so an agent does not have to paste the complete project policy into every conversation.

## Project rules from `AGENTS.md`

The project-level guidance establishes these important rules:

- Prefer deterministic, accurate work: inspect facts and existing code before using a command, path, or project structure; do not guess.
- Validate code changes with a build, test, or another check appropriate to the change.
- The baseline is C# 14, Aspire 13+, ASP.NET Core 10, and EF Core 10; Angular is the default frontend technology.
- The project is organized around `src/ClientApp/WebApp`, `src/Services`, `src/Definition/Entity`, `src/Modules`, `src/Definition/Share`, `src/Definition/ServiceDefaults`, `tests`, `scripts`, and `templates`.
- DTOs belong under a module's `Models/{Entity}Dtos` directory. Keep one type per file, use a `Dto` suffix for data-transfer types, and do not replace DTOs with names containing `Input`, `Request`, or `Response`.
- Prefer Perigon for scaffolding, adding modules/services, code generation, OpenAPI clients, and MCP configuration. Prefer the Aspire CLI for AppHost startup, resource state, logs, traces, and distributed-app configuration.
- Before implementation, planning, or review, read the `perigon` and `aspire` entry skills. UI work also requires `ux` and the reference for the target platform.

These rules provide AI workflow context; they do not replace the compiler, tests, or code review for the project.

## Available skills

| Skill | Use it for |
| --- | --- |
| `perigon` | Perigon CLI, scaffolding, adding modules/services, generating entities and DTOs/Managers/Controllers, OpenAPI request clients, module packages, and MCP/Studio; see `references/perigon-cli.md` for command details. |
| `aspire` | The top-level router for Aspire AppHost work, directing tasks to startup, orchestration, deployment, or monitoring workflows. |
| `aspire-orchestration` | `aspire start`, `wait`, `describe`, resource restarts, file locks, port conflicts, and isolated local runs. |
| `ux` | Page and interaction design for Angular Material + Bootstrap, WPF/Avalonia, and Android Material, including states, responsiveness, and accessibility. |
| `test` | TUnit, Microsoft.Testing.Platform, Aspire.Hosting.Testing, unit tests, API integration tests, and AppHost tests. |
| `dotnet-inspect` | Querying types, members, extension methods, implementors, dependencies, and version differences in NuGet, platform, and local assemblies. |
| `docs` | Requirement analysis, development task plans, and documentation work; load `references/pm.md` or `references/dev-plan.md` as needed. |
| `code-review` | Reviewing architecture, quality, performance, security, and frontend/backend consistency against project conventions. |
| `commit-message` | Generating Conventional Commits messages from the actual Git diff and the project's commit context. |

`perigon` and `aspire` are the primary entry skills. `aspire` routes distributed-app work, while `aspire-orchestration` handles concrete local lifecycle operations; ordinary builds and tests should not be delegated to the Aspire workflow.

## Recommended workflow

1. Read `AGENTS.md`, then load `perigon`, `aspire`, or another focused skill for the task.
2. Prefer Perigon CLI/MCP when creating solutions, modules, services, or generated code; inspect `perigon <command> -h` before running a command.
3. For Aspire runtime work, use commands such as `aspire start`, `aspire wait`, and `aspire describe` instead of substituting `dotnet run` for the AppHost workflow.
4. When generating DTOs or changing a module, check the directory, file granularity, type names, and all references together.
5. Run the appropriate build or tests after a change, and use the code-review skill for high-risk changes.

See [MCP](./MCP.md) for Perigon Agent MCP setup and code-generation capabilities.
