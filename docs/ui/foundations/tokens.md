# UI — Design tokens

Owner: UI

Shell and accent tokens currently shipped by `BreezeOn.UI`. Related: [shell.md](../shell/shell.md), [navigation.md](../shell/navigation.md), [typography.md](typography.md), [forms.md](../controls/forms.md), [sections.md](../layout/sections.md), [overview.md](../overview.md).

Configured via `BoThemeOptions` / `BoThemeProvider` / `IBoThemeModeService`. Font family: [typography.md](typography.md).

## Theme mode (locked)

- **Dual palettes, one semantic name per role.** CSS variables stay `--bo-color-primary` (etc.). Do **not** use `*-light` / `*-dark` suffixes on token names or markup.
- `BoThemeMode` = `Light` | `Dark`. `IBoThemeModeService` applies `BoThemePalettes.Light` / `.Dark` onto the active `BoThemeOptions`.
- **Cookie persistence (shipped):** name `bo-theme-mode`; values `light` \| `dark` (lowercase); `Path=/`; `Max-Age≈31536000` (1 year); `SameSite=Lax`; `Secure` when the page is HTTPS; `HttpOnly=false` (JS-readable for Interactive Server restore). Invalid/missing → **Light**. `BoProviders` hosts `BoThemeModeBootstrap` which calls `InitializeAsync()` once per circuit. Hosts should load `_content/BreezeOn.UI/js/bo-theme-mode.js` early (gallery `App.razor` does) so `document.documentElement.dataset.boThemeMode` can be set from the cookie on `<html>` before circuit restore. **FOUC is not fixed by this:** token values (palette colors, structural tokens) are still emitted inline by `BoThemeProvider` from `IBoThemeModeService.Active`, and `.bo-theme-root[data-bo-theme-mode]` follows the service mode — so the shell can still paint Light until the circuit restores the cookie. The early dataset only helps `html`-level consumers; it does not apply tokens.
- Gallery Theme (`/theme`) shows **both** Light and Dark palette values as read-only fields (`BoFieldReadOnly`) under separate Main Sections. It does not live-recolor the shell; the header theme switch does.

## Palette rules (locked)

1. **Canonical white / black** exist once: `color-semantic-white` (`#FFFFFF`) and `color-semantic-black` (`#000000`) in both modes.
2. Light mode: roles that need pure white or black (**card fill**, **nav text**, **section labels**, etc.) match semantic white/black.
3. Dark mode: surfaces and labels that are not pure white/black use **independent** palette values (e.g. dark card fill, light section labels). Do not invent parallel pure `#FFFFFF` / `#000000` tokens.
4. **Any color not listed in this document** must **not** be introduced as a new hex requirement. Update this file in the same change set when a new independent token is intentional.

## Color tokens (current)

| Internal code | CSS variable | Light default | Dark default | Description |
| --- | --- | --- | --- | --- |
| `color-semantic-white` | `--bo-color-semantic-white` | `#FFFFFF` | `#FFFFFF` | Canonical white |
| `color-semantic-black` | `--bo-color-semantic-black` | `#000000` | `#000000` | Canonical black |
| `color-section-tab-label` | `--bo-color-section-tab-label` | `#000000` | `#F2F5F3` | Section headers; header-tab default text/icon |
| `color-text-field-label` | `--bo-color-text-field-label` | `#757575` | `#A8B2AC` | Text Field label (10px bold uppercase) |
| `color-field-background` | `--bo-color-field-background` | `#FFFFFF` | `#252D29` | Text Field input fill |
| `color-background` | `--bo-color-background` | `#F6F7F8` | `#121614` | Page/canvas behind shell cards |
| `color-card-container-background` | `--bo-color-card-container-background` | `#FFFFFF` | `#1E2622` | Shell and content card fill |
| `color-card-container-border` | `--bo-color-card-container-border` | `#E8EDF1` | `#4A5650` | Card / divider borders |
| `color-primary` | `--bo-color-primary` | `#224D3A` | `#2D5A45` | Accent: nav panel fill, primary buttons |
| `color-primary-hover` | `--bo-color-primary-hover` | `#1A3A2C` | `#3A6F56` | Primary button hover |
| `color-secondary` | `--bo-color-secondary` | `#7CF76C` | `#7CF76C` | Secondary accent |
| `color-tertiary` | `--bo-color-tertiary` | `#D8F3DC` | `#3D5C4A` | Soft surface: secondary buttons, tab fills (not selected nav) |
| `color-nav-selected` | `--bo-color-nav-selected` | `#D8F3DC` | `#D8F3DC` | Selected left-nav item fill — **same as Light tertiary in both modes** |
| `color-nav-logo-divider` | `--bo-color-nav-logo-divider` | `#E8EDF1` | `#E8EDF1` | Horizontal rule under nav brand logos — **same as Light card-container-border in both modes** |
| `color-text` | `--bo-color-text` | `#242424` | `#EEF2EF` | Default body text |
| `color-text-muted` | `--bo-color-text-muted` | `#616161` | `#A8B2AC` | Muted text (e.g. character count) |
| `color-danger` | `--bo-color-danger` | `#C50F1F` | `#FF8A8A` | Danger / mandatory asterisk |
| `color-success` | `--bo-color-success` | `#0E700E` | `#4ADE80` | Success |
| `color-warning` | `--bo-color-warning` | `#C19C00` | `#C19C00` | Alert toast accent / badge gradient |
| `color-info` | `--bo-color-info` | `#0078D4` | `#0078D4` | Information accent (Information toasts) |
| `color-overlay-scrim` | `--bo-color-overlay-scrim` | `rgba(0,0,0,0.35)` | `rgba(0,0,0,0.35)` | Modal / profile-menu scrim |
| `color-nav-text` | `--bo-color-nav-text` | `#FFFFFF` | `#FFFFFF` | Unselected nav text/icon |
| `color-nav-text-selected` | `--bo-color-nav-text-selected` | `#000000` | `#000000` | Selected nav text/icon (black on light selected fill) |
| `color-nav-text-hover` | `--bo-color-nav-text-hover` | `#FFFFFF` | `#FFFFFF` | Unselected nav text on hover |
| `color-nav-hover-background` | `--bo-color-nav-hover-background` | `rgba(255,255,255,0.16)` | `rgba(255,255,255,0.12)` | Unselected nav hover fill |

Legacy aliases still emitted: `--bo-color-surface` → card-container-background; `--bo-color-surface-muted` → background; `--bo-color-border` → card-container-border; `--bo-color-nav-background` → primary.

**Nav-stable tokens:** `color-nav-selected` and `color-nav-logo-divider` do **not** follow Dark `color-tertiary` / `color-card-container-border`. They keep Light values so selected page fill and the brand logo divider match Light chrome in Dark mode.

## Non-color shell tokens (current)

| Token name | CSS variable | Where used |
| --- | --- | --- |
| `card-container-shadow` | `--bo-shadow-card-container` | Card elevation (palette may vary shadow by mode) |
| `shell-margin` | `--bo-space-shell-margin` | Slim margins on shell cards; **nav right margin is 0** |
| `content-card-margin` | `--bo-space-content-card-margin` | Larger margins for in-body content cards |
| `row-inset` | `--bo-space-row-inset` | Inside padding for `BoRow` and each field container (default `4px`) — see [layout.md](../layout/layout.md) |
| `row-gap` | `--bo-space-row-gap` | Gap between field containers in a `BoRow` (default `16px`) — see [layout.md](../layout/layout.md) |

### Layering and focus tokens (current)

Emitted by `BoThemeProvider` (fixed values; not `BoThemeOptions` properties):

| CSS variable | Value | Used for |
| --- | --- | --- |
| `--bo-z-profile-scrim` | `900` | Profile menu scrim |
| `--bo-z-profile-menu` | `901` | Profile menu panel |
| `--bo-z-dialog` | `1000` | Dialog / Settings overlay |
| `--bo-z-popup-backdrop` | `9998` | `BoDropDownList` / `BoDateField` popup backdrop |
| `--bo-z-popup` | `10000` | Popup panel (above dialogs) |
| `--bo-z-toast` | `11000` | Toasts (top layer) |
| `--bo-focus-ring` | `0 0 0 2px var(--bo-color-primary)` | Shared keyboard focus ring on interactive controls |

## Theme options (`AddBreezeOnUI(configureTheme)`)

`AddBreezeOnUI(opts => …)` registers `IOptions<BoThemeOptions>`; `IBoThemeModeService` reads it and re-applies it after every palette switch (Light ↔ Dark).

| Option group | Behavior |
| --- | --- |
| **Structural** (font family, radii, spacing, row inset/gap, shell/content margins, nav widths, card border width) | **Always applied** in both modes |
| `ColorWarning`, `ColorInfo` | Applied in both modes when non-empty |
| **Light accents** (`ColorPrimary`, `ColorPrimaryHover`, `ColorSecondary`, `ColorTertiary`) | Applied in **Light** only, and only when the value **differs** from the Light palette default (hex compare, case-insensitive). Setting a value equal to the default is a no-op. `ColorPrimaryHover` applies only together with a customized `ColorPrimary` (blank hover → falls back to `ColorPrimary`) |
| **Dark accents** (`ColorPrimaryDark`, `ColorPrimaryHoverDark`, `ColorSecondaryDark`, `ColorTertiaryDark`) | Applied in **Dark** only, when set. `ColorPrimaryHoverDark` blank → hover uses `ColorPrimaryDark`. When unset, Dark keeps the Dark palette accents. Light accent options never leak into Dark |
| Other color properties (backgrounds, text, nav, card, border, danger, success, scrim, …) | Come from the Light/Dark **palette**, not from `configureTheme` |

The `*Dark` names exist only as **option properties**; CSS variable names stay mode-agnostic (`--bo-color-primary`). Without `configureTheme`, the Light and Dark palettes apply unchanged.

Shared accents used by nav and buttons: `PrimaryColor` / `TertiaryColor`. Nav color rules: [navigation.md](../shell/navigation.md). Header tab fills: [shell.md](../shell/shell.md).

**Gallery:** Theme (`/theme`) tabs (order) — Primary, Secondary, Tertiary, Background, Border, Field Label. Each tab stacks two Main Sections: `{Friendly Name} Color (Light Theme)` then `{Friendly Name} Color (Dark Theme)` (same tab icon on each). Each Main contains Sub **Attributes** (`BoFieldReadOnly` Hex / Internal Code / Description; FieldKeys suffixed `Light` / `Dark`) and Sub **Preview** (swatch). Values come from `BoThemePalettes.Light` / `.Dark` (not the active shell mode). Main icons: Primary `PaintBrushSparkle` (Regular); Secondary `ColorFill` (Regular); Tertiary `Eyedropper` (Regular); Background `ImageBorder` (Filled); Border `BorderAll` (Regular — Fluent has no `Border` glyph); Field Label `TextCaseTitle` (Regular).
