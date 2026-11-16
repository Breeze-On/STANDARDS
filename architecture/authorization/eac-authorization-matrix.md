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

A user may hold Application and Business Entity administrator membership for different objects; rights do not cross domains. There is **no** current Application Configuration Administrator persona: `APPENA_*` groups exist for lifecycle ownership only and grant no authorization today ([ADR-015](../../decisions/ADR-015-object-owned-administrator-groups.md)).

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
| APPENA membership grants visibility / edit / page access | No (not evaluated today) | No | No | No |

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
- **APPENA:** Groups are lifecycle-owned security artifacts. Membership is GSA-managed but **not evaluated** by authorization (no visibility, edit, or page access). Application Configuration authorization is future work; revisit docs when that module ships. Do not invent Configuration capabilities here.
- Page vs data security: [authorization-standard.md](authorization-standard.md). Architecture: [ADR-015](../../decisions/ADR-015-object-owned-administrator-groups.md). Product surface: [architecture/eac.md](../eac.md).
