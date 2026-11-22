<!-- Classification: DEC; Scope: platform -->
# ADR-010: Platform Identity schema

Status: Accepted

## Context

Users may authenticate into multiple Breeze On applications (EAC, future VMR, billing, etc.) without ever using EAC. Identity cannot be an EAC-only schema. ASP.NET Core Identity / `AspNet*` was removed and is not the directory model.

Earlier wording described physical tables as living in “each application database.” The verified platform topology is **one customer database per customer-environment**, shared by all product applications in that environment.

Directory synchronization and login-time profile photos require additional Identity tables beyond the original Users / UsersLogins pair ([ADR-013](ADR-013-microsoft-graph-directory-synchronization.md)).

Earlier wording treated `UsersId` as the shared cross-application identity reference. That is superseded: **`UserGUID` is the canonical BreezeOn platform user identifier**. Integer `UsersId` remains the physical primary key only. Logical relationships use GUID columns ([database.md](../docs/database.md), [naming.md](../docs/naming.md)).

## Decision

- Platform schema **`Identity`** with tables:
  - **`Identity.Users`** — authoritative user directory
  - **`Identity.UsersLogins`** — login history
  - **`Identity.Tenants`** — observed Entra tenant registry + sync enablement/status (not a login allowlist)
  - **`Identity.UserPhotos`** — profile photo storage (V1 SQL bytes; migration-ready for external object store)
- Authoritative Entra resolution key: **`(TenantId, ExternalObjectId)`** (Entra `tid` + `oid`). Email and UPN are attributes only.
- Canonical BreezeOn user identifier: **`UserGUID`**. Hierarchy: Entra `(TenantId, ExternalObjectId)` → `UserGUID` → physical `UsersId`.
- **Within a customer database:** cross-application references, authorization, and integrations that identify a user **must use `UserGUID`**, not `UsersId`.
- **Cross-environment portable payloads** (import/export files, local seed JSON): do **not** require environment-local `UserGUID`. Prefer Codes; when a user reference is unavoidable, use environment-stable Entra keys (`ExternalObjectId`, and `TenantId` when needed). See [data-portability.md](../docs/data-portability.md).
- Relationships:
  - `UsersLogins.UserGUID` → `Users.UserGUID`
  - `UserPhotos.UserGUID` → `Users.UserGUID` (1:1)
- `Identity.Tenants` shape: `TenantsId` (physical PK), `TenantGUID` (BreezeOn platform tenant id), `TenantId` (Entra `tid`, UNIQUE external key).
- GUID column naming: singular entity + `GUID` (e.g. `UserGUID`, `UserLoginGUID`, `UserPhotoGUID`, `TenantGUID`) — never plural stems such as `UsersGuid`.
- **SYSTEM-SHARED-UI** owns T-SQL definitions (`sql/identity/`), the default SQL directory writer, directory synchronizer, photo service, and user query helpers. SHARED-UI does **not** own a database.
- Physical tables live in the **customer database** (shared by EAC, VMR, and other products for that customer-environment). Products must not create competing identity masters or a second Identity catalog for the same customer.
- Login path: upsert user, enforce `IsEnabled` (disabled users do not receive a cookie), set `LastLoginUtc` and insert login row when enabled via `IBoIdentityDirectory` (default SQL implementation); discover `Identity.Tenants` without setting `IsSyncEnabled`; hosts only register a connection factory to the customer database.
- Concurrent first logins are serialized with `UPDLOCK, HOLDLOCK` plus the unique `(TenantId, ExternalObjectId)` constraint.
- These Identity tables are **excepted** from ADR-005 mandatory transactional audit columns (directory / login history / sync metadata / photo cache).
- `Department`, `JobTitle`, and `ManagerExternalObjectId` are **not** part of V1 Users schema (deferred until a business consumer exists).

## Consequences

- Adopting apps apply SHARED-UI Identity scripts into the customer DB init/deploy order.
- Graph sync targets `Identity.Users` without changing the permanent Entra resolution key ([ADR-013](ADR-013-microsoft-graph-directory-synchronization.md)).
- Schema changes require SHARED-UI scripts + [identity-schema-standard.md](../architecture/identity-and-authentication/identity-schema-standard.md) + this ADR update in the same change set.
- Cookie/session behaviour remains per product host ([ADR-012](ADR-012-cookie-session-management.md)); shared Identity ≠ cross-app SSO cookie.
- Platform authorization references users by `UserGUID` ([ADR-014](ADR-014-platform-authorization.md)).
