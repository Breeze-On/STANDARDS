<!-- Classification: AA; Scope: platform; Domain: Security; Capability: Authorization -->
# Authorization standard

Owner: Architecture

## Model

Platform authorization is based on **Security Groups** stored in `Security.Groups` / `Security.GroupsMembers`. Membership is keyed by **`UserGUID`** ([identity-schema-standard.md](../identity-and-authentication/identity-schema-standard.md)).

### Group Codes and ownership boundary

**Platform** owns the `Security` schema, SHARED-UI evaluation/mutation APIs, and the seed group `GLOBAL-SYSTEM-ADMINISTRATORS`.

**EAC** owns object-administrator naming and lifecycle for Applications, Business Entities, and Application Enabled (`APP_*` / `BUSENT_*` / `APPENA_*`), plus App Config Security Groups (`APPSG_*`). Other products are **not** required to adopt those Codes. Multi-app reuse of object-owned groups is undefined ([ADR-015](../../decisions/ADR-015-object-owned-administrator-groups.md); Future Validation).

| Code / pattern | Purpose | Category | Naming owner |
| --- | --- | --- | --- |
| `GLOBAL-SYSTEM-ADMINISTRATORS` | Users Security, Sync Now, platform admin surfaces | Automatically created (`IsManuallyCreated = 0`) | Platform |
| `APP_{UniqueCode}` | Application administrator group (one per Application) | Automatically created | EAC |
| `BUSENT_{Code}` | Business Entity administrator group (one per Business Entity) | Automatically created | EAC |
| `APPENA_{UniqueCode}_{BusinessEntityCode}` | Application Enabled administrator group (lifecycle; App Configuration selector visibility Path C; not used by Applications/BE page filters) | Automatically created | EAC |
| `APPSG_{…}` | EAC Application Configuration Security Group (linked via `EACSecurityGroups`) | **Configuration-owned** (`IsManuallyCreated = 0`); reserved Code prefix; deleted only with App Config | EAC |
| `EACSG_{…}` | Legacy reserved prefix (collision defense only) | Reserved | EAC (legacy) |
| (user-chosen) | Operator-created groups via Groups UI | Manually created | Product / operator |

**Do not confuse** platform `Security.Groups` administration (Users → Groups) with **App Config Security Groups** (`EACSecurityGroups` / `APPSG_*` under Application Configuration). The latter is an EAC business capability that still stores membership rows in `Security.GroupsMembers` but does **not** replace platform Groups administration ([eac-authorization-matrix.md](../applications/eac-authorization-matrix.md), EAC `db-model.md`).

**Automatically created / configuration-owned groups** use `Security.Groups.IsManuallyCreated = 0`. They cannot be deleted from the Groups UI/API. Object-owned admin groups (`APP_*` / `BUSENT_*` / `APPENA_*`) are deleted only with their Application / Business Entity / Application Enabled; **`GLOBAL-SYSTEM-ADMINISTRATORS` is never deleted**. **APPSG** is configuration-owned (`IsManuallyCreated = 0`) and follows **delete-with-config**: removing the `EACSecurityGroups` row (Save, sync, or Application Context delete) also removes linked memberships and the APPSG group. Code and Name are immutable via Groups UI for `IsManuallyCreated = 0` groups; Description/Metadata remain GSA-editable there. Manually created groups (`IsManuallyCreated = 1`) may be deleted by GSA. **Exceptions — APPSG via App Config:** (1) App Config may rewrite `Security.Groups.Code` when AttributeCode changes and may set portable **Name**; (2) Application Administrators may mutate APPSG membership **interactively and via bulk** (same `EnsureCanManageContextAsync` grant as members portability). Ownership is assigned explicitly on create (`CreateGroupAsync(..., isManuallyCreated: …)`); it is not inferred from reserved-Code allowance. Object-scoped Application / Business Entity / Application Enabled ownership: [ADR-015](../../decisions/ADR-015-object-owned-administrator-groups.md), [eac-authorization-matrix.md](../applications/eac-authorization-matrix.md). APPENA membership does not affect Applications/BE page filters; it contributes to Application Configuration context selector visibility (Path C) only.

## `IBoAuthorizationService`

SHARED-UI owns **`IBoAuthorizationService`** for **Code-based** membership and **page catalog** evaluation. Products must not invent parallel helpers for those concerns.

| Capability | Behavior |
| --- | --- |
| Resolve group Codes for a `UserGUID` | SQL read with short TTL cache (~60s; `SqlBoAuthorizationService.CacheTtl`) |
| `IsInGroupAsync` | Membership test by Code |
| `CanAccessPageAsync` / `CanAccessRouteAsync` | Page catalog `RequiredGroupCodes` vs membership (empty ⇒ any authenticated; **unknown catalog key/route ⇒ deny**, subject to longest-prefix route inheritance — [page-security-standard.md](page-security-standard.md)) |
| `EnsureInGroupAsync` | Privileged-write guard: invalidate cache, require group, throw `BoAuthorizationDeniedException` if denied |
| Invalidation | `InvalidateUser(UserGUID)` after membership add/remove |

### Dual evaluation paths (current)

| Path | Mechanism | Consistency |
| --- | --- | --- |
| Page security / Code membership | `IBoAuthorizationService` | In-process cache ~60s; `InvalidateUser` on same instance |
| Object-admin data security (Application / Business Entity `GroupGUID`) | Product data-layer membership checks (e.g. EAC `EnsureCanManageObjectAsync` / SQL `IsMemberAsync` by `GroupGUID`) | Immediate SQL read — **not** the Code TTL cache |

Passing page security does not imply unrestricted data access. A platform GroupGUID evaluation API on SHARED-UI is **not** shipped (Future Validation).

Application Context–scoped permissions beyond enablement visibility remain future work under [ADR-006](../../decisions/ADR-006-application-context-ownership.md).

## Privileged writes (defense in depth)

### Convention-based mutation APIs (accepted)

SHARED-UI **`IBoSecurityGroupQueries`** mutation methods (`CreateGroupAsync`, `UpdateGroupAsync`, `DeleteGroupAsync`, `AddMemberAsync`, `RemoveMemberAsync`, …) **do not** take an actor or enforce group membership. **Authorization enforcement is the responsibility of consuming applications.** Products must call `EnsureInGroupAsync` (or an equivalent product check) **before** invoking those APIs. This is an accepted platform design ([ADR-014](../../decisions/ADR-014-platform-authorization.md)) — SHARED-UI will **not** add actor-based enforcement to these APIs.

### Default platform rule

Navigation / route checks (`BoAuthorizeRouteView`, nav filtering) are **necessary but not sufficient** for security-sensitive mutations. Before Sync Now, security-group create/update, membership add/remove on automatically created groups (`GLOBAL-SYSTEM-ADMINISTRATORS`, `APP_*` / `BUSENT_*` / `APPENA_*`), Application/Business Entity create/delete, Application Enabled mutations, and Entity Types mutations, products must call **`EnsureInGroupAsync`** for the actor `UserGUID` and **`GLOBAL-SYSTEM-ADMINISTRATORS`**.

### Named EAC exception — App Config APPSG membership

EAC Application Configuration allows an **Application administrator** (`APP_*` / `EnsureCanManageContextAsync`) to add/remove members on **APPSG-linked** `Security.Groups` for that Application Enabled context — **both interactively** (Manage Members dialog) **and via bulk** members import/export (`P_POST_EACSecurityGroupMembersBulk`). Those paths do **not** use `EnsureInGroupAsync(…, GLOBAL-SYSTEM-ADMINISTRATORS)`. This is a **named exception** to the GSA-only Groups UI/API membership default; capability detail: [eac-authorization-matrix.md](../applications/eac-authorization-matrix.md), [data-portability.md](../../docs/data-portability.md).

Object metadata edits (Application / Business Entity allowed business fields) require GSA **or** membership in that object’s admin `GroupGUID` (product data-layer check)—not a substitute for inventing parallel page-security helpers. Business Entity metadata edits also succeed when the actor is a member of an **ancestor** entity’s admin group (descendant `CanManage` inheritance). Type, Parent, enablement relationships, and security assignments remain GSA-only. Capability detail: [eac-authorization-matrix.md](../applications/eac-authorization-matrix.md); architecture: [ADR-015](../../decisions/ADR-015-object-owned-administrator-groups.md).

Do **not** call `EnsureInGroupAsync` on every render or read path. Do **not** invent parallel product-local helpers for **Code-based page** evaluation outside `IBoAuthorizationService`.

### Last-GSA membership removal (coverage)

SHARED-UI `RemoveMemberAsync` rejects removing a membership when the target is an **enabled** user and they are the **last enabled** `GLOBAL-SYSTEM-ADMINISTRATORS` member (sequential in-app remove path). This is **not** a complete lockout-prevention system:

- Concurrent removals of two GSAs are not serialized.
- Directory sync / soft-disable can set the last GSA user’s `IsEnabled = 0` without this guard.
- Operator recovery: [Customer Onboarding Master Flow](../../runbooks/customer-onboarding-master-flow.md) Recovery appendix (break-glass / re-bootstrap).

## Evaluation

Hybrid: load memberships by `UserGUID` (login and/or first check), cache in-process with short TTL, evaluate page access in memory. **Do not** round-trip the database on every Blazor page render.

## Membership changes and authorization cache

When a user is added to or removed from a Security Group (for example via EAC **Manage Members**):

1. The membership row is **persisted immediately** to `Security.GroupsMembers`.
2. Authorization cache invalidation runs through the existing infrastructure (`IBoAuthorizationService.InvalidateUser` for the affected `UserGUID`) so the next authorization check on that process instance reloads group Codes from SQL.
3. **Existing authenticated sessions are not forcibly terminated.** Cookie/session validity is separate from authorization membership cache (session revocation follows Identity session-gate rules, not membership edits).
4. Permission changes become effective according to the current cache model: in-process TTL **~60 seconds**, with immediate effect on the same App Service instance after `InvalidateUser` for subsequent cache misses.
5. On multi-instance hosts, other instances may continue serving cached Codes until their local entry expires or is invalidated. **Delayed permission visibility is expected platform behavior, not a defect.** Administrators and support should not treat non-instantaneous page-access updates after membership edits as a bug when they fall within this model.
6. APPSG Code rewrites (AttributeCode sync) do not call `InvalidateUser` for all members; other instances may cache the previous Code until TTL expiry (APPSG Codes are not used in page catalogs today).

## Page vs data security

| Concern | Owner | Where |
| --- | --- | --- |
| Page security | Platform (`IBoAuthorizationService` + page catalog) | Nav, Home, route, Access Denied |
| Data security | Product / domain | Stored procedures, retrieval contracts, EF filters, GroupGUID membership checks |

Passing page security does not imply unrestricted data access.

## Related

- [Security schema standard](security-schema-standard.md)
- [Page security standard](page-security-standard.md)
- [EAC authorization matrix](../applications/eac-authorization-matrix.md)
- [ADR-014](../../decisions/ADR-014-platform-authorization.md)
- [ADR-015](../../decisions/ADR-015-object-owned-administrator-groups.md)
