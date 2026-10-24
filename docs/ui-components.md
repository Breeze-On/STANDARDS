# UI component standards

Shared UI conventions for Breeze On applications.

## Shared library (current)

| | |
| --- | --- |
| Repository | [Breeze-On/SYSTEM-SHARED-UI](https://github.com/Breeze-On/SYSTEM-SHARED-UI) |
| Package / project | `BreezeOn.UI` (`src/BreezeOn.UI`) |
| Approach | Option B+: BreezeOn public API on top of Fluent UI Blazor (Fluent is internal) |
| Registration | `services.AddBreezeOnUI()` |
| Host requirements | Render `BoThemeProvider` and `BoProviders` in the app layout |
| Decision record | [ADR-004](../decisions/ADR-004-breezeon-ui-abstraction-layer.md) |

Product applications must use **`BreezeOn.UI`** components (`Bo*`). Do not reference `Microsoft.FluentUI.AspNetCore.Components` types from product pages.

### Shipped components

| Component | Purpose |
| --- | --- |
| Design tokens / `BoThemeProvider` | CSS variables and theme options (palette, spacing, radius, typography, shell tokens) |
| `BoProviders` | Hosts Fluent providers without exposing Fluent |
| `BoAppShell` | Option B app chrome: full-height nav + header/body column |
| `BoShellCard` | Floating card chrome (border, shadow, `card-container-background`); margin density Shell/Content/None |
| `BoNavPane` / `BoNavLink` | Left navigation; collapses to a narrow icon rail; bottom collapse control; prefer `IconContent` with `BoIcon` |
| `BoIcon` | Public icon API (`Name`, `BoIconVariant`, `Size`); resolves Fluent System Icons internally |
| `BoAppHeader` | Top header card; `AppTitle` (bold) + `Subtitle` (regular, smaller) |
| `BoAppBody` | Scrollable body region content host |
| `BoCard` | Content card with optional title/footer; uses `card-container-*` tokens; optional `MarginDensity` |
| `BoStack` | Vertical or horizontal stack layout |
| `BoPageHeader` | Page title and description |
| `BoTextField` | Text input |
| `BoButton` | Button (primary / secondary / stealth) |

### Left navigation standard (locked)

`BoAppShell` is required for apps using this library (Option B). The **left navigation bar is a platform standard**. Product apps compose pages inside it; they do not redesign nav chrome.

**Required structure (top → bottom):** brand logos (expanded + minimized) → horizontal divider → nav pages with Fluent icons via `BoIcon` → fixed collapse control.

**Fixed (not per-app):** Fluent icons through `BoIcon` for page items; logo divider; page hover (lift) and selected fill; collapse control (green icon-only hit; `PanelRightExpand` when expanded, `PanelLeftExpand` when collapsed). Hover/selected patterns are **left-nav only**.

**Per-application customization:** logo image URLs (`LogoExpandedSrc` / `LogoMinimizedSrc`); number of pages, routes, and labels; page icons (except collapse) via `BoNavLink.IconContent` + `BoIcon`; optional `NavBackgroundColor` / `NavSelectedTabColor`.

Authoritative detail: [SYSTEM-SHARED-UI README](https://github.com/Breeze-On/SYSTEM-SHARED-UI/blob/main/README.md) (Left navigation standard).

### Shell tokens (current)

| Token name | CSS variable | Where used |
| --- | --- | --- |
| `background` | `--bo-color-background` | Page/canvas behind floating shell cards |
| `card-container-background` | `--bo-color-card-container-background` | Shell and content card fill |
| `card-container-border` | `--bo-color-card-container-border` | Light card borders (`#EEEEF0`) |
| `card-container-shadow` | `--bo-shadow-card-container` | Card elevation |
| `shell-margin` | `--bo-space-shell-margin` | Slim margins on shell cards; **nav right margin is 0** (gap from main column left margin) |
| `content-card-margin` | `--bo-space-content-card-margin` | Slightly larger margins for in-body content cards |

### Typography (hard standard)

Default UI font for Breeze On applications using `BreezeOn.UI` is **Calibri** (`BoThemeOptions.FontFamily` / `--bo-font-family`, with Segoe UI / system-ui as fallbacks only). Do not change the default typeface without an explicit org decision and STANDARDS update.

### Local gallery

`src/BreezeOn.UI.Gallery` in SYSTEM-SHARED-UI runs a local Interactive Server host to preview components (`dotnet run` in that project). Gallery pages (current): Home (empty landing), Theme, Text Field.

## When new shared components are introduced

Document each shared component here (name, purpose, repo/package, usage expectations) at the time it exists, and keep this file current-state only.
