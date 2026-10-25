# UI — Layout (Row + page composition)

Row layout and the Page → Section → Row → Field composition contract. Related: [sections.md](sections.md), [forms.md](forms.md), [tokens.md](tokens.md), [overview.md](overview.md).

## Page composition (locked — hard standard)

Canonical hierarchy for editable / form-style page content:

```text
Page → Body (BoAppShell body) → Section (BoSectionMain / BoSectionSub) → Row (BoRow) → Field container → Field (BoTextField / future Bo*)
```

| Layer | Component / concept | Role |
| --- | --- | --- |
| Section | `BoSectionMain` / `BoSectionSub` | Group related content; optional header — see [sections.md](sections.md) |
| Row | `BoRow` | One horizontal band of fields; equal-width slots; owns horizontal field layout |
| Field container | Direct child of `BoRow` (`.bo-row > *`) | Slot around one field (padding + separator target) |
| Field | `BoTextField` (etc.) | Control chrome + `@bind-Value` to typed working model — see [forms.md](forms.md) |

### Mandatory placement rules (agents and apps)

1. **Every form field** (`BoTextField` and future form `Bo*` controls) **must** be placed as a **direct child of a `BoRow`** (that child *is* the field container). Do not put fields as loose children of a Section body without a Row.
2. **Every `BoRow` must** live **inside a Section** (`BoSectionMain` or `BoSectionSub` content). Do not put Rows directly under the shell body without a Section.
3. Stack multiple Rows inside a Section with `BoStack Gap="0"` when vertical spacing should come only from section/row rules (not double gaps).
4. Stack multiple Sections with `BoStack Gap="0"` so section outside-bottom margins are not doubled.

**Do not** invent alternate per-page CSS grids or free-floating fields when this composition applies.

## Row (`BoRow`)

**Display name:** Row.  
**Component:** `BoRow` in [SYSTEM-SHARED-UI](https://github.com/Breeze-On/SYSTEM-SHARED-UI).

A **Row** is a layout container for one or more fields in a section. It standardizes **equal horizontal spread**: N **direct children** → N equal-width field containers. Each field fills its container (`width: 100%` of the slot).

| Concern | Standard |
| --- | --- |
| API | `ChildContent` (Option A) — not a `Fields` collection parameter |
| Children | Form fields (`BoTextField`, future `Bo*`) as **direct** children of `BoRow` |
| Columns | CSS grid: `grid-auto-flow: column`; `grid-auto-columns: 1fr` — 1 child = full width; 4 children = four equal columns |
| Field container | Each direct child of `BoRow` (`.bo-row > *`) |
| Row + container inside padding | **`--bo-space-row-inset`** (default **4px**) on all four sides — see [tokens.md](tokens.md) |
| Field container outside spacing | **`--bo-space-row-gap`** (default **16px**) `column-gap` between adjacent containers (no vertical separator between containers) |
| Field width | Control fills the field container width (`max-width` overridden inside a row; input stretches 100%) |

### Spacing tokens (change once, applies to Row + field container)

| Token | CSS variable | `BoThemeOptions` | Default | Used by |
| --- | --- | --- | --- | --- |
| `row-inset` | `--bo-space-row-inset` | `SpaceRowInset` | `4px` | Inside padding of `.bo-row` **and** each field container |
| `row-gap` | `--bo-space-row-gap` | `SpaceRowGap` | `16px` | Gap between field containers + separator centering |

To change inset globally (e.g. to `6px` or `8px`), set `BoThemeOptions.SpaceRowInset` / `--bo-space-row-inset` — do not hardcode per page.

**Gallery reference:** Theme (`/theme`) — Primary Color section: Row 1 = Hex Code + Internal Code; Row 2 = Description.

### Not shipped yet (do not invent)

- `columnCount` / reserved empty slots (“2 fields aligned as if 4 columns”)
- Dynamic hide/show column rules
- Separate `BoRowContainer` component type (container = direct child of `BoRow` today)

## Page composition JSON (planning-agent input)

**Purpose:** Humans and planning agents submit **structured page requirements** in JSON. Agents translate that JSON into Dev prompts / Razor that follow Breeze On UI standards (this file + sections + forms).

**Runtime note:** This JSON is a **requirements / planning** shape. It is **not** the Blazor working-model cache. Apps bind fields with `@bind-Value` to a **typed DTO / entity**. Each field’s `fieldKey` is mapping metadata for that property. Persistence JSON (if any) is an application concern outside SHARED-UI.

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
| `fields` | array | Yes | Ordered fields; **length N** → N equal `BoRow` columns / containers |

### Field object (schemaVersion 1)

| Field | Type | Required | Meaning |
| --- | --- | --- | --- |
| `control` | string | Yes | `"TextField"` → `BoTextField` (extend when new controls ship) |
| `label` | string | Yes | Field label |
| `fieldKey` | string | Yes | Stable DTO / working-model property id (`FieldKey` / `@bind-Value` target) |
| `required` | boolean | No | Default false → `Required` / Mandatory asterisk |
| `maxLength` | number | No | Default **600** for Text Field |
| `showCharacterCount` | boolean | No | Default false |
| `placeholder` | string | No | Optional |
| `disabled` | boolean | No | Default false |

Future (not in v1 — do not emit until STANDARDS says shipped): `columnCount`, visibility flags, empty reserved slots.

### Translation rules (JSON → Razor)

| JSON | Razor / standard |
| --- | --- |
| `sections[].kind: "main"` / `"sub"` | `BoSectionMain` / `BoSectionSub` |
| `sections[].title` / `icon` | `Title` + optional `IconContent` (`BoIcon`) |
| `sections[].rows[]` | one `BoRow` **inside that Section** each |
| `rows[].fields[]` length N | N **direct** children of that `BoRow` (each child = field container + field) |
| `control: "TextField"` | `BoTextField` with `Label`, `FieldKey`, `Required`, `MaxLength`, `ShowCharacterCount`, … + `@bind-Value` to the typed property for `fieldKey` |
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

Expected layout: Row 1 → two equal columns with 16px gap + separator; Row 2 → one full-width field. Both Rows inside the Identification Section.

### Example — Theme Primary Color (gallery)

Main Section `{Name} Color` contains Sub Sections **Attributes** (fields) and **Preview** (gallery swatch; no icon). Nested `sections` under a parent is not in schemaVersion `"1"` — Dev maps Attributes rows under a `kind: "sub"` sibling group inside the main section body, or uses two top-level sections when emitting flat JSON. Gallery Razor nests `BoSectionSub` inside `BoSectionMain`.

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
      "title": "Primary Color",
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
              "control": "TextField",
              "label": "Hex Code",
              "fieldKey": "ColorHexCodePrimary",
              "required": true,
              "showCharacterCount": true
            },
            {
              "control": "TextField",
              "label": "Internal Code",
              "fieldKey": "PrimaryColorInternalCode",
              "required": true,
              "showCharacterCount": true
            }
          ]
        },
        {
          "fields": [
            {
              "control": "TextField",
              "label": "Description",
              "fieldKey": "Description",
              "required": true,
              "maxLength": 1000,
              "showCharacterCount": true
            }
          ]
        }
      ]
    }
  ]
}
```

(Preview Sub Section with a non-`Bo*` swatch is gallery-only and is outside this field schema.)
