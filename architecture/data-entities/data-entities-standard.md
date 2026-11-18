# Data Entities standard

Owner: Architecture

Authoritative business and platform rules for BreezeOn **Data Entities** — the configurable master-data framework owned by EAC.

## Purpose

Data Entities are BreezeOn’s standard framework for configurable reference / master data and lookup values (for example Regions, Cost Centers, Statuses). Future applications should consume Data Entities through EAC before inventing per-application lookup tables.

## What Qualifies as a Data Entity?

Use this section to decide **Data Entities vs custom tables**.

Data Entities are intended for **configurable reference / master data and lookup values** maintained by administrators — **not** transactional business data.

### Recommended (use Data Entities)

- Regions
- Departments
- Cost Centers
- WBS
- Countries
- Cities
- Statuses
- Other administrator-maintained reference / master data

### Not recommended (use application-owned transactional tables)

- Invoices
- Timesheets
- Purchase Orders
- Transactions
- Business Events
- High-volume operational records

Prefer Data Entities over custom lookups such as `InvoiceRegions` or `TimesheetDepartments`. When in doubt: if the data is a shared lookup/master list configured in EAC and reused in business processes, it belongs here; if it is an operational document or event stream, it does not.

## Ownership

| Concern | Owner |
| --- | --- |
| Definitions, columns, rows, translations, metadata | EAC |
| CRUD, validation, stored procedures, business rules | EAC |
| Standards and documentation | EAC + STANDARDS (this tree) |
| Consumer apps | Read / filter / search / display / use in processes only |

Consumer applications must **not** create or modify Data Entities, columns, or rows (including translations and metadata) outside EAC.

## Scope

- Data Entity **definitions** belong to an **Application** (`ApplicationGUID`). Application = codebase.
- Every Application Context (`ApplicationEnabledGUID`) inherits the same definitions.
- **Rows** (and translations / metadata) belong to an Application Context.
- There is no schema versioning per enablement.

See [ADR-016](../../decisions/ADR-016-data-entity-ownership.md).

## Naming standards

### Data Entity and Column `Code`

- Lowercase
- Kebab-case
- Plural for Data Entity codes (e.g. `regions`, `cost-centers`, `invoice-statuses`)
- Distinct from Business Entity codes (often uppercase elsewhere in EAC)

Do **not** create custom columns named `code`, `description`, or `sort-order`. Those are first-class row fields, not Data Entity Columns.

### Column types (database)

Allowed: `TEXT`, `DECIMAL`, `BOOLEAN`, `DATE`, `DATETIME`.

Do not introduce database types for DDL, Person, People Picker, or Entity Reference — those are frontend concepts.

Column **Type** is immutable once created.

### DECIMAL precision (`Decimals`)

When `Type = DECIMAL`, `Decimals` is required (integer **0–10**, default **2** on create). Non-DECIMAL columns store `Decimals = NULL`. `Decimals` may be updated after create; Values UI formats/edits using the current scale.

## Navigation display

Data Entity navigation items must display:

1. **Description** (preferred) when non-empty after trim
2. **Code** only when Description is null, empty, or whitespace

Use one shared helper in product UI; do not invent alternate label rules per screen. Order navigation by Data Entity `SortOrder`.

## SortOrder ownership and reordering

- `SortOrder` on Data Entity definitions is owned by EAC.
- On **create**, the server assigns `SortOrder = MAX(existing) + 1` for that Application.
- On **Change Order**, the UI submits the authoritative visual order; `System.P_POST_EACDataEntitiesReorder` rewrites SortOrder as **1..N** (top card = 1) in a single transaction.
- On **Edit Data Entities**, SortOrder is rewritten the same way as part of `System.P_POST_EACDataEntitiesSave` from the working-grid order (together with Code/Description updates and staged deletes).
- The Change Order payload must be a **complete permutation** of every Data Entity GUID for the Application (no partial lists). Edit Save accounts for remaining rows + staged deletes covering every definition exactly once.
- Reordering requires the same authorization as create: Global System Administrator or Application object administrator.
- Navigation does not support inline drag-reorder; order changes via the Change Order dialog or the Edit Data Entities dialog.

### Change Order dialog display

| Rule | Detail |
| --- | --- |
| Title | Dialog title **Change Order** only — no duplicate body heading/hint above the list |
| Card content | Drag handle + **Description only** (`DataEntityNavLabel`: Description preferred, Code fallback when Description empty). Do not show Code as a secondary line, SortOrder, or other metadata |
| Density | Compact-professional card padding (denser than showcase cards; still comfortable) so more entities are visible while scanning |
| Motion | On drop, the moved card **glides** into place and neighbors **visibly shift** (~280–320ms, ease-out / Fluent-style easing). Avoid instant teleport. Honor `prefers-reduced-motion` (animation off / minimal) |
| Drag affordance | Entire card surface is draggable; `ReOrderDotsVertical` remains a visual affordance only (not the sole hit target). Whole-page drag outside the list is not allowed |

## Quick Actions (App Configuration)

Quick Actions are **commands**, not navigation. They must still **feel** part of the App Configuration left-rail nav ecosystem.

### Behavior

| Rule | Detail |
| --- | --- |
| Component | Collapsible `BoSectionSub` + EAC-local action list (**not** `BoPanelNavigation`) with leading icons |
| Actions | New Data Entity (`Add`), Edit Data Entities (`Edit`), Change Order (`ReOrderDotsVertical`) — order in the rail: New → Edit → Change Order |
| Enablement | New: manage grant. Edit and Change Order: manage grant **and** Data Entity count **≥ 1** (disabled when none exist; first entity is created via New) |
| Overlap rationale | Edit supports drag-and-drop reordering **and** Code/Description/delete. Change Order remains a **focused reorder-only** workflow (Description-only cards) for users who do not need definition edits. Both stay intentionally. |
| Auth | Unauthorized users see actions **disabled** (not hidden); server still enforces write gates |
| Smart default expand | Data Entity count **== 0** → Quick Actions defaults **Expanded**; count **> 0** → defaults **Collapsed**. Apply only when establishing the initial expansion for a loaded Application context (page load / `ApplicationGUID` change) |
| In-session persistence | Expanding/collapsing, then opening New, Edit, or Change Order (and closing the dialog), **must not** reset expand state. Do not re-run smart-default after create/edit/reorder list refresh. Reset to smart default only on page navigation/reload or Application context change |

### Visual standards (command cards)

| Concern | Standard |
| --- | --- |
| Layout | Full-width rows; left-aligned icon + label; gap/rhythm aligned with `BoPanelNavigation` items |
| Typography | Same font size / weight / line-height as `.bo-panel-nav-item` labels |
| Shape | Less-rounded corners (`--bo-radius-md`) — like Import JSON / secondary action cards, **not** pill-shaped |
| Chrome | Subtle border (`--bo-color-card-container-border`) + light outer shadow / elevation (`--bo-shadow-card-container`) |
| Interaction | Hover and `:focus-visible` consistent with BreezeOn panel-nav / field standards |
| Section spacing | Vertical space between Quick Actions and Navigation `BoSectionSub`s uses standard section spacing tokens (e.g. `--bo-space-md` / 16px stacked-section rhythm); do not invent one-off px gaps |

Keep `BoPanelNavigation` for the Data Entity **Navigation** list only.

## Platform rules

| Rule | Detail |
| --- | --- |
| Sparse metadata | If a custom column value is NULL, **do not** create a metadata row. Absence equals NULL. |
| `ValueRichText` | Reserved; unused. `TEXT` values use `ValueText` only. |
| One typed value | Metadata rows populate exactly one typed value column matching Column.Type. |
| Row identity | `DataEntityRowGUID` is immutable system identity; `Code` is editable business value. |
| Row Code uniqueness | Unique within a Data Entity for that Application Context. |
| Column deletion | **Always allowed.** Removes the column definition and **all** associated `EACDataEntitiesRowsMetadata` (Settings Save and Application Configuration synchronize share this rule). |
| Data Entity deletion | Allowed only when **no rows** exist; otherwise blocked. Application Configuration synchronize may remove definitions when safe ([ADR-017](../../decisions/ADR-017-application-configuration-deployment.md)). |

## Performance principles

- Index for Application + SortOrder (definitions), ApplicationEnabled + DataEntity + SortOrder (rows), and metadata/translation by row.
- Avoid unnecessary table growth; never insert null metadata rows.
- Design must remain viable for large catalogs (e.g. Cities ~200k rows).

## Usage expectations

- Prefer Data Entities for shared lookups before custom tables ([What Qualifies](#what-qualifies-as-a-data-entity)).
- Consumers: [using-data-entities.md](using-data-entities.md).
- Technical shape: [data-entities-architecture.md](data-entities-architecture.md).

## Values & Settings workspaces (shipped)

App Configuration → Data Entities right panel (when a Data Entity is selected):

| Surface | Role |
| --- | --- |
| Actions | Equal-weight `BoRow` slots: Save · Discard · empties · `BoToggle` (Values / Settings; toggle slot weight 2). Save/Discard use dedicated semantic action tokens (`--bo-color-save-button-*` / `--bo-color-discard-button-*`) — not Primary/Secondary. Dirty State is **outside** BoToggle ([dirty-state.md](../../docs/ui/patterns/dirty-state.md), [toggle.md](../../docs/ui/controls/toggle.md), [tokens.md](../../docs/ui/foundations/tokens.md)). **Anchored:** Actions stay visible while Values/Settings scroll (Fill composition: pinned Actions + workspace scroll region — see [panels.md](../../docs/ui/layout/panels.md#pinned-chrome-inside-fill)). |
| Values | Rows for the selected Application Context. **Server QueryMode** browsing + **local Changeset** editing. Save submits Added/Modified/Deleted only. Discard clears the Changeset and reloads the current page. Column order: Delete (leading) → Code → Description → dynamic columns → Sort Order. New row `SortOrder = max + 1` (or 1). Description uses current `IBoLocaleService.FormatCulture.Name` (`en-CA` / `fr-CA`) — no language picker. **Page size** is host-owned and viewport-derived (clamp 5–40, then −1 row for footer breathing room; recompute on layout/resize only — not on edit/Add). Local Adds that exceed the fitted page stay in the workspace scroll until Save; paging does not change for unpersisted rows. |
| Settings | Column definitions for the Data Entity (Application-scoped). Client working copy. Delete Column requires confirm before working-copy delete; Save cascades metadata remove. Type immutable once created; DECIMAL has editable `Decimals` (0–10). Codes auto `extraN`. Delete is the leading grid actions column. Long lists scroll inside the workspace region (Actions remain pinned). |

**Layout ownership (Fill panel):** App Configuration footer stays shell-owned. Data Entities Fill uses a product flex column (`.eac-data-entities-fill`): Actions `BoSectionSub` is non-scrolling chrome; `.eac-data-entities-workspace-scroll` owns vertical overflow for Values/Settings. Do not put Actions inside the workspace scrollport. Do not extend `BoSectionSub` for fill/scroll.

Save applies **only** to the active toggle workspace. Entity deletion when rows exist remains blocked. Column deletion always cascades metadata (Settings Save and Import synchronize).

### Edit Data Entities dialog (shipped)

Quick Action **Edit Data Entities** opens a deferred working-copy dialog:

| Rule | Detail |
| --- | --- |
| Scope | Existing definitions only — no Add row; create remains **New Data Entity** |
| Columns | GUID (read-only), Code (editable, auto-lowercase), Description (editable, required on Update), drag handle, delete |
| Local until Update | Code/Description edits, DnD reorder, and trash staging stay in-memory; Cancel/Escape/close with dirty state prompts Continue Editing / Discard Changes |
| Validation | On Update only; consolidated summary prefers `Data Entity "{code}": …`, falls back to `Row N: …` when Code is blank |
| Persist | `System.P_POST_EACDataEntitiesSave` — GUID-keyed updates, SortOrder 1..N from grid order, staged deletes; delete blocked while Values rows exist |
| Code rename | `DataEntityGUID` stays the FK identity (columns/rows unchanged). Code is the editable business / portable key — App Config sync/seed still match by Code, so deployment JSON must be updated deliberately after a rename |

## Future scope (documented only)

Not shipped yet: multi-language translation editor UI, auditing extensions, soft delete. Definition edit/delete via Edit Data Entities **is shipped**. Definition SortOrder drag-reorder via Change Order **is shipped**. Application Configuration deployment import/export for definitions + columns **is shipped** (synchronize-by-Code; see [app-configuration deployment](../app-configuration/application-configuration-deployment.md)). Values row CRUD + Settings column CRUD **are shipped** (see above).
