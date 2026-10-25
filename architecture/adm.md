# Architecture — ADM

Owner: Architecture

Current-state description of the Administration application.

## Identity

| | |
| --- | --- |
| Name | ADM (Administration) |
| Repository | [Breeze-On/SYSTEM-ADMIN-ADM](https://github.com/Breeze-On/SYSTEM-ADMIN-ADM) |
| Project | `src/BreezeOn.Adm` |
| Namespace | `BreezeOn.Adm` |

## Responsibility

ADM is the centralized application for:

- System configuration
- Business drop-down (DDL) values
- Security access
- Role assignments

It is the configuration and access hub for the Breeze On ecosystem.

## Implementation (current)

| Area | State |
| --- | --- |
| UI framework | Blazor Web App, Interactive Server (global interactivity) |
| Runtime | ASP.NET Core / C# / .NET 10 (App Service stack: `DOTNETCORE|10.0`) |
| Auth | ASP.NET Core Identity (`AspNet*` tables via EF migrations) |
| Surfaces | Home (cards), Dashboard (authorized), left navigation, Identity account pages |
| Data access | EF Core + SQL Server provider |
| SQL scripts | `sql/current_model/` (T-SQL): schema `SYSADM`, table `SYSADM.ADMApplications` |
| DB model doc | [`docs/db-model.md`](https://github.com/Breeze-On/SYSTEM-ADMIN-ADM/blob/main/docs/db-model.md) |
| Local database | SQL Server Docker (`BreezeOnLocal`); see [local-database.md](../docs/local-database.md) |

## Local development (current)

| Resource | Value |
| --- | --- |
| Engine | SQL Server 2022 container (`docker-compose.yml` in ADM repo) |
| Physical database | `BreezeOnLocal` |
| Auth | SQL `sa` (password via `.env` / `LocalSql:SaPassword` or `MSSQL_SA_PASSWORD`) |
| Init | `scripts/local-db-init.ps1` applies `sql/current_model/` |
| Seed | `scripts/local-db-seed.ps1` applies `sql/seed/` (required local fake data; keep in sync with schema) |

Routine local runs do **not** use Azure SQL. Org pattern: [local-database.md](../docs/local-database.md). Human runbook and agent steps: ADM [`README.md`](https://github.com/Breeze-On/SYSTEM-ADMIN-ADM/blob/main/README.md) / [`README_AI.md`](https://github.com/Breeze-On/SYSTEM-ADMIN-ADM/blob/main/README_AI.md).

## DV environment (current)

| Resource | Value |
| --- | --- |
| Resource group | `RG-BREEZEON-DEV` |
| Azure SQL server | `sql-breezeon-dev.database.windows.net` |
| Azure SQL database | `BreezeOnDV` |
| App Service | `breezeon-system-admin-adm-dv` (Linux, Free F1, stack .NET 10) |
| App Service plan | `asp-breezeon-dev` |
| Hostname | `breezeon-system-admin-adm-dv-e4gwcgd7aqdegvgx.canadaeast-01.azurewebsites.net` |
| Managed Identity | System-assigned; principal `0100ae8a-b5c1-4c4f-84e9-517db2e5815e` |
| Local / operator DB auth | Microsoft Entra (`Authentication=Active Directory Default`) |
| App Service DB auth | Managed Identity (`Authentication=Active Directory Managed Identity`) |

## Boundaries

- This application lives only in `SYSTEM-ADMIN-ADM`.
- Org-wide standards and cross-cutting architecture live in `Breeze-On/STANDARDS`, not duplicated here at length.
- Ecosystem map (repos, hosting, SQL, UI position): [landscape.md](landscape.md).
- Application expectations: [application-model.md](../docs/application-model.md). Environments: [environments.md](../docs/environments.md).
