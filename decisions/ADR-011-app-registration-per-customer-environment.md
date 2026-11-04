# ADR-011: App Registration per customer-environment

Status: Accepted

## Context

BreezeOn hosts SaaS apps in the BreezeOn Azure tenant while customers authenticate from their own Entra tenants. Isolation of secrets, consent, and redirects requires a clear App Registration strategy. Database topology is separate: products in the same customer-environment share one customer database ([ADR-010](ADR-010-platform-identity-schema.md)).

## Decision

- **One App Registration per customer-environment** (product-scoped naming such as `CustomerA-EAC-DEV`) and **one product application deployment per customer-environment**, each with its own `AUTHENTICATION__*` settings and host-only application cookie.
- Multiple product deployments for the same customer-environment (e.g. EAC + VMR) share the **customer database** and Identity directory, but keep separate App Registrations, deployments, and cookies unless a future ADR changes that.
- BreezeOn owns App Registrations; customer consent creates an Enterprise Application in the customer tenant.
- Internal platform registrations: **`BreezeOn-LOCAL`** (all local apps), **`BreezeOn-DEV`**, **`BreezeOn-UAT`**, **`BreezeOn-PRD`** when used for BreezeOn-operated shared environments.
- Multi-tenant access (e.g. BreezeOn + customer home tenants) is configured **in Entra** on the registration. No application `AUTHENTICATION__TENANTID` or `Identity.AllowedTenants`.
- Hosted secrets live in **Azure App Service application settings** until a future ADR supersedes that store.

## Consequences

- Naming and onboarding follow [cloud-architecture.md](../architecture/identity-and-authentication/cloud-architecture.md).
- Local work always uses `BreezeOn-LOCAL` and the same OIDC flow as hosted ([local-development-standard.md](../architecture/identity-and-authentication/local-development-standard.md)).
