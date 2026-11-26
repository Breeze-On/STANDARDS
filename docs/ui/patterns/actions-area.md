<!-- Classification: AA; Scope: platform; Domain: UI; Capability: Patterns -->
# UI — Actions area

Owner: UI

Authoritative definition of **"Actions"** as used in [grids.md](../controls/grids.md), [shuffle-card-grid.md](../controls/shuffle-card-grid.md), [validation-summary.md](validation-summary.md), [panels.md](../layout/panels.md), and [dirty-state.md](dirty-state.md). Related: [button.md](../controls/button.md), [sections.md](../layout/sections.md), [normative-tiers.md](../foundations/normative-tiers.md).

Current reality only.

## Status

| Aspect | Status |
| --- | --- |
| **Concept** (what "Actions" means, where it sits, what it holds) | **Platform** standard (this document) |
| SHARED-UI component for the Actions area | **None** — composed from `BoSectionSub` + `BoButton` |
| Reference composition | **EAC reference**: `BoSectionSub` titled Actions containing `EacSaveDiscardActions` (Save Primary + Discard Secondary) |
| Promotion of a shared Save/Discard/Actions component | Future Validation (FV-001) — only after a second application validates the need |

## Definition (Tier 2 — STANDARD)

The **Actions area** is the **page- or workspace-level** region holding the commands that apply to the **entire active working copy** for **workspace / catalog editors** (e.g. EAC App Configuration):

- **Save** (Primary) and **Discard** (Secondary) — [button.md § Save / Discard](../controls/button.md#save--discard-platform-pattern)
- optionally other **page-level** commands of the same scope, after Save / Discard

It is rendered as a **`BoSectionSub` titled "Actions"** (localized) at the **top** of the editable workspace.

**Default process initiation** (New Request) does **not** use this area — use shell footer **Save + Submit** ([page-footer-actions.md](page-footer-actions.md), [initiation-experience.md](initiation-experience.md)).

### Vertical order inside an editable workspace

```text
Actions                      <- this area (Save | Discard)
Errors (BoValidationSummary) <- only after a failed Save/Commit attempt
Editable sections / BoGrid / BoShuffleCardGrid
```

This is the order referenced by [validation-summary.md](validation-summary.md) ("below Actions, above the grid").

## What the Actions area is not

| Surface | Where it lives | Reference |
| --- | --- | --- |
| Grid toolbar (`Add New`, `Save`, `Filters`) | **Section** `HeaderActions` of the section that owns the grid | [grids.md](../controls/grids.md) |
| Shuffle Card Add New / Filters | Host section `HeaderActions` | [shuffle-card-grid.md](../controls/shuffle-card-grid.md) |
| Row actions (edit, delete, handle) | Leading / trailing action track of the row | [grids.md](../controls/grids.md), [shuffle-card-grid.md](../controls/shuffle-card-grid.md) |
| Dialog Cancel / Confirm | `BoDialog` footer | [overlays.md](../shell/overlays.md) |
| **Quick Actions** (EAC Data Entities command cards: New, Edit, Excel Tool) | Collapsible command-card section — an **EAC composition**, not the Actions area | [architecture/applications/eac.md](../../../architecture/applications/eac.md) |

## Rules

1. **Scope** — Save / Discard in the Actions area act on the whole active working copy (all sections / grids in that workspace), not one grid.
2. **Single owner** — when the Actions area owns Save / Discard, grids on that page set `ShowSave="false"` so there is exactly one Save ([`BoGrid.ShowSave`](https://github.com/Breeze-On/SYSTEM-SHARED-UI/blob/main/docs/public-component-api.md#bogrid)).
3. **Dirty-aware** — Save and Discard are disabled while the working copy is clean (`IsDirty` false) — [dirty-state.md](dirty-state.md).
4. **Validation first** — Save runs the page's validation (`BoValidationContext.Validate`); on failure show the [Validation Summary](validation-summary.md) + Alert toast and **stay** — never trap the user.
5. **Order** — Save then Discard; Primary leftmost ([button.md § Ordering](../controls/button.md#ordering-tier-2--standard)).
6. **Pinned when scrolling** — in a workspace whose body scrolls (panel `Fill`), pin the Actions area as a non-scrolling sibling above the scroll region so Save / Discard stay in the viewport ([panels.md § Pinned chrome](../layout/panels.md#pinned-chrome-inside-fill-eac-reference-composition)).
7. **Not for dialogs** — dialog editors use footer actions and local discard confirmation ([dirty-state.md](dirty-state.md)).

## Gallery

No Gallery demo of an Actions area yet (the EAC reference is the only composition). Recorded in [gallery-index.md](../gallery-index.md) and [DEV-002](../../deviations/DEV-002-example-governance-approved-exceptions.md).
