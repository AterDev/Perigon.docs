# Installation

EasyDocs targets .NET 10. Install the global tool from NuGet:

```powershell
dotnet tool install -g Ater.EasyDocs
```

Upgrade an existing installation with:

```powershell
dotnet tool update -g Ater.EasyDocs
```

Verify the installation:

```powershell
ezdoc --version
ezdoc --help
```

The command-line help displays the installed version, the EasyDocs documentation URL, and the GitHub repository URL. The command names are stable English names (`init` and `build`); Chinese aliases (`初始化` and `生成`) are also available. Descriptions follow the system UI language and include the other language as a fallback.

## Requirements

- .NET 10 SDK or a compatible .NET 10 runtime for the tool;
- a writable directory for the source content and generated output;
- a static-file server only when previewing locally.

EasyDocs does not require a database, a web framework, or a runtime on the final hosting platform.
