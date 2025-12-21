# Built-in Tool Usage Examples

This article mainly explains how to use the built-in MCP tools to generate code.

## Create New Entity

You can generate entity class code through natural language descriptions, markdown tables, or CREATE TABLE SQL statements. When describing, it's best to clearly specify the module the entity belongs to, for example:

```
I need to generate an Order entity class, it belongs to the Order module, with the following fields:
Order ID - Integer - Primary Key
Customer Name - String - Required
xxxx
```

Or
```
// sql
Generate entity model in the Order module based on the above SQL.
```

Or

```
I need to generate an Order entity class in the Order module to provide simple order management functionality, please generate common fields accordingly.
```

You can provide requirements or explicit basis for generating entities. Usually, you also need to tell it which module it belongs to. Module information is not required, but it is the framework's recommended practice.

## Generate DTO

Generating DTO is simple. You need to select the entity file in the client (usually through #), then tell it to generate DTO.

## Generate Manager

Generating Manager is simple. You need to select the entity file in the client (usually through #), then tell it to generate Manager.

## Generate Controller

Generating Controller requires not only selecting the entity file in the client (usually through #), but also telling it which service to generate to, for example:

```
Generate controller to #file:AdminService service based on #file:ChatMessage.cs
```

## Add New Module

Generating a module is simple. You just need to tell it the module name and description.

## Generate Razor Template

This is a tool to assist you in writing razor templates for use in code generation tasks.

Usually you need to provide an entity class as context, then tell it what template content you want to generate, for example:

```
Call mcp tool to generate angular frontend mat-table list razor template for displaying entity list, including filter controls.
UI uses material angular.
Generate razor templates for .html and .ts files respectively.
```
