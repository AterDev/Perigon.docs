# Controller Generation

This document explains the implementation details of Controller generation.

## Overview

When selecting an entity to generate a Controller, since Controller depends on `DTO` and `Manager`, both `DTO` and `Manager` are generated first.

Generated Controllers inherit from `RestControllerBase<TManager>`:

```csharp
[ApiExplorerSettings(GroupName = "v1")]
[Authorize(Policy = WebConst.User)]
public class RestControllerBase<TManager>(
    Localizer localizer,
    TManager manager,
    IUserContext user,
    ILogger logger
) : RestControllerBase(localizer)
    where TManager : class
{
    protected readonly TManager _manager = manager;
    protected readonly ILogger _logger = logger;
    protected readonly IUserContext _user = user;
}
```

> [!TIP]
> Controllers have one Manager generic parameter. When multiple `Manager` instances are needed, you can inject additional managers directly and use them in the Controller.

## Generation Logic

Controller generation requires the following information:

- Parse the specified entity class `Entity` through `DbContextParseHelper` to get the `EntityInfo` object.
- The service project selected by the user to determine the generation location.
- Check if `SystemMod` is referenced (configurable) to determine management permissions.
- DTO information from the previous generation step, obtained through cache.
- Solution configuration information.

Interface generation primarily calls related methods of `Manager` according to REST API specifications. Generated interface methods include:

- Pagination and filtering
- Create
- Update
- Get details
- Delete

See the `RestApiGenerate` class for specific implementation details and `TplContent.cs` for template content.
