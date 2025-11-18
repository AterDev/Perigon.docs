# Manager 业务处理

Manager 层是专门处理业务逻辑的地方，它被Controller 层或其他服务调用。

## Manager的作用

在简单CURD应用中，Manager主要是通过`DbContext`,`CacheService`等对象来实现数据库和缓存的操作。

典型的Manager，提供两个泛型参数，它提供了一些常用的CURD方法。

```csharp
public class CustomerInfoManager(
    DefaultDbContext dbContext,
    ILogger<CustomerInfoManager> logger)
    : ManagerBase<DefaultDbContext, CustomerInfo>(dbContext, logger){}
```

当你不需要特定实体时，可以使用其他的Manager基类，如：

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

Manager是承载业务逻辑的主要载体，你可以根据实际需求，继承不同的基类。

在编写Manager时，需要遵循以下原则：

- ❌ 不要直接返回`ActionResult`相关类型，应该返回具体的实体或DTO。
- ❌ Manager之间不要互相引用，这样会导致循环引用。
- ❌ 不要直接使用`HttpContext`，应该通过参数传递需要的信息。
- ❌ 不要直接使用`IUserContext`，应该通过参数传递需要的信息。
- ✅ 可以使用`DbContext`，`CacheService`等对象来实现数据的操作。

Manager不应该关心和处理请求上下文相关的逻辑，它应该专注于业务逻辑的实现。


## 使用ManagerBase基类方法

在ManagerBase抽象类中，提供了对实体操作的方法，如果你是继承自`ManagerBase<TDbContext,TEntity>`，可以直接使用这些方法。


| 方法              | 返回说明       | 场景                              |
| ----------------- | -------------- | --------------------------------- |
| FindAsync         | 返回第一条数据 | 根据主键查询，返回实体，会被跟踪  |
| FindAsync<TDto>   | 返回第一条数据 | 根据条件查询，不会被跟踪          |
| Exist             | bool           | 主键id                            |
| ExistAsync        | bool           | where表达式                       |
| ToListAsync<TDto> |                |                                   |
| ToPageAsync       | 分页列表       |                                   |
| UpsertAsync       |                | 添加或更新实体                    |
| BulkUpsertAsync   |                | 批量添加或更新实体                |
| DeleteAsync       |                | 根据主键删除，支持软删除,批量删除 |


## 生成Manager

当我们定义好实体后，可以通过代码生成器，自动生成Manager类，它继承自`ManagerBase<TDbContext,TEntity>`，包含了常用的CURD方法。


### AddAsync



### UpdateAsync
### AddAsync
### AddAsync
### AddAsync

