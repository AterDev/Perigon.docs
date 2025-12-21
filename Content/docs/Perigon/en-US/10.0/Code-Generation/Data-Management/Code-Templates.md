# Code Templates

Code generation templates are text template files written using `razor` syntax, with a `.razor` suffix. They are used to generate specific code content or provide references for MCP tools.

## Viewing Template Files

You can view your template files through the `Basic Data/Templates` page in **Studio**.

You can also view template files in the `templates` directory in the project root directory. The page will read and display templates from this directory.

## Template Management

First, you need to add a template category (corresponding to the directory name), then add template files in that category.

You can add through the `UI` page or directly add in the `templates` directory.

> [!TIP]
> When adding templates through UI, it will preliminarily verify whether your content conforms to the `razor` syntax specification.

## Template Context and Variables

Template context and variables are data and variables that can be used when writing templates. When creating a generation task, you can select the context type and custom variable list.

### Context Structure

| Property     | Description      |
| ------------ | ---------------- |
| Namespace    | `@Namespace`     |
| Model Name   | `@ModelName`     |
| Type Description | `@Description`   |
| New Line     | `@NewLine`       |
| Entity Properties | `@PropertyInfos` |
| Variable List | `@Variables`     |

For entity data types, additionally includes:

| Type       | Variable               |
| ---------- | ---------------------- |
| Add DTO    | `@AddPropertyInfos`    |
| Update DTO | `@UpdatePropertyInfos` |
| List DTO   | `@ItemPropertyInfos`   |
| Detail DTO | `@DetailPropertyInfos` |
| Filter DTO | `@FilterPropertyInfos` |

The `PropertyInfos` structure of DTOs is the same as that of entities.

### PropertyInfo Structure

| Property         | Description      |
| ---------------- | ---------------- |
| Type             | `Type`           |
| Name             | `Name`           |
| Display Name     | `DisplayName`    |
| Is Array         | `IsList`         |
| Is Public        | `IsPublic`       |
| Is Navigation    | `IsNavigation`   |
| Is Enum          | `IsEnum`         |
| XML Comment      | `CommentXml`     |
| Comment Summary  | `CommentSummary` |
| Is Required      | `IsRequired`     |
| Is Nullable      | `IsNullable`     |
| Min Length       | `MinLength`      |
| Max Length       | `MaxLength`      |

### Built-in Functions

| Method       | Example              |
| ------------ | -------------------- |
| ToHyphen     | `str.ToHyphen()`     |
| ToSnakeLower | `str.ToSnakeLower()` |
| ToPascalCase | `str.ToPascalCase()` |
| ToCamelCase  | `str.ToCamelCase()`  |

### Path Variables

Variables that can be used in paths when defining generation steps:

| Property                 | Description       |
| ------------------------ | ----------------- |
| Model Name (CamelPascal) | `ModelName`       |
| Model Name (a-b-c)       | `ModelNameHyphen` |


## Template Example

Next, let's add a template.

1. In the menu, find `Basic Data/Templates`, click the + sign on the right side of the directory to add a new template category, name it `sample`.
2. Click the + sign on the right template list to add a new template, name it `ModelDetail`, with the following content:

    ```razor
    @foreach (var item in PropertyInfos)
    {
        <p>@item.Name</p>
    }
    ```

We will use this template in subsequent code generation tasks.

The template itself follows the `razor` syntax specification. You can create a `templates/sample/ModelDetail.razor` file in the project directory and edit it with tools like `VS Code`. After adding, refresh the list to see the template.


> [!TIP]
> Writing templates is not easy. You need to understand what variables and data structures you can use. You can use [MCP tools to generate](../MCP-Server/Built-in-Tool-Examples.md#generate-razor-template) and modify on that basis.
