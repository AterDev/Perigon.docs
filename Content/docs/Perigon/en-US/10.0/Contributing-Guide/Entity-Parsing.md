# Entity Parsing

Entity parsing is the foundation of code generation. This document explains how the tool parses entity classes to extract information needed for code generation.

## Parsing Methods

There are two main methods for parsing entities:

1. **Roslyn Static Analysis**: Parse entity class source code directly using Roslyn to extract property information, attributes, and relationships.

2. **EntityFramework Core Design**: Use EF Core's design-time services to model the database context and extract comprehensive entity information including:
   - Entity properties and types
   - Relationships (one-to-one, one-to-many, many-to-many)
   - Constraints and indexes
   - Navigation properties

## XML Documentation

XML documentation comments are extracted using `XmlDocHelper` to provide descriptions for:
- Entity classes
- Properties
- Enums and their values

This information is used in generated code comments and API documentation.

## Property Analysis

For each entity property, the parser extracts:
- Name and type
- Required/optional status
- Maximum length constraints
- Data annotations and attributes
- Relationships to other entities
- XML documentation comments

## Usage in Code Generation

The parsed entity information is used by generators to:
- Create DTO models with appropriate properties
- Generate Manager methods for CRUD operations
- Build Controller endpoints with proper routing
- Produce accurate API documentation
