# Project Templates Overview

**Perigon.template** is a framework template based on the `Aspire`, `ASP.NET Core`, and `EntityFramework Core` technology stack. Combined with best practices, good development standards, and the development auxiliary tool `Perigon.CLI`, it provides rapid development capabilities, helping developers quickly build clearly structured and easily maintainable modern Web application services.

`Results-oriented, practical goals` is the core philosophy behind our template design. In terms of architecture design, we mainly follow three principles: **Universal, Simple, and Flexible**, dedicated to providing developers with an efficient and easy-to-use development experience. The specific meanings of the three principles:

- Universal: Refers to using mainstream, official, widely adopted or recognized technology stacks and implementation methods as much as possible to reduce mental burden and learning costs.
- Simple: Simple and fast. Maintain clear code structure, convenient and fast to use, and intuitive. Avoid over-design and unnecessary abstractions, focusing on business logic implementation.
- Flexible: Not dependent on any one design pattern or limited to a certain development method, but rather provides conventions and best practices. All source code can be modified and extended, allowing developers to adjust and optimize according to actual needs.

> [!IMPORTANT]
> **Best Practices** in the documentation is a technical term, referring to recommended implementation methods after practice, and does not mean the best method. Everyone or team can have their own best practices.

## Directory Structure

Software development and delivery is essentially a process of digital asset production and manufacturing. In reality, many productions can be simply summarized as: `Design -> Production -> Delivery`, which also applies to software development.

In software development, we can simplify it to: **Definition -> Implementation -> Service**. Based on this, we designed the following project structure:

- Definition: Determines what to do, what is needed, and what is provided. In the template, it is implemented by the `Definition` layer.
- Implementation: Implement business logic based on the definition. In the template, it is implemented through `Modules` (multiple modules).
- Service: Provide business logic implementation to the outside through interfaces. In the template, it is implemented through the `Services` layer.

You can refer to the [Directory Structure](./Directory-Structure.md) document to learn detailed descriptions of each directory and project.

## AppHost

`AppHost` is the **Aspire** host project, which is responsible for starting and managing all service instances. In the template, the `AppHost` project is the entry point for running the entire application.

We will define the infrastructure needed by the application through code. You can read [Configuring Development Environment with AppHost](./Configuring-Environment-with-AppHost.md) to learn how to use it.
