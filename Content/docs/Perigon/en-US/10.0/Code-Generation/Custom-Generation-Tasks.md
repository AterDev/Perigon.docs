# Custom Generation Tasks

The tool provides custom code generation task functionality, allowing users to generate code according to specific needs. This article introduces how to create and use custom code generation tasks.

Code generation related features are under the navigation `Code Generation/Generation Tasks`.

## Creating Custom Generation Tasks

Creating a generation task involves two steps:
1. Create steps
2. Create task

A task can contain multiple steps, each with corresponding templates and generation paths.

Assuming we already have an example template, if not please refer to [Code Templates](../Data-Management/Code-Templates.md) to create one.

### Creating Steps

Click the + button on the right side of the steps list to enter the create step page:

![Create Task Step](../../_images/create_task_step.png)

- You can only select one template file
- When generating code based on a model, you can use supported variables in the output directory.
  

### Creating Tasks

Click the + button on the right side of the task list to enter the create task page:

![Create Task](../../_images/create_task.png)

The context type is used to specify the data type used during code generation, including:

1. Entity, commonly used for generating DTOs from entities, or generating SQL scripts, or performing conversions, etc.
2. DTO Model, such as generating request models, response models, and frontend pages, etc.
3. OpenAPI, provides the `OpenApiPaths` object to expose API related information. You need to be familiar with [OpenAPI.NET](https://github.com/microsoft/OpenAPI.NET) to use it in templates.
4. You can add custom variables for use in templates.

### Running Tasks

After creation, return to the task list and click the run button. According to the context type you selected, you will be asked to select an appropriate data source (searchable), such as a specific entity or configured OpenAPI node.

## Summary

Custom code generation allows you to generate the code you need based on entity or DTO model information provided by the backend, reducing repetitive work and human errors.

However, you need to have some basic knowledge of `razor` template writing. It is strongly recommended to use `VS Code` to edit `razor` files, as it can provide syntax highlighting and code completion.

In the future, we will leverage AI to help generate code templates.
