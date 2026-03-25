# Aspire 13.2.0 更新概要

虽然13.2.0从版本上来看不像是什么大更新，但这次内容确实包含了不少内容，更重要的是使用起来的体验有了较大的变化，同时也能从这个版本判断出未来的方向：**扩展使用范围和AI支持**。

因此，专门写一篇文章来介绍一下13.2.0的更新内容和使用体验，完整内容还是需要看官方文档。

## 命令行的全面升级

以前的Aspire CLI只包含简单几个命令，最常用的就是`aspire run`，即使如此，这个命令也可以直接使用`dotnet run`替代，所以CLI的存在感并不那么强。

这跟之前Aspire的定位有关，它是专门针对.NET生态的，但现在已经抽象了一层，变成了一个更通用的工具，支持更多语言和框架，所以需要自己专门的CLI来管理和使用。

从现在的命令行看起来，像是`.NET CLI`和`Docker CLI`的结合体。

| Command         | Status  | 功能                                             |
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

虽然很多命令行很少手动调用，但能看得出来，拥有命令行之后，为**自动化调试和部署**提供了更多的可能性，**或者说直接增强了AI能力**。

以前几乎都是通过Dashboard来获取的信息和操作，现在也方便习惯CLI的开发者或者AI来直接获取和操作了。

## 出圈进一步，支持Typescript AppHost

在之前的版本中，Aspire是支持多种语言的项目混合开发的，但AppHost.cs仍然是一个.cs文件，你必须依赖.NET SDK。

现在扩展到支持Typescript AppHost了，这意味着你可以完全脱离.NET SDK，而是使用Node.js即可。

`aspire doctor`命令可以帮助你检查环境是否满足运行Aspire的要求。

那么很自然的，对于`aspire new`之类的命令，也会提供Typescript的模板了。

## Aspire与应用模型的变化

在之前使用Aspire时，有两个问题：

1. 如果要运行多个Aspire项目，管理起来比较麻烦。
2. 热重载(.NET)的体验并不好，很多时候，只想重启某个应用，但实际上是需要重启整个Aspire。
3. 同一个项目，不同环境或并行运行时，会有冲突。

现在有了`分离模式`，aspire可以在后台运行，管理多个不同的AppHost。

以下两个命令作用相同

```bash
aspire run --detach
aspire start 
```

像`docker`一样查询正在运行的AppHost：

```bash
aspire ps 
```

`隔离模式`解决同一AppHost多个实例运行时的冲突问题：

```bash
aspire run --isolat
aspire start --isolate
```

> [!IMPORTANT]
> 很多命令都支持`--format Json`，有些内容只有Json格式才会输出，很明显了，就是为了AI自动化处理准备的。

## Aspire Agent

由`aspire mcp`更名而来，或者说又加了一层命令，mcp算是agent的一个子命令了。

现在使用`aspire agent init`，不仅会添加`mcp`的配置，还会添加`aspire`的`SKILL.md`文件，用来描述使用`Aspire`的技能，直接一步上手，不需要你花时间去实践技术了。

## 配置文件

现在统一使用`aspire.config.json`文件，不管你是.NET还是Node.js的AppHost，配置文件都是一样的了，示例:

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

`aspire config`相关命令可以直接修改这个配置文件。这里要专门提到的一个配置是`features.defaultWatchEnabled`，把它设置为`true`，就可以在运行时自动监视文件变化了。

## 马上升级

这是一个变化挺多，影响广泛的版本，早升级早享受，下面给出升级步骤要点：

1. `aspire update --self`，先升级CLI工具到最新版本。
2. `aspire update`，升级项目中的Aspire集成包的版本。
3. `aspire agent init`，添加MCP和SKILL文档，方便与AI工具集成。
4. `aspire config set features.defaultWatchEnabled true`，开启默认监视文件变化的功能。
  
现在跑应用直接`aspire start`就可以了，在后台一直运行即可。