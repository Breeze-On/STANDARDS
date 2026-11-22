<!-- Classification: AA; Scope: platform; Domain: UI; Capability: Controls -->
# UI — Buttons (`BoButton`, `BoIconButton`)

Owner: UI

Single source of truth for **button hierarchy, ordering, destructive actions, icon-only actions, and corner radius**. Related: [forms.md](forms.md), [tokens.md](../foundations/tokens.md), [icons.md](../foundations/icons.md), [accessibility.md](../foundations/accessibility.md), [actions-area.md](../patterns/actions-area.md), [dirty-state.md](../patterns/dirty-state.md), [overlays.md](../shell/overlays.md), [normative-tiers.md](../foundations/normative-tiers.md).

API (parameters, events, enums): [`public-component-api.md`](https://github.com/Breeze-On/SYSTEM-SHARED-UI/blob/main/docs/public-component-api.md) — [BoButton](https://github.com/Breeze-On/SYSTEM-SHARED-UI/blob/main/docs/public-component-api.md#bobutton) · [BoIconButton](https://github.com/Breeze-On/SYSTEM-SHARED-UI/blob/main/docs/public-component-api.md#boiconbutton).

Current reality only.

## Approved components (Tier 1 — LOCKED)

Product pages use **only** these for actions (no raw `<button>`, no Fluent buttons, no hex `BackgroundColor` overrides for semantic roles):

| Need | Component |
| --- | --- |
| Text (and optional leading icon) action | `BoButton` with a `BoButtonVariant` |
| Icon-only action (row actions, dismiss, compact toolbar) | **`BoIconButton`** (approved) — requires `AriaLabel`; default `Variant` = Stealth |
| Destructive action | **`BoButtonVariant.Danger`** (approved) — on `BoButton` or `BoIconButton` |

Using `BackgroundColor` / `ForegroundColor` to imitate Danger, Save, or Discard is a deviation. Use the variant or the tokens below.

## Hierarchy (Tier 2 — STANDARD)

| Variant | Emphasis | Use for | Do not use for |
| --- | --- | --- | --- |
| **Primary** | Highest — filled `--bo-color-primary`, white label | The **one** main action in a region (Add New, Save, dialog confirm, Submit) | More than one Primary per action group |
| **Secondary** | Medium — filled `--bo-color-tertiary` | Normal / alternative actions (Discard, Filters, Cancel in a footer) | The only way to perform a destructive action |
| **Danger** | Highest warning — filled `--bo-color-danger`, white label | Destructive or hard-to-undo actions (Delete, Remove, Reset) | Routine actions; non-destructive "Cancel" |
| **Stealth** | Low — transparent | Low-emphasis tertiary actions, toolbar chrome, links-as-buttons | Primary workflows; the only visible action |
| **Icon-only** (`BoIconButton`) | Per variant (default Stealth) | Dense surfaces where a label does not fit (grid row actions, close) | Actions that are not instantly recognizable; anything without an accessible name |

Rules:

1. **One Primary per action group.** Everything else steps down (Secondary → Stealth).
2. **Label every action** unless it is an icon-only control with `AriaLabel` ([accessibility.md](../foundations/accessibility.md)).
3. Labels are one line (`nowrap`); the button hugs its label. Give the slot more `Weight` rather than letting a label clip.
4. Blocking work uses `IBoPageFreezeService` from the click handler — `BoButton` has no busy / spinner API ([overlays.md](../shell/overlays.md)).

### Chrome (Tier 2 — STANDARD)

- **Fill by variant:** Primary `--bo-color-primary` (white label, hover `--bo-color-primary-hover`); Secondary `--bo-color-tertiary`; Danger `--bo-color-danger` (white label); Stealth transparent. Optional `BackgroundColor` / `ForegroundColor` exist for exceptional cases only — prefer a variant.
- **No border**; soft shadow + hover lift (reduced motion: no lift — [motion.md](../foundations/motion.md)).
- **Bold label**; optional leading `IconContent` (16px — [icons.md](../foundations/icons.md)).
- **Padding:** shorter and wider than the spacing default — half the vertical and double the horizontal of `--bo-space-md` ([tokens.md § Spacing scale](../foundations/tokens.md#spacing-scale)).
- **Label wrapping:** labels are one line (`nowrap`); the button hugs its label (`width: max-content`) and does not stretch to its `BoRow` slot.

## Decision matrix

| Situation | Choose |
| --- | --- |
| Submit / confirm the main outcome of the page, section, or dialog | **Primary** |
| Cancel / close a dialog; Discard unsaved edits; open Filters | **Secondary** |
| Delete a row, record, or setting (not undoable without Save/Discard) | **Danger** (+ confirmation per below) |
| Subtle toolbar affordance beside stronger buttons | **Stealth** |
| Edit / Delete / Dismiss in a grid or card row | **`BoIconButton`** (Stealth; Danger for Delete when emphasized) |
| Toggle between views | Not a button — [Toggle](selection-and-navigation.md) |
| Navigate to another page | Not a button — left nav / hyperlink ([navigation.md](../shell/navigation.md)) |

## Destructive guidance (Tier 1 for the confirmation rule)

- Destructive actions use **Danger** — never Primary, never a hex-overridden Secondary.
- Deletion that is **staged** in a working copy (grid row delete before Save) needs no extra confirm; Save / Discard and [Dirty State](../patterns/dirty-state.md) already gate persistence.
- Deletion that is **immediate and irreversible** (persists on click) requires an explicit confirmation dialog (`BoDialog`) whose confirm button is **Danger**. `BoDialog` renders its built-in `PrimaryAction` button as Primary, so compose the Danger confirm in `FooterContent` and set `SuppressEnterPrimary` so Enter cannot confirm a destructive action by accident.
- Pair an icon-only Danger with `AriaLabel` that names the object ("Delete row").

## Ordering (Tier 2 — STANDARD)

Order depends on the container, because reading flow differs:

| Container | Order (left → right) | Reference |
| --- | --- | --- |
| **Dialog footer** | Secondary (Cancel) then **Primary** — Primary rightmost | `BoDialog` footer |
| **Section / grid header actions** | **Primary** first, then Secondary; Filters rightmost: `Add New \| Save \| Filters` | [grids.md](grids.md) |
| **Actions area** (page / workspace) | **Save** (Primary) then **Discard** (Secondary) | [actions-area.md](../patterns/actions-area.md) |
| **Row actions** | Edit, then Delete; Danger last | [grids.md](grids.md) |

Keep a consistent order across all pages of a product.

## Save / Discard (platform pattern)

Save and Discard of a working copy is a **platform action pattern**, not an EAC-only feature. Any application with an editable working copy exposes the pair in its [Actions area](../patterns/actions-area.md) and gates abandon points through [Dirty State](../patterns/dirty-state.md).

| Role | Variant | Notes |
| --- | --- | --- |
| **Save** | Primary | Persists the active working copy; runs validation first ([forms.md](forms.md)) |
| **Discard** | Secondary | Reverts to the baseline |

Tokens `--bo-color-save-button-*` and `--bo-color-discard-button-*` ([tokens.md](../foundations/tokens.md)) are the platform tokens for soft Save / Discard chrome. Products map them onto `.bo-button` through CSS (EAC does this in its app stylesheet) — **never** raw hex. Today there is **no** SHARED-UI Save/Discard component; the EAC composition (`EacSaveDiscardActions`) is the **EAC reference**. Promotion is Future Validation (FV-001, app #2).

## Corner radius — single authority (Tier 2)

Every button (all variants, `BoIconButton`, dialog footers, grid toolbar / pager / icon buttons, shuffle-card action buttons) uses **`--bo-button-radius`**, which aliases `--bo-radius-md`. It is **not independently tunable**. Value, token model, and the full list of surfaces that share it: [tokens.md § Corner radius](../foundations/tokens.md#corner-radius-tokens-current).

- There is no per-instance radius or shape API.
- Product apps and Gallery pages **must not** set `border-radius` on `.bo-button` (Tier 1).
- Header `BoTabs` also use `--bo-button-radius`; circular non-button chrome (header icon hits, avatars, theme-switch track) uses `--bo-radius-full` / `50%`.

## Not a button

Header tabs, toggle segments, panel navigation items, and left-nav links are **selection controls** with their own chrome — [selection-and-navigation.md](selection-and-navigation.md).

## Gallery

Components → **Other** → **Button** (variants incl. Danger, `BoIconButton`, Tabs keyboard + `TabRequested` demo). Index: [gallery-index.md](../gallery-index.md). Stealth in context: Import Summary, Validation Summary demos.
