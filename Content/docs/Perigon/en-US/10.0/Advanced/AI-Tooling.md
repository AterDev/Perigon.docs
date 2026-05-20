# AI Tooling in the Template

Perigon.template ships with complete AI tooling support out of the box. It includes GitHub Copilot configuration covering global instructions, custom agents, reusable skills, and prompts. This lets AI tools understand the project structure, follow project conventions, and assist with development tasks effectively.

## Configuration Layout

```
.github/
├── copilot-instructions.md       # Project-wide instructions: tech stack, directories, conventions
├── agents/
│   ├── engineer.agent.md         # Implementation engineer agent
│   └── reviewer.agent.md         # Code review agent
├── instructions/
│   ├── dotnet.instructions.md    # C#/.NET code rules (auto-applied to .cs/.csproj)
│   └── angular.instructions.md   # Angular front-end rules (auto-applied to .ts/.html)
└── prompts/
    ├── commit.prompt.md          # Conventional Commits message generation
    ├── development-plan.prompt.md # Generate a modular development plan from requirements
    └── angular-template.prompt.md # Generate Angular Razor CRUD page templates

.agents/skills/
├── backend/       # ASP.NET Core / EF Core / Aspire back-end conventions
├── angular/       # Angular front-end conventions
├── aspire/        # AppHost operations, resource status, logs, traces
├── aspireify/     # Initialize Aspire AppHost in an existing project
├── perigon/       # Perigon CLI/MCP scaffolding, code generation, client generation
├── test/          # TUnit integration test conventions
├── code-review/   # Code review standards
├── documentation/ # Technical documentation writing conventions
├── dotnet-inspect/# Query .NET assemblies, APIs, and extension methods
└── playwright-cli/# Browser automation and end-to-end testing
```

## Agents

Agents are custom GitHub Copilot modes with specific expertise. Invoke them in Copilot Chat using `@agent-name`.

### engineer

**Role**: Senior software engineer; owns the full loop from requirement to delivery.

**Capabilities**:
- Research, plan, implement, verify, and clean up as one cohesive workflow.
- Deep understanding of Perigon, Aspire, .NET, and Angular conventions.
- After completing changes, automatically hands off to the `reviewer` agent for code review.

**Use for**: feature development, bug fixes, refactoring, build error fixes, adding modules and services.

### reviewer

**Role**: Strict code review expert; identifies problems without modifying code.

**Capabilities**:
- Runs build and test validation as a precondition.
- Classifies issues as blocking or improvement suggestions.
- When the review passes (`REVIEW_STATUS: PASS`), it stops and does not trigger further handoffs.

**Use for**: code reviews, PR reviews, architecture consistency checks, security reviews.

### Using Both Together

The two agents cooperate through a Handoff mechanism, forming a `develop → review → fix → re-review` loop. This reduces manual back-and-forth and keeps quality gates automated.

## Skills

Skills are domain-specific knowledge files. AI tools load the relevant skill automatically when handling a related task.

| Skill | Trigger scenario |
| --- | --- |
| `backend` | Controller, Manager, DTO, Entity, DbContext, migrations, API design |
| `angular` | Angular components, routing, forms, Angular Material, i18n, request client |
| `aspire` | AppHost operations, resource status, log and trace inspection, integration config |
| `aspireify` | Initialize an Aspire AppHost in an existing app |
| `perigon` | Scaffolding, add module or service, code generation, OpenAPI client generation, MCP config |
| `test` | ApiTest integration tests, TUnit, test failure diagnosis, coverage |
| `code-review` | Code quality, security, performance, architecture |
| `documentation` | README, developer guides, deployment docs, task plans |
| `dotnet-inspect` | Query .NET library types, APIs, extension methods, implementors |
| `playwright-cli` | Browser automation, end-to-end tests, page validation |

## Instructions

Instructions are code convention files that apply automatically based on file path patterns. No manual prompting is needed.

| File | Applied automatically when editing |
| --- | --- |
| `dotnet.instructions.md` | All `*.cs` and `*.csproj` files |
| `angular.instructions.md` | All `*.ts` and `*.html` files |

This ensures AI follows naming conventions, layering rules, exception handling patterns, and performance guidelines whenever it generates or modifies code.

## Prompts

Prompts are reusable task templates. Call them in Copilot Chat using `/prompt-name`.

| Prompt | Purpose |
| --- | --- |
| `commit` | Generate a Conventional Commits-compliant message from the current git diff |
| `development-plan` | Generate a modular development plan and task checklist from `docs` requirements |
| `angular-template` | Generate Angular Razor templates for list, detail, add, and edit pages |

## MCP Tools

Beyond Copilot configuration, the template supports MCP (Model Context Protocol) tools. MCP allows AI tools to call structured, domain-specific tools directly:

- **Perigon MCP**: code generation, module creation, OpenAPI client generation. Start with `perigon mcp init` / `perigon mcp start` in Studio.
- **Aspire MCP**: query resource status, logs, and traces; interact directly with a running distributed application.

MCP configuration is in `.vscode/mcp.json` and can be enabled per project need.

> [!TIP]
> Prefer Perigon MCP for code generation. It is faster than creating files manually and produces output that matches project conventions automatically.

## Recommended Practices

1. **Route tasks to agents**: For day-to-day feature work, invoke the `engineer` agent; it completes implementation and automatically initiates a code review.
2. **Instructions apply automatically**: You don't need to mention conventions in every prompt; they are applied by the instruction files. Updating those files improves quality globally.
3. **Prefer MCP for scaffolding**: When adding modules, services, or generating code, use Perigon MCP rather than creating files by hand.
4. **Aspire for distributed concerns**: For distributed application state, log inspection, or integration config, use the Aspire skill and MCP.
5. **Commit messages**: Use the `commit` prompt to generate commit messages automatically and keep the history clean and readable.
6. **Larger features**: Use the `development-plan` prompt to create a development plan first, then hand each step to the `engineer` agent.
