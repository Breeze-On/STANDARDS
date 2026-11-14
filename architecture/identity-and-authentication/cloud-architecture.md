# Cloud architecture — App Registration strategy

Owner: Architecture

## Customer environments

Approved hosting and identity binding:

- **One App Registration per customer-environment**, named `{Customer}-{ENV}` (e.g. `CustomerA-DEV`). Product tokens do **not** appear in the registration name.
- **One product application deployment per product** in that customer-environment (e.g. EAC-DEV and VMR-DEV are separate App Services). Product deployment ≠ product App Registration.
- **One customer database per customer-environment**, shared by all product applications in that environment (Identity schema + business schemas). See [identity-schema-standard.md](identity-schema-standard.md) and [ADR-010](../../decisions/ADR-010-platform-identity-schema.md).
- All product deployments in the same customer-environment **share** `AUTHENTICATION__AUTHORITY`, `AUTHENTICATION__CLIENTID`, and `AUTHENTICATION__CLIENTSECRET` (the shared App Registration). Each deployment keeps its **own** host-only application cookie. Shared Identity directory and shared App Registration ≠ shared SSO cookie. See [ADR-012](../../decisions/ADR-012-cookie-session-management.md).

Illustrative naming:

| Example App Registration | Meaning |
| --- | --- |
| `CustomerA-DEV` | Customer A, DEV (all products in that environment) |
| `CustomerA-UAT` | Customer A, UAT |
| `CustomerA-PRD` | Customer A, PRD |
| `CustomerB-DEV` | Customer B, DEV |
| `CustomerB-UAT` | Customer B, UAT |
| `CustomerB-PRD` | Customer B, PRD |

BreezeOn owns the App Registration. Customer admin consent creates an Enterprise Application in the customer tenant (one consent relationship per customer-environment).

Which home tenants may sign in (for example BreezeOn + Customer A) is configured **on the App Registration in Microsoft Entra**, not in application code. There is no `AUTHENTICATION__TENANTID` and no `Identity.AllowedTenants` table.

**`Identity.Tenants` is not a login allowlist.** It is a platform registry of Entra tids observed in the customer database (login discovery) plus explicit directory-sync enablement (`IsSyncEnabled`). Sign-in eligibility remains Entra App Registration configuration only. See [directory-synchronization-standard.md](directory-synchronization-standard.md) and [ADR-013](../../decisions/ADR-013-microsoft-graph-directory-synchronization.md). Application permission `User.Read.All` (admin consent) on the same App Registration enables Graph directory sync and login-time profile photo refresh.

## Internal BreezeOn registrations

| App Registration | Purpose |
| --- | --- |
| `BreezeOn-LOCAL` | Shared local development for **all** BreezeOn applications (same shared-registration pattern) |
| `BreezeOn-DEV` | BreezeOn-operated shared DEV when used |
| `BreezeOn-UAT` | BreezeOn-operated shared UAT when used |
| `BreezeOn-PRD` | BreezeOn-operated shared PRD when used |

Distinguish **customer-environment registrations** from **internal BreezeOn registrations**. Do not reuse a customer-environment ClientId for local development; use `BreezeOn-LOCAL`.

## Implications

| Concern | Practice |
| --- | --- |
| Secret blast radius | One client secret compromise affects all products in that customer-environment. Rotate once on the App Registration; update `AUTHENTICATION__CLIENTSECRET` on **every** product App Service (and local User Secrets when applicable). |
| Redirect URI sprawl | Every product base URL registers `{base}/signin-oidc` and `{base}/signout-callback-oidc` on the shared App Registration. Entra supports many redirect URIs on one registration. |
| Logout coupling | Entra end-session for that client ends IdP SSO for all products on the registration. Other products’ application cookies remain until idle/absolute expiry or the next challenge. |
| Cookie SSO | Shared ClientId enables Entra-level silent re-auth across products. It does **not** share `BreezeOn.Auth` across hosts. Cross-app application-cookie SSO remains [future roadmap](future-roadmap.md). |
| Migration | Consolidate any product-scoped registrations (e.g. historical `*-EAC-*` names) into `{Customer}-{ENV}`. Point all product hosts at the shared ClientId/Secret; register all redirect URIs; retire old registrations after cutover. |

Per-product App Registrations within a customer-environment are **not** the platform standard. Exceptions require a superseding ADR (see [ADR-011](../../decisions/ADR-011-app-registration-per-customer-environment.md)).

## Related

- [Configuration standard](configuration-standard.md)
- [Local development standard](local-development-standard.md)
- [Session management standard](session-management-standard.md)
- [ADR-011](../../decisions/ADR-011-app-registration-per-customer-environment.md)
