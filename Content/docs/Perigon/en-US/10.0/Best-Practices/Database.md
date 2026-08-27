# Relational Database

This article introduces best practices for relational database design and use.

## Choosing a Database

In the .NET ecosystem, choose `SQL Server` first, then `PostgreSQL`.

- Choose `SQL Server` for commercial projects
- Choose `PostgreSQL` for free projects

### Rationale

- Powerful functionality with broad applicability
- Excellent .NET ecosystem support backed by the Microsoft development team
- EF Core has strong support and timely updates

> [!NOTE]
> New projects should use `SQL Server 2025+` and `PostgreSQL 18+`.

## Database Operations

### Using Entity Framework Core

EF Core is Microsoft's official ORM framework. Use EF Core as your standard data access method. It also supports native SQL queries and is optimized by both official and community efforts, offering high query performance.

### Batch Operations

For large-scale insert, update, or delete operations prioritizing speed, EF Core is not ideal. Use [EFCore.BulkExtensions](https://github.com/borisdj/EFCore.BulkExtensions) instead, which provides database-specific implementations for efficient batch operations.

## Database Table Structure Design

Here are recommended practices and guidance to help you avoid design debates.

### Foreign Keys

❌ Never using foreign keys is a poor practice that loses important relational database features.

Use foreign keys within the same domain model to strengthen constraints. Use them selectively across domain models.

A typical case is the `user entity`, which is often cross-domain, cross-service, or cross-database. In such cases, foreign keys should not or cannot be used.

### Field Type Selection

To minimize time spent on design choices, here are recommended field types:

- ✅ Use `Guid` for primary keys, client-generated, using `Guid V7`
- ✅ Avoid string delimiters for multiple values; use array types (PostgreSQL) or JSON types (SQL Server)
- ✅ Use `DateTimeOffset` for date-time values, converting to UTC when storing
- ✅ Use `DateOnly` for date-only values, converting to UTC when storing
- ✅ Use optimistic lock fields like `RowVersion` only when necessary

> [!TIP]
> Avoid wasting time debating design choices. Use these recommended practices unless they don't fit your business requirements.

## Database Migration

As you iterate development, database structure changes. Use `Code First` to centrally manage the database schema and avoid manual operation inconsistencies.

### ApiStandard migration architecture

`ApiStandard` uses Aspire's `AddEFMigrations` API in `AppHost`. The migration resource is attached to the default `AdminService` project:

```csharp
var adminMigrations = adminService
    .AddEFMigrations(
        "AdminService-Migrations",
        "EntityFramework.AppDbContext.DefaultDbContext"
    )
    .WithMigrationsProject("..\\Definition\\EntityFramework\\EntityFramework.csproj")
    .WithReference(database)
    .WaitFor(database)
    .RunDatabaseUpdateOnStart()
    .PublishAsMigrationBundle(publishContainer: true);

apiService.WaitForCompletion(adminMigrations);
adminService.WaitForCompletion(adminMigrations);
```

- During local `aspire start`, `RunDatabaseUpdateOnStart()` applies the database update and API/admin resources wait for the migration resource.
- `RunDatabaseUpdateOnStart()` affects local run mode only; it does not replace the migration step in a production release.
- `PublishAsMigrationBundle(publishContainer: true)` creates a migration container for targets such as Docker Compose and Kubernetes.
- For Kubernetes, the template's `PublishAsKubernetesService` customization converts the migration workload to a `batch/v1 Job` and sets `restartPolicy: OnFailure`. The Job exits after success and must not be treated as a long-running API service.

Migration bundles are idempotent, but a production release should still verify that the migration Job succeeds before sending traffic to the new API version.

See the official Aspire guides: [automated EF Core migrations with AddEFMigrations](https://aspire.dev/integrations/databases/efcore/migrations/#automated-ef-migrations-with-addefmigrations), [preventing container restarts per environment](https://aspire.dev/integrations/databases/efcore/migrations/#preventing-container-restarts-per-environment), and [seed data in a database](https://aspire.dev/integrations/databases/efcore/seed-database/).

### Create migrations

The `scripts` directory provides `EFMigrations.ps1` for generating migrations. It reads `Components:Database` and `Components:IsMultiTenant` from `src/AppHost/appsettings.Development.json`, exports them as `Components__Database` and `Components__IsMultiTenant`, and runs EF tooling with `AdminService` as the startup project and `EntityFramework` as the migrations project:

```powershell
.\scripts\EFMigrations.ps1 Init
```

Migration files are generated in `EntityFramework/Migrations` by default. Generate a migration after changing the model, then validate the local update flow through AppHost. Do not edit a migration that has already been applied to production.

### Seed data

The default database uses EF Core `UseSeeding` and `UseAsyncSeeding` to create the `default.com` tenant. Seeding stores the default business connection in `DbConnectionString` and the analysis connection in `AnalysisConnectionString`; when no separate analysis connection is configured, the analysis connection uses the business default. Both paths use the same idempotent check, so rerunning migrations does not insert duplicate default tenants.

The default tenant is the global tenant catalog root, so it does not receive a `TenantId`; normal tenant entities continue to follow the template's tenant-isolation rules regardless of the `IsMultiTenant` setting.

See [Seed data in a database using Aspire](https://aspire.dev/integrations/databases/efcore/seed-database/) and [EF Core Data Seeding](https://learn.microsoft.com/ef/core/modeling/data-seeding).

## Multi-Database Support

In the `AppDbContext` directory of the `EntityFramework` project, add additional `DbContext` classes.

Then register the new `DbContext` in the `FrameworkExtensions` extension class of the `ServiceDefaults` project.

When needed, obtain the corresponding `DbContext` instance via the `UniversalDbFactory` factory class.
