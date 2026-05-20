# Deploying Applications

Template projects use `Aspire` for local development and service orchestration. For publishing, choose the workflow based on your target:

- Publish one service image: use the service `Dockerfile` and the publish script.
- Orchestrate multiple services, databases, caches, and dependencies: use `AppHost` and Aspire publishing/deployment features.

> [!NOTE]
> The Docker publish script is only for packaging a single service image. Use `AppHost` when you need database, cache, migration service, startup ordering, or environment composition.

## Prerequisites

Make sure the following tools are installed:

- .NET SDK
- Docker or a compatible container runtime

From the solution root, verify the project builds:

```pwsh
dotnet build -c Release
```

Backend services are usually located under `src/Services`, for example:

- `ApiService`
- `AdminService`
- `MigrationService`

The public API services are usually `ApiService` and `AdminService`. `MigrationService` is used for database migrations and is not intended to be a long-running API service image.

## Publish a Single Service Image

The template provides `scripts/PublishDocker.ps1` to publish one service and build an image from the matching `Dockerfile`.

Script parameters:

| Parameter | Description |
| --- | --- |
| `Service` | Service and assembly name, such as `ApiService` or `AdminService`. |
| `ImageName` | Image name, such as `myprojectname-api-service`. |
| `Tag` | Image tag. Optional, defaults to `latest`. |
| `Configuration` | Publish configuration. Optional, defaults to `Release`. |
| `InstallFonts` | Installs common fonts. Fonts are not installed by default. |
| `CjkFontPackage` | CJK font package. Use `font-wqy-zenhei` or `font-noto-cjk`. |
| `NoRestore` | Skips restore. Use only after a runtime-specific restore already exists. |

Publish `ApiService`:

```pwsh
.\scripts\PublishDocker.ps1 -Service ApiService -ImageName myprojectname-api-service
```

Publish `AdminService` with a custom tag:

```pwsh
.\scripts\PublishDocker.ps1 -Service AdminService -ImageName myprojectname-admin-service -Tag v1
```

The script will:

1. Run `dotnet publish` for the selected service.
2. Write publish output to `artifacts/publish/<Service>`.
3. Build the image using the service `Dockerfile`.
4. Print the image size.
5. Remove the publish output directory after the build completes.

> [!TIP]
> `NoRestore` is not recommended by default. If the assets file does not contain the target runtime, publish will fail.

## Fonts and Globalization

Service images use `mcr.microsoft.com/dotnet/aspnet:10.0-alpine-extra` by default. This keeps the image small while preserving globalization support for non-invariant scenarios.

Fonts are not installed by default. This is best for pure API services.

Install fonts only when the service renders text on the server, such as image generation, report export, verification codes, PDF generation, or SkiaSharp drawing:

```pwsh
.\scripts\PublishDocker.ps1 -Service AdminService -ImageName myprojectname-admin-service -InstallFonts
```

The default font set includes:

- `fontconfig`
- `font-dejavu`
- `font-noto-emoji`
- `font-wqy-zenhei`

For broader CJK coverage, use `font-noto-cjk`:

```pwsh
.\scripts\PublishDocker.ps1 -Service AdminService -ImageName myprojectname-admin-service -InstallFonts -CjkFontPackage font-noto-cjk
```

> [!NOTE]
> Fonts noticeably increase image size. Install them only when the service needs server-side text rendering.

## Trim and AOT

The template does not enable `PublishTrimmed` or `PublishAot` by default.

Template projects commonly include:

- ASP.NET Core controllers and OpenAPI
- System.Text.Json serialization
- EF Core runtime models
- Mapster object mapping and query projection
- Resource files and localization
- Authentication and third-party login
- Optional toolkit capabilities such as SkiaSharp, MiniExcel, MailKit, and S3

Several of these features depend on runtime metadata, expression trees, reflection, or native assets. Enabling Trim or AOT without additional work can remove required members or break runtime behavior.

The recommended publishing strategy is:

- Use framework-dependent publishing.
- Use Alpine runtime images to reduce size.
- Do not generate an apphost executable.
- Do not include debug symbols in Release publish output.
- Limit Docker build context to publish output.

For further size reduction, prefer splitting optional dependencies into separate modules or packages before enabling Trim or AOT.

## Use AppHost for Orchestration

The single-service publish script does not handle dependencies such as:

- Database
- Cache
- Migration service
- Service startup ordering
- Connection strings
- Development environment parameters

Use `AppHost` to describe these resources. The template `AppHost` starts infrastructure resources based on configuration and passes database/cache references to services.

Run `AppHost` locally:

```pwsh
dotnet run --project .\src\AppHost\AppHost.csproj
```

Or use Aspire CLI:

```pwsh
aspire run
```

Aspire can describe container images, Dockerfiles, build arguments, and publish workflows in the application model. Use it when you need to publish or deploy multiple resources together.

> [!IMPORTANT]
> If documentation, scripts, and `AppHost` differ, the current project code is the source of truth.

## Recommendations

- Use one image per service.
- Use lowercase image names with hyphens.
- Let the publish script package one service only; use `AppHost` for orchestration.
- Do not store secrets in images. Inject them through environment variables, secret stores, or the deployment platform.
- Install fonts only when server-side text rendering is required.
- Prefer the `Release` configuration.
- After building an image, check image size and startup logs.

Check local image size:

```pwsh
docker images myprojectname-api-service
```

Run the image:

```pwsh
docker run --rm -p 8080:8080 myprojectname-api-service:latest
```

If the service depends on a database or cache, provide connection strings and environment variables through your deployment platform or `AppHost`.