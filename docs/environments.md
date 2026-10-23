# Environments

Central reference for **environment names and models** used across Breeze On documentation and applications. Product repositories should **link here** instead of redefining environment concepts.

Current Reality Only: details below match what is implemented or already defined in STANDARDS and product docs today.

## Summary

| Name | Role | Implemented hosting (ADM) |
| --- | --- | --- |
| **Local** | Developer / agent sandbox | SQL Server Docker on the workstation |
| **DV** | Hosted development | Azure App Service + Azure SQL (`BreezeOnDV`) |

Scripts and docs also name **PP** and **PR** alongside **DV** when listing hosted Azure SQL environments that must **not** receive local `sql/seed/` by default ([database.md](database.md), [local-database.md](local-database.md)). Those labels are part of existing seed/governance language; this file does not invent separate hosted resources beyond what architecture docs already describe for DV.

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

## DV

| | |
| --- | --- |
| **Name** | DV (Development hosted) |
| **Purpose** | Shared hosted development instance of ADM |
| **Hosting model** | Azure App Service Linux Free F1 (`breezeon-system-admin-adm-dv`), resource group `RG-BREEZEON-DEV`, stack `DOTNETCORE\|10.0` |
| **Authentication model** | ASP.NET Core Identity for end users; App Service → Azure SQL via **system-assigned Managed Identity**; operators may use Entra Default for scripts |
| **Database model** | Azure SQL `sql-breezeon-dev.database.windows.net` / database `BreezeOnDV`; Identity `AspNet*` via EF; business schema under `SYSADM` |
| **Intended usage** | Deployed ADM for DV smoke and shared hosted development; CI via GitHub Environment `DV` |

Details: [architecture/adm.md](../architecture/adm.md), [architecture/security.md](../architecture/security.md).

---

## Hosted seed rule (DV / PP / PR)

Local `sql/seed/` is for the **Local** sandbox only. Do **not** apply seed scripts to hosted Azure SQL environments named **DV**, **PP**, or **PR** by default. Product READMEs and seed READMEs already use these three labels together for that rule.

---

## Product documentation

- Describe environment-specific URLs, connection settings, and workflows in the **product** README / README_AI.
- Use this document for shared meaning of Local vs hosted DV and for the hosted seed-exclusion labels.
- Do not duplicate full environment matrices in every product README.
