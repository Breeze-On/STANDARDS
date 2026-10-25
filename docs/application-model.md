# Application model

Defines what constitutes a **standard Breeze On application** based on patterns already implemented in the ecosystem (primarily ADM). Shared libraries (e.g. `BreezeOn.UI`) follow related documentation and boundary rules but are not full applications.

## What exists today

| Kind | Example repository | Notes |
| --- | --- | --- |
| Application | [SYSTEM-ADMIN-ADM](https://github.com/Breeze-On/SYSTEM-ADMIN-ADM) | Blazor Web App, Identity, SQL ownership, DV hosting |
| Shared library | [SYSTEM-SHARED-UI](https://github.com/Breeze-On/SYSTEM-SHARED-UI) | RCL + gallery; no business DB |
| Org standards | [STANDARDS](https://github.com/Breeze-On/STANDARDS) | Not an application |

## Dedicated repository ownership

- One **GitHub repository** per application or shared concern ([ADR-001](../decisions/ADR-001-multi-repository-model.md)).
- Application code uses the `BreezeOn.*` namespace and `src/<Project>` layout (e.g. `src/BreezeOn.Adm`).
- Do not add unrelated products or business domains into an existing application repository.

## Required documentation files

| File | Role |
| --- | --- |
| `README.md` | Humans — purpose, run/deploy as implemented, links to STANDARDS and org profile |
| `README_AI.md` | Agents — thin repo-specific context; references STANDARDS; update duties |
| `AGENTS.md` | Short pointer to STANDARDS and critical repo facts |

Product READMEs stay **thin**: link to STANDARDS for org-wide rules; do not duplicate vision (org profile) or full standards.

## STANDARDS references

Every application repository must:

1. Follow [Breeze-On/STANDARDS](https://github.com/Breeze-On/STANDARDS) (start at [`README_AI.md`](../README_AI.md)).
2. Keep product docs synchronized with implementation (**Current Reality Only**).
3. Update STANDARDS `architecture/` (and ADRs when required) when org-visible reality changes.

## Documentation requirements

- Document **implemented** behavior only ([documentation.md](documentation.md)).
- Same change set: code + affected product docs + STANDARDS/ADRs as applicable.
- Apps that own business schema: maintain `docs/db-model.md`, `sql/current_model/`, and `sql/seed/` together ([database.md](database.md)).

## Local development expectations

For applications with a database (ADM pattern):

- Default local engine: SQL Server Docker sandbox ([local-database.md](local-database.md)).
- Repo typically includes `docker-compose.yml`, `.env.example`, init/seed scripts, and README steps.
- Do not default Development to Azure SQL.
- Agents follow the product `README_AI` autonomous local test steps when present.

For the Shared UI gallery: local `dotnet run` of the gallery project; no database required.

## Deployment expectations

As implemented for ADM:

- Hosted DV on Azure App Service (Linux Free F1, .NET 10 stack) with Azure SQL and Managed Identity.
- GitHub Actions deploy workflow and GitHub Environment secrets as documented in the ADM README.
- Environment naming and meaning: [environments.md](environments.md).

Shared UI is not separately hosted as a production web app; it is consumed as a library.

## Database ownership expectations

Applications that own business tables:

| Path | Role |
| --- | --- |
| `sql/current_model/` | Executable schema SSOT (T-SQL) |
| `docs/db-model.md` | Human-readable business model |
| `sql/seed/` | Local-only sample data (required; not default-applied to hosted Azure SQL) |

Identity/`AspNet*` tables (when used) are owned by ASP.NET Core Identity / EF migrations and are out of scope for `db-model.md`.

## Documentation update responsibilities

When behavior, setup, schema, or architecture changes:

1. Update implementation.
2. Update product `README` / `README_AI` / `AGENTS` as needed.
3. Update `db-model` / `current_model` / `seed` together when schema changes.
4. Update STANDARDS (`docs/`, `architecture/`, `decisions/`) when the change is org-wide or architectural.
5. Treat documentation (including ADRs) as part of **Definition of Done**.

## Repository boundaries

| Repository | Owns |
| --- | --- |
| Application repo (e.g. ADM) | That app’s UI, Identity wiring, business schema, local sandbox, deploy for that app |
| SYSTEM-SHARED-UI | `BreezeOn.UI` and gallery only |
| STANDARDS | How we work, what exists org-wide, ADRs |
| `.github` profile | Vision / mission / ecosystem messaging only |

Applications that adopt the shared design system consume Shared UI via the public `Bo*` API; they do not own the design-system implementation. Current topology (including whether a given app already references `BreezeOn.UI`): [architecture/landscape.md](../architecture/landscape.md). UI standards: [docs/ui/overview.md](ui/overview.md).
