# Manager 业务处理

Manager是专门处理业务逻辑的地方，它通常被服务层在Controller中调用。

## Manager的作用

在常规的应用中，Manager主要是通过`DbContext`,`CacheService`等对象来实现数据库和缓存的操作。

典型的Manager，提供两个泛型参数，它提供了一些常用的CURD方法。

```csharp
public class CustomerInfoManager(
    TenantDbFactory dbContextFactory, 
    ILogger<CustomerInfoManager> logger,
    IUserContext userContext
)
    : ManagerBase<DefaultDbContext, CustomerInfo>(dbContextFactory, userContext, logger){}
```

当你不需要特定实体时，可继承不带泛型参数的ManagerBase，如：

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
> 继承`ManagerBase`的类，会被自动注入到应用(通过代码生成器)。
> 
> 如果不继承，需要自己手动注入。

## Manager规范

Manager是承载业务逻辑的主要载体，在编写Manager时，需要遵循以下原则：

- ❌ 不要直接返回`ActionResult`相关类型，应该返回具体的实体或DTO。
- ❌ Manager之间不要互相引用，这样会导致循环引用。
- ❌ 不要直接使用`HttpContext`，应该通过参数传递需要的信息。
- ❌ 不要直接编写算法/数据结构等通用逻辑，而是直接调用封装好的方法。
- ✅ 使用`DbContext`，`CacheService`等对象来实现数据的操作。

Manager不应该关心和处理请求上下文相关的逻辑，它应该专注于业务逻辑的实现。

## 使用ManagerBase基类方法

在ManagerBase抽象类中，提供了对实体操作的方法，如果你是继承自`ManagerBase<TDbContext,TEntity>`，可以直接使用这些方法。


| 方法                          | 返回说明       | 场景                              |
| ----------------------------- | -------------- | --------------------------------- |
| FindAsync                     | 返回第一条数据 | 根据主键查询，返回实体，会被跟踪  |
| FindAsync<TDto>               | 返回第一条数据 | 根据条件查询，不会被跟踪          |
| ExistAsync                    | bool           | 主键id                            |
| ListAsync<TDto>               | 列表查询       |                                   |
| PageListAsync<TFilter, TItem> | 列表查询分页   | 筛选，分页                        |
| InsertAsync                   |                | 添加实体                          |
| UpdateAsync                   |                | 更新实体                          |
| BulkInsertAsync               |                | 批量添加或更新实体                |
| DeleteAsync                   |                | 根据主键删除，支持软删除,批量删除 |
| ExecuteInTransactionAsync<T>  | T              | 事务操作                          |
| ExecuteInTransactionAsync<T>  | T              | 事务操作                          |


以上方法是是结合性能和易用性设计的，你可以直接使用它们来实现大部分的业务逻辑，代码生成的Manager会依赖这些方法。

当这些方法不符合你的需求时，可在Manager中自行实现业务逻辑。

> [!NOTE]
> 基类中添加/修改/删除方法，会直接执行数据库操作，不需要`SaveChangesAsync`,因为不走EF Core的ChangeTracker机制。


## 生成Manager

当我们定义好实体后，可以通过代码生成器，自动生成业务Manager类，它继承自`ManagerBase<TDbContext,TEntity>`，包含了常用的CURD方法，你可以在此基础上，添加特定的业务逻辑。

## 避免Manager过度膨胀

通常一个Manager是对一个实体或领域模型进行操作的，它应该专注于业务逻辑的实现，以下是最佳实践：

- 将第三方调用或中间件调用封装到独立的服务类中，通常放到`Share/Services`目录下，以便在其他Manager中复用。
- 将数据转换，数据格式处理等放到模型类中，或者提供静态的辅助类。
- 将算法或计算逻辑封装到独立的类中，以便测试和复用。

Manager更像是执行业务流的地方，调用各种工具或服务获取相关内容，最终返回结果。

## Manager业务异常处理

有时候，我们需要在Manager中抛出业务异常，以便在Controller中捕获并返回给客户端。

模板提供了`BusinessException`类，你可以在Manager中抛出该异常，如：

```csharp
if (user == null)
{
    throw new BusinessException(Localizer.UserNotFound);
}
```

`GlobalExceptionMiddleware`会捕获该异常，并将多语言内容返回给客户端。