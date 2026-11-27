<!-- Classification: AA; Scope: platform; Domain: UI; Capability: Patterns -->
# UI — Validation Summary (live editors)

Owner: UI

Collapsible, row-oriented validation summary for live editable grids and configuration surfaces. Implementation: `BoValidationSummary` / `BoValidationIssue` in [SYSTEM-SHARED-UI](https://github.com/Breeze-On/SYSTEM-SHARED-UI). Decision: [ADR-021](../../../decisions/ADR-021-validation-summary-experience.md).

Related: [forms.md](../controls/forms.md) (deferred field chrome), [grids.md](../controls/grids.md), [shuffle-card-grid.md](../controls/shuffle-card-grid.md), [dirty-state.md](dirty-state.md), [import-summary.md](import-summary.md), [expandable-section.md](../layout/expandable-section.md).

## Principle (locked)

Validation Summary is a **live-editor** discoverability surface. It answers: which row, which field, what action — without hunting through large grids or Shuffle Cards.

| Does | Does not |
| --- | --- |
| List concise, row-oriented, actionable issues after a Save/Commit attempt | Replace deferred field chrome or Alert toasts |
| Sit **above** `BoGrid` / `BoShuffleCardGrid` content | Live inside Import Summary / pre-apply dialogs |
| Support navigate-to-error (scroll + focus) | Embed product validators or SQL |
| Hide when valid or after Discard/Reset | Show on Add New / before the first attempt |

## Sibling patterns (do not merge)

| Pattern | When |
| --- | --- |
| **Validation Summary** (this doc) | Live editable multi-row editors after failed Save/Commit |
| **Import Summary** | Pre-apply review dialog (`BoImportSummaryDialog`) — Changes Summary + Errors and Warnings |
| **Field chrome + fail badges** | Always for deferred mandatory / `ErrorText` after attempt ([forms.md](../controls/forms.md)) |
| **Alert toast** | Co-required with chrome on Save/Commit failure for Required matrix rows |

Severity vocabulary aligns with Import Summary (**Error** blocks commit; **Warning** does not) — but the controls stay separate.

## Architecture boundary

- **SHARED-UI:** `BoValidationSummary`, `BoValidationIssue`, `BoValidationIssueSeverity`, focus/navigate helpers on Grid-family surfaces — presentation only.
- **Product hosts:** Build `IReadOnlyList<BoValidationIssue>` from domain validators; place summary above the editor; wire Save/Discard clear; set field `ErrorText` or cascade `BoValidationContext` so chrome matches the summary.
- Do **not** invent per-page bullet lists (`eac-*-edit__errors`) when Validation Summary applies.

Gallery: Components Library → Other → Validation Summary.

## UX (locked)

### Placement

Dedicated **`Errors` `BoSectionSub`** (via `BoValidationSummary`), rendered **below the [Actions area](actions-area.md)** and **above** editable sections (`BoGrid` / `BoShuffleCardGrid` / Settings). In dialogs, place the summary in the dialog body above the editable grid — not a competing footer-only bullet list. Visible only when failures exist after a validation attempt; empty → not rendered.

### Chrome

- Section title: localized **Errors**.
- **Collapsible** via `BoSectionSub` `IsCollapsible="true"` + `@bind-Expanded` (same disclosure engine as [sections.md](../layout/sections.md) / [expandable-section.md](../layout/expandable-section.md)). Default **expanded** when the Errors section appears; do not reset expand/collapse on host re-renders or while issues remain visible. Do **not** substitute `BoExpandableSection` for this surface.
- Body: read-only client `BoGrid` (same presentation family as Import Summary Errors and Warnings). Collapsed body stays mounted (visibility only).
- Columns: **Error** (severity icon only, Hug) · **Row** (Compact — Code when present, otherwise localized `Row {n}` 1-based position) · **Field** (column label only; ~22% width) · **Message** (remaining width; danger/red text).
- Clickable rows → navigate-to-error.
- Do **not** use ad-hoc bullet lists for this surface.

### Error highlighting

Field invalid chrome remains SSOT in [forms.md](../controls/forms.md): danger on **control edge only**, after attempt, live clear via `NotifyFieldChanged()` / clearing host `ErrorText`.

When Validation Summary is used, hosts cascade `BoFieldErrorMessageOptions.HighlightOnly` so **inline `bo-field__error` text is suppressed** — chrome shows *where*; the Errors grid shows *what*. Row wash / card outline is out of scope.

### Navigate-to-error

When Validation Summary is used, each issue **must** be actionable when `RowKey` / `FieldKey` can resolve. Prefer focus by `FieldKey` (`data-bo-field-key`); otherwise focus/scroll the row via Grid-family helpers (`FocusRowAsync` / `bo-grid.js`).

## Data shape (host → shell)

| Type | Fields |
| --- | --- |
| `BoValidationIssue` | `Severity`, `RowKey`, `RowLabel` (Code, else `Row {n}`), `FieldKey`, `FieldLabel` (column label only), `Message` |
| `BoValidationIssueSeverity` | `Error` / `Warning` |

Hosts map domain failures into these rows. Prefer **one issue per failing row/field** — do not `Distinct()` away duplicate messages across different rows.

## BoGrid

**Baseline (always):** cell / field validation execution, deferred field chrome (borders), Alert toast on failed Save/Commit, grid `Required` helper, and section/tab fail badges when applicable.

**Validation Summary (opt-in):** `BoGrid` renders `BoValidationSummary` above the table only when `ShowValidationSummary="true"` **and** failures exist after a failed attempt. Default is **`false`** — applications must explicitly opt in. When summary is on, cascade `HighlightOnly` (chrome shows *where*; Errors grid shows *what*).

Do **not** treat every Inline Edit product grid as requiring an Errors band. Prefer chrome + toast on initiation / request forms where failing cells stay on-screen.

## BoShuffleCardGrid

Shuffle does **not** embed validation, Dirty State, or Save ([shuffle-card-grid.md](../controls/shuffle-card-grid.md)). Hosts that **opt in** to Validation Summary for multi-row editable Shuffle (Adoption Matrix **Required** admin catalogs) compose `BoValidationSummary` above the control and use `FocusRowAsync` / field focus helpers for navigate-to-error.

## Integration

| Concern | Behavior |
| --- | --- |
| Dirty State | Validation failure keeps dirty; summary stays on the page ([dirty-state.md](dirty-state.md)) |
| Save | Begin attempt → validate → populate issues → summary + chrome + toast |
| Discard | Clear issues, reset attempt |
| Import | Keep Import Summary; do not dual-stack Validation Summary on the same analyze/confirm path |
| Configuration screens | Same composition above grid/shuffle; fail badges when sections/tabs participate |

## Validation Summary Adoption Matrix

Lightweight usage matrix for Planning Agents and Dev Agents (same role as Dirty State / Configuration Session Invalidation matrices).

### Legend

| Value | Meaning |
| --- | --- |
| **Required** | Validation Summary after failed Save/Commit when failures exist; field chrome + Alert toast + navigate-to-error are co-required |
| **Optional** | Field chrome + toast (and section/tab fail badges when applicable) are the baseline; add Validation Summary when failures are easy to miss |
| **Not Recommended** | Do not use Validation Summary; use the named sibling pattern instead |

### Experience → Adoption

| Experience | Adoption | Notes |
| --- | --- | --- |
| BoGrid editable multi-row editors (general / product apps) | **Optional** | Opt-in via `ShowValidationSummary="true"` (BoGrid default **false**). Baseline remains Validate + cell chrome + toast. |
| Product initiation / request forms with embedded Inline Edit | **Optional** / typically omit | Prefer field chrome + toast when the grid is small and cells stay visible (e.g. INV Invoice Details) |
| EAC / App Configuration multi-row Values & catalog editors | **Required** | Explicitly enable summary (`ShowValidationSummary="true"` or host `BoValidationSummary`). Wide dynamic columns / paging benefit from aggregated review |
| BoShuffleCardGrid editable experiences | **Required** for admin catalogs that opt into summary; else **Optional** | Host composition when used; EAC Security Groups keep summary |
| Settings editors | **Required** for multi-row admin catalogs that opt in; **Optional** for large multi-section forms; **Not Recommended** for tiny single-entity settings | |
| Large forms | **Optional** | Baseline: chrome + toast + fail badges |
| Small forms | **Not Recommended** | Chrome + toast (+ fail badges) |
| Dialogs | **Optional** when body hosts multi-row BoGrid; **Required** for EAC/admin catalog dialogs that opt in; **Not Recommended** for small single-entity dialogs | |
| Import workflows | **Not Recommended** | Use Import Summary |
| Wizard experiences | **Optional**; **Not Recommended** for simple steps | |
| Single-field actions | **Not Recommended** | Chrome and/or toast only |
| Bulk-edit / dense admin grids | **Required** | Explicit opt-in; toast alone is non-compliant when summary is Required |

### Planning Agent evaluation (mandatory)

Before inventing validation UX, evaluate:

1. Is Validation Summary **Required / Optional / Not Recommended** for this experience?
2. Is **field chrome** enough alone? Yes for Optional / Not Recommended when failures remain findable without hunting (default for product Inline Edit).
3. Is a **toast** enough alone? Never as the only signal — toast remains co-required with **field chrome** on editable Save/Commit failure. Summary is additional when Required or opted-in Optional.
4. Should **navigate-to-error** be available? Yes whenever Validation Summary is used; required for all Required matrix rows.
5. Did the host **explicitly opt in** (`ShowValidationSummary` or composed `BoValidationSummary`)? Do not assume BoGrid enables summary by default.

## Anti-patterns

- Ad-hoc bullet lists under grids for Required matrix experiences
- Toast-only Save failures (missing field chrome) on editable grids
- Auto-enabling Validation Summary on every product Inline Edit without business need
- Showing summary before the first validation attempt
- Merging Import Summary and Validation Summary into one control
- Collapsing N row failures into one deduped string

## Documentation duty

When shipping a multi-row editable editor, apply the Adoption Matrix. Use `BoValidationSummary` when Required or when Optional is explicitly chosen — do not invent a parallel summary UX. Leave summary off unless opted in.
