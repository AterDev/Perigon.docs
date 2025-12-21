# Module Example

Module design is to better organize and manage different functions in the project. In development, it can separate concerns and improve code maintainability and extensibility.

The module itself is relatively independent. It usually contains the business implementation `Manager` of the module and Dto models. Entity models are still uniformly defined in `Definition/Entity`.

When creating a solution, the template will add example modules by default. You can use them directly or modify or delete them as needed.

## Naming Convention

All modules end with `Mod` to make it easy to identify them as modules. They are in the `src/Modules` directory. Each module is a separate assembly.

## CommonMod

CommonMod is a `reserved` module, usually providing some common basic functions.


## SystemMod
