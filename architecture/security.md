# Architecture — Security

Owner: Architecture

Current-state security posture for implemented Breeze On applications.

## EAC application authentication

| | |
| --- | --- |
| Mechanism | **Not implemented** (ASP.NET Core Identity removed from EAC) |
| App | EAC (`SYSTEM-ADMIN-EAC` / `BreezeOn.Eac`) |
| UI access | Shell pages are public (Home + destination pages) |
| User store | None — no `AspNet*` tables |

End-user authentication and authorization will be introduced in a future milestone once Identity / security requirements are defined.

## Authorization (current)

- No `[Authorize]` attributes on EAC product pages.
- No login redirect for shell routes.

## Local SQL access

| Principal | How |
| --- | --- |
| Developer / app (Development) | SQL authentication (`sa`) against `localhost,1433` / `BreezeOnLocal` |
| Password source | Gitignored `.env` (`MSSQL_SA_PASSWORD`) and/or User Secrets `LocalSql:SaPassword` |

Local SQL passwords must never be committed or used against Azure SQL. See [local-database.md](../docs/local-database.md).

## Azure SQL access (DEV)

| Principal | How |
| --- | --- |
| Operators (e.g. Entra admin) | Microsoft Entra / Azure CLI token; used for scripts and optional Entra Default overrides |
| App Service `breezeon-system-admin-eac-dev` | System-assigned Managed Identity mapped as SQL user `breezeon-system-admin-eac-dev`, member of custom role **`breezeon_app`** |

Connection strings do not embed SQL passwords for the hosted app. Do not commit production secrets.

### Connection string name

| Setting | Value |
| --- | --- |
| Config key | **`SQLAzureConnection`** (`ConnectionStrings:SQLAzureConnection`) |
| App Service | Environment variables → **Connection strings** → name `SQLAzureConnection`, type SQLAzure |
| Hosted value shape | `Server=tcp:<sql-server>.database.windows.net,1433;Initial Catalog=<database>;Authentication=Active Directory Managed Identity;Encrypt=True;TrustServerCertificate=False;` |
| Repo | Empty in `appsettings.json`; local Docker value in `appsettings.Development.json` under the same key |
| App package (SqlClient 7+) | **`Microsoft.Data.SqlClient.Extensions.Azure`** (same major/minor as `Microsoft.Data.SqlClient`) plus register `ActiveDirectoryAuthenticationProvider` before any SQL open (including EF `Database.Migrate()`). Core SqlClient 7 no longer ships Entra/MI providers; without the extension, App Service startup crashes with `Cannot find an authentication provider for 'ActiveDirectoryManagedIdentity'`. |

Deploy procedure: [hosted-deployment.md](../docs/hosted-deployment.md) § Hosted database connection.

### Grant App Service Managed Identity (SQL)

Run as an Azure SQL Entra admin against the **target database**. SQL user name must match the App Service name. Template: [`templates/azure-sql/grant-app-service-mi.sql`](../templates/azure-sql/grant-app-service-mi.sql).

Permission model (template [`grant-app-service-mi.sql`](../templates/azure-sql/grant-app-service-mi.sql)):

- Custom role **`breezeon_app`** (do not customize built-in roles).
- `breezeon_app` is a member of `db_datareader`, `db_datawriter`, `db_ddladmin`.
- Database-level `GRANT EXECUTE TO [breezeon_app]` (all schemas; fixed DB roles do not include execute).
- Each App Service MI user is added only to `breezeon_app`.

## Secrets and local data

- Do not commit credentials or production secrets (including `.env`).
- App Service stores **`SQLAzureConnection`** as a connection string setting (Managed Identity auth).
- Local Development defaults to Docker SQL with password substitution (`__FROM_ENV__` → `LocalSql:SaPassword` or `MSSQL_SA_PASSWORD`).

## Scope note

This document describes only what is implemented today. Cross-app SSO and Microsoft Entra External ID for end users are not implemented.

Organization-wide **dependency and vulnerability governance** lives in [`docs/security-governance.md`](../docs/security-governance.md). Do not confuse that governance standard with this architecture document.
