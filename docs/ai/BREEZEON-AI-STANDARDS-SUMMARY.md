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
| App shape | Expected application repo contents | [application-model.md](../application-model.md) |
| Environments | Org environment vocabulary | [environments.md](../environments.md) |
| Hosted deployment | App Service / publish profile / GitHub Environment deploy standard | [hosted-deployment.md](../hosted-deployment.md) |

Before new patterns: read relevant ADRs ([adr.md](../adr.md), [decisions/README.md](../../decisions/README.md)).

---

## Coding / engineering standards

| Topic | Rule (short) | SSOT |
| --- | --- | --- |
| Naming | Breeze On (display), `Breeze-On` (GitHub), `BreezeOn` (code) | [naming.md](../naming.md) |
| Stack | Follow implemented engineering conventions | [engineering.md](../engineering.md) |
| Database | Schema scripts + product `docs/db-model.md`; seed with schema changes | [database.md](../database.md) |
| Local SQL | Do not default Development to Azure SQL | [local-database.md](../local-database.md) |
| Local scripts | Every runnable host: `scripts/dev-reset.ps1` only; secrets via `.env`; keep script + README aligned when local needs change | [local-development-scripts.md](../local-development-scripts.md) |
| Placeholders | testing / observability / versioning / domain-modeling / security-governance — **not formally defined**; do not invent | Placeholder files under `docs/` |

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

---

## UI standards

| Topic | Rule (short) | SSOT |
| --- | --- | --- |
| Entry | Inventory + philosophy | [ui/overview.md](../ui/overview.md) |
| New/changed page | Checklist first | [ui/page-development.md](../ui/page-development.md) |
| Shell | `BoAppShell` required; locked header actions | [ui/shell/shell.md](../ui/shell/shell.md) |
| Navigation | Left nav locked; URL = page name | [ui/shell/navigation.md](../ui/shell/navigation.md) |
| Home | `BoNavHub` + `BoNavCardStyleHyperlink` only | Shell Home section |
| Forms layout | Section → Row → Field; `BoStack Gap="0"` | [ui/layout/](../ui/layout/) |
| Controls | Shipped `Bo*` field types only | [ui/controls/forms.md](../ui/controls/forms.md) |
| Tokens / type | Semantic CSS vars; Calibri | [ui/foundations/tokens.md](../ui/foundations/tokens.md), [typography.md](../ui/foundations/typography.md) |

---

## Localization standards

| Rule | SSOT |
| --- | --- |
| Each app owns its own `.resx` library — never reuse Gallery `BoUi` as a shared glossary | [ui/foundations/i18n.md](../ui/foundations/i18n.md) |
| Never hardcode user-visible labels | Same |
| Languages `en` / `fr`; cookies `bo-culture` / `bo-timezone` via `IBoLocaleService` | Same |
| Host: `AddBreezeOnUI()`, `UseRequestLocalization`, early `bo-locale.js`, `BoProviders` | Same |
| Re-render on `Locale.Changed` where localized text is shown | Same |

ADM example: `AdmResources` + `IAdmLocalizer` (locale-aware, not ambient-only).

---

## How to use this summary

1. Match the task to a row above.
2. Open the SSOT link for binding detail.
3. Do not treat this summary as a substitute for page checklist or ADRs when implementing UI or architecture.
