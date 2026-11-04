# ADR-010: Platform Identity schema

Status: Accepted

## Context

Users may authenticate into multiple Breeze On applications (EAC, future VMR, billing, etc.) without ever using EAC. Identity cannot be an EAC-only schema. ASP.NET Core Identity / `AspNet*` was removed and is not the directory model.

Earlier wording described physical tables as living in “each application database.” The verified platform topology is **one customer database per customer-environment**, shared by all product applications in that environment.

## Decision

- Platform schema **`Identity`** with tables **`Identity.Users`** and **`Identity.UsersLogins`**.
- Permanent identity key: **`(TenantId, ExternalObjectId)`** (Entra `tid` + `oid`). Email and UPN are attributes only.
- **SYSTEM-SHARED-UI** owns T-SQL definitions (`sql/identity/`) and the default SQL directory writer. SHARED-UI does **not** own a database.
- Physical tables live in the **customer database** (shared by EAC, VMR, and other products for that customer-environment). Products must not create competing identity masters or a second Identity catalog for the same customer.
- `UsersId` is shared across applications within that customer database. Different customers have independent directories; the same Entra identity may map to separate rows across customers.
- Login path: upsert user, enforce `IsEnabled` (disabled users do not receive a cookie), set `LastLoginUtc` and insert login row when enabled via `IBoIdentityDirectory` (default SQL implementation); hosts only register a connection factory to the customer database.
- Concurrent first logins are serialized with `UPDLOCK, HOLDLOCK` plus the unique `(TenantId, ExternalObjectId)` constraint.
- These tables are **excepted** from ADR-005 mandatory transactional audit columns (directory / append-only login history).

## Consequences

- Adopting apps apply SHARED-UI Identity scripts idempotently into the customer DB init/deploy order.
- Future Graph sync targets `Identity.Users` without changing the permanent key.
- Schema changes require SHARED-UI scripts + [identity-schema-standard.md](../architecture/identity-and-authentication/identity-schema-standard.md) + this ADR update in the same change set.
- Cookie/session behaviour remains per product host ([ADR-012](ADR-012-cookie-session-management.md)); shared Identity ≠ cross-app SSO cookie.
