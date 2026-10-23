# Documentation standards

Applies to every Breeze On repository, including STANDARDS itself.

## Philosophy (highest priority)

Documentation must represent **CURRENT REALITY ONLY**.

### Rules

1. Document **implemented** functionality only.
2. Document **existing** architecture only.
3. Document **actual** standards currently in use.
4. Do **not** document planned features.
5. Do **not** document future architecture.
6. Do **not** document roadmap items or intended behavior as if they exist.
7. Whenever code, architecture, standards, ADRs, or behavior change, update documentation in the **same change set**.
8. `README.md`, `README_AI.md`, and Architecture Decision Records (ADRs) are living documents and must remain synchronized with the current implementation state.

## STANDARDS repo layout

| Tree | Holds |
| --- | --- |
| `docs/` | Standards and governance (how we work) |
| `architecture/` | Descriptions of systems that exist now (what exists) |
| `decisions/` | Architecture Decision Records (why decisions were made) |

Do not place unimplemented designs in these trees.

## Architecture Decision Records

ADRs are part of the official Breeze-On documentation set. Process, lifecycle, naming, and template: [`adr.md`](adr.md). Index: [`../decisions/README.md`](../decisions/README.md).

### ADR rules

1. Significant architectural decisions must be recorded as ADRs.
2. New architectural decisions require a **new** ADR (or an update to an existing ADR when the same decision evolves).
3. Changes that replace an accepted decision require the prior ADR to be marked **Superseded** (retain the file) and a new Accepted ADR when applicable.
4. ADRs follow **Current Reality Only** — do not use them to document speculative or unimplemented futures as present.
5. Agents must **review existing ADRs** before introducing new architecture patterns.
6. ADR creates/updates/supersessions must occur in the **same change set** as the implementation change.

## README.md (humans)

- Professional, concise, current-state only.
- Describe what the repo/application **is** and how to run or use what exists today.
- Link to [Breeze-On/STANDARDS](https://github.com/Breeze-On/STANDARDS).
- Do not include roadmaps, “coming soon,” or speculative architecture.

## README_AI.md (agents)

Required in every product/platform repo.

### Organization-wide content

Belongs in **STANDARDS** (`README_AI.md`, `docs/`, `architecture/`, `decisions/`). Product files must **reference** STANDARDS rather than duplicating it.

### Product README_AI.md must

1. Reference [`STANDARDS/README_AI.md`](https://github.com/Breeze-On/STANDARDS/blob/main/README_AI.md).
2. Hold **repository-specific** context only (role, local surface, boundaries).
3. Require agents to follow STANDARDS and to **update documentation** (including ADRs when architecture changes) when a task changes reality.
4. Enforce **current state only**.
5. Treat documentation maintenance as part of completion criteria (avoid documentation drift).

Keep product `README_AI.md` high-level and thin. Not a tutorial or full org handbook.

## Org profile

The organization landing README lives in `Breeze-On/.github` → `profile/README.md`. Same current-reality rule applies.

## External review export (agents)

**Scope:** Breeze-On organization documentation only.

When a human asks an agent to **extract all `.md` documentation for external review** (or equivalent), produce a **single Markdown file** suitable for tools that do not accept zip uploads (e.g. Copilot).

| Item | Requirement |
| --- | --- |
| Sources | `STANDARDS`, `SYSTEM-ADMIN-ADM`, `SYSTEM-SHARED-UI`, `.github` (local `Projects` clones preferred; shallow `gh` clone to temp if needed) |
| Output | One `.md` under the user’s `Downloads` folder (timestamped name) |
| Format | Each source file wrapped with `DOC BEGIN` / `DOC END` plus Repository, File name, Path, and Full GitHub-style path |
| Not allowed | Zip-only delivery; creating or pushing GitHub repositories |

This is an agent workflow for the Breeze-On org, not a product feature. Cursor encodes the same procedure in a user/project rule so agents recognize the request phrase.

## Definition of Done

A change is incomplete until **all affected documentation reflects current reality**, including:

- Product `README` / `README_AI` / `AGENTS` as applicable
- STANDARDS `docs/` and/or `architecture/` as applicable
- **ADRs** created, updated, or superseded when architectural decisions are affected
- Indexes and cross-references kept accurate

Updates must occur in the **same change set** as the implementation change.
