# MCP Server

Version 10.0 has built-in MCP Server, which means you can generate code that conforms to project specifications through natural language descriptions in your IDE.

## Starting MCP Server

First, start `studio` with the `perigon studio` command. The `MCP Server` will start automatically, and you will see:

![mcp start](../../_images/mcp_start.png)

## Adding MCP Server to IDE

In the solution root directory, there is already a `.mcp.json` configuration file with the following content:

```json
{
  "servers": {
    "perigon": {
      "url": "http://localhost:19016/mcp",
      "type": "http"
    }
  }
}
```

It will be automatically read and used by `Visual Studio`.

If you are using `VS Code`, you can copy this configuration file to `.vscode/mcp.json`.


Then you will see the `perigon` tool in `copilot chat`, please enable it.

![mcp enable](../../_images/mcp_enable.png)



> [!TIP]
> If you don't see the mcp tool, make sure you run `perigon studio` first, then open the IDE.

## Using MCP Server

You can check the tool list you need. Currently, the following features are built-in:

- Create new entity
- Generate DTO
- Generate Manager
- Generate Controller
- Add new module

For detailed usage, please refer to [Built-in Tool Usage Examples](./Built-in-Tool-Examples.md).

If you need to customize tools, please refer to [Custom Tools](./Custom-MCP-Tools.md).

> [!IMPORTANT]
> Sometimes you need to explicitly tell the Agent to use MCP tools for it to correctly call the MCP Server to generate code.
