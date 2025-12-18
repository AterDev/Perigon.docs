# MCP Server

10.0 版本内置了MCP Server，这意味着你可以在IDE中，通过自然语言描述来生成符合项目规范的代码。

## 启动MCP Server

首先，通过`perigon studio`命令启动`studio`，`MCP Server`将自动启动，你会看到:

![mcp start](../../_images/mcp_start.png)

## 添加MCP Server到IDE

在解决方案根目录下，已经有`.mcp.json`配置文件，内容如下：

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

它将自动被`Visual Studio`读取并使用。

如果你使用`VS Code`，可将该配置文件复制到`.vscode/mcp.json`中。


然后你将在`copilot chat`中看到`perigon`工具，请启用它。

![mcp enable](../../_images/mcp_enable.png)



> [!TIP]
> 如果你看不到mcp工具，请确保先运行了`perigon studio`，然后再打开IDE。

## 使用MCP Server

你可以勾选你需要的工具列表，目前内置提供了以下功能：

- 创建新实体
- 生成DTO
- 生成Manager
- 生成Controller
- 添加新模块

详细使用方法，可参考[内置工具使用示例](./内置工具使用示例.md)。

如果你需要自定义工具，可以参考[自定义工具](./自定义工具.md)。

> [!IMPORTANT]
> 有时你需要明确告诉Agent要使用MCP工具，它才能正确调用MCP Server生成代码。