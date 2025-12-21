# Multi-tenancy

Multi-tenancy (preview) is one of the common system architectures, and the template provides certain support for this.

Consider the following scenarios:

I have 1000+ regular tenants, each tenant does not have a large amount of data, no strong resource isolation, and are cost-sensitive customers;

I have 10+ large customer tenants, each tenant has a very large amount of data and has resource isolation needs, with stability as the primary goal, and cost is not sensitive;

## Enabling Multi-tenancy

In `appsettings.Development.json` under `AppHost`, there is the following configuration item:

```json
  "Components": {
    // memory/redis/hybrid
    "Cache": "Hybrid",
    // SqlServer/PostgreSQL
    "Database": "PostgreSQL",
    // enable multi-tenant features
    "IsMultiTenant": false
  }
```

Where `IsMultiTenant` indicates whether to enable multi-tenant functionality. Change it to `true` to enable multi-tenant functionality.

## Implementing Multi-tenancy

The framework supports multi-tenancy by default, and you don't need to do much extra work. You can write code as usual.

What you need to focus on is `TenantContext` and `TenantDbFactory`.


In `TenantDbFactory`, `ITenantContext` is injected, and you can use it to get tenant information and independent tenant database connection strings.

The `Tenant.cs` entity contains basic tenant information, which you can extend as needed.

When the client gets a Token, `TenantId` information will be included. The server will identify the tenant based on `TenantId` in subsequent requests.

### Handling TenantId During Login

Before the user logs in, the backend cannot identify the tenant and needs to handle it during login. You can identify the tenant based on the domain name of the request source, the email suffix during login, or the tenant identifier passed during login, and include the corresponding `TenantId` in the Token returned to the client.

The following is sample code for handling `TenantId` when logging in with email:

```csharp
// SystemUserManager.cs
public async Task<AccessTokenDto> LoginAsync(SystemLoginDto dto)
{
    var domain = dto.Email.Split("@").Last();
    var tenant =
        await _dbContext.Tenants.Where(t => t.Domain == domain).FirstOrDefaultAsync()
        ?? throw new BusinessException(Localizer.TenantNotExist);

    tenantContext.TenantId = tenant.Id;
    tenantContext.TenantType = tenant.Type.ToString();

    // Query user
    var user = await _dbSet
        .Where(u => u.Email == dto.Email)
        .Include(u => u.SystemRoles)
        .FirstOrDefaultAsync() ?? throw new BusinessException(Localizer.UserNotExists);

    // Return Token
}
```

Where `tenantContext` is an `ITenantContext` instance obtained through dependency injection. Since there is no Token during login, you need to manually set `TenantId` so that the tenant can be correctly identified in subsequent logic.


### Configuring TenantId Index

You don't need to manually add a `TenantId` index to each entity model, the framework will handle it automatically for you. This ensures data correctness and isolation in both single-tenant and multi-tenant modes.

When generating migration code through EF Core, it will go through the `MigrationsModelDifferProxy` logic under `MigrationService`, which will automatically handle the `TenantId` index.


## Not Using Multi-tenancy

The template is designed to be compatible with multi-tenancy by default. Even if multi-tenant functionality is not enabled, the `Tenant` table will still be created, and entities will also include the `TenantId` property to enable a smooth transition when multi-tenant functionality is enabled in the future.

If you are sure not to use multi-tenancy and don't want to create the `Tenant` table and `TenantId` property, you can remove them in the following ways:

1. Delete the `Tenants` DbSet property in `ContextBase.cs`;
2. Modify `EntityBase.cs` to inherit from `IEntityBase` instead of `ITenantEntityBase`, and delete the `TenantId` property;
