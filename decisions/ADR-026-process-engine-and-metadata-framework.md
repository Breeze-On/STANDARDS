<!-- Classification: DEC; Scope: platform; Domain: Platform; Capability: ProcessEngine -->
# ADR-026 — Process Engine and Process Metadata Framework (runtime)

## Status

Amended — Process Engine owns the full Process Runtime (Process, History, sequence), not sequence-only; see [ADR-028](ADR-028-process-runtime-ownership-process-engine.md).

## Context

[ADR-024](ADR-024-platform-process-root.md) established the two-tier Process runtime (`Global.Process` + `{UniqueCode}.Process`). Product applications need reusable platform services for:

- Resolving which application Process extension table a `ProcessGUID` belongs to
- Resolving bracket tokens against process context
- Reading Application Context Variable TEXT values into sequence templates
- Allocating concurrency-safe integer sequences and formatting **Request Numbers**

These capabilities must not live inside product apps (duplication) or inside `breezeon-system-shared-ui` (UI library boundary). They are also **orthogonal** to Process Framework **definition** metadata ([ADR-019](ADR-019-process-framework-metadata.md)) — PF remains Roles / Steps / Options authoring; this decision covers **runtime** Process Metadata and sequence services.

A dedicated shared library repository is required so product apps consume the same foundation via sibling `ProjectReference` (same interim model as `BreezeOn.UI`).

## Decision

### Repository and namespace

| Item | Value |
| --- | --- |
| Repository | **`breezeon-system-process-engine`** (GitHub legacy until rename: `breezeon-system-process-engine`) |
| Namespace / assembly | **`BreezeOn.ProcessEngine`** |
| Kind | Shared library (not a hosted business application) |

Approved repository-name form is lowercase kebab-case `breezeon-system-process-engine` ([naming.md](../docs/naming.md)). A leading `breezeon-` segment is branding/ownership, not a naming-standard requirement for every future repo.

### Process Metadata Framework (runtime) — disambiguation

| Term | Meaning | SSOT |
| --- | --- | --- |
| **Process Framework metadata (PF)** | Definition-time Roles / Steps / Options + EAV column/value catalog | [ADR-019](ADR-019-process-framework-metadata.md) |
| **Process Metadata Framework (runtime)** | Variable templates → token resolution → persisted `SequenceTemplate` / `SequenceDisplay` / `Sequence` → Request Number | This ADR · [architecture/process-metadata](../architecture/process-metadata/README.md) |

Agents and authors must not conflate the two. ADR-019 does not own Request Number or sequence allocation.

### Foundational resolution

| Asset | Owner / role |
| --- | --- |
| `Global.P_GET_ProcessTable` | `breezeon-system-admin-eac` — authoritative Process table resolution by `ProcessGUID` |
| `IProcessTableResolver` / `SqlProcessTableResolver` | Process Engine — foundational consumer of `P_GET_ProcessTable` |

All Process Engine SQL that touches an application extension table **must** use the schema name returned by the resolver (quoted via PE helpers). Products must not hard-code schema names inside PE call paths.

### Shipped Current Implementation (Process Engine V1)

| Capability | Status |
| --- | --- |
| Process table resolution (`IProcessTableResolver`) | Shipped |
| Token resolution (`[Name]` bracket tokens) | Shipped |
| Process context provider + contributor model | Shipped |
| Sequence metadata resolve (`sequence-template` / `sequence-display` Variable Codes) | Shipped |
| Sequence allocation + extension assign | Shipped |
| Request Number formatting (`ProcessSequence:Digits`) | Shipped |
| Counter DDL/SP (`Global.ProcessSequenceCounter`, `Global.P_POST_ProcessSequenceAllocate`) | Shipped (definitions in PE; applied via EAC local reset discovery) |
| Process create (`CreateProcessAsync` → `Global.P_POST_Process`) | Shipped ([ADR-028](ADR-028-process-runtime-ownership-process-engine.md)) |
| Process History record/query (`RecordProcessHistoryAsync` + projection SP) | Shipped ([ADR-028](ADR-028-process-runtime-ownership-process-engine.md)) |
| Process Runtime SQL pack (`Global.Process`, `Global.ProcessHistory`, runtime SPs) | Shipped (authoritative in PE; EAC deploys on local reset) |

Detail and algorithms: [ADR-027](ADR-027-request-number-and-sequence-allocation.md).

### `Global.Process` remains ADR-024-minimal

`Global.Process` holds only platform identity + Application Context binding + audit. **Sequence columns live on every `{UniqueCode}.Process` extension only.** Do not add `SequenceTemplate`, `SequenceDisplay`, `Sequence`, `RequestNumber`, or digit-width columns to `Global.Process`.

### Consumption

Product applications consume Process Engine via a **sibling repository checkout** and a **`ProjectReference`** to `BreezeOn.ProcessEngine` sources (interim contract parallel to SHARED-UI). No NuGet package pin in V1.

```xml
<!-- Sibling folder today remains BREEZEON-SYSTEM-PROCESS-ENGINE until GitHub rename; standard name: breezeon-system-process-engine -->
<ProjectReference Include="..\..\BREEZEON-SYSTEM-PROCESS-ENGINE\src\BreezeOn.ProcessEngine\BreezeOn.ProcessEngine.csproj" />
```

### Explicit non-goals (V1) / Future Direction

Process Engine V1 is **not** a workflow engine. Out of scope for Current Implementation:

- Visual workflow designer
- Timers / schedulers
- Service bus / message orchestration
- Retry policies as a platform product
- Cross-process state machines / workflow execution runtime

Those capabilities remain **Future Direction**, aligned with [DEV-001](../docs/deviations/DEV-001-process-framework-future-engine-vision.md). PE may later host workflow execution that **reuses** table resolution, context, and metadata foundations — without claiming that work as shipped today.

Hard-coded permanent “generate on Submit” as a platform trigger is also a non-goal: applications choose when to call `GenerateProcessSequenceAsync`.

### Ownership boundaries

| Concern | Owner |
| --- | --- |
| Full Process Runtime (library + `Global.Process` / `ProcessHistory` / sequence SQL + runtime services/docs) | `breezeon-system-process-engine` |
| `Global.P_GET_ProcessTable`, Variable SQL; schema `Global` container; local reset **deployment** of PE SQL | `breezeon-system-admin-eac` |
| Product extension Sequence* columns, context contributors, Request Number UI | Product application |
| Org AA / ADRs / UX patterns | `standards` |
| Shared UI presentation (`Bo*`, History grid display models) — not runtime persistence clients | `breezeon-system-shared-ui` |

EAC **deploys** PE runtime SQL via local reset discovery; EAC does **not** own those authoritative definitions ([ADR-028](ADR-028-process-runtime-ownership-process-engine.md)).

## Consequences

- `standards` documents Process Engine as a first-class shared library in naming, landscape, application model, and process-runtime docs.
- Product bootstrap requires Sequence* columns, PE `ProjectReference` (Process Runtime + Request Number), and Request Number UI placement.
- Local EAC reset discovers and applies the sibling PE full Process Runtime SQL pack (Process, History, sequence).
- PF authoring and Process Metadata Framework (runtime) remain separately documented; glossary disambiguates both terms.
- Workflow designer / timers / bus / retries stay Future / DEV-001 — agents must not treat them as shipped PE capability.
- **Amended by [ADR-028](ADR-028-process-runtime-ownership-process-engine.md):** PE owns full Process Runtime, not sequence-only.

## Related

- [ADR-024](ADR-024-platform-process-root.md)
- [ADR-027](ADR-027-request-number-and-sequence-allocation.md)
- [ADR-019](ADR-019-process-framework-metadata.md)
- [ADR-028](ADR-028-process-runtime-ownership-process-engine.md)
- [architecture/process-engine/README.md](../architecture/process-engine/README.md)
- [architecture/process-metadata/README.md](../architecture/process-metadata/README.md)
- [architecture/process-runtime/README.md](../architecture/process-runtime/README.md)
- [DEV-001](../docs/deviations/DEV-001-process-framework-future-engine-vision.md)
- PE repo: [`Breeze-On/breezeon-system-process-engine`](https://github.com/Breeze-On/breezeon-system-process-engine)
