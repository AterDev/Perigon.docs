# Manager Generation

Manager is a core component for implementing business logic. This document explains how to generate Manager classes and the implementation details of Manager generation.

## ManagerBase

All Managers must inherit from `ManagerBase`. Those that do not inherit will not be injected by the source code generator. The template provides the following ManagerBase types:

- `ManagerBase<TDbContext, TEntity>(TenantDbFactory dbContextFactory, IUserContext userContext, ILogger logger)`: Specifies database context and entity. The code generator uses this by default.
- `ManagerBase<TDbContext>(TDbContext dbContext, ILogger logger)`: Specifies database context only.
- `ManagerBase(ILogger logger)`: Does not specify database context or entity. Free to register required services.

## Generation Logic

- Parse the specified entity class `Entity` through `DbContextParseHelper` to get the `EntityInfo` object.
- Generate the Manager class:
  - Use the entity's DbContext implementation class as the generic parameter `TDbContext`
  - Use the entity's module attribute to determine the module directory for Manager generation

See the `ManagerGenerate` class for specific implementation details and `TplContent.cs` for template content.
