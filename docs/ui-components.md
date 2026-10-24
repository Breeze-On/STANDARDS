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
| `BoProviders` | Hosts Fluent providers and `BoMessageDialogHost` without exposing Fluent |
| `BoAppShell` | Option B app chrome: full-height nav + header / body / footer column |
| `BoShellCard` | Floating card chrome (border, shadow, `card-container-background`); margin density Shell/Content/None |
| `BoNavPane` / `BoNavLink` | Left navigation; collapses to a narrow icon rail; bottom collapse control; prefer `IconContent` with `BoIcon` |
| `BoIcon` | Public icon API (`Name`, `BoIconVariant`, `Size`); resolves Fluent System Icons internally |
| `BoAppHeader` | Top header card; `AppTitle` + `  -  ` + `Subtitle` inline; optional `TabsContent` |
| `BoTabs` / `BoTab` | Optional page-section tabs under the header title row |
| `BoTabPanels` / `BoTabPanel` | Keep-alive body sections keyed to tabs (`SelectedTab`) |
| `BoAppBody` | Scrollable body region content host (scrolls inside body card) |
| `BoAppFooter` | **Hard standard** bottom footer card (required with `BoAppShell`; shorter inside padding) |
| `BoCard` | Content card with optional title/footer; uses `card-container-*` tokens; optional `MarginDensity` |
| `BoSectionMain` | **Main Section** — borderless content block with optional header; see [Main Section](#main-section-bosectionmain) |
| `BoStack` | Vertical or horizontal stack layout |
| `BoPageHeader` | Page title and description |
| `BoTextField` | Text input |
| `BoButton` | Pill button (primary / secondary / stealth); shorter+wider padding; shadow + hover lift; optional icon |
| `BoDialogService` | Message dialog facade (`ShowMessageAsync`) |




### Main Section (`BoSectionMain`)

**Display name:** Main Section.  
**Component:** `BoSectionMain` in [SYSTEM-SHARED-UI](https://github.com/Breeze-On/SYSTEM-SHARED-UI).

A **Main Section** groups related page content. It is intentionally **not** a floating card:

| Concern | Main Section (`BoSectionMain`) | Content card (`BoCard`) |
| --- | --- | --- |
| Border | None | Card-container border |
| Shadow | None | Card-container shadow |
| Inside padding | **None** (0) | Theme spacing on the card |
| Background | Transparent | Card-container background |
| Optional header | Yes (see below) | Simple title/footer (card chrome) |

Header is **optional**. When omitted, only the body content is rendered.

#### Optional header

| Concern | Standard |
| --- | --- |
| Label | Bold, **13px**, black (`#000000`); top-left aligned |
| Icon | Optional; to the **left** of the label; ~13px; tight ~4px gap to label; **vertically center-aligned** with the label (prefer `BoIcon` in `IconContent`) |
| Rule | Grey horizontal line **directly under** the header text/icon row; almost no gap (~2px); uses `--bo-color-card-container-border` |
| API | `Title` and/or `TitleContent`; optional `IconContent`; body via `ChildContent` |

Product apps must use `BoSectionMain` for Main Sections — do not reimplement this chrome in page CSS.

**Related (not shipped):** `BoSectionSub` (Sub Section) — do not document or invent until implemented.

**Gallery reference:** Theme page (`/theme`) — Main Section titled "Primary Color" with `PaintBrushSparkle` (Regular) icon and a Hex Code field.


### Header tabs (optional page sections)

Pages **may omit** tabs. When present, use `BoAppHeader.TabsContent` with `BoTabs` / `BoTab` and body `BoTabPanels` / `BoTabPanel`. Tabs are page sections, not left-nav routes.

| Concern | Standard |
| --- | --- |
| Width | Dynamic / content-hug; label nowrap |
| Content | Icon (`BoIcon`) + label; vertically center-aligned |
| Default colors | Black text/icon; transparent background |
| Hover (unselected) | Tertiary fill + full rounded pill + lift; selected has no hover |
| Selected | Tertiary fill + full rounded pill; no hover |
| Vertical separator | Border-token rule centered in the gap between tabs (16px gap) |
| Horizontal divider | 96% of width inside header padding |
| Inside padding | Tab hit: 4px vertical / 8px horizontal |
| Outside spacing | 16px gap between tabs; inside header padding |
| Switch behavior | All panels load together and stay mounted; hide inactive with CSS (no remount/reload) |
| `SelectedTab` | Bindable in-memory key (`@bind-SelectedTab`); defaults to first tab; persists across switches |

Authoritative detail: [SYSTEM-SHARED-UI README](https://github.com/Breeze-On/SYSTEM-SHARED-UI/blob/main/README.md) (Header tabs standard).

### App shell footer (hard standard)

Every application that uses `BoAppShell` **must** include the fixed bottom footer shell region (`BoAppFooter` / `FooterContent`). Do not ship apps with header/body only. Footer chrome matches the floating card family; body content scrolls inside the body card above it.

### Left navigation standard (locked)

`BoAppShell` is required for apps using this library (Option B). The **left navigation bar is a platform standard**. Product apps compose pages inside it; they do not redesign nav chrome.

**Required structure (top to bottom):** brand logos (expanded + minimized) -> horizontal divider -> nav pages with Fluent icons via `BoIcon` -> fixed collapse control.

**Fixed (not per-app):** Fluent icons through `BoIcon` for page items; logo divider; page hover (lift); selected fill using **tertiary** with **black bold** text/icon; unselected **white** text/icon on **primary** nav panel; collapse control (transparent background, **white** icon, hover like unselected nav; `PanelRightExpand` when expanded, `PanelLeftExpand` when collapsed). Hover/selected patterns are **left-nav only**.

**Per-application customization:** logo image URLs (`LogoExpandedSrc` / `LogoMinimizedSrc`); number of pages, routes, and labels; page icons (except collapse) via `BoNavLink.IconContent` + `BoIcon`; optional `PrimaryColor` / `TertiaryColor`.

Authoritative detail: [SYSTEM-SHARED-UI README](https://github.com/Breeze-On/SYSTEM-SHARED-UI/blob/main/README.md) (Left navigation standard).

### Shell tokens (current)

| Token name | CSS variable | Where used |
| --- | --- | --- |
| `background` | `--bo-color-background` | Page/canvas behind floating shell cards |
| `card-container-background` | `--bo-color-card-container-background` | Shell and content card fill |
| `card-container-border` | `--bo-color-card-container-border` | Light card borders |
| `card-container-shadow` | `--bo-shadow-card-container` | Card elevation |
| `shell-margin` | `--bo-space-shell-margin` | Slim margins on shell cards; **nav right margin is 0** (gap from main column left margin) |
| `content-card-margin` | `--bo-space-content-card-margin` | Slightly larger margins for in-body content cards |
| `primary` | `--bo-color-primary` | Accent (`#224D3A`): nav panel fill, primary buttons |
| `primary-hover` | `--bo-color-primary-hover` | Primary button hover |
| `secondary` | `--bo-color-secondary` | Selected header tab rounded bottom border (`#7CF76C`) |
| `tertiary` | `--bo-color-tertiary` | Soft surface (`#D8F3DC`): selected nav, secondary buttons, header tab selected/hover |

### Typography (hard standard)

Default UI font for Breeze On applications using `BreezeOn.UI` is **Calibri** (`BoThemeOptions.FontFamily` / `--bo-font-family`, with Segoe UI / system-ui as fallbacks only). Do not change the default typeface without an explicit org decision and STANDARDS update.

### Route / URL (hard standard)

Nav page URLs **must match the page name** (lowercase, hyphenated if multi-word). Example: **Components** -> `/components`. Do not keep a mismatched demo slug after renaming a nav page.

### Local gallery

`src/BreezeOn.UI.Gallery` in SYSTEM-SHARED-UI runs a local Interactive Server host to preview components (`dotnet run` in that project). Gallery pages (current): Home (README-style overview), Components (`/components` with Text Field / Drop-Down List / Date Field header tabs), Theme (Primary Color Main Section). Nav order: Home / Components (`/components`) / Theme; nav starts collapsed. URL must match page name.

## When new shared components are introduced

Documentation is part of **completion criteria** (same change set as code). Current reality only — never document planned components as shipped.

For every new or changed public `Bo*` surface:

1. Update **this** file (`docs/ui-components.md`): inventory row + dedicated rules section when the component has locked UX standards.
2. Update [SYSTEM-SHARED-UI](https://github.com/Breeze-On/SYSTEM-SHARED-UI) `README.md`, `README_AI.md`, and `AGENTS.md` as needed (link here; do not duplicate long org rules).
3. Add or update gallery examples when the component is demonstrable.
4. Update naming / ecosystem docs only if repo or package identity changed.
5. Create or supersede an ADR when the change is architectural (see [`docs/adr.md`](adr.md)).

A change is incomplete until STANDARDS and the owning product/library docs match the implemented code.
