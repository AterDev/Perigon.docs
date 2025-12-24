# DTO Generation

DTO is used to define the input and output data structure of interfaces. When interacting with databases, type conversion is required. We use `Mapster` for conversion between entity classes and DTOs. DTO content is generated based on entity classes, which is a prerequisite.

This document explains how to generate DTO classes and DTO generation rules.

## Generated DTO Types

Based on **entity classes**, the following DTO types are generated:

| DTO       | Purpose              |
| --------- | -------------------- |
| ItemDto   | List elements        |
| DetailDto | Entity details       |
| FilterDto | Filter condition model|
| AddDto    | Add model            |
| UpdateDto | Update model         |

When generating DTOs, DTO information is cached. After generation completes, the cache is cleared.

See the `DtoCodeGenerate` class for specific implementation details.

## DTO Generation Rules

DTOs globally ignore the following properties (temporary limitation):

- Properties with the `[JsonIgnore]` attribute
- Properties of type `JsonDocument` or `byte[]`

Future updates will handle these properties.

> [!TIP]
> Since `EntityFrameworkCore.Design` is used to obtain entity information, properties not recognized as database-mapped properties will not be included in Add/Update DTO generation.

For each DTO type, properties are filtered and processed based on the specific usage scenario.

## AddDto

Add model generation content:

- Ignore basic properties like "Id", "CreatedTime", "UpdatedTime", "IsDeleted"
- Must be assignable properties with a `set` method.
- Do not retain original `required` keyword restrictions for better instance creation.
- For navigation properties:
  - Ignore Collection and SkipNavigation properties

## ItemDto

List elements do not include the following properties:

- IsDeleted and UpdatedTime fields, but include CreatedTime
- Arrays or lists
- Strings longer than 200 characters
- Navigation properties and corresponding IDs

## DetailDto

Detail DTO does not include the following properties:

- IsDeleted
- Lists and navigation properties
- Properties of type `JsonDocument` and `byte[]`

## FilterDto

FilterDto generation content:

- Ignore basic properties like "Id", "CreatedTime", "UpdatedTime", "IsDeleted"
- Ignore lists and navigation properties
- Ignore string properties with maximum length over 1000
- Keep required properties (but not navigation properties)
- Include enum properties

## UpdateDto

Update model generation is the same as add model, but all properties are nullable by default.

Nullable properties mean that if a field is null, the update ignores that field, implementing partial updates.
