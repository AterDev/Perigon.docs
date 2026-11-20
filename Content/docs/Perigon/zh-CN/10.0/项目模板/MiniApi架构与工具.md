# MiniApi 架构与工具

MiniApi 是面向 Native AOT 的 Minimal API 模板，按三个边界组织应用：

| 边界 | 职责 | 典型项目 |
| --- | --- | --- |
| Definition | 实体、DbContext、共享契约、序列化和服务默认配置 | src/Definition/Entity、src/Definition/EntityFramework、src/Definition/Share、src/Definition/ServiceDefaults |
| Implementation | 模块业务逻辑、DTO、Manager、模块服务和初始化方法 | src/Modules/{ModuleName} |
| Service | HTTP Endpoint、Middleware、依赖注入和应用启动 | src/Services/ApiService |

AppHost 描述本地资源图，为 ApiService 提供连接字符串和服务发现，按需启动 Angular 前端并控制资源依赖顺序。业务逻辑不放在 AppHost 中。模块通过注册方法和初始化方法暴露能力，由实际服务在启动阶段调用。

跨模块关联在实体中保存 ID。需要多个模块的数据时，由服务的 Endpoint 依次调用相关 Manager，再把 ID、专用 DTO 或展示快照传给负责本次操作的 Manager。例如，审核 Endpoint 从系统模块获取用户显示名后再提交审核。通知记录由通知模块写入。写入需要原子提交时，由 Endpoint 保留原事务。

## Native AOT 请求流程

Endpoint 绑定 DTO，执行框架验证，调用 Manager，并返回类型明确的结果。Endpoint 保留传输层职责，业务规则由 Manager 和模块服务负责。每个公开 DTO 放在模块的 Models/{Entity}Dtos 目录中，一个公开类型一个文件。

Native AOT 构建需要编译期 JSON 元数据。生成的 ApiJsonSerializerContext 连接 Endpoint 契约和 System.Text.Json。修改 Endpoint 签名、DTO、模块模型或服务项目后执行：

```powershell
perigon aot jsonContext --path .
dotnet publish src/Services/ApiService/ApiService.csproj -c Release
```

CLI 会扫描 src/Services 下的服务，更新对应的序列化 context，不会修改服务启动注册。服务仍需把生成的 context 放进 TypeInfoResolverChain。对于 CLI 无法推断的根类型，例如 object、非泛型 IResult、运行时多态、反射注册和动态 Endpoint 契约，要手动添加 JsonSerializable 条目。发布前检查生成文件的差异。

## 数据库和启动

模板通过依赖注入注册 DbContextOptions<DefaultDbContext>，使用 AddDbContextPool。Perigon.PostgreSQL 0.3.8 提供源生成模型元数据、PostgreSQL 命名约定、继承实体基类的软删除行为和数据库初始化辅助方法。MiniApi 没有迁移资源，因此使用 EnsureCreatedAsync 初始化数据库。生产部署应按照自身发布策略预建并迁移数据库。

模块初始化数据应在模块的静态方法中定义，例如 InitModule.InitializeAsync(DefaultDbContext context, CancellationToken cancellationToken)。实际发布的服务负责在数据库初始化完成后调用该方法。模块加载时不要为了插入种子数据注册 BackgroundService，因为此时目标数据库可能尚未创建。

## 模块打包

安装 CLI 后先检查版本，再打包模块：

```powershell
dotnet tool install --global Perigon.CLI --version 10.2.2
perigon --version
perigon module pack CMSMod ApiService --version 1.1.0 --front-path src/ClientApp/WebApp/src/app/modules/cms
```

模块包包含指定模块的实体、实现、Endpoint、前端和元数据，不替代服务启动代码。安装模块后重新运行 perigon aot jsonContext --path .，检查生成的序列化 context，再构建并使用 Native AOT 发布服务。

Perigon.Modules 仓库的官方批量打包入口是 scripts/PackModules.ps1。它读取 modules.json，计算版本递增，使用显式 --version 调用 CLI，校验包元数据，全部成功后才更新模块索引。当前 AOT 宿主可以使用 CLI 在本地重新生成 CMSMod 和 ResourceMod，是否公开发布仍取决于模块仓库的发布流程。

## PostgreSQL 工具和数据库结构策略

`dotnet perigon` 是 `Perigon.PostgreSQL.Tools` 0.3.8 提供的迁移和数据库工具：

```powershell
dotnet perigon --version
dotnet perigon migrations add AddOrders --project src/Definition/EntityFramework/EntityFramework.csproj
dotnet perigon migrations list --project src/Definition/EntityFramework/EntityFramework.csproj
dotnet perigon database update --project src/Definition/EntityFramework/EntityFramework.csproj --connection "$env:ConnectionStrings__Default"
```

服务负责版本化数据库结构时使用 migrations。`MigrateAsync` 会通过 PostgreSQL 维护库创建不存在的目标数据库，再执行迁移。`EnsureCreatedAsync` 直接创建结构，不生成迁移历史，MiniApi 因为没有迁移资源而采用这种方式。一个数据库不要同时使用 `EnsureCreatedAsync` 和基于迁移的方式。

向已有服务安装模块包：

```powershell
perigon module install ./package_modules/CMSMod.zip ApiService --front-path src/ClientApp/WebApp
```

当前发布的工具版本为 Perigon.CLI 10.2.2、Perigon.PostgreSQL 0.3.8 和 Perigon.templates 1.3.18。
