# ADR-005: Mandatory transactional audit columns

Status: Accepted

## Context

Business records in Breeze On applications need a consistent answer to "who created this, when, and who last changed it, when". Without an org-wide rule, tables diverge on column names, types, and nullability, and the general nullability rule in [database.md](../docs/database.md) (`NOT NULL` only on primary key / `GUID` columns) would otherwise leave audit values optional. EAC (`System.EACApplications`) is the first application applying the standard to transactional business tables.

## Decision

- Every **transactional business table** includes four audit columns, all **`NOT NULL`**:
  - `CreatedBy` `NVARCHAR(600)`
  - `CreatedDate` `DATETIME2`
  - `LastUpdatedBy` `NVARCHAR(600)`
  - `LastUpdatedDate` `DATETIME2`
- This is an **explicit exception** to the general nullability rule; these four columns are always `NOT NULL`.
- **Create** populates all four. **Update** refreshes only `LastUpdatedBy` and `LastUpdatedDate`.
- The actor is the **logged-in user** when authentication exists. Where a product has no authentication yet, the interim product stamp **`LOCAL`** may be used.
- Migrations that add the columns to existing tables **backfill** first, then enforce `NOT NULL`.
- No table is exempt unless the exception is formally documented and approved.
- **Documented exception:** platform **`Identity.Users`** and **`Identity.UsersLogins`** ([ADR-010](ADR-010-platform-identity-schema.md)) — directory master and append-only login history, not ordinary transactional business entities.
- Data access: EF Core `SaveChanges` for standard CRUD and batched EF Core for bulk import; no stored procedure per table by default.
- Audit values are system-managed and are not part of user-facing import/export files ([data-portability.md](../docs/data-portability.md)).

Standard text: [database.md](../docs/database.md) § Mandatory audit columns.

## Consequences

- Product `sql/current_model/`, `docs/db-model.md`, and `sql/seed/` include the four columns for each transactional table, updated in the same change set.
- Application code (not database defaults alone) is responsible for stamping actor and timestamps on create and update.
- Rows written before authentication exists carry `LOCAL` as actor until updated by a real user.
- Adding the columns to an existing table requires a backfill step before `NOT NULL` is enforced.
