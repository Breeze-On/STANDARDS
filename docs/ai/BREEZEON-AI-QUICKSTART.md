<!-- Classification: AN; Scope: platform; Domain: Engineering; Capability: AiOnboarding -->
# BreezeOn AI Quickstart

Owner: Documentation

**Mandatory first read** for every AI agent (Cursor, planning, build, documentation, generation) before any analysis, planning, design, or implementation in a Breeze-On repository.

Goal: understand Breeze On in minutes. Then open **detailed** STANDARDS docs only as needed. Do not re-ingest the entire org corpus by default.

**After this reading order:** route with [`ai-catalog.json`](ai-catalog.json) — Domain → Entry Point → Capability → selected docs (see [`README.md`](README.md) § Catalog-first retrieval).

Current reality only. Summaries point to SSOT — do not invent rules here.

---

## BreezeOn Overview

### Vision

**Purpose-driven software. Process-driven intelligence.**  
One ecosystem, multiple specialized applications, shared platform capability without diluted purpose.

### Goals

- Encode clear objectives in each product (not generic toolkits).
- Share foundations (UI contract, environments, hosted deployment, documentation, ADRs) across apps.
- Keep docs and code synchronized with **what exists today**.

### Architectural philosophy

| Principle | Meaning |
| --- | --- |
| Multi-repo | One repo per application or shared concern ([ADR-001](../../decisions/ADR-001-multi-repository-model.md)) |
| Current reality | Document and build only what is implemented ([documentation.md](../documentation.md)) |
| Decisions recorded | Significant architecture choices are ADRs ([adr.md](../adr.md)) |
| Thin product docs | Product `README_AI` links here; does not duplicate org standards |

### Platform mindset

```text
Application (e.g. EAC)
    -> BreezeOn.UI   (public Bo* API)
        -> Fluent UI Blazor  (internal only)
```

Product pages consume **`Bo*`** only. Fluent is an implementation detail of Shared UI ([ADR-004](../../decisions/ADR-004-breezeon-ui-abstraction-layer.md)). Hosting: Blazor Interactive Server, .NET 10 ([ADR-002](../../decisions/ADR-002-blazor-interactive-server.md)).

---

## Core Rules

1. **Development assistant only** — Analyze, implement locally, document, test locally, recommend. Do **not** push, manage PRs, trigger CI/CD, deploy, change Azure/cloud, manage secrets, or administer repos unless the **current prompt** explicitly authorizes that action. SSOT: [ai-agent-governance.md](ai-agent-governance.md) ([ADR-007](../../decisions/ADR-007-ai-agent-operational-boundaries.md)).
1a. **Planning Agent — plans are files, not chat** — Write new plans only to `docs/plans/in-progress/*.md`. **Never** render plan content, previews, or summaries in chat. After create/update, return **only** the path and `[Build Locally]`. Update existing plans **in place** with **delta updates only** (no full regenerations, no V2/duplicates). SSOT: [planning-and-development-agents.md](planning-and-development-agents.md).
1b. **Development Agent — Build Locally from the plan** — Locate `docs/plans/in-progress/…`, implement from that file, update affected permanent docs, transfer lasting knowledge out of the plan, then move to `docs/plans/implemented/` (or delete if fully transferred). Implementation alone is not Done. Same SSOT.
2. **Reuse before create** — Prefer existing `Bo*` components, tokens, and STANDARDS patterns.
3. **Common UI first** — Layout, shell, nav, home hub, forms: use `BreezeOn.UI`, not ad-hoc chrome. **`BreezeOn.UI` is mandatory** for applications (shell + `Bo*` + auth + authZ + page catalog). Do **not** defer Identity/Auth/AuthZ for new apps ([application-model.md](../application-model.md)).
4. **ADR compliance** — Review `decisions/` before new architecture patterns; update/supersede ADRs in the same change set when decisions change.
5. **Localization required** — No hardcoded user-visible strings; each app owns its `.resx` library ([i18n.md](../ui/foundations/i18n.md)).
6. **Accessibility** — Use shipped `Bo*` chrome and controls; do not invent inaccessible custom widgets when a `Bo*` exists.
7. **Documentation must stay current** — Same change set as code when behavior, setup, schema, or architecture changes.
8. **No direct Fluent UI in applications** — Never import or use `Microsoft.FluentUI.*` on product pages.
8a. **Planning Agent default for queryable datasets** — **One primary retrieval contract per dataset** (rows / `TotalCount` / Nested View children / optional metadata). **Challenge** companion FilterOptions SPs and any secondary contract; require documented rationale; prefer EF / app services for simple catalogs. SSOT: [query-driven-retrieval.md](../ui/controls/query-driven-retrieval.md) · [ADR-008](../../decisions/ADR-008-query-driven-data-retrieval.md).
8b. **Planning Agent default for BoRow sizing / hidden fields** — Assume **`Weight=1`** (equal shares). Use proportional **`Weight`** when a field should be wider/narrower (not a 12-column grid). **`IsHidden` collapses** by default (Weight ignored); set **`PreserveLayoutWhenHidden`** only when alignment / dynamic visibility / multi-row stability requires reserved space. Challenge custom width CSS and unnecessary preserve. SSOT: [layout.md](../ui/layout/layout.md). **Do not confuse** with Nested View **`PreserveNestedExpansionOnCacheReset`** ([grids.md](../ui/controls/grids.md)).
8c. **Example Governance** — A UI / query standard is fully implemented only when **normative STANDARDS + AI guidance + Gallery working example** all exist. Challenge docs-only standards. Prefer Gallery as the copy source for library patterns. SSOT: [example-governance.md](../ui/example-governance.md).
8d. **Host helpers** — Use **`BoLatestWinsQuery`** for query / FilterCatalog concurrency; **`BoNestedViewKeywordFilter`** for client Nested View keyword Rules 1–3; large dropdowns use **`ItemsProvider`**.
8e. **UX Standards Compliance Review (before development)** — Normative in [planning-and-development-agents.md](planning-and-development-agents.md); detail [ux-conventions.md](../ui/patterns/ux-conventions.md) · [page-development.md](../ui/page-development.md).
8f. **Configuration Session Review (configuration-heavy work)** — Normative in [planning-and-development-agents.md](planning-and-development-agents.md); SSOT [configuration-session-cache.md](../../architecture/app-configuration/configuration-session-cache.md) · [ADR-020](../../decisions/ADR-020-configuration-session-cache.md).
8g. **Validation Summary Adoption Matrix (Save/Commit validation UX)** — Before inventing validation messaging, evaluate Required / Optional / Not Recommended for Validation Summary vs field chrome vs toast vs navigate-to-error. Multi-row BoGrid/Shuffle/bulk-edit Save failures use `BoValidationSummary` (not host `<ul>` lists; not Import Summary). SSOT: [validation-summary.md](../ui/patterns/validation-summary.md) · [ADR-021](../../decisions/ADR-021-validation-summary-experience.md).
8h. **Dev Agent — reuse before custom UX** — Normative in [planning-and-development-agents.md](planning-and-development-agents.md) § Before custom UX.
9. **Hosted Azure SQL MI (data-owning apps) — required packages** — If the app uses App Service → Azure SQL with `Authentication=Active Directory Managed Identity`, you **MUST** add NuGet **`Microsoft.Data.SqlClient.Extensions.Azure`** (same major/minor as `Microsoft.Data.SqlClient`) **and** register `ActiveDirectoryAuthenticationProvider` before any SQL open (including EF `Database.Migrate()`). Connection string + MI grant alone are **not** enough on SqlClient 7+. SSOT: [hosted-deployment.md](../hosted-deployment.md) § Hosted database connection, [architecture/security.md](../../architecture/security.md).

Also: do not invent standards for placeholder areas (testing, versioning, domain modeling, observability) that are not yet defined. Dependency vulnerability policy is defined: [security-governance.md](../security-governance.md).

---

## BreezeOn Architecture

High level only. Detail: [`architecture/landscape.md`](../../architecture/landscape.md).

| Kind | Repo (examples) | Owns |
| --- | --- | --- |
| Governance SSOT | `STANDARDS` | Docs, architecture descriptions, ADRs |
| Shared UI | `SYSTEM-SHARED-UI` | `BreezeOn.UI` (UI + auth + authZ frameworks; Identity/Security SQL defs) + Gallery — **mandatory** for apps |
| Application | `SYSTEM-ADMIN-EAC` | EAC product, SYSADM SQL, DEV deploy metadata (procedures → STANDARDS) |

**Dependency direction (must preserve):**

```text
Product apps  -->  BreezeOn.UI  -->  Fluent (internal)
STANDARDS     <--  link / follow  --  product & Shared UI
```

SHARED-UI does not own EAC business domains or business databases; it owns platform Identity/Security definitions and auth/authZ runtime (EAC-named reserved group Codes may live in SHARED-UI per ADR-014/015). Apps **must** consume `BreezeOn.UI` and do not own the design-system implementation ([application-model.md](../application-model.md)).

---

## Common UI Library

| | |
| --- | --- |
| Repo | `Breeze-On/SYSTEM-SHARED-UI` |
| Package / project | `BreezeOn.UI` |
| Decision | [ADR-004](../../decisions/ADR-004-breezeon-ui-abstraction-layer.md) |
| UI standards entry | [`docs/ui/overview.md`](../ui/overview.md) |
| Page checklist | [`docs/ui/page-development.md`](../ui/page-development.md) |

**Purpose:** Single public Blazor design-system contract (`Bo*`, tokens, `AddBreezeOnUI`) for all product apps.

**Responsibilities:** Shell chrome, theming, locale/theme cookies, navigation hub, form field chrome, layout primitives (Section / Row / Stack), dialogs/toasts — not EAC business domains or databases.

**Design philosophy:** Option B+ floating cards; locked left nav / header actions / Home hub patterns; dual Light/Dark semantic tokens; Calibri default; Fluent stays internal.

**Approved usage:** `services.AddBreezeOnUI()`; host renders `BoThemeProvider` + `BoProviders`; pages use `Bo*` only; Gallery (`BreezeOn.UI.Gallery`) is the component host reference, not a product glossary (`BoUi` resources are not for EAC).

---

## Application Adoption Pattern

**Canonical reference:** `SYSTEM-ADMIN-EAC` (EAC). See also [`BREEZEON-AI-APPLICATION-ADOPTION.md`](BREEZEON-AI-APPLICATION-ADOPTION.md) and [`architecture/applications/eac.md`](../../architecture/applications/eac.md).

| Topic | What to understand |
| --- | --- |
| Why | Prove a product app can adopt Shared UI for shell + nav without Fluent or custom chrome |
| Integration | Sibling `ProjectReference` to `BreezeOn.UI`; `AddBreezeOnUI()`; Fluent + `breezeon-ui.css` + early theme/locale JS in host `App.razor` |
| Layout | `MainLayout` = `BoThemeProvider` → `BoAppShell` → `BoProviders`; per-route `BoAppHeader` titles; footer optional (`ShowFooter`) |
| Home | Locked `BoNavHub` + `BoNavCardStyleHyperlink` (not Section→Row→Field) |
| Localization | App-owned resources (EAC: `EacResources` + `IEacLocalizer`); subscribe to `IBoLocaleService.Changed` |
| Navigation | Left `BoNavPane` / `BoNavLink` + `BoIcon`; URLs match page name (lowercase, hyphenated) |
| Branding | Library logos `_content/BreezeOn.UI/brand/*`; per-app Home hero under `wwwroot/brand/` |

End-user auth / platform Identity: **[architecture/identity-and-authentication/](../../architecture/identity-and-authentication/README.md)** (ADR-009–011). EAC consumes SYSTEM-SHARED-UI auth; business schema remains `sql/current_model/` (`System`); platform `Identity.*` scripts come from SHARED-UI `sql/identity/`.

---

## Required Components

| Component | Purpose |
| --- | --- |
| `BoThemeProvider` | Emits active theme CSS variables |
| `BoProviders` | Fluent providers + theme/locale bootstrap + dialog/toast hosts |
| `BoAppShell` | Required app chrome: nav + header + body (+ optional footer) |
| `BoNavPane` | Left nav: logos, divider, page links, collapse |
| `BoNavLink` | One nav destination (`Href`, `IconContent`, label) |
| `BoAppHeader` | Per-page `AppTitle` / `Subtitle` + standard header actions |
| `BoThemeSwitch` | Light/Dark toggle (part of locked `BoHeaderActions` order) |
| `BoProfileMenu` | Profile / sign-out chrome (wired through platform authentication framework) |
| `BoNavHub` | Locked Home landing: cards + brand panel |

Default header actions order: Theme → Settings → Profile. Details: [`docs/ui/shell/shell.md`](../ui/shell/shell.md).

---

## Local development scripts (agents)

Org standard: [`docs/local-development-scripts.md`](../local-development-scripts.md).

When creating or modifying a BreezeOn application:

1. Ship both `scripts/dev-reset.ps1` and `scripts/dev-run.ps1` (required layout).  
2. Do not invent a custom developer startup workflow (`dev-up` / `dev-down` / one-off start scripts).  
3. Keep README instructions aligned with both scripts.  
4. Keep both scripts updated as development requirements evolve.  
5. Prefer `.\scripts\dev-run.ps1` for routine relaunch; use `.\scripts\dev-reset.ps1` only for destructive recreate.  

Autonomous local verification: prefer `.\scripts\dev-run.ps1` when the environment already exists; use `.\scripts\dev-reset.ps1` for a fresh environment (requires `.env` from `.env.example`).

## Things AI Agents Must Never Do

### Operational boundaries (deny unless current prompt explicitly authorizes)

Full matrix: [ai-agent-governance.md](ai-agent-governance.md).

- Push commits, force push, create/delete branches
- Create, approve, merge, or close pull requests
- Trigger GitHub Actions, Azure DevOps pipelines, deploy/release workflows, or modify release definitions
- Deploy to any environment or modify Azure / cloud / infrastructure resources
- Create, modify, delete, or rotate secrets, PATs, or permissions
- Modify repository/organization settings, branch protections, CODEOWNERS, or access controls
- Treat prior chats, docs, or inferred urgency as approval for the above
- Continue into publish/deploy after local debugging — diagnostics stay local; then **stop**

### Product / standards boundaries

- Create new architectural or UI patterns without checking STANDARDS / ADRs first
- Use `Microsoft.FluentUI.*` types on product pages
- Duplicate shell, home hub, form chrome, or tokens already in `BreezeOn.UI`
- Hardcode user-visible strings or reuse Gallery `BoUi` as another app’s glossary
- Ignore accepted ADRs or invent conflicting hosting/UI stacks
- Duplicate hosted deploy procedures into product repos (use [`hosted-deployment.md`](../hosted-deployment.md))
- Leave documentation stale after changing behavior, setup, schema, or architecture
- Document planned/future work as if it were current reality
- Dump implementation plans into chat instead of `docs/plans/in-progress/*.md`, create V2/duplicate plans, regenerate entire plans instead of in-place delta updates, or leave completed plans in `docs/plans/in-progress/` after knowledge transfer
- Point routine Development at Azure SQL when local Docker SQL is the org pattern
- Ship a data-owning App Service with MI SQL auth **without** `Microsoft.Data.SqlClient.Extensions.Azure` + `ActiveDirectoryAuthenticationProvider` registration (SqlClient 7+); that crash-loops startup and burns Free F1 into **QuotaExceeded**
- Skip the org local script standard (`scripts/dev-reset.ps1` + `scripts/dev-run.ps1`) or invent alternate startup scripts (`dev-up` / `dev-down` / one-off `start.ps1` / `run-local.ps1`)
- Hardcode secrets; use `.env` for script config and User Secrets for OIDC credentials ([application-model.md](../application-model.md))
- Add EAC business features into Shared UI (or UI library concerns into EAC)

---

## Quick References

| Topic | Document |
| --- | --- |
| This AI path index | [`docs/ai/README.md`](README.md) |
| AI agent operational boundaries | [`ai-agent-governance.md`](ai-agent-governance.md) · [ADR-007](../../decisions/ADR-007-ai-agent-operational-boundaries.md) |
| Planning / Development Agents | [`planning-and-development-agents.md`](planning-and-development-agents.md) |
| Standards summary (AI) | [`BREEZEON-AI-STANDARDS-SUMMARY.md`](BREEZEON-AI-STANDARDS-SUMMARY.md) |
| App adoption (AI) | [`BREEZEON-AI-APPLICATION-ADOPTION.md`](BREEZEON-AI-APPLICATION-ADOPTION.md) |
| Org agent entry (full) | [`README_AI.md`](../../README_AI.md) |
| Documentation rules | [`docs/documentation.md`](../documentation.md) |
| Landscape | [`architecture/landscape.md`](../../architecture/landscape.md) |
| EAC | [`architecture/applications/eac.md`](../../architecture/applications/eac.md) |
| UI overview | [`docs/ui/overview.md`](../ui/overview.md) |
| Page checklist | [`docs/ui/page-development.md`](../ui/page-development.md) |
| Shell / nav | [`docs/ui/shell/shell.md`](../ui/shell/shell.md), [`navigation.md`](../ui/shell/navigation.md) |
| i18n | [`docs/ui/foundations/i18n.md`](../ui/foundations/i18n.md) |
| Local scripts | [`docs/local-development-scripts.md`](../local-development-scripts.md) |
| Environments | [`docs/environments.md`](../environments.md) |
| Hosted deployment | [`docs/hosted-deployment.md`](../hosted-deployment.md) |
| Review governance / severity | [`review-governance.md`](../review-governance.md) |
| Construct selection (**EAC-scoped**) | [`construct-selection.md`](../../architecture/app-configuration/construct-selection.md) |
| AI authoring contracts (**EAC-scoped**) | [Variables](../../architecture/variables/ai-authoring-contract.md) · [DE](../../architecture/data-entities/ai-authoring-contract.md) · [PF](../../architecture/process-framework/ai-authoring-contract.md) |
| Dependency / vulns (Phase 1) | [`security-governance.md`](../security-governance.md) |
| Runbooks (OPS index) | [`runbooks/README.md`](../../runbooks/README.md) |
| Templates index | [`templates/`](../../templates/) |
| ADR index | [`decisions/README.md`](../../decisions/README.md) |
| ADR-002 / ADR-004 | Blazor Interactive Server · BreezeOn.UI abstraction |
| Query-driven retrieval | [`query-driven-retrieval.md`](../ui/controls/query-driven-retrieval.md) · [ADR-008](../../decisions/ADR-008-query-driven-data-retrieval.md) |
| Shuffle Card Grid | [`shuffle-card-grid.md`](../ui/controls/shuffle-card-grid.md) |
| Example Governance | [`example-governance.md`](../ui/example-governance.md) |
| BoRow Weight / hidden layout | [`layout.md`](../ui/layout/layout.md) |
| `@FiltersJson` schema | [`database.md`](../database.md#filtersjson-schema) |
| Shared UI agents | [SYSTEM-SHARED-UI `README_AI.md`](https://github.com/Breeze-On/SYSTEM-SHARED-UI/blob/main/README_AI.md) |
| EAC agents | [SYSTEM-ADMIN-EAC `README_AI.md`](https://github.com/Breeze-On/SYSTEM-ADMIN-EAC/blob/main/README_AI.md) |

**Next:** Open [`BREEZEON-AI-STANDARDS-SUMMARY.md`](BREEZEON-AI-STANDARDS-SUMMARY.md) if the task touches standards; open [`BREEZEON-AI-APPLICATION-ADOPTION.md`](BREEZEON-AI-APPLICATION-ADOPTION.md) for UI adoption work; then the product repo’s `README_AI.md`.
