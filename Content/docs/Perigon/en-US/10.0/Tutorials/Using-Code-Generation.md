# Using Code Generation

Next, let's witness the power of code generation. This document introduces how to use the code generation features. Here we will complete the related operations using `Studio WebUI`.

## Check Project Configuration

Projects created through templates usually do not require additional configuration. To be safe, let's still check the project configuration and understand the meaning of the configuration.

Use `perigon studio` to start `Studio WebUI`, click the ⚙️ icon next to a solution to open the configuration popup:

![config](../_images/config.jpg)

The above is mainly directory configuration, which means you don't necessarily have to use the directory structure in the original template. You can customize the directory structure, but make sure it is consistent with the configuration.

Here we mainly focus on **User Foreign Key Name**, the template includes `UserId` by default, which is used to represent the foreign key property name of the user entity in other entities.

> [!NOTE]
> **User Foreign Key Name** refers to entity classes related to authentication, usually related to data permissions. Its identification is obtained using `IUserContext`. Logical processing will be performed during code generation, so it needs to be distinguished from ordinary entity classes.

## Generate DTO/Managers/Controllers

Select a solution and enter the workbench. We will see the entity list. In the operation column, there are three generation operation buttons, which are:

- Generate DTO: Generate corresponding DTO model definitions through entity parsing
- Generate Manager: Generate Manager classes containing basic CRUD operations. Since it depends on DTO, DTO will be generated automatically.
- Generate Controller: Generate Controller classes containing basic CRUD operations. Since it depends on Manager, Manager and DTO will be generated automatically.

![entity_list](../_images/entity_list.png)


## Generate Client Request Service

Through the OpenAPI specification, we can generate corresponding client request service code.

First, let's add the OpenAPI address. Click `OpenAPI` in the left navigation bar to enter the OpenAPI management page, and click the ➕ icon.

![add openapi](../_images/add_openapi.png)

After adding, the tool will request and parse the json content (please ensure the address is correct and accessible), and then provide an API list and information.

Now, let's generate the client request service code. On the right side of the top operation bar, click the `</>` icon:

![gen request](../_images/gen_request.png)

- Request Client: Currently supports generating `Angular`, `Csharp`, `Axios` client request services.
- Output Directory: The output directory for code generation.
- OnlyModels Option: Not selected by default, which means generating complete client request service code. If selected, only model definitions are generated.


> [!NOTE]
> If you feel that the generated client request code does not meet your requirements, you can implement it through custom templates. Please refer to the [Custom Code Generation Templates](../Code-Generation/Custom-Generation-Tasks.md) documentation for details.
> 
