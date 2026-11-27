<!-- Classification: DEC; Scope: platform; Domain: Engineering; Capability: AdrProcess -->
# ADR-012: Cookie and session management (SHARED-UI)

Status: Accepted

## Context

ADR-009 established Entra OIDC + application cookie sessions owned by breezeon-system-shared-ui, but did not specify cookie attributes, idle vs absolute lifetimes, logout semantics, or Data Protection hosting requirements. Product apps must not each invent cookie policy. Blazor Interactive Server and OIDC correlation/nonce cookies constrain SameSite choices.

Login-only enforcement of `Identity.Users.IsEnabled` left disabled users with valid cookies until idle or absolute expiry. That gap is closed by mid-session revalidation (see Amendment below).

## Decision

- breezeon-system-shared-ui owns the platform cookie/session policy (`BoCookieAuthenticationDefaults` applied by `AddBreezeOnAuthentication`). Products must not reconfigure authentication cookies.
- Cookie: name `BreezeOn.Auth`; `HttpOnly`; `Secure=Always`; `SameSite=Lax`; `Path=/`; host-only (no Domain); sliding idle **8 hours**; absolute lifetime **24 hours** from issue; non-persistent browser cookie; ticket stored in the cookie (no server session store).
- OIDC correlation/nonce cookies remain ASP.NET Core defaults (`SameSite=None; Secure`) — do not force them to `Lax`.
- Logout clears the application cookie and performs OIDC/Entra sign-out. Local logout is not promised to revoke other product apps’ cookies.
- **Login-time validation:** `Identity.Users.IsEnabled = 0` blocks **new** sessions at OIDC login (no application cookie).
- **Ongoing session validation:** `OnValidatePrincipal` enforces absolute lifetime, then `IBoIdentitySessionGate`. A missing Identity row or `IsEnabled = 0` rejects the principal and clears the application cookie. Process-local in-memory cache TTL is **60 seconds** (revocation latency bound per App Service instance). When Valid, the gate returns the current `Identity.Users.UserGUID` for `(tid, oid)`. If the cookie `breezeon_userguid` claim is missing or differs, middleware reconciles the claim (`ReplacePrincipal` + `ShouldRenew`); if reconciliation fails, the principal is rejected (challenge). No security stamp column and no server-side session store.
- Data Protection: Azure App Service default key folder within a deployment slot is approved; no Blob/Redis/Key Vault requirement for the current hosting model. Separate apps and slots have separate key rings. Product hosts set `AddDataProtection().SetApplicationName("BreezeOn.<Product>")`.
- Normative detail: [session-management-standard.md](../architecture/identity-and-authentication/session-management-standard.md).

## Consequences

- Cookie security posture is consistent across product hosts.
- Sliding sessions cannot run indefinitely past the absolute cap.
- Slot swaps and local restarts may invalidate cookies; document rather than add infrastructure prematurely.
- Disabled or missing Identity users lose application sessions within **≤ 60 seconds** per host instance (cache TTL). Database errors during recheck **fail closed** (challenge).
- A Blazor Interactive Server circuit may briefly outlive a rejected cookie until the next HTTP/circuit reconnect.
- Multi-product hosts each keep separate cookies and independently revalidate against the shared customer Identity database.
- Cross-app application-cookie SSO remains out of scope ([future-roadmap.md](../architecture/identity-and-authentication/future-roadmap.md)).
- Distributed cache invalidation and security-stamp revocation remain out of scope unless a future ADR supersedes this decision.

## Amendment — mid-session `IsEnabled` revalidation (2026-11-15)

Promoted from the Identity & Authentication future roadmap into current platform policy:

| Topic | Current platform behaviour |
| --- | --- |
| Login-time | Unchanged: disabled users never receive a cookie |
| Ongoing | `OnValidatePrincipal` → absolute timeout → `IBoIdentitySessionGate` |
| Revocation | Soft-disable / `IsEnabled = 0` / missing row ends the application session within the 60s cache SLO |
| Limits | Per-instance memory cache; no cross-app cookie clear; circuit caveat; fail-closed on recheck errors |

Implementation: breezeon-system-shared-ui (`BoCookieAuthenticationDefaults`, `IBoIdentitySessionGate`). Operator onboarding: [customer-onboarding-authentication.md](../runbooks/customer-onboarding-authentication.md).

## Amendment — UserGUID cookie reconciliation (2026-11-15)

Local Identity rebuilds (and any recreate of `Identity.Users` rows) mint a new `UserGUID` for the same `(TenantId, ExternalObjectId)`. A still-valid `BreezeOn.Auth` cookie can carry a stale `breezeon_userguid`, which breaks authorization membership lookups while the session gate still passes on `(tid, oid)`.

| Topic | Current platform behaviour |
| --- | --- |
| Gate result | Valid evaluations include current `UserGUID` |
| Cookie claim | Missing or mismatched `breezeon_userguid` → heal + renew ticket |
| Fallback | Heal failure → reject principal (re-authenticate) |
| AuthZ cache | Stale UserGUID invalidated when present and replaced |
