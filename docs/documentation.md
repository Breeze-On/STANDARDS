# Documentation standards

Owner: Documentation

Applies to every Breeze On repository, including STANDARDS itself.

## Philosophy (highest priority)

Documentation must represent **CURRENT REALITY ONLY**.

### Rules

1. Document **implemented** functionality only.
2. Document **existing** architecture only.
3. Document **actual** standards currently in use.
4. Do **not** document planned features **as if they are shipped**.
5. Do **not** document future architecture **as current**.
6. Do **not** document roadmap items or intended behavior as if they exist.
7. **Exception (structure only):** a clearly labeled **Planned / not shipped** section may reserve headings for an upcoming capability (example: Nested View under [`docs/ui/controls/grids.md`](ui/controls/grids.md)). It must not imply API availability or product usage.
8. Whenever code, architecture, standards, ADRs, or behavior change, update documentation in the **same change set**.
9. `README.md`, `README_AI.md`, and Architecture Decision Records (ADRs) are living documents and must remain synchronized with the current implementation state.

## Glossary

Shared vocabulary for humans and agents: [`glossary.md`](glossary.md). Prefer linking to glossary entries instead of inventing alternate definitions in product docs.

## Document ownership metadata

Major STANDARDS documents may include a single lightweight line near the top:

```text
Owner: <area>
```

Allowed values (documentation ownership areas only):

| Value | Typical documents |
| --- | --- |
| `Architecture` | `architecture/*`, ADR process / decision index |
| `Engineering` | Stack, database, environments, application model |
| `UI` | `docs/ui/*` |
| `Documentation` | Documentation standards, glossary, naming, placeholders for undeclared areas |
| `Operations` | `runbooks/` |
| `Product` | Product-facing application descriptions when ownership is product-scoped |

**What this is:** a discoverability hint for maintainers about which organizational **area** a document belongs to.

**What this is not:** an approval workflow, a permission model, a review board, named individuals or teams, or a gate before merging.

Do not invent additional owner labels or assign personal names. Omit the line on trivial stubs/redirects when it adds no value.

## Periodic review (advisory)

Documentation should be **reviewed periodically** so it continues to reflect **current reality**.

When reviewing (or when drift is noticed during normal work):

- Confirm content still matches implemented systems and standards in use
- **Remove** obsolete content when discovered
- **Correct** broken references when discovered
- Update related indexes in the same change set when structure or links change

This guidance is **advisory and pragmatic**. It does **not** create mandatory review cycles, compliance checklists, scheduled governance meetings, or formal sign-off processes. Same-change-set updates when reality changes remain the primary duty ([Definition of Done](#definition-of-done)).

## STANDARDS repo layout

| Tree | Holds |
| --- | --- |
| `docs/` | Standards and governance (how we work); glossary: [`glossary.md`](glossary.md) |
| `docs/ai/` | AI onboarding path (mandatory quickstart first); index: [`ai/README.md`](ai/README.md) |
| `docs/local-development-scripts.md` | Org Local Development Script Standard (`dev-reset.ps1` only) |
| `docs/hosted-deployment.md` | Canonical hosted deploy standard (App Service, publish profile, GitHub Environments) |
| `docs/ui/` | Hierarchical UI standards (entry: [`ui/overview.md`](ui/overview.md); page checklist: [`ui/page-development.md`](ui/page-development.md)); folders: `foundations/`, `shell/`, `layout/`, `controls/` |
| `runbooks/` | Operational procedures (sparse today); index: [`../runbooks/README.md`](../runbooks/README.md) — deploy **standard** lives in `hosted-deployment.md` |
| `architecture/` | Descriptions of systems that exist now (what exists); landscape map: [`../architecture/landscape.md`](../architecture/landscape.md) |
| `decisions/` | Architecture Decision Records (why decisions were made); index with Category / Impact Area: [`../decisions/README.md`](../decisions/README.md) |

Do not place unimplemented designs in these trees.

### Placeholder standards (undeclared governance areas)

Some `docs/` files exist only to record that an area is **not yet formally defined** (e.g. [`domain-modeling.md`](domain-modeling.md), [`testing.md`](testing.md), [`security-governance.md`](security-governance.md), [`observability.md`](observability.md), [`versioning.md`](versioning.md)). Those placeholders:

- State the **current reality** that no org-wide standard exists yet
- May list topics expected to be covered **later**, without defining rules
- Must not invent requirements, strategies, or implementation mandates

Update a placeholder into a real standard only when conventions are agreed and in use.

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

1. Point agents to [`docs/ai/BREEZEON-AI-QUICKSTART.md`](https://github.com/Breeze-On/STANDARDS/blob/main/docs/ai/BREEZEON-AI-QUICKSTART.md) first, then [`STANDARDS/README_AI.md`](https://github.com/Breeze-On/STANDARDS/blob/main/README_AI.md).
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
- STANDARDS `docs/` (including modular `docs/ui/` when UI standards change) and/or `architecture/` as applicable
- **ADRs** created, updated, or superseded when architectural decisions are affected (update [`decisions/README.md`](../decisions/README.md) Category / Impact Area columns)
- Indexes and cross-references kept accurate

Updates must occur in the **same change set** as the implementation change. Documentation maintenance is part of **Definition of Done**.

### UI / shared component DoD (BreezeOn.UI)

For work on public `Bo*` components, tokens, or gallery standards, also treat these as incomplete without a docs update in the same change set:

| Change | Documentation update |
| --- | --- |
| New feature / mode | STANDARDS `docs/ui/` SSOT + thin product README / README_AI |
| New public parameter | Parameter tables in the owning control doc |
| UX / visual standard change | UX section of the owning doc (+ tokens/sections/shell as needed) |
| Design standard change | STANDARDS `docs/ui/` + overview cross-links |
| Refactor that changes behavior | Same docs as a feature change; remove obsolete statements |

Examples must match the latest component behavior. Remove documentation that no longer matches implementation.
