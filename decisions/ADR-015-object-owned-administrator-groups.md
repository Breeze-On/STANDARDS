# ADR-015: Object-owned administrator groups (Applications & Business Entities)

Status: Accepted

## Context

[ADR-014](ADR-014-platform-authorization.md) established platform Security Groups, page catalogs, and `IBoAuthorizationService`. Phase 1 groups were platform-global (`GLOBAL-SYSTEM-ADMINISTRATORS` only). EAC Applications and Business Entities were visible to any authenticated user with no object-scoped data security.

EAC needs independent administrator groups per Application and per Business Entity, with clear separation of **business ownership** (object admins edit metadata), **security ownership** (GSA manages memberships and `GroupGUID`), and **platform ownership** (GSA manages lifecycle, Application Enabled, Entity Types).

## Decision

- Each **Application** and each **Business Entity** stores exactly one mandatory **`GroupGUID`** (`UNIQUEIDENTIFIER`) FK to `Security.Groups`. Groups do not require an Application or Business Entity.
- Administrator group Codes are system-generated at create: `APP_{UniqueCode}`, `BUSENT_{Code}`. Names/descriptions follow EAC provisioning conventions. **Metadata** on those groups is left empty. Group **Code** is a create-time snapshot and is **not** renamed when business codes change; `GroupGUID` is the stable link.
- **`Security.Groups.Code`** is **`NVARCHAR(700)`** with uniqueness on `Code` only (index-safe; no auth-driven caps on Application.UniqueCode or BusinessEntity.Code).
- **`Security.Groups.IsManuallyCreated`** (`BIT NOT NULL`, default `1`) is the first-class lifecycle ownership SSOT: `1` = Groups UI / manual workflows; `0` = automatically created (provisioning, GSA bootstrap, future system create). It is **not** derived from Code prefixes. `CreateGroupAsync` takes required `isManuallyCreated` independently of `allowSystemOwnedCode` (reserved-Code collision defense only).
- **Automatically created groups** (`IsManuallyCreated = 0`, including `GLOBAL-SYSTEM-ADMINISTRATORS`, `APP_*`, `BUSENT_*`) are system-owned: Code and Name immutable after create; Description/Metadata editable by GSA; **not** deletable via Groups UI/API. Object-owned admin groups are removed only by Application/BE delete SPs (dependents → object → members → group). **`GLOBAL-SYSTEM-ADMINISTRATORS` is never deleted** by any workflow. Manually created groups (`IsManuallyCreated = 1`) may be deleted by GSA. Reserve system Code prefixes against manual create as collision defense—not as ownership SSOT.
- **GSA only:** create/delete Applications and Business Entities; Application Enabled create/modify/remove; Entity Types; assign `GroupGUID` at provisioning; Manage Members on automatically created groups.
- **Application / Business Entity Administrators:** scoped view + edit of **business metadata** only; view enablements in their page context; **not** delete, membership, `GroupGUID` reassignment, or enablement mutation. For Business Entities, membership on an entity’s admin group also grants view + metadata edit on **all descendants**; **ancestors** remain visible as navigation context with `CanManage = 0`.
- **Data security** is enforced in EAC stored procedures / retrieval contracts with `@UserGUID` (GSA bypass or membership on object `GroupGUID`). Business Entity hierarchy: authorized entities and their **descendants** have `CanManage = 1`; **ancestors** are visible with `CanManage = 0` unless also authorized/descendant. Write guards re-check membership on the target or any ancestor `GroupGUID`. This is **not** SQL Server ROW LEVEL SECURITY.
- Page catalog routes `/applications` and `/business-entities` stay any-authenticated; empty authorized set for a non-GSA yields Access Denied. Entity Types tab is Access Denied for non-GSA.
- Central **provisioning** creates/reuses the admin group then persists `GroupGUID` (UI, JSON import, seed, future API). Import reuses an existing group by Code without renaming, description overwrite, membership, or metadata changes. No auto-members.
- Delete order: dependents → object row(s) → group members → group.
- Normative capability matrix: [eac-authorization-matrix.md](../architecture/authorization/eac-authorization-matrix.md).

## Consequences

- SHARED-UI Security schema and EAC `System` tables/procs change in the same initiative; docs and ADR-014 are amended to point here for object scope.
- Application Context–scoped permissions beyond enablement **visibility** remain future work under [ADR-006](ADR-006-application-context-ownership.md).
- Empty admin groups are valid until GSA assigns members.

## Related

- [ADR-014](ADR-014-platform-authorization.md)
- [authorization-standard.md](../architecture/authorization/authorization-standard.md)
- [eac-authorization-matrix.md](../architecture/authorization/eac-authorization-matrix.md)
- [architecture/eac.md](../architecture/eac.md)
