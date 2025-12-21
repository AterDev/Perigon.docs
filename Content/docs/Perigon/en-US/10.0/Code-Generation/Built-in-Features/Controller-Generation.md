# Controller Generation

Provides generation support for API Controllers that conform to the framework design.

**Support Methods: `Studio` and `MCP`**

## Prerequisites

- Generated based on a specific entity
- Need to select at least one service project to determine the generation location

## Generation Behavior

- Controller itself depends on Manager and DTO, so when generating Controller, the required DTOs and Managers will be generated first.
- The generated controller inherits from `RestControllerBase`.
- Controller subdirectories will be added according to the module the entity belongs to.

### Default Generated Methods

Built-in tools will generate the following common CRUD methods:


| Method Name | Description              |
| ----------- | ------------------------ |
| ListAsync   | Filtering with pagination|
| AddAsync    | Add entity               |
| UpdateAsync | Edit entity              |
| DetailAsync | Get entity details       |
| DeleteAsync | Delete entity            |
