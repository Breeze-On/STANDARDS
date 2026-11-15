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
| Resolve group Codes for a `UserGUID` | SQL read with short TTL cache (~60s; `SqlBoAuthorizationService.CacheTtl`) |
| `IsInGroupAsync` | Membership test |
| `CanAccessPageAsync` / `CanAccessRouteAsync` | Page catalog `RequiredGroupCodes` vs membership (empty ⇒ any authenticated; **unknown catalog key/route ⇒ deny**) |
| `EnsureInGroupAsync` | Privileged-write guard: invalidate cache, require group, throw `BoAuthorizationDeniedException` if denied |
| Invalidation | `InvalidateUser(UserGUID)` after membership add/remove |

Future capabilities (app-scoped permissions, business-entity permissions) evolve **behind the same abstraction**.

## Privileged writes (defense in depth)

Navigation / route checks (`BoAuthorizeRouteView`, nav filtering) are **necessary but not sufficient** for security-sensitive mutations. Before Sync Now, security-group create/update, and membership add/remove, products must call **`EnsureInGroupAsync`** for the actor `UserGUID` and the required group (today: `GLOBAL-SYSTEM-ADMINISTRATORS`).

Do **not** call `EnsureInGroupAsync` on every render or read path. Do **not** invent parallel product-local group checks.

Removing the last **enabled** `GLOBAL-SYSTEM-ADMINISTRATORS` member is rejected by SHARED-UI (`RemoveMemberAsync`) to prevent admin lockout.

## Evaluation

Hybrid: load memberships by `UserGUID` (login and/or first check), cache in-process with short TTL, evaluate page access in memory. **Do not** round-trip the database on every Blazor page render.

## Membership changes and authorization cache

When a user is added to or removed from a Security Group (for example via EAC **Manage Members**):

1. The membership row is **persisted immediately** to `Security.GroupsMembers`.
2. Authorization cache invalidation runs through the existing infrastructure (`IBoAuthorizationService.InvalidateUser` for the affected `UserGUID`) so the next authorization check on that process instance reloads group Codes from SQL.
3. **Existing authenticated sessions are not forcibly terminated.** Cookie/session validity is separate from authorization membership cache (session revocation follows Identity session-gate rules, not membership edits).
4. Permission changes become effective according to the current cache model: in-process TTL **~60 seconds**, with immediate effect on the same App Service instance after `InvalidateUser` for subsequent cache misses.
5. On multi-instance hosts, other instances may continue serving cached Codes until their local entry expires or is invalidated. **Delayed permission visibility is expected platform behavior, not a defect.** Administrators and support should not treat non-instantaneous page-access updates after membership edits as a bug when they fall within this model.

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
