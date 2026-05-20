# FAQ

This document collects common questions and solutions when using Perigon.CLI. If you encounter other issues, please use the [GitHub Discussions](https://github.com/AterDev/Perigon/discussions) so we can continue improving this guide.

## ARM Chips Not Supported

Some Apple computers use ARM chips; Perigon.CLI does not currently support ARM.

## OpenAPI Issues

Microsoft’s official OpenAPI packages are still maturing, even after two major iterations. Note that describing OpenAPI with JSON Schema has inherent limitations.

### The depth of the generated JSON schema exceeds the JsonSerializerOptions.MaxDepth setting

This usually stems from entity circular references. It does not honor your `JsonOptions` and exposes no configuration to adjust the limit. This is common, and the official OpenAPI library doesn’t yet provide an ideal solution. For example, `User` may have navigation properties that in turn reference `User`, causing this error. See the related [GitHub issue](https://github.com/dotnet/aspnetcore/issues/58943).

Recommended mitigations:

1. Recommended: return DTOs instead of raw entities.
2. Not recommended: use `[JsonIgnore]` on navigation properties to break cycles at serialization time.
3. Wait for an upstream fix.

> [!TIP]
> Prefer returning DTOs rather than entities.

### XML Comments Support

.NET 10 added XML comment support with some constraints:

1. You must call `services.AddOpenApi` in each Web API project (uses a source generator). You cannot centralize this setup in a separate assembly.
2. Reference OpenAPI packages directly from each Web API project; otherwise generation may fail or miss comments.

### Incorrect Client Generation

Clients are generated from the OpenAPI document. If the document is incorrect, the generated clients will be too.

Suggested actions:

1. Open an issue upstream and track for fixes.

> [!IMPORTANT]
> The template uses `Swashbuckle.AspNetCore` for OpenAPI and includes extensions to improve document quality and better support code generators.

## Without Aspire

If you only have a couple of services and already have infrastructure, you can skip Aspire. Adjust as follows:

- Remove the AppHost project.
- Remove the ServiceDefaults project.
- Remove `MigrationService` and manage EF migrations traditionally.
- Remove ServiceDefaults dependencies from services.
- Configure connection strings and other settings per standard ASP.NET Core guidance.
