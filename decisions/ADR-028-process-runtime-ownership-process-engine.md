<!-- Classification: DEC; Scope: platform; Domain: Platform; Capability: ProcessRuntime -->
# ADR-028 — Process Runtime ownership (Process Engine)

## Status

Accepted

## Context

[ADR-024](ADR-024-platform-process-root.md) and [ADR-025](ADR-025-process-history.md) established the two-tier Process Runtime (`Global.Process` + `Global.ProcessHistory`) with EAC as SQL owner and SHARED-UI shipping create/list clients. [ADR-026](ADR-026-process-engine-and-metadata-framework.md) placed sequence allocation and Process Metadata in Process Engine, applied via EAC local reset discovery.

That split left Process Runtime fragmented: root/history SQL in EAC, persistence clients in SHARED-UI, sequence in Process Engine. SHARED-UI documented as presentation-only while owning runtime persistence clients. This decision consolidates Process Runtime capability ownership in Process Engine.

## Decision

### Owner

**`breezeon-system-process-engine` (`BreezeOn.ProcessEngine`) owns the Process Runtime capability**, including:

| Asset | Owner |
| --- | --- |
| `Global.Process` | Process Engine |
| `Global.ProcessHistory` | Process Engine |
| `Global.P_POST_Process` / `Global.P_GET_Process` | Process Engine |
| `Global.P_POST_ProcessHistory` / `Global.P_GET_ProcessHistoryByProcessGUID` | Process Engine |
| `Global.ProcessSequenceCounter` / `Global.P_POST_ProcessSequenceAllocate` | Process Engine (unchanged) |
| Runtime command/query services and **runtime** contracts/models | Process Engine |

### Authoritative create / history path

Product applications **must not**:

- `INSERT` directly into `Global.Process` or `Global.ProcessHistory`
- Call runtime persistence stored procedures directly

Applications consume Process Engine services:

- `CreateProcessAsync`
- `RecordProcessHistoryAsync`
- `GenerateProcessSequenceAsync` (unchanged conceptually)

**Do not** introduce a higher-level `InitiateProcessAsync` orchestration service. Applications continue to orchestrate their own business persistence while delegating shared runtime operations to Process Engine.

### Transaction rule

All runtime write operations **must participate in the application’s existing transaction**. Process Engine services must not create independent commits that can leave orphaned runtime data when a caller transaction is supplied.

```text
Application Transaction
    Process Engine → CreateProcessAsync
    Application → Persist application-specific Process extension and business data
    Process Engine → RecordProcessHistoryAsync
    Process Engine → Optional GenerateProcessSequenceAsync
Commit
```

### Global schema nuance

This decision transfers **Process Runtime capability** ownership only. It does **not** transfer ownership of the entire `Global` schema. EAC continues to own the schema container script (`00_schema_Global.sql`) and other EAC-owned Global objects (notably `Global.P_GET_ProcessTable`).

### Single authoritative SQL source (hard rule)

**No repository may own a SQL object whose authoritative source file exists in another repository.**

Clarifications:

- Every SQL object has exactly one authoritative source repository.
- Consuming repositories may **deploy**, invoke, validate, reference, or depend on SQL objects owned elsewhere.
- Consuming repositories must not maintain duplicate authoritative definitions.
- EAC may **deploy** Process Engine SQL during local reset orchestration; Process Engine remains the sole authoritative owner of those definitions.
- Ownership, deployment, and consumption must be documented distinctly.

### What EAC retains

- Application registration and Application Context
- Process Framework definitions and configuration
- Administrative capabilities and configuration contracts consumed by Process Engine
- `Global.P_GET_ProcessTable` (registry join; PE consumes via `IProcessTableResolver`)
- AE delete fail-closed when `Global.Process` dependents exist
- Local DB lifecycle orchestration (drop/recreate, seed import), including **deployment** of PE runtime SQL from the PE repo path

### What SHARED-UI retains / must not own

**Principle:** Process Engine owns runtime behavior and runtime contracts. SHARED-UI owns presentation behavior and presentation models.

SHARED-UI owns UI abstractions, routes, view/grid/presentation models, and reusable presentation components (e.g. `BoProcessHistoryGrid`). SHARED-UI must **not** be the architectural owner of runtime persistence clients or authoritative SQL.

Runtime contracts, runtime DTOs, persistence models, query contracts, and Process Runtime business models belong in Process Engine. UI-specific display/view/grid/presentation/route models remain in SHARED-UI. Types are classified before relocation — do not move a type to PE solely because a runtime query currently returns it.

### Process History

Process Engine owns runtime history persistence, query APIs, and services (including the display-ready projection SP). Process Engine may **consume** Process Framework definition metadata from EAC. Process Framework **ownership** remains with EAC ([ADR-019](ADR-019-process-framework-metadata.md)).

### Local reset

EAC-driven reset remains the orchestrator. After EAC baseline (including schema `Global` and `P_GET_ProcessTable`), reset **deploys** the PE Process Runtime SQL pack from the sibling PE repository. PE is the authoritative source; EAC is the deploy orchestrator only.

## Consequences

- ADR-024 / ADR-025 / ADR-026 ownership tables are amended to name Process Engine as Process Runtime owner where applicable.
- SHARED-UI removes runtime SQL client registrations; product apps ProjectReference Process Engine for create/history/sequence.
- EAC `current_model` no longer ships duplicate Process/History authoritative scripts; `Invoke-EacProcessEngineDeployment` applies the full PE runtime pack.
- STANDARDS process-runtime, database, glossary, bootstrap, and local-dev docs distinguish ownership vs deployment vs consumption.

## Related

- [ADR-024](ADR-024-platform-process-root.md)
- [ADR-025](ADR-025-process-history.md)
- [ADR-026](ADR-026-process-engine-and-metadata-framework.md)
- [ADR-027](ADR-027-request-number-and-sequence-allocation.md)
- [ADR-019](ADR-019-process-framework-metadata.md)
- [architecture/process-runtime/README.md](../architecture/process-runtime/README.md)
- [architecture/process-engine/README.md](../architecture/process-engine/README.md)
