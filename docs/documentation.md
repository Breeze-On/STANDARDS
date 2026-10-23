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
7. Whenever code, architecture, standards, or behavior change, update documentation in the **same change set**.
8. `README.md` and `README_AI.md` are living documents and must remain synchronized with the current implementation state.

## STANDARDS repo layout

| Tree | Holds |
| --- | --- |
| `docs/` | Standards and governance (how we work) |
| `architecture/` | Descriptions of systems that exist now (what exists) |

Do not place unimplemented designs in either tree.

## README.md (humans)

- Professional, concise, current-state only.
- Describe what the repo/application **is** and how to run or use what exists today.
- Link to [Breeze-On/STANDARDS](https://github.com/Breeze-On/STANDARDS).
- Do not include roadmaps, “coming soon,” or speculative architecture.

## README_AI.md (agents)

Required in every product/platform repo.

### Organization-wide content

Belongs in **STANDARDS** (`README_AI.md`, `docs/`, `architecture/`). Product files must **reference** STANDARDS rather than duplicating it.

### Product README_AI.md must

1. Reference [`STANDARDS/README_AI.md`](https://github.com/Breeze-On/STANDARDS/blob/main/README_AI.md).
2. Hold **repository-specific** context only (role, local surface, boundaries).
3. Require agents to follow STANDARDS and to **update documentation** when a task changes reality.
4. Enforce **current state only**.

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

A change is incomplete until documentation that agents and humans rely on matches the new reality (product docs and/or STANDARDS as applicable).
