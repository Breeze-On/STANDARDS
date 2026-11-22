<!-- Classification: AA; Scope: platform -->
# Database standards

Owner: Engineering

Current conventions for relational databases in Breeze On applications.

## Platform

- **Engine:** Microsoft **SQL Server** / **Azure SQL** (Transact-SQL).
- Application `sql/current_model` scripts are authored in **T-SQL** for Azure SQL Database / SQL Server.
- Do not introduce a second relational engine for the same application without an explicit org decision and STANDARDS update.

## Local development

Routine local work uses a **SQL Server Docker sandbox** (not Azure SQL). Pattern, templates, and init expectations: [local-database.md](local-database.md). Starter files: [`templates/local-sql/`](../templates/local-sql/). Environment names: [environments.md](environments.md). Decision: [ADR-003](../decisions/ADR-003-azure-sql-with-local-docker-sql.md).

## Hosted Azure SQL (Managed Identity)

Data-owning apps on App Service use connection string **`SQLAzureConnection`** with `Authentication=Active Directory Managed Identity` ([architecture/security.md](../architecture/security.md), [hosted-deployment.md](hosted-deployment.md)).

**Required (SqlClient 7+ — do not skip):**

1. NuGet **`Microsoft.Data.SqlClient.Extensions.Azure`** (same major/minor as `Microsoft.Data.SqlClient`)
2. Register `ActiveDirectoryAuthenticationProvider` **before** any SQL open (including EF `Database.Migrate()`)

MI grant + connection string alone are **not** sufficient. Missing the extension crash-loops container startup and commonly surfaces as Free F1 **QuotaExceeded**.

## String columns (NVARCHAR)

- Use **NVARCHAR** for variable-length Unicode strings on all standard business columns.
- Do **not** use `VARCHAR` for those columns unless an explicit exception is documented for that column.
- Do **not** use `NVARCHAR(MAX)` as the default for ordinary business columns unless explicitly decided for that column.

### Default lengths

| Column kind | Default length | Rule |
| --- | --- | --- |
| **Code** (column named `Code`, or explicitly designated a code) | **30** | Unless a different length is specified for that column |
| **Non-Code** strings | **600** | Unless a different length is specified for that column |

**Documented Code length exceptions** (record also in the product `docs/db-model.md`):

| Table / column | Length | Reason |
| --- | --- | --- |
| `System.EACBusinessEntitiesTypes.Code` | **250** | Business entity type codes may be longer descriptive identifiers |
| `System.EACBusinessEntities.Code` | **250** | Hierarchy codes may include geographic / multi-segment business keys |

## Nullability (NOT NULL)

Apply `NOT NULL` when the **model requires a value** — not only for primary keys and GUID columns.

| Rule | Guidance |
| --- | --- |
| **Required by model** | Columns the application always writes and reads as present (flags, status, sort order, required codes, audit columns, most Identity/Security attributes) are **`NOT NULL`**. |
| **New natural / business keys** | New tables: natural keys that carry a **UNIQUE** constraint (e.g. `Code`, `UniqueCode`) should generally be **`NOT NULL`**. Prefer this over “nullable UNIQUE” (which allows a single NULL). |
| **Optional attributes** | Columns that are truly optional remain **NULL**-allowed; document intentional optionality in `docs/db-model.md`. |
| **Do not** | Do **not** use the obsolete rule “NOT NULL only on PK / GUID / audit.” That rule did not match platform practice. |

**Audit columns:** the four [mandatory audit columns](#mandatory-audit-columns) are always **`NOT NULL`**.

Tightening existing nullable natural keys on shipped tables is a **separate migration decision** (not automatic).

## Mandatory audit columns

Every **transactional business table** (tables that hold business records created and changed by users or application processes) must include these four columns:

| Column | Type | Nullability |
| --- | --- | --- |
| `CreatedBy` | `NVARCHAR(600)` | `NOT NULL` |
| `CreatedDate` | `DATETIME2` | `NOT NULL` |
| `LastUpdatedBy` | `NVARCHAR(600)` | `NOT NULL` |
| `LastUpdatedDate` | `DATETIME2` | `NOT NULL` |

Rules:

1. **Always `NOT NULL`.** These four columns follow the [Nullability](#nullability-not-null) “required by model” rule.
2. **Create** populates **all four** columns (`LastUpdatedBy` / `LastUpdatedDate` equal the created values on insert).
3. **Update** refreshes **only** `LastUpdatedBy` and `LastUpdatedDate`. `CreatedBy` and `CreatedDate` are never changed after insert.
4. **Actor** (`CreatedBy` / `LastUpdatedBy`) is the **logged-in user** (or other authenticated principal) when authentication exists.
5. **`LOCAL` actor stamp — intentional vs accidental:**
   - **Intentional:** Local Docker seed tools, App Configuration sync seed, and other **local-sandbox** callers may pass `@Actor = N'LOCAL'` (or rely on documented SP fallback) when no interactive user exists.
   - **Accidental:** Hosted / authenticated product paths must pass a real actor. Long-term direction is to **eliminate silent `LOCAL` fallback** in write SPs (reject null/blank `@Actor`) once callers are audited.
   - **Current EAC write SPs with silent fallback** (as of D03 remediation): `P_POST_EACApplicationConfigurationSync`, `P_POST_EACBusinessEntity`, `P_POST_EACBusinessEntityType`, `P_POST_EACDataEntities*`, `P_POST_EACDataEntity`, `P_POST_EACProcessMetadata*`, `P_POST_EACSecurityGroupsSave`, `P_POST_EACStep*`, `P_POST_EACVariablesSave`, `P_POST_EACVariableValuesSave`. Do not redesign these SPs in this change set; track removal of fallback as a follow-on.
6. **Migrations** that add these columns to an existing table must **backfill** existing rows first, then enforce `NOT NULL`.
7. **No exceptions** unless formally documented and approved for that table (record the exception in the product `docs/db-model.md` and, if it sets a pattern, an ADR).
8. Audit values are **system-managed**. They are not part of user-facing import/export file formats ([data-portability.md](data-portability.md)).

Decision record: [ADR-005](../decisions/ADR-005-mandatory-transactional-audit-columns.md). Product `sql/current_model/`, `docs/db-model.md`, and `sql/seed/` must reflect these columns in the same change set.

## Application data access

Platform doctrine reflects **shipped practice** (not “EF only”):

| Pattern | Use when |
| --- | --- |
| **EF Core `SaveChanges`** | Straightforward CRUD and simple filter catalogs; audit stamped by the application layer before save |
| **Stored procedures** | Bulk / JSON-set operations, multi-statement cascades, hierarchy retrieval, cycle checks, paging contracts (`@FiltersJson`), synchronizers, and other advanced business operations |

- Prefer EF for simple single-entity writes when no multi-statement or set logic is required.
- Prefer SPs when the operation is multi-statement, set-oriented, JSON-driven, hierarchical, or already established as the module’s write path (EAC `System.P_*` is the reference).
- Product `docs/db-model.md` should state which surfaces use EF vs SP and why for non-obvious cases.
- **Platform library SQL:** SYSTEM-SHARED-UI identity/authorization framework executes **parameterized** SQL against `Identity` / `Security` (and related platform tables). UI controls in `BreezeOn.UI` do **not** talk to SQL ([ADR-004](../decisions/ADR-004-breezeon-ui-abstraction-layer.md), [ADR-008](../decisions/ADR-008-query-driven-data-retrieval.md)).

### Stored procedure naming (when used)

When a product introduces stored procedures under the EAC-owned **`System`** schema (or another app schema), use:

**Pattern:** `P_GET_<AppCode><PascalName>` or `P_POST_<AppCode><PascalName>`

| Part | Rule |
| --- | --- |
| Prefix | `P_GET_` (read) or `P_POST_` (write / delete) — underscore only after `GET` / `POST` |
| App code | Friendly application code in capitals with no separators (e.g. **`EAC`**, **`HRM`**) immediately after the prefix |
| Name | PascalCase: capital letter on every word; **no spaces and no underscores** |
| Delete | Append **`Delete`** to the PascalCase name (not `_Delete`). Example: upsert `P_POST_EACBusinessEntity`, delete `P_POST_EACBusinessEntityDelete` |

| Kind | Example |
| --- | --- |
| **Read** | `System.P_GET_EACBusinessEntitiesHierarchy` |
| **Write (upsert)** | `System.P_POST_EACBusinessEntity` |
| **Delete** (when separate from upsert) | `System.P_POST_EACBusinessEntityDelete` |
| **Delete (types)** | `System.P_POST_EACBusinessEntityTypeDelete` |

Prefer one upsert POST plus a dedicated delete procedure when delete semantics differ (for example recursive hierarchy delete). Pass the audit actor as a parameter (for example `@Actor`) so procedures can stamp mandatory audit columns. Document each procedure in the product `docs/db-model.md`. Script file names should match the procedure name (e.g. `System.P_POST_EACBusinessEntityDelete.sql`).

### Platform Identity procedure (People Picker — one-off)

`Identity.P_GET_UsersComponentValues` (SYSTEM-SHARED-UI `sql/identity/current_model/`) is a **documented one-off** exception for the platform `BoPeoplePicker` control:

- Active users only (`IsEnabled = 1`); result projection does **not** include `IsEnabled`.
- Hard **TOP 100** (`@MaxItems` clamped 1..100).
- `@ExcludeUserGuids` / `@ResolveUserGuids`: **JSON array of GUID strings only** (no CSV / dual formats).
- Returns `UserGUID`, `DisplayName`, `Email`, `UserPrincipalName`, `DisplayText` — never `UsersId` as a selectable key.

Do **not** treat this name as the start of a `P_GET_*ComponentValues` family across schemas. Any future lookup procedure requires its own justified need (this section / [query-driven-retrieval.md](ui/controls/query-driven-retrieval.md)).

## Query-driven paged list stored procedures

Standard: [query-driven-retrieval.md](ui/controls/query-driven-retrieval.md) · [ADR-008](../decisions/ADR-008-query-driven-data-retrieval.md).

When a dataset is a filterable / sortable / paged list **and** a stored procedure is justified (a documented need, per [Application data access](#application-data-access)):

- **One primary retrieval contract per dataset.** The procedure returns the page of rows, `TotalCount`, Nested View children when hierarchical, and optional metadata.
- **Parameter pattern:**

| Parameter | Role |
| --- | --- |
| `@Keyword` | Free-text keyword filter |
| `@FiltersJson` | Typed filters (`In` / `Equals` / `Contains`) as JSON — see [FiltersJson schema](#filtersjson-schema) |
| `@PageNumber` / `@PageSize` | Pagination (applied **after** filter and sort) |
| `@SortColumn` / `@SortDirection` | Sort request |
| `@TotalCount` `OUTPUT` | Rows matching the filter before pagination |
| `@IncludeFilterMetadata` (optional / reserved) | Advanced only — filter metadata on **initial load**; most pages use EF FilterCatalog instead |

- **Pipeline:** Filter → Sort → Pagination.
- **Sort whitelist:** only known columns sort; an unknown `@SortColumn` / `@SortDirection` falls back to a **safe default** (never concatenated into SQL).
- **Do not default to a companion FilterOptions procedure.** Prefer EF Core / app-service **FilterCatalog** queries for simple distinct catalogs; `@IncludeFilterMetadata` only for advanced primary contracts.
- **Forbidden:** generic distinct-values procedures that take schema / table / column names.
- A documented need is still required to introduce **any** procedure; document it in the product `docs/db-model.md` (secondary contracts and exceptions need a recorded rationale).

### FiltersJson schema

Canonical JSON for `@FiltersJson`, aligned with `BoQueryFilter` / `BoQueryFilterOperator` in `BreezeOn.UI.Query`. **Host owns** serialization; the SP owns whitelist of `Field` values and safe SQL composition.

**Shape:** JSON array of objects:

| Property | Type | Meaning |
| --- | --- | --- |
| `Field` | string | Whitelisted filter field name (product-defined) |
| `Operator` | string | `In` \| `Equals` \| `Contains` (enum name) |
| `Values` | string array | One or more values; empty clauses are omitted by the host |

**Single filter (Equals):**

```json
[{ "Field": "Status", "Operator": "Equals", "Values": ["Active"] }]
```

**Multi-select (In):**

```json
[{ "Field": "Code", "Operator": "In", "Values": ["APP1", "APP2"] }]
```

**Multiple filters:**

```json
[
  { "Field": "Code", "Operator": "In", "Values": ["APP1", "APP2"] },
  { "Field": "Description", "Operator": "Contains", "Values": ["pay"] }
]
```

**SP expectations:** ignore or reject unknown `Field` / `Operator` per product contract (document in `docs/db-model.md`); never concatenate unchecked values into SQL. Keyword (`@Keyword`) is separate from `@FiltersJson`.

## Shared System schema ownership

- The SQL schema **`System`** holds platform administration / shared catalog tables owned by **EAC** (Enterprise Administration Center).
- Other applications **consume** those registry values (for example via `ApplicationGUID`); they must **not** fork duplicate application-catalog tables.
- Concrete table inventory lives in the EAC product [`docs/db-model.md`](https://github.com/Breeze-On/SYSTEM-ADMIN-EAC/blob/main/docs/db-model.md) and `sql/current_model/` — not in this file.

## Primary keys, GUID columns, and relationships

Standing platform rules (also summarized in [naming.md](naming.md)):

| Concept | Rule |
| --- | --- |
| **Primary key** | `TableName` + `Id` (e.g. `UsersId`, `GroupsMembersId`). Physical clustered key only. |
| **GUID column** | Singular entity + `GUID` (e.g. `UserGUID`, `GroupMemberGUID`). Never plural table stem (`UsersGuid` is forbidden). |
| **Logical relationships** | Use immutable GUID columns only (`UserGUID`, `GroupGUID`, `ApplicationGUID`, `BusinessEntityGUID`, `ApplicationEnabledGUID`, …). Integer `*Id` columns must not be used for logical relationships, cross-product contracts, authorization, or integrations. |
| **Canonical user id** | **`UserGUID`**. Hierarchy: Entra `(TenantId, ExternalObjectId)` → `UserGUID` → physical `UsersId`. |
| **User references — relational vs portable** | **Within a customer database:** authorization, FKs, and in-app contracts use **`UserGUID`**. **Cross-environment portable payloads** (import/export, seed JSON): do **not** require environment-local `UserGUID`; use Codes and, when a user reference is unavoidable, environment-stable Entra keys such as **`ExternalObjectId`** (and `TenantId` when needed). See [ADR-010](../decisions/ADR-010-platform-identity-schema.md), [data-portability.md](data-portability.md). |
| **Identity / Security GUID type** | `UNIQUEIDENTIFIER` (typically `NEWSEQUENTIALID()` default). |
| **EAC catalog GUID type (temporary)** | `NVARCHAR(600)` on EAC `System` catalog keys today. **Long-term direction:** converge to `UNIQUEIDENTIFIER` (same as Identity/Security). Do not invent a large migration program in day-to-day work; schedule convergence deliberately. Until then, treat values as **36-character upper-case `D` format** GUID strings (`XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX`) as generated by app/SP conventions. |
| **Canonical GUID string format (interim)** | When stored as `NVARCHAR`, use uppercase `Guid.ToString("D")` / `UPPER(CONVERT(NVARCHAR(36), …))`. Format CHECKs are optional Future Validation. |

## Platform Identity schema ownership

- The SQL schema **`Identity`** (`Identity.Users`, `Identity.UsersLogins`, `Identity.Tenants`, `Identity.UserPhotos`) is a **BreezeOn platform** directory model — not EAC-specific and not ASP.NET Core Identity / `AspNet*`.
- **Definitions** (T-SQL current model + local seed) are owned by **SYSTEM-SHARED-UI** (`sql/identity/`). SHARED-UI does not host a database.
- **Physical tables** live in the **customer database** (one catalog per customer-environment, shared by all product applications in that environment). Adopting apps apply the SHARED-UI scripts in local init / deploy order and must not fork competing user masters or create a second Identity catalog for the same customer.
- **Bootstrap / reset only:** Identity (and Security) `current_model` scripts are for **new database creation** or **full database reset** (e.g. local `dev-reset` that drops the database). They are **not** safe to DROP+CREATE re-apply on a **populated** customer database that has application FKs into `Identity` / `Security`. Hosted evolution uses **migration scripts** + [schema-version tracking](#platform-schema-evolution-hosted). Within a full reset, `Identity.Users` must still drop `Security.GroupsMembers` before `Users` (DROP dependents first).
- Authoritative Entra resolution key: `(TenantId, ExternalObjectId)`. Canonical BreezeOn user identifier: **`UserGUID`**. SSOT: [identity-schema-standard.md](../architecture/identity-and-authentication/identity-schema-standard.md), [ADR-010](../decisions/ADR-010-platform-identity-schema.md), [ADR-013](../decisions/ADR-013-microsoft-graph-directory-synchronization.md).

## Platform Security schema ownership

- The SQL schema **`Security`** (`Security.Groups`, `Security.GroupsMembers`) is the **BreezeOn platform** authorization store — not EAC-only business data.
- **Definitions** are owned by **SYSTEM-SHARED-UI** (`sql/security/`). Physical tables live in the customer database beside `Identity`.
- Relationships use `GroupGUID` and `UserGUID` only. SSOT: [architecture/authorization/](../architecture/authorization/README.md), [ADR-014](../decisions/ADR-014-platform-authorization.md), [ADR-015](../decisions/ADR-015-object-owned-administrator-groups.md).
- **`Security.Groups.Code`** is **`NVARCHAR(700)`** (documented column exception to the org Code default of 30) so system-generated Codes such as `APP_{UniqueCode}` fit without capping business UniqueCode fields; uniqueness is on Code only.

## Application registry identity columns

Conventions for registering applications in the EAC-owned catalog (column semantics are org-wide; physical table is EAC-owned):

| Column | Role |
| --- | --- |
| **ApplicationGUID** | Immutable relationship key between entities and across apps. Column name contains `GUID` → **NOT NULL**. Generate once on insert; **never** regenerate or overwrite on update. Prefer a **UNIQUE** constraint/index. |
| **UniqueCode** | Application **technical** identifier. Value follows the **GitHub repository name** (e.g. `SYSTEM-ADMIN-EAC`, `SYSTEM-HR-HRM`). Prefer a **UNIQUE** constraint/index. Length follows non-Code string defaults unless the product documents an exception. |
| **Code** | Short **business** identifier (e.g. `EAC`, `HRM`, `AP`). Length follows the **Code** default (**30**) unless documented otherwise. |

### Application Context identity

| Column / rule | Role |
| --- | --- |
| **ApplicationEnabledGUID** | Immutable canonical key for an Application Context (Application enabled for a Business Entity). `GUID` → **NOT NULL**. Generate once; never regenerate, reassign, or modify. Re-create after delete → new GUID; never reuse prior values. Prefer **UNIQUE**. |
| **Exclusivity** | Unique `(ApplicationGUID, BusinessEntityGUID)` is a **business rule**: many-to-many overall; a specific pair exists at most once. |
| **Ownership / deletion** | `ApplicationEnabledGUID` owns entity-specific application configuration. Delete via one centralized workflow that removes dependents then the enablement row (clean-data). See [ADR-006](../decisions/ADR-006-application-context-ownership.md). |

Repository ↔ identifier mapping: [naming.md](naming.md) § Application technical identifiers.

## Script layout (application repos)

Each application repository that owns database objects maintains SQL under:

```text
sql/
  current_model/          # Editable source of truth (executable T-SQL; one file per object)
  current_model.sql       # Committed consolidated reset script (regenerated from current_model/; never hand-edit)
  seed/                   # Required local-only sample data for local-ready testing (not for hosted envs by default)
  migration_scripts/      # Temporary deltas; clean up after applied
generated/                # Temporary local deploy copies (gitignored; produced by local scripts)
docs/
  db-model.md             # Human/agent-readable current DB model (required when the app owns SQL objects)
```

## Database Deployment Standard

Org rule for applications that own SQL objects (reference implementation: EAC):

1. **Source stays separated.** Tables, procedures, functions, views, schemas, etc. remain individual files under `sql/current_model/` for maintainability.
2. **Maintain a committed single-file reset script.** Every schema-owning app keeps **`sql/current_model.sql`**: the concatenation of ordered `sql/current_model/` sources. Regenerate it whenever sources or deploy order change; **never edit `sql/current_model.sql` by hand**. Commit it in the **same change set** as the source edits (for SSMS / review / one-file apply).
3. **Deploy through one consolidated script.** Local init / `dev-reset` regenerates the consolidated artifact (refreshing `sql/current_model.sql` and a gitignored `generated/current-model.sql` copy) and executes **one** `sqlcmd` against that file.
4. **Ordering is explicit.** Maintain a deterministic dependency-order list in the app’s local DB helpers whenever objects are added, removed, renamed, or reordered. **CREATE order** is dependency order (parents before children). **DROP order** inside each table script must remove **dependents first** within the **bootstrap/reset** graph (children before parents for objects in that reset set).
5. **Logging lists sources.** Generation must print (and embed in the consolidated header) which source files were included and in what order.
6. **`current_model` is not safe on populated hosted DBs.** See [Platform schema evolution (hosted)](#platform-schema-evolution-hosted).

### Definition of Done (schema change)

A database-object change is incomplete unless:

1. The object is implemented under `sql/current_model/` (and `docs/db-model.md` updated).
2. Deployment aggregation / ordering is updated if required.
3. **`sql/current_model.sql` is regenerated** from sources (never hand-patched) and included in the same change set.
4. Seed aggregation is updated if required (see Seed Maintenance Standard).
5. Product and STANDARDS documentation reflect current reality.

## Database Seed Maintenance Standard

1. **Seed sources may stay separated** under `sql/seed/` (T-SQL and/or portable JSON that local scripts compile to T-SQL).
2. **Seed deploy uses one consolidated script** (e.g. `generated/seed.sql`) executed once via `sqlcmd`.
3. **Any feature that introduces or changes seed data** must update seed sources **and** keep consolidated seed deployment valid in the **same change set**.

### `sql/current_model/` and `sql/current_model.sql`

- `sql/current_model/` represents the **current** database model only (editable SSOT).
- One script per table or discrete object.
- Each table script is authored as a full recreate (**drop dependents if they exist, drop if exists, then create**) for **new database creation** and **full database reset** only (local `dev-reset` that drops the database, or empty catalog bootstrap).
- **Do not** DROP+CREATE re-apply `current_model` (platform Identity/Security or product) against a **populated** hosted / customer database that already has cross-schema application FKs — that is **not** safe and is **not** idempotent in multi-schema reality.
- Include schema-creation scripts as needed (e.g. `00_schema_*.sql`).
- Use Transact-SQL idioms appropriate for Azure SQL (`IF OBJECT_ID` / `sys.schemas`, `IDENTITY`, `GO` batches as needed).
- Nullability must follow the rules above.
- **`sql/current_model.sql`** is the **committed** single-file **reset** script regenerated from those sources (see Database Deployment Standard). Local apply may also write a gitignored `generated/current-model.sql` copy for `sqlcmd`.

### Data categories: bootstrap, required reference, sample seed

| Category | Meaning | Where |
| --- | --- | --- |
| **Bootstrap data** | Operator/onboarding scripts required to stand up platform admin (e.g. Workflow G GSA grant) | **SSOT:** STANDARDS [`templates/onboarding/bootstrap-global-system-administrators.sql`](../templates/onboarding/bootstrap-global-system-administrators.sql). Product copies under `sql/seed/` are apply convenience only and must stay byte-aligned with the SSOT. |
| **Required reference data** | Rows every environment needs (e.g. SHARED-UI Security seed `GLOBAL-SYSTEM-ADMINISTRATORS` group **without** memberships) | SHARED-UI `sql/security/seed/`; may also be created by bootstrap if missing |
| **Sample / local seed data** | Fake/demo rows for Docker local testing | Product `sql/seed/` — **local only**; do **not** apply to hosted DEV / UAT / PRD by default |

### `sql/seed/` (required for apps with owned business schema)

Every application that owns business tables must keep a **local-ready** sample seed so developers and agents can exercise the app without Azure SQL or empty tables.

- **Sample/fake data** for **local Docker SQL** only (see category table above).
- Not the schema source of truth; keep scripts **idempotent** when practical.
- Do **not** apply sample seed to hosted **DEV / UAT / PRD** by default.
- Bootstrap scripts stored under `sql/seed/` for local tooling convenience remain **bootstrap**, not sample data — see category table.
- **Keep in sync:** when `sql/current_model/` or `docs/db-model.md` changes, update `sql/seed/` in the **same change set** so local testing still works.
- Seed assets are usually T-SQL under `sql/seed/`. Portable JSON payloads (same envelopes as import/export; [data-portability.md](data-portability.md)) are allowed when the app’s local seed scripts apply them to Docker SQL.
- Local apply path: build consolidated `generated/seed.sql` → single `sqlcmd` (see Database Seed Maintenance Standard).
- Ship a seed script (e.g. `scripts/local-db-seed.ps1`) and document it in the app README / README_AI.
- Local sandbox workflow: [local-database.md](local-database.md).

### `sql/migration_scripts/`

- Holds **hosted / populated** incremental migration SQL (the authoritative evolution path for existing databases).
- Not the source of truth for the full model (`current_model/` remains the model SSOT).
- Platform Identity/Security/platform ledger migrations are owned by **SYSTEM-SHARED-UI** under `sql/*/migration_scripts/`.
- Record applied versions in [`dbo.BreezeOnSchemaVersions`](#platform-schema-evolution-hosted).

### `docs/db-model.md` (required for apps with owned schema)

Each application that owns business database objects must maintain a **current** database model document (path convention: `docs/db-model.md`).

- Describe schemas and tables that exist **now** (columns, types, nullability, keys).
- Keep it in sync with `sql/current_model/` in the **same change set**.
- Do not document planned tables as if they exist.
- Point agents and humans to this file for the readable model; scripts remain the executable SSOT.

Database objects for EAC live in [Breeze-On/SYSTEM-ADMIN-EAC](https://github.com/Breeze-On/SYSTEM-ADMIN-EAC) under `sql/` and [`docs/db-model.md`](https://github.com/Breeze-On/SYSTEM-ADMIN-EAC/blob/main/docs/db-model.md).

**Seed vs current model (reminder):** `sql/current_model/` is **current-state schema only**. Sample and development data belong only under `sql/seed/` (except bootstrap copies that mirror STANDARDS templates). Do not mix seed inserts into current-model scripts.

## Platform schema evolution (hosted)

Lightweight V1 rules for shared platform schemas (`Identity`, `Security`, and platform ledger objects):

| Concern | Rule |
| --- | --- |
| **Bootstrap / reset** | Apply SHARED-UI `sql/*/current_model/` (and `sql/platform/current_model/`) only to a **new** catalog or after a **full database drop/recreate** (local `dev-reset`). |
| **Hosted / populated** | Evolve with SHARED-UI-owned **`migration_scripts/`** only. **Never** DROP+CREATE re-apply platform `current_model` on a customer database that already holds application data/FKs. |
| **Ownership** | SYSTEM-SHARED-UI owns platform definitions and migrations. Adopting apps apply them in documented order; they must not fork competing Identity/Security models. |
| **Schema-version table** | Authoritative applied-state mechanism is **`dbo.BreezeOnSchemaVersions`** (`SchemaName`, `Version`, `ScriptName`, `AppliedUtc`). Definition: SHARED-UI `sql/platform/`. Hosted install: `sql/platform/migration_scripts/20261121_add_BreezeOnSchemaVersions.sql`. |
| **Operator evidence logs** | Optional for tickets; **not** the authoritative applied-state record. |
| **Product schemas** | Same bootstrap vs migration split applies to EAC `System` (and future app schemas): `current_model` for reset; `migration_scripts/` for populated hosted. |

Master Flow Step 1 must apply platform schemas via bootstrap on empty catalogs, or migrations when schemas already exist — see [customer-onboarding-master-flow.md](../runbooks/customer-onboarding-master-flow.md).

## Runtime database permissions (v1 posture)

Hosted App Service Managed Identities currently share a DDL-capable runtime role (`breezeon_app` ∈ `db_datareader` / `db_datawriter` / `db_ddladmin` + `EXECUTE`) per [templates/azure-sql/README.md](../templates/azure-sql/README.md).

**Accepted v1 posture:** schema ownership (`Identity` / `Security` / `System`) is **convention-based** — docs and ADRs state ownership; the database does **not** yet enforce per-schema grants. Runtime identities are intentionally DDL-capable for current ops maturity.

**Future Validation:** more restrictive per-app / per-schema security before multiple product identities share a customer database at scale.
