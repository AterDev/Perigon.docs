# Manager Generation

Manager is the main implementation component of the business logic layer. Built-in tools can generate common CRUD code here. This document explains the details of Manager generation.

**Support Methods: `Studio` and `MCP`**

## Prerequisites

- Generated based on a specific entity

## Generation Behavior

During generation, the module is identified based on the directory structure of the entity. Before generation, it is recommended to add the corresponding module first.

Manager requires DTOs, so when generating Manager, the required DTOs will be generated first.

### ManagerBase

Built-in generated Manager classes all inherit from the `ManagerBase` class to use the methods in it to implement data operations.

### Default Generated Methods

Built-in tools will generate the following common CRUD methods:

| Method Name        | Description                  |
| ------------------ | ---------------------------- |
| FilterAsync        | Filtering with pagination    |
| AddAsync           | Add entity                   |
| EditAsync          | Edit entity                  |
| GetAsync           | Get entity details           |
| DeleteAsync        | Delete entity (batch capable)|
| HasPermissionAsync | Check permission             |
| GetOwnedIdsAsync   | Get list of owned IDs        |
