# UI — Forms

Form control standards. Related: [layout.md](layout.md) (Row + page composition JSON), [sections.md](sections.md), [typography.md](typography.md), [tokens.md](tokens.md), [overview.md](overview.md).

**Hard standard:** every Text Field (and future form controls) **must** be a direct child of a [`BoRow`](layout.md#row-borow), and that Row **must** sit inside a Section. See [layout.md — Page composition](layout.md#page-composition-locked--hard-standard).

## Text Field (`BoTextField`)

**Display name:** Text Field.  
**Component:** `BoTextField` in [SYSTEM-SHARED-UI](https://github.com/Breeze-On/SYSTEM-SHARED-UI).

Apps bind values with `@bind-Value` to a **typed DTO / working-model property**. The control does not own persistence or JSON transport.

| Parameter | Role |
| --- | --- |
| `Label` | Field label text |
| `FieldKey` | Stable typed DTO / entity property identifier (mapping metadata only; does **not** replace `@bind-Value`) |
| `Required` | **Mandatory** — when true, UI shows a red asterisk after the label |
| `MaxLength` | Maximum characters (enforced on the input). **Default 600** |
| `ShowCharacterCount` | When true, shows `current/max` inside the input on the right. **Default false** |
| `Value` / `ValueChanged` | Two-way bind to the working model |
| `Placeholder`, `Disabled`, `ErrorText` | Standard field chrome |

### Label and chrome

| Concern | Standard |
| --- | --- |
| Label font | **10px**, **bold**, **uppercase**; color `--bo-color-text-field-label` (`color-text-field-label`, default `#757575`) — see [tokens.md](tokens.md) |
| Label-to-input gap | Minimal (~0-1px) |
| Input typed text | **Calibri** (`--bo-font-family`); **14px** — see [typography.md](typography.md) |
| Mandatory mark | When `Required`: bold red `*` after the label; modest gap before the star (`margin-left` ~0.2em); color `--bo-color-danger` |
| Rest border / outline | Grey using `--bo-color-card-container-border` |
| Focus | Recolor Fluent’s **native** bottom focus border to **primary** (`--bo-color-primary`) so it stays on the control edge and keeps rounded corners; not Fluent blue; do **not** add a separate underline below the field |
| Character count | Optional (`ShowCharacterCount`, default false); format `current/max` (no brackets); **inside** the input (Fluent `EndTemplate`), trailing/right; italic **10px**; muted. Denominator = `MaxLength` (**default 600**) |

**Gallery reference:** Theme (`/theme`) color tabs (fields inside `BoRow`s); Components Text Field playground.

These Text Field rules are **org standards** for every `BoTextField` usage.
