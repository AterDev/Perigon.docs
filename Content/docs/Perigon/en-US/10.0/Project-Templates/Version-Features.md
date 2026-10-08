# Version Features

This article mainly introduces the main features of each version.

## 10.0 / Template package 1.3.17

- Integrated `.NET Aspire` by default.
- `ApiStandard` uses `Swashbuckle` for OpenAPI JSON and exposes a `/swagger` UI in non-production environments; `MiniApi` uses ASP.NET Core OpenAPI and exposes `/openapi/v1.json` by default.
- Uses `.slnx` as the solution file by default.
- Uses `CPM` central package management by default.
- `ApiStandard` runs with multi-tenant behavior by default; initialization stores the default business and analysis database connection strings for `default.com`, and tenant resolution does not silently fall back for missing or unknown tenants.
- `ApiStandard` and `MiniApi` include iteration-based PD/PT documents, implementation progress records, and an AI delivery loop.
- `MiniApi` includes focused Minimal API and Native AOT skills for endpoint binding, JSON, trimming, dependency, and publish-evidence checks.
- Integration-test database settings follow the AppHost Testing environment, and cleanup validates the resolved test database name before deletion.
- Both templates use a unified source generator with automatic Minimal API endpoint-group registration; MiniApi adds Native AOT JSON metadata.
- `IUserContext.RoleIds` in both templates reads valid, unique role IDs from `role_id` GUID claims.
- ApiStandard returns HTTP 400 for invalid MVC model state with JSON fields `title`, `detail`, `status`, and `traceId`.
- ApiStandard partial updates ignore `Id`, `TenantId`, and `CreatedTime`; bulk inserts enumerate their input once; both templates fix nested `Between` queries.
- The built-in image captcha helper and ImageSharp dependency are removed; projects that call the old helper must migrate.
- ApiStandard upgrades its Aspire AppHost/hosting packages to 13.6.1 and refreshes its .NET 10, EF Core, authentication, OpenTelemetry, testing, and third-party dependencies; EF Core Design no longer flows to downstream projects.
- This release updates ApiStandard only. MiniApi remains on Aspire 13.5.0 and its existing dependency baseline.

### Version compatibility matrix

| Component | Current version/requirement | Notes |
| --- | --- | --- |
| `Perigon.templates` | `1.3.17` | Template package covered by this page |
| .NET SDK | `10.0.103` or a compatible .NET 10 SDK | Both templates target `net10.0` |
| Aspire AppHost SDK | ApiStandard `13.6.1`; MiniApi `13.5.0` | Install the Aspire CLI matching the selected template |
| Aspire Hosting packages | ApiStandard `13.6.1`; MiniApi `13.5.0` | ApiStandard EF Core and Kubernetes hosting packages use `13.6.1-preview.1.26506.6` |
| `ApiStandard` | `perigon-webapi` | EF Core, Aspire migration resource, Admin/API, multiple databases |
| `MiniApi` | `perigon-miniapi` | Minimal API, PostgreSQL, NativeAOT, no built-in EF migration resource |

The documentation line `10.0` identifies the .NET/Perigon CLI major line; `1.3.17` identifies the `Perigon.templates` package release. Update this matrix and both quick-start guides when the template package changes.
