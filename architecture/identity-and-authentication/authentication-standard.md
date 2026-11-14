# Authentication standard

Owner: Architecture

## Protocol and session

| Item | Standard |
| --- | --- |
| Identity provider | Microsoft Entra ID |
| Protocol | OpenID Connect (OIDC) |
| Flow | Authorization Code Flow |
| Application session | Cookie authentication (Blazor Interactive Server — [ADR-002](../../decisions/ADR-002-blazor-interactive-server.md)) |
| Cookie / session policy | [session-management-standard.md](session-management-standard.md) ([ADR-012](../../decisions/ADR-012-cookie-session-management.md)) |
| Interactive packages | `Microsoft.AspNetCore.Authentication.OpenIdConnect` + Cookies in SYSTEM-SHARED-UI |
| Not used (interactive path) | Microsoft.Identity.Web; ASP.NET Core Identity / `AspNet*` user store |
| App-only Graph | Same App Registration client credentials for directory sync and login-time profile photo ([ADR-013](../../decisions/ADR-013-microsoft-graph-directory-synchronization.md)); does **not** replace cookie login |

## Ownership

- **SYSTEM-SHARED-UI** owns the authentication framework: OIDC registration helpers, cookie/session policy, middleware/endpoint helpers, current-user/claims helpers, login/logout, profile menu sign-out integration, the default Identity directory SQL writer, tenant discovery, directory synchronizer, and login-time profile photo refresh.
- **Product applications** call the shared registration helpers and supply a database connection factory to the **customer** database. They must **not** independently redesign OIDC, cookies, Identity upsert, or Graph sync logic.

## Successful login behaviour

1. Validate the OIDC ID token for the configured App Registration (ASP.NET Core OpenIdConnect middleware; do not disable built-in validation).
2. Extract claims: `oid`, `tid`, `upn` / `preferred_username` (when available), `email`, `name`, `given_name`, `family_name`.
3. Locate or create `Identity.Users` by `(TenantId, ExternalObjectId)`.
4. If `Identity.Users.IsEnabled = 0`, **fail sign-in** (no application cookie). Do not write a successful login history row or update `LastLoginUtc`.
5. When enabled: update informational attributes and `LastLoginUtc`; insert `Identity.UsersLogins` (successful).
6. Upsert `Identity.Tenants` for claim `tid` (**discover only** — do not set `IsSyncEnabled`).
7. Best-effort refresh of `Identity.UserPhotos` via Microsoft Graph. Failure must **never** fail sign-in; keep any existing photo.
8. Establish the authenticated cookie session per [session-management-standard.md](session-management-standard.md).

## Logout

Clear the application cookie and redirect to Entra end-session (`signout-callback-oidc`). Wire through `BoProfileMenu`. Local application logout and Entra sign-out are distinct — see session standard.

## Persistence seam

- `IBoIdentityDirectory` + default `SqlIdentityDirectory` in SYSTEM-SHARED-UI.
- Host registers `IBoIdentityConnectionFactory` (connection to the **customer** database where `Identity.*` physically lives, shared by all products in that customer-environment).
- No product `DbContext` or repository types inside SHARED-UI.
- Directory sync and photo services also use the same connection factory and authentication options.

## Related

- [Session management standard](session-management-standard.md)
- [Identity schema standard](identity-schema-standard.md)
- [Directory synchronization standard](directory-synchronization-standard.md)
- [ADR-009](../../decisions/ADR-009-entra-oidc-cookie-authentication.md)
- [ADR-012](../../decisions/ADR-012-cookie-session-management.md)
- [ADR-013](../../decisions/ADR-013-microsoft-graph-directory-synchronization.md)
