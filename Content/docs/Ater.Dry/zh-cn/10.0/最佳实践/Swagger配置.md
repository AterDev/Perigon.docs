# Swagger配置

Swagger在整个工具集成中扮演着重要角色，因为工具会根据Swagger文档生成代码生成客户端请求服务。

使用适当的包和配置，可以确保生成的Swagger文档符合预期，从而使代码生成过程顺利进行。

## 使用Swashbuckle.AspNetCore.SwaggerGen

项目模板默认使用`Swashbuckle.AspNetCore.SwaggerGen`来生成Swagger文档。并进行了符合实践的良好配置，请谨慎修改。

在`ServiceDefaults\WebExtensions.cs`中，其中`AddSwagger`扩展方法包含了所有必要的配置。

### 自定义SchemaFilter

这里使用了`SwaggerSchemaFilter`来自定义`OpenApi`的Schema生成行为，主要用于处理枚举类型和必填字段。
