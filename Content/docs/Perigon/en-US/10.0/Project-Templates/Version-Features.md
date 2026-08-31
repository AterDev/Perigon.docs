# Version Features

This article mainly introduces the main features of each version.

## 10.0 / Template package 1.3.15

- Integrated `.NET Aspire` by default.
- `ApiStandard` uses `Swashbuckle` for OpenAPI JSON and exposes a `/swagger` UI in non-production environments; `MiniApi` uses ASP.NET Core OpenAPI and exposes `/openapi/v1.json` by default.
- Uses `.slnx` as the solution file by default.
- Uses `CPM` central package management by default.
- `ApiStandard` runs with multi-tenant behavior by default; initialization stores the default business and analysis database connection strings for `default.com`, and tenant resolution does not silently fall back for missing or unknown tenants.
- `ApiStandard` and `MiniApi` include iteration-based PD/PT documents, implementation progress records, and an AI delivery loop.
- `MiniApi` includes focused Minimal API and Native AOT skills for endpoint binding, JSON, trimming, dependency, and publish-evidence checks.
- Integration-test database settings follow the AppHost Testing environment, and cleanup validates the resolved test database name before deletion.

### Version compatibility matrix

| Component | Current version/requirement | Notes |
| --- | --- | --- |
| `Perigon.templates` | `1.3.15` | Template package covered by this page |
| .NET SDK | `10.0.103` or a compatible .NET 10 SDK | Both templates target `net10.0` |
| Aspire AppHost SDK | `13.5.0` | Current development version, unified across both templates |
| Aspire Hosting packages | `13.5.0` | Matches the AppHost SDK; EF Core and Kubernetes hosting packages are currently preview packages |
| `ApiStandard` | `perigon-webapi` | EF Core, Aspire migration resource, Admin/API, multiple databases |
| `MiniApi` | `perigon-miniapi` | Minimal API, PostgreSQL, NativeAOT, no built-in EF migration resource |

The documentation line `10.0` identifies the .NET/Perigon CLI major line; `1.3.15` identifies the `Perigon.templates` package release. Update this matrix and both quick-start guides when the template package changes.
