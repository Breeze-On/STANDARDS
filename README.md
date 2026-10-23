# Breeze On — STANDARDS

Organization-wide **standards** and **current-state architecture** for every Breeze On repository.

**Canonical repo:** [Breeze-On/STANDARDS](https://github.com/Breeze-On/STANDARDS)

This repository is the single source of truth for how Breeze On builds and documents software. All product and platform repos must follow it.

## Documentation philosophy (highest priority)

Documentation must represent **CURRENT REALITY ONLY**.

| Do | Do not |
| --- | --- |
| Document implemented functionality | Document planned features |
| Document existing architecture | Document future architecture |
| Document standards actually in use | Document roadmap items or intended behavior as if they exist |
| Record accepted architectural decisions as ADRs | Use ADRs to speculate about unimplemented designs |
| Update docs in the **same change set** when code, architecture, standards, or behavior change | Leave README / README_AI / ADRs stale after a change |

`README.md` and `README_AI.md` (here and in every repo) are **living documents** and must stay synchronized with the current implementation state.

Full rules: [`docs/documentation.md`](docs/documentation.md). ADR process: [`docs/adr.md`](docs/adr.md).

## How this repository answers questions

| Question | Where |
| --- | --- |
| What exists? | [`architecture/`](architecture/) |
| How do we work? | [`docs/`](docs/) |
| Why was this decision made? | [`decisions/`](decisions/) (ADRs) |
| What defines a Breeze On application? | [`docs/application-model.md`](docs/application-model.md) |
| How are environments defined? | [`docs/environments.md`](docs/environments.md) |

## Repository structure

Standards, architecture, and decisions are separated on purpose.

```text
STANDARDS/
├─ README.md                 # This file — humans, index, structure
├─ README_AI.md              # Agents — mandate and how to use this repo
├─ docs/                     # Standards, conventions, governance
│  ├─ documentation.md
│  ├─ adr.md
│  ├─ naming.md
│  ├─ engineering.md
│  ├─ database.md
│  ├─ local-database.md
│  ├─ environments.md
│  ├─ application-model.md
│  └─ ui-components.md
├─ decisions/                # Architecture Decision Records (ADRs)
├─ templates/
│  └─ local-sql/             # Docker SQL sandbox starter (copy into app repos)
└─ architecture/             # Currently implemented systems only
   ├─ ecosystem.md
   ├─ adm.md
   └─ security.md
```

### `docs/` — standards

Conventions, rules, development practices, naming, documentation requirements, engineering decisions, UI patterns, environments, application model, and ADR process. Answers: **how we work**.

### `decisions/` — ADRs

Architecture Decision Records. Answers: **why** a significant decision was made. Index: [`decisions/README.md`](decisions/README.md).

### `architecture/` — current systems

Descriptions of **implemented** Breeze On systems, platform structure, application responsibilities, and security architecture as they exist today. Answers: **what exists**.

Do not mix speculative design into these trees. If it is not real yet, it does not belong here.

## Contents

### Standards (`docs/`)

| Document | Covers |
| --- | --- |
| [Documentation](docs/documentation.md) | Current-reality rules; README / README_AI; ADRs; update duty |
| [ADR process](docs/adr.md) | When and how to write Architecture Decision Records |
| [Naming](docs/naming.md) | Org, repos, projects, display names |
| [Engineering](docs/engineering.md) | Stack and repo shape in use |
| [Database](docs/database.md) | NVARCHAR lengths; NOT NULL rules; sql/current_model; seed; per-app `docs/db-model.md` |
| [Local database](docs/local-database.md) | SQL Server Docker sandbox for local development |
| [Environments](docs/environments.md) | Local and DV environment definitions; hosted seed labels |
| [Application model](docs/application-model.md) | What constitutes a Breeze On application (current patterns) |
| [UI components](docs/ui-components.md) | Shared UI conventions in use |

### Decisions (`decisions/`)

| ADR | Title | Status |
| --- | --- | --- |
| [ADR-001](decisions/ADR-001-multi-repository-model.md) | Multi-repository model | Accepted |
| [ADR-002](decisions/ADR-002-blazor-interactive-server.md) | Blazor Interactive Server | Accepted |
| [ADR-003](decisions/ADR-003-azure-sql-with-local-docker-sql.md) | Azure SQL with local Docker SQL | Accepted |
| [ADR-004](decisions/ADR-004-breezeon-ui-abstraction-layer.md) | BreezeOn.UI abstraction layer | Accepted |

Full index: [`decisions/README.md`](decisions/README.md).

### Templates

| Path | Covers |
| --- | --- |
| [templates/local-sql/](templates/local-sql/) | Starter `docker-compose.yml` and `.env.example` for local SQL Server |

### Architecture (`architecture/`)

| Document | Covers |
| --- | --- |
| [Ecosystem](architecture/ecosystem.md) | Org layout and existing repositories |
| [ADM](architecture/adm.md) | Administration application (current) |
| [Security](architecture/security.md) | Auth and access as implemented |

## Agent expectations

- Treat **STANDARDS** as the single source of truth for org-wide rules, current architecture, and ADRs.
- Review **existing ADRs** before introducing new architecture patterns.
- Product repo `README_AI.md` files must **reference** [`STANDARDS/README_AI.md`](README_AI.md), hold **repo-specific** context only, and **avoid duplicating** organization-wide standards.

## Related

- [`README_AI.md`](README_AI.md) — required reading for planning and coding agents
- Org profile: [Breeze-On/.github](https://github.com/Breeze-On/.github)
