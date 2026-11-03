# UI — Layout (Row + page composition)

Owner: UI

Row layout and the Page → Section → Row → Field composition contract. Related: [sections.md](sections.md), [forms.md](../controls/forms.md), [tokens.md](../foundations/tokens.md), [overview.md](../overview.md).

## Page composition (locked — hard standard)

Canonical hierarchy for editable / form-style page content:

```text
Page → Body (BoAppShell body) → Section (BoSectionMain / BoSectionSub) → Row (BoRow) → Field container → Field (BoTextField / future Bo*)
```

| Layer | Component / concept | Role |
| --- | --- | --- |
| Section | `BoSectionMain` / `BoSectionSub` | Group related content; optional header — see [sections.md](sections.md) |
| Row | `BoRow` | One horizontal band of fields; **proportional Weight** slots; owns horizontal field layout |
| Field container | Direct child of `BoRow` (`.bo-row > *`) | Slot around one field (padding + separator target) |
| Field | `BoTextField` / `BoFieldReadOnly` (etc.) | Editable control chrome + `@bind-Value`, or read-only pre-formatted `Value` — see [forms.md](../controls/forms.md) |

### Mandatory placement rules (agents and apps)

1. **Every form field** (`BoTextField`, `BoFieldReadOnly`, and future form `Bo*` controls) **must** be placed as a **direct child of a `BoRow`** (that child *is* the field container). Do not put fields as loose children of a Section body without a Row.
2. **Every `BoRow` must** live **inside a Section** (`BoSectionMain` or `BoSectionSub` content). Do not put Rows directly under the shell body without a Section.
3. Stack multiple Rows inside a Section with `BoStack Gap="0"` when vertical spacing should come only from section/row rules (not double gaps).
4. Stack multiple Sections with `BoStack Gap="0"` so section outside-bottom margins are not doubled.

**Do not** invent alternate per-page CSS grids or free-floating fields when this composition applies. Prefer `Weight` / `IsHidden` / `PreserveLayoutWhenHidden` over page-specific width CSS.

## Row (`BoRow`)

**Display name:** Row.  
**Component:** `BoRow` in [SYSTEM-SHARED-UI](https://github.com/Breeze-On/SYSTEM-SHARED-UI).

A **Row** is a layout container for one or more fields in a section. Horizontal sizing uses **proportional Weight** on each layout-participating direct child. Each field fills its container (`width: 100%` of the slot).

### Weight (organization standard)

Approved field API (on every BoRow field-slot control):

```csharp
public int Weight { get; set; } = 1;
```

- **Default `Weight = 1`** → equal distribution when no weights are overridden.
- **Share** = `Weight ÷ Sum(Weights of layout-participating children)`.
- **Not a 12-column grid.** `Weight = 4` means “four relative shares,” not “4 of 12 fixed columns.”
- **Approved name:** `Weight`. Do **not** invent `Span`, `ColumnSpan`, `Width`, `WidthPercentage`, or `GridColumn` for BoRow sizing.

Examples:

| Weights | Shares |
| --- | --- |
| 1 + 1 + 1 | 33.33% / 33.33% / 33.33% |
| 2 + 1 | 66.67% / 33.33% |
| 3 + 2 + 1 | 50% / 33.33% / 16.67% |
| 4 + 1 + 1 | 66.67% / 16.67% / 16.67% |
| 4 + 2 + 2 | 50% / 25% / 25% |

Implementation (SHARED-UI): flex row; each child sets `--bo-row-weight`; `flex: var(--bo-row-weight, 1) 1 0%`.

Do **not** pad a single full-width field with `BoEmptyField` siblings — that shrinks the field by those Weights. Put that field alone in the `BoRow`.

| Concern | Standard |
| --- | --- |
| API | `ChildContent` (Option A) — not a `Fields` collection parameter |
| Children | Form fields (`BoTextField`, future `Bo*`) as **direct** children of `BoRow` |
| Columns | CSS flex: proportional `--bo-row-weight` shares (default 1 → equal) |
| Field container | Each direct child of `BoRow` (`.bo-row > *`) |
| Field `Weight` | Default **1**; clamp below 1 → 1 |
| Row + container inside padding | **`--bo-space-row-inset`** (default **4px**) on all four sides — see [tokens.md](../foundations/tokens.md) |
| Field container outside spacing | **`--bo-space-row-gap`** (default **16px**) `column-gap` between adjacent containers |
| Field width | Control fills the field container width (`max-width` overridden inside a row; input stretches 100%) |
| Vertical align | Default: start-align field containers. When any child is a **multi-select or tall** Drop-Down List (`AllowMultiple` / multi read-only), the Row keeps **`align-items: start`** so chips/lines top-align |

### Spacing tokens (change once, applies to Row + field container)

| Token | CSS variable | `BoThemeOptions` | Default | Used by |
| --- | --- | --- | --- | --- |
| `row-inset` | `--bo-space-row-inset` | `SpaceRowInset` | `4px` | Inside padding of `.bo-row` **and** each field container |
| `row-gap` | `--bo-space-row-gap` | `SpaceRowGap` | `16px` | Gap between field containers + separator centering |

To change inset globally (e.g. to `6px` or `8px`), set `BoThemeOptions.SpaceRowInset` / `--bo-space-row-inset` — do not hardcode per page.

**Gallery reference:** Theme (`/theme`) — Primary Color rows; Components Text Field → **Row layout (Weight)** demos (`4+1+1`, `2+1`, collapse vs preserve).

### Hidden fields and layout preservation (organization standard)

Approved field API:

```csharp
public bool IsHidden { get; set; }
public bool PreserveLayoutWhenHidden { get; set; } = false;
```

**Approved name:** `PreserveLayoutWhenHidden` (UX intent: alignment / stability). Do **not** prefer KeepWeightWhenHidden / PreserveWeight / RetainWeight / KeepSpace.

| Mode | Parameters | Layout | Weight |
| --- | --- | --- | --- |
| **Default (org standard)** | `IsHidden=true`, `PreserveLayoutWhenHidden=false` | Collapses (`display: none`); siblings redistribute | **Ignored** (not in sum) |
| **Exception** | `IsHidden=true`, `PreserveLayoutWhenHidden=true` | Reserved (`visibility: hidden`); siblings do not shift | **Participates** |
| Visible | `IsHidden=false` | Normal | Participates |

**Example A — collapse (default):** `Weight=4`, `IsHidden=true`, `PreserveLayoutWhenHidden=false` → Weight removed from calculations; remaining controls redistribute.

**Example B — preserve:** `Weight=4`, `IsHidden=true`, `PreserveLayoutWhenHidden=true` → Weight kept; layout remains stable when visibility toggles.

**Use preserve when:** multi-row column alignment, dynamic/conditional controls, or any case where reflow would be disruptive.

**Prefer default collapse** otherwise. Challenge unnecessary `PreserveLayoutWhenHidden`. Document intentional exceptions.

| Surface | Standard |
| --- | --- |
| `IsHidden` (default) | Chrome hidden; layout collapses; Weight ignored; skips required validation |
| `PreserveLayoutWhenHidden` | Only meaningful while `IsHidden`; reserves slot + Weight |
| `BoEmptyField` | Permanent empty alignment slot (no label/value); still has `Weight` (default 1). Prefer for structural holes; prefer preserve-hidden for temporary hide |

Components stay mounted while hidden (state / binding / validation). Do **not** invent page CSS for hide/width when these APIs apply.

### Migration (from pre-Weight / always-reserve IsHidden)

Older SHARED-UI treated every `IsHidden` as a reserved slot. That legacy behavior is **removed** from the framework (no compatibility mode).

1. Ship default collapse immediately.
2. Audit all `IsHidden` call sites.
3. Where reserved space is intentional, set `PreserveLayoutWhenHidden="true"`.
4. Confirm screens still behave as intended after migration.

### Not shipped / not approved

- `columnCount` as a separate `BoRow` parameter
- Separate `BoRowContainer` / `BoRowItem` wrapper (container = direct child of `BoRow` today)
- Fixed 12-column Span naming for BoRow

### Developer guidance

- Omit `Weight` when equal shares are fine (default 1).
- Map “twice as wide” / “large search field” / “4 items wide” (relative) to proportional `Weight`.
- Do not use custom CSS widths for BoRow children.

### Planning Agent guidance

- Assume `Weight=1` and `PreserveLayoutWhenHidden=false` when unspecified.
- Use proportional Weight whenever a field should be wider/narrower than neighbors.
- Prefer collapse for hidden fields; recommend `PreserveLayoutWhenHidden` only when alignment, visual stability, dynamic visibility, or multi-row consistency requires reserved space.
- Challenge custom CSS and unnecessary preserve flags; document approved exceptions.
- If a requirement conflicts with this standard: challenge → explain tradeoffs → if overridden, implement and document the deviation.

## Page composition JSON (planning-agent input)

**Purpose:** Humans and planning agents submit **structured page requirements** in JSON. Agents translate that JSON into Dev prompts / Razor that follow Breeze On UI standards (this file + sections + forms).

**Runtime note:** This JSON is a **requirements / planning** shape. It is **not** the Blazor working-model cache. Apps bind fields with `@bind-Value` to a typed DTO / entity. Each field’s `fieldKey` is mapping metadata for that property. Persistence JSON (if any) is an application concern outside SHARED-UI.

### Schema version

| Field | Required | Meaning |
| --- | --- | --- |
| `schemaVersion` | Yes | Composition schema version. Current: `"1"` |

### Top level

| Field | Type | Required | Meaning |
| --- | --- | --- | --- |
| `schemaVersion` | string | Yes | `"1"` |
| `page` | object | Recommended | Page metadata |
| `page.route` | string | Optional | Route path (e.g. `/theme`) |
| `page.title` | string | Optional | Page title |
| `sections` | array | Yes | Ordered sections |

### Section object

| Field | Type | Required | Meaning |
| --- | --- | --- | --- |
| `kind` | string | Yes | `"main"` → `BoSectionMain`; `"sub"` → `BoSectionSub` |
| `title` | string | Optional | Section header label |
| `icon` | object | Optional | `{ "name": "<FluentSystemIconName>", "variant": "Regular" \| "Filled" }` via `BoIcon` |
| `rows` | array | Yes | Ordered rows (each row becomes a `BoRow`; fields in a row become direct children / field containers) |

### Row object

| Field | Type | Required | Meaning |
| --- | --- | --- | --- |
| `fields` | array | Yes | Ordered fields; each may set `weight` (default 1) for proportional shares |

### Field object (schemaVersion 1)

| Field | Type | Required | Meaning |
| --- | --- | --- | --- |
| `control` | string | Yes | `"TextField"` → `BoTextField`; `"ReadOnlyField"` → `BoFieldReadOnly`; `"EmptyField"` → `BoEmptyField`; `"DateField"` → `BoDateField`; `"NumberField"` → `BoNumberField` |
| `label` | string | Yes* | Field label (*omit / unused for `EmptyField`) |
| `fieldKey` | string | Yes* | Stable DTO / working-model property id (*omit for `EmptyField`) |
| `required` | boolean | No | Default false → `Required` / Mandatory asterisk |
| `maxLength` | number | No | Default **600** for Text Field |
| `showCharacterCount` | boolean | No | Default false |
| `placeholder` | string | No | Optional |
| `disabled` | boolean | No | Default false |
| `hidden` | boolean | No | Default false → `IsHidden` (collapses layout unless preserve) |
| `preserveLayoutWhenHidden` | boolean | No | Default false → `PreserveLayoutWhenHidden` |
| `weight` | number | No | Default **1** → `Weight` (proportional share) |
| `mode` | string | No | Date Field only: `"Date"` (default) or `"DateTime"` → `BoDateField.Mode` |
| `isInteger` | boolean | No | Number Field only: blocks decimals |
| `numberOfDecimals` | number | No | Number Field only: scale when not integer (default 0) |
| `isCurrency` | boolean | No | Number Field only; mutually exclusive with `isPercent` |
| `currencyIsoCode` | string | No | Number Field only: `CAD` / `USD` / `GBP` when `isCurrency` |
| `isPercent` | boolean | No | Number Field only; UI 0–100, bind ÷100; mutually exclusive with `isCurrency` |
| `alignment` | string | No | Number Field only: `"Left"` \| `"Center"` \| `"Right"` (default `"Right"`) |

### Translation rules (JSON → Razor)

| JSON | Razor / standard |
| --- | --- |
| `sections[].kind: "main"` / `"sub"` | `BoSectionMain` / `BoSectionSub` |
| `sections[].sectionKey` | `SectionKey` (validation ancestry / fail badge) |
| `sections[].title` / `icon` | `Title` + optional `IconContent` (`BoIcon`) |
| `sections[].rows[]` | one `BoRow` **inside that Section** each |
| `rows[].fields[]` | **direct** children of that `BoRow` (each child = field container + field) |
| `control: "TextField"` | `BoTextField` with `Label`, `FieldKey`, `Required`, `MaxLength`, `ShowCharacterCount`, … + `@bind-Value` to the typed property for `fieldKey` |
| `control: "ReadOnlyField"` | `BoFieldReadOnly` with `Label`, `FieldKey`, pre-formatted `Value` (host formats; no Required/validation) |
| `control: "EmptyField"` | `BoEmptyField` (alignment slot only) |
| `control: "DateField"` | `BoDateField` with `Label`, `FieldKey`, `Required`, optional `Mode` (`Date` / `DateTime`) + `@bind-Value` (**`DateTime?` only** — never `DateOnly`; Date mode → midnight) |
| `control: "NumberField"` | `BoNumberField` with `Label`, `FieldKey`, `Required`, optional `isInteger` / `numberOfDecimals` / `isCurrency` / `currencyIsoCode` / `isPercent` / `alignment` + `@bind-Value` (**`decimal?` only**; percent UI 0–100 → bind ÷100) |
| `weight` (when ≠ 1) | `Weight="N"` on the field |
| `hidden: true` | `IsHidden="true"` (collapses unless preserve) |
| `preserveLayoutWhenHidden: true` | `PreserveLayoutWhenHidden="true"` |
| Multiple sections | Wrap in `BoStack Gap="0"` |
| Multiple rows in a section | Wrap rows in `BoStack Gap="0"` inside the Section body |

### Example — Identification (two rows)

```json
{
  "schemaVersion": "1",
  "page": {
    "route": "/example",
    "title": "Example"
  },
  "sections": [
    {
      "kind": "main",
      "title": "Identification",
      "icon": { "name": "Document", "variant": "Regular" },
      "rows": [
        {
          "fields": [
            {
              "control": "TextField",
              "label": "Request Number",
              "fieldKey": "RequestNumber",
              "required": true,
              "maxLength": 600,
              "showCharacterCount": false
            },
            {
              "control": "TextField",
              "label": "Status",
              "fieldKey": "Status",
              "required": false
            }
          ]
        },
        {
          "fields": [
            {
              "control": "TextField",
              "label": "Additional Comments",
              "fieldKey": "AdditionalComments",
              "required": false
            }
          ]
        }
      ]
    }
  ]
}
```

Expected layout: Row 1 → two equal columns (`Weight` default 1) with 16px gap; Row 2 → one full-width field. Both Rows inside the Identification Section.

### Example — Filters with Weight 3+1+1

```json
{
  "schemaVersion": "1",
  "page": { "route": "/applications", "title": "Applications" },
  "sections": [
    {
      "kind": "main",
      "title": "Filters",
      "rows": [
        {
          "fields": [
            { "control": "TextField", "label": "Keyword", "fieldKey": "Keyword", "weight": 3 },
            { "control": "TextField", "label": "Code", "fieldKey": "CodeFilter" },
            { "control": "TextField", "label": "Description", "fieldKey": "DescriptionFilter" }
          ]
        }
      ]
    }
  ]
}
```

Expected: Keyword ≈ 60%; Code / Description ≈ 20% each.

### Example — Theme Primary Color Light (gallery)

Each Theme color tab stacks Main `{Name} Color (Light Theme)` then Main `{Name} Color (Dark Theme)`. Nested `sections` under a parent is not in schemaVersion `"1"` — Gallery Razor nests `BoSectionSub` inside each `BoSectionMain`. Attributes use `BoFieldReadOnly` (`control: "ReadOnlyField"`).

```json
{
  "schemaVersion": "1",
  "page": {
    "route": "/theme",
    "title": "Theme"
  },
  "sections": [
    {
      "kind": "main",
      "title": "Primary Color (Light Theme)",
      "icon": { "name": "PaintBrushSparkle", "variant": "Regular" },
      "rows": []
    },
    {
      "kind": "sub",
      "title": "Attributes",
      "rows": [
        {
          "fields": [
            {
              "control": "ReadOnlyField",
              "label": "Hex Code",
              "fieldKey": "ColorHexCodePrimaryLight"
            },
            {
              "control": "ReadOnlyField",
              "label": "Internal Code",
              "fieldKey": "PrimaryColorInternalCodeLight"
            }
          ]
        },
        {
          "fields": [
            {
              "control": "ReadOnlyField",
              "label": "Description",
              "fieldKey": "DescriptionPrimaryLight"
            }
          ]
        }
      ]
    }
  ]
}
```

(Dark Theme Main uses the same shape with `…Dark` FieldKeys. Preview Sub Section with a non-`Bo*` swatch is gallery-only and is outside this field schema.)
