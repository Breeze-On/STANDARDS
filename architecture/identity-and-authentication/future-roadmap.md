# Future roadmap — Identity & Authentication

Owner: Architecture

## Planned / not shipped

The following are **not** part of the current platform implementation. Headings reserve structure only; do not treat as available APIs or product behaviour.

| Topic | Notes |
| --- | --- |
| Scheduled directory synchronization | Optional timer/host calling the same SHARED-UI synchronizer; Sync Now remains |
| Delta Graph synchronization | `/users/delta` + cursor persistence when directory size/frequency justifies it |
| Tenants administration UI | Replaces V1 SQL `IsSyncEnabled` onboarding step |
| Azure Blob (or external) profile photo storage | Migrate behind SHARED-UI photo APIs; `Identity.UserPhotos` already migration-ready |
| `Department` / `JobTitle` / `ManagerExternalObjectId` on `Identity.Users` | Deferred until a business consumer exists |
| SCIM provisioning | Not designed |
| Role management / authorization beyond authenticated | Not designed (Users / Sync Now are any-authenticated in V1) |
| Entra group / claims mapping | Not designed |
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
| Customer authentication onboarding runbook | [customer-onboarding-authentication.md](customer-onboarding-authentication.md) |

When any remaining item ships, update the relevant Identity & Authentication documents and ADR(s) in the **same change set**, and remove or narrow the corresponding row here.
