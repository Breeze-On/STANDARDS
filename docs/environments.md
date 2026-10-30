# Environments

Owner: Engineering

Central reference for **environment names and models** used across Breeze On documentation and applications. Product repositories should **link here** instead of redefining environment concepts.

Current Reality Only: details below match what is implemented or already defined in STANDARDS and product docs today.

## Summary

| Name | Role | Implemented hosting (today) |
| --- | --- | --- |
| **Local** | Developer / agent sandbox | SQL Server Docker on the workstation |
| **DEV** | Hosted development | Azure App Service + Azure SQL (ADM / Shared UI Gallery as documented) |
| **UAT** | User acceptance / pre-production | Label reserved for hosted UAT; no separate UAT resources documented as implemented yet |
| **PRD** | Production | Label reserved for hosted production; no separate PRD resources documented as implemented yet |

**GitHub Environment names** for deploy workflows must be **`DEV`**, **`UAT`**, and **`PRD`** (exact spelling). Do not use legacy labels `DV` / `PP` / `PR` for new Environments or new docs.

Azure **resource** names may still contain older suffixes (e.g. App Service `…-dv`, database `BreezeOnDV`). Document the **environment** as DEV/UAT/PRD and list the physical Azure names as they exist.

Scripts and docs name **DEV**, **UAT**, and **PRD** when listing hosted Azure SQL environments that must **not** receive local `sql/seed/` by default ([database.md](database.md), [local-database.md](local-database.md)).

---

## Local

| | |
| --- | --- |
| **Name** | Local |
| **Purpose** | Routine development and agent verification without Azure SQL or Entra tokens |
| **Hosting model** | Developer machine; SQL Server 2022 container via Docker Compose in the application repo |
| **Authentication model** | SQL authentication (`sa`); password from gitignored `.env` (`MSSQL_SA_PASSWORD`) and/or User Secrets (`LocalSql:SaPassword`) |
| **Database model** | Physical name `{Logical}Local` (ADM: `BreezeOnLocal` on `localhost,1433`); apply `sql/current_model/` then `sql/seed/` |
| **Intended usage** | Default path for `dotnet run`, local Identity data, and local-ready testing |

Org pattern: [local-database.md](local-database.md). Decision context: [ADR-003](../decisions/ADR-003-azure-sql-with-local-docker-sql.md).

---

## DEV

| | |
| --- | --- |
| **Name** | DEV (hosted development) |
| **Purpose** | Shared hosted development instance |
| **Hosting model (ADM)** | Azure App Service Linux Free F1 (`breezeon-system-admin-adm-dv`), resource group `RG-BREEZEON-DEV`, stack `DOTNETCORE\|10.0` |
| **Hosting model (Shared UI Gallery)** | Azure App Service Linux (`breezeon-system-shared-ui-dev`), resource group `RG-BREEZEON-DEV`, stack .NET 10 |
| **Authentication model (ADM)** | ASP.NET Core Identity for end users; App Service → Azure SQL via **system-assigned Managed Identity**; operators may use Entra Default for scripts |
| **Database model (ADM)** | Azure SQL `sql-breezeon-dev.database.windows.net` / database `BreezeOnDV`; Identity `AspNet*` via EF; business schema under `SYSADM` |
| **Intended usage** | Deployed smoke and shared hosted development; CI via GitHub Environment **`DEV`** |

Details: [architecture/adm.md](../architecture/adm.md), [architecture/security.md](../architecture/security.md), [architecture/landscape.md](../architecture/landscape.md).

---

## UAT

| | |
| --- | --- |
| **Name** | UAT |
| **Purpose** | User acceptance / pre-production hosted instance |
| **Status** | Name reserved in seed/governance language; no UAT App Service / database documented as implemented yet |

---

## PRD

| | |
| --- | --- |
| **Name** | PRD |
| **Purpose** | Production hosted instance |
| **Status** | Name reserved in seed/governance language; no PRD App Service / database documented as implemented yet |

---

## Hosted seed rule (DEV / UAT / PRD)

Local `sql/seed/` is for the **Local** sandbox only. Do **not** apply seed scripts to hosted Azure SQL environments named **DEV**, **UAT**, or **PRD** by default. Product READMEs and seed READMEs use these three labels together for that rule.

---

## Product documentation

- Describe environment-specific URLs, connection settings, and workflows in the **product** README / README_AI.
- Use this document for shared meaning of Local vs hosted **DEV** / **UAT** / **PRD** and for the hosted seed-exclusion labels.
- Do not duplicate full environment matrices in every product README.
