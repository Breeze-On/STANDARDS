# Architecture — EAC

Owner: Architecture

Current-state description of the Enterprise Administration Center application.

## Identity

| | |
| --- | --- |
| Name | EAC (Enterprise Administration Center) |
| Repository | [Breeze-On/SYSTEM-ADMIN-EAC](https://github.com/Breeze-On/SYSTEM-ADMIN-EAC) |
| Project | `src/BreezeOn.Eac` |
| Namespace | `BreezeOn.Eac` |

## Responsibility

EAC is the centralized application for:

- System configuration
- Business drop-down (DDL) values
- Security access
- Role assignments
- Application registry (`System` schema)

It is the configuration and access hub for the Breeze On ecosystem.

## Implementation (current)

| Area | State |
| --- | --- |
| UI framework | Blazor Web App, Interactive Server (global interactivity) |
| Runtime | ASP.NET Core / C# / .NET 10 (App Service stack: `DOTNETCORE|10.0`) |
| Shared UI | ProjectReference to `SYSTEM-SHARED-UI` / `BreezeOn.UI` (`Bo*` only; [ADR-004](../decisions/ADR-004-breezeon-ui-abstraction-layer.md)) |
| Auth | **Not implemented** — ASP.NET Core Identity removed; no login/register; shell pages public |
| Surfaces | `BoAppShell` + left nav; Home (`BoNavHub`); Applications (ReadOnly `BoGrid` with selection over `System.EACApplications`; create/edit popup; JSON import/export); Organisation Entities / App Configuration (public empty bodies) |
| Localization | EAC `EacResources.resx` / `EacResources.fr.resx` via `IEacLocalizer` (not Gallery `BoUi`) |
| Data access | EF Core + SQL Server provider (`ApplicationDbContext` + empty `InitialBaseline` for `__EFMigrationsHistory`; business schema via SQL scripts; audit stamps via `IAuditActorProvider` → interim `LOCAL`) |
| SQL scripts | `sql/current_model/` (T-SQL): schema `System`, table `System.EACApplications` (includes mandatory audit columns) |
| DB model doc | [`docs/db-model.md`](https://github.com/Breeze-On/SYSTEM-ADMIN-EAC/blob/main/docs/db-model.md) |
| Portability | Applications JSON import/export — [data-portability.md](../docs/data-portability.md) (EAC-owned; not a shared service) |
| Local database | SQL Server Docker (`BreezeOnLocal`); see [local-database.md](../docs/local-database.md) |

## Applications: selection, import, export

Applications import/export is **owned by EAC** (`SYSTEM-ADMIN-EAC`). It is **not** a shared service. File format: [data-portability.md](../docs/data-portability.md). Audit columns: [database.md](../docs/database.md#mandatory-audit-columns) / [ADR-005](../decisions/ADR-005-mandatory-transactional-audit-columns.md) (interim actor **`LOCAL`**).

| Concern | Behavior |
| --- | --- |
| Grid selection | `BoGrid.EnableSelection` — compact unlabeled first column; select-all = all rows in **BoGrid cache**, not the database ([grids.md](../docs/ui/controls/grids.md#row-selection)) |
| Import | Footer **Import from JSON** → native picker → in-memory validate → batched upsert by current `UniqueCode` → single `SaveChangesAsync` → reload + toast |
| Export | Footer **Export JSON** (far right) → selected rows only → browser download (`ApplicationGUID` / audit omitted) |
| Match rule | Found = update; not found = create. No rename detection / aliases / history |
| Rename example | DB `SYSTEM-ADMIN-EAC` + file `LEGACY-SYSTEM-ADMIN-EAC` → **creates** new application |
| Size limit | `ApplicationsImport:MaxFileSizeMb` (default 2); uploads never persisted |

## Local development (current)

| Resource | Value |
| --- | --- |
| Engine | SQL Server 2022 container (`docker-compose.yml` in EAC repo) |
| Physical database | `BreezeOnLocal` |
| Auth | SQL `sa` (password via `.env` / `LocalSql:SaPassword` or `MSSQL_SA_PASSWORD`) |
| Init | `scripts/local-db-init.ps1` applies `sql/current_model/` |
| Seed | `scripts/local-db-seed.ps1` applies `sql/seed/` (required local fake data; keep in sync with schema) |

Routine local runs do **not** use Azure SQL. Org pattern: [local-database.md](../docs/local-database.md). Human runbook and agent steps: EAC [`README.md`](https://github.com/Breeze-On/SYSTEM-ADMIN-EAC/blob/main/README.md) / [`README_AI.md`](https://github.com/Breeze-On/SYSTEM-ADMIN-EAC/blob/main/README_AI.md).

## DEV environment (current)

GitHub Environment name: **`DEV`**. Physical Azure resource names below reflect current reality.

| Resource | Value |
| --- | --- |
| Resource group | `RG-BREEZEON-DEV` |
| Azure SQL server | `sql-breezeon-dev.database.windows.net` |
| Azure SQL database | `BreezeOnDV` (legacy physical name; convention for new DBs is `{Logical}Dev`) |
| App Service | `breezeon-system-admin-eac-dev` (Linux Free F1) |
| App Service plan | `asp-breezeon-dev` |
| App Service DB auth | Managed Identity (`Authentication=Active Directory Managed Identity`) |

## Boundaries

- This application lives only in `SYSTEM-ADMIN-EAC`.
- Org-wide standards and cross-cutting architecture live in `Breeze-On/STANDARDS`, not duplicated here at length.
- Ecosystem map (repos, hosting, SQL, UI position): [landscape.md](landscape.md).
- Application expectations: [application-model.md](../docs/application-model.md). Environments: [environments.md](../docs/environments.md).
