# 受限环境下配置 Windows 开发工具：WSL2 / Pwsh / Windows Terminal / Docker / Aspire

在受限的 Windows 10 机器上做 Aspire 本地开发时，最先遇到的不是代码问题，而是基础设施问题：

- 不能安装 Docker Desktop，通常是授权或策略限制
- Windows 10 不能直接依赖应用商店完成某些组件安装
- Aspire 需要容器运行时，但项目本身又不应该因为环境问题被改动

最后我采用的是一条比较朴素、但稳定的路线：**手动安装 WSL / Ubuntu，再在 WSL 里装 Docker Engine，Windows 侧只保留一个很薄的 `docker.exe` 转发器**。这样既避开 Docker Desktop，也不需要改应用代码。

下面按实际搭建顺序来：

1. 启用 WSL2
2. 手动安装 Ubuntu 24.04
3. 安装 Windows Terminal（可选）
4. 在 WSL 中安装 Docker Engine
5. 在 Windows 侧创建 `docker.exe` 桥接程序
6. 配置 Aspire
7. 处理代理（按需）

## 环境约束

- Windows 10
- WSL2
- Ubuntu 24.04
- PowerShell 7
- 无法依赖 Docker Desktop
- 无法依赖应用商店完成安装

## 目标

- Docker Engine 运行在 WSL 中
- Windows 侧提供一个轻量 `docker.exe`
- Aspire 可直接识别容器运行时
- 支持通过代理拉取镜像

## 预期结果

配置完成后，你在 Windows 侧执行 `aspire doctor`、`docker version` 和 `docker pull`，都应该能按预期工作；后续使用 Aspire 时不需要重复执行初始化步骤。

## 0. 启用 WSL2 基础组件

以管理员身份打开 PowerShell，执行：

```powershell
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
```

然后重启系统。

安装 WSL 2 内核更新包：

1. 下载 `https://aka.ms/wsl2kernel`
2. 运行安装包
3. 执行：

```powershell
wsl --set-default-version 2
```

验证：

```powershell
wsl --status
```

---

## 1. 手动安装 Ubuntu 24.04

如果机器不能直接用 Microsoft Store 或 `winget`，优先使用 **`.wsl` 安装包**。这类包更适合受限环境，也更接近当前 WSL 的原生分发方式。

### 推荐方式：安装 `.wsl`

假设你拿到的文件名类似：

```text
ubuntu-24.04.4-wsl-amd64.wsl
```

以管理员身份打开 PowerShell，执行：

```powershell
wsl --import Ubuntu-24.04 C:\WSL\Ubuntu-24.04 C:\Downloads\ubuntu-24.04.4-wsl-amd64.wsl
```

说明：

- `Ubuntu-24.04`：发行版注册名，后续 `wsl -d Ubuntu-24.04` 会用到
- `C:\WSL\Ubuntu-24.04`：WSL 实际存放位置
- 最后一个参数是你下载到的 `.wsl` 文件

如果你的 WSL 版本支持，也可以尝试：

```powershell
wsl --install --from-file C:\Downloads\ubuntu-24.04.4-wsl-amd64.wsl
```

但在受限环境里，**`wsl --import` 更稳**，因为路径和发行版名称都可控。

### 兼容方式：安装 `.appx` 或 `.msixbundle`

如果你拿到的不是 `.wsl`，而是 `.appx` 或 `.msixbundle`，也可以继续安装：

```powershell
Add-AppxPackage -Path "C:\Path\To\Ubuntu_24.04_LTS.appx"
```

如果你拿到的是 `.msixbundle`，命令一样，把路径换成对应文件即可。

### 首次启动

执行：

```powershell
wsl -d Ubuntu-24.04
```

如果是第一次导入的 rootfs / `.wsl` 发行版，通常需要你自己创建默认用户；后续 Docker、代理、Aspire 相关操作都在这个发行版里做。

验证：

```powershell
wsl -l -v
```


> [!IMPORTANT]
> 可参考[微软官方文档](https://learn.microsoft.com/zh-cn/windows/wsl/install-manual)，了解如何在受限条件下安装 WSL 和 Linux 发行版。
---

## 2. 可选：手动安装 Windows Terminal

如果当前机器不能使用 `winget` 或 Microsoft Store，可以直接从 GitHub Release 安装 Windows Terminal。

### 下载安装包

1. 打开 Windows Terminal 的 [GitHub Releases](https://github.com/microsoft/terminal/releases)
2. 下载最新的 `.msixbundle`
3. 如提示依赖缺失，先下载 `Microsoft.VCLibs.x64.14.00.appx`

### 安装

以管理员身份打开 PowerShell，执行：

```powershell
Add-AppxPackage -Path "C:\Path\To\Microsoft.VCLibs.x64.14.00.appx"
Add-AppxPackage -Path "C:\Path\To\Microsoft.WindowsTerminal_<version>.msixbundle"
```

### 说明

- 这是标准的侧载安装方式
- 不依赖 Store
- 不依赖 `winget`

---

## 3. 安装 Docker Engine

进入 WSL root：

```powershell
wsl -d Ubuntu-24.04 -u root -- bash
```

安装 Docker：

```bash
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y docker.io docker-buildx
```

将当前用户加入 `docker` 组：

```bash
usermod -aG docker dev
```

启用并启动服务：

```bash
systemctl enable --now docker
```

### 这里哪些是必装的

如果你希望 **Windows 侧的 Aspire 能完整驱动 WSL 中的 Docker**，下面这些能力是必须的：

1. `docker.io`：提供 `dockerd` 和基础 `docker` CLI
2. `docker-buildx`：提供 BuildKit / `docker buildx` 能力
3. `systemd` 可用：用于 `systemctl enable --now docker`

其中 `docker-buildx` 这一项很关键。  
Aspire 的 DCP 在启动时会构建自己的 tunnel proxy 镜像，实际会调用类似：

```powershell
docker build --progress plain ...
```

如果 `buildx/BuildKit` 没装，这一步会报：

```text
unknown flag: --progress
```

然后 Aspire 会卡在 dashboard 启动前，看起来像“正在启动仪表板”但没有继续。

### 验证

至少确认下面几条都能通过：

```bash
docker version
docker ps
docker buildx version
docker build --progress plain - <<'EOF'
FROM alpine:3.20
CMD ["echo","ok"]
EOF
```

---

## 4. 创建 Windows 侧 Docker 桥接程序

由于我们无法安装 Docker Desktop，要想在Windows命令行下使用Docker，就需要一个桥接程序把 `docker.exe` 调用转发到 WSL 中的 Docker CLI。

我们直接创建一个`dotnet`控制台应用，编译成 `docker.exe`，放在用户 PATH 中即可。

### `Program.cs`

```csharp
using System.Diagnostics;
using System.Text;

Console.InputEncoding = Encoding.UTF8;
Console.OutputEncoding = Encoding.UTF8;

return await RunAsync(args);

static async Task<int> RunAsync(string[] arguments)
{
    var normalizedArguments = NormalizeArguments(arguments);
    var redirectInput = Console.IsInputRedirected;
    var redirectOutput = Console.IsOutputRedirected;
    var redirectError = Console.IsErrorRedirected;

    var psi = new ProcessStartInfo
    {
        FileName = "wsl.exe",
        UseShellExecute = false,
        RedirectStandardInput = redirectInput,
        RedirectStandardOutput = redirectOutput,
        RedirectStandardError = redirectError,
    };

    psi.ArgumentList.Add("-d");
    psi.ArgumentList.Add("Ubuntu-24.04");
    psi.ArgumentList.Add("-u");
    psi.ArgumentList.Add("dev");
    psi.ArgumentList.Add("--exec");
    psi.ArgumentList.Add("docker");

    foreach (var arg in normalizedArguments)
    {
        psi.ArgumentList.Add(arg);
    }

    using var process = Process.Start(psi) ?? throw new InvalidOperationException("Failed to start wsl.exe.");

    Task copyStdOut = Task.CompletedTask;
    if (redirectOutput)
    {
        copyStdOut = process.StandardOutput.BaseStream.CopyToAsync(Console.OpenStandardOutput());
    }

    Task copyStdErr = Task.CompletedTask;
    if (redirectError)
    {
        copyStdErr = process.StandardError.BaseStream.CopyToAsync(Console.OpenStandardError());
    }

    Task copyStdIn = Task.CompletedTask;
    if (redirectInput)
    {
        copyStdIn = Console.OpenStandardInput()
            .CopyToAsync(process.StandardInput.BaseStream)
            .ContinueWith(_ => process.StandardInput.Close(), TaskScheduler.Default);
    }

    await Task.WhenAll(copyStdOut, copyStdErr, copyStdIn, process.WaitForExitAsync());
    return process.ExitCode;
}

static string[] NormalizeArguments(string[] arguments)
{
    if (arguments.Length == 0)
    {
        return arguments;
    }

    var normalized = new string[arguments.Length];
    string? command = null;

    for (var i = 0; i < arguments.Length; i++)
    {
        var argument = arguments[i];
        if (command is null && !argument.StartsWith("-", StringComparison.Ordinal))
        {
            command = argument;
            normalized[i] = argument;
            continue;
        }

        var previous = i > 0 ? arguments[i - 1] : null;
        normalized[i] = NormalizeArgument(argument, previous, command);
    }

    return normalized;
}

static string NormalizeArgument(string argument, string? previousArgument, string? command)
{
    if (RequiresPathValue(previousArgument))
    {
        return ConvertWindowsPath(argument);
    }

    if (TryNormalizeFlagAssignment(argument, out var normalizedFlag))
    {
        return normalizedFlag;
    }

    if (TryNormalizeVolume(argument, previousArgument, out var normalizedVolume))
    {
        return normalizedVolume;
    }

    if (TryNormalizeMount(argument, out var normalizedMount))
    {
        return normalizedMount;
    }

    if (IsBuildContext(command, argument))
    {
        return ConvertWindowsPath(argument);
    }

    return ConvertWindowsPath(argument);
}

static bool RequiresPathValue(string? previousArgument) =>
    previousArgument is "-f" or "--file" or "--iidfile" or "--cidfile" or "--env-file" or "--label-file";

static bool TryNormalizeFlagAssignment(string argument, out string normalized)
{
    foreach (var flag in new[] { "--file=", "--iidfile=", "--cidfile=", "--env-file=", "--label-file=" })
    {
        if (argument.StartsWith(flag, StringComparison.Ordinal))
        {
            normalized = flag + ConvertWindowsPath(argument[flag.Length..]);
            return true;
        }
    }

    normalized = argument;
    return false;
}

static bool TryNormalizeVolume(string argument, string? previousArgument, out string normalized)
{
    if (previousArgument is not "-v" and not "--volume")
    {
        normalized = argument;
        return false;
    }

    normalized = NormalizeVolumeSpec(argument);
    return true;
}

static bool TryNormalizeMount(string argument, out string normalized)
{
    const string prefix = "--mount=";
    if (!argument.StartsWith(prefix, StringComparison.Ordinal))
    {
        normalized = argument;
        return false;
    }

    var spec = argument[prefix.Length..];
    var parts = spec.Split(',');
    for (var i = 0; i < parts.Length; i++)
    {
        var separatorIndex = parts[i].IndexOf('=');
        if (separatorIndex <= 0)
        {
            continue;
        }

        var key = parts[i][..separatorIndex];
        if (!key.Equals("src", StringComparison.OrdinalIgnoreCase) &&
            !key.Equals("source", StringComparison.OrdinalIgnoreCase))
        {
            continue;
        }

        var value = parts[i][(separatorIndex + 1)..];
        parts[i] = $"{key}={ConvertWindowsPath(value)}";
    }

    normalized = prefix + string.Join(",", parts);
    return true;
}

static bool IsBuildContext(string? command, string argument) =>
    (string.Equals(command, "build", StringComparison.Ordinal) ||
     string.Equals(command, "buildx", StringComparison.Ordinal)) &&
    IsWindowsPath(argument);

static string NormalizeVolumeSpec(string value)
{
    if (!TrySplitWindowsVolume(value, out var hostPath, out var remainder))
    {
        return value;
    }

    return $"{ConvertWindowsPath(hostPath)}:{remainder}";
}

static bool TrySplitWindowsVolume(string value, out string hostPath, out string remainder)
{
    hostPath = string.Empty;
    remainder = string.Empty;

    if (value.Length < 3 || !char.IsLetter(value[0]) || value[1] != ':' || (value[2] != '\\' && value[2] != '/'))
    {
        return false;
    }

    var separatorIndex = value.IndexOf(':', 3);
    if (separatorIndex < 0)
    {
        return false;
    }

    hostPath = value[..separatorIndex];
    remainder = value[(separatorIndex + 1)..];
    return true;
}

static string ConvertWindowsPath(string value)
{
    if (!IsWindowsPath(value))
    {
        return value;
    }

    var drive = char.ToLowerInvariant(value[0]);
    var path = value[2..].Replace('\\', '/');
    if (!path.StartsWith('/'))
    {
        path = "/" + path;
    }

    return $"/mnt/{drive}{path}";
}

static bool IsWindowsPath(string value) =>
    value.Length >= 3 &&
    char.IsLetter(value[0]) &&
    value[1] == ':' &&
    (value[2] == '\\' || value[2] == '/');

```

### `DockerBridge.csproj`

```xml
 <Project Sdk="Microsoft.NET.Sdk">
   <PropertyGroup>
     <OutputType>Exe</OutputType>
     <AssemblyName>docker</AssemblyName>
     <OutputName>docker</OutputName>
     <TargetFramework>net10.0</TargetFramework>
     <Nullable>enable</Nullable>
     <ImplicitUsings>enable</ImplicitUsings>
     <PublishAot>true</PublishAot>
     <InvariantGlobalization>true</InvariantGlobalization>
     <StripSymbols>true</StripSymbols>
     <OptimizationPreference>Size</OptimizationPreference>
   </PropertyGroup>
 </Project>
```

### AOT 发布

该程序除了转发 `docker` 到 WSL 之外，还有一些额外处理：  
**把 Windows 侧传进来的 `C:\...` 路径转换成 WSL 可识别的 `/mnt/c/...`**。

这是 Aspire 必需的，因为 DCP 在构建内部镜像时会直接调用类似：

```powershell
docker build -f C:\Users\<你>\AppData\Local\Temp\...\Dockerfile ...
```

如果桥接层不做路径转换，WSL 里的 Docker 会直接报 `path not found`。

然后将其发布到用户环境变量路径下即可，例如：

```powershell
dotnet publish -c Release -r win-x64 -o C:\Users\<你>\bin
```

然后在 Windows 命令行中验证：

```powershell
docker version
docker buildx version
```

---

## 5. Aspire 初步验证

ok，现在我们来 验证一下 Aspire 能否识别这个 WSL 内的 Docker 运行时。

先使用`aspire doctor`，检查 Aspire 的环境依赖。

然后尝试在真实的项目中运行`aspire start`，看看能不能正常启动。

---

## 6. 代理配置

这里讨论的场景是：

- Windows 本机已经有一个代理
- 例如监听在 `127.0.0.1:7890`
- 希望 **WSL 中的 Docker** 也能通过它拉镜像

当前使用的脚本在：

```powershell
~\Configure-WslDockerProxy.ps1
```

它的职责只有一个：  
**把代理地址写入 WSL 内 Docker 服务的 `HTTP_PROXY/HTTPS_PROXY` 配置。**

### 配置脚本

使用：

```powershell
~\Configure-WslDockerProxy.ps1 -ProxyHost 192.168.1.10 -Verify
```

脚本行为：

1. 验证 WSL 是否能访问指定的代理地址
2. 配置 WSL 内 `docker.service` 的 `HTTP_PROXY/HTTPS_PROXY/NO_PROXY`

### `-ProxyHost` 应该填什么

`-ProxyHost` 要填的不是“我在 Windows 上习惯访问的地址”，而是：

> **WSL 里也能访问到的那个 Windows 代理地址**

例如可以是：

- Windows 的局域网 IP
- Windows 在 WSL 虚拟网络里的宿主机地址
- 代理软件监听的其他 WSL 可达地址

如果你只是想先找出 **WSL 看到的 Windows 宿主机地址**，可以在 WSL 里执行：

```bash
ip route | awk '/default/ {print $3}'
```

这个地址经常是 `172.x.x.1` 之类的网关地址，但**不要写死**，以实际输出为准。

如果你在 Windows 上的代理软件只监听 `127.0.0.1:7890`，那它对 WSL 通常是不可见的；这时要先把代理软件改成监听一个 **WSL 可达地址**，再执行脚本。

也就是说，下面这种写法通常**不成立**：

```powershell
~\Configure-WslDockerProxy.ps1 -ProxyHost 127.0.0.1 -Verify
```

因为这里的 `127.0.0.1` 对 WSL 而言是 **WSL 自己**，不是 Windows 宿主机。

### 使用方式

一次配置即可，不需要每次启动 Aspire 前执行。

```powershell
~\Configure-WslDockerProxy.ps1 -ProxyHost 192.168.1.10 -Verify
```
如果需要移除配置：

```powershell
~\Configure-WslDockerProxy.ps1 -Remove
```

### 验证拉镜像

```bash
docker pull hello-world
```

---

## 7. 运行原则

- `docker.exe` 只负责转发到 WSL
- `dockerd` 运行在 WSL 内
- Aspire 只依赖 PATH 中的 `docker.exe`
- 代理配置是基础设施初始化，不是日常启动步骤

---

## 8. 常见问题

### 1. Aspire 提示 `No container runtime detected`

检查：

- `docker.exe` 是否在用户 PATH 中
- `docker version` 是否可用

### 2. `docker pull` 超时

检查：

- 代理地址是否对 WSL 可达
- `-ProxyHost` 是否指向 **WSL 可达的 Windows 地址**，而不是 `127.0.0.1`
- 是否需要重新执行 `-ProxyHost <可达地址> -Verify`
- 当前脚本不会再自动创建 `portproxy`

### 3. Aspire 卡在“正在启动仪表板”

这类问题先不要只盯 dashboard，本质上往往是 **DCP 初始化容器运行时失败**。

重点检查：

- `docker buildx version` 是否可用
- `docker build --progress plain .` 是否支持
- Windows 侧 `docker.exe` 是否已经实现 **Windows 路径 -> WSL 路径** 的转换

典型症状：

```text
failed to build client proxy image
docker command 'BuildImage' returned with non-zero exit code 125
unknown flag: --progress
```

这通常不是缺 Docker Desktop，而是：

1. WSL 内没有安装 `docker-buildx`
2. Windows 侧桥接程序没有处理 `C:\...` 路径

### 4. 修改 PATH 后无效

重新打开 PowerShell 窗口，或者确认当前窗口里已经能执行：

```powershell
Get-Command docker
```

Aspire 只会读取启动它的那个进程环境；如果这个窗口是在添加 `C:\Users\<你>\bin` 之前打开的，就会继续报找不到 Docker runtime。

---

## 9. 最终清单

### 必做

1. 在 WSL 里安装并启动 Docker Engine。
2. 在 WSL 里安装 `docker-buildx`。
3. 把 Windows 侧 `docker.exe` 桥接程序放到 `C:\Users\<你>\bin\docker.exe`。
4. 把 `C:\Users\<你>\bin` 加进用户 `PATH`，然后重新打开终端。


### 需要时再做

1. 如果 `docker pull` 需要走代理，运行 `~\Configure-WslDockerProxy.ps1 -ProxyHost <Windows 可达地址> -Verify`。
2. 如果你的代理只监听在 Windows `127.0.0.1`，先把代理改成 Windows LAN 地址或其他 WSL 可达地址。
3. 如果后续你确实要让容器访问宿主机服务，再按 `aspire doctor` 的提示单独处理 container tunnel。

### 验证

```powershell
Get-Command docker
docker version
docker buildx version
aspire doctor
aspire start --isolated --no-build --non-interactive -l Debug
```