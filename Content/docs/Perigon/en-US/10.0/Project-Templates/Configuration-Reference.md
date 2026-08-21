# Template Configuration Reference

This page describes the configuration implemented by the current `ApiStandard` template. It uses the standard ASP.NET Core configuration system: JSON, environment variables, user secrets, and command-line values can be combined, and later providers override earlier values.

`MiniApi` reuses the cache, authentication, login-policy, SMTP, SMS, and S3 options. Its `ComponentOption` does not include `Database` or `IsMultiTenant`; its database is fixed to PostgreSQL and it has no built-in EF Core migration resource. The database-selection and multi-tenancy settings below apply only to `ApiStandard`.

## Configuration sources

The template has two configuration scopes:

- `src/AppHost/appsettings*.json`: read by AppHost to choose the database, cache, and multi-tenancy mode, then injected into services when Aspire starts them.
- `src/Services/ApiService` and `src/Services/AdminService` `appsettings*.json`: service-specific settings such as authentication, CORS, cache policy, and optional toolkit services.

When running through Aspire, AppHost shares the infrastructure choices with the services:

| JSON setting | Service environment variable | Purpose |
| --- | --- | --- |
| `Components:Cache` | `Components__Cache` | Selects `Memory`, `Redis`, or `Hybrid`. |
| `Components:Database` | `Components__Database` | Selects `PostgreSQL` or `SqlServer`. |
| `Components:IsMultiTenant` | `Components__IsMultiTenant` | Enables multi-tenancy. |
| Aspire database resource | `ConnectionStrings__Default` | Primary database connection. |
| Aspire Redis resource | `ConnectionStrings__Cache` | Cache connection. |

The `__` separator in an environment variable represents `:` in a configuration path:

```powershell
$env:Components__IsMultiTenant = "true"
$env:Authentication__Jwt__Sign = "replace-with-a-secret"
```

When a service is run directly, AppHost does not inject these values. Provide the same settings through the service configuration, environment, or secret store.

## Components

`Components` binds to `ComponentOption`:

| Setting | Values/type | Description |
| --- | --- | --- |
| `Cache` | `Memory`, `Redis`, `Hybrid` | Redis is required for `Redis` and `Hybrid`; AppHost creates Redis only for those modes. |
| `Database` | `PostgreSQL`, `SqlServer` | Selects the EF Core provider. The enum member is `PostgreSql`; `PostgreSQL` is the recommended JSON spelling. |
| `AuthType` | `Jwt`, `Cookie`, `OAuth` | Selects the authentication mode; default is `Jwt`. |
| `MQType` | `None`, `Nats`, `RabbitMQ`, `KafKa` | Selects the message-queue type. The current template enum uses the spelling `KafKa`; actual queue registration is supplied by modules or application code. |
| `UseCors` | Boolean | Retained CORS setting. Current `WebExtensions` always registers and uses CORS; the policy comes from `Cors` and the hosting environment, so this value is not currently a skip-CORS switch. |
| `IsMultiTenant` | Boolean | Enables tenant resolution and tenant data isolation. |
| `UseSMS` | Boolean | Registers `SMS` options and services when `true`. |
| `UseSmtp` | Boolean | Registers `Smtp` options and services when `true`. |
| `UseAWSS3` | Boolean | Registers `AWSS3` options and services when `true`. |

The current `ComponentOption` has no `Components:UseOpenAPI` property and the template does not read it. Do not use it to control OpenAPI. `ApiStandard` uses its current Swagger defaults; `MiniApi` uses ASP.NET Core OpenAPI.

## Cache

`Cache` binds to `CacheOption`; the time values are in minutes:

| Setting | Default | Description |
| --- | ---: | --- |
| `MaxPayloadBytes` | `1048576` | Maximum cache payload size in bytes. |
| `MaxKeyLength` | `1024` | Maximum cache-key length. |
| `Expiration` | `20` | Default distributed-cache expiration. |
| `LocalCacheExpiration` | `10` | Default local-cache expiration. |

## Authentication

### Jwt

The path is `Authentication:Jwt`. In production, provide `Sign` through an environment variable or secret store:

| Setting | Default | Description |
| --- | --- | --- |
| `ValidAudiences` | Required | JWT audience. |
| `ValidIssuer` | Required | JWT issuer. |
| `Sign` | Required | Signing key; do not commit a real key. |
| `ExpiredSecond` | `7200` | Access-token lifetime in seconds. |
| `RefreshExpiredSecond` | `604800` | Refresh-token lifetime in seconds. |

### OAuth

The path is `Authentication:OAuth`:

| Setting | Default | Description |
| --- | --- | --- |
| `Authority` | Empty | OAuth/OIDC authority URL. |
| `Audiences` | Empty array | Allowed audiences. |
| `RequireHttpsMetadata` | `true` | Require HTTPS metadata; disable only in Development when necessary. |
| `ValidateAudience` | `true` | Reserved audience-validation option; the built-in OAuth setup currently always enables audience validation. |
| `Sign` | Empty | Signing configuration for extension scenarios. |

`Authentication:OAuth:ClientId` appears in some examples but is not a property of the current `OAuthOption`; Microsoft and Google client settings are described below.

## LoginSecurityPolicy

The path is `LoginSecurityPolicy`:

| Setting | Default | Description |
| --- | --- | --- |
| `PasswordLevel` | `Normal` (`1`) | `Simple` (6 characters), `Normal` (8 characters with upper/lowercase and digits), or `Strict` (8 characters with upper/lowercase, digits, and symbols). |
| `IsNeedVerifyCode` | `false` | Require a verification code. |
| `PasswordExpired` | `365` | Password lifetime in months. |
| `LoginRetry` | `5` | Failed-login retry count. |
| `SessionLevel` | `None` (`0`) | `None`, `OnlyClient`, or `OnlyOne`. |
| `SessionExpiredSeconds` | `1800` | Session lifetime in seconds. |
| `IsEnable` | `false` | Enable the login security policy. |

## Optional toolkit services

These options are registered only when the corresponding `Components:Use*` flag is `true`:

| Configuration section | Key settings | Description |
| --- | --- | --- |
| `Smtp` | `Host`, `Port`, `DisplayName`, `From`, `Username`, `Password`, `EnableSsl` | SMTP email service; default port is `25`. |
| `SMS` | `AccessKeyId`, `AccessKeySecret`, `Sign` | SMS credentials and signature. |
| `AWSS3` | `Endpoint`, `AccessKeyId`, `AccessKeySecret`, `BucketName`, `Region`, `Prefix` | S3-compatible object storage. |

## Other configuration sections

These settings are read directly by the template but are not part of the custom Options above:

- `Cors:AllowedOrigins`: production allowed-origin list.
- `Cors:AllowedSubdomains`: allow wildcard subdomains.
- `Authentication:Microsoft` and `Authentication:Google`: third-party login is registered when `ClientId`, `ClientSecret`, and `CallbackUrl` are all valid.
- `ConnectionStrings:Default` and `ConnectionStrings:Cache`: use `AddConnectionString` in AppHost when an existing database or cache should be shared.
- `OTEL_EXPORTER_OTLP_ENDPOINT`: the standard OpenTelemetry exporter endpoint injected by Aspire.

## Migration environment variables

The migration script and AppHost use these variables to keep the model consistent:

- `Components__Database`: selects the database provider used by migration generation.
- `Components__IsMultiTenant`: is passed from AppHost and the migration script to the services; it does not control tenant-index generation. `TenantIndexConvention` handles entities implementing `ITenantEntityBase`.

See [EF Core migrations and seeding](../Best-Practices/Database.md) and [Deploying applications](../Tutorials/Deploying-Applications.md) for the migration and release workflows.
