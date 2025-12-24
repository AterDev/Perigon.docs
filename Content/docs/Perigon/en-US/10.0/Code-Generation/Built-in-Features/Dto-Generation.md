# DTO Generation

DTO generation creates DTO classes based on **entity classes**, usually including:

| DTO       | Purpose                      |
| --------- | ---------------------------- |
| ItemDto   | List element                 |
| DetailDto | Details of an entity         |
| FilterDto | Request filter condition model|
| AddDto    | Model for adding             |
| UpdateDto | Model for updating           |

DTOs will be generated in the corresponding module directory.

**Support Methods: `Studio` and `MCP`**

## DTO Generation Rules

DTOs globally ignore the following properties:

- Properties with the `[JsonIgnore]` attribute
- Properties of type `JsonDocument` or `byte[]`

For each type of DTO, properties are filtered and processed according to specific usage scenarios. The detailed rules are as follows:

### ItemDto

List elements will not include the following properties:

- IsDeleted and UpdatedTime fields, but will include CreatedTime
- Arrays or lists
- Strings longer than 200 characters
- Navigation properties and corresponding Ids

### DetailDto

Detail Dto does not include the following properties:

- IsDeleted
- Lists and navigation properties
- Properties of type `JsonDocument` and `byte[]`

### FilterDto

FilterDto generation content is as follows:

- Ignore basic properties such as "Id", "CreatedTime", "UpdatedTime", "IsDeleted"
- Ignore lists and navigation properties
- Ignore string properties with a maximum length of 1000
- Keep required properties (but not navigation properties)
- Include enum properties

### AddDto

Add model generation content is as follows:

- Ignore basic properties such as "Id", "CreatedTime", "UpdatedTime", "IsDeleted"
- Must be assignable properties, i.e., have a `set` method.
- For navigation properties, the following processing will be performed:
  - Ignore non-required navigation properties
  - Ignore list navigation properties
  - For required navigation properties, generate in the form of `property name` + `Id` to represent

### UpdateDto

Update model generation content is the same as add model, but all properties of the update model are nullable by default.

Nullable properties mean that if the field is null, the update will ignore the field to achieve partial updates.
