<!-- Classification: AN; Scope: platform; Domain: Engineering; Capability: AiOnboarding -->
# BreezeOn AI documentation

Owner: Documentation

Official **AI onboarding path** for agents working in any Breeze-On repository.

These documents summarize and point into STANDARDS. They do **not** replace detailed standards, architecture, or ADRs. Current reality only.

## Reading order (mandatory)

| Order | Document | When |
| --- | --- | --- |
| **1** | [`BREEZEON-AI-QUICKSTART.md`](BREEZEON-AI-QUICKSTART.md) | **Always first** — before analysis, planning, or code |
| **2** | [`ai-agent-governance.md`](ai-agent-governance.md) | **Operational boundaries** — agents are development assistants only (no push/PR/deploy/cloud/secrets/admin unless the current prompt explicitly authorizes) |
| **3** | [`planning-and-development-agents.md`](planning-and-development-agents.md) | **Planning / Development Agents** — plans in `docs/plans/in-progress/`; in-place delta updates only; never dump plans in chat; Build Locally + knowledge transfer |
| **4** | [`BREEZEON-AI-STANDARDS-SUMMARY.md`](BREEZEON-AI-STANDARDS-SUMMARY.md) | Before changing standards-sensitive behavior |
| **5** | [`BREEZEON-AI-APPLICATION-ADOPTION.md`](BREEZEON-AI-APPLICATION-ADOPTION.md) | Before adopting or extending `BreezeOn.UI` in an app |
| **5b** | [`application-development-process.md`](application-development-process.md) | Before creating a **new** product application (Steps 1–6; repo transition before Build Locally; Step 6 hosted) |
| **6** | Repo `README_AI.md` + detailed STANDARDS links | Only after the above — drill into specifics |

## Catalog-first retrieval (after the reading order)

Do **not** ingest the full documentation corpus by default. Use [`ai-catalog.json`](ai-catalog.json):

1. Identify **Domain** (`Security` · `Platform` · `UI` · `Engineering` · `Operations` · `Org`)
2. Open the Domain **entry point** first (`indexes.entryPointsByDomain` — lowest `entryPointPriority`)
3. Identify **Capability**
4. Open only matching `documents` (prefer `documentType` AA, then OPS/DEC as needed)

Schema: [`ai-catalog.schema.json`](ai-catalog.schema.json). Taxonomy + banner rules: [`documentation.md`](../documentation.md) § AI documentation catalog.

## Purpose

| Goal | How this folder helps |
| --- | --- |
| Cut context burn | One short path instead of ingesting every STANDARDS file |
| Shared starting point | Same first document for Cursor, planning, build, and docs agents |
| Correct defaults | Core rules and “never do” list up front |
| Operational boundaries | Deny-by-default publish/deploy/admin — SSOT [`ai-agent-governance.md`](ai-agent-governance.md) ([ADR-007](../../decisions/ADR-007-ai-agent-operational-boundaries.md)) |
| Planning / Build Locally | Plans in `docs/plans/in-progress/`; in-place delta updates only; chat returns path + Build Locally — SSOT [`planning-and-development-agents.md`](planning-and-development-agents.md) |
| Pointers, not copies | Summaries + links to SSOT under `docs/`, `architecture/`, `decisions/` |

## After the quickstart

| Need | Go to |
| --- | --- |
| Agent push / PR / deploy / cloud limits | [`ai-agent-governance.md`](ai-agent-governance.md) |
| Planning Agent / Development Agent / `docs/plans/in-progress/` | [`planning-and-development-agents.md`](planning-and-development-agents.md) |
| New product application (inputs + Steps 1–6; repo ownership transition) | [`application-development-process.md`](application-development-process.md) |
| How we work (full) | [STANDARDS `README_AI.md`](../../README_AI.md) |
| What exists | [`architecture/landscape.md`](../../architecture/landscape.md) |
| UI page checklist | [`docs/ui/page-development.md`](../ui/page-development.md) |
| Why a decision exists | [`decisions/README.md`](../../decisions/README.md) |

Product repos stay thin: their `README_AI.md` / `AGENTS.md` should **link here first**, then add repo-local facts only.

| Approved deviations | [../deviations/README.md](../deviations/README.md) |
