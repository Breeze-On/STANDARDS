# ADR-012: Cookie and session management (SHARED-UI)

Status: Accepted

## Context

ADR-009 established Entra OIDC + application cookie sessions owned by SYSTEM-SHARED-UI, but did not specify cookie attributes, idle vs absolute lifetimes, logout semantics, or Data Protection hosting requirements. Product apps must not each invent cookie policy. Blazor Interactive Server and OIDC correlation/nonce cookies constrain SameSite choices.

## Decision

- SYSTEM-SHARED-UI owns the platform cookie/session policy (`BoCookieAuthenticationDefaults` applied by `AddBreezeOnAuthentication`). Products must not reconfigure authentication cookies.
- Cookie: name `BreezeOn.Auth`; `HttpOnly`; `Secure=Always`; `SameSite=Lax`; `Path=/`; host-only (no Domain); sliding idle **8 hours**; absolute lifetime **24 hours** from issue; non-persistent browser cookie; ticket stored in the cookie (no server session store).
- OIDC correlation/nonce cookies remain ASP.NET Core defaults (`SameSite=None; Secure`) — do not force them to `Lax`.
- Logout clears the application cookie and performs OIDC/Entra sign-out. Local logout is not promised to revoke other product apps’ cookies.
- `Identity.Users.IsEnabled = 0` blocks **new** sessions at login; existing cookies are not immediately revoked (mid-session DB recheck is future work).
- Data Protection: Azure App Service default key folder within a deployment slot is approved; no Blob/Redis/Key Vault requirement for the current hosting model. Separate apps and slots have separate key rings. Product hosts set `AddDataProtection().SetApplicationName("BreezeOn.<Product>")`.
- Normative detail: [session-management-standard.md](../architecture/identity-and-authentication/session-management-standard.md).

## Consequences

- Cookie security posture is consistent across product hosts.
- Sliding sessions cannot run indefinitely past the absolute cap.
- Slot swaps and local restarts may invalidate cookies; document rather than add infrastructure prematurely.
- Cross-app SSO remains out of scope ([future-roadmap.md](../architecture/identity-and-authentication/future-roadmap.md)).
