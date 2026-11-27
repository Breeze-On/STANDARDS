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

Org-owned repositories live under `Breeze-On/…`.

### Repository name format (enforced)

| Rule | Contract |
| --- | --- |
| Case | **lowercase only** |
| Separators | **kebab-case only** (hyphen-separated segments) |
| Forbidden | SCREAMING_CASE, PascalCase, underscores, spaces, mixed case |

Examples (valid): `breezeon-corp-fin-inv`, `breezeon-system-admin-eac`, `breezeon-system-shared-ui`, `breezeon-system-process-engine`, `standards`.

Examples (invalid): `SYSTEM-ADMIN-EAC`, `BREEZEON-SYSTEM-PROCESS-ENGINE`, `SystemSharedUi`, `breezeon_corp_fin_inv`.

### Repository prefix (not enforced by naming)

A leading `breezeon-` segment is **ownership / product branding**, not part of the casing standard.

- Many Breeze On product and platform repositories **happen to** use a `breezeon-` prefix because they are Breeze On–owned.
- The naming standard does **not** require every future repository to start with `breezeon-`.
- Prefixes (or their absence) are chosen from ownership and branding; **format** (lowercase kebab-case) is what the naming standard enforces.

Examples of valid names **without** a `breezeon-` prefix: `standards`, and GitHub’s required org-profile repo name `.github` (literal GitHub convention; not kebab-caseable).

### Established repositories (standard names)

| Standard repository name | Kind | Notes |
| --- | --- | --- |
| `standards` | Org standards | Architecture + `docs/` SSOT |
| `.github` | Org profile | GitHub-required name |
| `breezeon-system-admin-eac` | Application | EAC (`BreezeOn.Eac`) |
| `breezeon-system-shared-ui` | Shared library | `BreezeOn.UI` |
| `breezeon-system-process-engine` | Shared library | `BreezeOn.ProcessEngine` |
| `breezeon-corp-fin-inv` | Application | INV (`BreezeOn.CorpFinInv`) — already matches the format |

Do not invent repositories using SCREAMING_CASE, PascalCase, underscores, or mixed case.

## Applications (code)

| Application / library | Repository (standard name) | Project / namespace |
| --- | --- | --- |
| EAC | `breezeon-system-admin-eac` | `BreezeOn.Eac` |
| INV | `breezeon-corp-fin-inv` | `BreezeOn.CorpFinInv` |
| Shared UI | `breezeon-system-shared-ui` | `BreezeOn.UI` |
| Process Engine | `breezeon-system-process-engine` | `BreezeOn.ProcessEngine` |

C# namespaces remain `BreezeOn.*` (PascalCase) — distinct from **GitHub repository** naming.

## Application technical identifiers

| Concept | Rule | Examples |
| --- | --- | --- |
| Repository name | GitHub technical id — **lowercase kebab-case** (this file § Repositories) | `breezeon-system-admin-eac`, `breezeon-corp-fin-inv` |
| `UniqueCode` | `repositoryName.ToUpperInvariant()` for EAC registry storage — must not diverge from the repository name ([application-definition.schema.json](ai/application-definition.schema.json)) | `BREEZEON-breezeon-system-admin-eac`, `BREEZEON-CORP-FIN-INV` |
| `Code` | Short business identifier for the application | `EAC`, `HRM`, `AP` |
| `ApplicationGUID` | Immutable relationship key (see [database.md](database.md)) | generated GUID string |

Do not invent alternate technical ids that diverge from the repository name without an explicit org decision and STANDARDS update.

**Rename coupling:** changing a repository name changes `UniqueCode` (and often `{UniqueCode}` SQL schema names for product apps). Keep repository name and UniqueCode aligned (`UniqueCode` = `repositoryName.ToUpperInvariant()`).

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

## Process persistence columns

On `{UniqueCode}.Process` extension ([database.md](database.md) § Process table convention · [ADR-024](../decisions/ADR-024-platform-process-root.md) · [ADR-027](../decisions/ADR-027-request-number-and-sequence-allocation.md)):

| Column / suffix | Holds | Example |
| --- | --- | --- |
| `ProcessGUID` | Platform process identity from **`Global.Process`** (SQL-generated via `Global.P_POST_Process`; apps must not mint) | — |
| `SequenceTemplate` / `SequenceDisplay` / `Sequence` | Required sequence metadata **immediately after** `ProcessGUID` on `{UniqueCode}.Process` CREATE (never persist `RequestNumber` / `SequenceDigits`) | — |
| `*Code` | Data Entity row **Code** (never Description / GUID) — [using-data-entities.md](../architecture/data-entities/using-data-entities.md) | `SupplierCode` |
| `*UserGUID` | People Picker `UserGUID` | `InitiatorUserGUID` |

A flat field's typed property name = `FieldKey` = column name.

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
