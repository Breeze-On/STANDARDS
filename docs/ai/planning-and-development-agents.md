<!-- Classification: AA; Scope: platform; Domain: Engineering; Capability: PlanningDevelopmentAgents -->
# Planning Agent and Development Agent rules

Owner: Documentation

**Scope:** GitHub org **Breeze-On** / namespaces **BreezeOn** — **all** repositories.

**Precedence:** These organization rules **supersede** any repository-specific planning or plan-output behavior unless the current prompt **explicitly** overrides them for that turn.

Related: [documentation.md](../documentation.md) · [ai-agent-governance.md](ai-agent-governance.md) · [ADR-007](../../decisions/ADR-007-ai-agent-operational-boundaries.md)

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
| `docs/plans/implemented/` | Retained completed plans only when retention is justified (`Classification: H`) |

- **New** plans are created under `docs/plans/in-progress/`.
- **Active** plans remain under `docs/plans/in-progress/`.
- **Successfully completed** plans: after knowledge transfer, **prefer delete**. Keep under `docs/plans/implemented/` only when retention is explicitly justified (audit/legal). Do not accumulate closed review corpora or fully transferred feature plans.

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
| Retained after close (exception) | `docs/plans/implemented/` |

Examples:

```text
docs/plans/in-progress/security-group-members.md
docs/plans/in-progress/security-group-members-excel.md
docs/plans/in-progress/data-entity-ordering.md
```

After knowledge transfer, **prefer delete**. Use `docs/plans/implemented/` only when retention is justified.

File names should be descriptive and stable.

### Delta updates only (mandatory)

When updating an existing plan, the Planning Agent **must**:

- Update the existing markdown file **directly**.
- Apply **delta changes only**.
- Preserve existing approved content whenever possible.
- **Not** regenerate the entire plan.
- **Not** rewrite unchanged sections.
- **Not** create V2 plans.
- **Not** create duplicate plan files.

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
- Always persist plans directly to files under `docs/plans/in-progress/` (delete after knowledge transfer; retain under `implemented/` only when justified).
- Update existing plans whenever possible.
- **Delta updates only** — see above (mandatory).
- Avoid repeating unchanged sections.
- Avoid regenerating plans that already exist.
- Prefer small targeted updates.

### Current-state documentation rule

Permanent documentation must represent **implemented reality**.

- Do **not** document future behavior.
- Do **not** document planned features.
- Do **not** leave implementation plans referenced inside standards documentation.
- Do **not** leave speculative content in permanent documentation.

### UX Standards Compliance Review (mandatory peer gate)

For every **UI-bearing** plan, Planning Agents **must** complete a **UX Standards Compliance Review** before development — peer gate to architecture, data, and security. Architecture approval is **not** UX approval.

**Document in the plan (required):**

- Shared UI (`Bo*`) components reused
- Gallery examples reviewed
- Applicable UX standards ([page-development.md](../ui/page-development.md), [ux-conventions.md](../ui/patterns/ux-conventions.md), control SSOTs)
- Page Freeze expectations
- Placeholder strategy
- Navigation-state behavior
- Truncation strategy
- Disabled / read-only behavior
- Intentional deviations with justification

SSOT detail: [ux-conventions.md](../ui/patterns/ux-conventions.md) · [page-development.md](../ui/page-development.md).

### Configuration Session Review (mandatory peer gate)

For every **configuration-heavy** plan (Application Configuration modules, or any future product workspace with circuit-scoped configuration baselines), Planning Agents **must** complete a **Configuration Session Review** before development — peer to Dirty State and UX Standards Compliance.

**Trigger:** The plan introduces or changes configuration catalogs, values workspaces, import/export sync, or tabbed configuration surfaces that retain baselines across navigation.

**Document in the plan (required fields):**

- Session Key · Session Lifetime · Cache Segments
- Cache Classification (Always / Conditionally / Never)
- Working Copy vs Baseline ownership · Dirty State interaction
- Cache Invalidation Matrix
- Save · Discard · Import · Export behavior
- Page Freeze interaction · Session rebuild events

**Governing question:** What should be cached, what should not be cached, and when must cache be invalidated?

**Acceptable outcome — “no session cache”:** Allowed only when the plan documents the classification matrix and an explicit Never Cache rationale for every segment. Skipping the review entirely is non-compliant.

SSOT: [configuration-session-cache.md](../../architecture/app-configuration/configuration-session-cache.md) · [ADR-020](../../decisions/ADR-020-configuration-session-cache.md).

Development Agents must refuse undocumented deviations from an approved Configuration Session Review when implementing configuration-heavy work.

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
6. For UI work: require the plan’s **UX Standards Compliance** subsection; follow [page-development.md](../ui/page-development.md) and [ux-conventions.md](../ui/patterns/ux-conventions.md).
7. Update the plan status throughout implementation if appropriate (delta updates only).

### Before custom UX (reuse first)

Before inventing placeholders, overlays, alignment CSS, Fluent usage, or other custom UX:

1. Confirm no existing Shared UI (`Bo*`) component, Gallery example, or documented STANDARDS pattern already solves the problem.
2. Prefer Gallery as the copy source for library patterns.
3. Refuse undocumented deviations (placeholders, overlays, alignment forks, direct Fluent on product pages).

Follow Page Freeze MUST / MUST NOT in [overlays.md](../ui/shell/overlays.md).

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

When catalog-eligible markdown is added, moved, renamed, or deleted (or Domain/Capability banners change), regenerate [`ai-catalog.json`](ai-catalog.json) in the **same change set** via [`scripts/docs/Generate-AiCatalog.ps1`](../../scripts/docs/Generate-AiCatalog.ps1). Do not hand-edit the catalog. SSOT: [`documentation.md`](../documentation.md) § AI documentation catalog.

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

Update status appropriately (delta updates only).

### Implemented plan cleanup

After successful implementation and successful documentation updates, choose **ONE**:

**Option A (preferred)** — Delete the plan if all useful information has been transferred into permanent documentation.

**Option B (exception)** — Move the plan from `docs/plans/in-progress/` to `docs/plans/implemented/` (`Classification: H`) only when retention is explicitly justified (e.g. audit/legal). Example:

```text
docs/plans/in-progress/security-group-members.md
→ docs/plans/implemented/security-group-members.md
```

Do **not** leave implemented plans in `docs/plans/in-progress/`.

Do **not** accumulate stale plans, closed review reports, or transferred feature plans as long-term inventory.

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
→ Plan Deleted (preferred) or Moved to docs/plans/implemented/ when retention justified
```

Chat should never become the storage location for implementation plans.

Markdown files are the source of truth for plans.

Documentation is the permanent record.

Plans are temporary working artifacts.

---

## Adoption in product repositories

This document is the **single source of truth**. Product repos must not redefine planning/output behavior.

1. Add a lightweight bootstrap Cursor rule from [`templates/cursor-rules/`](../../templates/cursor-rules/) that points agents here.
2. Create `docs/plans/in-progress/` and `docs/plans/implemented/` — see [`templates/docs-plans/`](../../templates/docs-plans/).
3. Point `README_AI.md` / `AGENTS.md` at this document (thin link only).
