<!-- Classification: AA; Scope: platform; Domain: UI; Capability: Patterns -->
# UI — Dirty State (unsaved changes)

Owner: UI / Architecture

Centralized abandon-guard for working copies. Related: [toggle.md](../controls/toggle.md), [selection-and-navigation.md](../controls/selection-and-navigation.md), [actions-area.md](actions-area.md), [button.md](../controls/button.md), [grids.md](../controls/grids.md), [shuffle-card-grid.md](../controls/shuffle-card-grid.md), Data Entities architecture.

## Status — platform concept, EAC reference implementation

| Aspect | Status |
| --- | --- |
| **Concept and flow** (one guard, one `IsDirty`, Save / Discard / Cancel, abandon points call the same gate) | **Platform** standard — the Philosophy and Flow sections below |
| **Implementation** | **EAC reference only**: `EacDirtyStateGuard`, the Dirty State dialog, and `EacSaveDiscardActions` live in SYSTEM-ADMIN-EAC. **There is no Dirty State service or `IBo*Dirty*` type in SHARED-UI.** A new application builds its own equivalent from this concept |
| What is platform today | The **flow / dialog contract** (Save | Discard | Cancel behavior, failure = stay) and the intent hooks on controls (`ToggleRequested`, `TabRequested`) |
| Promotion to a SHARED-UI service | **Future Validation (FV-001)** — only after application #2 validates the need and the shape |
| Validation (`Future Validation`) at app #2 | Confirm: guard lifetime, multi-dirty workspaces, Panel Navigation intent hook (FV-008), whether the Actions area becomes a shared component |

Sections below titled "EAC" describe the reference implementation, not a platform API.

## Philosophy (locked)

Any action that would abandon the active working copy must resolve Dirty State first — **one** framework, not per-feature rules.

| Does | Does not |
| --- | --- |
| Track a single `IsDirty` for the active workspace | Live inside presentation controls (`BoToggle`, etc.) |
| Present Unsaved Changes: Save / Discard / Cancel | Invent separate rules for tab vs toggle vs import |
| Let future abandon points call the same gate | Couple Save/Discard to BoToggle |

## EAC reference implementation (not a platform API)

- Service: `EacDirtyStateGuard` (scoped) — **EAC reference**
- Dialog: Compact `BoDialog` — Save | Discard | Cancel (platform dialog shell; EAC composition)
- [Actions area](actions-area.md) chrome: `EacSaveDiscardActions` (Save Primary + Discard Secondary; independent of `BoToggle`) — **EAC reference**; the pattern is platform ([button.md § Save / Discard](../controls/button.md#save--discard-platform-pattern))

### Values workspace

`IsDirty` ⇔ local **Changeset** is not empty (Added ∪ Modified ∪ Deleted).

### Settings workspace

`IsDirty` ⇔ column working copy differs from last loaded/saved baseline.

## Flow

```text
Abandon requested (toggle, nav, tab, selectors, import, route leave, …)
  → RequestAsync(continue)
  → If clean: continue
  → If dirty: dialog
       Save → persist active workspace
            success → Clear → continue
            failure (validation / save error) → same as Cancel: close dialog, stay,
              keep dirty, surface errors on the page (never trap the user in the dialog;
              multi-row editors use [Validation Summary](validation-summary.md) above the grid)
       Discard → discard active workspace → Clear → continue
       Cancel → stay
```

`BoToggle` only raises `ToggleRequested`. The host calls `RequestAsync` and updates `SelectedToggleKey` only when allowed. `BoTabs` raises `TabRequested`; the host calls `RequestAsync` from that handler and sets `args.Cancel = true` when blocked. `BoPanelNavigation` has no intent callback yet (interim guard in `SelectedItemChanged`; FV-008) — see [selection-and-navigation.md § Selection Authority Model](../controls/selection-and-navigation.md#selection-authority-model-tier-1--locked). (`RequestAsync` is the **EAC reference** guard's method name.)

## Configuration Session interaction (EAC reference)

When a surface uses Application Configuration Session Cache ([configuration-session-cache.md](../../../architecture/app-configuration/configuration-session-cache.md) · [ADR-020](../../../decisions/ADR-020-configuration-session-cache.md)):

- Session holds **baselines**; the active workspace holds the **working copy**
- Dirty State still tracks only the **active** registered workspace (no multi-dirty v1)
- Discard restores catalog working copies from the session baseline when warm
- Save updates the session baseline from the persistence response

## Documentation duty

When shipping a new abandon surface, wire it through the same guard — do not add a parallel confirm path.

`BoShuffleCardGrid` is an abandon surface when the host edits a working copy (reorder, field edits, staged deletes). The control does **not** embed Dirty State — wire page guard or dialog discard confirm in the host ([shuffle-card-grid.md](../controls/shuffle-card-grid.md)).
