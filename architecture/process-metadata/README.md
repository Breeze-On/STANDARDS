<!-- Classification: AA; Scope: platform; Domain: Platform; Capability: ProcessMetadata -->
# Architecture — Process Metadata Framework (runtime)

Owner: Architecture · implemented in [`breezeon-system-process-engine`](https://github.com/Breeze-On/breezeon-system-process-engine)

**This document is the org SSOT for the runtime Process Metadata Framework.** It is **orthogonal** to Process Framework (PF) definition metadata ([ADR-019](../../decisions/ADR-019-process-framework-metadata.md) · [process-framework/README.md](../process-framework/README.md)).

Decisions: [ADR-026](../../decisions/ADR-026-process-engine-and-metadata-framework.md) · [ADR-027](../../decisions/ADR-027-request-number-and-sequence-allocation.md). Engine index: [process-engine/README.md](../process-engine/README.md).

## Disambiguation (mandatory)

| Term | Layer | Meaning |
| --- | --- | --- |
| **Process Framework metadata (PF)** | Definition / authoring (EAC) | Roles, Steps, Options + EAV metadata columns/values under `System` |
| **Process Metadata Framework (runtime)** | Runtime (Process Engine) | AE Variable templates → token resolution → persisted `SequenceTemplate` / `SequenceDisplay` / `Sequence` → **Request Number** |

Do **not** use “Process metadata” without the qualifier when the distinction matters. PF does not allocate sequences or format Request Numbers. Runtime Process Metadata does not author Roles / Steps / Options.

## Purpose (Current Implementation)

1. Read Application Context Variable **TEXT** values by permanent Variable Codes
2. Resolve bracket tokens (`[Name]`) against process context
3. Persist resolved strings on the product `{UniqueCode}.Process` extension
4. Allocate sequences and format Request Numbers (display only — never persist RequestNumber)

## Variable Codes (permanent contracts)

| Code | Role |
| --- | --- |
| `sequence-template` | Allocation stream key after token resolution |
| `sequence-display` | Display prefix after token resolution |

- Codes are **not** localization values or user-facing labels.
- Do **not** rename or alias.
- Missing / unset at AE → resolved raw string `""` (no error, no fallback).
- Generation remains allowed when either or both are missing.

Variables SSOT (authoring + construct selection): [architecture/variables/](../variables/README.md). Runtime PE consumption of these Codes is **Current Implementation** (not Future Validation).

## Persist location

On **every** `{UniqueCode}.Process` extension:

| Column | Type |
| --- | --- |
| `SequenceTemplate` | `NVARCHAR(600) NULL` |
| `SequenceDisplay` | `NVARCHAR(600) NULL` |
| `Sequence` | `INT NULL` |

Never persist `RequestNumber` or `SequenceDigits`. `Global.Process` stays [ADR-024](../../decisions/ADR-024-platform-process-root.md)-minimal.

## Save vs generate

| Moment | Behavior |
| --- | --- |
| Save while `Sequence IS NULL` | Re-resolve and overwrite Template + Display |
| After `Sequence` set | Template + Display frozen |
| Generate | Allocate + set `Sequence`; fail if already generated with exact message in ADR-027 |

## Related

- [docs/database.md](../../docs/database.md) § Process table convention
- [docs/glossary.md](../../docs/glossary.md) — Request Number, Process Metadata Framework (runtime), SequenceTemplate, Token Resolution
- PE detail: [process-metadata-framework.md](https://github.com/Breeze-On/breezeon-system-process-engine/blob/main/docs/process-metadata-framework.md) (`breezeon-system-process-engine`; GitHub legacy: `breezeon-system-process-engine`)
