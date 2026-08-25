# Perigon Agent MCP

Perigon CLI 提供基于 Model Context Protocol（MCP）的本地 Agent 集成。当前推荐使用 `perigon agent` 命令组：`perigon agent init` 初始化 Agent 配置，`perigon agent mcp` 以 stdio 方式启动 MCP Server。

这里的 Agent MCP 与 `perigon studio` 提供的 Studio HTTP MCP 是两条不同的集成路径：前者面向 IDE/代码 Agent 的本地 stdio 连接，后者由 Studio 管理并通过 HTTP 提供服务。需要使用哪条路径，取决于客户端的连接方式。

## 初始化 Agent 配置

在解决方案或项目根目录执行：

```pwsh
perigon agent init
```

交互模式下可以选择以下操作：

- `MCP`：写入或更新 `.vscode/mcp.json`，将当前 CLI 配置为本地 stdio MCP Server。
- `Skills`：查找模板或 CLI 附带的 `agent.zip`，并将其中的 Agent 技能解压到当前目录。未找到压缩包时会提示，不会凭空创建技能文件。

在输入或输出被重定向的自动化场景中，`agent init` 默认选择 `MCP`。如果已有 `.vscode/mcp.json`，Perigon 会保留其 JSON 根结构，并更新 Perigon Server 配置。

典型配置如下：

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

不同 IDE 对 MCP 配置文件的位置或顶层字段可能有自己的要求；使用 `agent init` 生成配置后，按 IDE 的 MCP 设置启用并重启该 Server。

## 启动 stdio MCP Server

IDE 或 Agent 需要直接启动 Server 时，使用：

```pwsh
perigon agent mcp
```

该命令会：

1. 设置 stdio 模式，避免日志污染 MCP 的标准输出协议流。
2. 启动 Perigon MCP 主机，并通过 stdio transport 等待客户端连接。
3. 加载 Perigon 代码生成工具和项目服务。
4. 通过 MCP 客户端的 `roots/list` 请求获取当前项目根目录，再建立解决方案上下文。

通常不需要在普通终端中手动长期运行该命令；让 IDE 根据 `.vscode/mcp.json` 启动它即可。若客户端不支持 `roots/list`，工具可能无法定位解决方案。

## 提供的代码能力

当前 Agent MCP 工具覆盖以下工作：

| 能力 | 作用与主要输入 |
| --- | --- |
| 创建实体模型 | 根据用户描述生成实体模型规范和示例；实体路径、模块目录、`EntityBase`、可空性、长度、索引和关联关系等约束由 Perigon 提示词补充。 |
| 生成 DTO | 读取实体文件，生成对应模块 `Models/{Entity}Dtos` 下的 DTO 内容。 |
| 生成 Manager | 从实体生成包含 CRUD 和关联处理的 Manager 内容，遵循业务异常和项目分层规则。 |
| 生成 Controller | 根据实体文件和目标服务路径生成 REST API Controller 内容。 |
| 创建模块 | 按模块名创建模块；缺少 `Mod` 后缀时会自动补充。该能力会修改解决方案文件和目录。 |
| 生成 Razor 模板 | 提供实体/OpenAPI 代码生成所需的 Razor 模板上下文、变量和编写规则。 |
| 使用 Razor 模板生成代码 | 使用实体路径和模板内容计算生成结果，适用于自定义模板试验和重复生成。 |
| 执行生成任务 | 根据生成任务 ID 和实体路径执行已配置的生成任务；未提供任务 ID 时返回可选任务列表。 |
| 生成请求客户端 | 从本地或 URL 的 OpenAPI 文档生成 `NgHttp`、`Axios` 或 `CSharp` 客户端；可指定输出目录、API 文档名称并仅生成模型。 |

生成 DTO、Manager、Controller 和请求客户端时，工具通常返回生成内容或结果，由 Agent 根据项目上下文写入文件；创建模块和执行生成任务可能直接修改项目。执行前应检查目标路径和变更范围。

## 与 Studio MCP 的区别

| 集成方式 | 启动命令 | 传输方式 | 适用场景 |
| --- | --- | --- | --- |
| Agent MCP | `perigon agent mcp` | stdio | VS Code、Copilot、Cursor 等支持 MCP 的代码 Agent |
| Studio MCP | `perigon studio` | Studio 管理的 HTTP 服务 | 使用 Perigon Studio UI、内置 MCP 页面或旧版 Studio 集成 |

不要把 `perigon agent mcp` 写成旧版 `perigon mcp start`。如果命令行版本不接受 `agent`，先运行 `perigon -h` 和 `perigon agent -h`，并按照已安装的 Perigon CLI 版本更新模板或 CLI。

## 安全与排错

- 只在可信的本地项目中启用 Agent MCP；模块创建、生成任务等能力可能写入项目文件。
- 确认 `perigon` 已安装并位于 IDE 进程的 `PATH` 中。
- 修改 `.vscode/mcp.json` 后重启 MCP Server 或 IDE，使客户端重新发现工具。
- 如果工具无法定位项目，确认客户端提供了当前解决方案根目录，并从该目录运行初始化命令。
- 运行 `perigon agent mcp` 时不要把普通日志写入 stdout；stdio 通道必须留给 MCP 协议。

模板中的技能选择和使用规则见[模板 AI 支持](./模板AI支持.md)。
