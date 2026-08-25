# 模板 AI 支持

`ApiStandard` 模板在项目根目录提供 `AGENTS.md`，并在 `.agents/skills` 中提供可复用的 AI 技能。它们共同描述项目结构、技术约束、代码生成入口和验证方式，帮助支持这些文件的 AI 工具在执行任务前获得稳定的项目上下文。

## 文件结构

模板中的 AI 协作配置主要位于以下位置：

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

`SKILL.md` 是每个技能的入口。技能需要更具体的知识时，再加载其 `references` 下的参考文件；因此不需要在每次对话中手动粘贴整套项目规范。

## `AGENTS.md` 的项目规则

`AGENTS.md` 是模板项目级指导文件，重点规则包括：

- 以确定性和准确性为优先，先检查事实和现有代码，不猜测命令、路径或项目结构。
- 代码修改后必须进行构建、测试或其他适合的验证。
- 当前技术基线为 C# 14、Aspire 13+、ASP.NET Core 10、EF Core 10；前端默认使用 Angular。
- 项目结构按 `src/ClientApp/WebApp`、`src/Services`、`src/Definition/Entity`、`src/Modules`、`src/Definition/Share`、`src/Definition/ServiceDefaults`、`tests`、`scripts` 和 `templates` 划分。
- DTO 放在模块的 `Models/{Entity}Dtos` 目录中，一个文件只定义一个类型；数据传输类型使用 `Dto` 后缀，禁止用 `Input`、`Request` 或 `Response` 代替 DTO 名称。
- 脚手架、模块/服务添加、代码生成、OpenAPI 客户端和 MCP 配置优先使用 Perigon；Aspire 启动、资源状态、日志和链路排查优先使用 Aspire CLI。
- 开始实现、规划或审查任务前，先读取 `perigon` 和 `aspire` 两个主技能；涉及界面时还要读取 `ux` 以及目标平台参考文件。

这些规则是 AI 工作流的入口约束，不会替代项目自身的编译器、测试和代码审查。

## 可用技能

| 技能 | 适用场景 |
| --- | --- |
| `perigon` | Perigon CLI、项目脚手架、模块/服务创建、实体与 DTO/Manager/Controller 生成、OpenAPI 请求客户端、模块包和 MCP/Studio；相关 CLI 说明见 `references/perigon-cli.md`。 |
| `aspire` | Aspire AppHost 的总路由；根据任务转入启动、编排、部署或监控等工作流。 |
| `aspire-orchestration` | `aspire start`、`wait`、`describe`、资源重启、文件锁、端口冲突和隔离运行。 |
| `ux` | Angular Material + Bootstrap、WPF/Avalonia、Android Material 的页面、交互、状态、响应式和可访问性设计。 |
| `test` | TUnit、Microsoft.Testing.Platform、Aspire.Hosting.Testing、单元测试、API 集成测试和 AppHost 测试。 |
| `dotnet-inspect` | 查询 NuGet、平台库和本地程序集中的类型、成员、扩展方法、实现类、依赖关系及版本差异。 |
| `docs` | 需求分析、开发任务计划和文档类工作；按需读取 `references/pm.md` 与 `references/dev-plan.md`。 |
| `code-review` | 按项目规范检查架构、质量、性能、安全和前后端一致性，并区分阻断问题和改进建议。 |
| `commit-message` | 根据实际 Git diff 生成符合 Conventional Commits 的提交信息，并遵循项目提交上下文。 |

其中 `perigon` 和 `aspire` 是最常用的入口技能。`aspire` 负责分布式应用工作流路由，`aspire-orchestration` 负责具体的本地生命周期操作；不要把普通构建、测试任务误交给 Aspire 工作流。

## 推荐工作方式

1. 先读取 `AGENTS.md`，再根据任务读取 `perigon`、`aspire` 或其他专用技能。
2. 创建解决方案、模块、服务或生成样板代码时，优先使用 Perigon CLI/MCP；执行命令前先查看 `perigon <command> -h`。
3. 涉及 Aspire 运行时，使用 `aspire start`、`aspire wait`、`aspire describe` 等 Aspire 命令，不要用 `dotnet run` 替代 AppHost 工作流。
4. 生成 DTO 或修改模块时，同时检查目录、文件粒度、类型命名和所有引用。
5. 修改完成后运行适当的构建或测试，并让代码审查技能检查高风险变更。

Perigon 的 Agent MCP 用法和可用生成能力见 [MCP](./MCP.md)。
