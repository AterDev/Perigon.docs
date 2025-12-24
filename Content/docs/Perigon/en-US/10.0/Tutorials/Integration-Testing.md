# Integration Testing

The template includes an integration test project by default, which uses the `Tunit` testing framework. It is located in the `test/ApiTest` directory.

The `ApiTest` project is primarily used to test API requests and integrated service calls.

## Running Tests

To execute integration tests, run the following command in the test project directory:

```pwsh
dotnet test
```

Integration tests will use `Aspire` to launch all infrastructure and services, closely simulating a real environment.

## Writing Tests

You can leverage `AI` to generate test code. Typically, this involves making API requests and asserting response results.

The `TestHttpClientData` class contains an `HttpClient` instance that can be used to send requests. The `InitializeAsync` method includes an example of logging in to obtain a token, which can then be used for authentication in subsequent API tests.