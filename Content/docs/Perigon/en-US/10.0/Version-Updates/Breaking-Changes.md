# Breaking Changes

This page records changes that affect existing code behavior.

## v1.3.14 tenant resolution and default-tenant connections

- Initialization ensures that `default.com` exists and stores the default business and analysis database connection strings on it.
- Normal authenticated requests must carry a valid, non-empty `TenantId`; missing, empty-GUID, or unknown tenants are rejected instead of silently falling back to the default tenant or connection.
- `null` tenant ids are reserved for the system tenant-catalog context. A resolved tenant falls back to a corresponding default only when its connection field is empty; the analysis default uses the business default when it is not configured.

## `AnalysisDbContext` is read/write

`AnalysisDbContext` now inherits from `ContextBase` and supports both queries and saves. `AppDbFactory.CreateAnalysisDbContext(tenantId)` still selects the analysis connection and calls `SetTenantId`, so tenant filtering and save validation remain active.

When a workflow requires a strictly read-only context, derive it from `ReadonlyDbContext` and use a read-only database account or replica. Code that relies on `AnalysisDbContext.SaveChanges` always throwing must use the read-only context or remove that assumption.
