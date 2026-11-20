# UI — Motion

Owner: UI

Platform motion language for BreezeOn shared UI. Current reality only. Implementation: [SYSTEM-SHARED-UI](https://github.com/Breeze-On/SYSTEM-SHARED-UI) (`breezeon-ui.css`, control JS). Related: [tokens.md](tokens.md), [toggle.md](../controls/toggle.md), [shuffle-card-grid.md](../controls/shuffle-card-grid.md), [overview.md](../overview.md).

## Philosophy (locked)

- Prefer **CSS transitions** and existing engine FLIP (e.g. SortableJS) over new animation libraries.
- Motion should feel **premium and responsive** (Toggle-quality), never laggy or flashy.
- Honor **`prefers-reduced-motion: reduce`** — instant state change; no lift / FLIP / settle.
- Control SSOTs keep surface-specific rules and **cite** this document for shared reorder motion. Do not invent per-control duration dialects.

## Reorder motion (locked)

First consumer: `BoShuffleCardGrid` (SortableJS via `bo-sortable.js`). Future reorderable controls reuse the same tokens and behavior.

| Phase | Behavior |
| --- | --- |
| **While dragging** | Live sibling **FLIP** cascade as items vacate / fill slots (primary premium signal) |
| **After drop** | Drag chrome clears; shadow settle via CSS. Sortable FLIP for swaps already ran during drag |
| **Remount sync** | Host list mutates on drop; remount / engine re-init may follow immediately (FLIP is during-drag, already cleared by `onEnd`) |

### Tokens

Defined on `.bo-theme-root` in `breezeon-ui.css`:

| CSS variable | Value | Role |
| --- | --- | --- |
| `--bo-reorder-flip-duration` | `260ms` | Sibling FLIP duration (Sortable `animation`) |
| `--bo-reorder-flip-easing` | `cubic-bezier(0.2, 0.8, 0.2, 1)` | FLIP easing (aligned with Toggle thumb) |
| `--bo-reorder-settle-duration` | `220ms` | Drag chrome shadow settle |

JS / C# mirror the FLIP duration in milliseconds (**260**; **0** when reduced-motion) for the Sortable engine. Do **not** put a CSS `transition` on `transform` for reorderable rows — it fights Sortable’s FLIP (siblings jump instead of slide). Remount delay after drop is unnecessary when FLIP completes during drag.

### Reduced motion

- Sortable (or equivalent) `animation: 0`.
- CSS: no row lift / settle transitions.

### Anti-patterns (locked)

- Enabling Sortable **`forceFallback`** for chrome (paints ghost on source; washed flash).
- Transitioning **ghost opacity / background**.
- CSS **`transition` on `transform`** for reorderable items (fights Sortable FLIP → jumps, not slides).
- Applying a competing CSS **`transform`** (e.g. scale) on the dragged item while Sortable owns `transform`.
- Per-control forks of `--bo-reorder-*` durations/easing.
- Remounting / destroying the reorder engine **during** an in-progress FLIP swap.

### Identity and sync

- Stable item keys (`data-key` + framework `@key`) before any animated reorder.
- Host list mutation and order callbacks fire immediately on drop; remount may follow once drag-time FLIP has finished (typically already cleared at `onEnd`).
- Membership change (add/remove) may re-init the engine; **order-only** changes must not destroy the engine mid-drag.

## Related control motion (reference)

| Control | Duration / easing | Notes |
| --- | --- | --- |
| `BoToggle` thumb | `240ms` / `cubic-bezier(0.2, 0.8, 0.2, 1)` | Measured geometry; host-authoritative selection — [toggle.md](../controls/toggle.md) |
| Disclosure / expandable | ~0.24s height + opacity | [expandable-section.md](../layout/expandable-section.md) |
| Toast in/out | ~200–220ms | [overlays.md](../shell/overlays.md) |

Reorder motion intentionally shares the Toggle easing family so premium interactions feel like one platform.
