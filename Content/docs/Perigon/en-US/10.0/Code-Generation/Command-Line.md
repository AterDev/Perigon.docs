# Command Line

Perigon provides the `perigon` command-line tool for creating solutions, adding resources, generating code, packaging modules, installing modules, and launching Studio or MCP services.

## Quick Start

View the command overview:

```pwsh
perigon -h
```

View detailed help for a specific command:

```pwsh
perigon <command> -h
```

For example:

```pwsh
perigon add -h
perigon generate request -h
```

## Command Overview

The main commands shown by `perigon -h` are listed below:

| Command | Description |
| --- | --- |
| `new <name>` | Create a new .NET solution |
| `add` | Add resources to the current solution |
| `studio` | Start Perigon Studio |
| `generate` | Run code generation |
| `mcp` | Provide Model Context Protocol tools |
| `pack <ModuleName> <ServiceName>` | Package a module as a zip file |
| `install <PackagePath> <ServiceName>` | Install a module package into a project |

## new

The `new` command creates a new solution. It provides roughly the same result as creating a solution through the Studio UI.

```pwsh
perigon new <name>
```

Example:

```pwsh
perigon new DemoApp
```

Help output:

```sh
DESCRIPTION:
Create new .NET solution

USAGE:
    perigon new <name> [OPTIONS]

EXAMPLES:
    perigon new name

ARGUMENTS:
    <name>    Solution Name

OPTIONS:
    -h, --help    Prints help information
```

After you run the command, the CLI guides you through solution initialization, for example:

1. Select a database type, such as `SqlServer` or `PostgreSQL`
2. Select a cache type
3. Select a frontend integration option
4. Specify the output directory, which defaults to the current directory
5. Confirm the configuration and start generation

## add

`add` is a newly added command used to create modules and services in the **current solution**.

```pwsh
perigon add [OPTIONS] <COMMAND>
```

Examples:

```pwsh
perigon add module FileManagerMod
perigon add service AdminService
```

Help output:

```sh
DESCRIPTION:
Add resources to the current solution

USAGE:
    perigon add [OPTIONS] <COMMAND>

EXAMPLES:
    perigon add module FileManagerMod
    perigon add service AdminService

OPTIONS:
    -h, --help    Prints help information

COMMANDS:
    module <ModuleName>      Create a new module in the current solution
    service <ServiceName>    Create a new service in the current solution
```

### add module

Create a new module:

```pwsh
perigon add module <ModuleName>
```

Example:

```pwsh
perigon add module FileManagerMod
```

Notes:

- `ModuleName` is the module name
- The `Mod` suffix is optional, and the CLI handles it automatically

Help output:

```sh
DESCRIPTION:
Create a new module in the current solution

USAGE:
    perigon add module <ModuleName> [OPTIONS]

EXAMPLES:
    perigon add module FileManagerMod

ARGUMENTS:
    <ModuleName>    Module name, `Mod` suffix is optional / 模块名称，可省略 `Mod` 后缀

OPTIONS:
    -h, --help    Prints help information
```

### add service

Create a new service:

```pwsh
perigon add service <ServiceName>
```

Example:

```pwsh
perigon add service AdminService
```

Notes:

- `ServiceName` is the service name

Help output:

```sh
DESCRIPTION:
Create a new service in the current solution

USAGE:
    perigon add service <ServiceName> [OPTIONS]

EXAMPLES:
    perigon add service AdminService

ARGUMENTS:
    <ServiceName>    Service name / 服务名称

OPTIONS:
    -h, --help    Prints help information
```

## studio

The `studio` command starts Perigon Studio. Most visual operations can be completed in Studio.

```pwsh
perigon studio
```

Help output:

```sh
DESCRIPTION:
start Perigon Studio

USAGE:
    perigon studio [OPTIONS] [COMMAND]

OPTIONS:
    -h, --help    Prints help information

COMMANDS:
    update    update studio
```

### studio update

Update Studio:

```pwsh
perigon studio update
```

Help output:

```sh
DESCRIPTION:
update studio

USAGE:
    perigon studio update [OPTIONS]

OPTIONS:
    -h, --help    Prints help information
```

## generate

The `generate` command runs code generation tasks.

```pwsh
perigon generate [OPTIONS] <COMMAND>
```

It currently supports generating client request services and model files.

Help output:

```sh
DESCRIPTION:
Code generate

USAGE:
    perigon generate [OPTIONS] <COMMAND>

EXAMPLES:
    perigon generate request ./openapi.json ./src/services -t angular

OPTIONS:
    -h, --help    Prints help information

COMMANDS:
    request <path|url> <outputPath>    Generate client request service and models
```

### generate request

Generate client request services and models from an OpenAPI document.

```pwsh
perigon generate request <path|url> <outputPath> [OPTIONS]
```

Example:

```pwsh
perigon generate request https://localhost:17001/swagger/v1/swagger.json ./src/services -t angular
```

Help output:

```sh
DESCRIPTION:
Generate client request service and models

USAGE:
    perigon generate request <path|url> <outputPath> [OPTIONS]

EXAMPLES:
    perigon generate request ./openapi.json ./src/services -t angular

ARGUMENTS:
    <path|url>      Local path or url, support json format
    <outputPath>    The output path

OPTIONS:
                        DEFAULT
    -h, --help                     Prints help information
    -t, --type          angular    Support types: csharp/angular/axios, default: angular
    -m, --only-model    false      Only generate model files
```

Parameter notes:

- `<path|url>`: Local OpenAPI file path or remote URL
- `<outputPath>`: Output directory for generated code
- `-t, --type`: Target output type. Supported values are `csharp`, `angular`, and `axios`
- `-m, --only-model`: Generate model files only

## mcp

The `mcp` command provides Perigon Model Context Protocol tools.

```pwsh
perigon mcp [OPTIONS] <COMMAND>
```

Help output:

```sh
DESCRIPTION:
Model Context Protocol tools

USAGE:
    perigon mcp [OPTIONS] <COMMAND>

OPTIONS:
    -h, --help    Prints help information

COMMANDS:
    config    Print MCP stdio config JSON
    start     Start MCP server with stdio transport
```

### mcp config

Print the MCP stdio configuration JSON:

```pwsh
perigon mcp config
```

Help output:

```sh
DESCRIPTION:
Print MCP stdio config JSON

USAGE:
    perigon mcp config [OPTIONS]

OPTIONS:
    -h, --help    Prints help information
```

### mcp start

Start the MCP service over stdio transport:

```pwsh
perigon mcp start
```

Help output:

```sh
DESCRIPTION:
Start MCP server with stdio transport

USAGE:
    perigon mcp start [OPTIONS]

OPTIONS:
    -h, --help    Prints help information
```

## pack

The `pack` command packages a module as a zip file.

```pwsh
perigon pack <ModuleName> <ServiceName>
```

Example:

```pwsh
perigon pack FileManagerMod AdminService
```

Help output:

```sh
DESCRIPTION:
Package module as zip file

USAGE:
    perigon pack <ModuleName> <ServiceName> [OPTIONS]

EXAMPLES:
    perigon pack FileManagerMod AdminService

ARGUMENTS:
    <ModuleName>     Module name (with Mod suffix)
    <ServiceName>    Service name in Services directory

OPTIONS:
    -h, --help    Prints help information
```

Parameter notes:

- `ModuleName`: Module name, usually ending with `Mod`
- `ServiceName`: Service name, corresponding to an API service directory under `Services`

## install

The `install` command installs a module package into a project.

```pwsh
perigon install <PackagePath> <ServiceName>
```

Example:

```pwsh
perigon install ./package_modules/FileManagerMod.zip AdminService
```

Help output:

```sh
DESCRIPTION:
Install module package to project

USAGE:
    perigon install <PackagePath> <ServiceName> [OPTIONS]

EXAMPLES:
    perigon install ./package_modules/FileManagerMod.zip AdminService

ARGUMENTS:
    <PackagePath>    Path to the module package zip file
    <ServiceName>    Service name in Services directory

OPTIONS:
    -h, --help    Prints help information
```

Parameter notes:

- `PackagePath`: Path to the module zip package
- `ServiceName`: Target service name, corresponding to an API service directory under `Services`

## Notes

- Command descriptions in this document are based on the current `perigon -h` output and the help output of each subcommand.
- If future versions add new commands or parameters, rerun `perigon -h` and `perigon <command> -h`, then update this document accordingly.
