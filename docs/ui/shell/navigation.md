<!-- Classification: AA; Scope: platform; Domain: UI; Capability: ShellNavigation -->
# UI — Navigation and routes

Owner: UI

Left navigation and URL path standards. Related: [shell.md](shell.md), [tokens.md](../foundations/tokens.md), [overview.md](../overview.md).

## Left navigation standard (locked)

`BoAppShell` is required for apps using this library (Option B). The **left navigation bar is a platform standard**. Product apps compose pages inside it; they do not redesign nav chrome.

**Required structure (top to bottom):** brand logos (expanded + minimized) → horizontal divider → nav pages with Fluent icons via `BoIcon` → fixed collapse control.

**Fixed (not per-app):** Fluent icons through `BoIcon` for page items; logo divider; page hover (lift); selected fill using **`color-nav-selected`** (`#D8F3DC` Light tertiary — **same hex in Light and Dark**) with **black bold** text/icon; unselected **white** text/icon on **primary** nav panel; brand logo divider using **`color-nav-logo-divider`** (`#E8EDF1` Light card border — **same hex in both modes**); collapse control (transparent background, **white** icon, hover like unselected nav; `PanelRightExpand` when expanded, `PanelLeftExpand` when collapsed). Hover/selected patterns are **left-nav only**.

**Fixed values (Tier 2):** *Default expanded width* `192px` (`BoThemeOptions.SizeNavExpanded` / `--bo-size-nav-expanded`); *collapsed icon rail* `56px` (`SizeNavCollapsed` / `--bo-size-nav-collapsed`); default logos ship in `_content/BreezeOn.UI/brand/`. Collapse label: none (no "Minimize" text). Page URL = page name (below).

**Per-application customization:** logo image URLs (`LogoExpandedSrc` / `LogoMinimizedSrc`); number of pages, routes, and labels; page icons (except collapse) via `BoNavLink.IconContent` + `BoIcon`; optional `PrimaryColor` / `TertiaryColor` (soft surfaces / primary rail — not selected-nav fill).

### Branding ownership (current)

| Concern | Standard |
| --- | --- |
| Configuration surface | Set logos on **`BoNavPane`** (`LogoExpandedSrc` / `LogoMinimizedSrc`) — one place per app layout |
| Shared state | `BoNavPane` publishes both URLs to scoped **`IBoBrandingService`** (`SetLogos`) |
| Defaults | Null/whitespace → `BoBrandingDefaults` (`breezeon-wordmark.svg` / `breezeon-icon.svg`) |
| Page freeze | Consumes **`LogoMinimizedSrc` only** (compact square icon) — [overlays.md](overlays.md) |
| Do not | Configure a second freeze-specific logo URL; do not use `LogoExpandedSrc` for page freeze |

### Collapsed nav, tooltips, and accessibility (current)

| Concern | Standard |
| --- | --- |
| Collapsed labels | Link labels and brand text are **visually hidden** (1px clip pattern), **not** `display: none` — they stay in the accessibility tree |
| `BoNavLink.Title` | Optional localized text used as the `title` tooltip **only while the nav is collapsed** (label is visually hidden). Hosts should set it to the localized page label |
| Landmark label | `<nav>` `aria-label` = `Chrome_Aria_Nav` (expanded) / `Chrome_Aria_NavCollapsed` (collapsed) |
| Collapse control | `title` + `aria-label` = `Chrome_Aria_NavCollapse` / `Chrome_Aria_NavExpand`; `aria-expanded` reflects the expanded state |
| Validation badge | `BoValidationFailBadge` `title` = `Chrome_Aria_ValidationFailed` (icon itself `aria-hidden`) |
| Localization | All of the above resolve through `IBoUiLocalizer` (`Chrome_Aria_*` keys in `BoUi.resx` / `BoUi.fr.resx`); product apps with their own resource library supply equivalent strings — [i18n.md](../foundations/i18n.md) |

Accent tokens: [tokens.md](../foundations/tokens.md). Shell regions: [shell.md](shell.md).

**This document is the UX SSOT for left navigation** (structure, fixed behavior, per-app customization, branding, collapsed a11y). The SHARED-UI README no longer carries a left-nav section, and [`public-component-api.md`](https://github.com/Breeze-On/SYSTEM-SHARED-UI/blob/main/docs/public-component-api.md) holds only the API ([BoNavPane](https://github.com/Breeze-On/SYSTEM-SHARED-UI/blob/main/docs/public-component-api.md#bonavpane) / [BoNavLink](https://github.com/Breeze-On/SYSTEM-SHARED-UI/blob/main/docs/public-component-api.md#bonavlink) parameters). Left navigation is **not** a tab / panel-navigation control — see [selection-and-navigation.md](../controls/selection-and-navigation.md).

## Route / URL (hard standard)

Nav page URLs **must match the page name** (lowercase, hyphenated if multi-word). Example: **Components** → `/components`. Do not keep a mismatched demo slug after renaming a nav page.
