<!-- Classification: TPL; Scope: platform -->
# Cursor rules templates

Owner: Engineering

Copy-paste starters for Breeze-On product and platform repositories. **Organization policy lives in STANDARDS** — product repos keep thin bootstrap rules that point there.

| File | Purpose |
| --- | --- |
| [`breezeon-ai-agent-boundaries.mdc`](breezeon-ai-agent-boundaries.mdc) | Deny-by-default AI operational boundaries |
| [`breezeon-planning-agent.mdc`](breezeon-planning-agent.mdc) | Lightweight bootstrap → Planning Agent SSOT |
| [`breezeon-development-agent.mdc`](breezeon-development-agent.mdc) | Lightweight bootstrap → Development Agent SSOT |

## Install (required order)

**Repository governance is authoritative.** Prefer the versioned reading chain over local copies.

1. **Governance reading chain** — agents start at [`docs/ai/README.md`](../../docs/ai/README.md) (Quickstart → governance → planning).
2. **`AGENTS.md`** — thin pointer to that chain (and product facts only).
3. **`README_AI.md`** — thin pointers to [`ai-agent-governance.md`](../../docs/ai/ai-agent-governance.md) / [`planning-and-development-agents.md`](../../docs/ai/planning-and-development-agents.md) as needed; do **not** duplicate full matrices.
4. **Optional** `.cursor/rules/` — create the folder and copy the `.mdc` files above only as **defense-in-depth**. Optional; never weaker than STANDARDS; never machine-specific paths.

Also create `docs/plans/in-progress/` and `docs/plans/implemented/` — see [`../docs-plans/`](../docs-plans/).

SSOT: [`docs/ai/ai-agent-governance.md`](../../docs/ai/ai-agent-governance.md) · [`docs/ai/planning-and-development-agents.md`](../../docs/ai/planning-and-development-agents.md) · [ADR-007](../../decisions/ADR-007-ai-agent-operational-boundaries.md)
