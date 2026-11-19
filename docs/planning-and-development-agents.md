# Planning Agent and Development Agent rules

Owner: Documentation

**Scope:** GitHub org **Breeze-On** / namespaces **BreezeOn** — **all** repositories.

**Precedence:** These organization rules **supersede** any repository-specific planning or plan-output behavior unless the current prompt **explicitly** overrides them for that turn.

Related: [documentation.md](documentation.md) · [ai-agent-governance.md](ai-agent-governance.md) · [ADR-007](../decisions/ADR-007-ai-agent-operational-boundaries.md)

---

## BreezeOn organization standard

Breeze On follows a **Current-State Documentation** philosophy.

| Artifact | Role |
| --- | --- |
| Permanent documentation (`README*`, `docs/`, `architecture/`, ADRs, standards) | Describes **what currently exists** |
| Implementation plans (`docs/plans/in-progress/`, `docs/plans/implemented/`) | **Temporary** working artifacts |

Repository documentation must describe what currently exists.

Documentation must **not** describe planned, future, speculative, partially implemented, or aspirational behavior as if it were shipped.

Implementation plans are temporary working artifacts.

Standards and documentation are permanent artifacts.

---

## Plan lifecycle folders

The parent folder `docs/plans/` holds lifecycle subfolders only:

| Folder | Holds |
| --- | --- |
| `docs/plans/in-progress/` | New and active plans |
| `docs/plans/implemented/` | Successfully completed plans (after knowledge transfer) |

- **New** plans are created under `docs/plans/in-progress/`.
- **Active** plans remain under `docs/plans/in-progress/`.
- **Successfully completed** plans move to `docs/plans/implemented/`.

Do **not** store plan markdown files directly in the flat parent `docs/plans/` folder.

---

## Planning Agent

The Planning Agent is responsible for:

- Feature planning
- Architecture planning
- Refactoring plans
- Technical design plans
- Migration plans
- Performance plans

### Never render plans in chat

When creating a new implementation plan:

- Write the plan **directly** to a markdown file.
- **Never** render the plan content in chat.
- **Never** provide section previews.
- **Never** provide architecture summaries.
- **Never** provide implementation summaries.
- **Never** provide executive summaries.
- **Never** duplicate the markdown content in chat.

The markdown file itself is the deliverable.

### Chat response format

When a plan is **created**, return **ONLY**:

- Full file path
- File name
- Build Locally action/button (if supported)

Example:

```text
docs/plans/in-progress/security-group-members.md

[Build Locally]
```

No additional content.

When a plan is **updated**, return **ONLY**:

```text
docs/plans/in-progress/security-group-members.md

[Build Locally]
```

### Plan storage

| Lifecycle | Path |
| --- | --- |
| New / active | `docs/plans/in-progress/` |
| Completed | `docs/plans/implemented/` |

Examples:

```text
docs/plans/in-progress/security-group-members.md
docs/plans/in-progress/security-group-members-excel.md
docs/plans/in-progress/data-entity-ordering.md
docs/plans/implemented/security-group-members.md
```

File names should be descriptive and stable.

### In-place delta updates only (mandatory)

When updating an existing plan, the Planning Agent **must**:

- Update the existing markdown file **in place**.
- Apply **delta changes only**.
- Preserve existing approved content whenever possible.
- **Not** regenerate the entire plan.
- **Not** rewrite unchanged sections.
- **Not** create V2 plans (no `*-v2.md`, no parallel “revised” copies).
- **Not** create duplicate plan files.
- **Not** invent a new plan path for the same feature when an active plan already exists.

A feature should have a **single** authoritative active plan under `docs/plans/in-progress/`.

This is a **first-class** Planning Agent rule (not optional guidance). Its purpose is to minimize token consumption, plan duplication, Cursor chat verbosity, and large plan rewrites.

### Source of truth

All planning content must live in markdown files.

Chat output is **not** a source of truth.

Planning decisions should persist in files.

### Token optimization

Planning Agents must minimize token consumption.

Requirements:

- Never render large plans in chat.
- Always persist plans directly to files under `docs/plans/in-progress/` (or move to `docs/plans/implemented/` when complete).
- Update existing plans **in place** whenever possible.
- **In-place delta updates only** — see above (mandatory).
- Avoid repeating unchanged sections.
- Avoid regenerating plans that already exist.
- Prefer small targeted updates.

### Current-state documentation rule

Permanent documentation must represent **implemented reality**.

- Do **not** document future behavior.
- Do **not** document planned features.
- Do **not** leave implementation plans referenced inside standards documentation.
- Do **not** leave speculative content in permanent documentation.

### UX Standards Compliance Review (mandatory for UI plans)

BreezeOn challenges database schemas, relationships, portability, security, and reusability before build. **UX/UI discovery is a peer gate** — architecture approval is **not** UX approval.

For every **UI-bearing** plan, the Planning Agent **must** include a **UX Standards Compliance** subsection before development begins. Development must not start until it documents:

| Item | Required |
| --- | --- |
| Shared UI reuse | Which `Bo*` components are reused |
| Gallery | Which Gallery examples were reviewed |
| Applicable standards | Links to [page-development.md](ui/page-development.md), [ux-conventions.md](ui/patterns/ux-conventions.md), and control SSOTs |
| Page Freeze | Expectations (MUST / MUST NOT) — include cold hydrate vs warm cache-hit navigation |
| Placeholders | Default resources vs documented semantic exceptions |
| Navigation state | Reset vs keep-alive intent |
| Truncation | How long values stay layout-stable |
| Disabled / read-only | Path for each non-editable value |
| Deviations | Intentional deviations with justification |
| Configuration Session Review | **Mandatory** for configuration-heavy work (see below) |

Incomplete UX discovery is a **planning defect**. SSOT: [ux-conventions.md](ui/patterns/ux-conventions.md) · [example-governance.md](ui/example-governance.md) · [page-development.md](ui/page-development.md).

### Configuration Session Review (mandatory for configuration-heavy plans)

Peer gate to Dirty State and Page Freeze. For plans that load/edit configuration catalogs or multi-module Application Configuration data, the Planning Agent **must** document:

- Session Key · Session Lifetime · Cache Segments
- Cache Classification — Cache Always / Cache Conditionally / Never Cache
- Working Copy vs Baseline ownership · Dirty State interaction
- Cache Invalidation Matrix (actions → None / Partial / Full session rebuild)
- Save · Discard · Import · Export behavior
- Page Freeze interaction · Session rebuild events

Governing question: **What should be cached, what should not be cached, and when must cache be invalidated?**

Plans that only say “cache results” or “reload on tab switch” without classification and an invalidation matrix are non-compliant. Extending an existing session requires a **delta matrix**. Outcome may be “no session cache” only with documented Never Cache rationale — skipping the review is not allowed.

SSOT: [configuration-session-cache.md](../architecture/app-configuration/configuration-session-cache.md) · [ADR-020](../decisions/ADR-020-configuration-session-cache.md).

---

## Development Agent

The Development Agent must integrate with the Planning Agent workflow.

### Build Locally behavior

When **Build Locally** is executed:

1. Automatically locate the corresponding plan file under `docs/plans/in-progress/`.
2. Use the plan file as the implementation source.
3. Do **not** request the plan again through chat.
4. Implement directly from the markdown plan.
5. Preserve architecture decisions documented in the plan.
6. Update the plan status throughout implementation if appropriate (delta updates only).
7. For UI work: confirm the plan’s **UX Standards Compliance** subsection is present; run [page-development.md](ui/page-development.md) + [ux-conventions.md](ui/patterns/ux-conventions.md).
8. **Before custom UX:** validate that an existing Shared UI component, Gallery example, or documented pattern does **not** already solve the problem. Prefer Gallery as the copy source. Refuse undocumented deviations.
9. For configuration-heavy work: implement only against an approved Configuration Session model (segments, classification, invalidation matrix). Do not invent reload-on-activate behavior. Wire Save / Discard / Import / Export / Page Freeze to the matrix; update segment inventory + invalidation docs in the same change set.

### Documentation responsibilities

During implementation, the Development Agent must update all affected documentation.

Examples:

- `README_AI.md`
- `data-portability.md`
- `db-model.md`
- architecture documentation
- standards documentation
- implementation guidance
- developer documentation

Documentation updates are part of feature completion.

### Knowledge transfer

Any lasting knowledge discovered during implementation must be transferred from the temporary plan into **permanent** documentation.

Examples:

- New standards
- New architectural patterns
- New conventions
- Reusable implementation approaches
- Data portability standards
- Performance principles
- Security requirements

Permanent knowledge must **not** remain trapped inside plans.

### Plan completion

A plan is only considered completed when **ALL** of the following are true:

- Development completed
- Validation completed
- Documentation updated
- Standards updated where required
- Knowledge transfer completed

Implementation alone is **not** sufficient.

### Failed or partial implementations

Never delete a plan merely because implementation started.

If implementation is:

- Failed
- Blocked
- Cancelled
- Partial
- Deferred

The plan must remain under `docs/plans/in-progress/`.

Update status in place (delta updates only).

### Implemented plan cleanup

After successful implementation and successful documentation updates, choose **ONE**:

**Option A (preferred)** — Move the plan from `docs/plans/in-progress/` to:

```text
docs/plans/implemented/
```

Example:

```text
docs/plans/in-progress/security-group-members.md
→ docs/plans/implemented/security-group-members.md
```

**Option B** — Delete the plan if all useful information has been transferred into permanent documentation.

Do **not** leave implemented plans in `docs/plans/in-progress/`.

Do **not** accumulate stale plans.

---

## Success criteria

Planning workflow:

```text
Request
→ Plan File Created/Updated under docs/plans/in-progress/
→ Build Locally
→ Implementation
→ Documentation Updated
→ Knowledge Transfer
→ Plan Moved to docs/plans/implemented/ (or Deleted)
```

Chat should never become the storage location for implementation plans.

Markdown files are the source of truth for plans.

Documentation is the permanent record.

Plans are temporary working artifacts.

---

## Cursor enforcement

| Layer | Location | Role |
| --- | --- | --- |
| SSOT | This document | Full Planning / Development Agent policy |
| Org user rules | `~/.cursor/rules/breezeon-planning-agent.mdc`, `breezeon-development-agent.mdc` | Always-on enforcement for Breeze-On work |
| STANDARDS project rules | `.cursor/rules/breezeon-planning-agent.mdc`, `breezeon-development-agent.mdc` | Same rules when STANDARDS is open |
| Product copy (optional) | Each repo `.cursor/rules/` copies from [`templates/cursor-rules/`](../templates/cursor-rules/) | Defense in depth |
| Thin product pointers | Product `AGENTS.md` / `README_AI.md` | Link here; do not restate full plan-output rules |

## Adoption in product repositories

1. Keep this document as the org SSOT (do not fork conflicting plan-output rules into product repos).
2. Copy Cursor rule starters from [`templates/cursor-rules/`](../templates/cursor-rules/) into each product `.cursor/rules/` (defense in depth with the org user rules).
3. Ensure product repos use `docs/plans/in-progress/` and `docs/plans/implemented/` — see [`templates/docs-plans/`](../templates/docs-plans/).
4. Thin product `README_AI.md` / `AGENTS.md` may point here; they must not redefine chat plan-dumping behavior.
5. Enforce via this SSOT + Cursor project/user rules only.
