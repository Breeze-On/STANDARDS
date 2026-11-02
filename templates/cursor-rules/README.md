# Cursor rules templates

Owner: Engineering

Copy-paste starters for Breeze-On product and platform repositories. Organization policy remains in STANDARDS — these files only help agents enforce it locally.

| File | Purpose |
| --- | --- |
| [`breezeon-ai-agent-boundaries.mdc`](breezeon-ai-agent-boundaries.mdc) | Deny-by-default AI operational boundaries (push/PR/CI/deploy/cloud/secrets/admin) |

## Install

1. Create `.cursor/rules/` in the target repository if missing.
2. Copy `breezeon-ai-agent-boundaries.mdc` into that folder.
3. Add a thin pointer in `AGENTS.md` / `README_AI.md` to [`docs/ai-agent-governance.md`](../../docs/ai-agent-governance.md).

Do not edit the copied rule to allow push, PR, deploy, cloud, or secrets by default.

SSOT: [`docs/ai-agent-governance.md`](../../docs/ai-agent-governance.md) · [ADR-007](../../decisions/ADR-007-ai-agent-operational-boundaries.md)
