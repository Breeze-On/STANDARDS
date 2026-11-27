<!-- Classification: AA; Scope: platform; Domain: Platform; Capability: ProcessEngine -->
# Architecture — Process Engine

Owner: Architecture · repository [`breezeon-system-process-engine`](https://github.com/Breeze-On/breezeon-system-process-engine) (GitHub legacy: `breezeon-system-process-engine`; `BreezeOn.ProcessEngine`)

SSOT index for the **Process Engine** shared library. Decisions: [ADR-026](../../decisions/ADR-026-process-engine-and-metadata-framework.md) · [ADR-027](../../decisions/ADR-027-request-number-and-sequence-allocation.md). Runtime Process Metadata detail: [process-metadata/README.md](../process-metadata/README.md). Two-tier Process root: [process-runtime/README.md](../process-runtime/README.md).

## Current Implementation

| Capability | Notes |
| --- | --- |
| Process table resolution | Consumes EAC `Global.P_GET_ProcessTable` via `IProcessTableResolver` |
| Token resolution | Bracket `[Name]` tokens against process context |
| Process context provider | Snapshot + product `IProcessContextContributor` model |
| Sequence metadata | Permanent Variable Codes `sequence-template` / `sequence-display` |
| Sequence allocation | `Global.ProcessSequenceCounter` + `P_POST_ProcessSequenceAllocate` (`UPDLOCK`) |
| Request Number formatting | `ProcessSequence:Digits` (default 4); never persist RequestNumber / SequenceDigits |

**Consumption:** sibling `ProjectReference` to `BreezeOn.ProcessEngine` (interim; same model as SHARED-UI).

**Persist location:** Sequence columns on `{UniqueCode}.Process` only. `Global.Process` remains [ADR-024](../../decisions/ADR-024-platform-process-root.md)-minimal.

Product PE documentation (algorithms, examples, local seeding): [`breezeon-system-process-engine`/docs](https://github.com/Breeze-On/breezeon-system-process-engine/tree/main/docs).

## Future Direction

Process Engine may later host **workflow execution** services that reuse table resolution, context, and metadata foundations. That expansion is **not shipped**. Align with [DEV-001](../../docs/deviations/DEV-001-process-framework-future-engine-vision.md) and the Process Framework [Business vision (future engine)](../process-framework/README.md#business-vision-future-engine) section.

Explicit non-goals today (must not be treated as Current Implementation):

- Visual workflow designer
- Timers / schedulers
- Service bus / message orchestration
- Platform retry-policy product
- Hard-coded permanent generate-on-Submit platform trigger (apps choose call timing)

## Related

| Document | Covers |
| --- | --- |
| [process-metadata/README.md](../process-metadata/README.md) | Runtime Process Metadata Framework (disambiguate ADR-019) |
| [process-runtime/README.md](../process-runtime/README.md) | Two-tier `Global.Process` + extension |
| [process-framework/README.md](../process-framework/README.md) | PF **definition** metadata only |
| [docs/database.md](../../docs/database.md) § Process table convention | Required Sequence* columns + `P_GET_ProcessTable` |
| [docs/ui/patterns/process-request-section.md](../../docs/ui/patterns/process-request-section.md) | Request Number UI |
| [docs/ui/patterns/process-persistence.md](../../docs/ui/patterns/process-persistence.md) | Save resolve + generate timing |
