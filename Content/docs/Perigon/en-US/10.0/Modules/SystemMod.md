# SystemMod

`Perigon.SystemMod` provides management-side identity, user and role administration, menu authorization, system configuration, logging, and data-scope configuration. It currently integrates with `AdminService` and supplies user, role, and authorization configuration for other business modules.

## Capabilities

- Email sign-in, verification codes, token refresh, sign-out, and current-user information.
- User and role administration, role-to-menu assignments, and menu management.
- System configuration, enum dictionaries, and login security settings.
- Asynchronous system-log writing and filtering.
- Data scopes, data-scope groups, and group membership management for users.

## Configure data scopes

Data access configuration is organized as **scope → group → user membership**:

1. Create a data-scope group with a name, description, and enabled state.
2. Create a data scope with a resource code (`ResourceCode`), scope type (`ScopeType`), target IDs (`TargetIds`), and its group.
3. Choose `None` (no data), `All` (all data), or `Include` (only targets in `TargetIds`). IDs for `Include` must be GUIDs.
4. Add users from the current tenant to the group. `GET /api/SysDataScopeGroup/{id}/users` returns the current members; `PUT /api/SysDataScopeGroup/{id}/users` replaces the full membership list from `UserIds`.
5. `GET /api/SysUser/userinfo` returns the user's enabled groups and their data scopes.

`SuperAdmin` manages scopes and groups. Creating, querying, and updating memberships and scopes is tenant-scoped. A group cannot be deleted while scopes or users still reference it; remove those associations first.

SystemMod stores and returns authorization configuration, but it does not rewrite queries in other modules. Each business module must apply `ResourceCode`, `ScopeType`, and `TargetIds` to its own data queries.

There is currently no dedicated data-scope-group administration page; use the APIs or generated Angular service to manage groups and members. A system-organization entity exists, but there is no corresponding management API or standalone page today.

## Logging and initialization

System logs are queued and written to the database in batches by a hosted service. The initialization service creates baseline users and configuration for each tenant. If a tenant has no users, it seeds an `admin` account with the sample password `Perigon.2026`; change this password immediately after initial deployment.

## Install and integrate

```pwsh
perigon module install Perigon.SystemMod AdminService
```

The target service must reference the module and call the template's `AddModules()` registration entry point. Apply the EF Core migrations after installation or upgrade. The migration clears legacy permission rows, which cannot be mapped to the new resource-code and target-ID model, and removes the old role-to-permission-group relation. Existing group names and descriptions are retained; reconfigure scopes and group membership after the upgrade.

See the [module CLI guide](../Code-Generation/Command-Line.md) for installation and frontend packaging options.
