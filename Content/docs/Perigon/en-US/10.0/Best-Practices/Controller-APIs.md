# Controller APIs

MVC Controller is still our recommended structure. It is universal, flexible, stable, but currently does not support AOT.

## The Role of Controllers

Controllers should handle the following responsibilities:

- **Route Matching**: Define routing rules and match request paths.
- **Request Validation**: Verify that request parameters are valid and meet expectations.
- **Permission Handling**: Check if users have permission to access related data.
- **Response Return**: Return appropriate HTTP status codes and error messages when validation fails.
- **Call Services**: Call `Manager` to handle business logic.
- **Handle Return Results**: Convert service results into appropriate response formats.
- **Exception Handling**: Catch exceptions and return appropriate error responses.
- **Multi-language Support**: Return content in the appropriate language based on request headers.

Controllers should NOT directly:

- Use `DbContext` to access the database.
- Implement business logic.
- Implement algorithms or data processing.

In essence, controllers should do only what they're designed for. Anything else should not be implemented directly in the controller, as controllers already handle many concerns in complex scenarios.

> [!NOTE]
> Controller APIs should express only API contract-related content. Business implementation should be delegated to `Manager`, maintaining clean and maintainable code.
> 
> This is a recommended practice, not a hard requirement.

## General Recommended Practices

- ✅ Use HTTP verbs (GET, POST, PUT, DELETE, etc.) to clearly define routes.
- ✅ Return model classes or `ActionResult<T>` directly; do not use custom wrapper classes.
- ✅ Use `Problem()` in controllers to return error responses.
- ✅ Use `BusinessException` in Manager to throw business errors.

Both `Problem` and `BusinessException` support custom error codes.

## Common Anti-patterns

- ❌ Custom wrapper return types like `ApiResponse<T>`
- ❌ Returning 200 for all API responses

> [!NOTE]
> Using standard HTTP status codes maximizes compatibility with various clients and avoids unnecessary complications. This does not conflict with custom business status codes, which can be implemented through `Problem` and `BusinessException`, ultimately returning an `ErrorResult` structure.
