<!-- Classification: AA; Scope: platform -->
# UI — Grid (`BoGrid`) + Grid Family

Owner: UI

Section-level data grid for `BreezeOn.UI`. Related: [forms.md](forms.md), [shuffle-card-grid.md](shuffle-card-grid.md), [sections.md](../layout/sections.md), [layout.md](../layout/layout.md), [shell.md](../shell/shell.md), [overview.md](../overview.md), [page-development.md](../page-development.md).

**Composition (hard standard):** `BoGrid` is a **section-level** surface (like Home hub). It is **not** a `BoRow` child and does **not** use Section → Row → Field for its own body. Optional `Title` wraps `BoSectionMain` / `BoSectionSub`. Cell editors reuse shipped `Bo*` fields — including [browser autocomplete off by default](forms.md#browser-autocomplete-locked) (do **not** put raw `<input>` in `Edit` templates).

**Library:** [SYSTEM-SHARED-UI](https://github.com/Breeze-On/SYSTEM-SHARED-UI) — `BoGrid<TItem>`, `BoGridColumn<TItem>`, `BoGridCache<TItem>`, `BoGridRow<TItem>`, `BoGridCellContext<TItem>`, `BoGridFamilyFilter`, enums `BoGridMode` / `BoGridDefaultExpansionState` / `BoGridColumnAlign` / `BoGridColumnWidth` / `BoGridSectionKind`. Internal helper `BoGridNesting` (not a public component). Host script: `_content/BreezeOn.UI/js/bo-grid.js` (overflow title on truncated display cells; Add New → first-editable focus).

## Grid Family Standards (locked)

**SSOT for Planning Agents and Dev Agents.** Applies to **all** Grid-family surfaces:

| Member | Doc |
| --- | --- |
| `BoGrid` (table) | this file |
| `BoShuffleCardGrid` (card + optional DnD) | [shuffle-card-grid.md](shuffle-card-grid.md) |
| Future Grid-family controls | must inherit these rules unless a STANDARDS exception is documented |

Control-specific APIs and chrome live in each control doc. **Do not** restate family rules as one-off product inventions.

### Reuse-first (org standard)

When an approved SHARED-UI / Grid-family pattern already exists:

1. **Reuse** before redesign.
2. **Extend** the existing control/API before replacing it.
3. **Deviations** require documented justification in STANDARDS (current reality + reason) — not silent product forks.
4. **Do not** introduce a new UX pattern when an approved equivalent already exists (e.g. inventing a second Add New placement/focus model).

Planning Agents: choose an existing Grid-family surface + host pattern first. Dev Agents: call shipped helpers (`Cache.Add(..., insertAtTop: true)`, `InsertNewAtTopAsync`, `bo-grid.js`) — do not recreate focus/sort/placement locally.

### Add New / uncommitted rows

| Rule | Standard |
| --- | --- |
| Top placement | Uncommitted new rows insert at the **top** and stay there until Save/commit (host may then reload / re-apply normal order) |
| Edit-ready | The new row is immediately editable (Row Edit enters edit; Inline Edit / Shuffle Card fields are live) |
| Auto-focus | After the row is fully rendered, focus moves to the **first editable** field — user types with no extra click |
| Focus preservation | Focus must **not** be lost or stolen during the Add New → paint → first-field sequence |
| Deferred validation | Add New / begin edit must **not** show mandatory error chrome; validation runs on Save/Commit only ([forms.md](forms.md) deferred mandatory) |
| Autocomplete | Cell editors use shipped `Bo*` fields — [browser autocomplete off by default](forms.md#browser-autocomplete-locked); no raw `<input>` in edit templates |
| Keyboard-first | Row creation and editing must be operable without relying on mouse-only steps for the happy path |

**Visibility (hard):** users must **never** lose sight of a row they are creating. Uncommitted new rows always remain visible (e.g. paginated `BoGrid` resets to the first page on Add New).

### Sorting vs uncommitted new rows (no conflict)

These rules resolve frozen sort, Add New at top, and uncommitted visibility:

| Concern | Standard |
| --- | --- |
| Precedence | **Uncommitted new rows take precedence over active sorting** for display position |
| Active sort | Must **not** reposition a new/uncommitted row during creation or while that row remains uncommitted |
| Frozen order | Existing rows keep frozen display order while editing; Add New inserts at the **top of that frozen order** without re-sorting peers |
| After commit | Host Save/`ReplaceAll` / `RefreshSortOrder()` / user header-sort may restore normal sort — only after the create workflow is committed or cancelled |
| Rebuild while `IsNew` | Header re-sort / `RefreshSortOrder` / cache `Reset` keeps all `IsNew` rows at the top, then sorts non-new peers |

Shuffle Card has no column-header sort; list order is host + DnD. Add New still uses **index 0** via `InsertNewAtTopAsync` until commit.

### Accessibility (Grid Family)

Lightweight consolidation — implementation details stay in control docs + [forms.md](forms.md) / [overlays.md](../shell/overlays.md):

| Expectation | Standard |
| --- | --- |
| Add New focus | Automatic focus on first editable field after paint (see Add New above) |
| Keyboard-only | Create / edit / save-cancel happy paths must work without mouse |
| Sortable headers | Enter / Space cycle Asc → Desc → Off; `aria-sort` reflects the active column; focus-visible ring on sortable headers |
| Focus preservation | Do not drop or misroute focus during row creation |
| Deferred validation | Required chrome after Save/Commit attempt only — not on Add New |
| Required indicators | Consistent header/column `*` rules per control; no invented second asterisk system |
| Disabled state | Disabled fields/rows are non-editable and skip mandatory participation per forms rules |
| Errors vs warnings | **Errors** block destructive/commit actions; **warnings** do not block unless a product standard explicitly says so |
| Validation Summary | Multi-row editable Save/Commit failures use [Validation Summary](../patterns/validation-summary.md) as a dedicated Errors section below the [Actions area](../patterns/actions-area.md) / above the grid (with field chrome + Alert toast + navigate-to-error; inline field messages suppressed via HighlightOnly). Adoption Matrix is Required for editable multi-row BoGrid / Shuffle hosts |

Control a11y extras (Nested View keys, Shuffle Card `role="list"`, icon `aria-label`) remain in each control section.

### Control entry points (do not fork)

| Surface | Add New path |
| --- | --- |
| `BoGrid` | Built-in toolbar / `NewItemFactory` → `Cache.Add(..., insertAtTop: true)` + `bo-grid.js` `focusFirstEditableInRow` |
| `BoShuffleCardGrid` | Host HeaderActions → **`InsertNewAtTopAsync(item)`** + `bo-grid.js` `focusFirstEditableInShuffleRow` |

## Responsibilities (locked)

| Layer | Owns |
| --- | --- |
| `BoGrid` | Render surface, modes, sort/pagination, section chrome optional, toolbar actions, validation adapter for grid `Required`, frozen display order |
| `BoGridColumn` | Column metadata + Display/Edit templates; registers with parent grid |
| `BoGridCache` | In-memory working set (`CacheId`); Add/Remove/Clear/ReplaceAll; `Changed` / `Reset` events |
| `BoGridRow` | `CacheRowId`, nullable `PrimaryKey`, `Item`, `IsNew` / `IsDirty` |
| Host page | Load/save persistence; assign `PrimaryKey` after save; `NewItemFactory`; `OnSave` / `OnRowDeleted` / `OnChanged` |

The library **never** talks to SQL or application repositories.

## Modes (locked — shipped)

| Mode | Enum | Behavior |
| --- | --- | --- |
| Read-Only | `BoGridMode.ReadOnly` | HTML table; Display templates only. Default. |
| Row Edit | `BoGridMode.RowEdit` | Add / edit / delete **one row at a time**; row Save / Cancel |
| Inline Edit | `BoGridMode.InlineEdit` | All rows editable; Delete per row; overall **Save** |
| Nested View | `BoGridMode.NestedView` | Read-only hierarchy (expand/collapse); **not** an editable mode |

**Architecture (hard):** Nested View is a **mode of `BoGrid`**, not a separate public component. Do **not** invent `BoNestedGrid` / `BoHierarchyGrid` / `BoTreeGrid`. All modes share layout, styling, theme, column sizing, a11y, docs, and core table rendering.

**Boundary — Shuffle Card Grid:** Editable **card rows** with a shared header row and drag-and-drop reorder are a **Grid-family** surface rendered by **`BoShuffleCardGrid`** — [shuffle-card-grid.md](shuffle-card-grid.md). Gallery exposes it as a **Grid Type**. It is **not** an HTML-table `BoGridMode` — do **not** bolt card/DnD rendering onto `BoGrid` table chrome.

## Cache / working model (locked)

| Type | Role |
| --- | --- |
| `BoGridCache<TItem>` | Working set; required `CacheId` (stable id for this grid instance) |
| `BoGridRow<TItem>` | One row: `CacheRowId` (Guid, always), `PrimaryKey` (null until host/DB assigns), `Item` (`TItem`), `IsNew` / `IsDirty` |

- **Typed entity:** `TItem` is the app DTO / entity shape (Gallery: `GridDemoItem`).
- **New rows:** `PrimaryKey = null`, `IsNew = true`; UI identity is always `CacheRowId`.
- **`Changed`:** raised on Add / Remove / NotifyChanged (and after Clear/ReplaceAll before `Reset`).
- **`Reset`:** raised after `Clear` / `ReplaceAll` so the grid can re-apply the active sort from current values.

## Parameters (`BoGrid<TItem>`)

> **Informative.** The complete, authoritative parameter list (every `[Parameter]`: name, type, default — including `QueryMode`, `TotalCount`, `SortFieldKey` / `SortDirection`, `FiltersVisible`, `ShowValidationSummary`, `ValidationIssues`, `SelectedNodeKeys`) is SHARED-UI [`public-component-api.md` § BoGrid](https://github.com/Breeze-On/SYSTEM-SHARED-UI/blob/main/docs/public-component-api.md#bogrid) and [§ BoGridColumn](https://github.com/Breeze-On/SYSTEM-SHARED-UI/blob/main/docs/public-component-api.md#bogridcolumn). The table below explains usage and may omit parameters ([parameter-reference.md](parameter-reference.md)).

| Parameter | Role |
| --- | --- |
| `Cache` | Required `BoGridCache<TItem>` |
| `Mode` | `ReadOnly` (default) / `RowEdit` / `InlineEdit` / `NestedView` |
| `Title`, `SectionKind`, `SectionKey`, `IconContent` | Optional section chrome; when Title/Icon set, wraps Main or Sub |
| `Required` | At least one row; section title asterisk when grid owns the section; registers with `BoValidationContext` |
| `FieldKey`, `ValidationGroup` | Submit ancestry for grid Mandatory |
| `IsPagination` | Default **false** (Nested View: pages **root** cache rows only) |
| `StartIndex` / `StartIndexChanged` | 0-based offset into the **filtered then sorted** working set (when paginating; Client mode) |
| `PaginationSize` / `PaginationSizeChanged` | Page size (default **5**). `PaginationSizeChanged` is part of the public bind surface (`@bind-PaginationSize`); raised when the grid **clamps** an invalid size (e.g. &lt; 1 → 1), not on every render |
| `ShowFiltersButton` | Default **false**. When true, shows Filters toolbar button that toggles the column filter row (ignored in NestedView) |
| `ColumnFilters` / `ColumnFiltersChanged` | Optional controlled filter terms keyed by `FieldKey` (primarily Server hosts → `BoQueryFilter` Contains) |
| `EnableHorizontalScroll` | Default **false**. When true, wide tables may scroll horizontally |
| `Columns` | Child `BoGridColumn<TItem>` definitions |
| `ChildRowsHaveDifferentColumns` | Nested View only. Default **false** (same columns / indented tree). **true** → expanded parents render `ChildGridTemplate` |
| `DefaultExpansionState` | Nested View only. `Collapsed` (default) or `Expanded` — seeds initial expand set; then per-node toggles own state |
| `NestedExpandedSeedKeys` | Nested View only. When non-null, reseeds from these node keys instead of `DefaultExpansionState` (path-minimal keyword expand) |
| `ChildrenSelector` | Nested View same-columns: `Func<TItem, IEnumerable<TItem>?>` recursive children |
| `NodeKey` | Nested View: stable string id for expand state (**required** when Mode is NestedView) |
| `ChildGridTemplate` | Nested View different-columns: `RenderFragment<TItem>` — host embeds another `BoGrid` (typically ReadOnly) |
| `ParentHasChildren` | Nested View different-columns: optional; default true when `ChildGridTemplate` is set |
| `NewItemFactory` | Creates `TItem` for Add New (editable modes) |
| `ShowAddNew` | Default **true** in editable modes (ignored in Nested View) |
| `ShowSave` | Default **true**. When **false**, InlineEdit hides the section-header Save button so the host can own Save/Discard outside the grid (e.g. the page [Actions area](../patterns/actions-area.md)). Does not remove per-row RowEdit Save. |
| `ShowDelete` | Default **true**. When **false**, hides the per-row Delete action. In Inline Edit, the actions column is omitted entirely when Delete is the only action. Use for value-maintenance grids that must not delete rows (e.g. EAC Variables values). |
| `ActionsPlacement` | `BoGrid`-only. `BoGridActionsPlacement`: **`Trailing`** (default — actions after data columns) or **`Leading`** (actions before data columns, after selection when enabled). Use Leading when Delete must stay visible without horizontal scroll (e.g. wide dynamic columns). Does **not** apply to `BoShuffleCardGrid` — Shuffle Card handle/icons are always leading ([shuffle-card-grid.md](shuffle-card-grid.md)). |
| `OnSave`, `OnRowDeleted`, `OnChanged` | Host callbacks |
| `EnableSelection` | Default **false**. When true (flat modes only; not Nested View), shows a compact **first** selection column |
| `SelectionMode` | `Multiple` (default) or `Single` |
| `SelectedCacheRowIds` / `SelectedCacheRowIdsChanged` | Two-way bind of selected `CacheRowId` values |
| `GetSelectedItems()` | Public method — typed items for currently selected cache rows |
| `Class`, `Style` | Optional host chrome on section or host wrapper |
| `RefreshSortOrder()` | Public method — rebuild frozen display order from current values |

### Row selection

- **Column UX:** first column; **no header text**; **no labels**; checkbox controls only; minimum practical width (`--bo-grid-selection-col-width`); header and row checkboxes centered; vertical alignment consistent with other cells.
- **Flat grids:** bind `SelectedCacheRowIds`; select-all (Multiple) = the **filtered working set** when column filters are active; otherwise all rows in `BoGridCache` (not the database). Select All checkbox remains on the **column-header** row.
- **Nested View (same columns):** `EnableSelection` is supported. Bind `SelectedNodeKeys` (`NodeKey` strings). Select-all walks the full tree from cache roots via `ChildrenSelector`. **Cascade (Multiple):** selecting a node expands and selects all descendants; deselecting clears the node, all descendants, **and all ancestors** (so a parent cannot stay selected after a descendant is cleared—avoids surprising delete/export roots). Different-columns Nested View does not show selection.
- Selection clears on cache `Clear` / `ReplaceAll` (`Reset`).
- `GetSelectedItems()` returns selected flat cache items or nested nodes matched by key.

### Column (`BoGridColumn<TItem>`)

| Parameter | Role |
| --- | --- |
| `Title` | Header label — **same chrome as `BoTextField` label** (10px / 700 / uppercase / `--bo-color-text-field-label`). **Action / icon columns (Hug row actions):** always empty — never show a header label (use `Title=""`). Icon buttons keep `title` / `aria-label` for accessibility. Built-in Row Edit / Inline Edit action chrome already uses an unlabeled header. |
| `FieldKey` | Stable column / property id |
| `Required` | Red asterisk on header; Edit cells should set `Required` on `Bo*` fields |
| `Align` | Cell **value** alignment only — Left (default) / Center / Right. **Headers always left.** Framework defaults: text & date **Left**; number & currency **Right** |
| `Width` | `BoGridColumnWidth`: default **Flex** = equal `100%/n` among Flex columns without `WidthPercent` (`table-layout: fixed` + `<colgroup>`; table always 100% of container). Action column (Row Edit / Inline Edit) is Hug via `--bo-grid-action-col-width` (default `4.75rem`; never `1px`). Do not use `calc()` on `<col>`. **Compact** ≈ `12%` when set |
| `WidthPercent` | Optional explicit percent of table width (e.g. `20`). When set on a Flex column, that column uses `width: N%` instead of equal Flex share. Compact/Hug ignore this and keep their fixed behavior |
| `SortValue` | Optional `Func<TItem, object?>`; when set, header is sortable |
| `FilterText` | Optional `Func<TItem, string?>`; when set (with `FieldKey`), column is filterable — return the **displayed** string |
| `Display` | Read-only / non-editing cell template (`BoGridCellContext<TItem>`) |
| `Edit` | Editable cell template (`BoTextField`, `BoDropDownList`, `BoDateField`, `BoNumberField`, …) |

Changing a column's `Title`, `FieldKey`, `Required`, `Align`, `Width`, or `WidthPercent` after first render re-renders the grid (`NotifyColumnsChanged`), so headers and layout stay in sync with dynamic column parameters.

### Cell context (`BoGridCellContext<TItem>`)

| Member | Role |
| --- | --- |
| `Row` / `Item` / `CacheRowId` / `PrimaryKey` | Row identity and DTO |
| `IsEditing` | Whether this row is in edit templates |
| `ValidationGroup` | Group for cell field validation (RowEdit uses per-row group; InlineEdit uses grid/cache group) |

## Visual / UX (locked)

- **Philosophy:** less table / more surface. Typography + whitespace + soft elevation over lines. Flush into the page (no outer card / container border). Eye path: **label → actions → headers → data**.
- **Header labels:** `BoTextField` label chrome; always **left-aligned**. **Exception — action/icon columns:** no header text (`Title=""`).

- **Header separator:** **primary-tinted** gradient under headers (soft edge fade, reduced opacity, 1px) — branded anchor, not a grey table border. Transparent header band (no fill).
- **Section rule:** standard section header rule **remains** when a section hosts a grid.
- **Column width:** `table-layout: fixed` + `<colgroup>`; Flex = `100%/n`; Compact ≈12%; action Hug = CSS `--bo-grid-action-col-width` (default `4.75rem`; never `1px` — that clips Edit/Delete). Flex `%` + rem action together fill the table; avoid `calc()` on `<col>`. Table **always 100%** of container.
- **Header actions:** when the grid owns a section and toolbar is shown: `Title [Add New] [Save] [Filters]` on one line (no dash; Filters only when `ShowFiltersButton`); buttons ~**16px** height, **equal width** (widest label / locale-safe); Add New = **primary** fill; Save / Filters = **secondary**; Filters is **rightmost** (variant hierarchy and ordering: [button.md](button.md); these are section `HeaderActions`, not the [Actions area](../patterns/actions-area.md)). Soft elevation. Extra header/body air only when the section has `HeaderActions` (`bo-section--with-header-actions`) — **not** on ancestor sections that merely nest a grid.
- **Column header row:** tight padding; labels sit close to the header divider.
- **Display overflow:** single-line ellipsis; hover `title` = full value when truncated (`bo-grid.js`); click expands that cell only (overlay); click elsewhere collapses. Edit cells are not truncated.
- **Row separators:** inset hairlines only — never enclose cells. No vertical column lines.
- **Depth:** soft row hover elevation; RowEdit active row = light surface **without** a left accent bar. Inline Edit has **no** per-row accent chrome. Tighter cell padding in edit modes.
- **Row icons:** neutral muted chrome (not primary/danger fills); soft hover lift. RowEdit: Edit/Delete idle; Checkmark Save + Dismiss Cancel while editing. InlineEdit: Delete only.
- **Pagination footer (one row):** record count **left**, page controls **centered**, balanced spacer right. Window of **max 5** page numbers. Hover = elevation/lift only; active page primary. Keyboard focus rings preserved.
- Empty body: localized **“No items available.”** (`Grid_Empty`).
- Grid `Required` fail (after attempt / Save): red helper above the table — **“At least one item is required.”** (`Grid_RequiredAtLeastOne`) + Alert toast on fail paths.

### Light / Dark

- Separators and header rule use theme tokens / `color-mix` with primary (both modes).
- Row hover uses tertiary wash (works in both palettes).
- Toolbar / pager / icon contrast follows `--bo-color-*` from the active theme mode.

## Sort (locked)

Header click (and Enter/Space on a focused sortable header) cycles **Ascending → Descending → Off**. Only **one** column may be actively sorted. Clicking a different sortable column clears the previous column and starts Ascending. Sort applies to the **full cache** (after filters when filtering is active), then pagination slices. **Client and Server** reset `StartIndex` to **0** when the active sort changes.

**Active column chrome:** the sorted header uses class `bo-grid__th--sorted` — **bolder** label (`font-weight: 900`) + direction arrow (`ArrowSortUp` / `ArrowSortDown`) at full opacity. Label and icon keep the normal header label color (no primary tint, no header background fill). No always-on arrows on unsorted columns. Idle sortable headers keep pointer + hover text darken only.

**Accessibility:** sortable headers are keyboard-focusable (`tabindex="0"`). The active sorted column sets `aria-sort` to `ascending` or `descending`; other sortable headers set `aria-sort="none"`. Sort icons are `aria-hidden`; focus-visible uses the shared `--bo-focus-ring` / primary outline.

**Persistence:** active sort state is **component-instance only** (survives while the grid remains mounted). No cookies, localStorage, or URL sync. The grid may retain **internal** last Asc/Desc field + direction after Off for the instance lifetime — not part of the public host contract; does not change Off / default-order semantics or visuals.

**Off / default order:** `BoGridSortDirection.None` clears the active field; Client drops frozen display order (cache/`Items` order); Server hosts apply their own default when `SortFieldKey` is null.

**Frozen while editing:** after a sort is applied, display order is frozen by `CacheRowId`. Editing a sort-key value in Row Edit or Inline Edit **must not** move rows. Re-evaluation only when:

1. The user activates a sortable column header (click / Enter / Space), or
2. The cache raises `Reset` (`Clear` / `ReplaceAll`), or
3. The host calls `RefreshSortOrder()`.

On rebuild, **`IsNew` rows stay pinned at the top**; only non-new rows are ordered by `SortValue`.

**Uncommitted new rows (family rule):** Add New while sorted inserts at the **top** of the frozen order without re-sorting other rows. Active sorts must **not** bury or reposition the row being created — including when the user re-sorts or the host refreshes sort while uncommitted rows exist. Full precedence rules: [Sorting vs uncommitted new rows](#sorting-vs-uncommitted-new-rows-no-conflict).

**Shuffle Card:** no column-header sort — list order is host + DnD only.

## Pagination (locked)

Default off (`IsPagination = false`). When on:

- Slice with `StartIndex` + `PaginationSize` after sort (after filters when filtering is active).
- Footer **one row:** **Showing {from}–{to} of {total}** (`Grid_Pagination_Showing`) left; first / previous / **windowed page numbers (max 5)** / next / last centered — **icons** preferred (Chevrons); no text labels on the buttons. The "Showing…" text is formatted with **`IBoLocaleService.FormatCulture`**. `BoGrid` subscribes to `Locale.Changed` and re-renders on language change (no page reload).
- Window examples: page 1 → `1 2 3 4 5`; page 5 → `3 4 5 6 7`; near end clamps correctly.
- Client total uses the **filtered** working set when column filters are active.

## Filtering (lightweight — locked)

Grid Family capability for administration, troubleshooting, data entry, and locating rows. Shared helper: `BoGridFamilyFilter` (contains + AND). Same mental model on [Shuffle Card](shuffle-card-grid.md).

| Rule | Standard |
| --- | --- |
| Opt-in button | `ShowFiltersButton` (default **false**). Gallery demos set **true**. NestedView ignores it (use host keyword + `BoNestedViewKeywordFilter`) |
| Toggle | Filters button shows/hides the filter row; hiding does **not** clear terms. State is **component-instance only** (no cookie / cross-navigation persistence) |
| Filter row | Second header row of `BoTextField` **below** the header separator line (Column headers → separator → filter row → data). **Every data column** gets a `BoTextField` (same size/spacing/alignment) — filterable columns are editable; columns without `FilterText` render **disabled** (standard disabled chrome) so the row has no visual holes. Placeholder **`Grid_Filter_Placeholder`** (`Search...`). Debounce **300** ms. `ShowClearButton` on filterable fields only. Compact vertical spacing (**4px** margin above/below each filter field). No Apply button. Toolbar order: **Add New \| Save \| Filters** (Filters rightmost) |
| Select All placement | Select All checkbox stays on the **column-header** row (selection column). Filter row uses an empty selection spacer only — filtering controls only |
| Column opt-in | `BoGridColumn.FilterText` (`Func<TItem, string?>`) — when set with a `FieldKey`, the column is filterable. Match against the **displayed** string the user sees |
| Match | Case-insensitive **contains** only; multiple active columns AND together. No operators, builders, regex, or saved filters |
| Pipeline (Client) | Data source → **Filters** → Sorting → Pagination → Display |
| Uncommitted / editing | `IsNew` rows always remain visible; Row Edit keeps the row being edited visible |
| Select All | When filters are active, Select All targets the **filtered working set**. The Select All checkbox is **always on the column-header row** (selection column) — never on the filter row, even while the filter row is visible (see *Select All placement* above) |
| Server `QueryMode` | Do **not** filter the current page client-side. Bind `ColumnFilters` / `ColumnFiltersChanged`; host maps to `BoQueryFilter` (`Contains`) on `BoQueryRequest` |
| Non-text columns | Omit `FilterText` for Number / Boolean / Date / DateTime / Action unless a compelling display-string reason exists — those columns still show a **disabled** filter `BoTextField`. People / DDL / Lookup / Badge / Metadata participate only when the host supplies resolved display text. Action / selection chrome columns stay empty (not data columns) |

## Row Edit (locked)

- Action column: Edit (pencil) / Delete (trash).
- While editing: **Save** (Checkmark) + **Cancel** (Dismiss) — Cancel restores snapshot; new unsaved row is removed; unlocks the row.
- While a row is editing: **Add New** and other rows’ Edit/Delete are **disabled**.
- **Add New** follows [Grid Family Standards](#grid-family-standards-locked) (top + focus + deferred validation; resets to first page when paginated).
- When the grid owns a section: **Add New** on the section header row.
- Column mandatory validation runs only on **row Save**; fail → Alert toast + field border chrome + [Validation Summary](../patterns/validation-summary.md) above the table when failures exist (navigate-to-error).

## Inline Edit (locked)

- All rows show Edit templates; Delete available per row (no single-row lock); **no** left accent bar.
- When the grid owns a section: **Add New** + overall **Save** on the section header row (Save omitted when `ShowSave=false`).
- Save validates required cell fields (ValidationGroup) + grid `Required`; fail → toast + borders + [Validation Summary](../patterns/validation-summary.md) above the table when failures exist; success → `OnSave`. Hosts that hide Save must run equivalent validation before their own Save path (including summary when the Adoption Matrix says Required).
- Sort order remains frozen while cells change (same rules as Sort + [Sorting vs uncommitted new rows](#sorting-vs-uncommitted-new-rows-no-conflict)).
- **Add New** follows [Grid Family Standards](#grid-family-standards-locked).

## BoGrid Add New implementation (locked)

Family rules: [Grid Family Standards](#grid-family-standards-locked). This table is **`BoGrid`-only** wiring (Shuffle Card: [shuffle-card-grid.md](shuffle-card-grid.md)).

| Rule | Behavior |
| --- | --- |
| When | **Add New only** (`ShowAddNew` + `NewItemFactory` in Row Edit / Inline Edit) — `Cache.Add(..., insertAtTop: true)` |
| When not | Existing-row **Edit**, Delete, Save/Cancel, sort, pagination, selection, Nested View, or host cache inserts that bypass Add New |
| Timing | After the new row is rendered (`bo-grid.js` `focusFirstEditableInRow`; short paint retry for Fluent upgrade) |
| Target | First focusable control in left-to-right `.bo-grid__cell--edit` order (prefer `[data-bo-field-key]`); skips disabled / read-only |
| Exception | No editable field → focus unchanged; Add New still succeeds |

Host script: `_content/BreezeOn.UI/js/bo-grid.js`. Do not re-implement per product page.

## Server QueryMode

**Client mode remains the default:** the host loads the full dataset into `BoGridCache`; sort and pagination apply to the **full cache** (see Sort / Pagination above).

**Server `QueryMode`** is for datasets too large (or too filter-driven) to cache fully. Retrieval standard: [query-driven-retrieval.md](query-driven-retrieval.md) · [ADR-008](../../../decisions/ADR-008-query-driven-data-retrieval.md). The library still **never** talks to SQL — the host owns the primary retrieval contract.

### Decision matrix (Planning Agents)

| Choose | When |
| --- | --- |
| **Client `QueryMode` (default)** | Dataset fits in memory; client sort/page is enough; small catalogs (e.g. Entity Types) |
| **Server `QueryMode`** | Large or highly filter-driven lists; need server Filter → Sort → Page + `TotalCount`; Nested View roots paged |
| **Full-load exception** | Hierarchy correctness needs the whole tree (path, cycles, cascade) — document under [query-driven-retrieval Exceptions](query-driven-retrieval.md#exceptions); apply Nested View keyword Rules **client-side** with `BoNestedViewKeywordFilter` |

Also consider: sorting requirements (server whitelist vs client), future growth (revisit Client preload when size grows), and select-all semantics (below).

| Concern | Standard |
| --- | --- |
| Cache content | Host fills `BoGridCache` with **only the current page** returned by the primary contract |
| `TotalCount` | Comes from the **primary contract** (rows matching the filter before pagination); drives the pagination footer total and page count. **Pager navigation** (`GoToPageAsync`) must also use `TotalCount` in Server mode — never `Cache.Count` (cache is only the current page). |
| Pipeline | Server applies **Filter → Sort → Pagination** (in that order); header sort and page changes raise a new host query instead of slicing the cache |
| Nested View | Server query pages **roots**; children come from the same primary contract; keyword child selection + search expansion follow [Nested View keyword filtering](#nested-view-keyword-filtering-org-standard) |
| Select-all | Selects the **current page only** (rows currently in `BoGridCache`). Under Server `QueryMode`, the cache is the current page — **not** every row matching the filter across all pages |
| Filters | Filter controls follow [forms.md — Filter execution](forms.md#filter-execution-query-driven); no Apply button |
| Stale responses | Host uses `BoLatestWinsQuery` (or equivalent); a stale response never calls `ReplaceAll` |

### Host-driven dynamic `PaginationSize` (optional)

When a Server-paged grid should fill available vertical space (larger monitors → more rows), the **host** owns `PaginationSize` — `BoGrid` has no AutoPageSize API.

| Rule | Guidance |
| --- | --- |
| Measure | Available workspace height minus stable chrome (section header, toolbar, table header, pager) |
| Apply | `floor(remaining / rowHeight)`, then **clamp** (product chooses bounds; EAC Values uses 5–40), then optionally reserve one row (EAC Values: `max(min, size - 1)` for footer breathing room) |
| When to recompute | First layout after the workspace becomes active, and **debounced** container/window resize |
| When not to recompute | Typing, dirty toggles, Add/Delete row, sort, or page navigation |
| StartIndex | If size changes, snap `StartIndex` down to a page boundary before re-querying |
| Overflow safety | Prefer fitting the page; residual overflow (e.g. many local Adds overlaid on the current page) belongs to a parent workspace scroll region — not page-level scroll |

Shipped example: EAC Data Entities Values (`eac-workspace-page-size.js` + host `_pageSize`). Do not invent a Shared UI control until a second product needs the same helper.

## Extension points (host)

- Column `Display` / `Edit` templates (compose existing `Bo*` fields).
- `NewItemFactory`, `OnSave`, `OnRowDeleted`, `OnChanged`.
- `RefreshSortOrder()` after host-side data refresh that does not use `ReplaceAll`.
- Optional `EnableHorizontalScroll` for many-column pages.
- Optional explicit `Width` / `Align` per column.

Do **not** subclass `BoGrid` for product behavior; extend via parameters and templates.

## Nested View (locked — shipped)

Read-only hierarchical mode on the same `BoGrid` surface. No action column; no Add/Save. Unlimited nesting depth. Independent expand/collapse per node.

### Scenarios

1. **Same columns** (`ChildRowsHaveDifferentColumns = false`): one table, one header; children indented in the **first** data column with chevron + hierarchy guide rails (`.bo-grid--nested`). Children from `ChildrenSelector`.
2. **Different columns** (`ChildRowsHaveDifferentColumns = true`): parent headers stay; expanded parent inserts a colspan continuation row with `ChildGridTemplate` (host embeds another `BoGrid`, typically ReadOnly). No card wrapper. Parent `EnableSelection` uses flat `SelectedCacheRowIds` (no cascade into child grids).

`PreserveNestedExpansionOnCacheReset`: when true, Nested View expand/collapse survives cache `ReplaceAll` / Clear (stale keys pruned). Default false reseeds from `DefaultExpansionState` (or from `NestedExpandedSeedKeys` when that parameter is non-null).

### DefaultExpansionState

| Value | Initial render | Typical use |
| --- | --- | --- |
| `Collapsed` (default) | All expandable nodes collapsed | Org charts, category / process trees |
| `Expanded` | All expandable nodes expanded | Permission matrices, small nav / reference trees |

After seed, per-node toggles own the expansion set. Cache `Reset` / `ReplaceAll` re-seeds (unless preserve is on).

**`NestedExpandedSeedKeys`:** when non-null, Nested View reseeds from this explicit key set (pruned to nodes present in the tree) instead of `DefaultExpansionState`. Use for **path-minimal keyword expansion** (Rule 3). Null restores enum-based seeding. Empty collection = all collapsed under an explicit override.

### Nested View keyword filtering (org standard)

**Planning Agent default** for Nested View datasets that support a free-text **keyword** filter. Document a product exception only when justified (see [query-driven-retrieval.md — Exceptions](query-driven-retrieval.md#exceptions)).

This standard governs **result selection** and **search visibility**. It does not change Nested View scenarios (same-columns vs different-columns) or require a new grid component.

#### Ownership

| Concern | Owner |
| --- | --- |
| Which parents / children appear in the result | **Host retrieval contract** (typically SQL / SP) — service remains pass-through. When an [approved full-load exception](query-driven-retrieval.md#exceptions) keeps the whole tree in memory, the **host page** applies the same Rules 1–2 **client-side** over the loaded tree (do not force a paged SP solely for keyword). |
| Auto-expand while keyword is active; restore browse expansion when cleared | **Host page** — path-minimal expand keys via `NestedExpandedSeedKeys` (preferred for deep same-column trees) or, for shallow one-level Nested Views, `DefaultExpansionState = Expanded`; always `PreserveNestedExpansionOnCacheReset = false` while keyword is active. **Not** `PreserveLayoutWhenHidden` (that is a `BoRow` field-layout flag — [layout.md](../layout/layout.md)) |
| Client full-load Rules 1–3 | Prefer shared helper **`BoNestedViewKeywordFilter`** (`BreezeOn.UI.Grid`) — host supplies key / children / match / clone delegates |
| `BoGrid` / NestedView infrastructure | Seed/preserve mechanics + optional `NestedExpandedSeedKeys`; no keyword-matching logic inside `BoGrid` |

#### Rule 1 — Parent match

When the keyword matches the **parent** row (parent identity / description / metadata fields owned by that root):

- Return the parent.
- Return **all** child context for that parent (full enablement / child set — do not prune siblings).
- Host page expands using **Rule 3** (matching node + required ancestors only). Descendants included solely because of Rule 1 stay **collapsed** until the user expands them.

#### Rule 2 — Child match

When the keyword matches one or more **children** (and the parent is included because of those matches):

- Return the parent.
- Return **matching child branches only**.
- Hide non-matching sibling branches.
- Host page expands using **Rule 3** so matching paths are visible immediately.

If both parent fields and child fields match the same keyword, **Rule 1 wins** (full child context).

#### Rule 3 — Search visibility (path-minimal expansion)

While a keyword filter is **active**:

- Matching results must be immediately visible — users must **never** need to manually expand to discover a match.
- Expansion is **path-minimal**:
  - **Expand** = ancestors required to make each matching **row** visible (including intermediate nodes that themselves match when they sit above a deeper match).
  - **Do not expand** the match row itself solely because it matches — that would dump non-matching children preserved by Rule 1 (e.g. cost centres under a matching subdivision).
  - **Do not expand** non-matching descendants.
- Host typically binds `NestedExpandedSeedKeys` to that expand set and `PreserveNestedExpansionOnCacheReset = false` so each keyword-driven `ReplaceAll` reseeds from the keys.
- `DefaultExpansionState = Expanded` remains acceptable only for **shallow** Nested Views where “expand all returned parents” equals path-minimal (e.g. one-level parent/child such as EAC Applications). Do **not** use blanket `Expanded` on deep same-column hierarchy trees.

When the keyword is **cleared**:

- Clear `NestedExpandedSeedKeys` (null) and restore the normal browse experience (page default — commonly `Collapsed` + `PreserveNestedExpansionOnCacheReset = true`).

#### Reference implementation

- EAC **Applications** NestedView (`P_GET_EACApplicationsGrid` RS1/RS2 + `Applications.razor` expansion binding) — server primary contract owns Rules 1–2; shallow one-level shape may use `DefaultExpansionState = Expanded` for Rule 3 — [architecture/applications/eac.md](../../../architecture/applications/eac.md).
- EAC **Business Entities → Business Hierarchy** NestedView — approved full-load exception; page uses **`BoNestedViewKeywordFilter`** + `NestedExpandedSeedKeys` (ancestors of matches only) — [architecture/applications/eac.md](../../../architecture/applications/eac.md#business-entities).
- Gallery Components → Other → **Grid** — Server QueryMode + Filters (`BoLatestWinsQuery`) and Nested View keyword demo ([example-governance.md](../example-governance.md)).

### Keyboard (expand control focused)

| Key | Action |
| --- | --- |
| Left Arrow | Collapse (handled in `keydown`) |
| Right Arrow | Expand (handled in `keydown`) |
| Enter / Space | Toggle via the native **button click** only — not handled in `keydown`, so a key press toggles exactly once (no double-toggle) |

`aria-expanded` on the toggle; leaf rows have no control (spacer only).

### Sort / pagination

- Sort and pagination apply to **root** `Cache` rows only.
- Child order = `ChildrenSelector` / host template data order.
- Expanded children of visible roots still render when paginating.

### Visual

- Light theme-aware rails (low opacity); chevron rotates ~90° when expanded (~180ms; honor `prefers-reduced-motion`).
- Full-width Flex sizing unchanged; Nested View has no Hug action column.

### Recommended use cases

Organizational structures, business capabilities, menus, permissions, categories, process hierarchies, folder structures.

### Cleanup readiness (why Nested View stays inside BoGrid)

| Piece | Responsibility |
| --- | --- |
| `BoGrid` NestedView path | Mode gate, parameters, table shell, columns, root sort/pagination, expand UI + keyboard, templates |
| `BoGridNesting` (internal) | Pure tree logic: has-children, flatten visible, seed/prune expanded keys |
| Private render methods | `RenderNestedDataRow`, `RenderDisplayCell`, `RenderActionsCell`, `RenderEmptyRow` — internal only, **not** public components |
| CSS | `--bo-grid-action-col-width` SSOT for Hug/action col; `.bo-grid--nested` for hierarchy chrome |

**Maintainability notes (current):** Investigation/`data-bo-grid-*` debug attributes removed. Action `<col>` width comes from CSS class + variable (no duplicated hard-coded rem in markup).

Future extract candidates (do **not** extract in product apps): split `BoGrid.razor` into partial class files (`BoGrid.Nested.cs`, sort/pager) if the file grows further — still **not** a public grid type.

## Gallery

Components (`/components`) → header tab **Other** → left panel-navigation item **Grid** (`Key=grid`; **not** a top-level header tab). Index: [gallery-index.md](../gallery-index.md). Parameters: Mode (includes Nested View), and when Nested View — **Do Child Rows Have Different Columns?** + **Default Expansion State**. Editable demos: Sub **Grid Control** with 4 sample rows (Text / Drop-Down / Date / Number) and **`ShowFiltersButton=true`** (text + DDL supply `FilterText`; Date / Number show disabled filter fields). Nested same-columns: Michael Jackson International Holdings tree (≥3 divisions; one branch ≥6 levels). Nested different-columns: 4 departments, each expands to an employee `BoGrid` (2 rows). Server demo binds `ColumnFilters` → `BoQueryFilter` Contains. Shuffle Card demo enables Filters with reorder disabled while filtered. Host loads `bo-grid.js`.

## Documentation governance

Update this file (including **Grid Family Standards**) + [shuffle-card-grid.md](shuffle-card-grid.md) when family rules change + [overview.md](../overview.md) + [page-development.md](../page-development.md) + thin product README / README_AI / AGENTS in the **same change set**. Current reality only. Do not duplicate family rules in product pages — link here.
