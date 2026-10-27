# README_AI — STANDARDS

Owner: Documentation

Required context for AI agents working in any **Breeze-On** repository.

## Start here (mandatory)

**Before any analysis, planning, or implementation**, read:

1. [`docs/ai/BREEZEON-AI-QUICKSTART.md`](docs/ai/BREEZEON-AI-QUICKSTART.md) — org orientation in minutes  
2. Then [`docs/ai/README.md`](docs/ai/README.md) for reading order  

Do **not** ingest every STANDARDS file by default. Use the quickstart, then open detailed docs only as needed.

This file documents how the **STANDARDS** repository is structured and how agents must use it. Keep this file synchronized with the actual contents of this repo.

## Single source of truth

`Breeze-On/STANDARDS` governs consistency across the Breeze On ecosystem:

- **Standards** (`docs/`) — how we work
- **Architecture** (`architecture/`) — what exists today
- **Decisions** (`decisions/`) — why significant architectural choices were made (ADRs)

Product repositories must not restate org-wide standards at length. Their `README_AI.md` files **reference this file** and add **repository-specific** context only.

## Documentation philosophy (highest priority)

Documentation = **CURRENT REALITY ONLY**.

- Document implemented functionality only.
- Document existing architecture only.
- Document actual standards currently in use.
- Do **not** document planned features, future architecture, roadmaps, or intended behavior as if they exist.
- When code, architecture, standards, ADRs, or behavior change, update documentation in the **same change set**.
- `README.md`, `README_AI.md`, and ADRs are living documents; they must remain synchronized with implementation state.

Details: [`docs/documentation.md`](docs/documentation.md). ADR process: [`docs/adr.md`](docs/adr.md).

## How to answer common questions

| Question | Where |
| --- | --- |
| Where do I start as an AI agent? | [`docs/ai/BREEZEON-AI-QUICKSTART.md`](docs/ai/BREEZEON-AI-QUICKSTART.md) |
| AI standards / adoption summaries? | [`docs/ai/`](docs/ai/) |
| What exists? | `architecture/` — start at [`architecture/landscape.md`](architecture/landscape.md) |
| How do we work? | `docs/` |
| Why was this decided? | `decisions/` (ADRs) — index [`decisions/README.md`](decisions/README.md) |
| What does this term mean? | [`docs/glossary.md`](docs/glossary.md) |
| What is a Breeze On application? | [`docs/application-model.md`](docs/application-model.md) |
| What do environments mean? | [`docs/environments.md`](docs/environments.md) |
| What are the UI standards? | [`docs/ui/overview.md`](docs/ui/overview.md) |
| How do I build a compliant page? | [`docs/ui/page-development.md`](docs/ui/page-development.md) — checklist; then detailed `docs/ui/*` |
| Is testing / observability / versioning / domain modeling standardized? | Placeholder `docs/*.md` files — **not yet formally defined**; do not invent rules |
| Where are operational runbooks? | [`runbooks/README.md`](runbooks/README.md) |

## Repository structure (this repo)

```text
STANDARDS/
├─ README.md
├─ README_AI.md
├─ docs/                 # standards, conventions, governance
│  ├─ ai/                # AI onboarding (quickstart first)
│  ├─ documentation.md
│  ├─ glossary.md        # shared vocabulary (current usage)
│  ├─ adr.md
│  ├─ naming.md
│  ├─ engineering.md
│  ├─ database.md
│  ├─ local-database.md
│  ├─ local-development-scripts.md
│  ├─ environments.md
│  ├─ application-model.md
│  ├─ domain-modeling.md / testing.md / security-governance.md /
│  │    observability.md / versioning.md   # placeholders (not yet formally defined)
│  ├─ ui-components.md   # redirect stub → docs/ui/
│  └─ ui/                # UI standards (hierarchical by responsibility)
│     ├─ overview.md
│     ├─ page-development.md  # page-construction checklist
│     ├─ foundations/    # tokens, typography, i18n
│     ├─ shell/          # shell, navigation
│     ├─ layout/         # sections, layout (Row)
│     └─ controls/       # forms
├─ runbooks/             # operational runbooks (sparse today)
│  └─ README.md
├─ decisions/            # Architecture Decision Records
├─ templates/
│  └─ local-sql/         # Docker SQL sandbox starter for app repos
└─ architecture/         # currently implemented systems only
   ├─ README.md
   ├─ landscape.md
   ├─ ecosystem.md
   ├─ adm.md
   └─ security.md
```

| Path | Purpose |
| --- | --- |
| `docs/` | Standards, conventions, rules, practices, naming, documentation requirements, engineering decisions, UI patterns, environments, application model, ADR process |
| `docs/glossary.md` | Shared vocabulary — current usage only; do not invent terms |
| `docs/documentation.md` | Current-reality rules; lightweight `Owner:` metadata; advisory periodic review (not mandatory cycles) |
| `docs/ui/` | Hierarchical UI standards (entry: `overview.md`); folders: `foundations/`, `shell/`, `layout/`, `controls/` |
| `docs/*` placeholders | `domain-modeling`, `testing`, `security-governance`, `observability`, `versioning` — state that org standards are **not yet formally defined** (do not invent rules there) |
| `runbooks/` | Operational procedures; little content today — see `runbooks/README.md` |
| `decisions/` | ADRs (why decisions were made); index includes Category and Impact Area |
| `templates/` | Copy-paste starters for apps (e.g. local SQL Docker) |
| `architecture/` | Currently implemented systems, landscape map, platform structure, application responsibilities, security architecture (`architecture/security.md` ≠ `docs/security-governance.md`) |

If you add or remove files under `docs/`, `decisions/`, or `architecture/`, update **this** `README_AI.md` and the root `README.md` in the same change set.

## Mandate (every Breeze On task)

1. Follow org STANDARDS (this repository).
2. **Review existing ADRs** before introducing new architecture patterns.
3. Update documentation when you change reality (product README / README_AI and/or STANDARDS, including ADRs when architectural decisions change).
4. Current state only — never invent or document the future as present.
5. Do not duplicate org standards into product repos — link here; keep product `README_AI.md` thin.
6. Treat documentation maintenance (including ADRs and accurate references) as part of **completion criteria** — avoid documentation drift.

## How to use

Before planning or implementing in a Breeze On repo:

0. Read [`docs/ai/BREEZEON-AI-QUICKSTART.md`](docs/ai/BREEZEON-AI-QUICKSTART.md) (mandatory).
1. Read this file and [`docs/documentation.md`](docs/documentation.md) as needed for STANDARDS navigation.
2. Use [`docs/glossary.md`](docs/glossary.md) for shared terminology; do not invent alternate definitions.
3. Read [`docs/adr.md`](docs/adr.md) and relevant files under [`decisions/`](decisions/).
4. Read other `docs/*` and `architecture/*` files relevant to the task (for topology: [`architecture/landscape.md`](architecture/landscape.md); for UI: [`docs/ui/overview.md`](docs/ui/overview.md)).
5. Read that product repo’s `README_AI.md` for **local** scope only.
6. If you introduce a lasting convention or a new implemented system, document it here (`docs/` or `architecture/`) as current state — do not invent a one-off undocumented rule.
7. If you introduce or change a **significant architectural decision**, create or update an ADR in `decisions/` (or supersede an existing one) in the **same change set**.
8. For database work: follow [`docs/database.md`](docs/database.md). Product apps that own schema must update `sql/current_model/`, `docs/db-model.md`, and `sql/seed/` together.
9. For local database work: follow [`docs/local-database.md`](docs/local-database.md); do not point Development at Azure SQL by default. For one-command local bring-up: [`docs/local-development-scripts.md`](docs/local-development-scripts.md) (`.\scripts\dev-reset.ps1` only — do not invent `dev-up` / `dev-down` or alternate startup scripts).
10. For environment naming: follow [`docs/environments.md`](docs/environments.md); do not redefine environments independently in product docs.
11. For what an application repo must include: follow [`docs/application-model.md`](docs/application-model.md).
12. For UI standards: start with the page checklist [`docs/ui/page-development.md`](docs/ui/page-development.md), then [`docs/ui/overview.md`](docs/ui/overview.md) and docs under `foundations/`, `shell/`, `layout/`, `controls/`; when docs grow too large, deepen the hierarchy and update the UI index (organic structure rule in the overview).
13. Placeholder docs (`domain-modeling`, `testing`, `security-governance`, `observability`, `versioning`) mean **no org standard yet** — do not invent requirements there; update them only when conventions are actually established.
14. For operational procedures: see [`runbooks/README.md`](runbooks/README.md); add runbooks only from real procedures.
15. Major STANDARDS docs may carry lightweight `Owner:` metadata (area label only — not an approval workflow); see [`docs/documentation.md`](docs/documentation.md).

## Product README_AI expectations

Each product `README_AI.md` should:

- Point agents first to [`docs/ai/BREEZEON-AI-QUICKSTART.md`](docs/ai/BREEZEON-AI-QUICKSTART.md), then **this** file.
- Contain only repository-specific context (role, local surface, boundaries).
- Require agents to follow STANDARDS, update docs in the same change set, and update or respect ADRs when architecture changes.
- Avoid copying organization-wide standards, architecture, or ADR text that already lives here.

## Ecosystem key message

One ecosystem. Multiple purpose-built applications. Process-driven intelligence.

**Principles:** Objective → Process → Decision → Action → Outcome
