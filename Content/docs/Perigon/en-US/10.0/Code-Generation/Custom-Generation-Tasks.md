# Custom Generation Tasks

The tool provides custom code generation task functionality, allowing users to generate code according to specific needs. This article introduces how to create and use custom code generation tasks.

Code generation related features are under the navigation `Code Generation/Generation Tasks`.

## Creating Custom Generation Tasks

Creating a generation task involves two steps:
1. Create steps
2. Create task

A task can contain multiple steps, each with corresponding templates and generation paths.

Assuming you already have an example template, refer to [Code Templates](../Data-Management/Code-Templates.md) if needed.

### Creating Steps

Click the + button next to the steps list to open the create step page:

![Create Task Step](../../_images/create_task_step.png)

- You can only select one template file
- When generating code based on a model, you can use supported variables in the output directory

### Creating Tasks

Click the + button next to the task list to open the create task page:

![Create Task](../../_images/create_task.png)

The context type specifies what data type the generator uses:

1. **Entity**: Generate DTOs, SQL scripts, or perform transformations from entities
2. **DTO Model**: Generate request/response models and frontend pages
3. **OpenAPI**: Provides the `OpenApiPaths` object to expose API information. Requires familiarity with [OpenAPI.NET](https://github.com/microsoft/OpenAPI.NET)
4. **Custom Variables**: Add custom variables for use in templates

### Running Tasks

After creation, return to the task list and click the run button. Based on the context type, you'll select an appropriate data source (searchable), such as a specific entity or configured OpenAPI endpoint.

## Summary

Custom code generation lets you generate needed code from backend entity or DTO model information, reducing repetitive work and human errors.

You need basic knowledge of `razor` template writing. Use `VS Code` to edit `razor` files for syntax highlighting and code completion.

Future versions will leverage AI to help generate code templates.
