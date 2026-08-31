# 模板 AI 支持

`ApiStandard` 和 `MiniApi` 模板都在项目根目录提供 `AGENTS.md`，并在 `.agents/skills` 中提供可复用的 AI 技能。两者共享迭代文档与交付闭环，但后端实现约束不同：ApiStandard 面向 Controller/模块化业务，MiniApi 面向 Minimal API、Native AOT 和 Trim。

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

`SKILL.md` 是每个技能的入口。技能需要更具体的知识时，再加载其 `references` 下的参考文件；因此不需要在每次对话中手动粘贴整套项目规范。

## 迭代文档模型

`Demand.md` 和 `Design.md` 分别是全局需求/设计概要及目录，不承载单个功能的全部细节。具体产品设计和开发计划按迭代、功能模块管理：

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

- 迭代目录使用 `Iter<number>-<Name>`。
- `PD####-Name.md` 是 Product Design，记录某迭代一个功能模块的需求、场景与设计。
- `PT####-Name.md` 是 Plan Task，记录其来源 PD、任务、依赖、进度、实现结果与验证证据。
- PD/PT 在每个迭代内使用四位单调递增编号，不复用已用编号。一个文件聚焦一个功能模块。

两个模板都默认提供 `Iter0-Initial/PD0001-Initial.md` 和 `Iter0-Initial/PT0001-Initial.md`，作为初始产品设计和计划任务模板。MiniApi 的 PT 还会记录 AOT 影响判断、publish/运行证据或未验证原因。

## `AGENTS.md` 的项目规则

`AGENTS.md` 是模板项目级指导文件，重点规则包括：

- 以确定性和准确性为优先，先检查事实和现有代码，不猜测命令、路径或项目结构。
- 代码修改后必须进行构建、测试或其他适合的验证。
- 当前技术基线为 C# 14、Aspire 13+、ASP.NET Core 10、EF Core 10；前端默认使用 Angular。
- ApiStandard 的业务位于 `src/Modules` 并由 Controller 暴露；MiniApi 的业务默认位于 `ApiService/Endpoints/Managers/Models/Services`，不假设存在 `AdminService`、Controller、Modules 或内置迁移资源。
- MiniApi Endpoint group 继承 `RestEndpointBase`，通过静态 `MapEndpoints` 和源码生成的 `MapEndpointGroups()` 注册；typed handler、参数绑定和 JSON 契约必须保持 AOT 可分析。
- 脚手架、模块/服务添加、代码生成、OpenAPI 客户端和 MCP 配置优先使用 Perigon；Aspire 启动、资源状态、日志和链路排查优先使用 Aspire CLI。
- 规划、实现或审查 Perigon 业务代码前读取 `perigon`；只在涉及 AppHost 或分布式运行边界时读取 `aspire`。涉及界面时还要读取 `ux` 以及目标平台参考文件。
- 任务勾选只是进度索引；没有实现证据和通过的必需验证，不得宣称完成。
- 每次 AI coding 后必须更新当前 PT 的 checkbox、进度、实现记录和验证证据，同步 `ProjectTracking.md`；行为或设计改变时还要同步来源 PD。

这些规则是 AI 工作流的入口约束，不会替代项目自身的编译器、测试和代码审查。

## 可用技能

| 技能 | 适用场景 |
| --- | --- |
| `perigon` | Perigon CLI、项目脚手架、模块/服务创建、实体与 DTO/Manager/Controller 生成、OpenAPI 请求客户端、模块包和 MCP/Studio；相关 CLI 说明见 `references/perigon-cli.md`。 |
| `aspire` | Aspire AppHost 的总路由；根据任务转入启动、编排、部署或监控等工作流。 |
| `aspire-orchestration` | `aspire start`、`wait`、`describe`、资源重启、文件锁、端口冲突和隔离运行。 |
| `ux` | Angular Material + Bootstrap、WPF/Avalonia、Android Material 的页面、交互、状态、响应式和可访问性设计。 |
| `test` | TUnit、Microsoft.Testing.Platform、Aspire.Hosting.Testing、单元测试、API 集成测试和 AppHost 测试。 |
| `native-aot` | MiniApi 的 Request Delegate Generator、JSON 元数据、反射/动态代码、依赖、Trim warning、Native AOT publish 与运行验证。 |
| `dotnet-inspect` | 查询 NuGet、平台库和本地程序集中的类型、成员、扩展方法、实现类、依赖关系及版本差异。 |
| `docs` | 编写迭代 PD/PT、全局索引、实现记录和变更说明；追踪需求、任务、代码和验证。 |
| `delivery-loop` | 执行或只读审计 PD/PT，按 ready task 循环实现和验证；Implementation mode 每轮必须更新文档。 |
| `code-review` | 按需求和项目规范只读审查完整性、正确性、安全、性能、架构和测试证据。 |
| `commit-message` | 根据实际 Git diff 生成符合 Conventional Commits 的提交信息，并遵循项目提交上下文。 |

其中 `perigon` 和 `aspire` 是最常用的入口技能。`aspire` 负责分布式应用工作流路由，`aspire-orchestration` 负责具体的本地生命周期操作；不要把普通构建、测试任务误交给 Aspire 工作流。

## 推荐工作方式

1. 先读取 `AGENTS.md`，再根据任务读取 `perigon`、`aspire` 或其他专用技能。
2. 创建解决方案、模块、服务或生成样板代码时，优先使用 Perigon CLI/MCP；执行命令前先查看 `perigon <command> -h`。
3. 涉及 Aspire 运行时，使用 `aspire start`、`aspire wait`、`aspire describe` 等 Aspire 命令，不要用 `dotnet run` 替代 AppHost 工作流。
4. 生成 DTO 或修改模块时，同时检查目录、文件粒度、类型命名和所有引用。
5. 修改完成后运行适当的构建或测试，并让代码审查技能检查高风险变更。
6. 每次 AI coding 都使用 `delivery-loop` 执行“实现→验证→更新 PT/ProjectTracking/PD→收敛检查”；即使是简单修复也使用简短 PT 记录结果。
7. MiniApi 中修改 Endpoint、DTO/JSON、反射、依赖、EF 模型或发布设置时，同时使用 `native-aot`；普通 build 不能代替 Native AOT publish 证据。

Perigon 的 Agent MCP 用法和可用生成能力见 [MCP](./MCP.md)。
