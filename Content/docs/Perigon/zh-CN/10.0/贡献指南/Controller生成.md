# Controllers 的生成

## 概述

选择实体然后生成Controller，由于Controller依赖`DTO`和`Manager`，所以会先生成`DTO`和`Manager`。

生成的Controller默认继承`RestControllerBase<TManager>`，

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
> 控制器默认有一个Manager泛型，当需要多个`Manager`时，可自行注入`Manager`，然后在Controller中使用。

## 生成逻辑

controller的生成需要先获取以下信息

- 通过`DbContextParseHelper`解析指定的实体类`Entity`，最终获取`EntityInfo`对象。
- 用户选择的服务项目，判断是否引用了`SystemMod`(可配置)，以便区分是否具有管理权限。
- 前置步骤生成的`Dto`的信息，通过缓存获取
- 解决方案配置信息
  
接口的生成，主要是通过调用`Manager`的相关方法来实现。根据`RestApi`的规范，生成的接口方法包括：

- 分页查询
- 新增
- 更新
- 获取详情
- 删除

请查看`RestApiGenerate`类，了解具体的实现细节，`TplContent.cs`查看模板内容。