# Manager的生成

Manager是实现业务逻辑的核心组件，通常用于处理数据访问和业务逻辑。它们可以通过继承`ManagerBase`类来实现。

Manager是通过实体进行生成的，通过解析实体，获取相关信息，然后生成Manager类。

## ManagerBase

所有Manager都需要继承`ManagerBase`类，不继承的不会通过源代码生成器注入服务。模板提供了以下几种ManagerBase:

- `ManagerBase<TDbContext, TEntity>(TenantDbFactory dbContextFactory,IUserContext userContext, ILogger logger)`: 用于指定数据库上下文和实体，代码生成器默认使用该类作为基类。

- `ManagerBase<TDbContext>(TDbContext dbContext, ILogger logger)`：指定数据库上下文。

- `ManagerBase(ILogger logger)`，不指定数据库上下文和实体，可自由注册自己需要的服务。

## 生成逻辑

- 通过`DbContextParseHelper`解析指定的实体类`Entity`，最终获取`EntityInfo`对象。
- 生成Manager类
  - 将实体所属DbContext实现类作为泛型参数`TDbContext`
  - 实体的模模块特性，用来确定`Manager`生成时的模块目录
  

请查看`ManagerGenerate`类，了解具体的实现细节，`TplContent.cs`查看模板内容。
