# Deploying Applications

Template projects use `Aspire` for local development and service orchestration. For publishing, choose the workflow based on your target:

- Publish one service image: use the service `Dockerfile` and the publish script.
- Orchestrate multiple services, databases, caches, and dependencies: use `AppHost` and Aspire publishing/deployment features.

> [!NOTE]
> The Docker publish script is only for packaging a single service image. Use `AppHost` when you need database, cache, an EF Core migration Job, startup ordering, or environment composition.

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
- `ApiService-Migrations` (created by AppHost through `AddEFMigrations`)

The public API services are usually `ApiService` and `AdminService`. `ApiService-Migrations` is a one-shot migration resource and is not intended to be a long-running API service image. `AdminService` and `ApiService-Migrations` apply only to `ApiStandard`; `MiniApi` has only `ApiService`, uses PostgreSQL, and has no built-in EF Core migration resource.

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

`ApiStandard` service images use `mcr.microsoft.com/dotnet/aspnet:10.0-alpine-extra`; the NativeAOT `MiniApi` image uses `mcr.microsoft.com/dotnet/runtime-deps:10.0-alpine-extra`. Both preserve globalization support for non-invariant scenarios while keeping the image small.

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

The templates have different publishing strategies; one statement must not be applied to both:

- `ApiStandard` targets controllers, EF Core, authentication, and optional third-party capabilities. Keep it framework-dependent and do not enable Trim or AOT without a dedicated compatibility pass.
- `MiniApi` enables `PublishAot` and the Request Delegate Generator in `ApiService.csproj`; its Docker publishing script also explicitly sets `PublishTrimmed=true` and `PublishAot=true`.

MiniApi publishing example:

```powershell
dotnet publish src/Services/ApiService/ApiService.csproj -c Release
```

When using the MiniApi Docker publishing script, confirm the `linux-musl-x64` runtime and validate reflection, serialization, and native dependencies for AOT. See each template's quick-start guide for its limitations.

## Use AppHost for Orchestration

The single-service publish script does not handle dependencies such as:

- Database
- Cache
- EF Core migration Job
- Service startup ordering
- Connection strings
- Development environment parameters

Use `AppHost` to describe these resources. The template `AppHost` starts infrastructure resources based on configuration and passes database/cache references to services.

```pwsh
aspire start --non-interactive
```

### Generate Aspire deployment artifacts

List the publish steps, then generate artifacts for the selected target:

```pwsh
aspire publish --project .\src\AppHost\AppHost.csproj --list-steps --non-interactive
aspire publish --project .\src\AppHost\AppHost.csproj --output-path .\artifacts\aspire --non-interactive
```

The current template contains a Kubernetes environment, so the output is a Helm chart containing `Chart.yaml`, `values.yaml`, `templates/`, and the migration bundle. The migration file may still be named `deployment.yaml`; inspect its contents and verify `apiVersion: batch/v1` and `kind: Job`.

The Kubernetes Job uses `restartPolicy: OnFailure` and exits after a successful migration. The release process should verify the Job before sending traffic to the API and admin services. Images must be available from a registry reachable by the cluster. Before applying the chart, inspect image values, parameters, Secrets, and connection-string mappings in `values.yaml`.

To hand the generated chart to an existing cluster, use Helm:

```pwsh
helm upgrade --install perigon .\artifacts\aspire --namespace perigon --create-namespace
kubectl get jobs -n perigon
kubectl logs job/<migration-job-name> -n perigon
```

If Aspire should deploy directly, verify the current `kubectl` context, image registry, and namespace first:

```pwsh
aspire deploy --project .\src\AppHost\AppHost.csproj --non-interactive
```

See the official Aspire documentation: [EF Core migrations](https://aspire.dev/integrations/databases/efcore/migrations/), [Kubernetes deployment](https://aspire.dev/deployment/kubernetes/kubernetes/), and [Seed data](https://aspire.dev/integrations/databases/efcore/seed-database/).

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
