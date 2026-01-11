# Directory Structure

This article introduces the directory structure of the solution template.

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

In actual needs, business requirements often involve multiple domains or multiple business modules. We can split them according to business modules. The framework provides the `CommonMod` shared module by default, which is referenced by other modules.

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
- MigrationService: Provides database migration services using EF Core.

---

## templates

Template file directory, used to store templates needed for custom code generation.
