# ADR-007: AI agent operational boundaries

Status: Accepted

## Context

Breeze On uses AI coding agents widely across STANDARDS, product, and shared-library repositories. Agents can analyze and edit local workspaces effectively, but the same tooling can also push branches, open or merge pull requests, trigger deployment workflows, and change cloud or secret configuration.

Without an organization-wide boundary, agents may treat “finish the task” as permission to publish, deploy, or administer infrastructure. That conflates **development assistance** with **release management** and **infrastructure administration**, increasing the risk of unintended production impact, secret exposure, and irreversible source-control actions.

Existing STANDARDS already define how humans deploy and how documentation must stay current. They did not previously define a binding deny-by-default operational boundary for AI agents.

## Decision

Adopt an organization-wide **AI Agent Governance Standard** ([docs/ai-agent-governance.md](../docs/ai-agent-governance.md)):

- AI agents are **development assistants** only — not release managers, cloud operators, or repository administrators.
- By default, agents may analyze, plan, implement locally, document current reality, add diagnostics, test locally, and prepare recommendations.
- By default, agents must **not** push, manage PR lifecycle, trigger CI/CD or deploy workflows, modify Azure/cloud/infrastructure, manage secrets/PATs/permissions, or change repository/organization admin settings.
- Restricted actions require **explicit authorization in the current prompt**. Prior conversations, inferred intent, and documentation that describes human procedures are not approval.
- After allowed local work, agents **stop and return control** to the human.
- Debugging authorizes local diagnostics only — not publish, PR, workflow, or cloud changes.
- Enforce via STANDARDS documentation plus Cursor rules (org user rule, STANDARDS project rule, and an optional per-repo template). All current and future `Breeze-On` repositories inherit this decision.

## Consequences

- Humans remain the gate for publish, PR lifecycle, deploy, cloud, secrets, and repo administration.
- Agent sessions become predictable: local change sets and recommendations, then stop.
- Product repos stay thin: link to STANDARDS; optional copy of the Cursor rule template; no weakened local policy.
- Agents may still commit locally when the current prompt explicitly asks — push and PR remain separately authorized.
- Urgency during incidents does not expand agent authority; debugging stays local unless the current prompt explicitly authorizes restricted actions.
