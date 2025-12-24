# Built-in Tool Usage Examples

This document explains how to use the built-in MCP tools to generate code.

## Create New Entity

You can generate entity class code through natural language descriptions, markdown tables, or CREATE TABLE SQL statements. When describing, it is best to clearly specify the module the entity belongs to. For example:

```
I need to generate an Order entity class in the Order module with the following fields:
Order ID - Integer - Primary Key
Customer Name - String - Required
xxxx
```

Or:
```sql
-- Based on the SQL above, generate the entity model in the Order module.
```

Or:
```
I need to generate an Order entity class in the Order module to provide simple order management functionality. Please generate common fields accordingly.
```

You can provide requirements or explicit specifications for generating entities. Usually, you need to specify which module the entity belongs to. While module information is not required, it is the framework's recommended practice.

## Generate DTO

Generating a DTO is straightforward. Select the entity file in the client (typically via `#`), then ask it to generate the DTO.

## Generate Manager

Generating a Manager is straightforward. Select the entity file in the client (typically via `#`), then ask it to generate the Manager.

## Generate Controller

Generating a Controller requires both selecting the entity file in the client (typically via `#`) and specifying which service to generate it in. For example:

```
Generate a controller for the #file:ChatMessage.cs entity in the #file:AdminService service.
```

## Add New Module

Generating a module is straightforward. Simply provide the module name and description.

## Generate Razor Template

This tool assists you in writing razor templates for use in code generation tasks.

Typically, you provide an entity class as context, then specify what template content you want to generate. For example:

```
Use the MCP tool to generate an Angular Material mat-table list razor template for displaying entity lists with filter controls.
UI uses Material Angular.
Generate razor templates for both .html and .ts files.
```
