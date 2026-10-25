# Architecture Decision Records (ADR)

Owner: Architecture

Standard for recording **why** significant architectural decisions were made in the Breeze On ecosystem.

## Purpose

Architecture Decision Records (ADRs) document the **context**, **decision**, and **consequences** of architectural choices that shape how Breeze On builds software.

| Document type | Answers |
| --- | --- |
| `architecture/` | **What exists** |
| `docs/` | **How we work** |
| `decisions/` (ADRs) | **Why this decision was made** |

ADRs complement STANDARDS; they do not replace `docs/` or `architecture/` descriptions of current systems.

## Current Reality Only

ADRs follow the same documentation philosophy as the rest of STANDARDS ([documentation.md](documentation.md)):

- Record decisions that **exist and govern current work**.
- Do **not** use ADRs to describe planned, speculative, or intended-future architecture as if it were implemented.
- When reality changes, update or supersede the ADR in the **same change set** as the implementation and related STANDARDS updates.

## When ADRs are required

Create or update an ADR when a change introduces or alters a **significant architectural decision**, including for example:

- Repository or packaging model (e.g. multi-repo vs other shapes)
- UI hosting or interactivity model for applications
- Database platform or local-vs-hosted data approach
- Shared library / public API boundaries (e.g. design-system abstraction)
- Cross-cutting authentication or hosting patterns that bind multiple repos

Routine feature work inside an existing pattern does **not** require a new ADR. Prefer extending `architecture/` and product docs when describing **what** changed without a new **why**.

## Lifecycle

1. **Proposed** — Decision under consideration; may be recorded before acceptance when useful for review. Do not treat Proposed ADRs as binding org policy until Accepted.
2. **Accepted** — Decision is in force and reflects current practice.
3. **Superseded** — A later ADR replaces this decision. Keep the file; set Status to Superseded and link to the replacement ADR. Do not delete historical ADRs.

Changing an **Accepted** decision requires either updating that ADR (same decision evolved) or accepting a new ADR and marking the old one **Superseded**.

## Naming convention

Files live under [`decisions/`](../decisions/):

```text
ADR-NNN-short-kebab-title.md
```

Examples:

- `ADR-001-multi-repository-model.md`
- `ADR-002-blazor-interactive-server.md`

| Part | Rule |
| --- | --- |
| `ADR` | Fixed prefix |
| `NNN` | Zero-padded sequence (`001`, `002`, …) |
| `short-kebab-title` | Lowercase kebab-case summary |

Document title inside the file: `# ADR-NNN: Human-readable title`.

## Status values

| Status | Meaning |
| --- | --- |
| **Proposed** | Not yet accepted as org policy |
| **Accepted** | Current governing decision |
| **Superseded** | Replaced by another ADR; retained for history |

## Template

```markdown
# ADR-XXX: Title

Status: Accepted

## Context

## Decision

## Consequences
```

## Index discoverability

The ADR index ([`decisions/README.md`](../decisions/README.md)) includes **Category** and **Impact Area** columns so agents and humans can find relevant decisions quickly. When creating or superseding an ADR, update those columns in the **same change set**. Category examples: Governance, Platform, UI, Data, Hosting, Architecture.

## Relationship to STANDARDS and product docs

| Location | Role |
| --- | --- |
| `docs/adr.md` (this file) | How ADRs work |
| `decisions/*.md` | Individual ADRs |
| `decisions/README.md` | Index with Status, Category, Impact Area |
| `docs/*` | Working standards (including this process) |
| `architecture/*` | Current implemented systems |
| Product `README` / `README_AI` | Repo-specific surface; **link** to STANDARDS and relevant ADRs — do not restate ADR content at length |

Agents and humans must **review existing ADRs** before introducing new architecture patterns. New patterns that conflict with an Accepted ADR require an explicit ADR update or supersession in the same change set.

## Definition of Done (ADR-related)

A change that affects architecture is incomplete until:

1. Implementation matches the decision.
2. Related `docs/` and/or `architecture/` reflect current reality.
3. Affected ADRs are created, updated, or superseded as required.
4. Indexes and references (STANDARDS README / README_AI) remain accurate.
5. All of the above land in the **same change set**.
