# OpenApi自定义转换器

微软官方的`OpenApi`一言难尽，如果你想使用它，本文档介绍如何自定义`OpenApi`转换器来解决一些常见问题。

> [!WARNING]
> 在现有阶段，仍然建议使用`Swashbuckle.AspNetCore`，微软官方的`OpenApi`目前仍然不够成熟，很多功能都不完善。

## 处理枚举类型

默认情况下，`OpenApi`会将枚举类型转换为整数，其字段和描述信息会丢失，我们将使用Extension来添加这些信息。

```csharp
/// <summary>
/// Transformer for Microsoft.AspNetCore.OpenApi Schema
/// </summary>
public sealed class OpenApiSchemaTransformer : IOpenApiSchemaTransformer
{
    public Task TransformAsync(
        OpenApiSchema schema,
        OpenApiSchemaTransformerContext context,
        CancellationToken cancellationToken
    )
    {
        var type = context.JsonTypeInfo.Type;
        AddEnumExtension(schema, type);
        return Task.CompletedTask;
    }

    private static void AddEnumExtension(OpenApiSchema schema, Type type)
    {
        if (!type.IsEnum)
        {
            return;
        }
        schema.Extensions ??= new Dictionary<string, IOpenApiExtension>();

        var enumItems = new List<EnumItem>();
        foreach (var field in type.GetFields(BindingFlags.Public | BindingFlags.Static))
        {
            var raw = field.GetRawConstantValue();
            if (raw is null)
            {
                continue;
            }

            var value = Convert.ToInt32(raw);
            string? description = null;
            var desAttr = field.GetCustomAttribute<DescriptionAttribute>();
            if (desAttr is not null && !string.IsNullOrWhiteSpace(desAttr.Description))
            {
                description = desAttr.Description;
            }
            enumItems.Add(new EnumItem(field.Name, value, description));
        }

        if (schema.Enum is null || schema.Enum.Count == 0)
        {
            schema.Enum = [];
            foreach (var item in enumItems)
            {
                schema.Enum.Add(JsonValue.Create(item.Value));
            }
        }
        schema.Extensions["x-enumData"] = new EnumDataExtension(enumItems);
    }

    private sealed record EnumItem(string Name, int Value, string? Description);

    /// <summary>
    /// 自定义扩展写出器
    /// </summary>
    private sealed class EnumDataExtension(IReadOnlyList<EnumItem> items) : IOpenApiExtension
    {
        public void Write(IOpenApiWriter writer, OpenApiSpecVersion specVersion)
        {
            WriteInternal(writer);
        }

        private void WriteInternal(IOpenApiWriter writer)
        {
            writer.WriteStartArray();
            foreach (var item in items)
            {
                writer.WriteStartObject();
                writer.WritePropertyName("name");
                writer.WriteValue(item.Name);
                writer.WritePropertyName("value");
                writer.WriteValue(item.Value);
                if (!string.IsNullOrWhiteSpace(item.Description))
                {
                    writer.WritePropertyName("description");
                    writer.WriteValue(item.Description);
                }
                writer.WriteEndObject();
            }
            writer.WriteEndArray();
        }
    }
}

```

## 自定义OperationId

OperationId很重要，它提供了接口的唯一标识，可用在生成客户端代码时使用。

```csharp
/// <summary>
/// Transformer for Microsoft.AspNetCore.OpenApi operations.
/// </summary>
public class OpenApiOperationTransformer : IOpenApiOperationTransformer
{
    public Task TransformAsync(
        OpenApiOperation operation,
        OpenApiOperationTransformerContext context,
        CancellationToken cancellationToken
    )
    {
        if (string.IsNullOrEmpty(operation.OperationId))
        {
            var actionDescriptor = context.Description.ActionDescriptor;

            var controller = actionDescriptor.RouteValues.TryGetValue("controller", out var c)
                ? c
                : "UnknownController";
            var action = actionDescriptor.RouteValues.TryGetValue("action", out var a)
                ? a
                : context.Description.RelativePath;

            operation.OperationId = $"{controller}_{action}";
        }
        return Task.CompletedTask;
    }
}
```

> [!TIP]
> 以上示例使用controller和action名称来生成OperationId，从编码角度，你是可以定义多个action名称相同的方法，但不建议这样做，对于接口，建议每个接口具有唯一的action名称。