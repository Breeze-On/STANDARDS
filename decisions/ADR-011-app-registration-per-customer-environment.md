# ADR-011: App Registration per customer-environment

Status: Accepted

## Context

BreezeOn hosts SaaS apps in the BreezeOn Azure tenant while customers authenticate from their own Entra tenants. Isolation of secrets, consent, and redirects requires a clear App Registration strategy.

## Decision

- **One App Registration per customer-environment** and **one application deployment per customer-environment**, each with its own `AUTHENTICATION__*` settings.
- BreezeOn owns App Registrations; customer consent creates an Enterprise Application in the customer tenant.
- Internal platform registrations: **`BreezeOn-LOCAL`** (all local apps), **`BreezeOn-DEV`**, **`BreezeOn-UAT`**, **`BreezeOn-PRD`** when used for BreezeOn-operated shared environments.
- Multi-tenant access (e.g. BreezeOn + customer home tenants) is configured **in Entra** on the registration. No application `AUTHENTICATION__TENANTID` or `Identity.AllowedTenants`.
- Hosted secrets live in **Azure App Service application settings** until a future ADR supersedes that store.

## Consequences

- Naming and onboarding follow [cloud-architecture.md](../architecture/identity-and-authentication/cloud-architecture.md).
- Local work always uses `BreezeOn-LOCAL` and the same OIDC flow as hosted ([local-development-standard.md](../architecture/identity-and-authentication/local-development-standard.md)).
