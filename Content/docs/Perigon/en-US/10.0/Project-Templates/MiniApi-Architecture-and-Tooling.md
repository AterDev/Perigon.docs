# MiniApi Architecture and Tooling

MiniApi is a Native AOT-oriented Minimal API template. The application is organized around three boundaries:

| Boundary | Responsibility | Typical projects |
| --- | --- | --- |
| Definition | Entity types, DbContext, shared contracts, serialization and service defaults | src/Definition/Entity, src/Definition/EntityFramework, src/Definition/Share, src/Definition/ServiceDefaults |
| Implementation | Module business logic, DTOs, Managers, module services and initialization methods | src/Modules/{ModuleName} |
| Service | HTTP endpoint groups, middleware, dependency injection and application startup | src/Services/ApiService |

AppHost describes the local resource graph. It provides connection strings and service discovery to ApiService, starts the optional Angular frontend, and controls readiness dependencies. It does not contain business logic. Modules expose registration and initialization methods that the service invokes during startup.

Cross-module relationships store IDs. When a request needs data from multiple modules, the service endpoint calls the relevant Managers and passes IDs, purpose-built DTOs, or display snapshots to the Manager that owns the operation. An audit endpoint reads user display names from the system module before it submits the audit. The notification module owns its writes. The endpoint preserves the transaction when both writes belong to the same operation.

## Native AOT request flow

An endpoint binds a DTO, performs framework validation, calls a Manager, and returns a typed result. The endpoint keeps transport concerns in the service layer while Managers and module services own business rules. Put each public DTO in the module's Models/{Entity}Dtos directory, with one public type per file.

The Native AOT build needs compile-time JSON metadata. The generated ApiJsonSerializerContext is the boundary between endpoint contracts and System.Text.Json. After changing endpoint signatures, DTOs, module models, or service projects:

```powershell
perigon aot jsonContext --path .
dotnet publish src/Services/ApiService/ApiService.csproj -c Release
```

The CLI scans services below src/Services, updates the matching serializer context, and leaves startup registration unchanged. Keep the generated context in the service's TypeInfoResolverChain. Add manual JsonSerializable entries for roots that the analyzer cannot infer, including object, non-generic IResult, runtime polymorphism, reflection-driven registration, and dynamic endpoint contracts. Review the generated diff before publishing.

## Database and startup

The template uses AddDbContextPool with DbContextOptions<DefaultDbContext>. The context receives options through dependency injection. Perigon.PostgreSQL 0.3.8 provides source-generated model metadata, PostgreSQL naming conventions, soft-delete behavior for entities derived from the base entity, and database initialization helpers. The MiniApi template uses EnsureCreatedAsync because it has no migration resource. A production deployment should provision and migrate its database according to its own release policy.

Module initialization belongs in a static method such as InitModule.InitializeAsync(DefaultDbContext context, CancellationToken cancellationToken). The published service controls when that method runs, after database initialization. A module should not register a BackgroundService merely to insert seed data, because module loading can occur before the target database exists.

## Module packaging

Install the CLI and check its version before packaging:

```powershell
dotnet tool install --global Perigon.CLI --version 10.2.2
perigon --version
perigon module pack CMSMod ApiService --version 1.1.0 --front-path src/ClientApp/WebApp/src/app/modules/cms
```

The module package contains the selected module's entity, implementation, endpoint, frontend and metadata files. It does not replace service startup code. After installation, run perigon aot jsonContext --path ., review the generated serializer context, build, and publish the service with Native AOT.

Use scripts/PackModules.ps1 from the Perigon.Modules repository for the official multi-module package flow. The script reads modules.json, calculates the requested version bump, runs the CLI with an explicit --version, validates package metadata, and updates the module index only after all packages succeed. CMSMod and ResourceMod can be regenerated locally from the current AOT host with the CLI. Package availability still depends on the module repository release process.

## PostgreSQL tools and schema strategy

The `dotnet perigon` tool is the migration and database utility shipped with `Perigon.PostgreSQL.Tools` 0.3.8:

```powershell
dotnet perigon --version
dotnet perigon migrations add AddOrders --project src/Definition/EntityFramework/EntityFramework.csproj
dotnet perigon migrations list --project src/Definition/EntityFramework/EntityFramework.csproj
dotnet perigon database update --project src/Definition/EntityFramework/EntityFramework.csproj --connection "$env:ConnectionStrings__Default"
```

Use migrations when the service owns a versioned schema. `MigrateAsync` creates a missing target database through PostgreSQL's maintenance database and then applies migrations. `EnsureCreatedAsync` creates a schema directly without a migrations history and is the MiniApi template's choice because MiniApi has no migration resource. Do not combine `EnsureCreatedAsync` with a migration-based database.

To install a module package into an existing service:

```powershell
perigon module install ./package_modules/CMSMod.zip ApiService --front-path src/ClientApp/WebApp
```

The current published tool versions are Perigon.CLI 10.2.2, Perigon.PostgreSQL 0.3.8, and Perigon.templates 1.3.18.
