# DTO Generation

This document explains the implementation details of the DTO generation feature in the code generator.

## Generation Process

The DTO generator analyzes entity classes and generates the following DTO types:

### ItemDto
Used for list views, contains:
- Basic properties excluding complex types
- Excludes navigation properties
- Limits string lengths for performance

### DetailDto  
Used for detailed views, contains:
- Most entity properties
- Excludes collections and complex navigation properties
- Includes timestamps and metadata

### FilterDto
Used for filtering and search operations, contains:
- Properties suitable for filtering
- Excludes collections and binary data
- Includes enum properties for filtering

### AddDto
Used for creation operations, contains:
- Required properties for creating new entities
- Excludes auto-generated fields (Id, timestamps)
- Includes foreign key IDs instead of navigation properties

### UpdateDto
Used for update operations, contains:
- Similar to AddDto but all properties are nullable
- Allows partial updates
- Null values are ignored during updates

## Property Filtering Rules

The generator applies specific rules for each DTO type to determine which properties to include based on:
- Property type
- Attributes (Required, MaxLength, etc.)
- Navigation property status
- String length constraints
- JsonIgnore attributes

## Code Generation

Generated DTOs include:
- Proper namespaces
- XML documentation comments
- Data annotations for validation
- Mapster mapping hints
