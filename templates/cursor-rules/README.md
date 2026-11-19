# Cursor rules templates

Owner: Engineering

Copy-paste starters for Breeze-On product and platform repositories. Organization policy remains in STANDARDS — these files only help agents enforce it locally.

| File | Purpose |
| --- | --- |
| [`breezeon-ai-agent-boundaries.mdc`](breezeon-ai-agent-boundaries.mdc) | Deny-by-default AI operational boundaries (push/PR/CI/deploy/cloud/secrets/admin) |
| [`breezeon-planning-agent.mdc`](breezeon-planning-agent.mdc) | Planning Agent: plans in `docs/plans/in-progress/`; in-place delta updates only; never dump plans in chat |
| [`breezeon-development-agent.mdc`](breezeon-development-agent.mdc) | Development Agent: Build Locally from in-progress plan; docs + knowledge transfer; move to `docs/plans/implemented/` |

## Install

1. Create `.cursor/rules/` in the target repository if missing.
2. Copy the `.mdc` files above into that folder (keep names).
3. Ensure the product repo has `docs/plans/in-progress/` and `docs/plans/implemented/` — see [`../docs-plans/`](../docs-plans/).
4. Add thin pointers in `AGENTS.md` / `README_AI.md` to:
   - [`docs/ai-agent-governance.md`](../../docs/ai-agent-governance.md)
   - [`docs/planning-and-development-agents.md`](../../docs/planning-and-development-agents.md)

Do not edit the copied rules to allow push, PR, deploy, cloud, or secrets by default.

Do not edit the planning rule to allow rendering plan bodies in chat, full plan regenerations, V2 plans, or duplicate plan files.

Keep the matching org-level Cursor **user** rules enabled (`~/.cursor/rules/breezeon-planning-agent.mdc`, `breezeon-development-agent.mdc`, and `breezeon-ai-agent-boundaries.mdc`) so multi-repo sessions inherit the same behavior.

SSOT: [`docs/ai-agent-governance.md`](../../docs/ai-agent-governance.md) · [`docs/planning-and-development-agents.md`](../../docs/planning-and-development-agents.md) · [ADR-007](../../decisions/ADR-007-ai-agent-operational-boundaries.md)
