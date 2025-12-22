# Authorization and Authentication

Common approaches:

- JWT: for frontend-backend separation; clients carry a JWT.
- IdentityServer: for complex auth needs (OAuth2, OpenID Connect).
- Cookies: for traditional web apps; session state in cookies.
- Third-party login: OAuth2-based (Google, Microsoft, etc.).
- Passwordless: WebAuthn/PassKey device or biometric-based.

## JWT

Server issues a token during login; clients include it in subsequent requests; server validates the token to authenticate.

## IdentityServer

A full-featured auth framework supporting OAuth2 and OpenID Connect. Includes capabilities like multi-tenancy, client credentials, and resource servers.

## Passwordless Login

In .NET 10, use PassKey (WebAuthn) for biometric or device-backed login without passwords.

## Third-party Login

Register your app with the provider to obtain client ID/secret, then configure in your app.

## Template Support

Configure under the `Authentication` section. Built-in support:

- JWT via `JwtBearer`.
- Microsoft account login.
- Google account login.

With valid settings present, services and middleware are added automatically.

See `WebExtensions.cs` for `AddJwtAuthentication` and `AddThirdAuthentication`.
