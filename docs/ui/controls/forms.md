# UI — Forms

Owner: UI

Form control standards. Related: [layout.md](../layout/layout.md) (Row + page composition JSON), [sections.md](../layout/sections.md), [typography.md](../foundations/typography.md), [tokens.md](../foundations/tokens.md), [overview.md](../overview.md), [shell.md](../shell/shell.md) (toasts / Submit).

**Hard standard:** every Text Field, Drop-Down List, Checkbox, Read-Only Field, and future form controls **must** be a direct child of a [`BoRow`](../layout/layout.md#row-borow), and that Row **must** sit inside a Section. See [layout.md — Page composition](../layout/layout.md#page-composition-locked--hard-standard).

## Deferred mandatory validation (locked)

| Concern | Standard |
| --- | --- |
| Asterisk | When `Required` is true **and the field is not `Disabled`**, show the red `*` immediately |
| Error chrome | **Only after a validation attempt** (e.g. shell Submit). Until then, empty required fields show no error text and no red border |
| Required message | Universal resource string — English **"This field is required"** (`Validation_FieldRequired`). Same for every control; never field-label-specific |
| Invalid border | Danger color (`--bo-color-danger`) on the **control edge only** (same as Text Field input border) when the required-empty rule fails after attempt — **not** a wash/outline on the BoRow item container |
| Disabled | A `Disabled` field **never** shows the mandatory asterisk, **never** shows character count, and **never** participates in required validation (Submit ignores it for mandatory checks) |
| Mechanism | Cascading `BoValidationContext`; fields register via `IBoValidatableField`; pages gate Submit with `IBoSubmitInterceptor` |
| Scope | Gallery Submit validates **all** registered groups (`Validate(null)`), not only the active tab |
| Live clear | After attempt, field value changes call `NotifyFieldChanged()` — one O(n) pass over registered fields; fail badges clear when that ancestor no longer has required-empty fields |
| Fail path (gallery) | Toast **Alert** — Main `Validation_MandatoryFieldsToast`; Body `Validation_MandatoryFieldsToastBody` (“Required information is missing. Review and complete all required fields.”) |

### Failure ancestry (structured)

Each required-empty failure is a `BoValidationFailure`:

| Identifier | Source |
| --- | --- |
| `FieldKey` | Field `FieldKey` |
| `SectionSubKey` | Cascaded from `BoSectionSub.SectionKey` (if any) |
| `SectionMainKey` | Cascaded from `BoSectionMain.SectionKey` (if any) |
| `TabKey` | Field `ValidationGroup` (match `BoTab.TabKey` when using tabs) |

Context aggregates: `Failures`, `FailedGroups` (tabs), `FailedSectionMains`, `FailedSectionSubs`.

### Fail badges

`BoValidationFailBadge`: red filled disc + white “!” + subtle shadow (CSS; Fluent ErrorCircle is single-tone). Shown on:

- Matching **tab** label (`TabKey` ∈ `FailedGroups`)
- Matching **Main** / **Sub** section header (`SectionKey` ∈ failed section sets; **4px** from the right and **4px** from the bottom of the header)

### Field component checklist

When shipping or changing a form `Bo*` control:

- [ ] Direct child of `BoRow` inside a Section
- [ ] `FieldKey` + `@bind-Value` to typed model; never hardcode user-visible labels
- [ ] `Required` / `Disabled` / deferred validation via `IBoValidatableField` (expose `FieldKey`, `ValidationGroup`, section keys from cascade)
- [ ] Call `BoValidationContext.NotifyFieldChanged()` after value changes
- [ ] Invalid chrome = control edge only; universal `Validation_FieldRequired`
- [ ] Default Placeholder from resources when applicable
- [ ] Update STANDARDS `forms.md` + gallery Preview (editable \| read-only \| Backend Value) in the same change set

## Read-Only Field (`BoFieldReadOnly`)

**Display name:** Read-Only Field.  
**Component:** `BoFieldReadOnly` in [SYSTEM-SHARED-UI](https://github.com/Breeze-On/SYSTEM-SHARED-UI).

Flat **display-only** companion for read views. Always shows **already-formatted text** (string, number, decimal, date, etc. share the same chrome). The host formats values **before** passing `Value` — the control does not own culture/type formatters.

| Parameter | Role |
| --- | --- |
| `Label` | Field label text — **same chrome as Text Field** (10px bold uppercase, field-label color) |
| `Value` | Pre-formatted display string; null/whitespace → blank |
| `FieldKey` | Stable typed DTO / entity property identifier (mapping metadata only) |
| `Class` / `Style` | Optional (use `bo-field--section-flush` in section rows like other fields) |

### Label and chrome

| Concern | Standard |
| --- | --- |
| Label font | **Same as Text Field** — 10px bold uppercase; `--bo-color-text-field-label` |
| Label-to-value gap | Minimal (~0-1px), same as editable fields |
| Value text | **Calibri** 14px; body text color (`--bo-color-text`); no input border, fill, or focus ring |
| Validation | None — not required, no asterisk, no deferred validation |
| Placement | Direct child of `BoRow` inside a Section |

**Formatting (app-side):** document and apply date/number/boolean display formats in the product app (or page) before binding `Value`. Do not invent parallel typed read-only controls for flat scalars.

**Gallery reference:** Components Preview — editable | read-only | **Backend Value (Typed Entity & Database)** (`BoFieldReadOnly` showing the bound typed value).

These Read-Only Field rules are **org standards** for every `BoFieldReadOnly` usage.

## Text Field (`BoTextField`)

**Display name:** Text Field.  
**Component:** `BoTextField` in [SYSTEM-SHARED-UI](https://github.com/Breeze-On/SYSTEM-SHARED-UI).

Apps bind values with `@bind-Value` to a **typed DTO / working-model property**. The control does not own persistence or JSON transport.

| Parameter | Role |
| --- | --- |
| `Label` | Field label text |
| `FieldKey` | Stable typed DTO / entity property identifier (mapping metadata only; does **not** replace `@bind-Value`) |
| `Required` | **Mandatory** when editable — red asterisk after the label; suppressed when `Disabled` |
| `MaxLength` | Maximum characters (enforced on the input). **Default 600** |
| `ShowCharacterCount` | When true **and not `Disabled`**, shows `current/max` inside the input. **Never shown when `Disabled`**. **Default false** |
| `Value` / `ValueChanged` | Two-way bind to the working model |
| `Placeholder` | Optional override. When null/whitespace, uses resource **`Field_Placeholder_Default`** ("Enter text..."). **Always omitted when `Disabled`** |
| `ValidationGroup` | Optional group for scoped Submit validation |
| `Disabled`, `ErrorText` | Standard field chrome (`ErrorText` for non-required messages; required-empty uses the universal string after attempt) |

### Label and chrome

| Concern | Standard |
| --- | --- |
| Label font | **10px**, **bold**, **uppercase**; color `--bo-color-text-field-label` (`color-text-field-label`, default `#757575`) — see [tokens.md](../foundations/tokens.md) |
| Label-to-input gap | Minimal (~0-1px) |
| Input typed text | **Calibri** (`--bo-font-family`); **14px** — see [typography.md](../foundations/typography.md) |
| Mandatory mark | When `Required` and not `Disabled`: bold red `*` after the label; modest gap before the star (`margin-left` ~0.2em); color `--bo-color-danger` |
| Rest border / outline | Grey using `--bo-color-card-container-border` |
| Focus | Recolor Fluent’s **native** bottom focus border to **primary** (`--bo-color-primary`) so it stays on the control edge and keeps rounded corners; not Fluent blue; do **not** add a separate underline below the field |
| Character count | Optional (`ShowCharacterCount`, default false); format `current/max` (no brackets); **inside** the input (Fluent `EndTemplate`), trailing/right; italic **10px**; muted. Denominator = `MaxLength` (**default 600**). **Hidden when `Disabled`** |
| Disabled | Hide Placeholder; hide character count; hide mandatory asterisk; skip required validation; greyer fill (`--bo-color-background`) so the field reads as non-editable; muted text |

**Gallery reference:** Theme (`/theme`) Attributes rows (`BoFieldReadOnly` Light + Dark); Components Text Field Preview (`editableTextField` + `BoFieldReadOnly` companion).

These Text Field rules are **org standards** for every `BoTextField` usage.

## Drop-Down List (`BoDropDownList`)

**Display name:** Drop-Down List.  
**Component:** `BoDropDownList` in [SYSTEM-SHARED-UI](https://github.com/Breeze-On/SYSTEM-SHARED-UI).

Same field chrome as Text Field (label, mandatory asterisk, grey rest border, primary focus, `--bo-color-field-background` fill — including Dark). Public API is `Bo*`; searchable list is owned by BreezeOn (Fluent is not the public surface).

| Parameter | Role |
| --- | --- |
| `Label` | Field label text |
| `FieldKey` | Stable typed DTO / entity property identifier (mapping metadata only) |
| `Required` | Mandatory asterisk when true **and not `Disabled`/`ReadOnly`**; no required validation when disabled/read-only |
| `Items` | `IEnumerable<BoDropDownListItem>` — prefer **`Code` + `Description`** (`Value`/`Text` remain aliases) |
| `Value` / `ValueChanged` | Two-way bind (`string?`) = **Code only** (single); when `AllowMultiple`, Codes joined by **`;`** (empty → null/`""`) |
| `DisplayCode` | When true, list/selection shows `"{Code} - {Description}"`; default false = Description only |
| `AllowMultiple` | Multi-select; closed control shows removable **chips** + control-level **Clear all**; open list toggles rows (no checkboxes in the list) |
| `ReadOnly` | Single: Description for selected Code. Multi: one checked Description **per line** (`;` → line breaks for UI) |
| `Placeholder` | Optional override. When null/whitespace, uses resource **`Field_DropDown_Placeholder_Default`** ("Select a value") |
| `ValidationGroup` | Optional group for scoped Submit validation |
| `Disabled`, `ErrorText` | Standard field chrome; Disabled hides chevron/clear, no open, greyer fill |

### Search and list

- Search lives in the **expanded panel** as a **fixed first row** (always available — including `DisplayCode` and `AllowMultiple`).
- Type filters where **Description contains** the query (case-insensitive). When **`DisplayCode`** is on (Code is shown in the list), also match **Code**.
- Show at most **100** matches (narrow with search).
- Clear: single-select control **×** clears Value; multi-select keeps per-chip × plus a control **×** that clears all Codes.
- Selected rows in the list: bold + subtle elevated/shadow highlight (not tertiary fill); no list checkboxes for multi.
- Gallery seed (code-local): `DDL_0001`…`DDL_0150` / `Drop-Down List Value 001`…`150`.

### Label and chrome

Same as Text Field for editable chrome and deferred mandatory validation (invalid = input border only). Multi-height fields: `BoRow` uses **`align-items: start`** when any child is multi/tall; single-line controls stay optically centered in their slot. See [layout.md — Row](../layout/layout.md#row-borow).

**Gallery reference:** Components Drop-Down List Preview (DisplayCode / AllowMultiple / Disabled knobs; editable + read-only + Backend Value); Settings dialog Language / Timezone rows.

These Drop-Down List rules are **org standards** for every `BoDropDownList` usage.

## Checkbox (`BoCheckbox`)

**Display name:** Checkbox.  
**Component:** `BoCheckbox` in [SYSTEM-SHARED-UI](https://github.com/Breeze-On/SYSTEM-SHARED-UI).

Boolean control: `Label` + `FieldKey` + `@bind-Value` (`bool`). Place as a direct child of `BoRow` when used in form layouts. Vertically middle-aligned in the BoRow item container with sibling fields.

| Parameter | Role |
| --- | --- |
| `Label` | Editable: **11px bold**, field-label color, **not** uppercase. Read-only: Text Field label chrome (10px bold uppercase) |
| `FieldKey` | Stable typed DTO / entity property identifier (mapping metadata) |
| `Value` / `ValueChanged` | Two-way bind to a **typed `bool`** property |
| `Required` | **Mandatory** when editable — red asterisk after the label; after Submit attempt, fails when **unchecked** (`Value == false`). Suppressed when `Disabled` or `ReadOnly` |
| `ValidationGroup` | Optional group for Submit validation |
| `Disabled` | Standard disabled chrome (editable mode only) |
| `ReadOnly` | Dual Yes/No display (exception to flat `BoFieldReadOnly`) |

### Editable

Control box is compact (~12px); control and label are vertically center-aligned. Asterisk at the **end** of the label when `Required`. Invalid after attempt: danger outline on the **checkbox control** only (not the BoRow item container).

### Read-only (`ReadOnly`)

Always shows **two** options: localized **Yes** / **No** (`Field_Boolean_Yes` / `Field_Boolean_No`; FR Oui/Non). Exactly one option is checked to match `Value`. Compact modern boxes (primary fill when checked); no edit/focus. Not a plain text `BoFieldReadOnly`.

**Gallery:** Components Checkbox tab — Parameters (Mandatory/Disabled knobs) + Preview (editable + `ReadOnly` companion).

These Checkbox rules are **org standards** for every `BoCheckbox` usage.
