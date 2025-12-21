# Manager Generation

This document explains the implementation details of the Manager generation feature in the code generator.

## Generation Process

The Manager generator creates business logic classes that inherit from `ManagerBase<TDbContext, TEntity>`.

## Generated Methods

The generator creates the following standard CRUD methods:

### FilterAsync
- Implements pagination and filtering
- Uses FilterDto for search criteria
- Returns paged results of ItemDto

### AddAsync
- Creates new entity instances
- Validates input using AddDto
- Returns created entity details

### EditAsync
- Updates existing entities
- Uses UpdateDto for partial updates
- Handles null values by ignoring unchanged fields

### GetAsync
- Retrieves single entity by ID
- Returns DetailDto
- Includes permission checks

### DeleteAsync
- Soft delete or hard delete based on configuration
- Supports batch deletion
- Returns success status

### HasPermissionAsync
- Checks if current user has access to entity
- Used by other methods for authorization

### GetOwnedIdsAsync
- Returns IDs of entities owned by current user
- Used for data filtering based on ownership

## Dependencies

Generated Managers automatically inject:
- DbContext through TenantDbFactory
- ILogger for logging
- IUserContext for user information

## Customization

Developers can extend generated Managers by:
- Adding custom business methods
- Overriding base class methods
- Implementing additional validation logic
