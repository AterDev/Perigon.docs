# Data Access

Database is the foundation and core of application service development. The template uses `Entity Framework Core` as the ORM framework for data access, and uses `BulkExtensions` to optimize the performance of large-scale data operations.

Using `Entity Framework Core` is not only for convenience, but more importantly to standardize the way of data development and access.

It is recommended to use the `Code First` approach to define data models, and then use `DbContext` to access the database.

## Database Context

The template uses `DefaultDbContext` as the data access context by default, which inherits from `ContextBase.cs`.

You can define your own `DbContext` and inherit from `ContextBase`. Database contexts are centralized in the `Definition/EntityFrameworkCore/AppDbContext` directory.

To be compatible with multi-tenant scenarios, `TenantDbFactory` will be used by default to create database context instances. If your application does not need multi-tenant support, you can directly inject `DefaultDbContext`.


## Data Operations

Data queries are an important part of business logic. Business code is usually implemented in `XXXManager`, which inherits from `ManagerBase<TDbContext,TEntity>`, such as:

```csharp
public class AIAgentManager(
    TenantDbFactory dbContextFactory, 
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

The template will use `TenantDbFactory` by default to create database context instances to support multi-tenant scenarios. It will obtain current tenant information through `ITenantContext`, and then create the corresponding database context.

> [!TIP]
> You can modify the logic of creating database context in `TenantDbFactory` according to actual needs.

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

`UniversalDbFactory` will obtain the corresponding connection string according to your database context name by default, and create the corresponding `DbContext` instance. You can view the code logic in `UniversalDbFactory`, such as:

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
