# Authorization standard

Owner: Architecture

## Model

Platform authorization is based on **Security Groups** stored in `Security.Groups` / `Security.GroupsMembers`. Membership is keyed by **`UserGUID`** ([identity-schema-standard.md](../identity-and-authentication/identity-schema-standard.md)).

Platform group Codes (Phase 1):

| Code | Purpose |
| --- | --- |
| `GLOBAL-SYSTEM-ADMINISTRATORS` | EAC Users Security, Sync Now, and other platform admin surfaces |

## `IBoAuthorizationService`

SHARED-UI owns **`IBoAuthorizationService`**. Products must not implement parallel group-check helpers.

| Capability | Behavior |
| --- | --- |
| Resolve group Codes for a `UserGUID` | SQL read with short TTL cache |
| `IsInGroupAsync` | Membership test |
| `CanAccessPageAsync` | Page catalog `RequiredGroupCodes` vs membership (empty ⇒ any authenticated) |
| Invalidation | After membership changes; TTL aligned with session gate (~60s) |

Future capabilities (app-scoped permissions, business-entity permissions) evolve **behind the same abstraction**.

## Evaluation

Hybrid: load memberships by `UserGUID` (login and/or first check), cache in-process with short TTL, evaluate page access in memory. **Do not** round-trip the database on every Blazor page render.

## Page vs data security

| Concern | Owner | Where |
| --- | --- | --- |
| Page security | Platform (`IBoAuthorizationService` + page catalog) | Nav, Home, route, Access Denied |
| Data security | Product / domain | Stored procedures, retrieval contracts, EF filters |

Passing page security does not imply unrestricted data access.

## Related

- [Security schema standard](security-schema-standard.md)
- [Page security standard](page-security-standard.md)
- [ADR-014](../../decisions/ADR-014-platform-authorization.md)
