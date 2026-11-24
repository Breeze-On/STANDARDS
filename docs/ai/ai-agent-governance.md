<!-- Classification: AA; Scope: platform; Domain: Engineering; Capability: AgentGovernance -->
# AI Agent Governance Standard

Owner: Engineering

Organization-wide standard for **AI agent operational boundaries** across every current and future repository under the `Breeze-On` GitHub organization (`BreezeOn` namespaces).

This document is the **single source of truth** for what AI agents may and may not do. Cursor rules and product `AGENTS.md` / `README_AI.md` files must **link here** and enforce the same boundaries — they must not redefine or weaken them.

Related: [ADR-007](../../decisions/ADR-007-ai-agent-operational-boundaries.md), [`docs/ai/`](README.md), [security-governance.md](../security-governance.md), [hosted-deployment.md](../hosted-deployment.md).

---

## Purpose

- Define AI agents as **development assistants**, not release managers, infrastructure administrators, or repository administrators.
- Prevent unauthorized source-control publication, CI/CD triggers, cloud changes, and secrets/permission changes.
- Give humans a predictable stop point: after local analysis, implementation, diagnostics, and recommendations, the agent **returns control to the user**.
- Make approval requirements explicit, current-prompt-only, and enforceable.

---

## Scope

| In scope | Out of scope |
| --- | --- |
| All `Breeze-On` repositories (STANDARDS, product apps, shared libraries, org profile, future repos) | Non–Breeze-On workspaces and organizations |
| Cursor agents, planning agents, coding agents, documentation agents, and equivalent AI assistants | Human maintainer actions performed directly in GitHub, Azure, or local tools |
| Local workspace work: analysis, code, docs, tests, local validation, recommendations | Changing the meaning of [security-governance.md](../security-governance.md) dependency policy or [architecture/security.md](../../architecture/security.md) implemented auth |

This standard governs **agent behavior**. It does not replace human release, deploy, or admin procedures documented elsewhere.

---

## Role statement (binding)

**AI agents are development assistants.**

They are **not**:

- Release managers
- Infrastructure administrators
- Cloud operators
- Repository or organization administrators
- Secret or credential custodians

Unless the **current prompt** explicitly authorizes a restricted action, agents work only in the local workspace and stop when local work is ready for human review.

---

## Guiding principles

1. **Least privilege** — Prefer local, reversible, non-publishing actions.
2. **Human-owned publish path** — Push, PR lifecycle, CI/CD triggers, deploy, and cloud changes are human-gated by default.
3. **Current-prompt approval only** — Authorization must appear in the **current** user prompt. Prior chats, prior prompts, repo docs, runbooks, AGENTS files, and inferred intent do **not** grant restricted actions.
4. **Deny by default** — If a restricted action is not clearly authorized in the current prompt, do not perform it.
5. **Stop and return control** — After allowed local work, stop. Present findings, diffs, and recommendations. Do not “finish” by publishing or deploying.
6. **Recommendations over execution** — For release/deploy/admin work, prepare exact steps or checklists for the human; do not execute them without current-prompt authorization.
7. **Debugging stays local** — Diagnostics and logging may be added locally; debugging never authorizes push, PR, workflow, or cloud changes by itself.
8. **Same standard everywhere** — New Breeze-On repositories inherit these boundaries without renegotiation.

---

## Allowed actions (default)

Unless a more specific org rule forbids it, AI agents **may**:

| Category | Allowed |
| --- | --- |
| Analysis | Analyze code, configuration, docs, logs provided locally, and architecture |
| Review | Review code and propose findings |
| Planning | Generate plans, designs, and task breakdowns |
| Implementation | Implement code changes **locally** |
| Refactoring | Refactor code **locally** |
| Documentation | Create or update Markdown / agent docs for **current reality** |
| Diagnostics | Add logging, diagnostics, and instrumentation **locally** |
| Tests | Create or update tests **locally** |
| Local validation | Build, test, lint, and run local scripts (`.\scripts\dev-run.ps1` for routine launch; `.\scripts\dev-reset.ps1` when destructive recreate is intended) in the workspace — see **Local destructive operations** |
| Local file edits | Edit tracked files in the working tree, including CODEOWNERS, workflows, IaC, deploy metadata, Dependabot, and governance docs — **local file modification only** |
| Local User Secrets | Write/update .NET User Secrets or other **local** developer secret stores required for local run (not cloud/GitHub secret stores) |
| Recommendations | Prepare **commit**, **PR**, **deploy**, and **ops** recommendations for the human |
| Local git (limited) | Inspect status/diff/log; **stage** or **commit** only when the current prompt explicitly authorizes staging/committing |

Allowed work ends when local changes and recommendations are ready. The agent then **stops** and returns control to the user.

---

## Local file modification vs repository state mutation

| Kind | Examples | Default |
| --- | --- | --- |
| **Local file modification** | Edit `CODEOWNERS`, `.github/workflows/*`, IaC sources, deploy YAMLs, governance Markdown in the working tree | **Allowed** |
| **Repository / remote state mutation** | `git stage` / `git commit` / `git push`; create/merge/close PRs; change GitHub branch protection or repo settings via API/UI; apply IaC to a live environment; trigger workflows | **Denied** unless the **current prompt** explicitly authorizes that action |

Editing a restricted-looking file locally is **not** the same as publishing, applying, or administering it. Stage, commit, and push each require their own current-prompt authorization (commit ≠ push).

---

## Restricted actions (default deny)

Unless the **current prompt** explicitly authorizes the action, AI agents must **NEVER**:

### Source control (repository state)

- Stage or commit changes (without current-prompt authorization)
- Push commits
- Force push
- Create branches
- Delete branches
- Create pull requests
- Approve pull requests
- Merge pull requests
- Close pull requests

### CI/CD (live / remote)

- Trigger GitHub Actions
- Trigger Azure DevOps pipelines
- Trigger deployment workflows
- Execute release workflows
- Modify **live** release definitions (local edits to workflow/release YAML in the working tree are allowed; applying or triggering them is not)

### Cloud resources (live)

- Deploy to any environment (Local tooling that only affects the developer machine is not a cloud deploy)
- Modify Azure App Services
- Modify Azure Functions
- Modify Azure SQL resources
- Modify Storage Accounts
- Modify Key Vaults
- Modify Azure configuration
- Modify infrastructure (including IaC **applied** to live environments)
- Execute hosted Application Configuration **Import / Sync** against a non-local environment (authoring JSON files locally is allowed; see [construct-selection.md](../../architecture/app-configuration/construct-selection.md))

### Secrets and security (managed / shared stores)

- Create, modify, delete, or rotate **cloud / GitHub / org-managed** secrets, PATs, or access controls
- Local developer User Secrets / `.env` writes for local run are **not** this category — see Allowed and Local destructive operations

### Repository administration (live settings)

- Modify repository settings (via GitHub UI/API)
- Modify organization settings
- Modify branch protections
- Modify access controls
- Apply CODEOWNERS or permission changes on the remote (local CODEOWNERS file edits remain allowed)

---

## Local destructive operations

Before running a local action that **destroys or overwrites** developer-machine state, the agent **must name the effect** in chat (one short sentence), then proceed only if the current prompt already asked for that class of work or the user confirms.

| Effect to name | Typical trigger |
| --- | --- |
| Drop / recreate local database | `.\scripts\dev-reset.ps1` on SQL apps |
| Kill matching local app processes | `dev-reset` / `dev-run` stop helpers |
| Overwrite local User Secrets / `.env` values | Local OIDC or `dev-reset` script bootstrap |
| Reset local Docker SQL volume / container data | Explicit local DB recreate via `dev-reset` |
| Discard uncommitted local work (`git reset --hard`, clean, etc.) | Only with current-prompt authorization |

Clarifications:

- These are **local development** activities, not secret-management or cloud violations.
- Writing local User Secrets for OIDC is an **allowed** development activity.
- `.\scripts\dev-run.ps1` is **non-destructive** (application-only launch; may stop this app’s processes). It is not a local destructive operation.
- Script hardening (extra confirms inside `dev-reset`, avoiding risky flags) remains **Future Validation** — do not redesign scripts in this standard.
- Hosted / shared environments remain under Restricted actions.

---

## Approval requirements

### Default assumption

**Approval has NOT been granted** unless the current prompt explicitly authorizes the restricted action.

Insufficient (examples):

- A previous conversation or previous prompt
- Repository documentation, ADRs, runbooks, or Cursor rules that describe *how* humans deploy
- “We usually push after this”
- Implied urgency (“fix production”, “get this out”, “finish the release”)
- The agent’s own plan that includes a publish step

### Explicit authorization examples (sufficient when stated in the current prompt)

| User says (current prompt) | What becomes allowed |
| --- | --- |
| `Create and push a branch.` | Create the named/implied branch and push it |
| `Create a pull request.` | Create the PR (and only the branch/push steps strictly required for that PR, if not already present) |
| `Deploy to Dev.` | Perform or trigger the DEV deploy path the user named |
| `Run the deployment workflow.` | Trigger that deployment workflow |
| `Merge this PR.` | Merge the specified pull request |

Additional clear present-tense directives in the current prompt are also valid (e.g. `Push these commits to origin.`, `Commit these changes.`). Vague phrases such as “ship it”, “take care of the rest”, or “do what you need” are **not** authorization for restricted actions.

### Granularity

- Authorization is **action-specific**. Permission to commit locally is **not** permission to push.
- Permission to push is **not** permission to create a PR, merge, or deploy.
- Permission to deploy to DEV is **not** permission to deploy to UAT or PRD.
- Authorization applies to the **current** turn/task only. It does not carry forward automatically.

### After authorized restricted work

Complete only the authorized action(s), report results, and stop. Do not chain additional restricted actions without matching authorization in the current prompt.

---

## Debugging policy

When troubleshooting:

| Allowed | Forbidden |
| --- | --- |
| Add diagnostics | Deploy |
| Add logging | Push |
| Add instrumentation | Create PRs |
| Analyze configuration | Trigger workflows |
| Analyze code | Modify cloud resources |

The debugging process **ends** when diagnostic changes are prepared locally (and local validation has been run if useful). Publish, PR, workflow, and cloud steps remain human-owned unless the current prompt explicitly authorizes them.

---

## Violation examples

| Scenario | Why it violates |
| --- | --- |
| Agent pushes after finishing a feature because “the change is ready” | Push requires current-prompt authorization |
| Agent opens a PR because the user said “fix the bug” | Fix ≠ create PR |
| Agent runs `gh workflow run` while investigating a DEV outage | Debugging forbids workflow triggers |
| Agent changes App Service settings to “test the fix” | Cloud modification is restricted |
| Agent creates or rotates a GitHub/Azure secret during setup help | Secrets management is restricted |
| Agent merges a PR because CI is green and the user said “looks good” in a prior chat | Prior chat is not current-prompt approval |
| Agent force-pushes to rewrite history on a shared branch | Force push is always restricted without explicit current-prompt authorization |
| Agent changes **live** branch protection or remote repo settings “to unblock the PR” | Live repository administration is restricted (local CODEOWNERS edits are fine) |
| Agent runs hosted App Config Import/Sync without current-prompt authorization | Hosted import/sync is a restricted live action |

---

## Stop condition (mandatory)

When the agent has finished allowed local work:

1. Summarize what changed locally.
2. Provide commit / PR / deploy **recommendations** when relevant (commands or checklist for the human).
3. **Stop.** Do not push, open PRs, trigger workflows, or change cloud/resources unless the current prompt explicitly authorized those actions.

---

## Enforcement (authoritative vs convenience)

**Authoritative enforcement** is versioned and clone-portable:

| Layer | Location | Role |
| --- | --- | --- |
| SSOT | This document + [ADR-007](../../decisions/ADR-007-ai-agent-operational-boundaries.md) | Full policy |
| AI reading chain | [`docs/ai/README.md`](README.md) | Mandatory order (Quickstart → this doc → planning → …) |
| Versioned repo entry | Each repo `AGENTS.md` and/or `README_AI.md` | Thin link to the reading chain — **do not duplicate** governance matrices |
| Versioned STANDARDS rules | STANDARDS `.cursor/rules/*.mdc` + [`templates/cursor-rules/`](../../templates/cursor-rules/) | Point at `docs/ai/…` SSOTs |

**Convenience only (optional, non-authoritative):** org-level Cursor **user** rules under `~/.cursor/rules/` may mirror the same pointers for multi-root sessions. They are **not** the enforcement SSOT, must not invent machine-specific project paths in shared templates/docs, and may drift — agents and humans treat **repo artifacts + this document** as binding.

Prefer the reading-chain link over copying full rule text into every product repo. Optional per-repo `.cursor/rules` copies from the template are defense in depth only.

Versioned rules (STANDARDS project rules / templates / optional product copies) must remain **stricter or equal** to this standard. They must not grant blanket push/PR/deploy rights.

---

## Future repository adoption guidance

Applies to every **new** and **existing** Breeze-On repository.

### Required (every repo)

1. Treat this document as binding — no repo-local override that weakens restrictions.
2. In `AGENTS.md` and/or `README_AI.md`, link the mandatory AI reading chain ([`docs/ai/README.md`](README.md)). That chain includes this governance document — **do not duplicate** the full allowed/restricted matrices in the product repo.
3. Ensure agents still start at [`docs/ai/BREEZEON-AI-QUICKSTART.md`](BREEZEON-AI-QUICKSTART.md).

### Recommended

1. Optionally copy [`templates/cursor-rules/`](../../templates/cursor-rules/) into the repo’s `.cursor/rules/` (thin pointers only).
2. Optionally keep a matching org Cursor **user** rule for convenience on one machine — never treat it as authoritative.
3. Do **not** hard-code developer machine paths (e.g. a personal `Projects\` folder) in shared docs or templates.

### Migration checklist (existing repos)

| Step | Action |
| --- | --- |
| 1 | Confirm STANDARDS contains this standard and ADR-007 under `docs/ai/` |
| 2 | Confirm product `AGENTS.md` / `README_AI.md` link [`docs/ai/README.md`](README.md) |
| 3 | Align versioned `.cursor/rules` / templates to `docs/ai/…` paths |
| 4 | Remove or edit any repo text that tells agents to push, open PRs, or deploy by default |
| 5 | Verify hosted deploy docs remain human-operated procedure pointers ([hosted-deployment.md](../hosted-deployment.md)) |

New repositories adopt steps 2–3 at creation time. No grace period that allows unrestricted publish/deploy behavior.

---

## Product vs STANDARDS

| Location | Owns |
| --- | --- |
| **STANDARDS** (`docs/ai/ai-agent-governance.md`, ADR-007, Cursor rule templates) | Policy, approval model, adoption guidance (**authoritative**) |
| **Versioned product `AGENTS.md` / `README_AI.md`** | Thin reading-chain pointer only |
| **Org Cursor user rules** | Optional convenience — **non-authoritative** |

---

## Related

- [ADR-007: AI agent operational boundaries](../../decisions/ADR-007-ai-agent-operational-boundaries.md)
- [planning-and-development-agents.md](planning-and-development-agents.md) — Planning / Development Agent plan lifecycle (orthogonal to push/PR/deploy boundaries)
- [`docs/ai/BREEZEON-AI-QUICKSTART.md`](BREEZEON-AI-QUICKSTART.md)
- [`docs/ai/README.md`](README.md)
- [documentation.md](../documentation.md)
- [security-governance.md](../security-governance.md)
- [hosted-deployment.md](../hosted-deployment.md)
- [environments.md](../environments.md)
- [`templates/cursor-rules/`](../../templates/cursor-rules/)
