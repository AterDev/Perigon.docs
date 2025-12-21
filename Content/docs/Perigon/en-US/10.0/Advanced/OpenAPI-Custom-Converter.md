# OpenAPI Custom Converter

Microsoft's official `OpenApi` is hard to describe. If you want to use it, this document introduces how to customize `OpenApi` converters to solve some common problems.

> [!WARNING]
> At the current stage, it is still recommended to use `Swashbuckle.AspNetCore`. Microsoft's official `OpenApi` is still not mature enough, and many features are not complete.

## Handling Enum Types

By default, `OpenApi` converts enum types to integers, and their field and description information will be lost. We will use Extension to add this information.

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
    /// Custom extension writer
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

## Custom OperationId

OperationId is very important. It provides a unique identifier for the API and can be used when generating client code.

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
> The above example uses controller and action names to generate OperationId. From a coding perspective, you can define multiple methods with the same action name, but this is not recommended. For APIs, it is recommended that each API has a unique action name.
