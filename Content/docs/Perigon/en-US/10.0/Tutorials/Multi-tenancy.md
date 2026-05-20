# Multi-tenancy

Multi-tenancy (preview) is a common architecture, and the template includes support.

Consider two groups:

- 1000+ standard tenants: small datasets, minimal isolation, cost-sensitive.
- 10+ large tenants: very large datasets, require isolation, prioritize stability over cost.

## Enable Multi-tenancy

In `AppHost/appsettings.Development.json`, set:

```json
  "Components": {
    "Cache": "Hybrid",
    "Database": "PostgreSQL",
    "IsMultiTenant": true
  }
```

`IsMultiTenant` toggles multi-tenant features.

## Implementation

The framework is multi-tenant compatible by default. In most business code, keep writing code as usual. The important runtime pieces are `IUserContext`, `TenantResolutionMiddleware`, and `TenantDbFactory`.

- `UserContext` reads `tenant_id` and `tenant_type` from the current token claims and fills `IUserContext.TenantId` and `IUserContext.TenantType`.
- When multi-tenancy is enabled, `TenantResolutionMiddleware` runs after authentication, queries the `Tenant` by `IUserContext.TenantId`, and caches it in memory.
- `TenantDbFactory` receives the tenant id when creating a DbContext. It reads tenant-specific connection strings from the cached `Tenant`; if multi-tenancy is disabled, the tenant id is empty, or no tenant is cached, it falls back to the default connection string.

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

You don’t need to add `TenantId` indexes manually. The framework applies them automatically (including filtered indexes to ignore soft-deleted rows) so single-tenant and multi-tenant modes remain correct.

During EF migrations, `MigrationsModelDifferProxy` in `MigrationService` handles `TenantId` index generation.

## Without Multi-tenancy

The template is multi-tenant–compatible by default. Even with multi-tenancy disabled, it creates a `Tenant` table and `TenantId` on entities to allow a smooth future enablement.

If you will never use multi-tenancy and want to remove it:

1. Remove `Tenants` from `ContextBase.cs`.
2. Make `EntityBase.cs` inherit `IEntityBase` instead of `ITenantEntityBase` and remove `TenantId`.
