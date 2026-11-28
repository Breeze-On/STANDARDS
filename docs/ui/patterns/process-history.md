<!-- Classification: AA; Scope: platform; Domain: UI; Capability: ProcessHistory -->
# Process History

Owner: breezeon-system-process-engine (ledger + display-ready projection) · breezeon-system-shared-ui (thin History grid + `BoProcessHistoryDisplayRow`) · product apps (host composition)

Related: [ADR-025](../../../decisions/ADR-025-process-history.md) · [ADR-028](../../../decisions/ADR-028-process-runtime-ownership-process-engine.md) · [process-view.md](process-view.md) · [process-persistence.md](process-persistence.md) · [initiation-experience.md](initiation-experience.md) · [process-runtime](../../../architecture/process-runtime/README.md) · [grids.md](../controls/grids.md)

## Purpose

Cross-application, read-only history of **business decisions and workflow actions** for a process (`ProcessGUID`). Not a field-level audit trail.

## Write triggers

A history row is created only when a Process Framework option is completed:

| Trigger | StepCode | OptionCode |
| --- | --- | --- |
| Initiation Submit | `00` | `va` |
| Initiation Save | `00` | `va1` |
| Workflow task action | task step | chosen option |

Authoritative create: Process Engine `RecordProcessHistoryAsync` → `Global.P_POST_ProcessHistory`. Apps must not INSERT or call the SP directly. SHARED-UI owns presentation only (no create/list SQL clients).

## Comments

- Belong to the action; persist on `Global.ProcessHistory.Comments` (`NVARCHAR(4000)`).
- Control: `BoTextArea`, MaxLength 4000.
- Default placement when the app does not override: tab **Additional Information** → section **Additional Information** → Row 1 **Comments** (`BoProcessHistoryCommentsDefaults`).
- Apps may move, hide, or reposition; must not store Comments on `{UniqueCode}.Process`.

## Process View tab content (locked)

```text
Process History tab
  └─ Process Request (Request Number + Initiator + Requested Date) — first section
  └─ Section-level BoGrid Title "Process History"
        Role | Name | Response Status | Date | Comments
```

**Do not** place Process Request under General Information on Process View. Initiation keeps Process Request on General Information; Process View keeps it on Process History — [process-request-section.md](process-request-section.md) · [process-view.md](process-view.md).

## Retrieval

- `Global.P_GET_ProcessHistoryByProcessGUID` returns **display-ready** rows (Process Engine projects Role, Name, Response Status; consumes PF + Identity).
- SHARED-UI maps to `BoProcessHistoryDisplayRow` and renders `BoGrid` (ReadOnly, Flex columns; **Comments** `FlexWeight=2`, other columns default 1).
- Date: PE returns UTC `CompletedDate`; UI formats with `BoDateDisplay.FormatUtc`.
- Comments: **2-line clamp** via shared `BoClampedPlainText` (same control family as Text Area read-only; **placement differs** — History keeps end-of-line overlay). **Read more** overlays the end of line 2 (no extra row). **Show less** follows the full value after expand. Expanding grows the row height (not BoGrid overlay expand). Short comments omit the toggle.
- Empty: standard grid empty copy.

## Initiation conventions

See [ADR-025](../../../decisions/ADR-025-process-history.md) and Process Framework authoring: step `00` / `va` / `va1` (Save only on `00`); required option metadata `response-status`.
