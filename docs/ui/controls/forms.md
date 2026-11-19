# UI — Forms

Owner: UI

Form control standards. Related: [layout.md](../layout/layout.md) (Row + page composition JSON), [sections.md](../layout/sections.md), [typography.md](../foundations/typography.md), [tokens.md](../foundations/tokens.md), [overview.md](../overview.md), [shell.md](../shell/shell.md) (toasts / Submit), [ux-conventions.md](../patterns/ux-conventions.md) (placeholders, disabled, truncation).

**Hard standard:** every Text Field, Drop-Down List, Checkbox, Date Field, Number Field, Read-Only Field, Empty Field, and future form controls **must** be a direct child of a [`BoRow`](../layout/layout.md#row-borow), and that Row **must** sit inside a Section. See [layout.md — Page composition](../layout/layout.md#page-composition-locked--hard-standard).

## Reserved / empty row slots (locked)

| Surface | Standard |
| --- | --- |
| `Weight` | Proportional `BoRow` width share (default **1**). Not a 12-column span — see [layout.md](../layout/layout.md) |
| `IsHidden` | Chrome not shown; **default collapses** layout (Weight ignored). Skips required validation while hidden. |
| `PreserveLayoutWhenHidden` | When hidden, keep Weight share / reserved slot (`visibility: hidden`). Default **false**. |
| `BoEmptyField` | Empty alignment slot (no label/value); has `Weight` (default 1) |

See [layout.md — Hidden fields and layout preservation](../layout/layout.md#hidden-fields-and-layout-preservation-organization-standard).

## Deferred mandatory validation (locked)

| Concern | Standard |
| --- | --- |
| Asterisk | When `Required` is true **and the field is not `Disabled`**, show the red `*` immediately |
| Error chrome | **Only after a validation attempt** (e.g. shell Submit). Until then, empty required fields show no error text and no red border |
| Error text size | **10px** (shared `.bo-field__error`) — danger color; not body 14px |
| Required message | Universal resource string — English **"This field is required"** (`Validation_FieldRequired`). Same for every control; never field-label-specific |
| Invalid border | Danger color (`--bo-color-danger`) on the **control edge only** (same as Text Field input border) when the required-empty rule fails after attempt — **not** a wash/outline on the BoRow item container |
| Disabled | A `Disabled` field **never** shows the mandatory asterisk, **never** shows character count, and **never** participates in required validation (Submit ignores it for mandatory checks) |
| Hidden (`IsHidden`) | Same as Disabled for mandatory participation — no asterisk / required fail while hidden; layout collapses unless `PreserveLayoutWhenHidden` |
| Mechanism | Cascading `BoValidationContext`; fields register via `IBoValidatableField`; pages gate Submit with `IBoSubmitInterceptor` |
| Scope | Gallery Submit validates **all** registered groups (`Validate(null)`), not only the active tab |
| Group scoping | `BoValidationContext.IsAttempted(group)` drives field chrome. `Validate(group)` attempts **only** that group — fields in other groups do not show required chrome or fail badges. `Validate(null)` attempts all groups. Fields with no `ValidationGroup` participate only in a `Validate(null)` attempt |
| Host `ErrorText` | A non-empty `ErrorText` on a field sets `IsInvalid` (fails `BoValidationContext` validation / fail badges) **and** shows the red invalid chrome + error text, independent of `Required`. Required-empty after attempt still shows the universal required message instead |
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

`BoValidationFailBadge`: compact disc (~11px) + centered white “!” + soft shadow (CSS; Fluent ErrorCircle is single-tone). Light theme uses a **softer** danger red; dark theme keeps full danger. Visible but not dominant.

**Placement (locked):** on `BoSectionMain` / `BoSectionSub` / `BoTab`, the badge appears **left of the label** in the **icon slot**. When validation fails it **replaces** the configured `IconContent`; when the failure clears, the original icon returns. Shown on:

- Matching **tab** label (`TabKey` ∈ `FailedGroups`) — left icon slot
- Matching **Main** / **Sub** section header (`SectionKey` ∈ failed section sets) — left icon slot (replaces `IconContent` while failed)

### Field component checklist

When shipping or changing a form `Bo*` control:

- [ ] Direct child of `BoRow` inside a Section
- [ ] `FieldKey` + `@bind-Value` to typed model; never hardcode user-visible labels
- [ ] `Required` / `Disabled` / deferred validation via `IBoValidatableField` (expose `FieldKey`, `ValidationGroup`, section keys from cascade)
- [ ] Call `BoValidationContext.NotifyFieldChanged()` after value changes
- [ ] Invalid chrome = control edge only; universal `Validation_FieldRequired`; host `ErrorText` also sets invalid chrome (`BoFieldChromeRules.IsInvalidChrome`)
- [ ] Root classes via `BoFieldChromeRules.RootClass` (invalid / disabled / hidden modifiers) — all editable controls, including Number Field
- [ ] `ReadOnly` (Text / Number / Date): not editable, skips required validation; `Disabled` / `IsHidden` unchanged
- [ ] `<label for>` points at the control id (`FieldKey` → `bo-field-{FieldKey}`, else an auto id)
- [ ] Unmatched attributes (`AdditionalAttributes`, captured) are forwarded by the control (root field chrome only — do **not** use them for `autocomplete`; use `AutoComplete` on Text/Number)
- [ ] Browser autocomplete defaults to **off** on editable text surfaces (see [Browser autocomplete](#browser-autocomplete-locked))
- [ ] Default Placeholder from resources when applicable
- [ ] Update STANDARDS `forms.md` + gallery Preview (editable \| read-only \| Backend Value) in the same change set

## Browser autocomplete (locked)

Admin / enterprise workspaces (`Bo*` editable fields) **default autocomplete off**. Developers must not remember `autocomplete="off"` on every field. Opt in only when a field truly needs browser assistance.

| Control | Behavior |
| --- | --- |
| `BoTextField` / `BoNumberField` | `AutoComplete` parameter **default `"off"`** → Fluent `FluentTextInput` (requires control `Id`; Bo already sets `FieldId`) |
| `BoDateField` | Main date input and DateTime hour/minute/`select` use `autocomplete="off"` |
| `BoDropDownList` / `BoPeoplePicker` | Panel search input uses `autocomplete="off"` |
| Checkbox / Toggle / Button / Read-Only | N/A (no typed-history surface) |

| Concern | Standard |
| --- | --- |
| Default | Literal token **`off`** — do **not** invent non-standard tokens (`nope`, random strings); Chromium treats invalid tokens as absent and can re-enable history |
| Opt-in | Set `AutoComplete` on `BoTextField` / `BoNumberField` to a [standard HTML token](https://developer.mozilla.org/en-US/docs/Web/HTML/Reference/Attributes/autocomplete) (e.g. `email`) when needed |
| Unmatched attributes | Host `autocomplete=` via `AdditionalAttributes` lands on the **root field `<div>`**, not the real input — **ineffective** for Fluent-backed Text/Number; use the `AutoComplete` parameter |
| Grid cell editors | Reuse shipped `Bo*` fields in `Edit` templates — inherit this default. Raw `<input>` in an Edit template is a standards violation ([grids.md](grids.md)) |
| Product apps (e.g. EAC) | No per-screen / form-shell fix — inherit via Shared UI |
| Ownership | SYSTEM-SHARED-UI (`BreezeOn.UI`); documented here (no separate ADR) |

**Browser expectations (Chrome / Edge — Chromium):**

| Behavior | Realistic effect of `autocomplete="off"` |
| --- | --- |
| Typed-history / previously entered suggestions | Generally **suppressed** (primary admin UX goal) |
| Profile / address / payment autofill | May still appear when name/id/label/placeholder look personal — prefer admin-oriented labels (Code, Description); do not chase CSS or fake-token hacks |
| Password manager on login-like fields | Intentionally ignores `off` — N/A until a password control exists; then prefer `new-password` patterns |

Success bar: routine saved-value / history suggestions stay off for admin text/number entry. Do not promise elimination of every Chromium profile heuristic.

## Read-Only Field (`BoFieldReadOnly`)

**Display name:** Read-Only Field.  
**Component:** `BoFieldReadOnly` in [SYSTEM-SHARED-UI](https://github.com/Breeze-On/SYSTEM-SHARED-UI).

Flat **display-only** companion for read views. Always shows **already-formatted text** (string, number, decimal, date, etc. share the same chrome). The host formats values **before** passing `Value` — the control does not own culture/type formatters.

| Parameter | Role |
| --- | --- |
| `Label` | Field label text — **same chrome as Text Field** (10px bold uppercase, field-label color) |
| `Value` | Pre-formatted display string; null/whitespace → blank |
| `FieldKey` | Stable typed DTO / entity property identifier (mapping metadata only) |
| `IsHidden` | Chrome hidden; layout collapses by default |
| `PreserveLayoutWhenHidden` | Keep Weight share while hidden (default false) |
| `Weight` | Proportional BoRow share (default 1) |
| `Alignment` | `BoNumberFieldAlignment` Left (default) / Center / Right — use Right/Center for numeric companions (same `bo-field--align-*` modifiers as Number Field) |
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
| `AutoComplete` | HTML autocomplete token. **Default `"off"`** (admin workspace). Opt in with a standard token (e.g. `email`) — see [Browser autocomplete](#browser-autocomplete-locked) |
| `ShowCharacterCount` | When true **and not `Disabled`**, shows `current/max` inside the input. **Never shown when `Disabled`**. **Default false** |
| `Value` / `ValueChanged` | Two-way bind to the working model |
| `DebounceMilliseconds` | When &gt; 0, defers `ValueChanged` until the user stops typing for that many ms, presses Enter, or leaves the field (whichever first). Default **0** (immediate). Filters typically use **750** — see [Filter execution](#filter-execution-query-driven) |
| `Placeholder` | Optional override. When null/whitespace, uses resource **`Field_Placeholder_Default`** ("Enter text..."). **Do not** echo the field label or column header — [ux-conventions.md](../patterns/ux-conventions.md) § Placeholders. **Always omitted when `Disabled`** |
| `ValidationGroup` | Optional group for scoped Submit validation |
| `Disabled` | Standard disabled chrome |
| `ReadOnly` | Value shown but not editable; no asterisk and no required validation |
| `ErrorText` | Host-supplied error: invalid chrome + validation failure (see Deferred mandatory validation); required-empty uses the universal string after attempt |

### Label and chrome

| Concern | Standard |
| --- | --- |
| Label font | **10px**, **bold**, **uppercase**; color `--bo-color-text-field-label` (`color-text-field-label`, default `#757575`) — see [tokens.md](../foundations/tokens.md) |
| Label-to-input gap | **`--bo-field-label-gap`** (default **4px**) — same for Text Field and Drop-Down List |
| Input typed text | **Calibri** (`--bo-font-family`); **14px** — see [typography.md](../foundations/typography.md) |
| Mandatory mark | When `Required` and not `Disabled`: bold red `*` after the label; modest gap before the star (`margin-left` ~0.2em); color `--bo-color-danger` |
| Rest border / outline | Grey using `--bo-color-card-container-border`; **fully rounded** control corners via `--bo-radius-md` (same as Drop-Down List closed box) |
| Hover | Subtle border only (`--bo-color-field-border-hover`); **no** fill change, glow, or lift |
| Focus | **Full 1px border** in `--bo-color-field-border-focus` (Light = primary; Dark = brighter focus stroke for contrast on field fill). Same geometry for Text / Number / Date / DDL closed box. Fluent Text/Number: paint the border on **`::part(root)` only** — never also on `::part(control)`; suppress Fluent’s `::part(root)::after` bottom accent (that pair doubles/misaligns chrome). Not Fluent bottom-edge-only; not Fluent blue; do **not** add a separate underline, glow, or focus-ring stroke |
| Caret | Themed via native CSS `caret-color` (`--bo-color-caret`) only — **no** custom caret widgets or JS caret rendering |
| Selection | Branded via native `::selection` / `::-moz-selection` (`--bo-color-selection-bg` / `--bo-color-selection-fg`) only — **no** custom selection engines |
| Character count | Optional (`ShowCharacterCount`, default false); format `current/max` (no brackets); **inside** the input (Fluent `EndTemplate`), trailing/right; italic **10px**; muted. Denominator = `MaxLength` (**default 600**). **Hidden when `Disabled`** |
| Disabled | Hide Placeholder; hide character count; hide mandatory asterisk; skip required validation; greyer fill (`--bo-color-background`) so the field reads as non-editable; muted text |

### Editing visuals and native interaction (locked)

Premium enterprise chrome (Concept A — Confident Outline): calm focus/hover/caret/selection tokens. **Preserve browser-native editing behavior** — do not replace with custom engines:

- Caret placement on click
- Drag selection
- Double-click / triple-click selection
- Ctrl+A / Cmd+A
- Keyboard navigation and platform accessibility behavior

Visual polish enhances presentation only. Tokens: [tokens.md](../foundations/tokens.md).

**Gallery reference:** Theme (`/theme`) Attributes rows (`BoFieldReadOnly` Light + Dark); Components Text Field — Parameters Sub padded to **6** slots (`BoEmptyField`); Preview (editable \| read-only \| Backend Value).

These Text Field rules are **org standards** for every `BoTextField` usage.

## Drop-Down List (`BoDropDownList`)

**Display name:** Drop-Down List.  
**Component:** `BoDropDownList` in [SYSTEM-SHARED-UI](https://github.com/Breeze-On/SYSTEM-SHARED-UI).

Same field chrome as Text Field (label + **4px** label-to-control gap, mandatory asterisk, grey rest border, **`--bo-radius-md` rounded** closed box, hover border, **full-border** focus via `--bo-color-field-border-focus`, `--bo-color-field-background` fill — including Dark). Public API is `Bo*`; searchable list is owned by BreezeOn (Fluent is not the public surface).

| Parameter | Role |
| --- | --- |
| `Label` | Field label text |
| `FieldKey` | Stable typed DTO / entity property identifier (mapping metadata only) |
| `Required` | Mandatory asterisk when true **and not `Disabled`/`ReadOnly`**; no required validation when disabled/read-only |
| `Items` | `IEnumerable<BoDropDownListItem>` — prefer **`Code` + `Description`** (`Value`/`Text` remain aliases) |
| `Value` / `ValueChanged` | Two-way bind (`string?`) = **Code only** (single); when `AllowMultiple`, Codes joined by **`;`** (empty → null/`""`) |
| `DisplayCode` | When true, list/selection shows `"{Code} - {Description}"`; default false = Description only |
| `AllowMultiple` | Multi-select; closed control shows removable **chips** + control-level **Clear all**; open list toggles rows (no checkboxes in the list) |
| `KeepOpen` | Single-select only: when true, the panel stays open after a selection (repeated-add / picker flows). Multi-select already stays open; ignored when `AllowMultiple` is true |
| `ClearAfterSelect` | Single-select only: after raising `ValueChanged`, clears the bound Value so the closed control returns to placeholder. Typical with `KeepOpen` for add-pickers; ignored when `AllowMultiple` is true |
| `ReadOnly` | Single: Description for selected Code. Multi: one checked Description **per line** (`;` → line breaks for UI) |
| `Placeholder` | Optional override. When null/whitespace, uses resource **`Field_DropDown_Placeholder_Default`** ("Select a value"). **Do not** echo the field label or column header — [ux-conventions.md](../patterns/ux-conventions.md) § Placeholders. **Always omitted when `Disabled`** |
| `ValidationGroup` | Optional group for scoped Submit validation |
| `Disabled`, `ErrorText` | Standard field chrome; Disabled hides chevron/clear, no open, greyer fill, **muted text (same color as a disabled Text Field)**, and **omits Placeholder** |
| Closed value overflow | Single-select closed value **truncates** with ellipsis; hover `title` when truncated. Selected values must not widen the control — [ux-conventions.md](../patterns/ux-conventions.md) § Control width and truncation |

### Search and list

- Search lives in the **expanded panel** as a **fixed first row** (always available — including `DisplayCode` and `AllowMultiple`).
- Expanded panel is a **fixed** popover via `boPopup` / `bo-popup.js` (same escape path as Date Field): overlays shell cards and dialogs with `overflow: auto` (e.g. Settings); width matches the closed control; options `max-height` grows into available viewport space under (or above) the control, then scrolls inside the options region only when the list is taller than that space.
- Type filters where **Description contains** the query (case-insensitive). When **`DisplayCode`** is on (Code is shown in the list), also match **Code**.
- Static `Items` only: show at most **100** client-filtered matches in the panel (display cap — narrow with search). Large catalogs use **`ItemsProvider`** retrieval Top-N instead (see Drop-Down data retrieval).
- On open, focus moves to the search box (type without an extra click).
- Clear: single-select control **×** clears Value; multi-select keeps per-chip × plus a control **×** that clears all Codes.
- Selected rows: bold + soft elevated/shadow highlight; left accent bar **1.5px**, soft-rounded (not full corner wrap); no list checkboxes for multi.
- Gallery seed (code-local): `DDL_0001`…`DDL_0150` / `Drop-Down List Value 001`…`150`.

### Label and chrome

Same as Text Field for editable chrome and deferred mandatory validation (invalid = input border only): shared label gap, md corner radius on the closed control. Multi-height fields: `BoRow` uses **`align-items: start`** when any child is multi/tall; single-line controls stay optically centered in their slot. See [layout.md — Row](../layout/layout.md#row-borow).

**Gallery reference:** Components Drop-Down List — Parameters: Mandatory / Disabled / DisplayCode / AllowMultiple / KeepOpen / ClearAfterSelect / Hide editable; Preview (editable + read-only + Backend Value); Settings dialog Language / Timezone rows. KeepOpen and ClearAfterSelect are disabled in Gallery when AllowMultiple is on.

These Drop-Down List rules are **org standards** for every `BoDropDownList` usage.

## People Picker (`BoPeoplePicker`)

**Display name:** People Picker.  
**Component:** `BoPeoplePicker` in [SYSTEM-SHARED-UI](https://github.com/Breeze-On/SYSTEM-SHARED-UI).

Platform-standard **user** selector for BreezeOn applications (group membership, ownership, approvers, assignees). Visually and behaviorally a specialized Drop-Down List (same sizing, label gap, mandatory asterisk, validation chrome, disabled/read-only, chips, popup, debounce). Composes `BoDropDownList`; public API remains `Bo*` only.

| Parameter | Role |
| --- | --- |
| `Label` / `FieldKey` | Same as Drop-Down List |
| `Value` / `ValueChanged` | `string?` — **UserGUID** (`"D"` format) single; when `AllowMultiple`, UserGUIDs joined by **`;`**. No typed `Guid` / collection bind API in V1 |
| `Required` / `Disabled` / `ReadOnly` / `AllowMultiple` | Same as Drop-Down List (`Required` = Mandatory; `AllowMultiple` = multi-select) |
| `Placeholder` | Default resource **`Field_PeoplePicker_Placeholder_Default`** ("Select a person"). Same override rules as Drop-Down List; **omitted when `Disabled`** — [ux-conventions.md](../patterns/ux-conventions.md) |
| `SearchDebounceMilliseconds` / `ProviderMaxItems` | Default 300 / **100** |
| `ItemsProvider` | Optional override (Gallery fake / host custom). When null, uses `IBoPeoplePickerQueries` |
| `ExcludeUserGuids` | Optional GUIDs excluded from search (serialized as JSON for the procedure) |
| `TenantId` | Optional Entra tenant filter for the default provider |
| `IsHidden` / `PreserveLayoutWhenHidden` / `Weight` / `ErrorText` / `ValidationGroup` | Standard field |

**Bound value rules**

- Persist **`UserGUID` only**. Never bind `UsersId`, Email, UPN, or `ExternalObjectId`.
- Display text: **`DisplayName (Email)`** with null-safe fallback (DisplayName → Email → UPN → GUID string).
- Search fields: DisplayName, Email, UserPrincipalName.
- **Active users only** (`Identity.Users.IsEnabled = 1`). The picker model does **not** expose `IsEnabled`. Disabled users are never returned; a bound GUID that is no longer enabled falls back to showing the raw GUID string.
- **No photos / avatars** in V1.

**Data contract**

- Procedure: `Identity.P_GET_UsersComponentValues` in SHARED-UI `sql/identity/current_model/` (applied into the customer database).
- This is a **documented one-off** platform exception for reusable user selection — **not** a `*ComponentValues` procedure family. Future lookup procedures are evaluated independently.
- Hard **TOP 100** at the database layer (`@MaxItems` clamped 1..100).
- `@ExcludeUserGuids` / `@ResolveUserGuids`: **JSON array of GUID strings only** (no CSV). Invalid JSON fails the call.
- C# adapter: `IBoPeoplePickerQueries` (`SearchAsync` / `ResolveAsync`) registered by `AddBreezeOnAuthentication`. Admin grid search (`IBoIdentityUserQueries`) remains separate.
- Gallery demos use an in-memory fake `ItemsProvider` (no database) — [example-governance.md](../example-governance.md).

**Gallery reference:** Components → People Picker — Parameters: Mandatory / Disabled / AllowMultiple / Hide editable; Preview (editable \| read-only \| Backend Value); Loading Sub with delayed fake provider.

## Filter execution (query-driven)

When Text Fields and Drop-Down Lists act as **filters** for a queryable dataset (typically a Filters section above a grid). Retrieval standard: [query-driven-retrieval.md](query-driven-retrieval.md) · [ADR-008](../../../decisions/ADR-008-query-driven-data-retrieval.md).

| Control | Execution |
| --- | --- |
| Text Field | Runs the query after **750ms debounce**, on **Enter**, or on **blur**. **Skip** when the value is unchanged since the last executed query. |
| Drop-Down List | Applies **on change** (immediately) |
| Apply button | **None** |
| Concurrency | **Latest-wins:** a new execution cancels the in-flight one; a stale response never updates the UI |

### Drop-Down data retrieval

| Source size | Standard | `BoDropDownList` API |
| --- | --- | --- |
| Small | **Preload** the full item list | `Items` |
| Large | **Top-N** + **server search** as the user types | **`ItemsProvider`** (`BoDropDownItemsRequest.SearchText` / `MaxItems`; default MaxItems **100**, configurable via `ProviderMaxItems`) |

- When `ItemsProvider` is non-null, it **wins** over `Items` for panel options. Static `Items` remain available for **selection display hydration** (lookup of preselected Codes not in the last Top-N page). Panel search is debounced (`SearchDebounceMilliseconds`, default 300) and cancels in-flight provider calls (latest-wins). While a provider call is in flight, the panel shows **Loading…** (`Field_DropDown_Loading`).
- Static `Items` panel search remains **client-side** (display Take cap in `BoDropDownSelection` — separate from retrieval Top-N).
- Prefer **EF Core / app-service FilterCatalog** queries for simple distinct catalogs; do not add a companion FilterOptions procedure by default ([database.md](../../database.md#query-driven-paged-list-stored-procedures)).
- Filter catalog loads must use latest-wins (`BoLatestWinsQuery`) so stale responses never replace dropdown items.
- Optional `EmptyText` overrides the empty-panel message (default em dash).

## Checkbox (`BoCheckbox`)

**Display name:** Checkbox.  
**Component:** `BoCheckbox` in [SYSTEM-SHARED-UI](https://github.com/Breeze-On/SYSTEM-SHARED-UI).

Boolean control: `Label` + `FieldKey` + `@bind-Value` (`bool`). Place as a direct child of `BoRow` when used in form layouts.

**Alignment (locked):** same vertical structure as Text Field — an **invisible label-height spacer** (always reserved) + a **control row**. The checkbox control aligns with the **input area** of a sibling `BoTextField` (control row `min-height` ~32px, vertically centered), not with the top of the field container.

| Parameter | Role |
| --- | --- |
| `Label` | Text **beside** the checkbox (body text, not field-label chrome). Spacer still reserves Text Field label height for row alignment |
| `FieldKey` | Stable typed DTO / entity property identifier (mapping metadata) |
| `Value` / `ValueChanged` | Two-way bind to a **typed `bool`** property |
| `Required` | **Mandatory** when editable — red asterisk after the beside-checkbox label; after Submit attempt, fails when **unchecked** (`Value == false`). Suppressed when `Disabled` or `ReadOnly` |
| `ValidationGroup` | Optional group for Submit validation |
| `Disabled` | Standard disabled chrome (editable mode only) |
| `ReadOnly` | Dual Yes/No display (exception to flat `BoFieldReadOnly`) |
| `ErrorText` | Host-supplied error: invalid outline on the checkbox control + error text; fails validation (same rule as other fields) |

### Editable

Control box is compact (~12px) with the label immediately to its **right** (not in the field-label row). Asterisk after the beside-checkbox label when `Required`. Invalid after attempt: danger outline on the **checkbox control** only (not the BoRow item container).

### Read-only (`ReadOnly`)

Same spacer + control-row structure. Always shows **two** options: localized **Yes** / **No** (`Field_Boolean_Yes` / `Field_Boolean_No`; FR Oui/Non). Exactly one option is checked to match `Value`. Not a plain text `BoFieldReadOnly`.

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
| `Placeholder` | Optional; default resource **`Field_Date_Placeholder_Default`** ("Select date") or **`Field_DateTime_Placeholder_Default`** ("Select date/time") when `Mode` is DateTime; **hidden when Disabled**; placeholder color matches Text/Number (Fluent `--colorNeutralForeground4`) |
| `ReadOnly` | Not editable (no calendar popover); no asterisk / required validation |

### Typed model / persistence (hard standard)

| Concern | Standard |
| --- | --- |
| Bound type | Always **`DateTime?`** on the typed DTO / entity / working model |
| Forbidden | **`DateOnly`**, `DateOnly?`, or binding the field to a date-only string property as the model type |
| Why | One persistence shape end-to-end; converting **from** `DateTime` (strip/ignore time) is easier than promoting a date-only value to datetime later |
| Date mode storage | Still a `DateTime`; control **normalizes time to midnight** (`00:00:00`, `DateTimeKind.Unspecified`) on every write |
| DateTime mode storage | `DateTime` with hour + minute (seconds cleared); `DateTimeKind.Unspecified` |
| Database | Prefer a datetime / datetime2 (nullable) column that matches the entity — do not use a date-only column for `BoDateField` bindings |
| Read-only display | Host may format a **short date** string for `BoFieldReadOnly` when the UX is date-only; that is display-only. Prefer **`BoDateDisplay.Format`** / **`FormatUtc`** with `Locale.FormatCulture` (+ timezone for UTC instants) — see [i18n.md](../foundations/i18n.md) |
| Backend Value (gallery) | Always shown as **date + time** (`g` / culture general) to prove the typed value is `DateTime?` even when `Mode` is Date |

Planning JSON: `control: "DateField"`; optional `mode: "Date"` \| `"DateTime"`. The generated property remains `DateTime?`.

### Value and locale

| Concern | Standard |
| --- | --- |
| Date mode | Calendar / typing collect a **date**; bound value is `DateTime` at midnight |
| DateTime mode | Date + hour/minute; culture-aware display (`g`). Panel time row: digit **hh** (0–12 with AM/PM, or 0–23 when culture is 24h) · digit **mm** (0–60, clamp overshoot to 60; stored minute 0–59) · **AM/PM** select when culture uses 12h (`AMDesignator` / `PMDesignator`). No native `<input type="time">`. |
| Autocomplete | Main text input and DateTime hour/minute/`select` use `autocomplete="off"` — [Browser autocomplete](#browser-autocomplete-locked) |
| Locale | Format + calendar month/weekday names from `IBoLocaleService` / `bo-culture` (**en-CA** / **fr-CA**) — same family as other i18n |
| Typing | Parse culture-formatted input on blur / Enter; invalid input reverts to last good value |

### Chrome and picker

| Concern | Standard |
| --- | --- |
| Label gap / corners / focus | Same as Text Field / DDL: **`--bo-field-label-gap`**, **`--bo-radius-md`**, hover + **full-border** focus (`--bo-color-field-border-focus`), themed caret/selection on the text input, field fill |
| Placeholder color | Same as Text Field / Number Field: Fluent **`--colorNeutralForeground4`** (not `--bo-color-text-muted`) |
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
| `Placeholder` | Optional; default resource **`Field_Number_Placeholder_Default`** ("Enter value"); **hidden when Disabled or ReadOnly** |
| `ReadOnly` | Not editable; no asterisk / required validation |
| `AutoComplete` | HTML autocomplete token. **Default `"off"`** — see [Browser autocomplete](#browser-autocomplete-locked) |

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
| Focus | Raw digits (+ `.` when decimals allowed); no thousand separators / affixes while editing; **native caret / selection** (same as Text Field — click places caret; drag / double-click / triple-click / Ctrl+A unchanged). Do **not** select-all on focus |
| Blur / unfocused | Culture number format (group separators + scale); currency symbol or `%` before/after per culture / catalog |
| Keystrokes | Non-numeric rejected; `IsInteger` blocks `.`; decimals clamped to `NumberOfDecimals` |
| Required | Asterisk immediate; red border + 10px error **after** validation attempt; live clear via `NotifyFieldChanged` |
| Percent range | Outside 0–100 (UI) uses the same deferred invalid chrome; keys `Validation_NumberPercentRange` / `Validation_NumberInvalid` |
| Currency catalog | Extend the **internal** `BoCurrencyCatalog` table in BreezeOn.UI when adding ISO codes (not a product-page concern) |

**Placement:** Direct child of `BoRow` inside a Section; participates in `BoValidationContext` / fail badges (`IBoValidatableField` + `IsInvalid`).

**Gallery reference:** Components Number Field — Parameters (Mandatory / Disabled / Hide Editable / Is Integer / Number of Decimals / Is Currency / Currency IsoCode / Is Percent / Alignment; pad to **6** slots per row) + Preview (editable \| host-formatted read-only \| **Backend Value** as persisted `decimal?`).

These Number Field rules are **org standards** for every `BoNumberField` usage.

## Button (`BoButton`)

**Component:** `BoButton` in [SYSTEM-SHARED-UI](https://github.com/Breeze-On/SYSTEM-SHARED-UI). Pill button; visual tokens in [tokens.md](../foundations/tokens.md).

| Parameter | Role |
| --- | --- |
| `Variant` | `BoButtonVariant`: `Primary` (default), `Secondary`, `Stealth` |
| `HtmlType` | `BoButtonType` enum: `Button` (default — does not submit a form), `Submit`, `Reset`. Replaces the former string `Type`; do not pass raw strings |
| `Disabled`, `OnClick`, `IconContent`, `ChildContent`, `Class`, `Style` | Standard button behavior |
| `BackgroundColor` / `ForegroundColor` | Optional overrides |
| `AdditionalAttributes` | Unmatched attributes are captured and forwarded |

**Label wrapping (platform rule):** button labels stay on **one line**. `.bo-button` / `.bo-button__label` use `white-space: nowrap`; the control uses `width: max-content` (+ `align-self: flex-start`) so it **hugs the label** and does not stretch to the `BoRow` / `BoField` slot. When placing a button in a narrow slot, raise `Weight` (or reduce competing columns) so the label is not clipped by `max-width: 100%`.

**Long-running operations:** \BoButton\ stays a button — no \IsBusy\ / embedded spinner API. Blocking UX for multi-second work uses **\IBoPageFreezeService\** from the click handler / workflow — [overlays.md](../shell/overlays.md).
