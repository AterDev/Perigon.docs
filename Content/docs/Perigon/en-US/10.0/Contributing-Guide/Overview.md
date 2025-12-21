# Contributing Guide Overview

The contributing guide is mainly to help developers better participate in the development of Ater.Dry. This part will detail the design ideas, implementation principles, development guidelines, etc. of the internal implementation of the tool, so that developers can have a deeper understanding and participation in the development of Ater.Dry.

## Built-in Code Generation

The built-in code generation function is based on the template's use of `EntityFramework Core`, depending on entity information, to generate `Dto`, `Manager`, `Controller` related functions.

Including built-in functions to generate frontend Angular and Csharp client request services through `OpenAPI`.

### Parsing Entities

There are currently two ways to parse entities. One is to perform static parsing of entity classes through Roslyn.

The other is to model the database context through `EntityFrameworkCore.Design` to obtain relevant information.

Through `EntityFrameworkCore.Design`, more entity information can be obtained, including entity relationships, properties, etc., which is very helpful for code generation and frontend requests.

Regarding comments, document comment information will be extracted through `XmlDocHelper`.
