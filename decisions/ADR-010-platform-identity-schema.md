# ADR-010: Platform Identity schema

Status: Accepted

## Context

Users may authenticate into multiple Breeze On applications (EAC, future VMR, billing, etc.) without ever using EAC. Identity cannot be an EAC-only schema. ASP.NET Core Identity / `AspNet*` was removed and is not the directory model.

## Decision

- Platform schema **`Identity`** with tables **`Identity.Users`** and **`Identity.UsersLogins`**.
- Permanent identity key: **`(TenantId, ExternalObjectId)`** (Entra `tid` + `oid`). Email and UPN are attributes only.
- **SYSTEM-SHARED-UI** owns T-SQL definitions (`sql/identity/`) and the default SQL directory writer. SHARED-UI does **not** own a database.
- Each **application database** physically contains the tables. Products must not create competing identity masters.
- Login path: upsert user, set `LastLoginUtc`, insert login row via `IBoIdentityDirectory` (default SQL implementation); hosts only register a connection factory.
- These tables are **excepted** from ADR-005 mandatory transactional audit columns (directory / append-only login history).

## Consequences

- Adopting apps apply SHARED-UI Identity scripts into their local/hosted DB init order.
- Future Graph sync targets `Identity.Users` without changing the permanent key.
- Schema changes require SHARED-UI scripts + [identity-schema-standard.md](../architecture/identity-and-authentication/identity-schema-standard.md) + this ADR update in the same change set.
