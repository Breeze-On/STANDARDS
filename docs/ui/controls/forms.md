# UI — Forms

Owner: UI

Form control standards. Related: [layout.md](../layout/layout.md) (Row + page composition JSON), [sections.md](../layout/sections.md), [typography.md](../foundations/typography.md), [tokens.md](../foundations/tokens.md), [overview.md](../overview.md), [shell.md](../shell/shell.md) (toasts / Submit).

**Hard standard:** every Text Field, Drop-Down List, Checkbox, and future form controls **must** be a direct child of a [`BoRow`](../layout/layout.md#row-borow), and that Row **must** sit inside a Section. See [layout.md — Page composition](../layout/layout.md#page-composition-locked--hard-standard).

## Deferred mandatory validation (locked)

| Concern | Standard |
| --- | --- |
| Asterisk | When `Required` is true **and the field is not `Disabled`**, show the red `*` immediately |
| Error chrome | **Only after a validation attempt** (e.g. shell Submit). Until then, empty required fields show no error text and no red border |
| Required message | Universal resource string — English **"This field is required"** (`Validation_FieldRequired`). Same for every control; never field-label-specific |
| Invalid border | Danger color (`--bo-color-danger`) on the control edge when the required-empty rule fails after attempt |
| Disabled | A `Disabled` field **never** shows the mandatory asterisk, **never** shows character count, and **never** participates in required validation (Submit ignores it for mandatory checks) |
| Mechanism | Cascading `BoValidationContext`; fields register via `IBoValidatableField`; optional `ValidationGroup` (e.g. active Theme tab). Pages gate Submit with `IBoSubmitInterceptor` |
| Fail path (gallery) | Toast **Error** with **"Mandatory fields are required"** — do not run the success Submit dialog |

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

**Gallery reference:** Theme (`/theme`) Attributes rows; Components Text Field Preview (`editableTextField`).

These Text Field rules are **org standards** for every `BoTextField` usage.

## Drop-Down List (`BoDropDownList`)

**Display name:** Drop-Down List.  
**Component:** `BoDropDownList` in [SYSTEM-SHARED-UI](https://github.com/Breeze-On/SYSTEM-SHARED-UI).

Same field chrome as Text Field (label, mandatory asterisk, grey rest border, primary focus, field background). Fluent select stays **internal** to the library.

| Parameter | Role |
| --- | --- |
| `Label` | Field label text |
| `FieldKey` | Stable typed DTO / entity property identifier (mapping metadata only) |
| `Required` | Mandatory asterisk when true **and not `Disabled`**; no required validation when disabled |
| `Items` | `IEnumerable<BoDropDownListItem>` (`Value` + `Text`) |
| `Value` / `ValueChanged` | Two-way bind (`string?`) to the working model |
| `Placeholder` | Optional override. When null/whitespace, uses resource **`Field_DropDown_Placeholder_Default`** ("Choose…"). **Always omitted when `Disabled`** |
| `ValidationGroup` | Optional group for scoped Submit validation |
| `Disabled`, `ErrorText` | Standard field chrome |

### Label and chrome

Same table as Text Field (10px bold uppercase label, Calibri 14px control text, danger asterisk when editable, card-container border at rest, primary focus edge, `--bo-color-field-background` fill; Disabled greyer fill, no Placeholder, no mandatory asterisk / required validation). No character count. Same deferred mandatory validation rules.

**Gallery reference:** Components Drop-Down List Preview; Settings dialog Language / Timezone rows.

These Drop-Down List rules are **org standards** for every `BoDropDownList` usage.

## Checkbox (`BoCheckbox`)

**Display name:** Checkbox.  
**Component:** `BoCheckbox` in [SYSTEM-SHARED-UI](https://github.com/Breeze-On/SYSTEM-SHARED-UI).

Boolean control: `Label` + `FieldKey` + `@bind-Value` (`bool`). Place as a direct child of `BoRow` when used in form layouts.

| Parameter | Role |
| --- | --- |
| `Label` | Label text — **11px bold**, field-label color, **not** uppercase; vertically centered with the control box |
| `FieldKey` | Stable typed DTO / entity property identifier (mapping metadata) |
| `Value` / `ValueChanged` | Two-way bind to a **typed `bool`** property |
| `Disabled` | Standard disabled chrome |

Control box is compact (~12px); control and label are vertically center-aligned. Gallery: Components Checkbox tab Preview (`editableCheckbox`); also used on Components Parameters rows.

These Checkbox rules are **org standards** for every `BoCheckbox` usage.
