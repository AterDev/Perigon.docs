# OpenAPI Custom Converter

Microsoft’s `OpenApi` implementation is still evolving. If you choose to use it, here’s how to customize transformers to address common gaps.

> [!WARNING]
> Prefer `Swashbuckle.AspNetCore` for now. The official `OpenApi` stack is not yet as complete, and several features remain limited.

## Enum Handling

By default, enums are emitted as integers and their names/descriptions are lost. Add a custom extension with the enum metadata so clients can render useful labels.

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

`OperationId` is important for client generation and tooling because it uniquely identifies an endpoint.

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
> The sample derives `OperationId` from controller and action names. While you technically can repeat action names, avoid it—prefer globally unique operation names per endpoint.
