<!-- Classification: AA; Scope: platform; Domain: Platform; Capability: ProcessRuntime -->
# Process runtime (platform)

Owner: Architecture · `breezeon-system-process-engine` (Process Runtime) · `breezeon-system-admin-eac` (`Global` schema container + `P_GET_ProcessTable`) · product apps (`{UniqueCode}.Process`) · SHARED-UI (presentation)

SSOT for the **two-tier** runtime Process model. Decision records: [ADR-024](../../decisions/ADR-024-platform-process-root.md) · [ADR-025](../../decisions/ADR-025-process-history.md) · [ADR-026](../../decisions/ADR-026-process-engine-and-metadata-framework.md) · [ADR-027](../../decisions/ADR-027-request-number-and-sequence-allocation.md) · [ADR-028](../../decisions/ADR-028-process-runtime-ownership-process-engine.md).

## Model

| Tier | Qualified name | Role |
| --- | --- | --- |
| Platform root | `Global.Process` | Universal process identity (`ProcessGUID`) + Application Context binding |
| Platform history | `Global.ProcessHistory` | Append-only decision / workflow-action ledger keyed by `ProcessGUID` |
| Application extension | `{UniqueCode}.Process` | Application-specific flat business fields + required **Sequence\*** columns (`SequenceTemplate`, `SequenceDisplay`, `Sequence`) |

`ProcessGUID` is the platform identity. Application processes **consume** it; they do **not** generate it. **Request Number** is a computed business display id (never persisted) — [ADR-027](../../decisions/ADR-027-request-number-and-sequence-allocation.md).

### Ownership

| Asset | Owner | Deploy |
| --- | --- | --- |
| Schema `Global` container | EAC | EAC |
| `Global.Process` + `P_POST_Process` / `P_GET_Process` | Process Engine | EAC local reset deploys PE pack |
| `Global.ProcessHistory` + history SPs (incl. projection) | Process Engine | EAC local reset deploys PE pack |
| `Global.ProcessSequenceCounter` + allocate SP | Process Engine | EAC local reset deploys PE pack |
| `Global.P_GET_ProcessTable` | EAC | EAC |
| Runtime services (`CreateProcessAsync`, `RecordProcessHistoryAsync`, `GenerateProcessSequenceAsync`) | Process Engine | — |
| History grid + display models (`BoProcessHistoryDisplayRow`) | SHARED-UI | — |
| `{UniqueCode}.Process` extension | Product application | Product |

**Hard rule:** no repository owns a SQL object whose authoritative source lives in another repository. EAC may **deploy** PE SQL; PE remains the sole authoritative owner ([ADR-028](../../decisions/ADR-028-process-runtime-ownership-process-engine.md)).

### Process table resolution and Process Engine

- Authoritative SP: **`Global.P_GET_ProcessTable`** (EAC) — resolves which `{UniqueCode}.Process` extension a `ProcessGUID` belongs to.
- Foundational consumer: Process Engine `IProcessTableResolver` ([ADR-026](../../decisions/ADR-026-process-engine-and-metadata-framework.md) · [process-engine/README.md](../process-engine/README.md)).
- Runtime Process Metadata (Variables → tokens → Sequence\* → Request Number): [process-metadata/README.md](../process-metadata/README.md).
- Full Process Runtime SQL pack (Process, History, sequence) ships in PE and is applied via EAC local reset discovery.

### Process History

- Create: Process Engine `RecordProcessHistoryAsync` → `Global.P_POST_ProcessHistory` (apps must not INSERT or call the SP directly).
- Read: `Global.P_GET_ProcessHistoryByProcessGUID` — **PE-owned display-ready projection** (consumes PF + Identity; Role, Name, Response Status, CompletedDate, Comments).
- SHARED-UI renders thin History grid + display models only; it does not own create/list SQL clients or project Role / Name / Response Status.
- UI contract: [process-history.md](../../docs/ui/patterns/process-history.md).

## Create path

Authoritative application path: Process Engine **`CreateProcessAsync`** → `Global.P_POST_Process` (`@ApplicationEnabledGUID`, `@Actor` → returns `ProcessGUID`).

Products must not insert into `Global.Process` via ad-hoc SQL/EF and must not call runtime persistence SPs directly.

### Mandatory order

1. Process Engine `CreateProcessAsync` → `Global.P_POST_Process` (SQL generates `ProcessGUID`)
2. Insert `{UniqueCode}.Process` with that `ProcessGUID`
3. Commit one shared-database transaction (runtime writes participate in the app transaction)
4. Return `ProcessGUID`
5. Redirect to Process View

UI → Application Service → Persistence Orchestration → Process Engine services → Database. The UI must not persist Process tables directly.

## AE delete

`Global.Process` rows are runtime records. Application Enabled deletion **fails** when dependents exist. Never silent cascade. See [ADR-006](../../decisions/ADR-006-application-context-ownership.md) and [ADR-024](../../decisions/ADR-024-platform-process-root.md).

## Related UI

- [process-persistence.md](../../docs/ui/patterns/process-persistence.md) — Save/Submit orchestration, Page Freeze ≥1500ms, history row in TX
- [process-view.md](../../docs/ui/patterns/process-view.md) — terminal read-only Process View
- [process-history.md](../../docs/ui/patterns/process-history.md) — History tab grid + Comments
- [process-request-section.md](../../docs/ui/patterns/process-request-section.md) — initiation Process Request fields

## Distinct from Process Framework

PF under `System` = definition metadata only ([ADR-019](../../decisions/ADR-019-process-framework-metadata.md)). Runtime root = `Global.Process`; decision ledger = `Global.ProcessHistory` ([ADR-025](../../decisions/ADR-025-process-history.md) · [ADR-028](../../decisions/ADR-028-process-runtime-ownership-process-engine.md)). Initiation codes (`00` / `va` / `va1`) and required `response-status` are PF authoring conventions consumed by the runtime ledger.

**Also distinct from Process Metadata Framework (runtime):** Variable-driven sequence templates and Request Number live in Process Engine ([ADR-026](../../decisions/ADR-026-process-engine-and-metadata-framework.md)) — not in PF EAV tables.
