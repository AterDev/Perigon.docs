# Version Features

This article mainly introduces the main features of each version.

## 10.0 / Template package 1.3.12

- Integrated `.NET Aspire` by default.
- `ApiStandard` uses `Swashbuckle` for OpenAPI JSON; `MiniApi` uses ASP.NET Core OpenAPI and exposes `/openapi/v1.json` by default.
- Uses `.slnx` as the solution file by default.
- Uses `CPM` central package management by default.

### Version compatibility matrix

| Component | Current version/requirement | Notes |
| --- | --- | --- |
| `Perigon.templates` | `1.3.12` | Template package covered by this page |
| .NET SDK | `10.0.103` or a compatible .NET 10 SDK | Both templates target `net10.0` |
| Aspire AppHost SDK | `13.4.6` | Unified across both templates |
| Aspire Hosting packages | `13.4.6` | Matches the AppHost SDK |
| `ApiStandard` | `perigon-webapi` | EF Core, MigrationService, Admin/API, multiple databases |
| `MiniApi` | `perigon-miniapi` | Minimal API, PostgreSQL, NativeAOT, no MigrationService |

The documentation line `10.0` identifies the .NET/Perigon CLI major line; `1.3.12` identifies the `Perigon.templates` package release. Update this matrix and both quick-start guides when the template package changes.
