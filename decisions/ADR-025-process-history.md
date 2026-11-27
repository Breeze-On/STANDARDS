<!-- Classification: DEC; Scope: platform; Domain: Platform; Capability: ProcessHistory -->
# ADR-025 — Process History runtime ledger

## Status

Accepted

## Context

[ADR-024](ADR-024-platform-process-root.md) established `Global.Process` so platform capabilities (shared history, comments, attachments, notifications) can relate to a process without application-specific keys. Product apps already expose a Process History **tab** chrome, but content was a stub (Process Request fields only). Business users need a history of **decisions and workflow actions** (Submit, Save, Approve, Reject, Return, Cancel) — not a field-level audit trail.

Process Framework ([ADR-019](ADR-019-process-framework-metadata.md)) remains definition metadata only. History must live in the **runtime** Global tier and be reusable across INV, QCR, and future applications.

## Decision

### Ledger

| Asset | Owner |
| --- | --- |
| `Global.ProcessHistory` | breezeon-system-admin-eac |
| `Global.P_POST_ProcessHistory` | breezeon-system-admin-eac (authoritative create; apps must not INSERT) |
| `Global.P_GET_ProcessHistoryByProcessGUID` | breezeon-system-admin-eac (**display-ready projection**) |
| Thin create/list wrappers + History grid rendering | breezeon-system-shared-ui |
| Action triggers + page composition | Product applications |

Rows are append-only business decision events keyed by `ProcessGUID`. **Not** field-level audit. Comments for an action persist on the history row only — not on `{UniqueCode}.Process`.

### Projection ownership

**EAC owns Process History data retrieval and projection.** `P_GET_ProcessHistoryByProcessGUID` returns display-ready columns (`Role`, `Name`, `ResponseStatus`, `CompletedDate`, `Comments`) by joining the ledger to Process Framework metadata and `Identity.Users`. SHARED-UI is a UI rendering layer (format UTC dates locally); it must not re-implement Role / Name / Response Status projection.

### Process Framework conventions (normative for Process History)

**Initiation (PanelInitiation ≡ Step `00`):**

1. Entry Step (lowest `sortOrder`) must have code **`00`**.
2. On Step `00`: **`va`** = Submit (required); **`va1`** = Save (optional).
3. Missing step `00` or missing `va` → New Request must not render (configuration Application Error).
4. Missing `va1` on step `00` → do not render Save.
5. **`va1` has Save meaning only on Step `00`.** Presence of `va1` on any other step must never imply Save.

**`response-status`:**

- Mandatory conventional Option metadata Code on every option that can generate a Process History record.
- Missing / empty value = invalid Process Framework configuration.
- Not an ADR-019 reserved system column code; enforced as a Process History platform rule.

### Persistence

Initiation Save/Submit (and future workflow option completion) write history in the same shared-database transaction as process create/update orchestration via `P_POST_ProcessHistory`. INSERT-only; ADR-005 audit quartet stamped on create; no UPDATE SP in v1.

## Consequences

- STANDARDS process-runtime, process-view, process-persistence, initiation, and PF authoring docs document these conventions as current reality.
- EAC ships table + SPs + PF validation for required `response-status`.
- SHARED-UI ships thin query wrappers, initiation rules (`va1` Save only on `00`), CompleteAsync helper, Comments default fragment, History grid pattern.
- Product apps remap seeds (e.g. step-`00` `va1` = Save) and wire Save/Submit + Process View host.

## Related

- [ADR-024](ADR-024-platform-process-root.md)
- [ADR-019](ADR-019-process-framework-metadata.md)
- [ADR-005](ADR-005-mandatory-transactional-audit-columns.md)
- [architecture/process-runtime/README.md](../architecture/process-runtime/README.md)
- [docs/ui/patterns/process-history.md](../docs/ui/patterns/process-history.md)
