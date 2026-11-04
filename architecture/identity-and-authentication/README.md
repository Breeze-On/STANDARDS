# Identity & Authentication

Owner: Architecture

**Start here** for Breeze On end-user authentication, Identity schema, App Registrations, tenant/hosting model, configuration, and local auth.

This is a **BreezeOn platform standard**. It applies to all current and future Breeze On applications unless a future ADR explicitly supersedes it. It is **not** an EAC-only design.

| Document type | Location |
| --- | --- |
| **What** (this tree) | `architecture/identity-and-authentication/` |
| **Why** | [ADR-009](../../decisions/ADR-009-entra-oidc-cookie-authentication.md), [ADR-010](../../decisions/ADR-010-platform-identity-schema.md), [ADR-011](../../decisions/ADR-011-app-registration-per-customer-environment.md), [ADR-012](../../decisions/ADR-012-cookie-session-management.md) |
| **How** (related) | [database.md](../../docs/database.md), [environments.md](../../docs/environments.md), [hosted-deployment.md](../../docs/hosted-deployment.md) |

## Index

| Document | Covers |
| --- | --- |
| [Business vision](business-vision.md) | SaaS hosting, customer Entra tenants, OIDC, shared platform capability |
| [Cloud architecture](cloud-architecture.md) | App Registration + product deployment per customer-environment; shared customer database |
| [Authentication standard](authentication-standard.md) | OIDC Authorization Code, SHARED-UI ownership, login/logout |
| [Session management standard](session-management-standard.md) | Cookie attributes, idle/absolute lifetimes, Data Protection hosting, logout vs Entra sign-out |
| [Identity schema standard](identity-schema-standard.md) | `Identity.Users` / `Identity.UsersLogins`, permanent key, customer-DB topology |
| [Configuration standard](configuration-standard.md) | `AUTHENTICATION__AUTHORITY` / `CLIENTID` / `CLIENTSECRET`; secret lifecycle |
| [Local development standard](local-development-standard.md) | `BreezeOn-LOCAL`, no bypass, same OIDC flow as hosted |
| [Future roadmap](future-roadmap.md) | **Planned / not shipped** — Graph, SCIM, roles, certificates, mid-session revoke, SSO |

SQL Managed Identity for Azure SQL is **orthogonal** and remains in [security.md](../security.md).

## Implementation ownership

| Concern | Owner |
| --- | --- |
| Authentication framework (OIDC + cookies + Identity directory writer) | [SYSTEM-SHARED-UI](https://github.com/Breeze-On/SYSTEM-SHARED-UI) (`BreezeOn.UI`) |
| Identity schema T-SQL definitions / seed placeholders | SYSTEM-SHARED-UI (`sql/identity/`) |
| Physical `Identity.*` tables | Customer database (shared by all products in that customer-environment) |
| First product host | EAC (`SYSTEM-ADMIN-EAC`) — consumes shared framework; does not own the platform standard |

## Definition of Done (mandatory)

Any change affecting authentication architecture, Identity schema, App Registration strategy, tenant strategy, authentication environment variables, local development authentication, session/cookie policy, or customer onboarding authentication **must** update this tree and related ADR(s) in the **same change set**. See [documentation.md](../../docs/documentation.md) § Definition of Done.
