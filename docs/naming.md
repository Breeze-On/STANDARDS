<!-- Classification: AA; Scope: platform; Domain: Engineering; Capability: Naming -->
# Naming standards

Owner: Documentation

Current conventions across the organization.

## Organization

| Use | Form |
| --- | --- |
| Display name | **Breeze On** |
| GitHub org login | `Breeze-On` |
| Code / namespaces | `BreezeOn` (no space, no hyphen) |

## Repositories

- Org-owned repos under `Breeze-On/…`.
- Established repos:
  - `STANDARDS` — organization standards (`docs/`) and current architecture (`architecture/`)
  - `.github` — org profile README
  - `SYSTEM-ADMIN-EAC` — EAC application (Enterprise Administration Center)
  - `SYSTEM-SHARED-UI` — shared Blazor UI library (`BreezeOn.UI`)

## Applications (code)

| Application / library | Repo | Project / namespace |
| --- | --- | --- |
| EAC | `SYSTEM-ADMIN-EAC` | `BreezeOn.Eac` |
| INV | `breezeon-corp-fin-inv` | `BreezeOn.CorpFinInv` |
| Shared UI | `SYSTEM-SHARED-UI` | `BreezeOn.UI` |

## Application technical identifiers

| Concept | Rule | Examples |
| --- | --- | --- |
| Repository name | The application’s **technical identifier** in GitHub (case as created) | `SYSTEM-ADMIN-EAC`, `breezeon-corp-fin-inv` |
| `UniqueCode` | `repositoryName.ToUpperInvariant()` for EAC registry storage — must not diverge from the repository name ([application-definition.schema.json](ai/application-definition.schema.json)) | `SYSTEM-ADMIN-EAC`, `BREEZEON-CORP-FIN-INV` |
| `Code` | Short business identifier for the application | `EAC`, `HRM`, `AP` |
| `ApplicationGUID` | Immutable relationship key (see [database.md](database.md)) | generated GUID string |

Do not invent alternate technical ids that diverge from the repository name without an explicit org decision and STANDARDS update.

## Database primary keys

**Format:** `TableName` + `Id` (the full table name stem, then `Id`).

| Table | Primary key |
| --- | --- |
| `Users` | `UsersId` |
| `UsersLogins` | `UsersLoginsId` |
| `UserPhotos` | `UserPhotosId` |
| `Tenants` | `TenantsId` |
| `Groups` | `GroupsId` |
| `GroupsMembers` | `GroupsMembersId` |
| `EACApplications` | `EACApplicationsId` |

Integer `*Id` primary keys are **physical** clustered keys (storage / indexing). They are **not** logical relationship keys and must not be used as cross-product or authorization identifiers.

## Database GUID columns

**Format:** singular entity name + `GUID` (uppercase `GUID`).

| Correct | Incorrect |
| --- | --- |
| `UserGUID` | `UsersGuid`, `UsersGUID` |
| `UserLoginGUID` | `UsersLoginsGuid` |
| `UserPhotoGUID` | — |
| `TenantGUID` | `TenantsGUID` |
| `GroupGUID` | `GroupsGuid` |
| `GroupMemberGUID` | — |
| `ApplicationGUID` | `ApplicationsGUID` |
| `BusinessEntityGUID` | — |

**Canonical user identifier:** `UserGUID` is the BreezeOn platform user id. Hierarchy: Entra `(TenantId, ExternalObjectId)` → `UserGUID` → physical `UsersId`. Full rules: [database.md](database.md).

## Stored procedures

When used: `P_GET_` / `P_POST_` + friendly app **Code** (e.g. `EAC`) + PascalCase subject with **no spaces or underscores**. Separate delete procedures append `Delete` (e.g. `P_POST_EACBusinessEntityDelete`, not `…_Delete`). Full rules: [database.md](database.md) § Stored procedure naming.

## Environments (labels and Azure suffixes)

Hosted environment **labels** (docs, seed rules, GitHub Environments) are always **`DEV`**, **`UAT`**, and **`PRD`** (uppercase). Meaning: [environments.md](environments.md). Deploy binding: [hosted-deployment.md](hosted-deployment.md).

Azure **resource name** environment tokens are always lowercase **`dev`**, **`uat`**, and **`prd`**.

| Layer | DEV | UAT | PRD | Do not use |
| --- | --- | --- | --- | --- |
| Labels / GitHub Environments | `DEV` | `UAT` | `PRD` | `DV`, `PP`, `PR` |
| Azure name suffix / token | `dev` | `uat` | `prd` | `dv`, `pp`, `pr` |

Examples (pattern): App Service `breezeon-system-admin-eac-dev`; resource group `RG-BREEZEON-DEV`; SQL server hostname token `…-dev…`. New or recreated resources must follow this table. Do not introduce `…-dv` (or other legacy short forms) on new resources.

**Legacy physical names** that predate this rule (for example database `BreezeOnDV`) may remain until deliberately renamed; document them as current reality in architecture / product metadata, but do not copy the legacy token into new names.

Local sandbox database names stay `{Logical}Local` (for example `BreezeOnLocal`) — not an Azure hosted suffix.

## Documentation files

- `README.md` — humans
- `README_AI.md` — agents

Prefer clear, stable names. Do not rename established public identifiers without an explicit org decision.

Shared vocabulary beyond naming forms: [glossary.md](glossary.md).
