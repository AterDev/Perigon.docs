# 模板中的 AI 工具支持

Perigon 模板对 AI 编程工具有完整的支持，开箱即用。模板预置了 GitHub Copilot 所需的全部配置，包括代码编写指引（Instructions）、专属代理（Agents）、可复用技能（Skills）和提示词（Prompts），让 AI 工具能够理解项目结构、遵循项目规范、并高效地完成开发任务。

## 配置文件结构

```
.github/
├── copilot-instructions.md       # 项目级全局指令：技术栈、目录、规范
├── agents/
│   ├── engineer.agent.md         # 实现工程师 Agent
│   └── reviewer.agent.md         # 代码审查 Agent
├── instructions/
│   ├── dotnet.instructions.md    # C#/.NET 代码规范（自动应用于 .cs/.csproj）
│   └── angular.instructions.md   # Angular 前端代码规范（自动应用于 .ts/.html）
└── prompts/
    ├── commit.prompt.md          # Conventional Commits 提交信息生成
    ├── development-plan.prompt.md # 根据需求文档生成开发计划
    └── angular-template.prompt.md # Angular Razor 模板生成

.agents/skills/
├── backend/      # ASP.NET Core / EF Core / Aspire 后端开发规范
├── angular/      # Angular 前端开发规范
├── aspire/       # Aspire 启动、资源状态、日志、链路排查
├── aspireify/    # 为现有项目初始化 Aspire AppHost
├── perigon/      # Perigon CLI/MCP 脚手架、代码生成、客户端生成
├── test/         # TUnit 集成测试规范
├── code-review/  # 代码审查标准
├── documentation/# 技术文档编写规范
├── dotnet-inspect/# .NET 程序集和 API 探查
└── playwright-cli/# 浏览器自动化与端到端测试
```

## Agents

Agents 是 GitHub Copilot 中具备特定专长的自定义模式，可在 Copilot Chat 中通过 `@agent名称` 调用。

### engineer

**定位**：资深软件开发工程师，负责从需求到交付的全流程实现。

**能力**：
- 调研、计划、编码、验证、清理的完整闭环
- 内置对 Perigon、Aspire、.NET、Angular 的深度理解
- 修改完成后会主动触发 `reviewer` 进行代码审查（Handoff）

**使用场景**：功能开发、Bug 修复、重构、构建错误修复、模块/服务添加等。

### reviewer

**定位**：代码审查专家，只负责发现问题，不直接修改代码。

**能力**：
- 执行构建/测试验证作为前置条件
- 按阻断问题和改进建议分级输出
- 审查通过（`REVIEW_STATUS: PASS`）后自动结束，不再触发其他 Agent

**使用场景**：代码审查、PR 审查、架构一致性检查、安全性审查。

### 配合使用

两个 Agent 通过 Handoff 机制互相协作，形成`开发 → 审查 → 修复 → 再审查`的闭环，减少人工介入的轮次。

## Skills

Skills 是领域专项知识文件，AI 工具会在处理相关任务时自动加载，以便给出更准确的答案和操作。

| Skill | 触发场景 |
| --- | --- |
| `backend` | Controller、Manager、DTO、Entity、DbContext、迁移、接口设计 |
| `angular` | Angular 组件、页面、路由、表单、Angular Material、i18n、请求客户端 |
| `aspire` | AppHost 操作、资源状态、日志/链路排查、集成配置、分布式应用启动 |
| `aspireify` | 为尚未接入 Aspire 的现有应用完成 AppHost 初始化 |
| `perigon` | 项目脚手架、模块/服务添加、代码生成、OpenAPI 客户端生成、MCP 配置 |
| `test` | ApiTest 集成测试、TUnit、测试失败排查、覆盖率 |
| `code-review` | 代码审查、质量门禁、安全性、性能、架构 |
| `documentation` | README、开发指南、部署文档、任务计划 |
| `dotnet-inspect` | 查询 .NET 库类型、API、扩展方法、实现者 |
| `playwright-cli` | 浏览器自动化、端到端测试、页面验证 |

## Instructions

Instructions 是根据文件路径模式自动应用的代码规范，无需手动触发。

| 文件 | 自动应用条件 |
| --- | --- |
| `dotnet.instructions.md` | 所有 `*.cs`、`*.csproj` 文件 |
| `angular.instructions.md` | 所有 `*.ts`、`*.html` 文件 |

这确保 AI 在生成或修改代码时，自动遵循项目的命名、分层、异常处理和性能规范。

## Prompts

Prompts 是可复用的任务模板，可在 Copilot Chat 中通过 `/prompt名称` 调用。

| Prompt | 作用 |
| --- | --- |
| `commit` | 根据当前 git diff 生成符合 Conventional Commits 规范的提交信息 |
| `development-plan` | 根据 `docs` 目录中的需求文档生成模块化开发计划和待办列表 |
| `angular-template` | 生成 Angular Razor 模板（列表、详情、添加、编辑页面） |

## MCP 工具

除了上述 Copilot 配置，模板还支持 MCP（Model Context Protocol）工具。MCP 让 AI 工具能够直接调用结构化工具，包括：

- **Perigon MCP**：代码生成、模块创建、OpenAPI 客户端生成；在 Studio 中通过 `perigon mcp init/start` 启动。
- **Aspire MCP**：获取资源状态、日志、链路数据，与运行中的分布式应用直接交互。

MCP 配置存放在 `.vscode/mcp.json`，可根据项目需求按需启用。

> [!TIP]
> 优先使用 Perigon MCP 进行代码生成，它比手动编写更快且更符合项目规范。

## 最佳实践

1. **任务分发**：日常功能开发优先使用 `engineer` Agent，让其完成实现并自动发起代码审查。
2. **规范内化**：Instructions 会自动应用，无需额外提示；修改了规范文件后，代码质量会自动跟进。
3. **优先 MCP**：涉及脚手架、模块/服务添加、代码生成时，优先使用 Perigon MCP 能力，而不是手动创建文件。
4. **Aspire 优先**：涉及分布式应用状态、日志排查、集成配置时，优先使用 Aspire 相关 Skill 和 MCP。
5. **提交规范**：使用 `commit` Prompt 自动生成提交信息，保持提交历史整洁可读。
6. **文档与计划**：较大的功能迭代使用 `development-plan` Prompt 生成开发计划，然后交给 `engineer` Agent 逐步实现。
