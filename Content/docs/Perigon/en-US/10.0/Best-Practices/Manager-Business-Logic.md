# Manager Business Logic

Manager is a specialized place for handling business logic. It is usually called by the service layer in Controllers.

## The Role of Manager

In regular applications, Manager mainly implements database and cache operations through objects such as `DbContext`, `CacheService`, etc.

A typical Manager provides two generic parameters, and it provides some common CRUD methods.

```csharp
public class CustomerInfoManager(
    TenantDbFactory dbContextFactory, 
    ILogger<CustomerInfoManager> logger,
    IUserContext userContext
)
    : ManagerBase<DefaultDbContext, CustomerInfo>(dbContextFactory, userContext, logger){}
```

When you don't need a specific entity, you can inherit ManagerBase without generic parameters, such as:

```csharp
public abstract class ManagerBase(ILogger logger)
{
    protected ILogger _logger = logger;
}

public abstract class ManagerBase<TDbContext>(TDbContext dbContext, ILogger logger)
    : ManagerBase(logger)
    where TDbContext : DbContext
{
    protected readonly TDbContext _dbContext = dbContext;
}
```

> [!CAUTION]
> Classes that inherit from `ManagerBase` will be automatically injected into the application (through the code generator).
> 
> If not inherited, manual injection is required.

## Manager Specifications

Manager is the main carrier of business logic. When writing Manager, you need to follow the following principles:

- ❌ Do not directly return `ActionResult` related types, should return specific entities or DTOs.
- ❌ Managers should not reference each other, which will lead to circular references.
- ❌ Do not directly use `HttpContext`, should pass required information through parameters.
- ❌ Do not directly write algorithms/data structures and other general logic, but directly call encapsulated methods.
- ✅ Use `DbContext`, `CacheService` and other objects to implement data operations.

Manager should not care about and handle logic related to the request context, it should focus on the implementation of business logic.

## Using ManagerBase Base Class Methods

In the ManagerBase abstract class, methods for entity operations are provided. If you inherit from `ManagerBase<TDbContext,TEntity>`, you can directly use these methods.


| Method                        | Return Description   | Scenario                                  |
| ----------------------------- | -------------------- | ----------------------------------------- |
| FindAsync                     | Return first data    | Query by primary key, return entity, will be tracked |
| FindAsync<TDto>               | Return first data    | Query by condition, will not be tracked  |
| ExistAsync                    | bool                 | Primary key id                            |
| ListAsync<TDto>               | List query           |                                           |
| PageListAsync<TFilter, TItem> | List query pagination| Filter, pagination                        |
| InsertAsync                   |                      | Add entity                                |
| UpdateAsync                   |                      | Update entity                             |
| BulkInsertAsync               |                      | Bulk add or update entities               |
| DeleteAsync                   |                      | Delete by primary key, support soft delete, batch delete |
| ExecuteInTransactionAsync<T>  | T                    | Transaction operation                     |
| ExecuteInTransactionAsync<T>  | T                    | Transaction operation                     |


The above methods are designed combining performance and ease of use. You can directly use them to implement most business logic. The generated Manager will depend on these methods.

When these methods do not meet your needs, you can implement business logic yourself in the Manager.

> [!NOTE]
> The add/modify/delete methods in the base class will directly execute database operations without needing `SaveChangesAsync`, because they do not go through EF Core's ChangeTracker mechanism.


## Generate Manager

After we define the entity, we can automatically generate the business Manager class through the code generator. It inherits from `ManagerBase<TDbContext,TEntity>` and contains common CRUD methods. You can add specific business logic on this basis.

## Avoid Manager Bloat

Usually a Manager operates on one entity or domain model. It should focus on the implementation of business logic. The following are best practices:

- Encapsulate third-party calls or middleware calls into independent service classes, usually placed in the `Share/Services` directory for reuse in other Managers.
- Put data conversion and data format processing in the model class, or provide static helper classes.
- Encapsulate algorithms or calculation logic into independent classes for testing and reuse.

Manager is more like a place to execute business flows, calling various tools or services to get relevant content and finally returning results.

## Manager Business Exception Handling

Sometimes we need to throw business exceptions in Manager so that they can be caught in the Controller and returned to the client.

The template provides the `BusinessException` class. You can throw this exception in Manager, such as:

```csharp
if (user == null)
{
    throw new BusinessException(Localizer.UserNotFound);
}
```

`GlobalExceptionMiddleware` will catch this exception and return the multi-language content to the client.
