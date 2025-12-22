# Development Conventions and Standards

## Project Configuration

- Use `<Nullable>enable</Nullable>` configuration setting.

## Entity Model Definition

- All entity classes inherit from `EntityBase` by default, which defines common properties: `Id`, `CreatedAt`, `UpdatedAt`, and `IsDeleted`.
- The `Id` property uses `Guid` type by default, generated on the client using Guid V7.
- String properties must define maximum length, unless explicitly unlimited.
- Decimal properties must have explicit precision and scale:
  - For smaller ranges: `decimal(10, 2)` is recommended
  - For larger ranges: `decimal(18, 6)` is recommended

  ```csharp
  [Column(TypeName = "decimal(10,2)")]
  public decimal TotalPrice { get; set; }
  ```

- All enum values must have `[Description]` attribute.
- Use `DateTimeOffset` for date-time values instead of `DateTime` to preserve complete time information.
- Use `DateOnly` type for properties that are date-only.
- Use `TimeOnly` type for properties that are time-only.

## Services and Helper Classes

Helper classes typically end with "Helper" and are usually static classes, unrelated to DI.

Service classes typically end with "Service" and are implementation classes that usually need to be injected via DI.

## Business Manager

- Do not define interfaces for business implementation (Manager) classes. In reality, business logic changes frequently and usually has only one implementation. Define an interface only if you have strict business processes with multiple implementations.
- Manager inherits from `ManagerBase` class, which will be automatically injected via DI. If you don't inherit from it, you need to manually inject.

## API Requests and Responses

Follow RESTful conventions as the standard.

Controller method names are simple and consistent. For example, to add a user, use `AddAsync` instead of `AddUserAsync`:

- Add/Create: `AddAsync`
- Modify/Update: `UpdateAsync`
- Delete: `DeleteAsync`
- Get Details: `GetDetailAsync`
- Filter Query: `FilterAsync`

### Request Methods

- **GET**: Use GET to retrieve data. For complex filtering and conditional queries, you can use POST to send parameters.
- **POST**: Use POST to add data. Request body uses JSON format.
- **PUT**: Use PUT to modify data. Request body uses JSON format.
- **DELETE**: Use DELETE to delete data.

### Response Standards

Responses follow HTTP status codes:

- **200**: Execution succeeded.
- **201**: Creation succeeded.
- **401**: Not authenticated. Token not provided or expired. Must re-authenticate (login).
- **403**: Forbidden. User is logged in but lacks permission to access.
- **404**: The requested resource does not exist.
- **409**: Resource conflict.
- **500**: Server error or business error.

When a request succeeds, the frontend can directly retrieve the data.

When a request fails, a unified error format is returned:

```json
{
  "title": "",
  "status": 500,
  "detail": "Unknown error!",
  "traceId": "00-d768e1472decd92538cdf0a2120c6a31-a9d7310446ea4a3f-00"
}
```

### ASP.NET Core Request and Response Examples

1. **Route Definition**: Use HTTP verbs, not the `Route` attribute.
   See [**HTTP Verb Templates**](https://docs.microsoft.com/en-us/aspnet/core/mvc/controllers/routing?view=aspnetcore-7.0#http-verb-templates).

2. **Model Binding**: Use `[FromBody]` and `[FromRoute]` to clarify request sources.
   See [**Binding Sources**](https://docs.microsoft.com/en-us/aspnet/core/mvc/models/model-binding?view=aspnetcore-7.0#sources), for example:

   ```csharp
   // Update user information
   [HttpPut("{id}")]
   public async Task<ActionResult<TEntity?>> UpdateAsync([FromRoute] Guid id, TUpdate form)
   ```

3. **Return Type**: Use `ActionResult<T>` or specific types as return types.
   - For successful responses, return the specific type directly.
   - For error responses, use `Problem()`, for example:

   ```csharp
   // If error, use Problem to return content
   return Problem("Unknown error!", title: "Business Error");
   ```

   - For 404 responses, use `NotFound()`, for example:

   ```csharp
   // If not found, return 404
   return NotFound("Username or password does not exist");
   ```

