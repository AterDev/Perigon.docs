# Data Access

Database is the foundation and core of application service development. The template uses `Entity Framework Core` as the ORM framework for data access, and uses `BulkExtensions` to optimize the performance of large-scale data operations.

Using `Entity Framework Core` is not only for convenience, but more importantly to standardize the way of data development and access.

It is recommended to use the `Code First` approach to define data models, and then use `DbContext` to access the database.

## Database Context

The template uses `DefaultDbContext` as the default data access context. It inherits from `ContextBase`. Database contexts are centralized in `Definition/EntityFramework/AppDbContext`; define additional contexts in this directory and inherit from the appropriate base type.

### Default, read-only, and analysis contexts

| Type | Responsibility | Use it for |
| --- | --- | --- |
| `DefaultDbContext` | The read/write context for the application's primary business database. Entity sets and migrations are normally maintained around this context. | Normal business queries, creates, updates, deletes, and operations that participate in a primary-database transaction. |
| `ReadonlyDbContext` | The abstract base class for read-only contexts. It disables automatic change detection and throws when `SaveChanges` or `SaveChangesAsync` is called. | A dedicated context for a read-only database, replica, or reporting database. It cannot be instantiated directly. |
| `AnalysisDbContext` | A tenant-aware read/write context derived from `ContextBase`. | Reports, statistics, exports, and analysis workflows that also persist results. |

`AnalysisDbContext` supports both queries and saves. It uses `ConnectionStrings:Analysis` when configured; otherwise it falls back to `ConnectionStrings:Default`. Database permissions are still controlled by the deployment environment. When a context must be read-only, derive it from `ReadonlyDbContext` and use a read-only database account or replica.

`ReadonlyDbContext` limits EF Core save operations only; it is not a substitute for database permissions. Do not issue write SQL through it. If a read-only context needs model types beyond those already exposed by the base context, derive a dedicated context from `ReadonlyDbContext` and declare the required `DbSet` properties and model configuration.

### `AppDbFactory` and `UniversalDbFactory`

The template registers two factories with different responsibilities. Choose one by the connection target and tenant boundary; they are not interchangeable.

| Factory | Creates | Connection selection | Use it for |
| --- | --- | --- | --- |
| `AppDbFactory` | `DefaultDbContext` or `AnalysisDbContext` | `null` is reserved for the system tenant-catalog context and uses the configured default connections. Normal tenant access requires a non-empty TenantId that resolves from the catalog; an empty GUID or unknown tenant fails. A resolved tenant uses its primary or analysis connection, falling back to the corresponding default only when that tenant field is empty. | Most application business logic. `ManagerBase` uses it to obtain the primary context for the current tenant. |
| `UniversalDbFactory` | Any context derived from `DbContext` | Looks up a connection string from the context type name with the `DbContext` suffix removed; for example, `OrdersDbContext` uses `ConnectionStrings:Orders`. The caller also chooses the database provider. | Explicit access to another independent database, or creating contexts for multiple databases by context type. |

For ordinary business Managers, do not create the primary context yourself: inherit from `ManagerBase<DefaultDbContext, TEntity>`. Only create an analysis context explicitly when making analysis queries:

```csharp
public class TenantReportManager(
    AppDbFactory dbFactory,
    IUserContext userContext,
    ILogger<TenantReportManager> logger) : ManagerBase(logger)
{
    public async Task<List<TenantReportItem>> GetAsync()
    {
        await using var db = dbFactory.CreateAnalysisDbContext(userContext.TenantId);
        return await db.Tenants
            .AsNoTracking()
            .Select(x => new TenantReportItem(x.Id, x.Name))
            .ToListAsync();
    }
}
```

Contexts created by these factories are not tracked by the dependency injection container. Dispose a context created with `CreateDbContext` or `CreateAnalysisDbContext` promptly with `using` or `await using`.

## Tenant context and background jobs

`ContextBase` applies tenant filtering and save validation to business entities that inherit from `EntityBase`. `Tenant` is the global tenant catalog root: its inherited `TenantId` is ignored, so an unbound context can read and write the tenant catalog.

Tenant-scoped Managers require a tenant id. In an HTTP request, authentication claims, `UserContext`, and tenant middleware provide that value. A background job has no HTTP request and should not reuse a request-scoped `DbContext` or assume that `IUserContext` already contains a tenant id.

Create a short-lived context for each tenant. First query the global `Tenant` catalog with an unbound context, then create a tenant-bound context for business operations:

```csharp
public sealed class TenantJob(AppDbFactory dbFactory)
{
    public async Task RunAsync(CancellationToken cancellationToken)
    {
        await using var catalogDb = dbFactory.CreateDbContext(null);
        var tenants = await catalogDb.Tenants
            .AsNoTracking()
            .Where(tenant => !tenant.Disabled && !tenant.IsDeleted)
            .ToListAsync(cancellationToken);

        foreach (var tenant in tenants)
        {
            await using var tenantDb = dbFactory.CreateDbContext(tenant.Id);
            await tenantDb.Set<Order>()
                .Where(order => !order.IsDeleted)
                .ExecuteUpdateAsync(
                    update => update.SetProperty(
                        order => order.UpdatedTime,
                        DateTimeOffset.UtcNow),
                    cancellationToken);
        }
    }
}
```

`AppDbFactory` asks the tenant resolver for each non-null TenantId. The resolver checks the shared cache first, then loads the tenant from the global catalog and caches it, so a background job does not need to populate `CacheService` manually. `null` is only for the catalog context; an empty GUID or unknown TenantId fails. Use a separate, short-lived context for each tenant.

Use a dedicated `DbContext` that does not inherit from `ContextBase` only for controlled catalog or cross-tenant maintenance operations. Such a context bypasses tenant filters and ownership validation, so its model and authorization boundary must be deliberately restricted.


## Data Operations

Data queries are an important part of business logic. Business code is usually implemented in `XXXManager`, which inherits from `ManagerBase<TDbContext,TEntity>`, such as:

```csharp
public class AIAgentManager(
    AppDbFactory dbContextFactory,
    ILogger<AIAgentManager> logger,
    IUserContext userContext
) : ManagerBase<DefaultDbContext, AIAgent>(dbContextFactory, userContext, logger)
{
}
```

`ManagerBase<TDbContext,TEntity>` provides some encapsulated data operation methods for the current entity. Of course, you can also completely use `_dbContext` to implement data operations. The parent class provides the following properties:

```csharp
protected IQueryable<TEntity> Queryable { get; set; }
protected readonly ILogger _logger;
protected readonly TDbContext _dbContext;
protected readonly DbSet<TEntity> _dbSet;
```

As above, Queryable uses the `AsNoTracking()` query method by default to avoid data tracking.

> [!IMPORTANT]
> Please do not use `DbContext` directly in the Controller, but implement data operations in business logic through inheriting `ManagerBase`. This can ensure clarity and maintainability of business logic.

## Not Using Database Context or Entity

When your Manager does not involve database operations, or is not limited to a certain database context or entity, you can inherit `ManagerBase(ILogger logger)`, which does not depend on any database context or entity.

```csharp
public class TestManager(MyDbContext context, MyService service, ILogger<TestManager> logger)
    : ManagerBase(logger)
{
}
```

> [!IMPORTANT]
> Inheriting the `ManagerBase` class will generate injection code through the source code generator.

## Tenant Mode

The template uses tenant-aware behavior by default. The current tenant id comes from `IUserContext.TenantId`; the Manager base class passes it to `AppDbFactory`. `null` is reserved for the catalog context, normal tenant requests require a valid non-empty TenantId, and a resolved tenant falls back to the corresponding default connection only when its connection field is empty.

> [!TIP]
> You can modify the database-context creation logic in `AppDbFactory` according to actual needs.

## Multi-Database Operations (Preview)

When your logic needs to operate multiple databases, you can inject the `UniversalDbFactory` service, and then operate different databases.

```csharp
public class TestManager(        
    UniversalDbFactory dbFactory,
    ILogger<TestManager> logger)
    : ManagerBase(logger)
{

    public async Task MultiDatabase()
    {
        var mssqlDb = dbFactory.CreateDbContext<MainDbContext>();
        mssqlDb.Database.SetCommandTimeout(30);
        var tenant = await mssqlDb.Tenants.FirstOrDefaultAsync();

        var pgsqlDb = dbFactory.CreateDbContext<AnotherDbContext>(DatabaseType.PostgreSql);
        pgsqlDb.Database.SetCommandTimeout(30);
        var user = await pgsqlDb.Tenants.FirstOrDefaultAsync(u => u.TenantId == tenant.TenantId);
    }
}
```

`UniversalDbFactory` obtains the corresponding connection string from the database context name and creates the matching `DbContext`. For example, `OrdersDbContext` reads `ConnectionStrings:Orders`. It does not read the current tenant or select tenant-specific connections; use `AppDbFactory` for tenant-isolated primary or analysis access. You can view the code logic in `UniversalDbFactory`, such as:

```csharp
 var contextName = typeof(TContext).Name;
 if (contextName.EndsWith("DbContext"))
 {
     contextName = contextName[..^"DbContext".Length];
 }
 var connectionStrings = configuration.GetConnectionString(contextName);
```

You can modify the implementation of `UniversalDbFactory` to meet your actual needs for creating DbContext.

> [!NOTE]
> Multi-database operations are difficult to guarantee data consistency, have high coupling, and complex business understanding. This situation should be avoided as much as possible. It is recommended to implement cross-database operations through inter-service calls or message queues to maintain eventual consistency.
