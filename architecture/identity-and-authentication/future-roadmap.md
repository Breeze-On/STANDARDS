<!-- Classification: AN; Scope: platform -->
# Future roadmap — Identity & Authentication

Owner: Architecture

## Planned / not shipped

The following are **not** part of the current platform implementation. Headings reserve structure only; do not treat as available APIs or product behaviour.

| Topic | Notes |
| --- | --- |
| Scheduled directory synchronization | Optional timer/host calling the same SHARED-UI synchronizer; Sync Now remains |
| Delta Graph synchronization / large-tenant scalability | **Future Validation** — `/users/delta` + cursor persistence when directory size/frequency justifies it; V1 remains full sync |
| Tenants administration UI | Replaces V1 SQL `IsSyncEnabled` onboarding step (**Master Flow Step 8 / Workflow F** — sole sync-enablement control point) |
| Automated onboarding validation job | Hosted health check evolving from [templates/onboarding/validate-onboarding-readiness.sql](../../templates/onboarding/validate-onboarding-readiness.sql) (schema, tid, sync, admin membership) |
| Self-service tenant onboarding / consent wizard | Customer-facing UX; requires Master Flow stabilization + ADR |
| Automated consent verification | Graph app-only token probe + Enterprise Application Graph APIs |
| Operational dashboard (per customer-environment readiness) | Cross-environment ops view; depends on observability standard + multi-env inventory |
| Hard onboarding feature gates | Optional “environment not ready” banners / flags — **must not** block OIDC login without a superseding ADR; prefer soft indicators |
| Azure Blob (or external) profile photo storage | **Future Validation** — migrate behind SHARED-UI photo APIs; `Identity.UserPhotos` already migration-ready (SQL VARBINARY login-time photos remain current) |
| `Department` / `JobTitle` / `ManagerExternalObjectId` on `Identity.Users` | Deferred until a business consumer exists |
| SCIM provisioning | Not designed |
| Role management / authorization beyond authenticated | Shipped as platform Security Groups + page security — see [authorization/](../authorization/README.md), [ADR-014](../../decisions/ADR-014-platform-authorization.md) |
| Entra group / claims mapping | Not designed |
| Application Context–scoped permissions | Future; hang off `ApplicationEnabledGUID` ([ADR-006](../../decisions/ADR-006-application-context-ownership.md)) |
| Certificate-based App Registration credentials | Not designed; secrets remain current ([configuration-standard.md](configuration-standard.md)) |
| Microsoft.Identity.Web for delegated Graph | Optional future layer beside cookie auth |
| Key Vault for `AUTHENTICATION__*` | Would require a superseding ADR; App Service settings remain approved |
| External Data Protection key ring (Blob / Redis) | Needed only for slot-independent keys or non–App Service farms; would require a superseding ADR |
| Cross-app SSO productization | Products in a customer-environment already **share one App Registration** ([cloud-architecture.md](cloud-architecture.md), [ADR-011](../../decisions/ADR-011-app-registration-per-customer-environment.md)), which enables Entra-level silent re-auth. Shared Identity directory and shared ClientId are still **not** a shared application cookie. Separate product hosts keep separate `BreezeOn.Auth` cookies. Productized cross-app **application-cookie** / navigation SSO beyond shared library reuse is not shipped |

## Shipped (do not treat as future)

| Topic | Notes |
| --- | --- |
| Microsoft Graph full directory sync (manual Sync Now) | [directory-synchronization-standard.md](directory-synchronization-standard.md), [ADR-013](../../decisions/ADR-013-microsoft-graph-directory-synchronization.md) |
| Login-time profile photo refresh into `Identity.UserPhotos` (SQL bytes) | [identity-schema-standard.md](identity-schema-standard.md) |
| `Identity.Tenants` discovery + explicit `IsSyncEnabled` | Not a login allowlist |
| Mid-session `IsEnabled` revalidation (`IBoIdentitySessionGate`, 60s cache) | [session-management-standard.md](session-management-standard.md), [ADR-012](../../decisions/ADR-012-cookie-session-management.md) |
| Customer authentication onboarding runbook (Workflows A–F) | [customer-onboarding-authentication.md](../../runbooks/customer-onboarding-authentication.md) |
| Customer Onboarding Master Flow (end-to-end) | [customer-onboarding-master-flow.md](../../runbooks/customer-onboarding-master-flow.md) |
| Operator onboarding validation SQL pack | [templates/onboarding/](../../templates/onboarding/) |
| Soft onboarding readiness queries / EAC `/users` indicators | SHARED-UI `IBoOnboardingReadinessQueries` + EAC banner (read-only; does not block login) |

When any remaining item ships, update the relevant Identity & Authentication documents and ADR(s) in the **same change set**, and remove or narrow the corresponding row here.
