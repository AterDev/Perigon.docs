# Aspire 13.2.0 更新概要

13.2.0 从版本号上看只是一次小版本更新，但它带来的变化并不“小”。这次更新真正值得关注的，不是某一个孤立功能，而是 Aspire 的定位和使用方式都在发生变化：它正在从“面向 .NET 的开发编排工具”进一步走向“支持更多语言、并且更适合自动化处理的应用平台”。

下面结合官方文档，整理一下这次更新中最值得关注的几个点。

## 命令行的全面升级

早期的 Aspire CLI 功能比较有限，最常见的入口就是 `aspire run`。在那种使用场景下，它的存在感并不强，因为很多时候直接用 `dotnet run` 也能完成同样的事情。

到了 13.2.0，CLI 已经不只是“能跑起来就行”的辅助工具，而是开始承担初始化、恢复、运行、后台管理、资源操作、配置管理和 AI/自动化接入等职责。整体上看，它更像是 `.NET CLI` 和 `Docker CLI` 的组合体：既负责开发体验，也负责运行时管理。

| Command         | Status  | 说明                                             |
| --------------- | ------- | ------------------------------------------------ |
| aspire add      | Stable  | 为 apphost 添加托管集成。                        |
| aspire init     | Stable  | 在现有代码库中初始化 Aspire。                    |
| aspire new      | Stable  | 基于 Aspire 起始模板创建新应用。                 |
| aspire ps       | Stable  | 列出正在运行的 apphost。                         |
| aspire restore  | Stable  | 还原依赖并为 apphost 生成 SDK 代码。             |
| aspire run      | Stable  | 以交互方式运行 apphost 进行开发。                |
| aspire start    | Stable  | 在后台启动 apphost。                             |
| aspire stop     | Stable  | 停止正在运行的 apphost。                         |
| aspire update   | Preview | 更新 Aspire 项目中的集成。                       |
| aspire resource | Stable  | 在资源上执行命令。                               |
| aspire wait     | Stable  | 等待资源达到目标状态。                           |
| aspire describe | Stable  | 描述正在运行的 apphost 中的资源。                |
| aspire export   | Stable  | 将遥测和资源数据导出为 zip 文件。                |
| aspire logs     | Stable  | 显示正在运行的 apphost 中资源的日志。            |
| aspire otel     | Preview | 查看正在运行的 apphost 中的 OpenTelemetry 数据。 |
| aspire deploy   | Preview | 将 apphost 部署到其部署目标。                    |
| aspire do       | Preview | 执行指定的流水线步骤及其依赖项。                 |
| aspire publish  | Preview | 为 apphost 生成部署产物。                        |
| aspire agent    | Stable  | 管理 AI Agent 的环境配置。                       |
| aspire cache    | Stable  | 管理 CLI 操作的磁盘缓存。                        |
| aspire certs    | Stable  | 管理 HTTPS 开发证书。                            |
| aspire config   | Stable  | 管理 CLI 配置及功能开关。                        |
| aspire docs     | Stable  | 浏览并搜索来自 aspire.dev 的 Aspire 文档。       |
| aspire doctor   | Stable  | 诊断 Aspire 环境问题并验证安装配置。             |
| aspire mcp      | Stable  | 与 Aspire 资源暴露的 MCP 工具进行交互。          |
| aspire secret   | Stable  | 管理 apphost 的用户机密。                        |


虽然这些命令未必都会在日常开发中手动执行，但它们的意义很明确：CLI 让 Aspire 更容易被脚本、CI/CD 流程和 AI 工具调用，尤其是在调试、部署和环境管理方面，结构化接口会比 Dashboard 更适合自动化场景。

以前很多信息和操作主要依赖 Dashboard，现在则可以更方便地通过 CLI 交给开发者、脚本或 AI 直接处理。

## 出圈进一步，支持Typescript AppHost

在之前的版本中，Aspire 虽然已经可以编排多种语言的服务，但 AppHost 仍然依赖 `.cs` 文件和 .NET SDK。13.2.0 把这一层进一步抽象出来，开始支持 TypeScript AppHost。

这意味着编排层不再必须绑定 .NET 工具链，使用 Node.js 也可以完成 AppHost 的开发和运行。对于希望统一前端/后端工具链的团队来说，这一点非常关键。

`aspire doctor` 可以用于检查当前环境是否满足 Aspire 的运行要求。

既然支持了 TypeScript AppHost，那么 `aspire new` 之类的命令自然也会提供对应模板，方便直接创建新项目。

## Aspire 与应用模型的变化

在之前的使用方式里，常见的几个痛点是：

1. 如果要运行多个 Aspire 项目，管理起来比较麻烦。
2. 热重载（.NET）的体验并不好，很多时候只想重启某个应用，但实际需要重启整个 Aspire。
3. 同一个项目在不同环境或并行运行时，会有冲突。

13.2.0 引入了更清晰的后台运行模型。借助 `detach` / `start`，Aspire 可以在后台持续运行，并且更方便地同时管理多个 AppHost 实例。

以下两个命令在效果上是等价的：

```bash
aspire run --detach
aspire start 
```

如果需要查看当前有哪些 AppHost 正在运行，可以使用：

```bash
aspire ps 
```

`--isolate` 则用于解决同一个 AppHost 多实例并行运行时的冲突问题：

```bash
aspire run --isolate
aspire start --isolate
```

> [!IMPORTANT]
> 很多命令都支持 `--format json`。对于脚本和 AI 工具来说，结构化输出比自然语言输出更稳定，也更容易解析和复用。

## Aspire Agent

`aspire agent` 可以理解为对原有 `aspire mcp` 能力的进一步扩展：MCP 相关配置仍然存在，但现在被纳入更大的 Agent 体系之中。

使用 `aspire agent init` 后，CLI 不只是生成 MCP 配置，还会补充用于描述项目约束和使用方式的 `SKILL.md`。这类文件的价值在于：它能让 AI 工具更快理解项目上下文，从而减少重复说明和试错成本。

## 配置文件

现在 Aspire 统一使用 `aspire.config.json` 作为配置入口。无论 AppHost 是 .NET 还是 Node.js，配置模型都趋于一致，便于跨语言项目保持相同的管理方式。示例如下：

```json
{
  "appHost": {
    "path": "apphost.ts",
    "language": "typescript/nodejs"
  },
  "sdk": {
    "version": "13.2.0"
  },
  "channel": "stable",
  "profiles": {
    "default": {
      "applicationUrl": "https://localhost:17000;http://localhost:15000"
    }
  }
}
```

`aspire config` 相关命令可以直接读写这个文件。这里值得单独提一下的是 `features.defaultWatchEnabled`：将其设置为 `true` 后，可以让文件监视在运行时默认启用，减少手动重复配置的步骤。

## 马上升级

这是一次影响面比较广的更新，建议尽早升级。比较稳妥的升级顺序如下：

1. `aspire update --self`，先升级 CLI 工具到最新版本。
2. `aspire update`，升级项目中的 Aspire 集成包版本。
3. `aspire agent init`，添加 MCP 和 SKILL 文档，方便与 AI 工具集成。
4. `aspire config set features.defaultWatchEnabled true`，开启默认监视文件变化的功能。

完成以上步骤后，日常运行就可以直接使用 `aspire start`，让 AppHost 在后台持续工作。