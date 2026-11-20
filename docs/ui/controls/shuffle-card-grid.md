# UI — Shuffle Card Grid (`BoShuffleCardGrid`)

Owner: UI

Section-level editable card-row surface with a shared column header row and optional drag-and-drop reorder. Related: [grids.md](grids.md) (**Grid Family Standards** SSOT), [forms.md](forms.md), [sections.md](../layout/sections.md), [dirty-state.md](../patterns/dirty-state.md), [motion.md](../foundations/motion.md) (reorder motion SSOT), [overview.md](../overview.md).

**Library:** [SYSTEM-SHARED-UI](https://github.com/Breeze-On/SYSTEM-SHARED-UI) — `BoShuffleCardGrid<TItem>`, `BoShuffleCardGridColumn<TItem>`, `BoShuffleCardGridCellContext<TItem>`. Host scripts: `_content/BreezeOn.UI/js/lib/sortable.min.js`, `_content/BreezeOn.UI/js/bo-sortable.js`, and `_content/BreezeOn.UI/js/bo-grid.js` (Add New focus).

**Family membership (hard):** Shuffle Card is a **Grid-family** control. Inherit [Grid Family Standards](grids.md#grid-family-standards-locked) (reuse-first, Add New top + focus, deferred validation, accessibility). This file documents Shuffle Card–specific chrome and host wiring only — do not invent competing Add New / focus / placement rules.

## Responsibilities (locked)

| Layer | Owns |
| --- | --- |
| `BoShuffleCardGrid` | Header row, card rows, column track alignment, optional handle DnD, row-action track, empty state, optional lightweight `MaxHeight` |
| `BoShuffleCardGridColumn` | Column metadata + Field/Display templates; registers with parent |
| Host page / dialog | Items working copy; Add New (section `HeaderActions`); Save/Discard or dialog Update/Cancel; Dirty State; validation; persistence / `SortOrder` |

The library **never** talks to SQL or application repositories.

## What it is / is not (locked)

| Is | Is not |
| --- | --- |
| Grid-family section-level hybrid: one header row + editable card rows + optional shuffle | HTML-table `BoGrid` / spreadsheet |
| Page-first, host-agnostic body | Dialog-optimized control or modal shell |
| Column templates + row-action template | Built-in Add / Save / Discard / Dirty State |

**Architecture (hard):** Shuffle Card is part of the **Grid family** from a consumer perspective (Gallery **Grid Type** DDL; `BreezeOn.UI.Grid` namespace). It uses a specialized renderer (`BoShuffleCardGrid`) — **not** an HTML-table `BoGridMode`. Do **not** invent parallel product CSS copies.

## Hosting model (locked — page-first)

- **Primary design target:** page / workspace section (`BoSectionMain` / `BoSectionSub`).
- **Dialog usage:** supported as host composition (`BoDialog` wraps the same control). Dialog must not drive API, CSS, or scroll architecture.
- **Scroll:** default follows the host (page/workspace scroll). Optional `MaxHeight` is a lightweight escape hatch only.

## Add ownership (locked — host-owned)

- **Add New stays on the host** in `BoSectionMain` / `BoSectionSub` `HeaderActions`.
- `BoShuffleCardGrid` does **not** render Add, expose `ShowAdd` / `OnAdd`, or own create workflow.
- Empty state is display-only (no Add CTA inside the control).
- **Mandatory Add New path:** host creates the DTO, then calls **`InsertNewAtTopAsync(item)`** on the grid ref (requires `Items` as `IList<TItem>`). Do **not** `_items.Add` + manual `RefreshSortableAsync` for new rows.
- Family UX (top placement, auto-focus, deferred validation, keyboard-first): [Grid Family Standards](grids.md#grid-family-standards-locked).

### Shuffle Card Add New wiring (locked)

| Rule | Behavior |
| --- | --- |
| API | `InsertNewAtTopAsync(item)` — inserts at index **0**, refreshes Sortable, focuses first editable field |
| Focus | `bo-grid.js` `focusFirstEditableInShuffleRow` after paint |
| When not | Delete, reorder, field edits, or host list mutations that bypass `InsertNewAtTopAsync` |
| Exception | No editable field → focus unchanged; insert still succeeds |

Public helpers: `InsertNewAtTopAsync`, `RefreshSortableAsync` (non–Add New add/remove), `ReadDomOrderAsync` (before Save), `FocusRowAsync` (Validation Summary navigate-to-error).

## Parameters (`BoShuffleCardGrid<TItem>`)

| Parameter | Role |
| --- | --- |
| `Items` | Host working list (`IList<TItem>` or equivalent) |
| `ItemKey` | Required `Func<TItem, string>` → stable `data-key` for Sortable order |
| `Columns` | Child `BoShuffleCardGridColumn<TItem>` definitions |
| `AllowReorder` | Default **true**. When false, hide handle and do not init Sortable |
| `Disabled` | Gates editors + Sortable |
| `MaxHeight` | Optional CSS length (e.g. `min(60vh, 28rem)`). When set, list region scrolls inside the control |
| `EmptyContent` | Optional empty placeholder when `Items` is empty |
| `RowActions` | Optional template for the Hug actions track (delete, manage members, …) |
| `ReorderHandleAriaLabel` | Accessible name for the drag handle |
| `ListAriaLabel` | Accessible name for the list |
| `OnOrderChanged` | Raised with ordered keys after a drag |
| `OnChanged` | Optional host signal when fields/order/structure mutate |
| `Class`, `Style` | Optional host chrome on the root |

Public helpers: `InsertNewAtTopAsync` (Add New — top + focus); `RefreshSortableAsync` (other add/remove); `ReadDomOrderAsync` (before Save).

## Column (`BoShuffleCardGridColumn<TItem>`)

| Parameter | Role |
| --- | --- |
| `Title` | Header label — rendered **uppercase** via CSS (see Header standards) |
| `Required` | Red asterisk on header only (`.bo-field__required`). Field labels/asterisks inside cells are **hidden** (same pattern as `BoGrid`). Field templates may still set `Required` on `Bo*` fields for **validation** — not for visible asterisks |
| `ReadOnly` | Prefer Display template / read-only field path |
| `WidthTrack` | CSS grid track fragment for this column (e.g. `minmax(0, 0.9fr)`). **Use `minmax(0, …fr)`** — a non-zero minimum (`minmax(8rem, 1fr)`) or bare `1fr` lets long values widen the track. Shared definition drives **both** header cell and row cell |
| `Align` | `BoGridColumnAlign` (`Left` default / `Center` / `Right`) for header label **and** cell content (same enum as `BoGrid`). Use **`Center`** for checkbox-only columns |
| `Field` | Editable cell template |
| `Display` | Read-only / custom cell template |

Changing `Title`, `Required`, `WidthTrack`, `Align`, or templates after first render notifies the parent so headers and tracks stay aligned.

**Checkbox cells:** inside a grid, a `BoCheckbox`'s invisible label spacer is collapsed (the grid already owns the header label) and the control is centered in the cell — pair the column with `Align="BoGridColumnAlign.Center"` so header and checkbox line up.

### Cell context (`BoShuffleCardGridCellContext<TItem>`)

| Member | Role |
| --- | --- |
| `Item` | Row DTO |
| `ItemKey` | Stable key string |
| `Disabled` | Grid-level disabled |

## Header standards (locked)

- Same **size / weight / color / family / case** as `.bo-grid__th-label` (10px / 700 / `--bo-color-text-field-label` / **uppercase**).
- Header **horizontal alignment follows column `Align`** (Left default / Center / Right) — intentional difference from `BoGrid` (headers always left). See [ux-conventions.md](../patterns/ux-conventions.md) § Column header alignment.
- **`text-transform: uppercase`** (locked). Hosts may pass sentence-case `Title` strings; CSS renders `ATTRIBUTE CODE *`.
- Header padding/border box mirrors card row so tracks share content boxes. Vertical header padding matches `.bo-grid__th`. Section body does **not** add the extra `bo-grid` top inset (header row is thead-equivalent).
- Header labels are flush with the field **control box** left edge (not Fluent inner text inset).
- Actions + drag-handle track: fixed `--bo-scg-action-col-width` (shared by header and rows — not `auto`); **actions header unlabeled**.
- **`WidthTrack` MUST use `minmax(0, …fr)`** so long cell values truncate inside the track rather than skewing columns — [ux-conventions.md](../patterns/ux-conventions.md) § Control width and truncation. The library sets `min-width: 0; max-width: 100%` on `.bo-shuffle-card-grid__col` and on `.bo-field` / `.bo-ddl__*` / Fluent roots inside cells (closed DDL values ellipsize with `title`).
- **Header ↔ row alignment (hard):** header and each row are separate CSS grids that must resolve to identical tracks. The library does **not** use `min-width: max-content` on them (that made track sizes depend on each grid's own content, so long selected values misaligned headers vs controls). Tracks are container-relative; hosts needing horizontal scroll set `--bo-scg-min-width` on the grid root (`Style`), applied to header and rows alike.
- **Leading icons / actions (locked — mandatory):** the reorder handle (`ReOrderDotsVertical`) and `RowActions` (delete, …) **always** render as the **first** grid track in both header and every row, content start-aligned (`justify-content: flex-start`). End-of-row / trailing icon placement is **not supported** — there is no `ActionsPlacement` (or other) override on `BoShuffleCardGrid`. (`BoGrid` may still use `ActionsPlacement` Leading/Trailing; that enum does **not** apply to Shuffle Card.)
- Cell editors use platform default placeholders (not column titles) — [ux-conventions.md](../patterns/ux-conventions.md) § Placeholders.

## Required field standards (locked)

- Column `Required=true` → `.bo-field__required` after the title — **the only visible required indicator for the column**.
- Inside cells, `.bo-field__label` is hidden (including per-field asterisks). Do not invent a second visible required chrome.
- Field templates may set `Required` on `Bo*` fields so deferred validation still runs.
- Host owns validation messages and submit timing.

## Reordering standards (locked)

Platform cascade / settle / tokens / remount deferral: **[motion.md](../foundations/motion.md) § Reorder motion** (SSOT). Shuffle Card is the first consumer — do not fork durations or easing here.

Shuffle-specific:

- Handle-only drag (`ReOrderDotsVertical`); handle **always leading** (first track) — see Header standards. Not whole-card drag by default.
- Ghost / chosen / drag classes under `bo-shuffle-card-grid__row--*` (consume `--bo-reorder-*` for settle chrome).
- Respect `prefers-reduced-motion` (no lift/animation when reduced) — see motion SSOT.
- Order persistence remains host/SP responsibility (`SortOrder` 1..N from list order).
- Stable `ItemKey` on every row (`data-key` **and** Blazor `@key`) so host re-renders after `OnOrderChanged` reconcile by identity, not by index — Sortable moves DOM outside Blazor; unkeyed rows desync on the first drag.
- On successful drop: mutate host `IList` and raise `OnOrderChanged` / `OnChanged` immediately; remount list + re-init Sortable after drop (FLIP cascade runs during drag swaps and is cleared by `onEnd` — do not add a post-drop delay that only feels laggy). Generation-guarded interop ignores stale `onEnd` callbacks. Membership fingerprint alone must not treat reorder as add/remove. Do **not** CSS-transition `transform` on rows (Sortable FLIP owns transform).
- Final drop index is derived from pointer Y vs sibling row midlines (tall cards make Sortable `swapThreshold` miss index 0/last). Do **not** enable Sortable `forceFallback` — it paints `ghostClass` on the source row on micro-moves/clicks and flashes a washed/white card when row opacity/background are transitioned.
- Sync order from DOM before save when hosts need it (`ReadDomOrderAsync`).

## Responsive behavior (locked — v1)

- Shared CSS grid tracks for header and each card row.
- When many columns overflow: **horizontal overflow scroll** on the surface so header cells stay aligned with fields (set `--bo-scg-min-width` on the grid root; default `0` = fit container and truncate).
- Do **not** stack per-card labels in v1.

## Theming (locked)

- Card rows use card-container tokens (`--bo-color-card-container-*`, border, radius, shadow).
- Handle / delete icon chrome follows theme text and danger tokens.
- Light/Dark via existing `BoThemeProvider` variables.

## Accessibility

Family expectations (Add New focus, keyboard-first, deferred validation, errors vs warnings): [Grid Family Standards — Accessibility](grids.md#accessibility-grid-family).

Shuffle Card–specific:

- List: `role="list"` + `ListAriaLabel`.
- Rows: `role="listitem"` + `data-key`.
- Header row may be `aria-hidden="true"` when column titles are also conveyed via field placeholders/labels; prefer visible sentence-case headers for sighted users.
- Handle and icon actions require `title` / `aria-label`.
- Keyboard reorder is a **follow-up** (not required for v1 standardization).

## Dirty State

`BoShuffleCardGrid` does **not** embed Dirty State. Hosts wire page `EacDirtyStateGuard` (or equivalent) or dialog local discard confirm per [dirty-state.md](../patterns/dirty-state.md).

## Validation Summary (host composition — locked)

`BoShuffleCardGrid` does **not** embed validation, Save, or Validation Summary. For multi-row editable Shuffle experiences the host **must**:

1. Compose [`BoValidationSummary`](../patterns/validation-summary.md) as a dedicated **Errors** section **below Actions** and **above** the Shuffle content after a failed Save/Commit when failures exist.
2. Map domain errors to `BoValidationIssue` (one issue per failing row/field — do not collapse distinct rows into one string).
3. Apply matching field chrome (`BoValidationContext` + `Validate()`, or per-field `ErrorText`).
4. Show the co-required Alert toast.
5. Wire navigate-to-error via `FocusRowAsync` / field-key focus helpers (`bo-grid.js`).

Adoption Matrix: **Required** for editable Shuffle hosts — see [validation-summary.md](../patterns/validation-summary.md#validation-summary-adoption-matrix).

## Supported scenarios

- Page section editable configuration lists with reorder (e.g. Application Configuration → Security Groups).
- Dialog-hosted editors that reuse the same control (e.g. Edit Data Entities) without dialog-specific APIs.
- Required / optional / read-only columns; custom Field/Display and RowActions templates.
- Host-owned Add via section `HeaderActions`.

## Unsupported scenarios (v1)

- Built-in Add / `ShowAdd` / `OnAdd`
- Dialog-specific chrome, footer actions, or scroll packs
- Column-click sorting, pagination, selection checkboxes, Nested hierarchy
- `BoGrid` InlineEdit Persist / spreadsheet paste
- Stacked-mobile label mode
- Embedding Dirty State dialogs inside the control

## Host scripts

Include Sortable + interop when the page uses Shuffle Card Grid:

| Script | Role |
| --- | --- |
| `_content/BreezeOn.UI/js/lib/sortable.min.js` | Vendored SortableJS (`window.Sortable`) |
| `_content/BreezeOn.UI/js/bo-sortable.js` | `boSortableInit` / `boSortableDestroy` / `boSortableReadOrder` |
| `_content/BreezeOn.UI/js/bo-grid.js` | Add New first-editable focus (`focusFirstEditableInShuffleRow`); Validation Summary navigate-to-error (`focusRowByKey` / field-key focus) — same script as `BoGrid` |

Gallery and product hosts that already load the standard `bo-*.js` set should also load Sortable + `bo-sortable.js` when adopting Shuffle Card Grid.
