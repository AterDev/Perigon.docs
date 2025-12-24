# Contributing Guide Overview

This guide provides detailed information on the design ideas, implementation principles, and development guidelines of the tool's internal implementation. It enables developers to have a deeper understanding of and participate in the development of Perigon.

## Project Structure

The Perigon project mainly includes the following components:

- **scripts**: Contains script files for assisting development and deployment.
- **src**: Contains main source code files.
  - Command/CommandLine: Command-line tool implementation.
  - Definition: Definition layer
    - CodeGenerator: Core code generation logic
    - EfCoreContext: EntityFramework Core related definitions
    - Entity: Entity definitions
    - Share: Shared helper classes and generation services
  - Modules/StudioMod: Studio business logic implementation module.
  - Services/AterStudio: ASP.NET Core application providing Studio Web UI management interface and MCP service.

## Command-Line Tool

Implemented based on `Spectre.Console.Cli`. Implemented in the `CommandLine` project by calling `CommandService` to invoke specific logic.

## Studio Management Interface

The `AterStudio` project is a Web application implemented based on `Blazor Server`. The `AterStudio/Components` directory contains implementations of various components.

Components call **Manager** classes in the `Modules/StudioMod` module to implement specific business logic.

## Built-in Code Generation

Code generation primarily relies on `Roslyn` for implementation, with core code in the `Definition/CodeGenerator` directory.

### Entity Parsing

Currently, there are two methods for parsing entities:

1. **Roslyn Static Analysis**: Perform static parsing of entity classes through Roslyn.
2. **EntityFramework Core Design**: Model the database context through `EntityFrameworkCore.Design` to obtain relevant information.

Through `EntityFrameworkCore.Design`, more entity information can be obtained, including entity relationships and properties, which is very helpful for code generation and frontend requests.

Comments are extracted through `XmlDocHelper` for documentation information.

### OpenAPI Parsing

Parse OpenAPI specifications using `Microsoft.OpenApi` to extract relevant API information.

Different types of client request service generation are implemented by inheriting the `ClientRequestBase` abstract class. Type parsing for each language is implemented by inheriting `LanguageFormatterBase`.

## Running and Testing

The simplest and most intuitive way is to run the `AterStudio` project directly, which will start the Web application providing the Studio management interface.

For the `CommandLine` project, use the `dotnet run` command with parameters.
