# Controller Generation

This document explains the implementation details of the Controller generation feature in the code generator.

## Generation Process

The Controller generator creates API controllers that inherit from `RestControllerBase` and follow RESTful conventions.

## Generated Endpoints

The generator creates the following standard API endpoints:

### GET - List/Filter
- Route: `GET /api/[controller]`
- Uses FilterDto for query parameters
- Returns paginated list of ItemDto
- Implements sorting and filtering

### POST - Create
- Route: `POST /api/[controller]`
- Accepts AddDto in request body
- Returns 201 Created with DetailDto
- Includes Location header

### PUT - Update
- Route: `PUT /api/[controller]/{id}`
- Accepts UpdateDto in request body
- Returns 200 OK with updated DetailDto
- Validates entity exists

### GET - Detail
- Route: `GET /api/[controller]/{id}`
- Returns DetailDto for specified ID
- Returns 404 if not found

### DELETE - Remove
- Route: `DELETE /api/[controller]/{id}`
- Supports batch deletion with multiple IDs
- Returns 204 No Content on success
- Implements soft delete by default

## Features

Generated controllers include:
- Automatic dependency injection of Manager
- API versioning support
- Swagger/OpenAPI documentation
- Model validation
- Exception handling through middleware
- Authorization attributes where applicable

## Organization

Controllers are organized by:
- Module subdirectories
- RESTful naming conventions
- Consistent route patterns

## Customization

Developers can customize generated controllers by:
- Adding custom endpoints
- Modifying route patterns
- Implementing additional authorization
- Adding custom validation logic
