# Template: local SQL Server (Docker)

Copy `docker-compose.yml` and `.env.example` into an application repository root. Create a gitignored `.env` from `.env.example` and set `MSSQL_SA_PASSWORD`.

Full standard: [docs/local-database.md](../../docs/local-database.md).

Each app must add its own init script to create `{Logical}Local` and apply `sql/current_model/`.
