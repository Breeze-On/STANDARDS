# Local database sandbox

Standard for running a **local SQL Server** in Docker so Breeze On applications can develop and test without consuming Azure SQL or Entra tokens.

Hosted environments (DV / PP / PR) remain **Azure SQL** with Managed Identity (or Entra Default for operators). Local password authentication is **local only** — never use SQL `sa` passwords against Azure SQL.

## Purpose

- Same engine dialect as production: **SQL Server / T-SQL** (see [database.md](database.md)).
- No Azure SQL DTU/vCore use and no Entra token use for routine local runs.
- Each application applies its own `sql/current_model/` scripts against a local database.

## Prerequisites (developer machine)

1. [Docker Desktop](https://www.docker.com/products/docker-desktop/) installed and running (Windows with WSL2 is fine).
2. A strong **SA password** that meets SQL Server complexity (at least 8 characters, upper, lower, number, symbol). Store it only in a **gitignored** `.env` and/or .NET User Secrets — never commit it and never paste it into chat or tickets.
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
5. Run the application. ASP.NET Core Identity / EF migrations (if used) apply on startup as configured by the app.

## What belongs where

| Location | Owns |
| --- | --- |
| **STANDARDS** `docs/local-database.md` + `templates/local-sql/` | Org pattern and copy-paste starter |
| **Each app repo** | `docker-compose.yml`, `.env.example`, gitignored `.env`, init script, Development connection wiring, app README “run locally” steps |
| **Each app** `sql/current_model/` | Business schema scripts applied into the local DB |

## Hosted vs local (do not mix)

| | Local sandbox | Hosted (e.g. DV) |
| --- | --- | --- |
| Engine | SQL Server container | Azure SQL |
| Auth | SQL login (`sa` or local login) | Managed Identity / Entra Default |
| Secrets | `.env` / User Secrets | App Service settings (no SQL password for the app) |
