# UI — Forms

Owner: UI

Form control standards. Related: [layout.md](../layout/layout.md) (Row + page composition JSON), [sections.md](../layout/sections.md), [typography.md](../foundations/typography.md), [tokens.md](../foundations/tokens.md), [overview.md](../overview.md), [shell.md](../shell/shell.md) (toasts / Submit).

**Hard standard:** every Text Field, Drop-Down List, Checkbox, Date Field, Number Field, Read-Only Field, Empty Field, and future form controls **must** be a direct child of a [`BoRow`](../layout/layout.md#row-borow), and that Row **must** sit inside a Section. See [layout.md — Page composition](../layout/layout.md#page-composition-locked--hard-standard).

## Reserved / empty row slots (locked)

| Surface | Standard |
| --- | --- |
| `IsHidden` | On form fields: still occupies a `BoRow` column (`.bo-row-item--hidden`); chrome not shown; **do not** use `display: none`. Skips required validation while hidden. |
| `BoEmptyField` | Empty alignment slot (no label/value); one equal-width column |

See [layout.md — Reserved / empty slots](../layout/layout.md#reserved--empty-slots-shipped).

## Deferred mandatory validation (locked)

| Concern | Standard |
| --- | --- |
| Asterisk | When `Required` is true **and the field is not `Disabled`**, show the red `*` immediately |
| Error chrome | **Only after a validation attempt** (e.g. shell Submit). Until then, empty required fields show no error text and no red border |
| Error text size | **10px** (shared `.bo-field__error`) — danger color; not body 14px |
| Required message | Universal resource string — English **"This field is required"** (`Validation_FieldRequired`). Same for every control; never field-label-specific |
| Invalid border | Danger color (`--bo-color-danger`) on the **control edge only** (same as Text Field input border) when the required-empty rule fails after attempt — **not** a wash/outline on the BoRow item container |
| Disabled | A `Disabled` field **never** shows the mandatory asterisk, **never** shows character count, and **never** participates in required validation (Submit ignores it for mandatory checks) |
| Hidden (`IsHidden`) | Same as Disabled for mandatory participation — reserved slot only; no asterisk / required fail while hidden |
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
| Label-to-value gap | Same as editable fields (`--bo-field-label-gap`, default **4px**) |
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
| Label-to-input gap | **`--bo-field-label-gap`** (default **4px**) — same for Text Field and Drop-Down List |
| Input typed text | **Calibri** (`--bo-font-family`); **14px** — see [typography.md](../foundations/typography.md) |
| Mandatory mark | When `Required` and not `Disabled`: bold red `*` after the label; modest gap before the star (`margin-left` ~0.2em); color `--bo-color-danger` |
| Rest border / outline | Grey using `--bo-color-card-container-border`; **fully rounded** control corners via `--bo-radius-md` (same as Drop-Down List closed box) |
| Focus | Recolor Fluent’s **native** bottom focus border to **primary** (`--bo-color-primary`) so it stays on the control edge and keeps rounded corners; not Fluent blue; do **not** add a separate underline below the field |
| Character count | Optional (`ShowCharacterCount`, default false); format `current/max` (no brackets); **inside** the input (Fluent `EndTemplate`), trailing/right; italic **10px**; muted. Denominator = `MaxLength` (**default 600**). **Hidden when `Disabled`** |
| Disabled | Hide Placeholder; hide character count; hide mandatory asterisk; skip required validation; greyer fill (`--bo-color-background`) so the field reads as non-editable; muted text |

**Gallery reference:** Theme (`/theme`) Attributes rows (`BoFieldReadOnly` Light + Dark); Components Text Field — Parameters Sub padded to **6** slots (`BoEmptyField`); Preview (editable \| read-only \| Backend Value).

These Text Field rules are **org standards** for every `BoTextField` usage.

## Drop-Down List (`BoDropDownList`)

**Display name:** Drop-Down List.  
**Component:** `BoDropDownList` in [SYSTEM-SHARED-UI](https://github.com/Breeze-On/SYSTEM-SHARED-UI).

Same field chrome as Text Field (label + **4px** label-to-control gap, mandatory asterisk, grey rest border, **`--bo-radius-md` rounded** closed box, primary focus, `--bo-color-field-background` fill — including Dark). Public API is `Bo*`; searchable list is owned by BreezeOn (Fluent is not the public surface).

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
- On open, focus moves to the search box (type without an extra click).
- Clear: single-select control **×** clears Value; multi-select keeps per-chip × plus a control **×** that clears all Codes.
- Selected rows: bold + soft elevated/shadow highlight; left accent bar **1.5px**, soft-rounded (not full corner wrap); no list checkboxes for multi.
- Gallery seed (code-local): `DDL_0001`…`DDL_0150` / `Drop-Down List Value 001`…`150`.

### Label and chrome

Same as Text Field for editable chrome and deferred mandatory validation (invalid = input border only): shared label gap, md corner radius on the closed control. Multi-height fields: `BoRow` uses **`align-items: start`** when any child is multi/tall; single-line controls stay optically centered in their slot. See [layout.md — Row](../layout/layout.md#row-borow).

**Gallery reference:** Components Drop-Down List — Parameters Sub padded to **6** slots (`BoEmptyField`); Preview (DisplayCode / AllowMultiple / Disabled knobs; editable + read-only + Backend Value); Settings dialog Language / Timezone rows.

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

Always shows **two** options: localized **Yes** / **No** (`Field_Boolean_Yes` / `Field_Boolean_No`; FR Oui/Non). Exactly one option is checked to match `Value`. Not a plain text `BoFieldReadOnly`.

| Concern | Standard |
| --- | --- |
| Box size | Fixed **14×14** outer size for both checked and unchecked (`box-sizing: border-box`) |
| Tick | Horizontally and vertically **centered** in the box (flex); rotate only — no off-center translate |
| Chrome | Soft / non-interactive: `cursor: default`; muted unchecked fill; checked = muted primary wash + primary border + primary tick (not solid interactive fill); no hover lift |
| Text | Muted body color |

**Gallery:** Components Checkbox tab — Parameters (Mandatory/Disabled/Hide Editable) padded to **6** slots (`BoEmptyField`) + Preview (editable \| `ReadOnly` Yes-No \| Backend Value `true`/`false`).

These Checkbox rules are **org standards** for every `BoCheckbox` usage.

## Date Field (`BoDateField`)

**Display name:** Date Field.  
**Component:** `BoDateField` in [SYSTEM-SHARED-UI](https://github.com/Breeze-On/SYSTEM-SHARED-UI).

Single-value date (or date+time) control. Public API is `Bo*` only; calendar popover is owned by BreezeOn.

| Parameter | Role |
| --- | --- |
| `Label` | Same chrome as Text Field (10px bold uppercase, field-label color) |
| `FieldKey` | Stable typed DTO / entity property identifier |
| `Value` / `ValueChanged` | `@bind-Value` to **`DateTime?` only** (see typed model hard standard below) |
| `Mode` | `BoDateFieldMode.Date` (default) or `DateTime` — **UI only**; does not change the bound CLR type |
| `Required` / `Disabled` / `IsHidden` | Same deferred mandatory rules as Text Field (Disabled / hidden skip participation) |
| `Placeholder` | Optional; default resource **`Field_Date_Placeholder_Default`** ("Choose a date") or **`Field_DateTime_Placeholder_Default`** when `Mode` is DateTime; **hidden when Disabled** |
| `ValidationGroup` / `ErrorText` / `Class` / `Style` | Same family as other form fields |

### Typed model / persistence (hard standard)

| Concern | Standard |
| --- | --- |
| Bound type | Always **`DateTime?`** on the typed DTO / entity / working model |
| Forbidden | **`DateOnly`**, `DateOnly?`, or binding the field to a date-only string property as the model type |
| Why | One persistence shape end-to-end; converting **from** `DateTime` (strip/ignore time) is easier than promoting a date-only value to datetime later |
| Date mode storage | Still a `DateTime`; control **normalizes time to midnight** (`00:00:00`, `DateTimeKind.Unspecified`) on every write |
| DateTime mode storage | `DateTime` with hour + minute (seconds cleared); `DateTimeKind.Unspecified` |
| Database | Prefer a datetime / datetime2 (nullable) column that matches the entity — do not use a date-only column for `BoDateField` bindings |
| Read-only display | Host may format a **short date** string for `BoFieldReadOnly` when the UX is date-only; that is display-only |
| Backend Value (gallery) | Always shown as **date + time** (`g` / culture general) to prove the typed value is `DateTime?` even when `Mode` is Date |

Planning JSON: `control: "DateField"`; optional `mode: "Date"` \| `"DateTime"`. The generated property remains `DateTime?`.

### Value and locale

| Concern | Standard |
| --- | --- |
| Date mode | Calendar / typing collect a **date**; bound value is `DateTime` at midnight |
| DateTime mode | Date + hour/minute; culture-aware display (`g`). Panel time row: digit **hh** (0–12 with AM/PM, or 0–23 when culture is 24h) · digit **mm** (0–60, clamp overshoot to 60; stored minute 0–59) · **AM/PM** select when culture uses 12h (`AMDesignator` / `PMDesignator`). No native `<input type="time">`. |
| Locale | Format + calendar month/weekday names from `IBoLocaleService` / `bo-culture` (**en-CA** / **fr-CA**) — same family as other i18n |
| Typing | Parse culture-formatted input on blur / Enter; invalid input reverts to last good value |

### Chrome and picker

| Concern | Standard |
| --- | --- |
| Label gap / corners / focus | Same as Text Field / DDL: **`--bo-field-label-gap`**, **`--bo-radius-md`**, primary focus border, field fill |
| Invalid border | Control edge only after validation attempt |
| Picker | Modern popover calendar: **fixed** placement (`boPopup` / `bo-popup.js`) so it overlays shell card / section overflow; rounded panel, soft elevation, tertiary/primary accents, today ring, selected primary fill |
| Month nav (Dark) | Prev/next arrow glyphs are **white** (`--bo-color-semantic-white`) on the nav chip so they stay visible |
| Affordances | Clear × + calendar toggle (same family as Drop-Down List clear/chevron) |

**Placement:** Direct child of `BoRow` inside a Section; participates in `BoValidationContext` / fail badges.

**Gallery reference:** Components Date Field — Parameters (Mandatory / Disabled / Mode = DateTime / Hide Editable) padded to **6** slots (`BoEmptyField`) + Preview (editable \| host-formatted read-only \| **Backend Value** as date+time).

These Date Field rules are **org standards** for every `BoDateField` usage.

## Number Field (`BoNumberField`)

**Display name:** Number Field.  
**Component:** `BoNumberField` in [SYSTEM-SHARED-UI](https://github.com/Breeze-On/SYSTEM-SHARED-UI).

Numeric entry with Text Field chrome. Public API is `Bo*` only; input uses Fluent text under the hood. Locale separators and currency/% affix placement come from `IBoLocaleService`.

| Parameter | Role |
| --- | --- |
| `Label` | Same chrome as Text Field (10px bold uppercase, field-label color) |
| `FieldKey` | Stable typed DTO / entity property identifier |
| `Value` / `ValueChanged` | `@bind-Value` to **`decimal?` only** (never `int` / `double` / string) |
| `IsInteger` | When true, blocks decimal point; scale is 0 |
| `NumberOfDecimals` | `int?` — meaningful when `!IsInteger`; default **0** when unset |
| `IsCurrency` / `CurrencyIsoCode` | Currency mode; approved ISO codes **CAD** / **USD** / **GBP** (internal catalog). `IsCurrency` and `IsPercent` are **mutually exclusive** |
| `IsPercent` | UI shows **0–100**; bound value is **entered ÷ 100** (e.g. 90 → `0.90m`) |
| `Alignment` | `BoNumberFieldAlignment`: `Left` / `Center` / `Right`; **default Right** (also apply to read-only companions) |
| `Required` / `Disabled` / `IsHidden` | Same deferred mandatory rules as Text Field (Disabled / hidden skip participation) |
| `Placeholder` | Optional; default resource **`Field_Number_Placeholder_Default`** ("Enter value"); **hidden when Disabled** |
| `ValidationGroup` / `ErrorText` / `Class` / `Style` | Same family as other form fields |

### Typed model / persistence (hard standard)

| Concern | Standard |
| --- | --- |
| Bound type | Always **`decimal?`** on the typed DTO / entity / working model |
| Forbidden | Binding to `int` / `double` / string as the model type |
| Database | Prefer `decimal(36, N)` where **N = max(2, NumberOfDecimals)** — host owns SQL; library does not |
| Percent storage | Persist the **fractional** value (UI 90 → `0.90`) |
| Read-only display | Host formats via the same rules as unfocused `BoNumberField` (`BoNumberDisplay.Format` helpers) |
| Backend Value (gallery) | Shows persisted `decimal?` (percent as fractional) |

Planning JSON: `control: "NumberField"`; optional `isInteger`, `numberOfDecimals`, `isCurrency`, `currencyIsoCode`, `isPercent`, `alignment`, `hidden`.

### Focus, blur, and validation

| Concern | Standard |
| --- | --- |
| Focus | Raw digits (+ `.` when decimals allowed); no thousand separators / affixes while editing; **first click / focus selects the whole value** so typing replaces it (second click places the caret) |
| Blur / unfocused | Culture number format (group separators + scale); currency symbol or `%` before/after per culture / catalog |
| Keystrokes | Non-numeric rejected; `IsInteger` blocks `.`; decimals clamped to `NumberOfDecimals` |
| Required | Asterisk immediate; red border + 10px error **after** validation attempt; live clear via `NotifyFieldChanged` |
| Percent range | Outside 0–100 (UI) uses the same deferred invalid chrome; keys `Validation_NumberPercentRange` / `Validation_NumberInvalid` |
| Currency catalog | Extend the **internal** `BoCurrencyCatalog` table in BreezeOn.UI when adding ISO codes (not a product-page concern) |

**Placement:** Direct child of `BoRow` inside a Section; participates in `BoValidationContext` / fail badges (`IBoValidatableField` + `IsInvalid`).

**Gallery reference:** Components Number Field — Parameters (Mandatory / Disabled / Hide Editable / Is Integer / Number of Decimals / Is Currency / Currency IsoCode / Is Percent / Alignment; pad to **6** slots per row) + Preview (editable \| host-formatted read-only \| **Backend Value** as persisted `decimal?`).

These Number Field rules are **org standards** for every `BoNumberField` usage.
