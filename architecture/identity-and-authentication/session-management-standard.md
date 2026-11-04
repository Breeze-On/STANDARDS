# Session management standard

Owner: Architecture

Platform cookie authentication and application session policy for BreezeOn product hosts. Implementation lives in SYSTEM-SHARED-UI (`BoCookieAuthenticationDefaults` / `AddBreezeOnAuthentication`). Products must **not** independently reconfigure authentication cookies.

Related: [authentication-standard.md](authentication-standard.md), [ADR-012](../../decisions/ADR-012-cookie-session-management.md), [ADR-009](../../decisions/ADR-009-entra-oidc-cookie-authentication.md).

## Cookie policy (application session)

| Setting | Platform value | Notes |
| --- | --- | --- |
| Cookie name | `BreezeOn.Auth` | Host-only; not shared across product apps |
| HttpOnly | `true` | |
| Secure | `Always` | HTTPS required (including local `https://localhost`) |
| SameSite | `Lax` | Compatible with top-level OIDC redirects. Do **not** set the session cookie to `None`. OIDC correlation/nonce cookies remain framework defaults (`SameSite=None; Secure`) |
| Path | `/` | |
| Domain | unset | No cross-subdomain / cross-customer / cross-app domain sharing |
| Sliding expiration | `true` | |
| Idle timeout (`ExpireTimeSpan`) | 8 hours | Sliding ticket lifetime |
| Absolute lifetime | 24 hours from ticket issue | Enforced in `OnValidatePrincipal`; sliding cannot extend past this |
| Persistent browser cookie | No (`IsPersistent` left false) | Browser session cookie; ticket still carries idle/absolute lifetimes |
| Ticket store | Cookie (ASP.NET Core default) | No server-side session store |
| Login / logout paths | `/Account/Login`, `/Account/Logout` | Mapped by `MapBreezeOnAuthentication` |

Configuration knobs for these security attributes are **not** exposed on `BoAuthenticationOptions`. Change them only in SYSTEM-SHARED-UI.

## Session lifecycle

| Event | Behaviour |
| --- | --- |
| Successful authentication | OIDC ID token validated → Identity directory upsert (when enabled) → application cookie issued |
| Idle renewal | Sliding expiration renews the ticket while requests arrive within the idle window |
| Absolute expiry | Ticket older than 24 hours from issue is rejected; user is challenged again |
| Explicit logout | Clear application cookie, then OIDC sign-out (Entra end-session / `signout-callback-oidc`) |
| Expired / invalid ticket | Challenge → login |
| `Identity.Users.IsEnabled = 0` | Blocks **new** authenticated sessions at login. Existing cookies remain valid until idle or absolute expiry. Immediate mid-session revocation is **not** implemented |
| Application restart | Depends on Data Protection key persistence (see below) |
| Multiple App Service instances (same slot) | Cookies remain decryptable via the shared App Service key folder |
| Separate product apps (e.g. EAC vs VMR) | Separate cookies and key rings — expected. Shared Identity directory ≠ shared SSO cookie |
| Blazor Interactive Server circuit | Auth state follows the cookie on HTTP. A long-lived circuit may briefly outlive a rejected cookie until the next HTTP/circuit reconnect |

### Local application session vs Entra session

- Clearing `BreezeOn.Auth` ends the **application** session only.
- OIDC sign-out ends the Entra session for that sign-out flow.
- Other BreezeOn product apps (different hosts / App Registrations) keep their own cookies unless the user signs out of those apps or Entra SSO state no longer satisfies a new challenge.

## Data Protection (hosting requirements)

Cookie tickets are protected by ASP.NET Core Data Protection.

| Hosting | Requirement |
| --- | --- |
| Azure App Service (current) | Default key ring at `%HOME%\ASP.NET\DataProtection-Keys` is shared across instances **within the same deployment slot**. Approved for current hosting. No Blob / Redis / Key Vault dependency. |
| Deployment slots | Slots do **not** share key rings. Slot swap can invalidate cookies (users re-authenticate). External key rings require a future ADR. |
| Separate App Services | Separate key rings — correct for per-app cookies. |
| Local Development | User-profile or ephemeral keys; restart may invalidate cookies — acceptable. |

Product hosts should call `AddDataProtection().SetApplicationName("BreezeOn.<Product>")` so purpose strings stay product-scoped if a shared key store is introduced later.

## OIDC middleware (platform requirements)

Rely on supported ASP.NET Core OpenIdConnect middleware:

- Do not disable built-in security validation.
- Do not implement custom protocol validation without an ADR.
- Do not override security-sensitive defaults without justification documented here or in an ADR.
- Keep `Microsoft.AspNetCore.Authentication.OpenIdConnect` on a supported version aligned with the host TFM.

## Related

- [Configuration standard](configuration-standard.md)
- [Identity schema standard](identity-schema-standard.md)
- [Future roadmap](future-roadmap.md)
