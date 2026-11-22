<!-- Classification: DEC; Scope: platform -->
# ADR-013: Microsoft Graph directory synchronization

Status: Accepted

## Context

Login-time upsert only creates `Identity.Users` for people who sign in. Business scenarios (approvers, assignments, employee search, organization directory) need the full customer Entra directory in the customer database. Interactive authentication remains Entra OIDC + cookies ([ADR-009](ADR-009-entra-oidc-cookie-authentication.md)). Graph must not replace that path.

## Decision

- **SYSTEM-SHARED-UI** owns Microsoft Graph directory synchronization, Graph client credentials usage, Identity directory sync writers, login-time profile photo refresh, and Identity user query helpers. EAC (and future products) consume these APIs; they do not reimplement Graph or Identity upsert SQL.
- Synchronization is **additive** to login-time provisioning. Permanent key remains `(TenantId, ExternalObjectId)` ([ADR-010](ADR-010-platform-identity-schema.md)).
- **V1 sync** is **manual Sync Now** only (first admin surface: EAC Users). No Azure Functions, WebJobs, Hangfire, or extra Azure infrastructure for sync.
- **V1 algorithm** is a **full** Graph user enumeration (paged `/users`). Delta sync (`/users/delta`, delta cursors) is deferred.
- Credentials use the **same** customer-environment App Registration ([ADR-011](ADR-011-app-registration-per-customer-environment.md)) with **application** permission `User.Read.All` and admin consent. Token authority is `https://login.microsoftonline.com/{tenantId}/.default` for the enabled sync tenant. No `AUTHENTICATION__TENANTID` env var.
- **`Identity.Tenants`** is a sync/metadata registry of observed Entra tids. It is **not** a login allowlist and must not recreate forbidden `Identity.AllowedTenants`. Login discovery upserts tenants but **never** sets `IsSyncEnabled`.
- Sync runs for **every** tenant with `IsSyncEnabled = 1` (sequentially). Zero enabled tenants → fail with a clear error. V1 enablement is a documented SQL onboarding step at **Master Flow Step 8 / Workflow F** (sole control point; Workflow G must not enable sync; no Tenants admin UI); local seed may enable all `IDENTITY__SEEDTENANTIDS` entries.
- Missing directory users after a successful full sync are **soft-disabled** (`IsEnabled = 0`), never deleted.
- **Profile photos** refresh on successful login only (not during directory sync). V1 stores bytes in `Identity.UserPhotos` (`VARBINARY(MAX)`, `StorageProvider = Sql`). Failure never blocks login; prior photo is kept. Schema is migration-ready for a future Azure Blob (or other) store behind SHARED-UI photo APIs.
- **Deferred from V1 schema:** `Department`, `JobTitle`, `ManagerExternalObjectId` (no consumer yet).
- **Authorization:** Users Security and Sync Now require `GLOBAL-SYSTEM-ADMINISTRATORS` ([ADR-014](ADR-014-platform-authorization.md)).
- Org attributes and delta/scheduling/Tenants UI/Blob photos/authZ remain future; Sync Now remains when scheduling is added.

## Consequences

- Identity schema expands with `Identity.Tenants` and `Identity.UserPhotos`; ADR-010 and [identity-schema-standard.md](../architecture/identity-and-authentication/identity-schema-standard.md) update in the same change set.
- [future-roadmap.md](../architecture/identity-and-authentication/future-roadmap.md) removes shipped Graph sync / login photos from “not shipped” and lists deferred items (delta, schedule, Blob, Tenants UI, authZ, org attributes).
- Customer onboarding Phase 2 (application consent + explicit `IsSyncEnabled` SQL): [customer-onboarding-authentication.md](../runbooks/customer-onboarding-authentication.md).
- Cookie login path stays OIDC + cookies; Graph is app-only for sync and login photo.

## Amendment — targeted UPN upsert for local bootstrap (2026-11-15)

Full Sync Now remains the product directory sync. SHARED-UI also exposes `UpsertUsersByPrincipalNamesAsync` for **local tooling** (EAC `LocalDirectoryBootstrap`): resolve listed UPNs via Graph get-by-UPN, upsert those rows only, and **do not** soft-disable the rest of the tenant or mark a full sync as succeeded. Hosted onboarding still uses Workflow G (admins) then Workflow F / Sync Now as documented.
