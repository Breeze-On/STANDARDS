# UI — Dirty State (unsaved changes)

Owner: UI / Architecture

Centralized abandon-guard for working copies. Related: [toggle.md](../controls/toggle.md), [grids.md](../controls/grids.md), [shuffle-card-grid.md](../controls/shuffle-card-grid.md), Data Entities architecture.

## Philosophy (locked)

Any action that would abandon the active working copy must resolve Dirty State first — **one** framework, not per-feature rules.

| Does | Does not |
| --- | --- |
| Track a single `IsDirty` for the active workspace | Live inside presentation controls (`BoToggle`, etc.) |
| Present Unsaved Changes: Save / Discard / Cancel | Invent separate rules for tab vs toggle vs import |
| Let future abandon points call the same gate | Couple Save/Discard to BoToggle |

## Product shape (EAC)

- Service: `EacDirtyStateGuard` (scoped)
- Dialog: Compact `BoDialog` — Save | Discard | Cancel
- Actions chrome: `EacSaveDiscardActions` (Save + Discard only; independent of `BoToggle`)

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
              keep dirty, surface errors on the page (never trap the user in the dialog)
       Discard → discard active workspace → Clear → continue
       Cancel → stay
```

`BoToggle` only raises `ToggleRequested`. The host calls `RequestAsync` and updates `SelectedToggleKey` only when allowed.

## Documentation duty

When shipping a new abandon surface, wire it through the same guard — do not add a parallel confirm path.

`BoShuffleCardGrid` is an abandon surface when the host edits a working copy (reorder, field edits, staged deletes). The control does **not** embed Dirty State — wire page guard or dialog discard confirm in the host ([shuffle-card-grid.md](../controls/shuffle-card-grid.md)).
