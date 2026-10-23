# ADR-003: Azure SQL with local Docker SQL

Status: Accepted

## Context

ADM and other applications that own relational data need SQL Server / T-SQL compatibility. Hosted DV uses Azure SQL with Managed Identity so the App Service does not embed SQL passwords. Routine local development previously depended on Azure SQL and Entra tokens, which consumes cloud resources and complicates agent and developer workflows. A local SQL Server container provides the same dialect without Azure for day-to-day work.

## Decision

- **Hosted data:** Microsoft **Azure SQL** / SQL Server (T-SQL) for environments such as ADM DV, with app access via **Managed Identity** (operators may use Entra Default where documented).
- **Local development default:** **SQL Server in Docker** (`BreezeOnLocal` for ADM), SQL authentication via gitignored `.env` / User Secrets — not Azure SQL for routine runs.
- Schema ownership follows `sql/current_model/`, `docs/db-model.md`, and local-only `sql/seed/` per [database.md](../docs/database.md) and [local-database.md](../docs/local-database.md).
- Do not introduce a second relational engine for the same application without an explicit org decision and STANDARDS update.

## Consequences

- Local and hosted connection strings and auth differ by design; Development must not default to Azure SQL.
- Seed scripts apply to local Docker only unless explicitly directed otherwise.
- Agents can bring up Docker → init → seed → `dotnet run` without Entra for routine verification.
- Hosted App Service settings hold Managed Identity connection strings, not SQL passwords.
