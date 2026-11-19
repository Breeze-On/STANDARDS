# Cursor rules templates

Owner: Engineering

Copy-paste starters for Breeze-On product and platform repositories. **Organization policy lives in STANDARDS** — product repos keep thin bootstrap rules that point there.

| File | Purpose |
| --- | --- |
| [`breezeon-ai-agent-boundaries.mdc`](breezeon-ai-agent-boundaries.mdc) | Deny-by-default AI operational boundaries |
| [`breezeon-planning-agent.mdc`](breezeon-planning-agent.mdc) | Lightweight bootstrap → Planning Agent SSOT |
| [`breezeon-development-agent.mdc`](breezeon-development-agent.mdc) | Lightweight bootstrap → Development Agent SSOT |

## Install

1. Create `.cursor/rules/` in the target repository if missing.
2. Copy the `.mdc` files above into that folder (keep names).
3. Create `docs/plans/in-progress/` and `docs/plans/implemented/` — see [`../docs-plans/`](../docs-plans/).
4. Add thin pointers in `AGENTS.md` / `README_AI.md` to:
   - [`docs/ai-agent-governance.md`](../../docs/ai-agent-governance.md)
   - [`docs/planning-and-development-agents.md`](../../docs/planning-and-development-agents.md)

Do not fork or weaken STANDARDS rules in product copies.

SSOT: [`docs/ai-agent-governance.md`](../../docs/ai-agent-governance.md) · [`docs/planning-and-development-agents.md`](../../docs/planning-and-development-agents.md) · [ADR-007](../../decisions/ADR-007-ai-agent-operational-boundaries.md)
