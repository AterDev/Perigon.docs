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

The framework supports multi-tenancy out of the box. Keep writing code as usual and focus on `TenantContext` and `TenantDbFactory`.

`TenantDbFactory` injects `ITenantContext` to obtain tenant info and per-tenant connection strings.

`Tenant.cs` defines core tenant data; extend as needed.

Clients include `TenantId` in tokens; servers derive tenant identity from `TenantId` on subsequent requests.

### Handle TenantId at Login

Before login, the backend cannot know the tenant. On login, infer the tenant (domain, email suffix, or explicit identifier) and include `TenantId` in the returned token.

```csharp
public async Task<AccessTokenDto> LoginAsync(SystemLoginDto dto)
{
    var domain = dto.Email.Split("@").Last();
    var tenant = await _dbContext.Tenants.Where(t => t.Domain == domain).FirstOrDefaultAsync()
        ?? throw new BusinessException(Localizer.TenantNotExist);

    tenantContext.TenantId = tenant.Id;
    tenantContext.TenantType = tenant.Type.ToString();

    var user = await _dbSet
        .Where(u => u.Email == dto.Email)
        .Include(u => u.SystemRoles)
        .FirstOrDefaultAsync() ?? throw new BusinessException(Localizer.UserNotExists);

    // Return Token
}
```

Since there’s no token pre-login, set `TenantId` on the injected `ITenantContext` so downstream logic recognizes the correct tenant.

### TenantId Indexes

You don’t need to add `TenantId` indexes manually. The framework applies them automatically (including filtered indexes to ignore soft-deleted rows) so single-tenant and multi-tenant modes remain correct.

During EF migrations, `MigrationsModelDifferProxy` in `MigrationService` handles `TenantId` index generation.

## Without Multi-tenancy

The template is multi-tenant–compatible by default. Even with multi-tenancy disabled, it creates a `Tenant` table and `TenantId` on entities to allow a smooth future enablement.

If you will never use multi-tenancy and want to remove it:

1. Remove `Tenants` from `ContextBase.cs`.
2. Make `EntityBase.cs` inherit `IEntityBase` instead of `ITenantEntityBase` and remove `TenantId`.
