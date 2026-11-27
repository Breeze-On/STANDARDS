<!-- Classification: DEC; Scope: platform; Domain: Platform; Capability: ProcessSequence -->
# ADR-027 — Request Number and sequence allocation

## Status

Accepted

## Context

Process instances need a **business display identity** (Request Number) in addition to the immutable technical `ProcessGUID` from [ADR-024](ADR-024-platform-process-root.md). Administrators configure templates per Application Context via Variables. Allocation must be concurrency-safe, transactional with ambient Save/Submit, and reusable across product applications through Process Engine ([ADR-026](ADR-026-process-engine-and-metadata-framework.md)).

This decision freezes the persistence contract, Variable Codes, digit formatting, save/generate lifecycle, uniqueness policy, and UI placement for Request Number.

## Decision

### Identities

| Identity | Role |
| --- | --- |
| **`ProcessGUID`** | Immutable technical platform id (`Global.Process`). Apps must not mint. |
| **Request Number** | **Computed** business display id — never a persisted column. Formatted from `SequenceDisplay` + `Sequence` (or `DRAFT` when sequence is null) via Process Engine formatter. |

### Persistence columns (every `{UniqueCode}.Process`)

Required on every application Process **extension** table:

| Column | Type | Role |
| --- | --- | --- |
| `SequenceTemplate` | `NVARCHAR(600) NULL` | Resolved allocation-stream key (after token resolution) |
| `SequenceDisplay` | `NVARCHAR(600) NULL` | Resolved display prefix (after token resolution) |
| `Sequence` | `INT NULL` | Allocated integer; null until generated |

**Never persist** `RequestNumber` or `SequenceDigits` on the extension (or on `Global.Process`). Digit width is host app configuration only.

`Global.Process` stays ADR-024-minimal — no sequence columns there.

### Variable Codes (permanent contracts)

| Variable Code | Role |
| --- | --- |
| `sequence-template` | Source template for allocation stream key |
| `sequence-display` | Source template for display prefix |

Rules:

- Codes are **permanent contracts** — not localization keys or user-facing labels. Do not rename or alias.
- Missing / unset Variable at the Application Context → resolved raw string **`""`** (no error, no platform fallback default).
- **Generation remains allowed** when either or both Variables are missing (empty template stream is valid).

### Digits

- App configuration section: **`ProcessSequence:Digits`**
- Default: **4**
- Applied **only** by the Process Engine Request Number formatter (`IRequestNumberFormatter` / `ProcessSequenceOptions`)
- Not stored per row; changing digits re-pads on read (e.g. 4→6 ⇒ `INV-001234`)

Formatting:

| `Sequence` | Request Number |
| --- | --- |
| `null` | `SequenceDisplay + "DRAFT"` |
| integer | `SequenceDisplay + Sequence.ToString(D{digits})` |

### Save vs generate lifecycle

| Moment | Behavior |
| --- | --- |
| **Save** (while `Sequence IS NULL`) | Re-resolve Variables + tokens; **overwrite** `SequenceTemplate` / `SequenceDisplay` |
| **After `Sequence` is set** | Template + Display are **frozen** (immutable); PE save helpers no-op |
| **Generate** | Allocate next integer for the template stream; set `Sequence`; reject if already set |

Save does **not** allocate a sequence. Applications choose when to call generate (typical: after Initiation **Submit**).

### `GenerateProcessSequence`

Authoritative algorithm (Process Engine `IProcessSequenceService.GenerateProcessSequenceAsync`):

1. Resolve table via `IProcessTableResolver` / `Global.P_GET_ProcessTable`.
2. Load extension `Sequence` / `SequenceTemplate` / `SequenceDisplay`.
3. If `Sequence IS NOT NULL` → fail with exact message:  
   **`Sequence was already generated for this ProcessGUID`**
4. Re-resolve metadata if needed (missing Variables → `""`); generation still proceeds.
5. Refresh Template/Display while `Sequence IS NULL`.
6. Allocate via `Global.P_POST_ProcessSequenceAllocate` with **`UPDLOCK` / `HOLDLOCK`** on the counter row for that `SequenceTemplate` stream.
7. Assign `Sequence` with optimistic `WHERE Sequence IS NULL`.
8. Format Request Number with current `ProcessSequence:Digits`.

**Allocation stream key** = resolved `SequenceTemplate` string **only** (not AE, not Application). Processes that share the same resolved template share one counter — including across applications.

On failure, the **caller** rolls back the ambient transaction → **no number reserved** (do not keep an allocated counter value outside a committed transaction).

### Uniqueness

Request Numbers are **not** required to be unique across applications. Uniqueness is enforced only within a resolved `SequenceTemplate` allocation stream (`Global.ProcessSequenceCounter`). Do not add standards, tests, or validations that require cross-app Request Number uniqueness.

### UI placement

| Surface | Contract |
| --- | --- |
| Process Request section | **Three** fields: **Request Number** (left), **Initiator**, **Requested Date** |
| Request Number control | `BoFieldReadOnly` (computed display; not an editable scalar column) |
| Process View | Same Request Number display; **App Title = Request Number** |

SSOT patterns: [process-request-section.md](../docs/ui/patterns/process-request-section.md) · [process-view.md](../docs/ui/patterns/process-view.md).

## Consequences

- Every product Process extension schema includes `SequenceTemplate` / `SequenceDisplay` / `Sequence`.
- Product apps ProjectReference Process Engine and bind `ProcessSequence:Digits`.
- Initiation Save refreshes templates until sequence generation; Submit (or app-chosen moment) calls `GenerateProcessSequenceAsync`.
- UI shows Request Number left of Initiator; Process View title uses Request Number.
- Cross-app duplicate display strings (e.g. two apps both showing `INV-0001`) are allowed when streams / padding coincide.

## Related

- [ADR-026](ADR-026-process-engine-and-metadata-framework.md)
- [ADR-024](ADR-024-platform-process-root.md)
- [architecture/process-metadata/README.md](../architecture/process-metadata/README.md)
- [architecture/process-engine/README.md](../architecture/process-engine/README.md)
- [architecture/variables/variables-standard.md](../architecture/variables/variables-standard.md)
- [docs/database.md](../docs/database.md) § Process table convention
- PE docs: [generate-process-sequence.md](https://github.com/Breeze-On/BREEZEON-SYSTEM-PROCESS-ENGINE/blob/main/docs/generate-process-sequence.md) (`breezeon-system-process-engine`; GitHub legacy: `BREEZEON-SYSTEM-PROCESS-ENGINE`)
