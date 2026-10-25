# UI standards — overview

Entry point for Breeze On shared UI conventions. Standards are organized by **responsibility** under `docs/ui/` so the tree can grow without a single ever-expanding document.

Current reality only. Implementation lives in [SYSTEM-SHARED-UI](https://github.com/Breeze-On/SYSTEM-SHARED-UI) (`BreezeOn.UI`). Decision record: [ADR-004](../../decisions/ADR-004-breezeon-ui-abstraction-layer.md).

## UI documentation index

| Document | Responsibility |
| --- | --- |
| [overview.md](overview.md) (this file) | Library contract, shipped inventory, gallery, documentation governance |
| **Foundations** | |
| [foundations/tokens.md](foundations/tokens.md) | Design / shell tokens |
| [foundations/typography.md](foundations/typography.md) | Default typeface |
| [foundations/i18n.md](foundations/i18n.md) | Culture / timezone cookies; per-app resource libraries; no hardcoded labels |
| **Shell** | |
| [shell/shell.md](shell/shell.md) | App shell chrome, footer, header tabs |
| [shell/navigation.md](shell/navigation.md) | Left navigation, route/URL matching |
| **Layout** | |
| [layout/sections.md](layout/sections.md) | Main Section / Sub Section |
| [layout/layout.md](layout/layout.md) | Row (`BoRow`), page composition, planning JSON schema |
| **Controls** | |
| [controls/forms.md](controls/forms.md) | Text Field, Drop-Down List, and form controls |

Former single file [`docs/ui-components.md`](../ui-components.md) redirects here. Flat paths under `docs/ui/*.md` (e.g. `docs/ui/tokens.md`) redirect to the hierarchical files above.

## Shared library (current)

| | |
| --- | --- |
| Repository | [Breeze-On/SYSTEM-SHARED-UI](https://github.com/Breeze-On/SYSTEM-SHARED-UI) |
| Package / project | `BreezeOn.UI` (`src/BreezeOn.UI`) |
| Approach | Option B+: BreezeOn public API on top of Fluent UI Blazor (Fluent is internal) |
| Registration | `services.AddBreezeOnUI()` |
| Host requirements | Render `BoThemeProvider` and `BoProviders` in the app layout |
| Decision record | [ADR-004](../../decisions/ADR-004-breezeon-ui-abstraction-layer.md) |

Product applications must use **`BreezeOn.UI`** components (`Bo*`). Do not reference `Microsoft.FluentUI.AspNetCore.Components` types from product pages.

Dependency position (landscape): [architecture/landscape.md](../../architecture/landscape.md).

## Shipped components

| Component | Purpose | Detail |
| --- | --- | --- |
| Design tokens / `BoThemeProvider` | CSS variables and theme options (palette, spacing, radius, typography, shell tokens); dual Light/Dark palettes | [tokens.md](foundations/tokens.md), [typography.md](foundations/typography.md) |
| `IBoThemeModeService` | `ThemeMode` + active palette; cookie `bo-theme-mode` restore via `BoProviders` bootstrap | [tokens.md](foundations/tokens.md) |
| `BoProviders` | Hosts Fluent providers, theme/locale bootstrap, dialog hosts | [tokens.md](foundations/tokens.md), [i18n.md](foundations/i18n.md) |
| `IBoLocaleService` | Culture + IANA timezone; cookies `bo-culture` / `bo-timezone` | [i18n.md](foundations/i18n.md) |
| `BoAppShell` | Option B app chrome: full-height nav + header / body / footer column | [shell.md](shell/shell.md) |
| `BoShellCard` | Floating card chrome (border, shadow, `card-container-background`); margin density Shell/Content/None | [shell.md](shell/shell.md), [tokens.md](foundations/tokens.md) |
| `BoNavPane` / `BoNavLink` | Left navigation; collapses to a narrow icon rail; bottom collapse control; prefer `IconContent` with `BoIcon` | [navigation.md](shell/navigation.md) |
| `BoIcon` | Public icon API (`Name`, `BoIconVariant`, `Size`); resolves Fluent System Icons internally | [navigation.md](shell/navigation.md) |
| `BoAppHeader` | Top header card; titles + trailing actions; optional `TabsContent` / `ActionsContent` | [shell.md](shell/shell.md) |
| `BoHeaderActions` | Theme switch + Settings + Profile cluster | [shell.md](shell/shell.md) |
| `BoThemeSwitch` | Apple-style Light/Dark switch (`BrightnessLow` icon) | [shell.md](shell/shell.md), [tokens.md](foundations/tokens.md) |
| `BoProfileMenu` | Avatar placeholder + Sign out menu (design only) | [shell.md](shell/shell.md) |
| `BoTabs` / `BoTab` | Optional page-section tabs under the header title row | [shell.md](shell/shell.md) |
| `BoTabPanels` / `BoTabPanel` | Keep-alive body sections keyed to tabs (`SelectedTab`) | [shell.md](shell/shell.md) |
| `BoAppBody` | Scrollable body region content host (scrolls inside body card) | [shell.md](shell/shell.md) |
| `BoAppFooter` | Bottom footer card (optional per page via `ShowFooter`; shorter inside padding) | [shell.md](shell/shell.md) |
| `BoCard` | Content card with optional title/footer; uses `card-container-*` tokens; optional `MarginDensity` | [tokens.md](foundations/tokens.md) |
| `BoSectionMain` | **Main Section** — borderless content block with optional header | [sections.md](layout/sections.md) |
| `BoSectionSub` | **Sub Section** — nested grouping (different label/margins than Main) | [sections.md](layout/sections.md) |
| `BoRow` | **Row** — equal-width field slots inside a section | [layout.md](layout/layout.md) |
| `BoStack` | Vertical or horizontal stack layout | [sections.md](layout/sections.md) |
| `BoPageHeader` | Page title and description | — |
| `BoTextField` | Text input | [forms.md](controls/forms.md) |
| `BoDropDownList` | Drop-Down List (same field chrome as Text Field) | [forms.md](controls/forms.md) |
| `BoButton` | Pill button (primary / secondary / stealth); shorter+wider padding; shadow + hover lift; optional icon | [tokens.md](foundations/tokens.md) |
| `BoDialogService` | Message dialog facade (`ShowMessageAsync`) | — |
| `BoSettingsDialogService` | Centered Settings dialog (Language / Timezone via `BoDropDownList`) | [shell.md](shell/shell.md), [i18n.md](foundations/i18n.md) |

## Local gallery

`src/BreezeOn.UI.Gallery` in SYSTEM-SHARED-UI runs a local Interactive Server host to preview components (`dotnet run` in that project). Gallery pages (current): Home (README-style overview), Components (`/components` with Text Field / Drop-Down List / Date Field header tabs), Theme (per color tab: Main `{Name} Color` → Sub **Attributes** fields + Sub **Preview** swatch). Nav order: Home / Components (`/components`) / Theme; nav starts collapsed. URL must match page name — see [navigation.md](shell/navigation.md).

## Documentation governance

Documentation is part of **completion criteria** (same change set as code). Current reality only — never document planned components as shipped.

### When new shared components are introduced

For every new or changed public `Bo*` surface:

1. Add or update the inventory row in this overview.
2. Document rules in the appropriate responsibility file under `foundations/`, `shell/`, `layout/`, or `controls/` (create a focused sibling if needed).
3. Update the gallery when the component is previewable.
4. Update STANDARDS indexes (`README.md`, `README_AI.md`, this overview) and any product README / README_AI links in the same change set.

### Organic structure rule

When a UI document becomes too large or covers multiple independent concerns, split by responsibility under the folders above and update this index. Prefer deepening the hierarchy over a flat list of ever-larger files.
