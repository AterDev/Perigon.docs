# Integration Testing

The template includes two TUnit projects: `tests/UnitTest` contains infrastructure-free unit tests, while `tests/ApiTest` contains Aspire integration tests.

The AppHost global hook runs only in `ApiTest`, so unit tests remain fast and independent.

## Running Tests

Run unit tests without starting Aspire:

```pwsh
dotnet test --project tests/UnitTest/UnitTest.csproj
```

When real databases and services are needed, run the integration project (Docker/Podman required):

```pwsh
dotnet test --project tests/ApiTest/ApiTest.csproj --treenode-filter '/*/*/*/*[Category=Integration]'
```

Integration tests use `Aspire` to launch all infrastructure and services, closely simulating a real environment.

## Writing Tests

You can leverage `AI` to generate test code. Typically, this involves making API requests and asserting response results.

The `TestHttpClientData` class contains an `HttpClient` instance for API requests. The template does not create an administrator account; when `SystemMod` is installed, set `PERIGON_TEST_ADMIN_EMAIL` and `PERIGON_TEST_ADMIN_PASSWORD` so `InitializeAsync` can obtain a token for authenticated tests.
