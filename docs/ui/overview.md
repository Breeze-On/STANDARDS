# UI standards — overview

Entry point for Breeze On shared UI conventions. Standards are organized by **responsibility** under `docs/ui/` so the tree can grow without a single ever-expanding document.

Current reality only. Implementation lives in [SYSTEM-SHARED-UI](https://github.com/Breeze-On/SYSTEM-SHARED-UI) (`BreezeOn.UI`). Decision record: [ADR-004](../../decisions/ADR-004-breezeon-ui-abstraction-layer.md).

## UI documentation index

| Document | Responsibility |
| --- | --- |
| [overview.md](overview.md) (this file) | Library contract, shipped inventory, gallery, documentation governance |
| [shell.md](shell.md) | App shell chrome, footer, header tabs |
| [navigation.md](navigation.md) | Left navigation, route/URL matching |
| [sections.md](sections.md) | Main Section / Sub Section |
| [layout.md](layout.md) | Row (`BoRow`), page composition, planning JSON schema |
| [forms.md](forms.md) | Text Field, Drop-Down List, and form controls |
| [i18n.md](i18n.md) | Culture / timezone cookies + en/fr resource foundation |
| [typography.md](typography.md) | Default typeface |
| [tokens.md](tokens.md) | Design / shell tokens |

Former single file [`docs/ui-components.md`](../ui-components.md) redirects here.

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
| Design tokens / `BoThemeProvider` | CSS variables and theme options (palette, spacing, radius, typography, shell tokens); dual Light/Dark palettes | [tokens.md](tokens.md), [typography.md](typography.md) |
| `IBoThemeModeService` | `ThemeMode` + active palette; cookie `bo-theme-mode` restore via `BoProviders` bootstrap | [tokens.md](tokens.md) |
| `BoProviders` | Hosts Fluent providers, theme/locale bootstrap, dialog hosts | [tokens.md](tokens.md), [i18n.md](i18n.md) |
| `IBoLocaleService` | Culture + IANA timezone; cookies `bo-culture` / `bo-timezone` | [i18n.md](i18n.md) |
| `BoAppShell` | Option B app chrome: full-height nav + header / body / footer column | [shell.md](shell.md) |
| `BoShellCard` | Floating card chrome (border, shadow, `card-container-background`); margin density Shell/Content/None | [shell.md](shell.md), [tokens.md](tokens.md) |
| `BoNavPane` / `BoNavLink` | Left navigation; collapses to a narrow icon rail; bottom collapse control; prefer `IconContent` with `BoIcon` | [navigation.md](navigation.md) |
| `BoIcon` | Public icon API (`Name`, `BoIconVariant`, `Size`); resolves Fluent System Icons internally | [navigation.md](navigation.md) |
| `BoAppHeader` | Top header card; titles + trailing actions; optional `TabsContent` / `ActionsContent` | [shell.md](shell.md) |
| `BoHeaderActions` | Theme switch + Settings + Profile cluster | [shell.md](shell.md) |
| `BoThemeSwitch` | Apple-style Light/Dark switch (`BrightnessLow` icon) | [shell.md](shell.md), [tokens.md](tokens.md) |
| `BoProfileMenu` | Avatar placeholder + Sign out menu (design only) | [shell.md](shell.md) |
| `BoTabs` / `BoTab` | Optional page-section tabs under the header title row | [shell.md](shell.md) |
| `BoTabPanels` / `BoTabPanel` | Keep-alive body sections keyed to tabs (`SelectedTab`) | [shell.md](shell.md) |
| `BoAppBody` | Scrollable body region content host (scrolls inside body card) | [shell.md](shell.md) |
| `BoAppFooter` | Bottom footer card (optional per page via `ShowFooter`; shorter inside padding) | [shell.md](shell.md) |
| `BoCard` | Content card with optional title/footer; uses `card-container-*` tokens; optional `MarginDensity` | [tokens.md](tokens.md) |
| `BoSectionMain` | **Main Section** — borderless content block with optional header | [sections.md](sections.md) |
| `BoSectionSub` | **Sub Section** — nested grouping (different label/margins than Main) | [sections.md](sections.md) |
| `BoRow` | **Row** — equal-width field slots inside a section | [layout.md](layout.md) |
| `BoStack` | Vertical or horizontal stack layout | [sections.md](sections.md) |
| `BoPageHeader` | Page title and description | — |
| `BoTextField` | Text input | [forms.md](forms.md) |
| `BoDropDownList` | Drop-Down List (same field chrome as Text Field) | [forms.md](forms.md) |
| `BoButton` | Pill button (primary / secondary / stealth); shorter+wider padding; shadow + hover lift; optional icon | [tokens.md](tokens.md) |
| `BoDialogService` | Message dialog facade (`ShowMessageAsync`) | — |
| `BoSettingsDialogService` | Centered Settings dialog (Language / Timezone via `BoDropDownList`) | [shell.md](shell.md), [i18n.md](i18n.md) |

## Local gallery

`src/BreezeOn.UI.Gallery` in SYSTEM-SHARED-UI runs a local Interactive Server host to preview components (`dotnet run` in that project). Gallery pages (current): Home (README-style overview), Components (`/components` with Text Field / Drop-Down List / Date Field header tabs), Theme (per color tab: Main `{Name} Color` → Sub **Attributes** fields + Sub **Preview** swatch). Nav order: Home / Components (`/components`) / Theme; nav starts collapsed. URL must match page name — see [navigation.md](navigation.md).

## Documentation governance

Documentation is part of **completion criteria** (same change set as code). Current reality only — never document planned components as shipped.

### When new shared components are introduced

For every new or changed public `Bo*` surface:

1. Update the **appropriate** file under `docs/ui/` (inventory row in this overview + dedicated rules in the responsibility document when the component has locked UX standards).
2. Update [SYSTEM-SHARED-UI](https://github.com/Breeze-On/SYSTEM-SHARED-UI) `README.md`, `README_AI.md`, and `AGENTS.md` as needed (link here; do not duplicate long org rules).
3. Add or update gallery examples when the component is demonstrable.
4. Update naming / ecosystem / landscape docs only if repo or package identity or topology changed.
5. Create or supersede an ADR when the change is architectural (see [`docs/adr.md`](../adr.md)).

A change is incomplete until STANDARDS and the owning product/library docs match the implemented code.

### Organic structure (maintainability)

When introducing or documenting new UI standards, evaluate whether the existing UI documentation structure remains maintainable.

If a document is becoming excessively large or serves multiple independent concerns, create a new focused document and update the UI index in this overview accordingly.

Prefer a modular documentation structure over a single ever-growing UI document.

Documentation organization should evolve organically with the design system.
