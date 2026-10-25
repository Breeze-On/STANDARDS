# Local database sandbox

Owner: Engineering

Standard for running a **local SQL Server** in Docker so Breeze On applications can develop and test without consuming Azure SQL or Entra tokens.

Hosted environments (DV / PP / PR) remain **Azure SQL** with Managed Identity (or Entra Default for operators). Local password authentication is **local only** — never use SQL `sa` passwords against Azure SQL. Environment definitions: [environments.md](environments.md). Decision context: [ADR-003](../decisions/ADR-003-azure-sql-with-local-docker-sql.md).

## Purpose

- Same engine dialect as production: **SQL Server / T-SQL** (see [database.md](database.md)).
- No Azure SQL DTU/vCore use and no Entra token use for routine local runs.
- Each application applies its own `sql/current_model/` scripts against a local database.

## Prerequisites (developer machine)

1. [Docker Desktop](https://www.docker.com/products/docker-desktop/) installed and running (Windows with WSL2 is fine).
2. A strong **SA password** that meets SQL Server complexity (at least 8 characters, upper, lower, number, symbol). Store it only in a **gitignored** `.env` and/or .NET User Secrets — never commit it and never paste it into chat or tickets.
   - **Use an ASCII-only password** (letters, digits, and basic symbols such as `!#%*`). Avoid `$` (Compose/PowerShell) and non-ASCII characters such as `£` (encoding mismatches between `.env`, Docker, and sqlcmd).
   - With `env_file: .env`, store the **literal** password (do not use `$$` unless interpolating inside a compose `environment:` value).
   - Use `env_file: .env` in compose (see template) so the password is not re-expanded via `"${MSSQL_SA_PASSWORD}"`.
3. Optional: Azure Data Studio or SSMS to inspect `localhost,1433`.

## Standard container

| Setting | Value |
| --- | --- |
| Image | `mcr.microsoft.com/mssql/server:2022-latest` |
| Host port | `1433` |
| EULA | `ACCEPT_EULA=Y` |
| SA password | `MSSQL_SA_PASSWORD` from `.env` (gitignored) |
| Data | Named Docker volume (persists across restarts) |

Starter files live in [`templates/local-sql/`](../templates/local-sql/). Copy them into each application repository root and adjust the database name / init script for that app.

## Database naming

| | Convention | ADM example |
| --- | --- | --- |
| Logical product DB | Product family name | BreezeOn |
| Environment | `Local` | Local |
| Physical database name | `{Logical}Local` | `BreezeOnLocal` |

## Connection string (local)

Use SQL authentication against the container:

```text
Server=localhost,1433;Initial Catalog={PhysicalDb};User Id=sa;Password=***;TrustServerCertificate=True;Encrypt=True
```

Do **not** commit the real password. Typical pattern:

- Docker Compose reads `MSSQL_SA_PASSWORD` from `.env`.
- The app resolves the same password from environment variable `MSSQL_SA_PASSWORD` and/or configuration `LocalSql:SaPassword` (User Secrets) and substitutes it into the Development connection string.

Optional: override the connection string with User Secrets to point at Azure SQL when intentionally testing hosted DV (requires `az login` for Entra Default). That is not the default local path.

## Init sequence

1. `docker compose up -d` (from the app repo that owns `docker-compose.yml`).
2. Wait until the SQL service is healthy.
3. Create the physical database if it does not exist.
4. Apply that app’s `sql/current_model/` scripts **in documented order** (schema scripts first, then tables).
5. Apply that app’s `sql/seed/` scripts for local sample/fake data (required for local-ready testing; never default-apply seed to hosted Azure SQL).
6. Configure the app’s local SA password (`LocalSql:SaPassword` user-secrets and/or `MSSQL_SA_PASSWORD`) and run the application. ASP.NET Core Identity / EF migrations (if used) apply on startup as configured by the app.

Apps that own business schema **must** maintain `sql/seed/` and update it in the same change set as schema changes (see [database.md](database.md)).

### SSMS / Azure Data Studio

| Setting | Value |
| --- | --- |
| Server | `localhost,1433` |
| Auth | SQL Server Authentication (`sa` + `.env` password) |
| Trust server certificate | Yes (local Docker) |

### Agents

Product `README_AI.md` / `AGENTS.md` should describe how to bring up the local sandbox autonomously (Docker → init → seed → `dotnet run`) without using Azure SQL for routine verification. Never commit or print `.env` passwords.

## What belongs where

| Location | Owns |
| --- | --- |
| **STANDARDS** `docs/local-database.md` + `templates/local-sql/` | Org pattern and copy-paste starter |
| **Each app repo** | `docker-compose.yml`, `.env.example`, gitignored `.env`, init/seed scripts, Development connection wiring, README / README_AI local run steps |
| **Each app** `sql/current_model/` | Business schema scripts applied into the local DB |
| **Each app** `sql/seed/` | Required local-only sample data (keep in sync with schema) |

## Hosted vs local (do not mix)

| | Local sandbox | Hosted (e.g. DV) |
| --- | --- | --- |
| Engine | SQL Server container | Azure SQL |
| Auth | SQL login (`sa` or local login) | Managed Identity / Entra Default |
| Secrets | `.env` / User Secrets | App Service settings (no SQL password for the app) |
