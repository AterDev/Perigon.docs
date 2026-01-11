# Module Example

Module design is intended to better organize and manage different functions in the project. In development, it can separate concerns, improve code maintainability, and enhance extensibility.

Modules are relatively independent. They typically contain the business implementation `Manager` of the module and Dto models. Entity models are still uniformly defined in `Definition/Entity`.

When creating a solution, the template adds example modules by default. You can use them directly, or modify or delete them as needed.

## Naming Convention

All modules end with `Mod` to make it easy to identify them as modules. They are located in the `src/Modules` directory. Each module is a separate assembly.

## CommonMod

CommonMod is a `reserved` module that typically provides common basic functionality shared across other modules.

## SystemMod

SystemMod is the default module that provides system-related functionalities such as administrator user roles, including common system features like user login.
