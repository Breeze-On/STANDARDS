<!-- Classification: AA; Scope: platform -->
# UI — Workspace panels (`BoPanelHost` / `BoPanel` / `BoPanelNavigation`)

Owner: UI

Reusable workspace layout and navigator-only section navigation for large multi-section configuration experiences. Related: [shell.md](../shell/shell.md) (header tabs), [layout.md](layout.md), [forms.md](../controls/forms.md) (validation), [page-development.md](../page-development.md).

Implementation: [SYSTEM-SHARED-UI](https://github.com/Breeze-On/SYSTEM-SHARED-UI) (`BreezeOn.UI`). Complete parameter lists: [`public-component-api.md`](https://github.com/Breeze-On/SYSTEM-SHARED-UI/blob/main/docs/public-component-api.md) ([BoPanelNavigation](https://github.com/Breeze-On/SYSTEM-SHARED-UI/blob/main/docs/public-component-api.md#bopanelnavigation), [BoPanel](https://github.com/Breeze-On/SYSTEM-SHARED-UI/blob/main/docs/public-component-api.md#bopanel), [BoKeepAlivePanels](https://github.com/Breeze-On/SYSTEM-SHARED-UI/blob/main/docs/public-component-api.md#bokeepalivepanels)); tables below are informative. Choosing between Tabs / Toggle / Panel Navigation, selection authority, and keyboard contract: [selection-and-navigation.md](../controls/selection-and-navigation.md). "Actions" is defined in [actions-area.md](../patterns/actions-area.md).

## Strategic purpose (design target)

This is BreezeOn’s primary **workspace-navigation** pattern — not a gallery-only feature.

**Primary design targets:**

- Application Configuration (EAC and future apps)
- Customer Onboarding experiences
- Future administrative workspaces
- Large multi-section configuration experiences

The Gallery Components Library **Other** tab (Grid, Page Freeze, Dialog, Toggle, …) is a **demonstration and validation vehicle only**.

**Optimize for:**

| Concern | Implication |
| --- | --- |
| 10–30 navigation items | Vertical card list; ellipsis labels; scroll inside left panel |
| Large forms | Independent panel scrolling; Section→Row→Field inside Fill |
| Validation across hidden sections | Keep-alive regions; `Validate(null)`; fail badges on every nav group |
| Long-lived form state | Never unmount inactive sections |
| Future deep linking | Stable bindable `SelectedItem` string keys |
| Future panel collapse | Reserved `IsCollapsible` / `IsCollapsed` on `BoPanel` |
| Future workspace layouts | Host/panel not coupled to `BoAppBody`; Left/Fill/Right (Top/Bottom later) |

## Relationship to `BoTabs`

`BoTabs` and `BoPanelNavigation` solve **different problems**. Do not treat them as interchangeable skins.

| | `BoTabs` / `BoTabPanels` | `BoPanelNavigation` + `BoKeepAlivePanels` |
| --- | --- | --- |
| Problem | Header-oriented **page segmentation** | **Workspace navigation** inside body layout |
| Ownership | Navigation **and** content pairing | **Navigator-only**; app owns content composition |
| Placement | `BoAppHeader.TabsContent` + body panels | Typically left `BoPanel` + Fill content |
| Scale | Small set of page sections | 10–30 workspace / config sections |
| Visual | Compact header pills | Vertical cards (Home card language + selected state) |

**When to use `BoTabs`:** Components-style page sections; Error Message scenarios; short page-level mode switches.

**When to use `BoPanelNavigation`:** App Config; onboarding/admin workspaces; long-lived multi-section forms.

Shared **contracts** (not a duplicated Tabs product API): `BoValidationContext` groups, `BoValidationFailBadge`, keep-alive/hide (not unmount), bindable selected key.

## `BoPanelHost` + `BoPanel`

Generic independently scrolling regions. **Not** owned by `BoAppBody` — reusable in sections and custom layouts.

```razor
<BoPanelHost>
  <BoPanel Dock="BoPanelDock.Left">…</BoPanel>
  <BoPanel Dock="BoPanelDock.Fill">…</BoPanel>
  <BoPanel Dock="BoPanelDock.Right" Width="15%">…</BoPanel>
</BoPanelHost>
```

| Parameter | Component | Notes |
| --- | --- | --- |
| `Dock` | `BoPanel` | `Left` / `Right` / `Fill` (`BoPanelDock`). Top/Bottom reserved for future additive enum values |
| `Width` | `BoPanel` | Default `15%`; Left/Right only (override when needed — short nav labels favor the default) |
| `MinWidth` | `BoPanel` | Default `10rem`; Left/Right only |
| `IsCollapsible` / `IsCollapsed` | `BoPanel` | **Reserved** — no collapse chrome in current release; CSS modifiers ready |
| `ChildContent` | both | Panel / host body |
| `Class` / `Style` | both | Escape hatches |

**Scrolling:** each panel scrolls in `.bo-panel__scroll`. Host does not scroll. When a **visible** host is under `BoAppBody`, body scroll is suppressed (same exception class as Home hub). Hosts inside **hidden** keep-alive tab panels must not disable body scroll for other tabs.

**Separation:** host gap uses `--bo-panel-host-gap` (default `--bo-space-lg` / 1.5rem). A subtle vertical divider (1px `--bo-color-card-container-border`, **80%** of panel height, vertically centered) is structural chrome on the Left dock (`::after`) — it sits in the gap and does **not** scroll with either panel’s content. The panel **shell** uses `overflow: visible` so that divider can paint into the gap; clipping/scroll remain on `.bo-panel__scroll`. On stacked layouts (`max-width: 48rem`) the same rule becomes a centered horizontal divider under Left.

**Responsive:** below `48rem`, host stacks column (Left → Fill → Right); side panels use `max-height: 40vh`.

### Pinned chrome inside Fill (EAC reference composition)

> **EAC reference composition** — a product composition, not a SHARED-UI API. The platform concept of the Actions area is defined in [actions-area.md](../patterns/actions-area.md).

When Fill content needs a stable [Actions area](../patterns/actions-area.md) / toolbar row **and** a scrollable body (so Save/Discard never leave the viewport while grids grow), compose a **product flex column** inside the Fill panel — do **not** add fill/scroll APIs to `BoSectionMain` / `BoSectionSub`.

```text
.bo-panel__scroll
  └─ fill column (height: 100%; overflow: hidden; flex column)
       ├─ pinned chrome (flex: 0 0 auto) — e.g. Actions BoSectionSub
       └─ workspace scroll (flex: 1; min-height: 0; overflow: auto) — Values/Settings grids
```

**Rules:**

| Concern | Ownership |
| --- | --- |
| Viewport / footer | `BoAppShell` (unchanged) |
| Panel height slot | `BoPanelHost` / `.bo-panel__scroll` |
| Anchored Actions | Non-scrolling sibling above the workspace scroll region |
| Workspace overflow | Inner product scroll container only |
| Section chrome | `BoSectionSub` remains grouping only |

**EAC reference:** App Configuration → Data Entities Fill (`.eac-data-entities-fill` / `.eac-data-entities-workspace-scroll`). Reuse this composition for future App Configuration workspaces; promote to SHARED-UI only when a second product needs the same helper.

## `BoPanelNavigation` (navigator only)

```razor
<BoPanelNavigation Items="_items" @bind-SelectedItem="_key" />
```

| Parameter | Notes |
| --- | --- |
| `Items` | `IEnumerable<BoPanelNavigationItem>` (`Key`, `Label`, optional `IconContent`) |
| `SelectedItem` / `SelectedItemChanged` | Bindable key; defaults to first item; deep-link-ready |
| `Class` / `Style` | Escape hatches |

Does **not** render section content. Item DOM ids: `bo-panel-nav-{key}`.

**Visual:** compact administrative cards (not landing-page density); subtle hover; selected uses tertiary fill + thin inset accent bar (~2px; primary in light, semantic white in dark — not left-nav `--bo-color-nav-selected`); single-line label ellipsis (~13px). Prefer hosting inside `BoSectionMain` (or `BoSectionSub` when the Fill peer is also Sub, e.g. EAC App Config Steps workspace) with title **Navigation**, icon Fluent **ArrowSplit** Regular rotated −90° via `bo-icon--rotate-90` so forks point right.

**A11y:** `role="tablist"` + `aria-orientation="vertical"`; items `role="tab"`; Arrow Up/Down / Home/End; `:focus-visible` primary outline. Full keyboard / ARIA contract: [selection-and-navigation.md](../controls/selection-and-navigation.md#panel-navigation-bopanelnavigation).

**Selection authority:** `SelectedItem` / `SelectedItemChanged` only — no intent (`*Requested`) callback is shipped, so guarded hosts use the interim pattern in [selection-and-navigation.md § Shipped authority per control](../controls/selection-and-navigation.md#shipped-authority-per-control-current).

**Validation:** `Key` ≡ field `ValidationGroup`. After Submit (`Validate(null)`), failed groups show `BoValidationFailBadge` in the left icon slot (same contract as header tabs).

## Keep-alive content — `BoKeepAlivePanels` / `BoKeepAlivePanel`

Layout primitive (not a second Tabs framework; not owned by Navigation).

```razor
<BoKeepAlivePanels SelectedKey="_key">
  <BoKeepAlivePanel Key="general" AriaLabelledBy="bo-panel-nav-general">…</BoKeepAlivePanel>
  <BoKeepAlivePanel Key="permissions" AriaLabelledBy="bo-panel-nav-permissions">…</BoKeepAlivePanel>
</BoKeepAlivePanels>
```

Inactive panels stay mounted (`hidden` / `--inactive`). **Hard rule:** do **not** use `@if (SelectedItem == …)` for validated or long-lived workspace sections — unmounting drops fields from `BoValidationContext` and loses form state.

**Why not `BoPanelNavigationPanels`?** Keep-alive cannot be internal to navigator-only navigation without taking content ownership. Navigation-named public panels would duplicate Tabs concepts. A generic Layout primitive keeps the public API lean and preserves validation/state.

**Why not reuse `BoTabPanels`?** Header-tab ARIA ids (`bo-tab-*`) and product semantics differ. Workspace pages compose navigator + keep-alive explicitly.

## Design rationale (for agents)

1. Generic host/panel — reusable outside `BoAppBody`.
2. Navigator-only — apps own content composition for App Config–scale forms.
3. Keep-alive Layout primitive — validation + long-lived state without a second Tabs API.
4. Collapse params reserved — avoid breaking changes when collapse ships.
5. Gallery Other is demo-only — do not under-scope the pattern to gallery chrome.

## Gallery

SYSTEM-SHARED-UI Components Library → header tab **Other** → left `BoPanelNavigation` (Grid, Page Freeze, Dialog, Toggle, Import Summary, Validation Summary, Button) + Fill `BoKeepAlivePanels`. Index: [gallery-index.md](../gallery-index.md).
