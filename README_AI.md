# README_AI — STANDARDS

Required context for AI agents working in any **Breeze-On** repository.

This file documents how the **STANDARDS** repository is structured and how agents must use it. Keep this file synchronized with the actual contents of this repo.

## Single source of truth

`Breeze-On/STANDARDS` governs consistency across the Breeze On ecosystem:

- **Standards** (`docs/`) — how we work
- **Architecture** (`architecture/`) — what exists today

Product repositories must not restate org-wide standards at length. Their `README_AI.md` files **reference this file** and add **repository-specific** context only.

## Documentation philosophy (highest priority)

Documentation = **CURRENT REALITY ONLY**.

- Document implemented functionality only.
- Document existing architecture only.
- Document actual standards currently in use.
- Do **not** document planned features, future architecture, roadmaps, or intended behavior as if they exist.
- When code, architecture, standards, or behavior change, update documentation in the **same change set**.
- `README.md` and `README_AI.md` are living documents; they must remain synchronized with implementation state.

Details: [`docs/documentation.md`](docs/documentation.md).

## Repository structure (this repo)

```text
STANDARDS/
├─ README.md
├─ README_AI.md
├─ docs/                 # standards, conventions, governance
│  ├─ documentation.md
│  ├─ naming.md
│  ├─ engineering.md
│  └─ ui-components.md
└─ architecture/         # currently implemented systems only
   ├─ ecosystem.md
   ├─ adm.md
   └─ security.md
```

| Path | Purpose |
| --- | --- |
| `docs/` | Standards, conventions, rules, practices, naming, documentation requirements, engineering decisions, UI patterns, governance |
| `architecture/` | Currently implemented systems, platform structure, application responsibilities, security architecture |

If you add or remove files under `docs/` or `architecture/`, update **this** `README_AI.md` and the root `README.md` in the same change set.

## Mandate (every Breeze On task)

1. Follow org STANDARDS (this repository).
2. Update documentation when you change reality (product README / README_AI and/or STANDARDS).
3. Current state only — never invent or document the future as present.
4. Do not duplicate org standards into product repos — link here; keep product `README_AI.md` thin.

## How to use

Before planning or implementing in a Breeze On repo:

1. Read this file and [`docs/documentation.md`](docs/documentation.md).
2. Read other `docs/*` and `architecture/*` files relevant to the task.
3. Read that product repo’s `README_AI.md` for **local** scope only.
4. If you introduce a lasting convention or a new implemented system, document it here (`docs/` or `architecture/`) as current state — do not invent a one-off undocumented rule.

## Product README_AI expectations

Each product `README_AI.md` should:

- Reference **this** file (`Breeze-On/STANDARDS` → `README_AI.md`).
- Contain only repository-specific context (role, local stack surface, boundaries).
- Avoid copying organization-wide standards or architecture that already live here.

## Ecosystem key message

One ecosystem. Multiple purpose-built applications. Process-driven intelligence.

**Principles:** Objective → Process → Decision → Action → Outcome
