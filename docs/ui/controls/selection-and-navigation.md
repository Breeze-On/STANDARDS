<!-- Classification: AA; Scope: platform -->
# UI — Selection and navigation controls

Owner: UI

One contract for every control that expresses "**selected**": Tabs, Toggle, Panel Navigation, left navigation, Drop-Down List, and Grid row selection. Defines **which control to choose**, **who owns the selected state**, and **keyboard / ARIA expectations**. Related: [toggle.md](toggle.md), [shell.md § Header tabs](../shell/shell.md#header-tabs-optional-page-sections), [panels.md](../layout/panels.md), [navigation.md](../shell/navigation.md), [grids.md](grids.md), [forms.md](forms.md), [dirty-state.md](../patterns/dirty-state.md), [motion.md](../foundations/motion.md), [accessibility.md](../foundations/accessibility.md), [normative-tiers.md](../foundations/normative-tiers.md).

API (parameters, events, types): [`public-component-api.md`](https://github.com/Breeze-On/SYSTEM-SHARED-UI/blob/main/docs/public-component-api.md) — [BoTabs](https://github.com/Breeze-On/SYSTEM-SHARED-UI/blob/main/docs/public-component-api.md#botabs) · [BoToggle](https://github.com/Breeze-On/SYSTEM-SHARED-UI/blob/main/docs/public-component-api.md#botoggle) · [BoPanelNavigation](https://github.com/Breeze-On/SYSTEM-SHARED-UI/blob/main/docs/public-component-api.md#bopanelnavigation).

Current reality only.

## Decision matrix (Tier 1 for the control categories; Tier 3 for count thresholds)

Answer in order; stop at the first match.

1. **Is it an application route** (changes URL / page)? → **Left navigation** (`BoNavPane` / `BoNavLink`) — [navigation.md](../shell/navigation.md). Not a selection control for page content.
2. **Is the selected thing a data value** that is saved on the record (a Code, a status, a type)? → **Drop-Down List** (or Checkbox for boolean) — [forms.md](forms.md). Do **not** use Tabs / Toggle / Panel Navigation to capture field values.
3. **Is it a mode or view of the same data** (e.g. Values / Settings; Grid / Chart) with 2–4 compact options, and the host does not need per-option validation badges? → **Toggle**.
4. **Is it a set of page sections** with their own content, short enough to sit in the header? → **Tabs** (header).
5. **Is it a large workspace / configuration** with many sections that stay validated and long-lived? → **Panel Navigation** + keep-alive panels.

| | `BoToggle` | `BoTabs` + `BoTabPanels` | `BoPanelNavigation` + `BoKeepAlivePanels` | `BoDropDownList` |
| --- | --- | --- | --- | --- |
| Question it answers | "Which **mode / view**?" | "Which **page section**?" | "Which **workspace section**?" | "Which **value**?" |
| Owns content? | No (presentation only) | Yes (pairs tab + panel) | No (navigator only; app composes content) | No |
| Persisted as record data? | No | No | No | **Yes** (bound property) |
| Options (guidance) | 2–4 (minimum **2** is enforced by the API; renders nothing below 2) | ~2–7 | 8–30 (typical 10–30) | Any; searchable; Top-N `ItemsProvider` for large catalogs |
| Placement | Inline / toolbar / section body | Header under title row (or section body) | Left `BoPanel` dock of a `BoPanelHost` | Form field inside `BoRow` |
| Validation fail badges | No | Yes (`ValidationGroup` = `TabKey`) | Yes (`ValidationGroup` = item `Key`) | Field-level chrome |
| Inactive content | n/a | Mounted, hidden (keep-alive) | Mounted, hidden (keep-alive) | n/a |
| Authority model | Controlled; intent event | Intent event + commit event | Commit event only (see below) | Value binding |
| Do not use for | Navigation between pages or sections | 8+ sections; field values | Short page segmentation | Mutually exclusive **view** switching |

Thresholds in the "Options" row are **Tier 3 guidance** (readability), except the Toggle minimum of 2 which is an API contract. If a Toggle would need 5+ options, or Tabs would need horizontal scroll, re-evaluate against the matrix (usually Tabs → Panel Navigation, Toggle → Tabs or Drop-Down).

Do not mix: do not nest header Tabs inside a Panel Navigation workspace to express the same hierarchy, and do not use Toggle as a Tabs substitute because it is more compact ([toggle.md](toggle.md): "not a Tab control and not a navigation control").

## Selection Authority Model (Tier 1 — LOCKED)

1. **The host owns the selected state.** Controls display the host-provided selection; they do not decide business outcomes.
2. **Prefer intent-based selection (`*Requested`) over change-then-revert.** The control raises *what the user wants* **before** any change is committed. The host may allow or veto. The control shows no optimistic selected state — the indicator moves only after the selection is committed ([motion.md § Selection travel](../foundations/motion.md#selection-travel-locked)).
3. **Change-then-revert is not permitted** for any surface that must be guarded (Dirty State, unsaved edits, permission). Guarding inside a "changed" callback is fragile (re-render resets, flicker, double-notification).
4. **Guarded abandon points call Dirty State from the intent event** — see [dirty-state.md](../patterns/dirty-state.md).
5. Name intent callbacks **`<Thing>Requested`** (`ToggleRequested`, `TabRequested`). New selection controls follow this naming.

### Shipped authority per control (current)

| Control | Intent (before commit) | After commit | How a host blocks a change |
| --- | --- | --- | --- |
| `BoToggle` | `ToggleRequested` (`EventCallback<string>`) | none — host assigns `SelectedToggleKey` | Do not update `SelectedToggleKey` |
| `BoTabs` | `TabRequested` (`BoTabRequestedEventArgs`: `FromTab`, `ToTab`, `Source` Click/Keyboard) | `SelectedTabChanged` | Set `args.Cancel = true` (async handler allowed); nothing changes and `SelectedTabChanged` does not fire |
| `BoPanelNavigation` | **Not shipped** | `SelectedItemChanged` | Interim only: guard in `SelectedItemChanged`, re-assert the previous `SelectedItem` from the host if blocked (change-then-revert). An intent callback for Panel Navigation is **Future Validation (FV-008)**; hosts must keep guard logic in one method so it can move to the intent event unchanged |
| `BoGrid` selection | none | `SelectedCacheRowIdsChanged` / `SelectedNodeKeysChanged` | n/a — selection is not an abandon point |
| `BoDropDownList` | none | `ValueChanged` | n/a — value, not navigation |

Not raised for the automatic default-first-tab selection or host-driven `SelectedTab` assignments (`TabRequested`).

## Keyboard and ARIA (Tier 1)

Baseline: [accessibility.md](../foundations/accessibility.md).

### Tabs (`BoTabs`)

| Concern | Standard |
| --- | --- |
| Roles | `role="tablist"` (`aria-orientation="horizontal"`) → `role="tab"` → `role="tabpanel"` |
| Name | Optional `AriaLabel` on `BoTabs` for the tablist; tabs expose their visible label |
| State | `aria-selected` on every tab |
| Association | Tab `aria-controls` → panel id `bo-tab-panel-{TabKey}`; panel `aria-labelledby` → tab id `bo-tab-{TabKey}` (`RenderAriaControls` default true; set false only when no panels exist) |
| Focus | Roving `tabindex`: only the selected tab (first tab if none) is in the Tab order |
| Keys | **Left / Right** move to previous / next (wraps); **Home / End** first / last. Selection follows focus (automatic activation) and goes through `TabRequested` with `Source = Keyboard`; if vetoed, focus stays |
| Inactive panels | Stay mounted; `hidden` |

### Toggle (`BoToggle`)

| Concern | Standard |
| --- | --- |
| Roles | `role="radiogroup"` → items `role="radio"` with `aria-checked`; icon `aria-hidden` |
| Focus | Group is one Tab stop; items `tabindex="-1"` |
| Keys | **Left / Right** (and Up / Down) previous / next with wrap; **Home / End** first / last. Each key raises `ToggleRequested` for the target (host decides) |
| Already selected | Activating the selected item is a no-op (no event) |

### Panel Navigation (`BoPanelNavigation`)

| Concern | Standard |
| --- | --- |
| Roles | `role="tablist"` + `aria-orientation="vertical"`; items `role="tab"`, `aria-selected`, id `bo-panel-nav-{key}` |
| Focus | Roving `tabindex` (selected item = 0) |
| Keys | **Up / Down** previous / next (clamped, no wrap); **Home / End** first / last; selection follows focus |
| Panels | `BoKeepAlivePanel` `AriaLabelledBy` = `bo-panel-nav-{key}` |

### Left navigation

Landmark / collapse accessibility is defined in [navigation.md](../shell/navigation.md#collapsed-nav-tooltips-and-accessibility-current). Links use standard link semantics (not tabs).

## Grid selection (brief)

Full rules: [grids.md § Row selection](grids.md#row-selection).

| Concern | Standard |
| --- | --- |
| Opt-in | `EnableSelection`; `SelectionMode` Single / Multiple |
| Bind | Flat: `SelectedCacheRowIds`; Nested View (same columns): `SelectedNodeKeys` |
| Select All | Checkbox on the **column-header row** (selection column). Scope = the **filtered working set** when column filters are active; otherwise all rows in `BoGridCache` (flat) or the nested tree; **Server** `QueryMode` = current page only. Not on the filter row |
| Visual | The checkbox column is the selection indicator; no separate selected-row fill is specified (recorded gap, not a rule) |
| Not an abandon point | Selecting rows does not run Dirty State |

## Drop-Down List selection (brief)

Full rules: [forms.md § Drop-Down List](forms.md#drop-down-list-bodropdownlist).

- `@bind-Value` = Code (`string?`), or `;`-joined Codes when `AllowMultiple`.
- Closed value truncates with ellipsis + hover title; selected values must not resize the control ([ux-conventions.md](../patterns/ux-conventions.md#control-width-and-truncation-locked)).
- Use for **record values**, not for switching views or sections.

## Left navigation vs Tabs vs Panel Navigation (do not conflate)

| | Left nav | Tabs | Panel Navigation |
| --- | --- | --- | --- |
| Changes URL | Yes | No | No |
| Scope | Application | One page | One workspace |
| Chrome | Platform-fixed ([navigation.md](../shell/navigation.md)) | Header tab strip | Vertical card list |
| Selected visual | Filled row, black bold | Traveling indicator | Tertiary fill + inset accent bar |

Selected-state visuals intentionally differ per control; they are not a shared interaction language.

## Gallery

Toggle: Components → Other → Toggle. Tabs: Components header tabs (no dedicated demo). Panel Navigation: Components → Other (left nav of the Other tab). Grid selection: Components → Other → Grid. See [gallery-index.md](../gallery-index.md).
