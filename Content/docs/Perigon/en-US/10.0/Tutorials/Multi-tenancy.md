# Multi-tenancy

Multi-tenancy (preview) is a common architecture, and the template includes support.

Consider two groups:

- 1000+ standard tenants: small datasets, minimal isolation, cost-sensitive.
- 10+ large tenants: very large datasets, require isolation, prioritize stability over cost.

## Tenant Configuration

In `AppHost/appsettings.Development.json`, set:

```json
  "Components": {
    "Cache": "Hybrid",
    "Database": "PostgreSQL",
    "IsMultiTenant": true
  }
```

`ApiStandard` always uses a tenant-aware data model. Even when `IsMultiTenant` is `false`, the database contains the `Tenant` catalog, business entities contain `TenantId`, and tenant query filters and save validation remain active. AppHost passes the value to services as `Components__IsMultiTenant`; it does not turn off those model rules. A single-tenant deployment initializes a default tenant.

## Implementation

The framework uses tenant-aware data access by default. In most business code, keep writing code as usual. The important runtime pieces are `IUserContext`, `TenantResolutionMiddleware`, and `AppDbFactory`.

- `UserContext` reads `tenant_id` and `tenant_type` from the current token claims and fills `IUserContext.TenantId` and `IUserContext.TenantType`.
- `TenantResolutionMiddleware` runs after authentication, queries the `Tenant` by `IUserContext.TenantId`, and caches it in memory. Requests without a valid tenant are rejected.
- `AppDbFactory` receives the tenant id when creating a DbContext. It reads tenant-specific connection strings from the cached `Tenant`; an empty tenant id or a missing cached tenant falls back to the default connection string.
- `Tenant` is the global tenant catalog root. Its inherited `TenantId` is ignored, while other tenant entities use the current tenant filter and save validation.

`Tenant.cs` defines core tenant data; extend it as needed.

Clients should include `TenantId` in tokens. Subsequent requests use the token claim `tenant_id` to resolve the tenant on the server.

### Handle TenantId at Login

Before login, the backend cannot know the tenant. On login, infer the tenant (domain, email suffix, or explicit identifier) and include `TenantId` in the returned token.

```csharp
public async Task<AccessTokenDto> LoginAsync(SystemLoginDto dto)
{
    var domain = dto.Email.Split("@").Last();
    var tenant = await _dbContext.Tenants.Where(t => t.Domain == domain).FirstOrDefaultAsync()
        ?? throw new BusinessException(Localizer.TenantNotExist);

    var user = await _dbSet
        .Where(u => u.Email == dto.Email)
        .Include(u => u.SystemRoles)
        .FirstOrDefaultAsync() ?? throw new BusinessException(Localizer.UserNotExists);

  jwtService.Claims =
  [
    new Claim(CustomClaimTypes.TenantId, tenant.Id.ToString()),
    new Claim(CustomClaimTypes.TenantType, tenant.Type.ToString())
  ];

    // Return Token
}
```

Since there is no token before login, identify the tenant from login information first, then write `tenant_id` and `tenant_type` into the returned token. Subsequent requests are resolved by `UserContext` and `TenantResolutionMiddleware`.

### TenantId Indexes

You don’t need to add `TenantId` indexes manually. The framework applies them automatically (including filtered indexes to ignore soft-deleted rows) so the data model remains consistent in both single-tenant and multi-tenant deployments.

During EF migration generation, `TenantIndexConvention` adds `TenantId` to indexes for entities implementing `ITenantEntityBase`. The migration is executed by the AppHost `AddEFMigrations` resource, and the migration script uses `AdminService` as the startup project.

## Single-tenant Deployment

Single-tenant deployment keeps the `Tenant` table and the `TenantId` column on business entities. This keeps the data structure, query filters, save validation, and authorization model consistent, and ensures that authenticated users receive a tenant id.

If you will never use multi-tenancy and want to remove it:

1. Remove `Tenants` from `ContextBase.cs`.
2. Make `EntityBase.cs` inherit `IEntityBase` instead of `ITenantEntityBase` and remove `TenantId`.
