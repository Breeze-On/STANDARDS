<!-- Classification: AA; Scope: platform; Domain: UI; Capability: Patterns -->
# UI — Process Request section

Owner: UI

Mandatory baseline section for every BreezeOn product application that creates or edits a process instance. Related: [page-development.md](../page-development.md), [page-archetypes.md](page-archetypes.md), [ux-conventions.md](ux-conventions.md), [forms.md](../controls/forms.md), [initiation-experience.md](initiation-experience.md), [page-footer-actions.md](page-footer-actions.md), [process-persistence.md](process-persistence.md), [process-view.md](process-view.md), [actions-area.md](actions-area.md), [database.md](../../database.md) § Process table convention, **[application-bootstrap-checklist.md](../../application-bootstrap-checklist.md)** (New Application Checklist).

Current reality: contract + naming + layout + field definitions. **Implementation is application-owned** — do **not** ship a SHARED-UI reusable Process Request package/component. Each app owns its Razor, typed model, and persistence so future apps may extend fields, visibility, or editability without breaking other applications.

## Mandatory placement (Tier 2 — STANDARD)

### Initiation (New Request / editable process)

| Layer | Required value |
| --- | --- |
| First tab | **General Information** |
| First section within that tab | **Process Request** |

Future applications may add additional tabs and additional sections **below** Process Request inside General Information. They must not move Process Request out of this position on initiation.

Typical host: the product **New Request** page (and later open-process Detail/Edit). Composition follows the **default initiation experience**: header `BoTabs` (General Information, Form outlined icon) → `BoTabPanels` → sections → rows → fields; shell **footer** Save+Submit via `BoPageFooterActions` — [initiation-experience.md](initiation-experience.md) · [page-footer-actions.md](page-footer-actions.md). Do **not** place an Actions-area Save|Discard on default initiation.

### Process View (locked — do not deviate)

| Layer | Required value |
| --- | --- |
| Tab | **Process History** |
| First section within that tab | **Process Request** (Request Number, Initiator, Requested Date) |
| Below Process Request | Process History grid — [process-history.md](process-history.md) |

**Do not** place Process Request under the **General Information** tab on Process View. General Information mirrors initiation Request Details (and other business sections) only. SSOT: [process-view.md](process-view.md) · [process-history.md](process-history.md).

## Required layout

**Row 1** (inside section Process Request):

| Position | Field |
| --- | --- |
| Left | Request Number |
| Middle | Initiator |
| Right | Requested Date |

Use `BoRow` with **exactly three** field children (equal `Weight` / default **1** unless a documented exception). Request Number is **left of** Initiator. Do not invent free-floating fields. Do **not** add `BoEmptyField` siblings to compress or left-align fields — that shrinks each field’s share ([layout.md](../layout/layout.md) § Weight). Same three-field rule applies on Process View (read-only) — [process-view.md](process-view.md).

## Field definitions

### Request Number

| Aspect | Contract |
| --- | --- |
| Label | Request Number |
| Control (initiation) | `BoTextField` with **`Disabled="true"`** (not `ReadOnly`, not `BoFieldReadOnly`) |
| Control (Process View) | `BoFieldReadOnly` (read-only display parity with other Process View scalars) |
| Source | Computed via Process Engine formatter from `SequenceDisplay` + `Sequence` (or `DRAFT` when sequence is null) — **never** a persisted column |
| Digits | Host `ProcessSequence:Digits` (default 4) — [ADR-027](../../../decisions/ADR-027-request-number-and-sequence-allocation.md) |
| Pending (initiation) | Until **every** bracket token in Variables `sequence-template` **and** `sequence-display` has a non-whitespace process-context value (`ResolvedProcessMetadata.AllTokensSatisfied`), leave **Value empty** and show Placeholder **`Pending below selections...`** (app resource; fr-CA localized). Do **not** show a partial/token-stripped Request Number. |
| Disabled / Required | Initiation: `Disabled=true`, `Required=false`. Process View: read-only display. |
| Placement | **Left** of Initiator |

Do not bind an editable text field to a `RequestNumber` column. SSOT: [process-metadata](../../../architecture/process-metadata/README.md) · [process-engine](../../../architecture/process-engine/README.md).

### Initiator

| Aspect | Contract |
| --- | --- |
| Label | Initiator |
| Control | `BoPeoplePicker` |
| Typed entity | `InitiatorUserGUID` |
| Database column | `InitiatorUserGUID` |
| Selection | Single (`AllowMultiple="false"`) |
| Disabled | **Yes** (baseline) |
| Required | **No** (`Required="false"`) |
| Auto-populate | Logged-in user (`UserGUID` from authenticated context) on new process |

Persist **UserGUID** only (string `"D"` format for the picker `Value`; case-insensitive match to hydrated Codes). Never UsersId / Email / UPN / ExternalObjectId. Display **`DisplayName (Email)`** when the user resolves — never show a GUID to end users as the primary label when resolve succeeds ([forms.md](../controls/forms.md)).

### Requested Date

| Aspect | Contract |
| --- | --- |
| Label | Requested Date |
| Control | `BoDateField` |
| Typed entity | `RequestedDate` |
| Database column | `RequestedDate` |
| Mode | Date only (`Mode="BoDateFieldMode.Date"`) |
| Value type | `DateTime?` (never `DateOnly`) |
| Disabled | **Yes** (baseline) |
| Required | **No** |
| Auto-populate | Current **local** calendar date (host locale/timezone) on new process |

## Persistence rules

On **new process** creation:

1. Populate `InitiatorUserGUID` from authenticated user context.
2. Populate `RequestedDate` from the current local date.
3. Obtain `ProcessGUID` from Process Engine **`CreateProcessAsync`** → `Global.Process` — applications **must not mint** GUIDs.
4. Persist flat fields to the application’s `{UniqueCode}.Process` **extension** using that `ProcessGUID`.

Full create order, freeze, and redirect: **[process-persistence.md](process-persistence.md)** · [database.md](../../database.md) § Process table convention · [ADR-024](../../../decisions/ADR-024-platform-process-root.md) · [ADR-028](../../../decisions/ADR-028-process-runtime-ownership-process-engine.md).

Baseline: **no manual user editing** of Request Number, Initiator, or Requested Date. Applications may later enable editing of Initiator / Requested Date or add fields in their own implementation without changing this contract’s required names or placement.

## Application ownership (locked)

| Own in the product app | Do not |
| --- | --- |
| Page / section Razor composition | A SHARED-UI `BoProcessRequest` (or equivalent) package |
| Typed edit model + save orchestration (calls PE `CreateProcessAsync` then extension insert) | Cross-app binary coupling for this section; minting `ProcessGUID`; calling runtime SPs directly |
| Product `sql/current_model` `{UniqueCode}.Process` extension | Placing process instance rows in EAC Process Framework metadata tables; owning `Global.Process` |

EAC Process Framework remains **definition metadata** only. Runtime platform root is `Global.Process` (Process Engine); application business fields are `{UniqueCode}.Process`.

## Gallery / copy-source

- `BoPeoplePicker` / `BoDateField`: breezeon-system-shared-ui Gallery `Components.razor` (people-picker, date-field tabs).
- Header tabs + initiation footer: [page-archetypes.md](page-archetypes.md), [shell.md](../shell/shell.md), [initiation-experience.md](initiation-experience.md), [page-footer-actions.md](page-footer-actions.md).

## New-app gate

Mandatory for all future BreezeOn applications — [application-bootstrap-checklist.md](../../application-bootstrap-checklist.md) · [application-development-process.md](../../ai/application-development-process.md) Default UX rules and Step 4/5. New mandatory Process Request / Process table requirements must update the New Application Checklist in the same change set.
