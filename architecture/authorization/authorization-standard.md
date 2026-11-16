# Authorization standard

Owner: Architecture

## Model

Platform authorization is based on **Security Groups** stored in `Security.Groups` / `Security.GroupsMembers`. Membership is keyed by **`UserGUID`** ([identity-schema-standard.md](../identity-and-authentication/identity-schema-standard.md)).

Platform / system group Codes:

| Code / pattern | Purpose | Category |
| --- | --- | --- |
| `GLOBAL-SYSTEM-ADMINISTRATORS` | EAC Users Security, Sync Now, platform admin surfaces | Automatically created |
| `APP_{UniqueCode}` | Application administrator group (one per Application) | Automatically created |
| `BUSENT_{Code}` | Business Entity administrator group (one per Business Entity) | Automatically created |
| `APPENA_{UniqueCode}_{BusinessEntityCode}` | Application Enabled administrator group (lifecycle / future Configuration; **not evaluated by authorization today**) | Automatically created |
| (user-chosen) | Manually created groups for future scenarios | Manually created |

**Automatically created groups** are system-owned (`Security.Groups.IsManuallyCreated = 0`). Only Global System Administrators may add/remove membership for them. They cannot be deleted from the Groups UI/API; object-owned admin groups are deleted only with their Application / Business Entity / Application Enabled; **`GLOBAL-SYSTEM-ADMINISTRATORS` is never deleted**. Code and Name are immutable; Description/Metadata remain editable. Manually created groups (`IsManuallyCreated = 1`) may be deleted by GSA. Ownership is assigned explicitly on create (`CreateGroupAsync(..., isManuallyCreated: …)`); it is not inferred from reserved-Code allowance. Object-scoped Application / Business Entity / Application Enabled ownership: [ADR-015](../../decisions/ADR-015-object-owned-administrator-groups.md), [eac-authorization-matrix.md](eac-authorization-matrix.md). APPENA membership grants no page access or data visibility today.

## `IBoAuthorizationService`

SHARED-UI owns **`IBoAuthorizationService`**. Products must not implement parallel group-check helpers.

| Capability | Behavior |
| --- | --- |
| Resolve group Codes for a `UserGUID` | SQL read with short TTL cache (~60s; `SqlBoAuthorizationService.CacheTtl`) |
| `IsInGroupAsync` | Membership test |
| `CanAccessPageAsync` / `CanAccessRouteAsync` | Page catalog `RequiredGroupCodes` vs membership (empty ⇒ any authenticated; **unknown catalog key/route ⇒ deny**) |
| `EnsureInGroupAsync` | Privileged-write guard: invalidate cache, require group, throw `BoAuthorizationDeniedException` if denied |
| Invalidation | `InvalidateUser(UserGUID)` after membership add/remove |

Object-owned Application / Business Entity administrator groups use membership on each object’s `GroupGUID` for **data security** (product SPs). Page catalog evaluation remains Code-based via this service. Application Context–scoped permissions beyond enablement visibility remain future work under [ADR-006](../../decisions/ADR-006-application-context-ownership.md).

## Privileged writes (defense in depth)

Navigation / route checks (`BoAuthorizeRouteView`, nav filtering) are **necessary but not sufficient** for security-sensitive mutations. Before Sync Now, security-group create/update, membership add/remove on any group (including automatically created `APP_*` / `BUSENT_*` groups), Application/Business Entity create/delete, Application Enabled mutations, and Entity Types mutations, products must call **`EnsureInGroupAsync`** for the actor `UserGUID` and **`GLOBAL-SYSTEM-ADMINISTRATORS`**.

Object metadata edits (Application / Business Entity business fields) require GSA **or** membership in that object’s admin `GroupGUID` (product data-layer check)—not a substitute for inventing parallel page-security helpers. Business Entity edits also succeed when the actor is a member of an **ancestor** entity’s admin group (descendant manage inheritance; see [ADR-015](../../decisions/ADR-015-object-owned-administrator-groups.md)).

Do **not** call `EnsureInGroupAsync` on every render or read path. Do **not** invent parallel product-local group-check services outside `IBoAuthorizationService` for membership/page evaluation.

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
- [EAC authorization matrix](eac-authorization-matrix.md)
- [ADR-014](../../decisions/ADR-014-platform-authorization.md)
- [ADR-015](../../decisions/ADR-015-object-owned-administrator-groups.md)
