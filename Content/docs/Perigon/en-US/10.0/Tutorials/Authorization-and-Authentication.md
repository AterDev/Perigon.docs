# Authorization and Authentication

In our applications, we typically use the following methods for authentication:

- JWT: Suitable for front-end and back-end separated applications, where the front-end verifies identity by carrying JWT tokens.
- IdentityServer: Suitable for applications that require more complex authorization and authentication, providing support for OAuth2 and OpenID Connect protocols.
- Cookie: Suitable for traditional Web applications, using cookies to store user login status.
- Third-party Login: Integrate third-party login services through protocols such as OAuth2, such as logging in with Google and Microsoft accounts.
- Passwordless Login: Authenticate through methods such as sending verification codes or device confirmation, without passwords.

Let's briefly analyze the differences between different methods in terms of user systems and program implementation.

## JWT

The core of JWT implementation is generating and verifying tokens. Usually, when a user logs in, the server generates a JWT token and returns it to the client. The client carries the token in subsequent requests, and the server confirms the user's identity by verifying the token.

## IdentityServer

IdentityServer is a complete identity authentication and authorization framework that supports protocols such as OAuth2 and OpenID Connect. It provides rich features such as multi-tenant support, client credentials, resource servers, etc.

## Passwordless Login

In .NET 10, we can use PassKey to implement passwordless login. PassKey is a WebAuthn-based authentication method that allows users to log in using biometrics or device authentication without entering a password.

## Third-party Login

That is, logging in through third-party platform accounts, such as Google and Microsoft accounts. Usually, you need to register an application on the third-party platform, obtain a client ID and secret, and then configure this information in the application.

## Template Support

In the `Authentication` node in the configuration file, you can configure different authentication methods. The template provides support for the following authentication methods by default:

- JWT: Authenticate through `JwtBearer`.
- Microsoft: Support third-party login, such as Microsoft account login.
- Google: Support third-party login, such as Google account login.

When your configuration contains these authentication methods and has valid configuration, the template will automatically add the corresponding services and configuration for you.

You can view the specific implementation of the `AddJwtAuthentication` and `AddThirdAuthentication` methods in `WebExtensions.cs`.
