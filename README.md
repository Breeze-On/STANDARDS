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
| Update docs in the **same change set** when code, architecture, standards, or behavior change | Leave README / README_AI stale after a change |

`README.md` and `README_AI.md` (here and in every repo) are **living documents** and must stay synchronized with the current implementation state.

Full rules: [`docs/documentation.md`](docs/documentation.md).

## Repository structure

Standards and architecture are separated on purpose.

```text
STANDARDS/
├─ README.md                 # This file — humans, index, structure
├─ README_AI.md              # Agents — mandate and how to use this repo
├─ docs/                     # Standards, conventions, governance
│  ├─ documentation.md
│  ├─ naming.md
│  ├─ engineering.md
│  ├─ database.md
│  └─ ui-components.md
└─ architecture/             # Currently implemented systems only
   ├─ ecosystem.md
   ├─ adm.md
   └─ security.md
```

### `docs/` — standards

Conventions, rules, development practices, naming, documentation requirements, engineering decisions, UI patterns, and governance. Answers: **how we work**.

### `architecture/` — current systems

Descriptions of **implemented** Breeze On systems, platform structure, application responsibilities, and security architecture as they exist today. Answers: **what exists**.

Do not mix speculative design into either tree. If it is not real yet, it does not belong here.

## Contents

### Standards (`docs/`)

| Document | Covers |
| --- | --- |
| [Documentation](docs/documentation.md) | Current-reality rules; README / README_AI; update duty |
| [Naming](docs/naming.md) | Org, repos, projects, display names |
| [Engineering](docs/engineering.md) | Stack and repo shape in use |
| [Database](docs/database.md) | NVARCHAR lengths; NOT NULL rules; sql/current_model; per-app `docs/db-model.md` |
| [UI components](docs/ui-components.md) | Shared UI conventions in use |

### Architecture (`architecture/`)

| Document | Covers |
| --- | --- |
| [Ecosystem](architecture/ecosystem.md) | Org layout and existing repositories |
| [ADM](architecture/adm.md) | Administration application (current) |
| [Security](architecture/security.md) | Auth and access as implemented |

## Agent expectations

- Treat **STANDARDS** as the single source of truth for org-wide rules and current architecture.
- Product repo `README_AI.md` files must **reference** [`STANDARDS/README_AI.md`](README_AI.md), hold **repo-specific** context only, and **avoid duplicating** organization-wide standards.

## Related

- [`README_AI.md`](README_AI.md) — required reading for planning and coding agents
- Org profile: [Breeze-On/.github](https://github.com/Breeze-On/.github)
