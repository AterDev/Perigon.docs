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

The `MigrationsService` project handles database structure updates. When you start the application through `AppHost`, it automatically applies the latest migrations before other services start.

The `scripts` directory provides `EFMigrations.ps1` for generating migrations. Use it directly or modify it as needed. Migration files are generated in `EntityFramework/Migrations` by default.

## Multi-Database Support

In the `AppDbContext` directory of the `EntityFramework` project, add additional `DbContext` classes.

Then register the new `DbContext` in the `FrameworkExtensions` extension class of the `ServiceDefaults` project.

When needed, obtain the corresponding `DbContext` instance via the `UniversalDbFactory` factory class.
