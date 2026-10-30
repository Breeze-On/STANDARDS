# BreezeOn AI Quickstart

Owner: Documentation

**Mandatory first read** for every AI agent (Cursor, planning, build, documentation, generation) before any analysis, planning, design, or implementation in a Breeze-On repository.

Goal: understand Breeze On in minutes. Then open **detailed** STANDARDS docs only as needed. Do not re-ingest the entire org corpus by default.

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
Application (e.g. ADM)
    -> BreezeOn.UI   (public Bo* API)
        -> Fluent UI Blazor  (internal only)
```

Product pages consume **`Bo*`** only. Fluent is an implementation detail of Shared UI ([ADR-004](../../decisions/ADR-004-breezeon-ui-abstraction-layer.md)). Hosting: Blazor Interactive Server, .NET 10 ([ADR-002](../../decisions/ADR-002-blazor-interactive-server.md)).

---

## Core Rules

1. **Reuse before create** — Prefer existing `Bo*` components, tokens, and STANDARDS patterns.
2. **Common UI first** — Layout, shell, nav, home hub, forms: use `BreezeOn.UI`, not ad-hoc chrome.
3. **ADR compliance** — Review `decisions/` before new architecture patterns; update/supersede ADRs in the same change set when decisions change.
4. **Localization required** — No hardcoded user-visible strings; each app owns its `.resx` library ([i18n.md](../ui/foundations/i18n.md)).
5. **Accessibility** — Use shipped `Bo*` chrome and controls; do not invent inaccessible custom widgets when a `Bo*` exists.
6. **Documentation must stay current** — Same change set as code when behavior, setup, schema, or architecture changes.
7. **No direct Fluent UI in applications** — Never import or use `Microsoft.FluentUI.*` on product pages.

Also: do not invent standards for placeholder areas (testing, versioning, etc.) that are not yet defined.

---

## BreezeOn Architecture

High level only. Detail: [`architecture/landscape.md`](../../architecture/landscape.md).

| Kind | Repo (examples) | Owns |
| --- | --- | --- |
| Governance SSOT | `STANDARDS` | Docs, architecture descriptions, ADRs |
| Shared UI | `SYSTEM-SHARED-UI` | `BreezeOn.UI` + Gallery |
| Application | `SYSTEM-ADMIN-ADM` | ADM product, SYSADM SQL, DEV deploy metadata (procedures → STANDARDS) |

**Dependency direction (must preserve):**

```text
Product apps  -->  BreezeOn.UI  -->  Fluent (internal)
STANDARDS     <--  link / follow  --  product & Shared UI
```

No reverse dependency of Shared UI on ADM domains/databases. Apps do not own the design-system implementation.

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

**Responsibilities:** Shell chrome, theming, locale/theme cookies, navigation hub, form field chrome, layout primitives (Section / Row / Stack), dialogs/toasts — not ADM business domains or databases.

**Design philosophy:** Option B+ floating cards; locked left nav / header actions / Home hub patterns; dual Light/Dark semantic tokens; Calibri default; Fluent stays internal.

**Approved usage:** `services.AddBreezeOnUI()`; host renders `BoThemeProvider` + `BoProviders`; pages use `Bo*` only; Gallery (`BreezeOn.UI.Gallery`) is the component host reference, not a product glossary (`BoUi` resources are not for ADM).

---

## Application Adoption Pattern

**Canonical reference:** `SYSTEM-ADMIN-ADM` (ADM). See also [`BREEZEON-AI-APPLICATION-ADOPTION.md`](BREEZEON-AI-APPLICATION-ADOPTION.md) and [`architecture/adm.md`](../../architecture/adm.md).

| Topic | What to understand |
| --- | --- |
| Why | Prove a product app can adopt Shared UI for shell + nav without Fluent or custom chrome |
| Integration | Sibling `ProjectReference` to `BreezeOn.UI`; `AddBreezeOnUI()`; Fluent + `breezeon-ui.css` + early theme/locale JS in host `App.razor` |
| Layout | `MainLayout` = `BoThemeProvider` → `BoAppShell` → `BoProviders`; per-route `BoAppHeader` titles; footer optional (`ShowFooter`) |
| Home | Locked `BoNavHub` + `BoNavCardStyleHyperlink` (not Section→Row→Field) |
| Localization | App-owned resources (ADM: `AdmResources` + `IAdmLocalizer`); subscribe to `IBoLocaleService.Changed` |
| Navigation | Left `BoNavPane` / `BoNavLink` + `BoIcon`; URLs match page name (lowercase, hyphenated) |
| Branding | Library logos `_content/BreezeOn.UI/brand/*`; per-app Home hero under `wwwroot/brand/` |

Auth/Identity is **not** part of current ADM shell adoption (deferred). Business schema remains `sql/current_model/` (SYSADM); EF keeps migration infrastructure without Identity tables.

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
| `BoProfileMenu` | Profile / sign-out chrome (design surface; product auth wiring later) |
| `BoNavHub` | Locked Home landing: cards + brand panel |

Default header actions order: Theme → Settings → Profile. Details: [`docs/ui/shell/shell.md`](../ui/shell/shell.md).

---

## Local development scripts (agents)

Org standard: [`docs/local-development-scripts.md`](../local-development-scripts.md).

When creating or modifying a BreezeOn application:

1. Reuse the existing `scripts/dev-reset.ps1` pattern.  
2. Do not invent a custom developer startup workflow.  
3. Keep README instructions aligned with the script.  
4. Keep the script updated as development requirements evolve.  
5. Prefer modifying the existing script rather than introducing additional scripts.  

Autonomous local verification: `.\scripts\dev-reset.ps1` (requires `.env` from `.env.example`).

## Things AI Agents Must Never Do

- Create new architectural or UI patterns without checking STANDARDS / ADRs first
- Use `Microsoft.FluentUI.*` types on product pages
- Duplicate shell, home hub, form chrome, or tokens already in `BreezeOn.UI`
- Hardcode user-visible strings or reuse Gallery `BoUi` as another app’s glossary
- Ignore accepted ADRs or invent conflicting hosting/UI stacks
- Duplicate hosted deploy procedures into product repos (use [`hosted-deployment.md`](../hosted-deployment.md))
- Leave documentation stale after changing behavior, setup, schema, or architecture
- Document planned/future work as if it were current reality
- Point routine Development at Azure SQL when local Docker SQL is the org pattern
- Skip the org local script standard (`scripts/dev-reset.ps1`) or invent alternate startup scripts (`dev-up` / `dev-down` / custom run scripts)
- Hardcode secrets instead of a gitignored `.env`
- Add ADM business features into Shared UI (or UI library concerns into ADM)

---

## Quick References

| Topic | Document |
| --- | --- |
| This AI path index | [`docs/ai/README.md`](README.md) |
| Standards summary (AI) | [`BREEZEON-AI-STANDARDS-SUMMARY.md`](BREEZEON-AI-STANDARDS-SUMMARY.md) |
| App adoption (AI) | [`BREEZEON-AI-APPLICATION-ADOPTION.md`](BREEZEON-AI-APPLICATION-ADOPTION.md) |
| Org agent entry (full) | [`README_AI.md`](../../README_AI.md) |
| Documentation rules | [`docs/documentation.md`](../documentation.md) |
| Landscape | [`architecture/landscape.md`](../../architecture/landscape.md) |
| ADM | [`architecture/adm.md`](../../architecture/adm.md) |
| UI overview | [`docs/ui/overview.md`](../ui/overview.md) |
| Page checklist | [`docs/ui/page-development.md`](../ui/page-development.md) |
| Shell / nav | [`docs/ui/shell/shell.md`](../ui/shell/shell.md), [`navigation.md`](../ui/shell/navigation.md) |
| i18n | [`docs/ui/foundations/i18n.md`](../ui/foundations/i18n.md) |
| Local scripts | [`docs/local-development-scripts.md`](../local-development-scripts.md) |
| Environments | [`docs/environments.md`](../environments.md) |
| Hosted deployment | [`docs/hosted-deployment.md`](../hosted-deployment.md) |
| ADR index | [`decisions/README.md`](../../decisions/README.md) |
| ADR-002 / ADR-004 | Blazor Interactive Server · BreezeOn.UI abstraction |
| Shared UI agents | [SYSTEM-SHARED-UI `README_AI.md`](https://github.com/Breeze-On/SYSTEM-SHARED-UI/blob/main/README_AI.md) |
| ADM agents | [SYSTEM-ADMIN-ADM `README_AI.md`](https://github.com/Breeze-On/SYSTEM-ADMIN-ADM/blob/main/README_AI.md) |

**Next:** Open [`BREEZEON-AI-STANDARDS-SUMMARY.md`](BREEZEON-AI-STANDARDS-SUMMARY.md) if the task touches standards; open [`BREEZEON-AI-APPLICATION-ADOPTION.md`](BREEZEON-AI-APPLICATION-ADOPTION.md) for UI adoption work; then the product repo’s `README_AI.md`.
