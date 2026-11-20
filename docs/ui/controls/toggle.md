# UI — Toggle (`BoToggle`)

Owner: UI

Presentation-only segmented toggle for mutually exclusive options. Related: [forms.md](forms.md), [motion.md](../foundations/motion.md) (selection travel + easing family shared with reorder), [overview.md](../overview.md), [dirty-state.md](../patterns/dirty-state.md).

**Library:** [SYSTEM-SHARED-UI](https://github.com/Breeze-On/SYSTEM-SHARED-UI) — `BoToggle`, `BoToggleItem` (`BreezeOn.UI.Inputs`). Gallery: Components → Other → Toggle.

## Philosophy (locked)

`BoToggle` is a **pure UI component**.

| Does | Does not |
| --- | --- |
| Render options (required icon + label) | Know about Dirty State |
| Display host-provided `SelectedToggleKey` | Evaluate navigation / abandon rules |
| Raise **user intent** via `ToggleRequested` | Evaluate Save/Discard |
| Support keyboard Left/Right/Home/End | Commit selection internally |
| | Make business decisions |

This is **not** a Tab control and **not** a navigation control. Exactly one item is active as displayed by the host.

## API (locked)

| Parameter | Role |
| --- | --- |
| `Items` | `IReadOnlyList<BoToggleItem>` — **minimum 2**, unlimited maximum |
| `SelectedToggleKey` | Host-owned display of the active key (controlled; never mutated by BoToggle) |
| `ToggleRequested` | `EventCallback<string>` — intent when the user chooses a **different** key |
| `FieldKey`, `Class`, `Style` | Optional a11y / chrome |

### `BoToggleItem`

| Member | Role |
| --- | --- |
| `Key` | Stable id compared to `SelectedToggleKey` (ordinal ignore-case) |
| `Label` | Visible label (host-localized) |
| `IconContent` | **Required** leading icon (`BoIcon`) |

## Interaction

```text
User chooses Settings
  → BoToggle raises ToggleRequested("settings")
  → Host may run Dirty State / other guards
  → If allowed: host sets SelectedToggleKey = "settings"
  → If blocked: host leaves SelectedToggleKey unchanged
```

Gallery demos assign `SelectedToggleKey` directly in the handler. Product hosts with unsaved work **must** gate through Dirty State outside BoToggle.

Clicking the already-selected item is a no-op (no event).

## Visual

- Outer card container (border + elevation tokens)
- **Sliding selection pill** (`.bo-toggle__thumb`): primary fill + subtle elevation; geometry follows the host-owned selected item via shared **selection travel** (`bo-sliding-selection.js` / `boSlidingSelection` called directly from `BoToggle`). No optimistic movement on click — pill moves only after `SelectedToggleKey` updates. Duration / easing: shared `--bo-selection-travel-*` tokens (**240ms** / `cubic-bezier(0.2, 0.8, 0.2, 1)`); `--bo-toggle-thumb-duration` / `--bo-toggle-thumb-easing` are aliases — [motion.md](../foundations/motion.md)
- Selected label/icon: white foreground (`--bo-color-semantic-white`) for contrast on the pill; unselected hover/focus unchanged
- Icon + label vertically centered via flex (`align-items: center`); empty icon slot collapses
- Full-width friendly: equal flex segments
- Honor `prefers-reduced-motion` (pill relocates instantly)

## Host script

Hosts that render `BoToggle` (or `BoTabs`) must load `_content/BreezeOn.UI/js/bo-sliding-selection.js` (see [page-development.md](../page-development.md) § Host integration). Without it, selected segments fall back to a static primary fill (no slide). Do **not** load a separate `bo-toggle.js`.

## Intended use

- Workspace mode switches (e.g. Values / Settings)
- Compact exclusive choices where Tabs would over-communicate navigation

Do **not** use for multi-page navigation (use `BoTabs` / `BoPanelNavigation`).
