<!-- Classification: DEC; Scope: platform -->
# ADR-011: App Registration per customer-environment

Status: Accepted

## Context

BreezeOn hosts SaaS apps in the BreezeOn Azure tenant while customers authenticate from their own Entra tenants. Isolation of secrets, consent, and redirects requires a clear App Registration strategy. Database topology is separate: products in the same customer-environment share one customer database ([ADR-010](ADR-010-platform-identity-schema.md)).

Earlier wording used product-scoped registration names (for example `CustomerA-EAC-DEV`) and implied separate App Registrations per product within a customer-environment. That contradicted the decision title and produced unnecessary registration sprawl as products are added.

## Decision

- **One App Registration per customer-environment**, named `{Customer}-{ENV}` (for example `CustomerA-DEV`, `CustomerA-UAT`, `CustomerA-PRD`). Product tokens (EAC, VMR, Billing) do **not** appear in the App Registration name.
- **One product application deployment per product** in that customer-environment (for example EAC-DEV and VMR-DEV are separate App Services). Product deployment ≠ product App Registration.
- All product hosts in the same customer-environment **share** the same `AUTHENTICATION__AUTHORITY`, `AUTHENTICATION__CLIENTID`, and `AUTHENTICATION__CLIENTSECRET` (the shared registration). Each host keeps its own host-only application cookie ([ADR-012](ADR-012-cookie-session-management.md)).
- Multiple product deployments for the same customer-environment (e.g. EAC + VMR) share the **customer database**, Identity directory, and **App Registration**; they keep separate deployments and cookies.
- Register every product host’s redirect URIs on that single App Registration (`{base}/signin-oidc`, `{base}/signout-callback-oidc` per product base URL).
- BreezeOn owns App Registrations; customer consent creates an Enterprise Application in the customer tenant (one consent relationship per customer-environment).
- Internal platform registrations: **`BreezeOn-LOCAL`** (all local apps — same shared-registration pattern), **`BreezeOn-DEV`**, **`BreezeOn-UAT`**, **`BreezeOn-PRD`** when used for BreezeOn-operated shared environments.
- Multi-tenant access (e.g. BreezeOn + customer home tenants) is configured **in Entra** on the registration. No application `AUTHENTICATION__TENANTID` or `Identity.AllowedTenants`. Platform table **`Identity.Tenants`** records observed tids and sync enablement only — it must **not** be used as an application login allowlist ([ADR-013](ADR-013-microsoft-graph-directory-synchronization.md)).
- The same App Registration may hold **application** Microsoft Graph permissions (e.g. `User.Read.All`) for directory synchronization and login-time profile photos, with customer admin consent, without changing the interactive OIDC cookie path.
- Hosted secrets live in **Azure App Service application settings** until a future ADR supersedes that store. Secret rotation updates the shared registration and every product host’s `AUTHENTICATION__CLIENTSECRET` in that customer-environment.

## Consequences

- Naming, onboarding, redirect URI lists, and implications follow [cloud-architecture.md](../architecture/identity-and-authentication/cloud-architecture.md) and [configuration-standard.md](../architecture/identity-and-authentication/configuration-standard.md). Operator cutover checklist: [customer-onboarding-authentication.md](../runbooks/customer-onboarding-authentication.md).
- Local work always uses `BreezeOn-LOCAL` and the same OIDC flow as hosted ([local-development-standard.md](../architecture/identity-and-authentication/local-development-standard.md)).
- Shared App Registration enables Entra-level SSO (silent re-auth across products). It does **not** create a shared `BreezeOn.Auth` cookie across hosts; cookie SSO productization remains future work ([future-roadmap.md](../architecture/identity-and-authentication/future-roadmap.md)).
- Per-product App Registrations within a customer-environment are **not** the platform standard. Exceptions (independent consent, separate secret blast radius, or a product outside the shared customer database) require a superseding ADR.
