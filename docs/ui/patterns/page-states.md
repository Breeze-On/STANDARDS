<!-- Classification: AA; Scope: platform -->
# UI — Page states (empty, loading, error, toast)

Owner: UI

One place that says **which mechanism to use for each page state** and what each toast variant means. Detailed rules stay in the linked SSOTs. Related: [overlays.md](../shell/overlays.md), [shell.md § Toasts](../shell/shell.md#toasts-ibotoastservice), [error-messages.md](../shell/error-messages.md), [validation-summary.md](validation-summary.md), [ux-conventions.md](ux-conventions.md), [grids.md](../controls/grids.md), [page-archetypes.md](page-archetypes.md), [normative-tiers.md](../foundations/normative-tiers.md).

Current reality only.

## State to mechanism

| State | Mechanism | Rule | SSOT |
| --- | --- | --- | --- |
| **Empty collection** (grid / list has no rows) | Built-in empty body | `BoGrid`: localized "No items available." (`Grid_Empty`). `BoShuffleCardGrid`: optional display-only `EmptyContent` — **no** Add CTA inside the control; Add stays in the section header | [grids.md](../controls/grids.md), [shuffle-card-grid.md](../controls/shuffle-card-grid.md) |
| **Empty required collection** | Grid `Required` failure | Red helper above the table ("At least one item is required.") + Alert toast on fail paths | [grids.md](../controls/grids.md) |
| **Empty drop-down results** | `EmptyText` on the panel | Optional message; default em dash. Open panel never shows a blank box | [forms.md](../controls/forms.md#drop-down-list-bodropdownlist) |
| **No validation issues** | Validation Summary not rendered | Empty / null issues → section absent | [validation-summary.md](validation-summary.md) |
| **No import changes** | `NoChangesMessage` in Import Summary | Shown above the Changes Summary; confirm gate follows `HasChanges` | [import-summary.md](import-summary.md) |
| **Loading — perceptible backend work** (save, delete, import, export, sync, bulk, workspace / config hydration, tab/panel activation that reloads data) | **`IBoPageFreezeService`** (`RunAsync` preferred) | **MUST**. Pass an already-localized message; show outcome toasts **after** Hide | [overlays.md § Page freeze](../shell/overlays.md#page-freeze-ibopagefreezeservice) · [ux-conventions.md § Page Freeze](ux-conventions.md#page-freeze-summary) |
| **Loading — not worth blocking** (filter / sort / page / search, chrome-only tab or dialog open, validation-only, sub-second work) | None — update in place | **MUST NOT** freeze | [overlays.md](../shell/overlays.md) |
| **Loading — async lookup inside a field** | Field-owned (`BoDropDownList` / `BoPeoplePicker` `ItemsProvider`, debounce) | Latest wins; stale responses never update the UI ([`BoLatestWinsQuery`](https://github.com/Breeze-On/SYSTEM-SHARED-UI/blob/main/docs/public-component-api.md#services-and-non-visual-api)) | [query-driven-retrieval.md](../controls/query-driven-retrieval.md) |
| **Loading — button** | None | `BoButton` has no busy / spinner; use Page Freeze; dialogs disable footer actions via `Busy` / disabled flags | [button.md](../controls/button.md) |
| **Field error** | Field chrome | `ErrorText` or deferred required error **after** a validation attempt | [forms.md](../controls/forms.md#deferred-mandatory-validation-locked) |
| **Multi-row save failure** | Validation Summary + field chrome + **Alert** toast + navigate-to-error | Required where the Adoption Matrix says so | [validation-summary.md](validation-summary.md) |
| **Not authorized** | Error Message Page (`BoAccessDenied`) | Footer **off** (`ShowFooter = false`); app-agnostic copy | [error-messages.md](../shell/error-messages.md) |
| **Other page-level errors** (not found, session expired, maintenance, unhandled error) | Error Message framework | Only **Access Denied** ships; other types are **deferred** — reuse the framework design language when added | [error-messages.md § Introducing a new error type](../shell/error-messages.md#introducing-a-new-error-type) |

Do **not** invent page-local loading overlays, inline spinners that block the page, or host `<ul>` error lists ([ux-conventions.md](ux-conventions.md), [validation-summary.md](validation-summary.md)).

## Toast semantics (Tier 2 — STANDARD)

Toasts report the **outcome of a user action**. They are transient, non-blocking, and never the only place an error is shown for multi-row edits.

| Variant | Meaning | Use for | Not for |
| --- | --- | --- | --- |
| **Success** | The action completed | Saved, imported, deleted, synchronized | Progress updates; "nothing changed" |
| **Alert** | The user must **review or fix something**; recoverable | Validation failure ("Required information is missing…"), partial result, conflict the user can resolve | System faults |
| **Information** | Neutral notice; no action required | "No changes to save", background refresh notice | Anything that needs a decision |
| **Error** | The action **failed** unexpectedly (system / persistence / permission), not caused by form input | Save failed on the server, operation could not complete | Field validation (use **Alert**) |

Rules:

1. **Validation fail → Alert**, never Error ([forms.md](../controls/forms.md#deferred-mandatory-validation-locked)).
2. Content = **Main** (bold, short) + optional **Body** (one sentence of what to do next). Both are localized resources ([i18n.md](../foundations/i18n.md)); no raw exception text, schema names, or tokens ([ux-conventions.md § Admin surface language](ux-conventions.md#admin-surface-language-locked)).
3. Show outcome toasts **after** Page Freeze hides, not while it is visible.
4. One toast per outcome; do not stack a toast and a blocking dialog for the same event.
5. Toasts do not replace the Validation Summary or inline field errors; they accompany them.
6. API, stacking, dismissal, and motion: [shell.md § Toasts](../shell/shell.md#toasts-ibotoastservice) (`IBoToastService.ShowAsync`, top-right, click / Enter / Space / Escape dismiss, auto-dismiss).

## Dialog outcomes

- Confirmation of a destructive immediate action: `BoDialog` with a Danger confirm ([button.md](../controls/button.md#destructive-guidance-tier-1-for-the-confirmation-rule)).
- Informational one-off message: `BoDialogService.ShowMessageAsync` (Compact dialog), not a toast, when the user must acknowledge.
- Failed Save from a Dirty State dialog: close the dialog, stay on the page, keep dirty, surface errors on the page ([dirty-state.md](dirty-state.md)).

## Future Validation

| Id | Item |
| --- | --- |
| FV-010 | Shared skeleton / inline loading placeholder (none exists; Page Freeze is the only loading mechanism) |
| FV-011 | Additional Error Message page types (Not Found, Session expired, Maintenance) |
