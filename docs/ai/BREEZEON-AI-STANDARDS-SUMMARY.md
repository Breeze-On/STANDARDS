<!-- Classification: AN; Scope: platform; Domain: Engineering; Capability: AiOnboarding -->
# BreezeOn AI — Standards summary

Owner: Documentation

Concise map of org standards for AI agents. **SSOT remains the linked documents** — this file only orients. Read after [`BREEZEON-AI-QUICKSTART.md`](BREEZEON-AI-QUICKSTART.md).

---

## Architecture standards

| Topic | Rule (short) | SSOT |
| --- | --- | --- |
| Multi-repo | One app or shared concern per repository | [ADR-001](../../decisions/ADR-001-multi-repository-model.md) |
| UI host | Blazor Interactive Server, .NET 10 | [ADR-002](../../decisions/ADR-002-blazor-interactive-server.md) |
| Data locality | Azure SQL hosted; local Docker SQL for Development | [ADR-003](../../decisions/ADR-003-azure-sql-with-local-docker-sql.md), [local-database.md](../local-database.md) |
| UI contract | Product → `BreezeOn.UI` → Fluent (internal) | [ADR-004](../../decisions/ADR-004-breezeon-ui-abstraction-layer.md) |
| What exists | Describe implemented systems only | [`architecture/`](../../architecture/), [landscape.md](../../architecture/landscape.md) |
| Process runtime | Two-tier: `Global.Process` (EAC) + `{UniqueCode}.Process` extension; no app-minted `ProcessGUID`; Save/Submit → Process View | [process-runtime](../../architecture/process-runtime/README.md) · [ADR-024](../../decisions/ADR-024-platform-process-root.md) · [process-view.md](../ui/patterns/process-view.md) · [process-persistence.md](../ui/patterns/process-persistence.md) |
| App shape | Expected application repo contents | [application-model.md](../application-model.md) |
| Environments | Org environment vocabulary | [environments.md](../environments.md) |
| Hosted deployment | App Service / publish profile / GitHub Environment deploy standard | [hosted-deployment.md](../hosted-deployment.md) |
| Hosted SQL MI (SqlClient 7+) | **MUST** add `Microsoft.Data.SqlClient.Extensions.Azure` + register `ActiveDirectoryAuthenticationProvider` before SQL open — not optional if using Managed Identity | [hosted-deployment.md](../hosted-deployment.md), [architecture/security.md](../../architecture/security.md) |

Before new patterns: read relevant ADRs ([adr.md](../adr.md), [decisions/README.md](../../decisions/README.md)).

---

## Coding / engineering standards

| Topic | Rule (short) | SSOT |
| --- | --- | --- |
| Naming | Breeze On (display), `Breeze-On` (GitHub), `BreezeOn` (code) | [naming.md](../naming.md) |
| Stack | Follow implemented engineering conventions | [engineering.md](../engineering.md) |
| Database | Schema scripts + product `docs/db-model.md`; seed with schema changes | [database.md](../database.md) |
| Local SQL | Do not default Development to Azure SQL | [local-database.md](../local-database.md) |
| Local scripts | Every runnable host: `scripts/dev-reset.ps1` (fresh/destructive) + `scripts/dev-run.ps1` (day-to-day); script config via `.env`, OIDC via User Secrets; keep scripts + README aligned when local needs change | [local-development-scripts.md](../local-development-scripts.md), [application-model.md](../application-model.md) |
| Dependencies / vulns | NuGet audit, Dependabot, severity policy, remediation order — Phase 1 gates | [security-governance.md](../security-governance.md) |
| Placeholders | testing / observability / versioning / domain-modeling — **not formally defined**; do not invent | Placeholder files under `docs/` |
| Review findings | Owner-oriented finding shape; severity; Closed reports → `docs/plans/implemented/` (H) | [review-governance.md](../review-governance.md) |
| Runbooks / Templates | OPS procedures index; operator/agent/SQL/Dependabot starters | [runbooks/README.md](../../runbooks/README.md) · [templates/](../../templates/) |
| Construct selection (**EAC-scoped**, not platform-promoted) | Variable vs DE vs PF vs BE vs SG; envelope `[]` hazards | [construct-selection.md](../../architecture/app-configuration/construct-selection.md) |
| AI authoring contracts (**EAC-scoped**) | Field contracts + hazards for Variables / DE / PF | [variables](../../architecture/variables/ai-authoring-contract.md) · [data-entities](../../architecture/data-entities/ai-authoring-contract.md) · [process-framework](../../architecture/process-framework/ai-authoring-contract.md) |

---

## Agent operational governance

| Topic | Rule (short) | SSOT |
| --- | --- | --- |
| Agent role | Development assistant — not release manager / cloud / repo admin | [ai-agent-governance.md](ai-agent-governance.md), [ADR-007](../../decisions/ADR-007-ai-agent-operational-boundaries.md) |
| Default deny | No push, PR lifecycle, CI/CD trigger, deploy, cloud, secrets, or repo-admin without **current-prompt** authorization | Same |
| Stop condition | After local work, recommend next steps and return control to the human | Same |
| Debugging | Local diagnostics only; debug does not authorize publish/deploy | Same |
| Planning Agent | Plans only in `docs/plans/in-progress/`; **in-place delta updates only** (no V2/duplicates); never render plan bodies in chat; reply with path + Build Locally only | [planning-and-development-agents.md](planning-and-development-agents.md) |
| Development Agent | Build Locally from `docs/plans/in-progress/`; update permanent docs; knowledge transfer; move completed plans to `docs/plans/implemented/` | Same |
| Precedence | Org planning/output rules supersede repo-specific plan chat behavior unless current prompt overrides | Same |

---

## Documentation standards

| Rule | SSOT |
| --- | --- |
| Current reality only — no future-as-present | [documentation.md](../documentation.md) |
| Same change set as code when reality changes | Same |
| Product `README_AI` thin; link STANDARDS | [documentation.md](../documentation.md), [README_AI.md](../../README_AI.md) |
| ADRs for significant decisions; index Category / Impact Area | [adr.md](../adr.md) |
| Shared vocabulary | [glossary.md](../glossary.md) |
| AI onboarding path | [`docs/ai/README.md`](README.md) |
| AI operational boundaries | [ai-agent-governance.md](ai-agent-governance.md) |

---

## UI standards

| Topic | Rule (short) | SSOT |
| --- | --- | --- |
| Entry | Inventory + philosophy | [ui/overview.md](../ui/overview.md) |
| New product application | New Application Checklist first | [application-bootstrap-checklist.md](../application-bootstrap-checklist.md) · [application-development-process.md](application-development-process.md) |
| New/changed page | Page-construction checklist | [ui/page-development.md](../ui/page-development.md) |
| Shell | `BoAppShell` required; locked header actions | [ui/shell/shell.md](../ui/shell/shell.md) |
| Navigation | Left nav locked; URL = page name | [ui/shell/navigation.md](../ui/shell/navigation.md) |
| Home | `BoNavHub` + `BoNavCardStyleHyperlink` only | Shell Home section |
| Forms layout | Section → Row → Field; `BoStack Gap="0"`; `Weight` (default 1); `IsHidden` collapses unless `PreserveLayoutWhenHidden` | [ui/layout/](../ui/layout/) |
| Preserve* | `PreserveLayoutWhenHidden` = field layout; `PreserveNestedExpansionOnCacheReset` = Nested View expand — **unrelated** | [layout.md](../ui/layout/layout.md), [grids.md](../ui/controls/grids.md) |
| Query-driven retrieval | One primary contract per dataset; Filter → Sort → Page; `BoLatestWinsQuery`; FilterCatalog (not FilterOptions SP) | [query-driven-retrieval.md](../ui/controls/query-driven-retrieval.md) · [ADR-008](../../decisions/ADR-008-query-driven-data-retrieval.md) |
| Nested View keyword | Rules 1–3; client helper `BoNestedViewKeywordFilter` | [grids.md](../ui/controls/grids.md#nested-view-keyword-filtering-org-standard) |
| Drop-Down retrieval | Small → `Items`; large → `ItemsProvider` Top-N + search | [forms.md](../ui/controls/forms.md) |
| Consumer Data Entity lookup | EAC `P_GET_EACDataEntityLookupValues` + SHARED-UI `IBoDataEntityLookupQueries` (Search TOP 100 / Resolve / batch); persist `*Code` on `{UniqueCode}.Process`; Process View hydrate uses batch; sort Code default; flat field property = column name | [using-data-entities.md](../../architecture/data-entities/using-data-entities.md) · [ADR-023](../../decisions/ADR-023-consumer-data-entity-lookup.md) · [database.md](../database.md) |
| Process View / persistence | Terminal read-only after Save/Submit; freeze ≥1500ms; `Global.P_POST_Process` then extension | [process-view.md](../ui/patterns/process-view.md) · [process-persistence.md](../ui/patterns/process-persistence.md) · [ADR-024](../../decisions/ADR-024-platform-process-root.md) |
| People Picker | `BoPeoplePicker`; Value = `UserGUID` / `;`-joined; active only; Top-N 100; no photos V1 | [forms.md](../ui/controls/forms.md#people-picker-bopeoplepicker) |
| Example Governance | Normative + AI + **STANDARDS-compliant** Gallery; **STANDARDS win** on conflict; Gallery illustrative only | [example-governance.md](../ui/example-governance.md) |
| UX conventions | Placeholders, truncation, disabled/read-only, nav state, freeze summary, Compliance Review | [ux-conventions.md](../ui/patterns/ux-conventions.md) |
| Page Freeze | MUST for saves/bulk/perceptible workspace hydrate (incl. tab reload); MUST NOT for filter/sort/chrome-only | [overlays.md](../ui/shell/overlays.md) |
| Placeholders | Platform defaults only; no label/header echo; omit when Disabled | [ux-conventions.md](../ui/patterns/ux-conventions.md) |
| Controls | Shipped `Bo*` field types only | [ui/controls/forms.md](../ui/controls/forms.md) |
| Shuffle Card Grid | Grid-family specialized renderer (`BoShuffleCardGrid`); Gallery Grid Type; header-only required `*`; page-first; host-owned Add | [shuffle-card-grid.md](../ui/controls/shuffle-card-grid.md) |
| Tokens / type | Semantic CSS vars; Calibri | [ui/foundations/tokens.md](../ui/foundations/tokens.md), [typography.md](../ui/foundations/typography.md) |
| Authority split | UX = STANDARDS `docs/ui`; API = SHARED-UI `public-component-api.md`; never read Razor for API | [ui/overview.md](../ui/overview.md#authority-split-ux-vs-api), [parameter-reference.md](../ui/controls/parameter-reference.md) |
| Normative tiers | Tier 1 LOCKED / 2 STANDARD / 3 GUIDANCE | [normative-tiers.md](../ui/foundations/normative-tiers.md) |
| Selection / navigation | Tabs vs Toggle vs Panel Nav vs Drop-Down; intent-based authority; keyboard | [selection-and-navigation.md](../ui/controls/selection-and-navigation.md) |
| Buttons / Actions | Hierarchy, Danger, `BoIconButton`, Save / Discard, Actions area | [button.md](../ui/controls/button.md), [actions-area.md](../ui/patterns/actions-area.md) |
| Page shape / states | Archetypes; empty / loading / error / toast | [page-archetypes.md](../ui/patterns/page-archetypes.md), [page-states.md](../ui/patterns/page-states.md) |
| Icons / a11y / motion | Icon sizes; WCAG 2.2 AA; approved motion tokens | [icons.md](../ui/foundations/icons.md), [accessibility.md](../ui/foundations/accessibility.md), [motion.md](../ui/foundations/motion.md) |
| Gallery coverage | Pattern → Gallery path (non-authoritative); confirm STANDARDS first; DEV-002 gaps | [gallery-index.md](../ui/gallery-index.md) |

---

## Localization standards

| Rule | SSOT |
| --- | --- |
| Each app owns its own `.resx` library — never reuse Gallery `BoUi` as a shared glossary | [ui/foundations/i18n.md](../ui/foundations/i18n.md) |
| Never hardcode user-visible labels | Same |
| Languages `en` / `fr`; cookies `bo-culture` / `bo-timezone` via `IBoLocaleService` | Same |
| Host: `AddBreezeOnUI()`, `UseRequestLocalization`, early `bo-locale.js`, `BoProviders` | Same |
| Re-render on `Locale.Changed` where localized text is shown | Same |

EAC example: `EacResources` + `IEacLocalizer` (locale-aware, not ambient-only).

---

## How to use this summary

1. Match the task to a row above.
2. Open the SSOT link for binding detail.
3. Do not treat this summary as a substitute for page checklist or ADRs when implementing UI or architecture.
