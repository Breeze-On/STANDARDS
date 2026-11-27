<!-- Classification: AA; Scope: platform; Domain: UI; Capability: Patterns -->
# UI — Process Request section

Owner: UI

Mandatory baseline section for every BreezeOn product application that creates or edits a process instance. Related: [page-development.md](../page-development.md), [page-archetypes.md](page-archetypes.md), [ux-conventions.md](ux-conventions.md), [forms.md](../controls/forms.md), [initiation-experience.md](initiation-experience.md), [page-footer-actions.md](page-footer-actions.md), [process-persistence.md](process-persistence.md), [process-view.md](process-view.md), [actions-area.md](actions-area.md), [database.md](../../database.md) § Process table convention, **[application-bootstrap-checklist.md](../../application-bootstrap-checklist.md)** (New Application Checklist).

Current reality: contract + naming + layout + field definitions. **Implementation is application-owned** — do **not** ship a SHARED-UI reusable Process Request package/component. Each app owns its Razor, typed model, and persistence so future apps may extend fields, visibility, or editability without breaking other applications.

## Mandatory placement (Tier 2 — STANDARD)

| Layer | Required value |
| --- | --- |
| First tab | **General Information** |
| First section within that tab | **Process Request** |

Future applications may add additional tabs and additional sections **below** Process Request inside General Information. They must not move Process Request out of this position.

Typical host: the product **New Request** page (and later open-process Detail/Edit). Composition follows the **default initiation experience**: header `BoTabs` (General Information, Form outlined icon) → `BoTabPanels` → sections → rows → fields; shell **footer** Save+Submit via `BoPageFooterActions` — [initiation-experience.md](initiation-experience.md) · [page-footer-actions.md](page-footer-actions.md). Do **not** place an Actions-area Save|Discard on default initiation.

## Required layout

**Row 1** (inside section Process Request):

| Position | Field |
| --- | --- |
| Left | Initiator |
| Right | Requested Date |

Use `BoRow` with **exactly two** field children (equal `Weight` / default **1** unless a documented exception). Do not invent free-floating fields. Do **not** add `BoEmptyField` siblings to compress or left-align the pair — that shrinks each field’s share ([layout.md](../layout/layout.md) § Weight). Same two-field rule applies on Process View (read-only) — [process-view.md](process-view.md).

## Field definitions

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
3. Obtain `ProcessGUID` from **`Global.P_POST_Process`** / `Global.Process` — applications **must not mint** GUIDs.
4. Persist flat fields to the application’s `{UniqueCode}.Process` **extension** using that `ProcessGUID`.

Full create order, freeze, and redirect: **[process-persistence.md](process-persistence.md)** · [database.md](../../database.md) § Process table convention · [ADR-024](../../../decisions/ADR-024-platform-process-root.md).

Baseline: **no manual user editing** of these two fields. Applications may later enable editing or add fields in their own implementation without changing this contract’s required names or placement.

## Application ownership (locked)

| Own in the product app | Do not |
| --- | --- |
| Page / section Razor composition | A SHARED-UI `BoProcessRequest` (or equivalent) package |
| Typed edit model + save orchestration (calls Global create then extension insert) | Cross-app binary coupling for this section; minting `ProcessGUID` |
| Product `sql/current_model` `{UniqueCode}.Process` extension | Placing process instance rows in EAC Process Framework metadata tables; owning `Global.Process` |

EAC Process Framework remains **definition metadata** only. Runtime platform root is `Global.Process` (EAC); application business fields are `{UniqueCode}.Process`.

## Gallery / copy-source

- `BoPeoplePicker` / `BoDateField`: SYSTEM-SHARED-UI Gallery `Components.razor` (people-picker, date-field tabs).
- Header tabs + initiation footer: [page-archetypes.md](page-archetypes.md), [shell.md](../shell/shell.md), [initiation-experience.md](initiation-experience.md), [page-footer-actions.md](page-footer-actions.md).

## New-app gate

Mandatory for all future BreezeOn applications — [application-bootstrap-checklist.md](../../application-bootstrap-checklist.md) · [application-development-process.md](../../ai/application-development-process.md) Default UX rules and Step 4/5. New mandatory Process Request / Process table requirements must update the New Application Checklist in the same change set.
