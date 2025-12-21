# Project Template Overview

**Perigon.template** is a framework template based on the `Aspire`, `ASP.NET Core`, and `EntityFramework Core` technology stack. Combined with best practices, good development standards, and the development assistance tool `Perigon.CLI`, it provides rapid development capabilities to help developers quickly build modern Web application services with clear structure and easy maintenance.

`Result-oriented and practical` is the core concept of our template design. In architectural design, we mainly follow three principles: **universal, concise, and flexible**, committed to providing developers with efficient and easy-to-use development experiences. The specific meanings of the three principles:

- Universal: Refers to using mainstream, official, widely adopted or recognized technology stacks and implementation methods as much as possible to reduce mental burden and learning costs.
- Concise: Simple and fast. Maintain clear code structure, convenient and fast to use, and intuitive. Avoid over-design and unnecessary abstraction, focus on business logic implementation.
- Flexible: Not dependent on any design pattern or limited to a certain development method, but provides conventions and best practices. All source code can be modified and extended, allowing developers to adjust and optimize according to actual needs.

> [!IMPORTANT]
> **Best Practices** in the documentation is a technical expression term, referring to recommended implementation methods after practice, and does not mean the best way. Everyone or team can have their own best practices.

## Directory Structure

Software development and delivery is essentially the process of digital asset production and manufacturing. Many productions in reality can be simply summarized as: `Design->Production->Delivery`, which also applies to software development.

In software development, we can simplify it to: **Definition->Implementation->Service**. On this basis, we have designed the following project structure:

- Definition determines what to do, what is needed, and what to provide. Implemented by the `Definition` layer in the template.
- Implementation specifically implements business logic according to the definition. Implemented through `Modules` (multiple modules) in the template.
- Service provides external services through APIs for implemented business logic. Implemented through the `Services` layer in the template.

You can refer to the [Directory Structure](./Directory-Structure.md) document for detailed instructions on each directory and project.

## AppHost

`AppHost` is the **Aspire** host project, which is responsible for starting and managing all service instances. In the template, the `AppHost` project is the entry point for running the entire application.

We will define the infrastructure needed for the application through code. You can read [Configuring Development Environment with Aspire](./Configuring-Dev-Environment-with-Aspire.md) to learn how to use it.
