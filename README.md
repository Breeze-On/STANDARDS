# Breeze On — STANDARDS

Owner: Documentation

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

Full rules: [`docs/documentation.md`](docs/documentation.md) (includes lightweight document ownership metadata and advisory periodic review). Glossary: [`docs/glossary.md`](docs/glossary.md). ADR process: [`docs/adr.md`](docs/adr.md).

## How this repository answers questions

| Question | Where |
| --- | --- |
| Where should an AI agent start? | [`docs/ai/BREEZEON-AI-QUICKSTART.md`](docs/ai/BREEZEON-AI-QUICKSTART.md) (see [`docs/ai/`](docs/ai/)) |
| What exists? | [`architecture/`](architecture/) — start at [landscape](architecture/landscape.md) |
| How do we work? | [`docs/`](docs/) |
| Why was this decision made? | [`decisions/`](decisions/) (ADRs) |
| What does this term mean? | [`docs/glossary.md`](docs/glossary.md) |
| What defines a Breeze On application? | [`docs/application-model.md`](docs/application-model.md) |
| How are environments defined? | [`docs/environments.md`](docs/environments.md) |
| What are the UI standards? | [`docs/ui/overview.md`](docs/ui/overview.md) |
| How do I build a compliant page? | [`docs/ui/page-development.md`](docs/ui/page-development.md) |
| Is there a testing / observability / versioning standard yet? | Placeholder docs under `docs/` (status: not yet formally defined) |
| Where are operational runbooks? | [`runbooks/README.md`](runbooks/README.md) |

## Repository structure

Standards, architecture, and decisions are separated on purpose.

```text
STANDARDS/
├─ README.md                 # This file — humans, index, structure
├─ README_AI.md              # Agents — mandate and how to use this repo
├─ docs/                     # Standards, conventions, governance
│  ├─ ai/                    # AI onboarding (quickstart first)
│  ├─ documentation.md
│  ├─ glossary.md            # Shared vocabulary (current usage)
│  ├─ adr.md
│  ├─ naming.md
│  ├─ engineering.md
│  ├─ database.md
│  ├─ local-database.md
│  ├─ local-development-scripts.md  # Local Development Script Standard (dev-reset.ps1)
│  ├─ environments.md
│  ├─ application-model.md
│  ├─ domain-modeling.md     # Placeholder — not yet formally defined
│  ├─ testing.md             # Placeholder — not yet formally defined
│  ├─ security-governance.md # Placeholder — distinct from architecture/security.md
│  ├─ observability.md       # Placeholder — not yet formally defined
│  ├─ versioning.md          # Placeholder — not yet formally defined
│  ├─ ui-components.md       # Redirect stub → docs/ui/
│  └─ ui/                    # UI standards (hierarchical by responsibility)
│     ├─ overview.md
│     ├─ page-development.md # Page-construction checklist
│     ├─ foundations/        # tokens, typography, i18n
│     ├─ shell/              # shell, navigation
│     ├─ layout/             # sections, layout (Row)
│     └─ controls/           # forms
├─ runbooks/                 # Operational runbooks (sparse today)
│  └─ README.md
├─ decisions/                # Architecture Decision Records (ADRs)
├─ templates/
│  └─ local-sql/             # Docker SQL sandbox starter (copy into app repos)
└─ architecture/             # Currently implemented systems only
   ├─ README.md
   ├─ landscape.md
   ├─ ecosystem.md
   ├─ adm.md
   └─ security.md
```

### `docs/` — standards

Conventions, rules, development practices, naming, documentation requirements, engineering decisions, UI patterns, environments, application model, and ADR process. Answers: **how we work**.

### `decisions/` — ADRs

Architecture Decision Records. Answers: **why** a significant decision was made. Index: [`decisions/README.md`](decisions/README.md).

### `architecture/` — current systems

Descriptions of **implemented** Breeze On systems, platform structure, application responsibilities, and security architecture as they exist today. Answers: **what exists**. Index: [`architecture/README.md`](architecture/README.md).

Do not mix speculative design into these trees. If it is not real yet, it does not belong here.

## Contents

### Standards (`docs/`)

| Document | Covers |
| --- | --- |
| [Documentation](docs/documentation.md) | Current-reality rules; ownership metadata; advisory review; README / README_AI; ADRs; update duty |
| [Glossary](docs/glossary.md) | Shared vocabulary (current usage only) |
| [ADR process](docs/adr.md) | When and how to write Architecture Decision Records |
| [Naming](docs/naming.md) | Org, repos, projects, display names |
| [Engineering](docs/engineering.md) | Stack and repo shape in use |
| [Database](docs/database.md) | NVARCHAR lengths; NOT NULL rules; sql/current_model; seed; per-app `docs/db-model.md` |
| [Local database](docs/local-database.md) | SQL Server Docker sandbox for local development |
| [Local development scripts](docs/local-development-scripts.md) | Single entry: `dev-reset.ps1`; secrets via `.env` |
| [Environments](docs/environments.md) | Local, DEV, UAT, PRD; hosted seed labels; GitHub Environment names |
| [Application model](docs/application-model.md) | What constitutes a Breeze On application (current patterns) |
| [UI standards](docs/ui/overview.md) | Shared UI conventions (`docs/ui/` hierarchical tree) |
| [Domain modeling](docs/domain-modeling.md) | Placeholder — not yet formally defined |
| [Testing](docs/testing.md) | Placeholder — not yet formally defined |
| [Security governance](docs/security-governance.md) | Placeholder — future governance (see also [architecture/security.md](architecture/security.md)) |
| [Observability](docs/observability.md) | Placeholder — not yet formally defined |
| [Versioning](docs/versioning.md) | Placeholder — not yet formally defined |

### Runbooks

| Path | Covers |
| --- | --- |
| [runbooks/](runbooks/README.md) | Operational procedures home (little content today) |

### Decisions (`decisions/`)

| ADR | Title | Status | Category | Impact Area |
| --- | --- | --- | --- | --- |
| [ADR-001](decisions/ADR-001-multi-repository-model.md) | Multi-repository model | Accepted | Governance | Organization / all repositories |
| [ADR-002](decisions/ADR-002-blazor-interactive-server.md) | Blazor Interactive Server | Accepted | Platform | Applications, Shared UI gallery |
| [ADR-003](decisions/ADR-003-azure-sql-with-local-docker-sql.md) | Azure SQL with local Docker SQL | Accepted | Data | Applications with databases, Hosting |
| [ADR-004](decisions/ADR-004-breezeon-ui-abstraction-layer.md) | BreezeOn.UI abstraction layer | Accepted | UI | Shared UI, Product applications |

Full index: [`decisions/README.md`](decisions/README.md).

### Templates

| Path | Covers |
| --- | --- |
| [templates/local-sql/](templates/local-sql/) | Starter `docker-compose.yml` and `.env.example` for local SQL Server |

### Architecture (`architecture/`)

| Document | Covers |
| --- | --- |
| [Landscape](architecture/landscape.md) | Ecosystem map: repos, UI position, Azure hosting, SQL, boundaries |
| [Ecosystem](architecture/ecosystem.md) | Org layout and existing repositories |
| [ADM](architecture/adm.md) | Administration application (current) |
| [Security](architecture/security.md) | Auth and access as implemented |

Index: [`architecture/README.md`](architecture/README.md).

## Agent expectations

- Treat **STANDARDS** as the single source of truth for org-wide rules, current architecture, and ADRs.
- Review **existing ADRs** before introducing new architecture patterns.
- Product repo `README_AI.md` files must **reference** [`STANDARDS/README_AI.md`](README_AI.md), hold **repo-specific** context only, and **avoid duplicating** organization-wide standards.

## Related

- [`README_AI.md`](README_AI.md) — required reading for planning and coding agents
- Org profile: [Breeze-On/.github](https://github.com/Breeze-On/.github)
