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

Apply `NOT NULL` **only** when:

1. The column is part of the **primary key**, or
2. The column **name contains `GUID`** (case-insensitive match, e.g. `ApplicationsGUID`).

All other business columns are **NULL**-allowed unless an explicit, documented exception is approved for that column.

**Explicit exception:** the four [mandatory audit columns](#mandatory-audit-columns) on transactional business tables are **always `NOT NULL`**, even though they are not part of the primary key and do not contain `GUID` in their names.

Do not default every column to `NOT NULL`.

## Mandatory audit columns

Every **transactional business table** (tables that hold business records created and changed by users or application processes) must include these four columns:

| Column | Type | Nullability |
| --- | --- | --- |
| `CreatedBy` | `NVARCHAR(600)` | `NOT NULL` |
| `CreatedDate` | `DATETIME2` | `NOT NULL` |
| `LastUpdatedBy` | `NVARCHAR(600)` | `NOT NULL` |
| `LastUpdatedDate` | `DATETIME2` | `NOT NULL` |

Rules:

1. **Always `NOT NULL`.** These four columns are an explicit exception to the general [Nullability](#nullability-not-null) rule (`NOT NULL` only on primary key / `GUID` columns).
2. **Create** populates **all four** columns (`LastUpdatedBy` / `LastUpdatedDate` equal the created values on insert).
3. **Update** refreshes **only** `LastUpdatedBy` and `LastUpdatedDate`. `CreatedBy` and `CreatedDate` are never changed after insert.
4. **Actor** (`CreatedBy` / `LastUpdatedBy`) is the **logged-in user** when authentication exists. While a product has no authentication, an interim product stamp may be used: **`LOCAL`**. Replace the interim stamp with the real user when auth is implemented.
5. **Migrations** that add these columns to an existing table must **backfill** existing rows first, then enforce `NOT NULL`.
6. **No exceptions** unless formally documented and approved for that table (record the exception in the product `docs/db-model.md` and, if it sets a pattern, an ADR).
7. Audit values are **system-managed**. They are not part of user-facing import/export file formats ([data-portability.md](data-portability.md)).

Decision record: [ADR-005](../decisions/ADR-005-mandatory-transactional-audit-columns.md). Product `sql/current_model/`, `docs/db-model.md`, and `sql/seed/` must reflect these columns in the same change set.

## Application data access

- **Standard CRUD:** EF Core `SaveChanges` (audit columns stamped by the application layer before save).
- **Bulk import:** batched EF Core operations (not row-at-a-time round trips where a batch is practical).
- **No stored-procedure-per-table by default.** Introduce stored procedures only for a specific, documented need (for example hierarchy retrieval with path columns, cycle detection on re-parent, or recursive subtree delete).

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

## Shared System schema ownership

- The SQL schema **`System`** holds platform administration / shared catalog tables owned by **EAC** (Enterprise Administration Center).
- Other applications **consume** those registry values (for example via `ApplicationGUID`); they must **not** fork duplicate application-catalog tables.
- Concrete table inventory lives in the EAC product [`docs/db-model.md`](https://github.com/Breeze-On/SYSTEM-ADMIN-EAC/blob/main/docs/db-model.md) and `sql/current_model/` — not in this file.

## Application registry identity columns

Conventions for registering applications in the EAC-owned catalog (column semantics are org-wide; physical table is EAC-owned):

| Column | Role |
| --- | --- |
| **ApplicationGUID** | Immutable relationship key between entities and across apps. Column name contains `GUID` → **NOT NULL**. Generate once on insert; **never** regenerate or overwrite on update. Prefer a **UNIQUE** constraint/index. |
| **UniqueCode** | Application **technical** identifier. Value follows the **GitHub repository name** (e.g. `SYSTEM-ADMIN-EAC`, `SYSTEM-HR-HRM`). Prefer a **UNIQUE** constraint/index. Length follows non-Code string defaults unless the product documents an exception. |
| **Code** | Short **business** identifier (e.g. `EAC`, `HRM`, `AP`). Length follows the **Code** default (**30**) unless documented otherwise. |

Repository ↔ identifier mapping: [naming.md](naming.md) § Application technical identifiers.

## Script layout (application repos)

Each application repository that owns database objects maintains SQL under:

```text
sql/
  current_model/          # Source of truth for the current schema (executable T-SQL)
  seed/                   # Required local-only sample data for local-ready testing (not for hosted envs by default)
  migration_scripts/      # Temporary deltas; clean up after applied
docs/
  db-model.md             # Human/agent-readable current DB model (required when the app owns SQL objects)
```

### `sql/current_model/`

- Represents the **current** database model only.
- One script per table or discrete object.
- Each table script must be maintainable as a full recreate: **drop if exists, then create** (safe to apply against an empty database when run in documented order).
- Include schema-creation scripts as needed (e.g. `00_schema_*.sql`).
- Use Transact-SQL idioms appropriate for Azure SQL (`IF OBJECT_ID` / `sys.schemas`, `IDENTITY`, `GO` batches as needed).
- Nullability must follow the rules above.

### `sql/seed/` (required for apps with owned business schema)

Every application that owns business tables must keep a **local-ready** seed so developers and agents can exercise the app without Azure SQL or empty tables.

- Sample/fake data for **local Docker SQL** only.
- Not the schema source of truth; keep scripts **idempotent** when practical.
- Do **not** apply to hosted DEV / UAT / PRD by default.
- **Keep in sync:** when `sql/current_model/` or `docs/db-model.md` changes, update `sql/seed/` in the **same change set** so local testing still works.
- Seed assets are usually T-SQL under `sql/seed/`. Portable JSON payloads (same envelopes as import/export; [data-portability.md](data-portability.md)) are allowed when the app’s local seed scripts apply them to Docker SQL.
- Ship a seed script (e.g. `scripts/local-db-seed.ps1`) and document it in the app README / README_AI.
- Local sandbox workflow: [local-database.md](local-database.md).

### `sql/migration_scripts/`

- Holds one-off or incremental migration SQL used while evolving environments.
- Not the source of truth for the model.
- Clean up regularly after migrations have been applied to all relevant environments.

### `docs/db-model.md` (required for apps with owned schema)

Each application that owns business database objects must maintain a **current** database model document (path convention: `docs/db-model.md`).

- Describe schemas and tables that exist **now** (columns, types, nullability, keys).
- Keep it in sync with `sql/current_model/` in the **same change set**.
- Do not document planned tables as if they exist.
- Point agents and humans to this file for the readable model; scripts remain the executable SSOT.

Database objects for EAC live in [Breeze-On/SYSTEM-ADMIN-EAC](https://github.com/Breeze-On/SYSTEM-ADMIN-EAC) under `sql/` and [`docs/db-model.md`](https://github.com/Breeze-On/SYSTEM-ADMIN-EAC/blob/main/docs/db-model.md).

**Seed vs current model (reminder):** `sql/current_model/` is **current-state schema only**. Sample and development data belong only under `sql/seed/`. Do not mix seed inserts into current-model scripts.
