<!-- Classification: AA; Scope: platform -->
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
7. **Exception (structure only):** a clearly labeled **Planned / not shipped** section may reserve headings for an upcoming capability (example: a future control mode under [`docs/ui/controls/`](ui/controls/) while Nested View itself is **shipped**). It must not imply API availability or product usage.
8. Whenever code, architecture, standards, ADRs, or behavior change, update documentation in the **same change set**.
9. `README.md`, `README_AI.md`, and Architecture Decision Records (ADRs) are living documents and must remain synchronized with the current implementation state.
10. Do **not** put new technical contracts in `README.md` / `README_AI.md` / `AGENTS.md` — those files are entry points only (see [README contracts](#readmemd-humans)).

## Glossary

Shared vocabulary for humans and agents: [`glossary.md`](glossary.md). Prefer linking to glossary entries instead of inventing alternate definitions in product docs.

## Classification model (mandatory)

Every applicable markdown document in the BreezeOn documentation ecosystem (STANDARDS, SYSTEM-SHARED-UI, SYSTEM-ADMIN-EAC, `.github` profile) must carry a **lightweight classification banner** near the top of the file (immediately after any YAML frontmatter if present; otherwise as the first line).

### Banner format (standardized)

```html
```

| Token | Values |
| --- | --- |
| `<CLASS>` | `AA` · `AN` · `H` · `OPS` · `DEC` · `ENT` · `TPL` |
| `<SCOPE>` | `platform` · `shared-ui` · `application:<app>` (e.g. `application:eac`) · `org` |

### Classification meanings

| Class | Meaning |
| --- | --- |
| **AA** | Active authoritative — current-state source of truth for its scope |
| **AN** | Active non-authoritative — indexes, stubs, placeholders, AI orientation summaries, labeled vision |
| **H** | Historical / frozen — implemented plans after knowledge promotion; superseded ADR bodies retained |
| **OPS** | Operational procedure (runbooks) |
| **DEC** | Decision rationale (ADRs) |
| **ENT** | Entry point (`README.md`, `README_AI.md`, `AGENTS.md`, org profile) |
| **TPL** | Template / copy-starter |

Do **not** omit banners for “small” or “obvious” files. Consistency is required for maintainability, scalability, discoverability, and governance. Keep the banner to one line — never remove or weaken the classification approach.

Implemented plans that have completed knowledge promotion use `Classification: H` and a visible **Historical — not authoritative** note in the body.

## Document-category contracts

| Category | Responsibility |
| --- | --- |
| **Standards** (`docs/` engineering/process/UI; excluding AI orientation summaries, plans, and deviation *entries* as defined below) | Normative how-we-work / how-we-build rules for all BreezeOn apps. Current state only. |
| **Architecture** (`architecture/`) | Describes systems that exist. Not procedures. Not plans. |
| **Application references** (`architecture/applications/`) | Mature application / platform consumer / reference implementation docs. Never auto-promote to platform standards. EAC lives here as a completed-scope reference consumer — not the definition of the platform. |
| **Reference documentation** | Scope-bound contracts shared by humans and agents (e.g. SHARED-UI public `Bo*` API; EAC `docs/db-model.md`; seed READMEs). |
| **Decisions** (`decisions/`) | Why a choice was made; not the living how-to. |
| **Runbooks** (`runbooks/`) | Ordered operational procedures. May reference standards; must not redefine them. |
| **Plans** (`docs/plans/in-progress/`) | Temporary design/implementation artifacts. Never AA for shipped behavior. |
| **History** (`docs/plans/implemented/` + superseded ADRs) | Frozen record. Readable; not SSOT. |
| **Deviations** (`docs/deviations/`) | **Only** place an approved exception to a standard may be authoritative. First-class permanent governance (expected to grow). |
| **Entry points** | Navigation, precedence, required-reading routing, repo identity — never long technical contracts. |
| **Templates** | Copy-starters; not runtime SSOT. |
| **AI onboarding summaries** (`docs/ai` Quickstart / Summary / Adoption) | Orientation; must link to AA docs rather than restate contracts. |

## Source-of-truth and precedence

Highest wins on conflict:

1. Implemented code / `sql/` in the owning repository
2. STANDARDS **AA** (platform standards, platform architecture, UI behavioral standards, org process)
3. Approved **deviation** entry in [`docs/deviations/`](deviations/README.md) (must cite the standard it excepts)
4. Shared-library **AA** (SHARED-UI public component API; identity/security schema ownership docs for SQL owned by SHARED-UI)
5. Application **AA** (e.g. EAC `docs/db-model.md`, seed README; STANDARDS `architecture/applications/eac*` as application reference only)
6. Runbooks (procedure sequencing only)
7. ADRs (rationale / constraints when standards are silent)
8. Entry files (`README` / `README_AI` / `AGENTS`) — routing only
9. AI orientation summaries — non-authoritative
10. Active plans — non-authoritative for current state
11. Implemented plans / history — non-authoritative

**Conflict rule:** if two AA docs at the same layer disagree, fix the docs in the same change set; do not paper over in `README_AI`.

**Shell / UI split:**

- STANDARDS [`docs/ui/`](ui/overview.md) = UX / behavior / page-construction SSOT
- SHARED-UI `docs/public-component-api.md` = public `Bo*` parameters / host-integration API SSOT
- Product READMEs must not claim authority for either

**Future BreezeOn applications:** consume STANDARDS by link; hold only app AA (schema, seed, app-specific runbooks); never copy platform standards into the app repo.

## Approved deviations (first-class)

Deviations are first-class citizens of documentation governance. Even when the initial inventory is small, [`docs/deviations/`](deviations/README.md) is a **permanent** home from day one and is expected to grow as the platform matures.

- Index + rules: [`deviations/README.md`](deviations/README.md)
- Entry template: [`deviations/TEMPLATE.md`](deviations/TEMPLATE.md)
- Sparse index at launch is acceptable; absence of the folder is not
- Exceptions must not live only inside plans or `README_AI`
- Application-specific behavior that never claimed to be a platform standard belongs under `architecture/applications/`, not as a deviation

## Document ownership metadata

Major STANDARDS documents may include a single lightweight line near the top (below the classification banner):

```text
Owner: <area>
```

Allowed values (documentation ownership areas only):

| Value | Typical documents |
| --- | --- |
| `Architecture` | `architecture/*`, ADR process / decision index |
| `Engineering` | Stack, database, environments, application model, security governance |
| `UI` | `docs/ui/*` |
| `Documentation` | Documentation standards, glossary, naming, placeholders for undeclared areas |
| `Operations` | `runbooks/` |
| `Product` | Product-facing application descriptions when ownership is product-scoped |

**What this is:** a discoverability hint for maintainers about which organizational **area** a document belongs to.

**What this is not:** an approval workflow, a permission model, a review board, named individuals or teams, or a gate before merging.

Do not invent additional owner labels or assign personal names. Omit the Owner line on trivial stubs/redirects when it adds no value; **do not** omit the classification banner.

## Review governance (mandatory finding format)

Owner-oriented review reports (documentation content reviews, architecture/domain reviews, and other finding-bearing reviews) **must** follow [`review-governance.md`](review-governance.md): Problem, Evidence, Recommended Action, Scope, Owner Decision Required?, Reviewer Recommendation, Expected Outcome, plus Executive Summary. Optimize for owner decision-making — not evidence-only audit notes.

## Periodic review (advisory)

Documentation should be **reviewed periodically** so it continues to reflect **current reality**.

When reviewing (or when drift is noticed during normal work):

- Confirm content still matches implemented systems and standards in use
- **Remove** obsolete content when discovered
- **Correct** broken references when discovered
- Update related indexes in the same change set when structure or links change
- Confirm classification banners remain present and accurate

This guidance is **advisory and pragmatic**. It does **not** create mandatory review cycles, compliance checklists, scheduled governance meetings, or formal sign-off processes. Same-change-set updates when reality changes remain the primary duty ([Definition of Done](#definition-of-done)).

## STANDARDS repo layout

| Tree | Holds |
| --- | --- |
| `docs/` | Standards and governance (how we work); glossary: [`glossary.md`](glossary.md) |
| `docs/ai/` | AI onboarding + AI process SSOT (mandatory quickstart first); index: [`ai/README.md`](ai/README.md) — includes agent governance and Planning/Development Agent rules |
| `docs/deviations/` | Approved exceptions to standards (first-class); index: [`deviations/README.md`](deviations/README.md) |
| `docs/local-development-scripts.md` | Org Local Development Script Standard (`dev-reset.ps1` only) |
| `docs/data-portability.md` | File-format standard for JSON import/export (Applications JSON today) |
| `docs/hosted-deployment.md` | Canonical hosted deploy standard (App Service, publish profile, GitHub Environments) |
| `docs/ui/` | Hierarchical UI standards (entry: [`ui/overview.md`](ui/overview.md); page checklist: [`ui/page-development.md`](ui/page-development.md); Example Governance: [`ui/example-governance.md`](ui/example-governance.md)); folders: `foundations/`, `shell/`, `layout/`, `controls/`, `patterns/` |
| `docs/plans/` | Plan lifecycle only (`in-progress/`, `implemented/`); see [plans/README.md](plans/README.md) |
| `runbooks/` | Operational procedures; index: [`../runbooks/README.md`](../runbooks/README.md) — includes Customer Onboarding Master Flow and slice procedures; deploy **standard** lives in `hosted-deployment.md` |
| `architecture/` | Descriptions of systems that exist now (what exists); landscape map: [`../architecture/landscape.md`](../architecture/landscape.md) |
| `architecture/applications/` | Application references (mature consumers / reference implementations); not platform definitions — index: [`../architecture/applications/README.md`](../architecture/applications/README.md) |
| `decisions/` | Architecture Decision Records (why decisions were made); index with Category / Impact Area: [`../decisions/README.md`](../decisions/README.md) |
| `templates/` | Copy-into-product starters |

Do not place unimplemented designs in AA trees.

### Placeholder standards (undeclared governance areas)

Some `docs/` files exist only to record that an area is **not yet formally defined** (e.g. [`domain-modeling.md`](domain-modeling.md), [`testing.md`](testing.md), [`observability.md`](observability.md), [`versioning.md`](versioning.md)). Those placeholders:

- Classification: **AN**
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

Entry point only (`Classification: ENT`). Allow-list:

- Purpose / Responsibilities (short)
- Relationship to Breeze On + link to STANDARDS
- Stack (bullets)
- Repository layout (short)
- How to run locally (commands + link to [`local-database.md`](local-database.md) / product scripts)
- Deploy metadata (names/URLs + link to [`hosted-deployment.md`](hosted-deployment.md))
- Related docs (links)

Do **not** include: long UI inventories, auth essays, seed policy restatements, public component API tables, route encyclopedias, roadmaps, or speculative architecture.

## README_AI.md (agents)

Required in every product/platform repo. Entry point only (`Classification: ENT`). Allow-list:

1. Pointer to mandatory AI reading order: [`docs/ai/README.md`](ai/README.md) (single chain)
2. Short document-precedence ladder (matching [precedence](#source-of-truth-and-precedence) above)
3. Repo role + boundaries (what this repo owns)
4. Task → doc routing table (links only)
5. Autonomous local validation / smoke unique to this repo
6. Documentation duty one-liner (same-change-set; no technical contracts here)

### Organization-wide content

Belongs in **STANDARDS**. Product files must **reference** STANDARDS rather than duplicating it.

### Product README_AI.md must

1. Point agents to [`docs/ai/README.md`](https://github.com/Breeze-On/STANDARDS/blob/main/docs/ai/README.md) first (Quickstart is step 1 of that order).
2. Hold **repository-specific** context only.
3. Require agents to follow STANDARDS and to **update documentation** (including ADRs when architecture changes) when a task changes reality.
4. Enforce **current state only**.
5. Treat documentation maintenance as part of completion criteria.

Keep product `README_AI.md` high-level and thin. Not a tutorial or full org handbook.

### AGENTS.md

Ultra-thin pointer chain only: [`docs/ai/README.md`](ai/README.md) order → repo `README_AI.md` → stop.

## Org profile

The organization landing README lives in `Breeze-On/.github` → `profile/README.md`. Same current-reality rule and classification banner apply (`Scope: org`).

## External review export (agents)

**Scope:** Breeze-On organization documentation only.

When a human asks an agent to **extract all `.md` documentation for external review** (or equivalent), produce a **single Markdown file** suitable for tools that do not accept zip uploads (e.g. Copilot).

| Item | Requirement |
| --- | --- |
| Sources | `STANDARDS`, `SYSTEM-ADMIN-EAC`, `SYSTEM-SHARED-UI`, `.github` (local `Projects` clones preferred; shallow `gh` clone to temp if needed) |
| Output | One `.md` under the user’s `Downloads` folder (timestamped name) |
| Format | Each source file wrapped with `DOC BEGIN` / `DOC END` plus Repository, File name, Path, and Full GitHub-style path |
| Not allowed | Zip-only delivery; creating or pushing GitHub repositories |

This is an agent workflow for the Breeze-On org, not a product feature. Cursor encodes the same procedure in a user/project rule so agents recognize the request phrase.

## Implementation plans (temporary)

Org-wide Planning Agent and Development Agent rules: [`ai/planning-and-development-agents.md`](ai/planning-and-development-agents.md).

### Plan lifecycle

**proposed → approved → implemented → durable outcomes promoted → historical/frozen**

- New and active plans live under `docs/plans/in-progress/` (temporary working artifacts; never AA for shipped behavior).
- Chat must **not** store or re-render plan bodies; the markdown file is the deliverable.
- Plan updates are **in-place and delta-only** — edit the existing file; do not regenerate unchanged sections or create V2/duplicate plans.
- Before treating a plan as pure history: verify each durable claim has an AA home; if missing, move/extract existing text into that home (no stylistic rewrite), then mark **Historical — not authoritative** (`Classification: H`).
- After successful implementation, validation, documentation updates, and knowledge transfer: move to `docs/plans/implemented/` (preferred) or delete if fully transferred.
- Permanent documentation remains **current reality only** — do not embed planned/future behavior or dangling plan references into standards.
- Remediation backlogs and “future phases” left inside implemented plans are **not** authoritative.

These org rules **supersede** repository-specific planning/output behavior unless the current prompt explicitly overrides them.

## Definition of Done

A change is incomplete until **all affected documentation reflects current reality**, including:

- Product `README` / `README_AI` / `AGENTS` as applicable (entry allow-lists; no new technical contracts)
- STANDARDS `docs/` (including modular `docs/ui/` when UI standards change) and/or `architecture/` as applicable
- Classification banners present and accurate on new/moved docs
- **ADRs** created, updated, or superseded when architectural decisions are affected (update [`decisions/README.md`](../decisions/README.md) Category / Impact Area columns)
- Indexes and cross-references kept accurate

Updates must occur in the **same change set** as the implementation change. Documentation maintenance is part of **Definition of Done**.

### Identity & Authentication DoD (platform)

Any change affecting **authentication architecture**, **Identity schema**, **App Registration strategy**, **tenant strategy**, **authentication environment variables**, **local development authentication**, **cookie/session policy**, or **customer onboarding authentication** is incomplete until [`architecture/identity-and-authentication/`](../architecture/identity-and-authentication/README.md) (including the mandatory [customer-onboarding-authentication.md](../runbooks/customer-onboarding-authentication.md) runbook when A–F steps change) and related ADR(s) (ADR-009 / ADR-010 / ADR-011 / ADR-012 / ADR-013 or successors) are updated in the **same change set**. When the **end-to-end** onboarding sequence or checkpoints change, also update [`runbooks/customer-onboarding-master-flow.md`](../runbooks/customer-onboarding-master-flow.md) (owns intake + go-live checklist SSOT; slices must not maintain competing checklists). This is a mandatory BreezeOn platform standard.

### Authorization DoD (platform)

Any change affecting **authorization architecture**, **Security schema**, **page security**, **`IBoAuthorizationService`**, or **authorization onboarding (Workflow G)** is incomplete until [`architecture/authorization/`](../architecture/authorization/README.md) and related ADR(s) (ADR-014 or successors) are updated in the **same change set**. When Workflow G or end-to-end onboarding checkpoints change, also update [`runbooks/customer-onboarding-master-flow.md`](../runbooks/customer-onboarding-master-flow.md). Workflow G procedure: [`runbooks/customer-onboarding-authorization.md`](../runbooks/customer-onboarding-authorization.md).

### Data Entities DoD (platform)

Any change affecting Data Entity **schema**, **stored procedures**, **API contracts**, **business rules**, **CRUD flows**, or **platform standards** is incomplete until [`architecture/data-entities/`](../architecture/data-entities/README.md), related ADR(s) (ADR-016 or successors), and EAC [`docs/db-model.md`](https://github.com/Breeze-On/SYSTEM-ADMIN-EAC/blob/main/docs/db-model.md) (plus thin product `README` / `README_AI` pointers) are updated in the **same change set**.

UI / query-driven standards also follow **[Example Governance](ui/example-governance.md)**: normative standard + AI guidance + Gallery working example (unless an approved exception applies — record in [`docs/deviations/`](deviations/README.md)).

### UI / shared component DoD (BreezeOn.UI)

For work on public `Bo*` components, tokens, or gallery standards, also treat these as incomplete without a docs update in the same change set:

| Change | Documentation update |
| --- | --- |
| New feature / mode | STANDARDS `docs/ui/` SSOT + thin product README / README_AI pointers |
| New public parameter | Parameter tables in SHARED-UI `docs/public-component-api.md` and/or the owning STANDARDS control doc as applicable |
| UX / visual standard change | UX section of the owning STANDARDS `docs/ui/` doc (+ tokens/sections/shell as needed) |
| Design standard change | STANDARDS `docs/ui/` + overview cross-links |
| Refactor that changes behavior | Same docs as a feature change; remove obsolete statements |

Examples must match the latest component behavior. Remove documentation that no longer matches implementation.
