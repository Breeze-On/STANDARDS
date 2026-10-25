# README_AI — STANDARDS

Required context for AI agents working in any **Breeze-On** repository.

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
| What exists? | `architecture/` — start at [`architecture/landscape.md`](architecture/landscape.md) |
| How do we work? | `docs/` |
| Why was this decided? | `decisions/` (ADRs) — index [`decisions/README.md`](decisions/README.md) |
| What is a Breeze On application? | [`docs/application-model.md`](docs/application-model.md) |
| What do environments mean? | [`docs/environments.md`](docs/environments.md) |
| What are the UI standards? | [`docs/ui/overview.md`](docs/ui/overview.md) |

## Repository structure (this repo)

```text
STANDARDS/
├─ README.md
├─ README_AI.md
├─ docs/                 # standards, conventions, governance
│  ├─ documentation.md
│  ├─ adr.md
│  ├─ naming.md
│  ├─ engineering.md
│  ├─ database.md
│  ├─ local-database.md
│  ├─ environments.md
│  ├─ application-model.md
│  ├─ ui-components.md   # redirect stub → docs/ui/
│  └─ ui/                # UI standards (modular)
│     ├─ overview.md
│     ├─ shell.md
│     ├─ navigation.md
│     ├─ sections.md
│     ├─ layout.md
│     ├─ forms.md
│     ├─ typography.md
│     └─ tokens.md
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
| `docs/ui/` | Modular UI standards (entry: `overview.md`); grow by responsibility when documents become large |
| `decisions/` | ADRs (why decisions were made); index includes Category and Impact Area |
| `templates/` | Copy-paste starters for apps (e.g. local SQL Docker) |
| `architecture/` | Currently implemented systems, landscape map, platform structure, application responsibilities, security architecture |

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

1. Read this file and [`docs/documentation.md`](docs/documentation.md).
2. Read [`docs/adr.md`](docs/adr.md) and relevant files under [`decisions/`](decisions/).
3. Read other `docs/*` and `architecture/*` files relevant to the task (for topology: [`architecture/landscape.md`](architecture/landscape.md); for UI: [`docs/ui/overview.md`](docs/ui/overview.md)).
4. Read that product repo’s `README_AI.md` for **local** scope only.
5. If you introduce a lasting convention or a new implemented system, document it here (`docs/` or `architecture/`) as current state — do not invent a one-off undocumented rule.
6. If you introduce or change a **significant architectural decision**, create or update an ADR in `decisions/` (or supersede an existing one) in the **same change set**.
7. For database work: follow [`docs/database.md`](docs/database.md). Product apps that own schema must update `sql/current_model/`, `docs/db-model.md`, and `sql/seed/` together.
8. For local database work: follow [`docs/local-database.md`](docs/local-database.md); do not point Development at Azure SQL by default.
9. For environment naming: follow [`docs/environments.md`](docs/environments.md); do not redefine environments independently in product docs.
10. For what an application repo must include: follow [`docs/application-model.md`](docs/application-model.md).
11. For UI standards: follow [`docs/ui/overview.md`](docs/ui/overview.md) and the focused sibling docs; when docs grow too large, split by responsibility and update the UI index (organic structure rule in the overview).

## Product README_AI expectations

Each product `README_AI.md` should:

- Reference **this** file (`Breeze-On/STANDARDS` → `README_AI.md`).
- Contain only repository-specific context (role, local surface, boundaries).
- Require agents to follow STANDARDS, update docs in the same change set, and update or respect ADRs when architecture changes.
- Avoid copying organization-wide standards, architecture, or ADR text that already lives here.

## Ecosystem key message

One ecosystem. Multiple purpose-built applications. Process-driven intelligence.

**Principles:** Objective → Process → Decision → Action → Outcome
