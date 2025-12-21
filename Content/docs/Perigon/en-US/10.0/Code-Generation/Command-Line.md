# Command Line

Provides the **Perigon** command-line tool.

## new

The `new` command is used to create a new solution, with the same effect as creating through the `Studio` graphical interface.

```pwsh
perigon new <name>
```

Solution creation process:

1. Select database type: Sqlserver, PostgreSql
2. Select cache type
3. Select frontend integration
4. Enter directory, defaults to current directory
5. Confirm and run

## studio

The `studio` command is used to launch the Dashboard, where most operations can be completed.

```pwsh
perigon studio
```

## generate

Provides code generation related commands, alias `g`.

Currently supports generation of client request services, for example:

```pwsh
perigon g request https://localhost:17001/swagger/v1/swagger.json ./src/services -t angular
```

You can use `perigon g request -h` to view help information, such as:
```pwsh
DESCRIPTION:
Generate client request services and models

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
