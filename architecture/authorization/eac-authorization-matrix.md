# EAC authorization matrix

Owner: Architecture

Capability × persona for Enterprise Administration Center (Applications, Business Entities, Application Enabled, groups). Normative companion to [ADR-015](../../decisions/ADR-015-object-owned-administrator-groups.md).

## Ownership model

| Concern | Owner | Meaning |
| --- | --- | --- |
| **Business ownership** | Application Administrator / Business Entity Administrator | View and edit business metadata on authorized objects |
| **Security ownership** | Global System Administrator | Group membership, `GroupGUID`, automatically created groups |
| **Platform ownership** | Global System Administrator | Create/delete objects, Application Enabled, Entity Types, Users/Groups admin |

## Personas

| Persona | Meaning |
| --- | --- |
| **Global System Administrator (GSA)** | Member of `GLOBAL-SYSTEM-ADMINISTRATORS` |
| **Application Administrator** | Member of that Application’s associated `APP_*` group only (not a global role) |
| **Business Entity Administrator** | Member of that Business Entity’s associated `BUSENT_*` group only |
| **Authenticated user** | Signed in, not in the relevant admin groups |

A user may hold Application and Business Entity administrator membership for different objects; rights do not cross domains. There is **no** separate Application Configuration Administrator persona name, but `APPENA_*` membership **is** evaluated for **Application Configuration selector visibility** (Path C). Applications and Business Entities page filters still ignore APPENA ([ADR-015](../../decisions/ADR-015-object-owned-administrator-groups.md)).

## Legend

| Value | Meaning |
| --- | --- |
| **Yes** | Allowed |
| **No** | Denied |
| **Scoped** | Only for objects whose admin `GroupGUID` includes the user (direct membership) |
| **Ancestor** | Parent (or higher) of an authorized entity: visible for navigation only; not editable |
| **Descendant** | Child (or deeper) of an authorized Business Entity: visible and editable (`CanManage`) |
| **CanManage** | Row may be edited for allowed business metadata fields (see Notes) |
| **View-context** | Read-only within that page context |

## Applications

| Capability | GSA | Application Administrator | Business Entity Administrator | Authenticated (no admin groups) |
| --- | --- | --- | --- | --- |
| Open Applications page | Yes | Yes if ≥1 app else Access Denied | Access Denied if no app membership | Access Denied if zero apps |
| View Application | Yes (all) | Scoped | No | No |
| Edit Application business metadata (UniqueCode, Code, Description, Metadata) | Yes | Scoped | No | No |
| Create Application | Yes | No | No | No |
| Delete Application | Yes | No | No | No |
| Reassign GroupGUID | Yes (provisioning/lifecycle only) | No | No | No |
| View Application Enabled (Application context) | Yes | View-context (scoped apps) | No | No |
| Modify Application Enabled (create/update/remove) | Yes | No | No | No |
| View Group Membership (`APP_*` via Manage Members) | Yes | No (action disabled) | No | No |
| Modify Group Membership (`APP_*`) | Yes | No | No | No |
| View Group Membership (`APPENA_*` via child-grid Manage Members) | Yes | No (action disabled) | No | No |
| Modify Group Membership (`APPENA_*`) | Yes | No | No | No |
| APPENA membership grants Applications/BE page visibility / edit / page access | No | No | No | No |
| APPENA membership grants App Configuration context visibility (selector Path C) | Yes (all contexts) | No (unless also APPENA member) | No (unless also APPENA member) | No (unless APPENA member) |

## Business Entities

| Capability | GSA | Application Administrator | Business Entity Administrator | Authenticated (no admin groups) |
| --- | --- | --- | --- | --- |
| Open BE Hierarchy | Yes | Access Denied if no BE membership | Yes if ≥1 BE else Access Denied | Access Denied if zero BEs |
| View Business Entity | Yes (all) | No | Scoped + Descendants + Ancestors (ancestors view-only) | No |
| Edit BE business metadata (Code, Description, Metadata) | Yes | No | Scoped + Descendants (`CanManage`); not Ancestors | No |
| Change BE Type / Parent | Yes | No | No | No |
| Create Business Entity | Yes | No | No | No |
| Delete Business Entity | Yes | No | No | No |
| Reassign GroupGUID | Yes (lifecycle/provisioning) | No | No | No |
| View Application Enabled (BE context) | Yes | No | View-context (scoped BEs) | No |
| Modify Application Enabled | Yes | No | No | No |
| View Group Membership (`BUSENT_*`) | Yes | No | No (action disabled) | No |
| Modify Group Membership (`BUSENT_*`) | Yes | No | No | No |
| Entity Types tab / manage types | Yes | Access Denied | Access Denied | Access Denied |

## Application Configuration

Selector visibility on `/app-configuration` is **not** Applications/BE page RLS. It is a grant-driven `VisibleContexts` projection (union), then Application / Business Entity dropdowns are distinct projections of that set (mutual filter within the set).

**Page route vs context visibility:** The catalog route remains any-authenticated (not a required-group gate). After `VisibleContexts` is computed, **zero contexts → standard `BoAccessDenied`** (same component as Applications/Business Entities empty authorized set). That is **context visibility**, not route authorization failure — empty selector / disabled Configuration chrome is intentionally not shown.

| Capability | GSA | Application Administrator | Business Entity Administrator | APPENA member (context only) | Authenticated |
| --- | --- | --- | --- | --- | --- |
| Open App Configuration route | Yes | Yes (authenticated) | Yes (authenticated) | Yes (authenticated) | Yes |
| See workspace (selectors / Configuration) | Yes if ≥1 context else Access Denied | Yes if ≥1 visible context else Access Denied | Yes if ≥1 visible context else Access Denied | Yes if ≥1 visible context else Access Denied | Access Denied if zero contexts |
| See all enablements for an administered Application (Path A) | Yes (all) | Scoped (that Application’s enablements) | No (unless also Path A/C) | No | No |
| See enablements under administered BE + descendants (Path B) | Yes (all) | No (unless also Path B/C) | Scoped + Descendants | No | No |
| See a single enablement via APPENA membership (Path C) | Yes (all) | No (unless also Path C) | No (unless also Path C) | That row only | No |
| Configure / persist / Import-Export files | No (layout only today) | No | No | No | No |

## Platform / security

| Capability | GSA | Application Administrator | Business Entity Administrator | Authenticated |
| --- | --- | --- | --- | --- |
| Users / Groups (`/users`) | Yes | No | No | No |
| Edit group Code | No after create (all groups) | No | No | No |
| Edit group Name | Manual groups only (`IsManuallyCreated = 1`) | No | No | No |
| Edit group Description / Metadata | Yes | No | No | No |
| Delete manually created group | Yes | No | No | No |
| Delete automatically created group (Groups UI/API) | No | No | No | No |
| Delete `GLOBAL-SYSTEM-ADMINISTRATORS` | No (any path) | No | No | No |
| Modify membership of automatically created groups | Yes | No | No | No |
| Modify membership of manually created groups | Yes | No | No | No |

## Notes

- System group **Code** (`APP_*` / `BUSENT_*` / `APPENA_*`) is a create-time snapshot; editing Application UniqueCode or BE Code does not rename the group. **`GroupGUID`** remains the stable link. Reserved prefixes (create-time collision defense): [security-schema-standard.md](security-schema-standard.md).
- Empty administrator groups are valid until GSA assigns members.
- **Business Entity forest (current):** Membership on a BE admin group grants view + edit (`CanManage`) for that entity and **all descendants**. **Ancestors** of authorized entities are visible for navigation only (not editable). Membership does **not** grant siblings or unrelated branches.
- **Business Entity administrators** may edit Code / Description / Metadata on `CanManage` rows. They may **not** change Type, Parent, Application Enabled relationships, or security membership / `GroupGUID`. Those remain GSA.
- **APPENA:** Groups remain lifecycle-owned security artifacts (GSA manages membership). Membership is **not** used by Applications or Business Entities page filters. On **Application Configuration** (`/app-configuration`), selector visibility is a **grant-driven** union of: (A) Application `APP_*` → all enablements for that Application; (B) Business Entity `BUSENT_*` → enablements on that BE and **descendants**; (C) Application Enabled `APPENA_*` → that enablement row only. Construction resolves grants first, expands BE descendants once, then set-queries matching `EACApplicationsEnabled` rows (do not scan all enablement rows for per-row permission checks). **Requires at least one visible Application Enabled context**; `VisibleContexts.Count == 0` → standard Access Denied (not empty dropdowns). **Data Entities:** create definitions and **Change Order** (SortOrder rewrite) require GSA or Application object admin (`APP_*` / `EnsureCanManageObjectAsync` on Application `GroupGUID`). Unauthorized users see Quick Actions **disabled**. Listing definitions is available whenever the Application is visible via `VisibleContexts`. Other configuration edit capabilities remain future work. Platform: [data-entities](../data-entities/README.md) · [ADR-016](../../decisions/ADR-016-data-entity-ownership.md).
- Page vs data security: [authorization-standard.md](authorization-standard.md). Architecture: [ADR-015](../../decisions/ADR-015-object-owned-administrator-groups.md). Product surface: [architecture/eac.md](../eac.md).
