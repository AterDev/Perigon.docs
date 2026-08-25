# Perigon Agent MCP

The Perigon CLI provides a local Agent integration through the Model Context Protocol (MCP). The current `perigon agent` command group is the recommended entry point: `perigon agent init` initializes Agent configuration, and `perigon agent mcp` starts the MCP server over stdio.

Agent MCP and the HTTP MCP exposed by `perigon studio` are different integration paths. Agent MCP is intended for a local IDE or coding agent using stdio; Studio manages its own HTTP service. Choose the path that matches the client's connection model.

## Initialize Agent configuration

Run the command from the solution or project root:

```pwsh
perigon agent init
```

Interactive mode offers these actions:

- `MCP`: write or update `.vscode/mcp.json` so the local Perigon CLI is used as a stdio MCP server.
- `Skills`: locate an `agent.zip` supplied by the template or CLI and extract its Agent skills into the current directory. If no archive is found, the command reports that fact instead of creating placeholder skills.

When input or output is redirected for automation, `agent init` selects `MCP` by default. If `.vscode/mcp.json` already exists, Perigon preserves the JSON root structure and updates the Perigon server entry.

A typical configuration is:

```json
{
  "servers": {
    "perigon": {
      "command": "perigon",
      "args": ["agent", "mcp"]
    }
  }
}
```

MCP configuration locations and top-level fields vary between IDEs. After `agent init` creates the configuration, enable it through the IDE's MCP settings and restart the server.

## Start the stdio MCP server

When an IDE or Agent needs to start the server directly, use:

```pwsh
perigon agent mcp
```

The command:

1. Enables stdio mode so logs do not corrupt the MCP protocol stream on standard output.
2. Starts the Perigon MCP host and waits for a client over stdio transport.
3. Loads the Perigon code-generation tools and project services.
4. Uses the MCP client's `roots/list` request to discover the project root and establish the solution context.

You normally do not need to keep this command running in a regular terminal. Let the IDE launch it from `.vscode/mcp.json`. A client without `roots/list` support may not be able to resolve the solution.

## Available code capabilities

The Agent MCP tools cover these workflows:

| Capability | Purpose and main inputs |
| --- | --- |
| Create an entity model | Build entity-model guidance and examples from a user prompt, including module placement, `EntityBase`, nullability, lengths, indexes, and relationships. |
| Generate a DTO | Read an entity file and generate DTO content under the module's `Models/{Entity}Dtos` directory. |
| Generate a Manager | Generate a Manager from an entity, including CRUD and relationship handling, while following business-exception and layering rules. |
| Generate a Controller | Generate a REST API Controller from an entity file and a target service path. |
| Create a module | Create a module from a module name; the `Mod` suffix is added when it is missing. This capability can modify solution files and directories. |
| Create a Razor template | Return the Razor template context, variables, and rules used for entity/OpenAPI code generation. |
| Generate code from a Razor template | Evaluate template content against an entity path, useful for custom-template experiments and repeatable generation. |
| Execute a generation task | Run a configured generation task by task ID and entity path; without a task ID, return the available task list. |
| Generate a request client | Generate an `NgHttp`, `Axios`, or `CSharp` client from a local or URL-based OpenAPI document; supports an output directory, API document name, and model-only generation. |

DTO, Manager, Controller, and request-client operations commonly return generated content or a result for the Agent to place in the project. Module creation and generation-task execution may modify the project directly, so inspect target paths and the resulting diff.

## Agent MCP and Studio MCP

| Integration | Command | Transport | Typical use |
| --- | --- | --- | --- |
| Agent MCP | `perigon agent mcp` | stdio | VS Code, Copilot, Cursor, and other MCP-capable coding agents |
| Studio MCP | `perigon studio` | HTTP managed by Studio | Perigon Studio UI, its MCP page, or older Studio integrations |

Do not replace `perigon agent mcp` with the legacy `perigon mcp start`. If the installed CLI does not recognize `agent`, run `perigon -h` and `perigon agent -h`, then align the template and CLI versions before proceeding.

## Security and troubleshooting

- Enable Agent MCP only for trusted local projects; module creation and generation tasks can write project files.
- Confirm that `perigon` is installed and available on the `PATH` inherited by the IDE process.
- After changing `.vscode/mcp.json`, restart the MCP server or IDE so the client discovers the tools again.
- If tools cannot locate the project, confirm that the client provides the solution root and initialize from that directory.
- When running `perigon agent mcp`, keep ordinary logs off stdout; the stdio channel is reserved for MCP messages.

See [AI Support in the Template](./Template-AI-Support.md) for the template's skill and project-guidance rules.
