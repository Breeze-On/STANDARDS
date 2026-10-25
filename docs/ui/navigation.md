# UI — Navigation and routes

Left navigation and URL path standards. Related: [shell.md](shell.md), [tokens.md](tokens.md), [overview.md](overview.md).

## Left navigation standard (locked)

`BoAppShell` is required for apps using this library (Option B). The **left navigation bar is a platform standard**. Product apps compose pages inside it; they do not redesign nav chrome.

**Required structure (top to bottom):** brand logos (expanded + minimized) → horizontal divider → nav pages with Fluent icons via `BoIcon` → fixed collapse control.

**Fixed (not per-app):** Fluent icons through `BoIcon` for page items; logo divider; page hover (lift); selected fill using **tertiary** with **black bold** text/icon; unselected **white** text/icon on **primary** nav panel; collapse control (transparent background, **white** icon, hover like unselected nav; `PanelRightExpand` when expanded, `PanelLeftExpand` when collapsed). Hover/selected patterns are **left-nav only**.

**Per-application customization:** logo image URLs (`LogoExpandedSrc` / `LogoMinimizedSrc`); number of pages, routes, and labels; page icons (except collapse) via `BoNavLink.IconContent` + `BoIcon`; optional `PrimaryColor` / `TertiaryColor`.

Accent tokens for primary/tertiary: [tokens.md](tokens.md). Shell regions: [shell.md](shell.md).

Authoritative detail: [SYSTEM-SHARED-UI README](https://github.com/Breeze-On/SYSTEM-SHARED-UI/blob/main/README.md) (Left navigation standard).

## Route / URL (hard standard)

Nav page URLs **must match the page name** (lowercase, hyphenated if multi-word). Example: **Components** → `/components`. Do not keep a mismatched demo slug after renaming a nav page.
