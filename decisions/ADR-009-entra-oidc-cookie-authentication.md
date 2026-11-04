# ADR-009: Entra OIDC cookie authentication (SHARED-UI)

Status: Accepted

## Context

Breeze On applications need end-user authentication against Microsoft Entra ID. Product apps must not each redesign OIDC. Blazor Interactive Server ([ADR-002](ADR-002-blazor-interactive-server.md)) favors cookie sessions. Phase 1 does not call Microsoft Graph.

## Decision

- Interactive authentication is **OIDC Authorization Code Flow** with Microsoft Entra ID, then an application **cookie** session.
- Implementation lives in **SYSTEM-SHARED-UI** (`BreezeOn.UI` authentication helpers). Product applications **consume** the shared framework; they must not independently redesign authentication.
- Phase 1 uses ASP.NET Core **OpenIdConnect + Cookies**, not Microsoft.Identity.Web. App-only Graph sync or delegated Graph may add MSAL/Identity.Web later **without** replacing the cookie login path.
- Configuration: `AUTHENTICATION__AUTHORITY`, `AUTHENTICATION__CLIENTID`, `AUTHENTICATION__CLIENTSECRET` (no hard-coded authority; no `AUTHENTICATION__TENANTID`).
- Tenant who may sign in is controlled by **Entra App Registration** configuration, not application allowlists.

## Consequences

- All apps share login/logout, claims mapping, and Identity directory write behaviour.
- Agents and developers follow [architecture/identity-and-authentication/](../architecture/identity-and-authentication/README.md).
- Changing this model requires updating or superseding this ADR in the same change set as code.
