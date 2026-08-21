# Breaking Changes

This page records changes that affect existing code behavior.

## `AnalysisDbContext` is read/write

`AnalysisDbContext` now inherits from `ContextBase` and supports both queries and saves. `AppDbFactory.CreateAnalysisDbContext(tenantId)` still selects the analysis connection and calls `SetTenantId`, so tenant filtering and save validation remain active.

When a workflow requires a strictly read-only context, derive it from `ReadonlyDbContext` and use a read-only database account or replica. Code that relies on `AnalysisDbContext.SaveChanges` always throwing must use the read-only context or remove that assumption.
