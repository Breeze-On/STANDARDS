# UI — Design tokens

Shell and accent tokens currently shipped by `BreezeOn.UI`. Related: [shell.md](shell.md), [navigation.md](navigation.md), [typography.md](typography.md), [forms.md](forms.md), [sections.md](sections.md), [overview.md](overview.md).

Configured via `BoThemeOptions` / `BoThemeProvider`. Font family: [typography.md](typography.md).

## Palette rules (locked)

1. **Canonical white / black** exist once: `color-semantic-white` (`#FFFFFF`) and `color-semantic-black` (`#000000`).
2. Roles that need pure white or black (**card fill**, **nav text**, **section / tab labels**, **primary button foreground**, etc.) **derive** from those tokens — do **not** invent parallel `#FFFFFF` / `#000000` requirements.
3. **`color-section-tab-label`** is the same underlying value as **`color-semantic-black`** (alias for documentation / Theme gallery).
4. **Any color not listed in this document** must **not** be introduced as a new hex requirement. Derive it from the tokens below (or from opacity / mix of an existing token). Update this file in the same change set when a new independent token is intentionally added.

## Color tokens (current)

| Internal code | CSS variable | Default | Description |
| --- | --- | --- | --- |
| `color-semantic-white` | `--bo-color-semantic-white` | `#FFFFFF` | Canonical white |
| `color-semantic-black` | `--bo-color-semantic-black` | `#000000` | Canonical black |
| `color-section-tab-label` | `--bo-color-section-tab-label` | *(alias → semantic black)* | Section headers; header-tab default text/icon |
| `color-text-field-label` | `--bo-color-text-field-label` | `#757575` | Text Field label (10px bold uppercase) |
| `color-background` | `--bo-color-background` | `#F6F7F8` | Page/canvas behind shell cards |
| `color-card-container-background` | `--bo-color-card-container-background` | *(derive → semantic white)* | Shell and content card fill |
| `color-card-container-border` | `--bo-color-card-container-border` | `#E8EDF1` | Light card / divider borders |
| `color-primary` | `--bo-color-primary` | `#224D3A` | Accent: nav panel fill, primary buttons |
| `color-primary-hover` | `--bo-color-primary-hover` | `#1A3A2C` | Primary button hover |
| `color-secondary` | `--bo-color-secondary` | `#7CF76C` | Secondary accent |
| `color-tertiary` | `--bo-color-tertiary` | `#D8F3DC` | Soft surface: selected nav, secondary buttons, tab fills |
| `color-text` | `--bo-color-text` | `#242424` | Default body text |
| `color-text-muted` | `--bo-color-text-muted` | `#616161` | Muted text (e.g. character count) |
| `color-danger` | `--bo-color-danger` | `#C50F1F` | Danger / mandatory asterisk |
| `color-success` | `--bo-color-success` | `#0E700E` | Success |
| `color-nav-text` | `--bo-color-nav-text` | *(derive → semantic white)* | Unselected nav text/icon |
| `color-nav-text-selected` | `--bo-color-nav-text-selected` | *(derive → semantic black)* | Selected nav text/icon |
| `color-nav-text-hover` | `--bo-color-nav-text-hover` | *(derive → semantic white)* | Unselected nav text on hover |
| `color-nav-hover-background` | `--bo-color-nav-hover-background` | `rgba(255,255,255,0.16)` | Unselected nav hover fill (**derived**: semantic white @ 16% opacity) |

Legacy aliases still emitted: `--bo-color-surface` → card-container-background; `--bo-color-surface-muted` → background; `--bo-color-border` → card-container-border; `--bo-color-nav-background` → primary; `--bo-color-nav-selected` → tertiary.

## Non-color shell tokens (current)

| Token name | CSS variable | Where used |
| --- | --- | --- |
| `card-container-shadow` | `--bo-shadow-card-container` | Card elevation |
| `shell-margin` | `--bo-space-shell-margin` | Slim margins on shell cards; **nav right margin is 0** |
| `content-card-margin` | `--bo-space-content-card-margin` | Larger margins for in-body content cards |
| `row-inset` | `--bo-space-row-inset` | Inside padding for `BoRow` and each field container (default `4px`) — see [layout.md](layout.md) |
| `row-gap` | `--bo-space-row-gap` | Gap between field containers in a `BoRow` (default `16px`) — see [layout.md](layout.md) |

Shared accents used by nav and buttons: `PrimaryColor` / `TertiaryColor`. Nav color rules: [navigation.md](navigation.md). Header tab fills: [shell.md](shell.md).

**Gallery:** Theme (`/theme`) tabs (order) — Primary, Secondary, Tertiary, Background, Border, Field Label. Each tab: Main Section `{Friendly Name} Color` (tab icon) containing Sub Sections **Attributes** (fields, no icon) and **Preview** (swatch, no icon). Main icons: Primary `PaintBrushSparkle` (Regular); Secondary `ColorFill` (Regular); Tertiary `Eyedropper` (Regular); Background `ImageBorder` (Filled); Border `BorderAll` (Regular — Fluent has no `Border` glyph); Field Label `TextCaseTitle` (Regular).
