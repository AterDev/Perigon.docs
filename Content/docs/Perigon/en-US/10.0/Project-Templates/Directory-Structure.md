# Directory Structure

This article introduces the directory structure of the solution template.

The structure below primarily describes `ApiStandard`. `MiniApi` does not include `AdminService` or default `Modules`; its default business code lives in `src/Services/ApiService` under `Endpoints/Managers/Models/Services`.

## docs

Used to store project-related documentation materials by category, such as requirement background, architecture design, module design, technical implementation plans, etc.

## scripts

Used to store commonly used script files, mainly ps1 or cs scripts, to reduce repetitive workload.

---

## src

src is the source code directory, containing all source code files of the solution, divided into different subdirectories according to functionality:

### Perigon Base Libraries

Provides basic class libraries needed for development, all provided in source code form, facilitating developers to modify and extend as needed. Includes the following projects:

- **Perigon.AspNetCore**: Common parts related to Web development, including basic model definitions, common extension methods, and tool helper classes.
- **Perigon.AspNetCore.Toolkit**: Integration of commonly used third-party libraries in Web development, such as sending emails, graphic verification codes, Excel export, etc.
- **Perigon.AspNetCore.SourceGeneration**: Source code generator and code analyzer related functions.

Since the framework layer is independent of projects and business, these can be packaged into class libraries. You can develop your own toolkit based on this and publish it to private or public NuGet sources for use in other projects.

### Definition

The definition layer defines business models, determines the data model and behavior of the business, and is the foundation and premise of business implementation, usually including:

- **Entity**: Entity definition, determines the storage structure of core business models.
- **EntityFramework**: ORM mapping definition, determines the mapping relationship between entities and database tables.
- **Share**: Some shareable model content, such as DTO, Options, etc.
- **ServiceDefaults**: Definition of common service injection, such as health checks, retry mechanisms, logs, etc.

### Modules

Module is the carrier of the implementation layer, mainly implementing business logic, implemented by breaking it down into different Modules.

Business requirements often involve multiple domains or modules. Install modules through `Perigon.CLI` or module packages when needed; the blank template does not include business modules by default.

Typical structure is as follows:

- CommonMod: Shared module for use by various business modules.
- CustomerModule: Customer module, containing customer-related business logic.
- OrderModule: Order module, containing order-related business logic.

for each module, it usually includes the following contents:

- Models
- Managers
- Services
- ModuleExtensions.cs

### Services

The service layer faces actual callers. Usually we provide API calls through `Restful API` or `Grpc`. Different services are usually deployed with different images.

For API services, we need to focus on:

- User Requests: Parsing and validation of requests
- Business Logic: Implement business logic by calling the business layer, not directly in the service layer.
- Return Results: Formatting and returning responses

At this level, the template provides the following services by default:

- AdminService: Provides API services for the admin backend.
- ApiService: Provides API services for frontend applications.
- AppHost: `ApiStandard` declares its EF Core migration resource through Aspire `AddEFMigrations`; `MiniApi` has no built-in migration resource.

---

## tests

- `UnitTest`: does not reference AppHost or start Aspire; use it for fast unit tests.
- `ApiTest`: Aspire integration tests; its global hook starts AppHost and tests are marked with `Category=Integration`.

## templates

Template file directory, used to store templates needed for custom code generation.
