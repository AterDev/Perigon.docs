# Module Example

Module design is intended to better organize and manage different functions in the project. In development, it can separate concerns, improve code maintainability, and enhance extensibility.

Modules are relatively independent. They typically contain the business implementation `Manager` of the module and Dto models. Entity models are still uniformly defined in `Definition/Entity`.

The latest templates no longer add example modules by default. You can select official modules during solution creation or install them later only when needed.

## Naming Convention

All modules end with `Mod` to make it easy to identify them as modules. They are located in the `src/Modules` directory. Each module is a separate assembly.

## CommonMod

CommonMod is a `reserved` module that typically provides common basic functionality shared across other modules.

## SystemMod

SystemMod is an official module that provides system-related capabilities such as administrator users, roles, permissions, and common login features. Select it during solution creation or install it later when needed.
