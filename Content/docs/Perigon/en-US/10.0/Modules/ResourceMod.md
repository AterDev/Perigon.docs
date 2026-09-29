# ResourceMod

`Perigon.ResourceMod` manages tenant-scoped resources with categories and configurable properties. It suits catalogs of assets, services, environments, and other records that need structured fields, role-based access, or user-submitted review.

## Resource configuration

Resources use configuration records and resource instances:

- **Environments**, such as Development, Test, and Production.
- **Categories**, which every resource must belong to.
- **Groups and tags**: groups belong to a category; resources can optionally use a group and tags.
- **Resource definitions**, which describe the dynamic properties of a resource type.
- **Dynamic properties**, supporting strings, numbers, booleans, dates, URIs, and IP addresses, with required and length constraints.
- **Resource instances**, associated with an environment, category, definition, and property values. Property-name and type snapshots help read existing values after a definition changes.

The initialization service creates Development, Test, and Production environments, common operating-system tags, and a Default category for each tenant. When no resource definitions exist, it also creates example Website, Server, and Database definitions with shared properties.

## Manage resources and access

Administrators can create, edit, delete, and filter resources, and maintain their configuration. When saving a resource, the service checks tenant ownership, verifies that a group belongs to the selected category, and validates dynamic values against the definition, including required properties. Configuration records that are still referenced cannot be deleted.

Resource read access is configured by **role + environment + category**. Administrators can read all resources in the current tenant; other users can read resources in environments and categories granted to their roles. ResourceMod has its own resource-permission relation and does not automatically apply SystemMod data scopes.

Main endpoint groups:

- `/api/Resource`: resource lists, details, and CRUD.
- `/api/ResourceConfiguration`: environments, categories, groups, tags, property definitions, resource definitions, and resource permissions.

## Personal-resource review and favorites

Users can submit a personal resource as private or request public access:

1. Private resources are visible only to their owner and need no review.
2. Public requests enter the administrator review queue.
3. When approved, an administrator supplies the environment, category, group, and tags. The service creates a regular resource and links it to the original request. Administrators can also reject a request with a review comment.

Personal-resource endpoints are under `/api/UserResource` and include `mine`, `review`, detail, CRUD, `approve`, and `reject`. An approved request can no longer be edited or deleted.

Users can also favorite regular resources they can currently access. Favorite endpoints are under `/api/UserFavoriteResource`. Private personal resources and pending requests cannot be favorited, and duplicate favorites are rejected.

## Pages and dependencies

Administration pages cover resource lists, configuration, definitions, personal resources, and public-request review. The module integrates with `AdminService`; role options come from SystemMod's role API. ResourceMod does not manage roles or provide a separate ApiService.

## Install and integrate

```pwsh
perigon module install Perigon.ResourceMod AdminService
```

Register the module through the target service's `AddModules()` entry point and apply its database migrations. To use the Angular pages, add the frontend module and menus to the target application. See the [module CLI guide](../Code-Generation/Command-Line.md) for frontend packaging and restore options.
