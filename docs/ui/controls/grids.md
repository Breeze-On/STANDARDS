# UI — Grid (`BoGrid`)

Owner: UI

Section-level data grid for `BreezeOn.UI`. Related: [forms.md](forms.md), [sections.md](../layout/sections.md), [layout.md](../layout/layout.md), [shell.md](../shell/shell.md), [overview.md](../overview.md).

**Composition (hard standard):** `BoGrid` is a **section-level** surface (like Home hub). It is **not** a `BoRow` child and does **not** use Section → Row → Field for its own body. Optional `Title` wraps `BoSectionMain` / `BoSectionSub`. Cell editors reuse shipped `Bo*` fields.

**Library:** [SYSTEM-SHARED-UI](https://github.com/Breeze-On/SYSTEM-SHARED-UI) — `BoGrid<TItem>`, `BoGridColumn<TItem>`, `BoGridCache<TItem>`, `BoGridRow<TItem>`, `BoGridCellContext<TItem>`, enums `BoGridMode` / `BoGridDefaultExpansionState` / `BoGridColumnAlign` / `BoGridColumnWidth` / `BoGridSectionKind`. Internal helper `BoGridNesting` (not a public component). Host script: `_content/BreezeOn.UI/js/bo-grid.js` (overflow title on truncated display cells).

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

| Parameter | Role |
| --- | --- |
| `Cache` | Required `BoGridCache<TItem>` |
| `Mode` | `ReadOnly` (default) / `RowEdit` / `InlineEdit` / `NestedView` |
| `Title`, `SectionKind`, `SectionKey`, `IconContent` | Optional section chrome; when Title/Icon set, wraps Main or Sub |
| `Required` | At least one row; section title asterisk when grid owns the section; registers with `BoValidationContext` |
| `FieldKey`, `ValidationGroup` | Submit ancestry for grid Mandatory |
| `IsPagination` | Default **false** (Nested View: pages **root** cache rows only) |
| `StartIndex` / `StartIndexChanged` | 0-based offset into the **sorted full cache** (when paginating) |
| `PaginationSize` / `PaginationSizeChanged` | Page size (default **5**). `PaginationSizeChanged` is part of the public bind surface (`@bind-PaginationSize`); raised when the grid **clamps** an invalid size (e.g. &lt; 1 → 1), not on every render |
| `EnableHorizontalScroll` | Default **false**. When true, wide tables may scroll horizontally |
| `Columns` | Child `BoGridColumn<TItem>` definitions |
| `ChildRowsHaveDifferentColumns` | Nested View only. Default **false** (same columns / indented tree). **true** → expanded parents render `ChildGridTemplate` |
| `DefaultExpansionState` | Nested View only. `Collapsed` (default) or `Expanded` — seeds initial expand set; then per-node toggles own state |
| `ChildrenSelector` | Nested View same-columns: `Func<TItem, IEnumerable<TItem>?>` recursive children |
| `NodeKey` | Nested View: stable string id for expand state (**required** when Mode is NestedView) |
| `ChildGridTemplate` | Nested View different-columns: `RenderFragment<TItem>` — host embeds another `BoGrid` (typically ReadOnly) |
| `ParentHasChildren` | Nested View different-columns: optional; default true when `ChildGridTemplate` is set |
| `NewItemFactory` | Creates `TItem` for Add New (editable modes) |
| `ShowAddNew` | Default **true** in editable modes (ignored in Nested View) |
| `OnSave`, `OnRowDeleted`, `OnChanged` | Host callbacks |
| `Class`, `Style` | Optional host chrome on section or host wrapper |
| `RefreshSortOrder()` | Public method — rebuild frozen display order from current values |

### Column (`BoGridColumn<TItem>`)

| Parameter | Role |
| --- | --- |
| `Title` | Header label — **same chrome as `BoTextField` label** (10px / 700 / uppercase / `--bo-color-text-field-label`) |
| `FieldKey` | Stable column / property id |
| `Required` | Red asterisk on header; Edit cells should set `Required` on `Bo*` fields |
| `Align` | Cell **value** alignment only — Left (default) / Center / Right. **Headers always left.** Framework defaults: text & date **Left**; number & currency **Right** |
| `Width` | `BoGridColumnWidth`: default **Flex** = equal `100%/n` (`table-layout: fixed` + `<colgroup>`; table always 100% of container). Action column (Row Edit / Inline Edit) is Hug via `--bo-grid-action-col-width` (default `4.75rem`; never `1px`). Do not use `calc()` on `<col>`. **Compact** ≈ `12%` when set |
| `SortValue` | Optional `Func<TItem, object?>`; when set, header is sortable |
| `Display` | Read-only / non-editing cell template (`BoGridCellContext<TItem>`) |
| `Edit` | Editable cell template (`BoTextField`, `BoDropDownList`, `BoDateField`, `BoNumberField`, …) |

### Cell context (`BoGridCellContext<TItem>`)

| Member | Role |
| --- | --- |
| `Row` / `Item` / `CacheRowId` / `PrimaryKey` | Row identity and DTO |
| `IsEditing` | Whether this row is in edit templates |
| `ValidationGroup` | Group for cell field validation (RowEdit uses per-row group; InlineEdit uses grid/cache group) |

## Visual / UX (locked)

- **Philosophy:** less table / more surface. Typography + whitespace + soft elevation over lines. Flush into the page (no outer card / container border). Eye path: **label → actions → headers → data**.
- **Header labels:** `BoTextField` label chrome; always **left-aligned**.
- **Header separator:** **primary-tinted** gradient under headers (soft edge fade, reduced opacity, 1px) — branded anchor, not a grey table border. Transparent header band (no fill).
- **Section rule:** standard section header rule **remains** when a section hosts a grid.
- **Column width:** `table-layout: fixed` + `<colgroup>`; Flex = `100%/n`; Compact ≈12%; action Hug = CSS `--bo-grid-action-col-width` (default `4.75rem`; never `1px` — that clips Edit/Delete). Flex `%` + rem action together fill the table; avoid `calc()` on `<col>`. Table **always 100%** of container.
- **Header actions:** when the grid owns a section and toolbar is shown: `Title [Add New] [Save]` on one line (no dash); buttons ~**16px** height, **equal width** (widest label / locale-safe); Add New = **primary** fill; Save = **tertiary** fill; soft elevation. Extra header/body air only when the section has `HeaderActions` (`bo-section--with-header-actions`) — **not** on ancestor sections that merely nest a grid.
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

Header click cycles **Ascending → Descending → Off**. Sort applies to the **full cache**, then pagination slices. Sorted column shows a subtle arrow beside the header.

**Frozen while editing:** after a sort is applied, display order is frozen by `CacheRowId`. Editing a sort-key value in Row Edit or Inline Edit **must not** move rows. Re-evaluation only when:

1. The user clicks a sortable column header, or
2. The cache raises `Reset` (`Clear` / `ReplaceAll`), or
3. The host calls `RefreshSortOrder()`.

Add New while sorted inserts at the **top** of the frozen order without re-sorting other rows.

## Pagination (locked)

Default off (`IsPagination = false`). When on:

- Slice with `StartIndex` + `PaginationSize` after sort.
- Footer **one row:** **Showing {from}–{to} of {total}** (`Grid_Pagination_Showing`) left; first / previous / **windowed page numbers (max 5)** / next / last centered — **icons** preferred (Chevrons); no text labels on the buttons.
- Window examples: page 1 → `1 2 3 4 5`; page 5 → `3 4 5 6 7`; near end clamps correctly.

## Row Edit (locked)

- Action column: Edit (pencil) / Delete (trash).
- While editing: **Save** (Checkmark) + **Cancel** (Dismiss) — Cancel restores snapshot; new unsaved row is removed; unlocks the row.
- While a row is editing: **Add New** and other rows’ Edit/Delete are **disabled**.
- **Add New** inserts at the **top** (resets to first page when paginated).
- When the grid owns a section: **Add New** on the section header row.
- **Add New / begin edit** must **not** show mandatory error chrome; column mandatory validation runs only on **row Save**; fail → Alert toast + field border chrome.

## Inline Edit (locked)

- All rows show Edit templates; Delete available per row (no single-row lock); **no** left accent bar.
- When the grid owns a section: **Add New** + overall **Save** on the section header row.
- Save validates required cell fields (ValidationGroup) + grid `Required`; fail → toast + borders; success → `OnSave`.
- Sort order remains frozen while cells change (same rules as Sort).

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
2. **Different columns** (`ChildRowsHaveDifferentColumns = true`): parent headers stay; expanded parent inserts a colspan continuation row with `ChildGridTemplate` (host embeds another `BoGrid`, typically ReadOnly). No card wrapper.

### DefaultExpansionState

| Value | Initial render | Typical use |
| --- | --- | --- |
| `Collapsed` (default) | All expandable nodes collapsed | Org charts, category / process trees |
| `Expanded` | All expandable nodes expanded | Permission matrices, small nav / reference trees |

After seed, per-node toggles own the expansion set. Cache `Reset` / `ReplaceAll` re-seeds.

### Keyboard (expand control focused)

| Key | Action |
| --- | --- |
| Left Arrow | Collapse |
| Right Arrow | Expand |
| Enter / Space | Toggle |

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

Components → **Grid** tab (`TabKey=grid`, `Table` icon). Parameters: Mode (includes Nested View), and when Nested View — **Do Child Rows Have Different Columns?** + **Default Expansion State**. Editable demos: Sub **Grid Control** with 4 sample rows (Text / Drop-Down / Date / Number). Nested same-columns: Michael Jackson International Holdings tree (≥3 divisions; one branch ≥6 levels). Nested different-columns: 4 departments, each expands to an employee `BoGrid` (2 rows). Host loads `bo-grid.js`.

## Documentation governance

Update this file + [overview.md](../overview.md) + [page-development.md](../page-development.md) + thin product README / README_AI / AGENTS when `BoGrid` behavior or parameters change (same change set as code). Current reality only.
