# Command Line

Perigon provides the `perigon` command-line tool for creating solutions, adding resources, generating code, packaging modules, installing modules, and launching Studio or Agent MCP services.

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
perigon generate -h
perigon generate request -h
```

## Command Overview

The main commands shown by `perigon -h` are listed below:

| Command | Description |
| --- | --- |
| `new <name>` | Create a new .NET solution |
| `update` | Compare and update the current project from the latest Perigon template |
| `add` | Add resources to the current solution |
| `studio` | Start Perigon Studio |
| `generate` | Run code generation |
| `agent` | Initialize Agent configuration or start the Agent MCP service |
| `module pack <ModuleName> <ServiceName>` | Package a module as a zip file |
| `module install <PackagePath> <ServiceName>` | Install a module package into a project |

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
3. Select official modules such as `Perigon.SystemMod`, `Perigon.CMSMod`, or `Perigon.ResourceMod`
4. Select a frontend integration option
5. Specify the output directory, which defaults to the current directory
6. Confirm the configuration and start generation

Notes:

- The official module list comes from `Perigon.Modules/modules.json`.
- Selected official modules are installed automatically after the solution is generated.
- If loading the official module list fails, the command shows a warning but still lets you continue creating the solution.

## update

The `update` command compares an existing project with the latest Perigon solution template and applies the selected differences. Run it from an interactive terminal at the solution root or one of its subdirectories:

```pwsh
perigon update
```

Before starting, the CLI warns that template updates may overwrite local changes and recommends creating and switching to a new Git branch. It then:

1. Updates the installed `Perigon.templates` package, or installs it if it is not available.
2. Generates a temporary comparison project using the current project's template type and frontend mode.
3. Opens a two-pane diff selector: the left pane lists only the filenames of added or changed template files with `(+added -removed)` line counts, and the right pane shows the full relative path and colorized diff.
4. Use the arrow keys to move, press Space to select or unselect files, use `PgUp/PgDn` to scroll the current file's diff in the right pane, select multiple files as needed, press Enter to apply the selected differences, or press `Esc` to cancel. Both panes show their visible range and scroll markers, and moving through the list keeps the focused file visible.

The current project is modified only after pressing Enter to apply. Pressing `Esc` leaves it unchanged, but the template update or installation has already completed before the selector. Comparison ignores line-ending differences, leading/trailing whitespace, changes in consecutive whitespace, and blank-line differences to avoid formatting noise; a strict snapshot check still runs before applying. The command processes only files that exist in the template; it does not delete project-only files and ignores files outside these scopes:

- `.cs` files under `src/Perigon`;
- `.cs` files under `src/Definition/ServiceDefault` or `src/Definition/ServiceDefaults`;
- `.cs` files under `src/Definition/Share`;
- `.cs` files under `src/Definition/EntityFramework`, excluding the entire `Migrations` directory and `DefaultDbContext.cs`, `AnalysisDbContext.cs`, and `ReadonlyDbContext.cs`;
- `.ps1` files under `scripts`;
- all files under `.agent` and `.agents`.

The exact file `src/Perigon/Perigon.AspNetCore/Constants/WebConst.cs` is also excluded so project-specific web constants are preserved.

If a project file changes after comparison, the update is rejected to avoid applying stale differences over the current project. After writing the selected files, the CLI runs `dotnet build` from the solution root and reports either build success or the build error. A failed build does not roll back files already applied, so fix the reported errors or restore through Git. Review the displayed differences first and make sure the worktree is committed or otherwise recoverable.

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

It supports printing entity-generation rules, generating DTOs/Managers/Controllers, and generating client request services and model files.

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
    entity                              Print entity model generation rules
    dto <EntityPath>                    Generate DTOs from an entity
    manager <EntityPath>                Generate a Manager from an entity
    controller <EntityPath> <ServicePath|ServiceName>
                                       Generate a Controller from an entity
    request <path|url> <outputPath>      Generate client request service and models
```

### generate entity

Print entity-model creation rules for LLMs or other code-generation workflows. This command does not create an entity file by itself.

```pwsh
perigon generate entity
```

The rules place entities in the `src/Definition/Entity` project. When a module is specified, use a directory named after the module with a `Mod` suffix under the entity project, creating it when necessary. If the module does not exist yet, create the module first. The rules also cover `EntityBase`, nullable reference types, string lengths, enum descriptions, indexes, relationships, and `DbSet` declarations.

### generate dto

Generate DTOs from an entity file:

```pwsh
perigon generate dto <EntityPath> [-f|--force]
```

Use `--force` to overwrite generated files.

### generate manager

Generate a Manager from an entity file:

```pwsh
perigon generate manager <EntityPath> [-f|--force]
```

Use `--force` to overwrite generated files.

### generate controller

Generate a Controller from an entity file:

```pwsh
perigon generate controller <EntityPath> <ServicePath|ServiceName> [-f|--force]
```

`ServicePath|ServiceName` can be a service directory, a `.csproj` path, or a service name. `controller` also has the `api` alias. Use `--force` to overwrite generated files.

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
    -c, --cover-base-service    false      Overwrite generated base.service.ts
```

Parameter notes:

- `<path|url>`: Local OpenAPI file path or remote URL
- `<outputPath>`: Output directory for generated code
- `-t, --type`: Target output type. Supported values are `csharp`, `angular`, and `axios`
- `-m, --only-model`: Generate model files only
- `-c, --cover-base-service`: Overwrite an existing `base.service.ts`; customized content is preserved by default. This mainly applies to Angular/Axios frontend request clients, and Studio also preserves the file by default. With `-m/--only-model`, no base service is generated or overwritten. C# clients generate `BaseService.cs` instead.

When the target type is `csharp`, OpenAPI `multipart/form-data` requests generate multipart upload methods and use the HTTP method declared by the document, such as `POST` or `PUT`. A single file field uses `MultipartFile` (wrapping a `Stream`, file name, and optional MIME type), while multiple file fields use `IEnumerable<MultipartFile>`. String, numeric, boolean, and array fields are also submitted as form fields. Angular and Axios clients use `File`/`File[]`, append fields to `FormData` using the schema field names, and follow the declared request method. C# clients generate relative URIs without a leading `/` and pass them directly to `HttpClient` for merging with `BaseAddress`; `BaseAddress` must end with `/`, for example `https://example.com/api/`, so multi-level base paths are preserved.

When an OpenAPI response is 204, 205, or 304, or the request method is `HEAD`, clients generate no-content return types: C# uses `Task`, while Angular/Axios use `void`. For non-success responses, C# clients preserve the raw response and expose its `Content`, `StatusCode`, and `ReasonPhrase` through `ResponseContent`, allowing callers to handle the actual error format outside the generated client.

When an OpenAPI tag contains spaces or other characters that cannot be used directly in a code identifier, the generator converts it to a PascalCase service name. For example, `User Management` generates `UserManagementService` or `UserManagementRestService`, while service filenames use hyphenated names.

## agent

The `agent` command initializes Perigon Agent integration or starts the MCP service used by IDEs and coding agents.

```pwsh
perigon agent [OPTIONS] <COMMAND>
```

The main subcommands are:

| Subcommand | Purpose |
| --- | --- |
| `init` | Interactively choose MCP or Skills integration; the MCP option writes `.vscode/mcp.json`. |
| `mcp` | Start the Perigon Agent MCP server over stdio transport. |

```pwsh
perigon agent init
perigon agent mcp
```

`perigon agent mcp` loads Perigon code-generation tools and uses the MCP client's `roots/list` request to discover the project root. See [Perigon Agent MCP](../AI-Support/MCP.md) for tool capabilities and IDE configuration. The legacy `perigon mcp config` and `perigon mcp start` commands are not the current recommended form.

## module pack

The `module pack` command packages a module as a zip file.

```pwsh
perigon module pack <ModuleName> <ServiceName> [-v|--version <VERSION>] [--front-path <FRONT_PATH>]
```

Example:

```pwsh
perigon module pack FileManagerMod AdminService --version 1.2.0
```

Help output:

```sh
DESCRIPTION:
Package module as zip file

USAGE:
    perigon module pack <ModuleName> <ServiceName> [OPTIONS]

EXAMPLES:
    perigon module pack FileManagerMod AdminService --front-path src/ClientApp/WebApp/src/app/modules/file-manager

ARGUMENTS:
    <ModuleName>     Module name (with Mod suffix)
    <ServiceName>    Service name in Services directory

OPTIONS:
    -h, --help                       Prints help information
    -v, --version <VERSION>          Package version; defaults to 1.0.0 when omitted / 包版本号；省略时默认使用 1.0.0
        --front-path <FRONT_PATH>    Frontend module directory to include in the package
```

Parameter notes:

- `ModuleName`: Module name, usually ending with `Mod`
- `ServiceName`: Service name, corresponding to an API service directory under `Services`
- `-v/--version`: Optional. The version written to the module-package metadata; omitted versions use `1.0.0` and print a warning.
- `--front-path`: Optional. The individual frontend module directory to package, for example `src/ClientApp/WebApp/src/app/modules/file-manager`.

### Frontend packaging and limitations

When `--front-path` is supplied, the CLI packages that directory and its sibling `share` directory into the zip:

```text
Frontend/file-manager/...
Frontend/share/...
```

- `file-manager` is the last directory name in `--front-path`; `share` must be a sibling of that module directory.
- When `--front-path` is omitted, no frontend content is included and backend packaging still succeeds. If the specified module directory does not exist, packaging fails. If the sibling `share` directory does not exist, only the module directory is packaged.
- Only files under the specified module directory and its sibling `share` directory are included. The frontend app shell, global routes, root `package.json`, lockfiles, and other module directories are excluded.
- The package does not install npm/pnpm dependencies. The target project must provide a compatible frontend application and dependencies.

## module install

The `module install` command installs a module package into a project. It also supports installing a module directly by official package name.

```pwsh
perigon module install [PackagePath] [ServiceName] [--front-path <FRONT_PATH>]
```

Example:

```pwsh
perigon module install ./package_modules/FileManagerMod.zip AdminService
```

Or install an official module directly:

```pwsh
perigon module install Perigon.SystemMod AdminService
```

Help output:

```sh
DESCRIPTION:
Install module package to project

USAGE:
    perigon module install [PackagePath] [ServiceName] [OPTIONS]

EXAMPLES:
    perigon module install ./package_modules/FileManagerMod.zip AdminService --front-path src/ClientApp/WebApp/src/app/modules

ARGUMENTS:
    <PackagePath>    Path to the module package zip file, or official package name like Perigon.SystemMod
    <ServiceName>    Service name in Services directory

OPTIONS:
    -h, --help                       Prints help information
        --front-path <FRONT_PATH>    Directory where bundled frontend code will be restored
```

Parameter notes:

- `PackagePath`: Path to the module zip package, or an official module package name such as `Perigon.SystemMod`
- `ServiceName`: Target service name, corresponding to an API service directory under `Services`
- `--front-path`: Optional. The frontend module root directory, such as `src/ClientApp/WebApp/src/app/modules`; it is not an individual module directory.

### Frontend restore rules

When the package contains `Frontend` content and `--front-path` is supplied, installation restores:

```text
<FRONT_PATH>/file-manager/...
<FRONT_PATH>/share/...
```

- Same-named files in the module directory are overwritten as part of module installation.
- Same-named files already in `share` are preserved; only missing files are added.
- Without `--front-path`, backend installation still runs but frontend files are not restored and the CLI displays a warning.
- Module packages no longer contain or process `UseSelfServices`; installation does not modify the target service's `Program.cs` or its default middleware configuration.

## Notes

- Command descriptions in this document are based on the current `perigon -h` output and the help output of each subcommand.
- If future versions add new commands or parameters, rerun `perigon -h` and `perigon <command> -h`, then update this document accordingly.
