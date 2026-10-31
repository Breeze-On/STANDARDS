# UI standards — overview

Owner: UI

Entry point for Breeze On shared UI conventions. Standards are organized by **responsibility** under `docs/ui/` so the tree can grow without a single ever-expanding document.

Current reality only. Implementation lives in [SYSTEM-SHARED-UI](https://github.com/Breeze-On/SYSTEM-SHARED-UI) (`BreezeOn.UI`). Decision record: [ADR-004](../../decisions/ADR-004-breezeon-ui-abstraction-layer.md).

## UI documentation index

| Document | Responsibility |
| --- | --- |
| [overview.md](overview.md) (this file) | Library contract, shipped inventory, gallery, documentation governance |
| [page-development.md](page-development.md) | Page-construction checklist for humans and AI agents (links to detailed standards) |
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
| [controls/forms.md](controls/forms.md) | Text Field, Drop-Down List, Date Field, and form controls |
| [controls/grids.md](controls/grids.md) | Grid (`BoGrid`) — Read-Only / Row Edit / Inline Edit / Nested View |

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
| `BoProviders` | Hosts Fluent providers, theme/locale bootstrap, dialog / toast hosts | [tokens.md](foundations/tokens.md), [i18n.md](foundations/i18n.md), [shell.md](shell/shell.md) |
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
| `BoNavHub` | Home hub host (~33%·67%, gradient + dots, brand logo `80cqmin`) | [shell.md](shell/shell.md#home--navigation-hub-locked-platform-pattern) |
| `BoNavCardStyleHyperlink` | Home destination card (internal SPA or external new-tab); locked chrome | [shell.md](shell/shell.md#home--navigation-hub-locked-platform-pattern) |
| `BoSectionMain` | **Main Section** — optional header; `SectionKey` for validation fail badge / ancestry | [sections.md](layout/sections.md) |
| `BoSectionSub` | **Sub Section** — nested grouping; `SectionKey` + cascaded Main/Sub keys to fields | [sections.md](layout/sections.md) |
| `BoRow` | **Row** — equal-width field slots inside a section | [layout.md](layout/layout.md) |
| `BoStack` | Vertical or horizontal stack layout | [sections.md](layout/sections.md) |
| `BoPageHeader` | Page title and description | — |
| `BoFieldReadOnly` | Flat read-only display field (pre-formatted string `Value`; same label chrome as Text Field) | [forms.md](controls/forms.md) |
| `BoEmptyField` | Empty `BoRow` alignment slot (no label/value) | [layout.md](layout/layout.md), [forms.md](controls/forms.md) |
| `BoTextField` | Text input (default Placeholder; deferred mandatory validation) | [forms.md](controls/forms.md) |
| `BoDropDownList` | Searchable Code/Description Drop-Down (`DisplayCode`, `AllowMultiple` chips, panel search) | [forms.md](controls/forms.md) |
| `BoCheckbox` | Boolean (`Required` / `ReadOnly` Yes-No) | [forms.md](controls/forms.md) |
| `BoDateField` | Date / DateTime UI; bound type always `DateTime?` (never `DateOnly`); locale + fixed calendar popover | [forms.md](controls/forms.md) |
| `BoNumberField` | Number UI; bound type always `decimal?`; integer/decimals; currency/% (mutex); focus raw / blur formatted; alignment default Right | [forms.md](controls/forms.md) |
| `BoButton` | Pill button (primary / secondary / stealth); shorter+wider padding; shadow + hover lift; optional icon | [tokens.md](foundations/tokens.md) |
| `BoDialogService` | Message dialog facade (`ShowMessageAsync`) | — |
| `IBoToastService` / `BoToastHost` | Top-right toasts (Main/Body; Success / Alert / Information / Error; click dismiss) | [shell.md](shell/shell.md) |
| `BoValidationContext` / `IBoSubmitInterceptor` | Deferred validation; `Validate(null)`; live fail badges; Field→Sub→Main→Tab failures | [forms.md](controls/forms.md) |
| `BoValidationFailBadge` | Red disc + white “!” (tabs + section headers) | [forms.md](controls/forms.md) |
| `BoSettingsDialogService` | Centered Settings dialog (Language / Timezone via `BoDropDownList`) | [shell.md](shell/shell.md), [i18n.md](foundations/i18n.md) |
| `BoGrid` / `BoGridColumn` / `BoGridCache` | Section-level grid (ReadOnly / RowEdit / InlineEdit / NestedView); typed cache; frozen sort while editing; column `Align` / `Width` (Flex default); Nested View expand/collapse + rails; optional horizontal scroll; host `bo-grid.js` for truncated-cell titles | [grids.md](controls/grids.md) |
| `BoSectionMain` / `BoSectionSub` `Required` | Optional red asterisk after section title (e.g. mandatory grid) | [sections.md](layout/sections.md), [grids.md](controls/grids.md) |

## Local gallery

`src/BreezeOn.UI.Gallery` in SYSTEM-SHARED-UI runs a local Interactive Server host (`dotnet run` in that project). Pages: Home (`BoNavHub`); Components (`/components` — Main → Parameters / Preview / Documentation; **Parameters** Sub rows always have **6** `BoRow` slots — pad with `BoEmptyField`, wrap every 6 when knobs exceed capacity; Preview = editable \| read-only \| **Backend Value**; **Grid** tab replaces Preview with Sub **Grid Control** hosting `BoGrid`; Submit = `Validate(null)` + Alert toast + fail badges); Theme (Light + Dark Main sections per color; Submit has no Theme field validation). Nav: Home / Components / Theme (starts collapsed). URL = page name — [navigation.md](shell/navigation.md).

## Documentation governance

Documentation is part of **completion criteria** (same change set as code). Current reality only — never document planned components as shipped. Org DoD: [documentation.md](../documentation.md#definition-of-done).

### When new shared components are introduced

For every new or changed public `Bo*` surface:

1. Add or update the inventory row in this overview.
2. Document rules in the appropriate responsibility file under `foundations/`, `shell/`, `layout/`, or `controls/` (create a focused sibling if needed).
3. Update [page-development.md](page-development.md) when the change affects how pages must be built (checklist living-document rule).
4. Update the gallery when the component is previewable.
5. Update STANDARDS indexes (`README.md`, `README_AI.md`, this overview) and any product README / README_AI links in the same change set.
6. New feature / parameter / UX or design-standard change / behavior-affecting refactor → documentation in the **same change set** (UI component DoD).

### Organic structure rule

When a UI document becomes too large or covers multiple independent concerns, split by responsibility under the folders above and update this index. Prefer deepening the hierarchy over a flat list of ever-larger files.
