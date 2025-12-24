# Entity Model Definition

Entity models define application data and relationships. Perigon uses Entity Framework Core for data access. This guide explains conventions for defining entities.

## Consistent Style

EF Core supports two configuration styles:

- Data Annotations (attributes)
- Fluent API (in `OnModelCreating`), optionally via `IEntityTypeConfiguration` per-entity classes

Pick one approach and be consistent. Two common practices:

- Configure every entity via `IEntityTypeConfiguration`.
- Use annotations for simple cases (length, keys) and Fluent API for complex ones (relationships, converters, JSON).

## Conventions

Recommended (not enforced) conventions:

- Group entities by module folder and matching namespace.
- Every property has comments; every enum has a `[Description]` attribute.
- Entities inherit `EntityBase` by default (`Id`, `CreatedAt`, `UpdatedAt`, `IsDeleted`).
- Default `Id` is `Guid` (client-generated Guid V7).
- Strings have max length unless truly unbounded.
- Decimal precision/scale is explicit:
  - Small range: `decimal(10,2)`
  - Large range: `decimal(18,6)`

  ```csharp
  [Column(TypeName = "decimal(10,2)")]
  public decimal TotalPrice { get; set; }
  ```

- Every enum value uses `[Description]`.
- Use `DateTimeOffset` rather than `DateTime`.
- Use `DateOnly` for date-only and `TimeOnly` for time-only fields.

## EntityBase

```csharp
public abstract class EntityBase
{
    [Key]
    public Guid Id { get; set; } = Guid.CreateVersion7();
    public DateTimeOffset CreatedTime { get; private set; } = DateTimeOffset.UtcNow;
    public DateTimeOffset UpdatedTime { get; set; }
    public bool IsDeleted { get; set; }
    public Guid TenantId { get; set; }
}
```

Notes:

- Ordered client GUID for primary key.
- Automatic UTC timestamps for creation and updates.
- `IsDeleted` enables soft delete; filtered by default.
- Include `TenantId` as needed.

## Unique Constraints

Model uniqueness carefully and enforce via unique indexes.

`ManagerBase.UpsertAsync` uses the PK to decide insert/update and relies on unique constraints to prevent duplicates. The system uniformly handles `TenantId` indexes and adds filtered indexes to ignore soft-deleted rows.

> [!TIP]
> Adjust defaults in `ContextBase.ConfigureMultiTenantUniqueIndexes`.

## Optimistic Concurrency

Add a concurrency token for concurrent updates:

```csharp
[Timestamp]
public byte[] RowVersion { get; set; }
```

Or use DB-specific tokens (e.g., Postgres `xmin`).

## Relationships

EF infers 1:N and N:N via navigation properties. Use Fluent API to define 1:1 and join tables.

Practical conventions:

### Explicit FK Ids

```csharp
public class Blog : EntityBase
{
    public string Title { get; set; }
    public Guid UserId { get; set; }
    [ForeignKey(nameof(UserId))]
    public User User { get; set; }
}
```

Explicit FK Ids improve query flexibility. For N:N, prefer explicit join entities with explicit Ids.

### JSON and Arrays

Leverage JSON/array types (e.g., Postgres) to avoid excessive joins when suitable. EF supports JSON queries well.

### Cross-Module Relationships

Keep related entities in the same module and use FK constraints there. For widely referenced modules (like Users), other modules may store only `UserId` without navigation properties.

> [!TIP]
> Prefer FKs when possible for integrity. Removing them later is easier than adding them later.
