# ADR-015: Object-owned administrator groups (Applications, Business Entities & Application Enabled)

Status: Accepted

## Context

[ADR-014](ADR-014-platform-authorization.md) established platform Security Groups, page catalogs, and `IBoAuthorizationService`. Phase 1 groups were platform-global (`GLOBAL-SYSTEM-ADMINISTRATORS` only). EAC Applications and Business Entities were visible to any authenticated user with no object-scoped data security.

EAC needs independent administrator groups per Application, per Business Entity, and per Application Enabled relationship, with clear separation of **business ownership** (object admins edit metadata), **security ownership** (GSA manages memberships and `GroupGUID`), and **platform ownership** (GSA manages lifecycle, Application Enabled create/delete, Entity Types).

## Decision

- Each **Application**, each **Business Entity**, and each **Application Enabled** row stores exactly one mandatory **`GroupGUID`** (`UNIQUEIDENTIFIER`) FK to `Security.Groups`. Groups do not require an Application, Business Entity, or Application Enabled row beyond that FK ownership.
- Administrator group Codes are system-generated at create: `APP_{UniqueCode}`, `BUSENT_{Code}`, `APPENA_{UniqueCode}_{BusinessEntityCode}`. Names/descriptions follow EAC provisioning conventions. **Metadata** on those groups is left empty. Group **Code** is a create-time snapshot and is **not** renamed when business codes change; `GroupGUID` is the stable link.
- **`Security.Groups.Code`** is **`NVARCHAR(700)`** with uniqueness on `Code` only (index-safe; no auth-driven caps on Application.UniqueCode or BusinessEntity.Code alone).
- **Application Enabled / APPENA length constraint (intentional platform limitation):** Application Enabled creation may fail if the generated APPENA administrator group code exceeds the maximum supported security group code length (`700`). This limitation is evaluated during Application Enabled creation because APPENA group creation is required as part of the lifecycle ownership model. A valid Application and valid Business Entity with individually valid codes can still fail to link when `LEN('APPENA_' + UniqueCode + '_' + BusinessEntityCode) > 700` (practical budget: UniqueCode + Business Entity Code ≤ 692). Failures must surface a clear error naming the cause and remediation (shorten UniqueCode and/or Business Entity Code)—not a generic failure.
- **`Security.Groups.IsManuallyCreated`** (`BIT NOT NULL`, default `1`) is the first-class lifecycle ownership SSOT: `1` = Groups UI / manual workflows; `0` = automatically created (provisioning, GSA bootstrap, future system create). It is **not** derived from Code prefixes. `CreateGroupAsync` takes required `isManuallyCreated` independently of `allowSystemOwnedCode` (reserved-Code collision defense only).
- **Automatically created groups** (`IsManuallyCreated = 0`, including `GLOBAL-SYSTEM-ADMINISTRATORS`, `APP_*`, `BUSENT_*`, `APPENA_*`) are system-owned: Code and Name immutable after create; Description/Metadata editable by GSA; **not** deletable via Groups UI/API. Object-owned admin groups are removed only by Application / Business Entity / Application Enabled delete SPs (dependents → object → members → group). **`GLOBAL-SYSTEM-ADMINISTRATORS` is never deleted** by any workflow. Manually created groups (`IsManuallyCreated = 1`) may be deleted by GSA. Reserve system Code prefixes against manual create as collision defense—not as ownership SSOT.
- **GSA only:** create/delete Applications and Business Entities; Application Enabled create/modify/remove; Entity Types; assign `GroupGUID` at provisioning; Manage Members on automatically created groups (including APPENA).
- **Application / Business Entity Administrators:** scoped view + edit of **business metadata** only (Application: UniqueCode / Code / Description / Metadata; Business Entity: Code / Description / Metadata); view enablements in their page context; **not** delete, membership, `GroupGUID` reassignment, enablement mutation, or (for Business Entities) Type / Parent changes — those remain GSA. For Business Entities, membership on an entity’s admin group also grants view + metadata edit on **all descendants**; **ancestors** remain visible as navigation context with `CanManage = 0` (not editable). Membership does not grant siblings or unrelated branches.
- **APPENA (Application Enabled administrator groups) — current state:** created and managed for lifecycle ownership and membership; **not evaluated by authorization logic** (no visibility, edit, page access, or data-filter effect). Existing Application / Business Entity authorization and page access are unchanged. **Future:** Application Configuration is expected to use APPENA memberships for visibility and edit; that behavior is out of scope here and **must be revisited when Application Configuration is implemented**.
- **Data security** is enforced in EAC stored procedures / retrieval contracts with `@UserGUID` (GSA bypass or membership on Application / Business Entity object `GroupGUID`). Business Entity hierarchy: authorized entities and their **descendants** have `CanManage = 1`; **ancestors** are visible with `CanManage = 0` unless also authorized/descendant. Write guards re-check membership on the target or any ancestor `GroupGUID`. This is **not** SQL Server ROW LEVEL SECURITY. APPENA membership is not used in those filters today.
- Page catalog routes `/applications` and `/business-entities` stay any-authenticated; empty authorized set for a non-GSA yields Access Denied. Entity Types tab is Access Denied for non-GSA.
- Central **provisioning** creates/reuses the admin group then persists `GroupGUID` (UI, JSON import, seed, future API). Import reuses an existing group by Code without renaming, description overwrite, membership, or metadata changes. No auto-members.
- Delete order: dependents → object row(s) → group members → group. Application Enabled delete: future AE dependents → capture GroupGUID → DELETE enablement → members → APPENA group.
- Normative capability matrix: [eac-authorization-matrix.md](../architecture/authorization/eac-authorization-matrix.md).

## Consequences

- SHARED-UI Security schema and EAC `System` tables/procs change in the same initiative; docs and ADR-014 are amended to point here for object scope.
- Application Context–scoped permissions beyond enablement **visibility** remain future work under [ADR-006](ADR-006-application-context-ownership.md); APPENA is the reserved ownership hook for that future Configuration security review.
- Empty admin groups are valid until GSA assigns members.

## Related

- [ADR-014](ADR-014-platform-authorization.md)
- [ADR-006](ADR-006-application-context-ownership.md)
- [authorization-standard.md](../architecture/authorization/authorization-standard.md)
- [eac-authorization-matrix.md](../architecture/authorization/eac-authorization-matrix.md)
- [architecture/eac.md](../architecture/eac.md)
