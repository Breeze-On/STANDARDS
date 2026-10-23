# Database standards

Current conventions for relational databases in Breeze On applications.

## Platform

- **Engine:** Microsoft **SQL Server** / **Azure SQL** (Transact-SQL).
- Application `sql/current_model` scripts are authored in **T-SQL** for Azure SQL Database / SQL Server.
- Do not introduce a second relational engine for the same application without an explicit org decision and STANDARDS update.

## Local development

Routine local work uses a **SQL Server Docker sandbox** (not Azure SQL). Pattern, templates, and init expectations: [local-database.md](local-database.md). Starter files: [`templates/local-sql/`](../templates/local-sql/).

## String columns (NVARCHAR)

- Use **NVARCHAR** for variable-length Unicode strings on all standard business columns.
- Do **not** use `VARCHAR` for those columns unless an explicit exception is documented for that column.
- Do **not** use `NVARCHAR(MAX)` as the default for ordinary business columns unless explicitly decided for that column.

### Default lengths

| Column kind | Default length | Rule |
| --- | --- | --- |
| **Code** (column named `Code`, or explicitly designated a code) | **30** | Unless a different length is specified for that column |
| **Non-Code** strings | **600** | Unless a different length is specified for that column |

## Nullability (NOT NULL)

Apply `NOT NULL` **only** when:

1. The column is part of the **primary key**, or
2. The column **name contains `GUID`** (case-insensitive match, e.g. `ApplicationsGUID`).

All other business columns are **NULL**-allowed unless an explicit, documented exception is approved for that column.

Do not default every column to `NOT NULL`.

## Script layout (application repos)

Each application repository that owns database objects maintains SQL under:

```text
sql/
  current_model/          # Source of truth for the current schema (executable T-SQL)
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

Database objects for ADM live in [Breeze-On/SYSTEM-ADMIN-ADM](https://github.com/Breeze-On/SYSTEM-ADMIN-ADM) under `sql/` and [`docs/db-model.md`](https://github.com/Breeze-On/SYSTEM-ADMIN-ADM/blob/main/docs/db-model.md).
