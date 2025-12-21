# Controller APIs

MVC Controller is still our recommended structure. It is universal, flexible, and stable, but currently does not support AOT.

## The Role of Controllers

The following are things that controllers should do:

- **Route Matching**: Define routing rules, match request paths.
- **Validate Requests**: Verify whether request parameters are legal and meet expectations.
- **Permission Handling**: Check whether users have permission to access related data.
- **Response Return**: Return appropriate response codes and error messages when validation fails.
- **Call Services**: Call `Manager` to handle business logic.
- **Handle Return Results**: Convert results returned by services into appropriate response formats.
- **API Exception Handling**: Catch exceptions and return appropriate error responses.
- **Multi-language Support**: Return content in the corresponding language according to the language preference in the request header.

The following content should not appear in controllers:

- Directly use `DbContext` to access the database.
- Directly implement business logic.
- Directly implement algorithms or data processing.

In one sentence, except for what should be done, everything else is not recommended to be implemented directly in the controller. Because in complex scenarios, the controller itself needs to handle many things.

> [!NOTE]
> Controller APIs should express as much as possible only content related to API contracts. Business implementation should be implemented by calling `Manager`, which can keep the code clean and maintainable.
> 
> This is not a mandatory requirement, but it is recommended to follow this principle.

## General Recommended Practices

- ✅Use HTTP verbs (GET, POST, PUT, DELETE, etc.) to clearly define routes.
- ✅Directly use model classes or `ActionResult<T>` as API return content, do not customize wrapper classes.
- ✅Use the `Problem()` method in controllers to return error responses.
- ✅Use `BusinessException` exceptions in Manager to throw error messages.

Both `Problem` and `BusinessException` support custom error codes.

## Common "Wrong" Methods


- ❌Customize wrapper return types, such as `ApiResponse<T>`
- ❌All APIs return 200.

> [!NOTE]
> Directly using standard HTTP status codes can maximize compatibility with various clients and avoid unnecessary troubles. It does not conflict with custom business status codes. Business status codes can be implemented through `Problem` and `BusinessException`, which ultimately return `ErrorResult` structure content.
