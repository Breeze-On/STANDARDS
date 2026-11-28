<!-- Classification: DEC; Scope: platform; Domain: Platform; Capability: ProcessHistory -->
# ADR-025 — Process History runtime ledger

## Status

Amended — ownership of Process History table / SPs / projection transferred to Process Engine per [ADR-028](ADR-028-process-runtime-ownership-process-engine.md). Ledger semantics and PF initiation conventions remain.

## Context

[ADR-024](ADR-024-platform-process-root.md) established `Global.Process` so platform capabilities (shared history, comments, attachments, notifications) can relate to a process without application-specific keys. Product apps already expose a Process History **tab** chrome, but content was a stub (Process Request fields only). Business users need a history of **decisions and workflow actions** (Submit, Save, Approve, Reject, Return, Cancel) — not a field-level audit trail.

Process Framework ([ADR-019](ADR-019-process-framework-metadata.md)) remains definition metadata only. History must live in the **runtime** Global tier and be reusable across INV, QCR, and future applications.

## Decision

### Ledger

| Asset | Owner |
| --- | --- |
| `Global.ProcessHistory` | breezeon-system-process-engine |
| `Global.P_POST_ProcessHistory` | breezeon-system-process-engine (authoritative create; apps must not INSERT or call SP directly) |
| `Global.P_GET_ProcessHistoryByProcessGUID` | breezeon-system-process-engine (**display-ready projection**; consumes PF + Identity) |
| Thin History grid + display models (`BoProcessHistoryDisplayRow`) | breezeon-system-shared-ui |
| Action triggers + page composition | Product applications |

Rows are append-only business decision events keyed by `ProcessGUID`. **Not** field-level audit. Comments for an action persist on the history row only — not on `{UniqueCode}.Process`.

### Projection ownership

**Process Engine owns Process History persistence, query APIs, and the display-ready projection SP.** `P_GET_ProcessHistoryByProcessGUID` returns display-ready columns (`Role`, `Name`, `ResponseStatus`, `CompletedDate`, `Comments`) by joining the ledger to Process Framework metadata (EAC-owned) and `Identity.Users`. SHARED-UI owns thin History grid rendering and display models only (`BoProcessHistoryDisplayRow`); it must **not** own create/list SQL clients or re-implement Role / Name / Response Status projection ([ADR-028](ADR-028-process-runtime-ownership-process-engine.md)).

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

Initiation Save/Submit (and future workflow option completion) write history in the same shared-database transaction as process create/update orchestration via Process Engine `RecordProcessHistoryAsync` → `P_POST_ProcessHistory`. INSERT-only; ADR-005 audit quartet stamped on create; no UPDATE SP in v1.

## Consequences

- STANDARDS process-runtime, process-view, process-persistence, initiation, and PF authoring docs document these conventions as current reality.
- Process Engine ships table + SPs (including projection); EAC retains PF validation for required `response-status` and deploys PE SQL on local reset.
- SHARED-UI ships thin History grid + display models, initiation rules (`va1` Save only on `00`), Comments default fragment — **not** runtime persistence clients.
- Product apps remap seeds (e.g. step-`00` `va1` = Save) and wire Save/Submit + Process View host via Process Engine services.
- **Amended by [ADR-028](ADR-028-process-runtime-ownership-process-engine.md):** PE owns Process History; SHARED-UI is presentation-only for history display.

## Related

- [ADR-024](ADR-024-platform-process-root.md)
- [ADR-019](ADR-019-process-framework-metadata.md)
- [ADR-005](ADR-005-mandatory-transactional-audit-columns.md)
- [ADR-028](ADR-028-process-runtime-ownership-process-engine.md)
- [architecture/process-runtime/README.md](../architecture/process-runtime/README.md)
- [docs/ui/patterns/process-history.md](../docs/ui/patterns/process-history.md)
