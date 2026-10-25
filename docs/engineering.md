# Engineering standards

Current technical defaults for Breeze On application work.

## Stack

| Layer | Standard |
| --- | --- |
| UI | Blazor Web App, Interactive Server (global interactivity); [ADR-002](../decisions/ADR-002-blazor-interactive-server.md) |
| Shared UI | `BreezeOn.UI` in [SYSTEM-SHARED-UI](https://github.com/Breeze-On/SYSTEM-SHARED-UI); see [ui/overview.md](ui/overview.md); [ADR-004](../decisions/ADR-004-breezeon-ui-abstraction-layer.md) |
| Typography | **Calibri** default UI font (hard standard via `BreezeOn.UI` / `--bo-font-family`); see [ui/foundations/typography.md](ui/foundations/typography.md) |
| Runtime | ASP.NET Core / C# / .NET 10 |
| Auth (ADM today) | ASP.NET Core Identity |
| Database | Azure SQL / SQL Server (T-SQL) + local Docker; see [database.md](database.md), [local-database.md](local-database.md); [ADR-003](../decisions/ADR-003-azure-sql-with-local-docker-sql.md) |

## Repository model

- **Multi-repo:** one repository per application or shared concern (e.g. STANDARDS, ADM). See [ADR-001](../decisions/ADR-001-multi-repository-model.md).
- Do not merge unrelated products into a single app repo.

## Local development

- Solution + `src/<Project>` layout as used in ADM.
- Ignore local databases and secrets; never commit credentials.
- **Database sandbox:** SQL Server in Docker for routine local runs (no Azure SQL / Entra tokens). Follow [local-database.md](local-database.md); copy [`templates/local-sql/`](../templates/local-sql/) into each app repo.

## Database

Relational column, nullability, SQL script, and per-app DB model conventions: [database.md](database.md).

Applications that own schema must keep `sql/current_model/` and `docs/db-model.md` current in the same change set as schema changes.

## Application shape and environments

- What a Breeze On application repository includes: [application-model.md](application-model.md).
- Environment names (Local, DV) and hosted seed labels: [environments.md](environments.md).
- Significant architectural decisions: [adr.md](adr.md) and [`decisions/`](../decisions/).

## Documentation

Engineering changes that affect how others run or understand the app must update that repo’s README / README_AI per [documentation standards](documentation.md). Cross-cutting or new implemented systems must update STANDARDS `architecture/` in the same change set when applicable. Architectural decision changes must update or supersede ADRs in the same change set.
