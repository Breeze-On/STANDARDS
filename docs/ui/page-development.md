# UI — Page development checklist

Owner: UI

Single-page **implementation checklist** for developers and AI agents creating or modifying Breeze On pages that use `BreezeOn.UI`.

This document does **not** replace detailed standards. It is the authoritative **page-construction checklist** that points to the responsibility docs under `docs/ui/`. Current reality only.

**Entry / inventory:** [overview.md](overview.md). **Library:** [SYSTEM-SHARED-UI](https://github.com/Breeze-On/SYSTEM-SHARED-UI) (`BreezeOn.UI`). **Decision:** [ADR-004](../../decisions/ADR-004-breezeon-ui-abstraction-layer.md).

## Goals

- Improve consistency across applications.
- Reduce AI agent mistakes.
- Centralize page creation guidance.
- Ensure new pages follow Breeze On UI standards.
- Stay useful for both humans and AI agents.

## Host integration (required)

Every app host that renders `BreezeOn.UI` must wire the following once (reference: SYSTEM-SHARED-UI Gallery `App.razor` + `MainLayout.razor`). Pages inherit this; do not repeat per page.

| Concern | Requirement |
| --- | --- |
| Services | `services.AddBreezeOnUI()` or `AddBreezeOnUI(opts => …)` — registers Fluent internally; `configureTheme` is honored via `IOptions<BoThemeOptions>` ([tokens.md § Theme options](foundations/tokens.md#theme-options-addbreezeonuiconfiguretheme)) |
| Localization | Supported cultures `en` / `fr` + `UseRequestLocalization()` — [i18n.md](foundations/i18n.md) |
| Layout | Render **`BoThemeProvider`** (CSS variables) and **`BoProviders`** (Fluent providers, theme/locale bootstrap, dialog + toast + **page-freeze** hosts) around the app; pages live inside **`BoAppShell`** |
| CSS (in `<head>`) | `_content/Microsoft.FluentUI.AspNetCore.Components/Microsoft.FluentUI.AspNetCore.Components.bundle.scp.css` and `_content/BreezeOn.UI/breezeon-ui.css` |
| JS (in `<head>`) | `_content/BreezeOn.UI/js/bo-theme-mode.js`, `bo-locale.js`, `bo-popup.js`, `bo-number-field.js`, `bo-grid.js` |

JS file roles:

| Script | Needed for |
| --- | --- |
| `bo-theme-mode.js` | Theme-mode cookie helpers; sets `document.documentElement.dataset.boThemeMode` |
| `bo-locale.js` | Locale cookie helpers for `bo-culture` / `bo-timezone` |
| `bo-popup.js` | Fixed-position panels for `BoDropDownList` and `BoDateField` |
| `bo-number-field.js` | **Required for `BoNumberField`** (key filter, focus/blur bridge to the Fluent input, select-all, display sync). Without it number entry does not behave per standard |
| `bo-grid.js` | `BoGrid` truncated-cell hover titles |

Include **all five** scripts even if a page does not use every control — shell chrome and future pages depend on them. Note: the early scripts reduce theme/locale flash only partly; CSS variables are still emitted by `BoThemeProvider` after the circuit renders (see [tokens.md](foundations/tokens.md)).

## New page development checklist

Every new or changed Breeze On page should validate the following.

### General

- [ ] Route follows Breeze On route naming: URL path **matches the page name** (lowercase, hyphenated if multi-word) — [navigation.md](shell/navigation.md#route--url-hard-standard).
- [ ] User-visible text uses the **host app’s resource library** — [i18n.md](foundations/i18n.md).
- [ ] No hardcoded labels, titles, toasts, or dialog copy.
- [ ] Uses **`BreezeOn.UI` (`Bo*`)** components only — [overview.md](overview.md).
- [ ] Does **not** import or use `Microsoft.FluentUI.*` types on product pages — [ADR-004](../../decisions/ADR-004-breezeon-ui-abstraction-layer.md).

### Shell

- [ ] Page is hosted within **`BoAppShell`** (Option B floating cards) — [shell.md](shell/shell.md).
- [ ] **Per-page** localized `AppTitle` provided — [shell.md § Header titles](shell/shell.md#header-titles-per-page).
- [ ] `Subtitle` provided when appropriate; empty/whitespace subtitle **omits** the title dash.
- [ ] Header actions remain platform-standard (`BoHeaderActions`: Theme → Settings → Profile) unless the host intentionally overrides `ActionsContent`.
- [ ] Footer behavior follows standards (`ShowFooter`; Home typically **false**) — [shell.md](shell/shell.md).

### Home pages

When the page is a **Home** (or equivalent landing hub):

- [ ] Uses **`BoNavHub`**.
- [ ] Uses **`BoNavCardStyleHyperlink`** for destinations.
- [ ] One card per application destination (internal SPA or external as required).
- [ ] Follows the locked Home / navigation hub pattern — [shell.md § Home](shell/shell.md#home--navigation-hub-locked-platform-pattern).
- [ ] Does **not** invent custom dashboard / markdown / Fluent card layouts.
- [ ] Does **not** use Section → Row → Field as the Home layout (that composition is for forms).

**Per-app only on Home:** card count/routes, localized Label/Description, card icons, right-panel logo asset, optional primary/tertiary accents.

### Layout (forms and structured content)

- [ ] Uses **`BoSectionMain`** for top-level groupings — [sections.md](layout/sections.md).
- [ ] Uses **`BoSectionSub`** for nested groupings (Sub is **not** the same as Main — different label size/case and margins).
- [ ] Uses **`BoRow`** for field layouts — [layout.md](layout/layout.md).
- [ ] Every **`BoRow` is inside a Section**.
- [ ] Every form field is a **direct child of a `BoRow`**.
- [ ] Stack Sections/Rows with **`BoStack Gap="0"`** so outside margins are not doubled.
- [ ] Do not invent free-floating fields or custom width CSS. Use **`Weight`** for proportional sizing; **`IsHidden`** collapses by default; **`PreserveLayoutWhenHidden`** only when reserved space is justified; **`BoEmptyField`** for permanent alignment holes — [layout.md](layout/layout.md).

Planning agents: emit **`schemaVersion "1"`** JSON per [layout.md](layout/layout.md#page-composition-json-planning-agent-input) (optional `weight` / `preserveLayoutWhenHidden`); nest Sub Sections in Razor even when flat JSON is used.

### Grid (section-level)

When the page includes a data grid:

- [ ] Uses **`BoGrid`** / **`BoGridColumn`** / **`BoGridCache`** — [grids.md](controls/grids.md).
- [ ] Treats the grid as a **section-level** surface (not a `BoRow` child; not Section → Row → Field for the grid body).
- [ ] If multi-select is needed: `EnableSelection` (flat: select-all = all cache rows; Nested Scenario 1: `SelectedNodeKeys` + cascade select/expand) — [grids.md](controls/grids.md#row-selection).
- [ ] Binds a typed cache with **`CacheId`**; rows expose **`CacheRowId`** + nullable **`PrimaryKey`**.
- [ ] Chooses **`Mode`**: ReadOnly (default), RowEdit, InlineEdit, or NestedView per requirements.
- [ ] **`IsPagination`** only when required (default false); sort is over the full cache; display order stays frozen while editing.
- [ ] Column **`Align`**: text/date Left; number/currency Right unless the design requires otherwise. Headers always left.
- [ ] Column **`Width`**: leave default **Flex** unless Compact/Hug is intentional; do not invent custom table layouts.
- [ ] **`EnableHorizontalScroll`** only when many columns truly need a horizontal scrollbar (default false).
- [ ] Host loads **`_content/BreezeOn.UI/js/bo-grid.js`** when using truncated display cells (hover full-value title).
- [ ] Cell editors reuse existing **`Bo*`** fields; column / grid **`Required`** follow [grids.md](controls/grids.md).
- [ ] Nested View: set `NodeKey`; same columns → `ChildrenSelector`; different columns → `ChildRowsHaveDifferentColumns` + `ChildGridTemplate` (nested `BoGrid`, not a new component). Optional `DefaultExpansionState`. Same-column Nested View may use `EnableSelection` with cascade. Keyword filters: follow [Nested View keyword filtering](controls/grids.md#nested-view-keyword-filtering-org-standard) unless a documented exception. See [grids.md Nested View](controls/grids.md#nested-view-locked--shipped).

### Filters and query-driven datasets

When the page filters, sorts, or pages a dataset — [query-driven-retrieval.md](controls/query-driven-retrieval.md) · [ADR-008](../../decisions/ADR-008-query-driven-data-retrieval.md):

**Canonical host pattern (copy from Gallery):**

Filters section → build `BoQueryRequest` → `BoLatestWinsQuery.RunAsync` → primary retrieval contract → `BoGridCache.ReplaceAll` + `TotalCount` → `StateHasChanged`. Nested View keyword: contract or `BoNestedViewKeywordFilter` → `NestedExpandedSeedKeys` / shallow `DefaultExpansionState` (not `PreserveLayoutWhenHidden`).

- [ ] Filters live in a dedicated **Filters** section (`BoSectionMain` / `BoSectionSub` + `BoRow`) above the grid; **no Apply button**.
- [ ] **One primary retrieval contract** per dataset (rows / `TotalCount` / Nested View children / optional metadata); host-owned, never called from `BreezeOn.UI`.
- [ ] **Challenge secondary contracts** (especially a companion FilterOptions SP); require documented rationale; no generic schema/table/column distinct SPs.
- [ ] Simple distinct catalogs use **EF / app services** (`*FilterCatalog`); large drop-downs use `ItemsProvider` Top-N + server search; small sets may preload `Items`.
- [ ] Uses `BoQuery*` types (`BoQueryFilterOperator`: `In`, `Equals`, `Contains`); sort column **whitelist**; Filter → Sort → Pagination; `@FiltersJson` per [database.md](../database.md#filtersjson-schema).
- [ ] Text filters: ~750ms debounce / Enter / blur (skip unchanged); dropdown filters apply on change — [forms.md](controls/forms.md#filter-execution-query-driven).
- [ ] **`BoLatestWinsQuery`** (or equivalent) for grid queries **and** FilterCatalog loads; stale responses never update the UI.
- [ ] Server query grids: Server `QueryMode`, cache = current page, `TotalCount` from the primary contract, select-all = current page only — [grids.md](controls/grids.md#server-querymode). Client mode remains the default.
- [ ] Any exception (full-tree load, secondary contract) is documented.
- [ ] Gallery working example exists or is explicitly pending ([example-governance.md](example-governance.md)).

### Controls

- [ ] **`BoTextField`** for text entry — [forms.md](controls/forms.md#text-field-botextfield).
- [ ] **`BoDropDownList`** for Code/Description selection (panel search; `DisplayCode` / `AllowMultiple` as needed) — [forms.md](controls/forms.md#drop-down-list-bodropdownlist).
- [ ] **`BoCheckbox`** for boolean values (`Required` / `ReadOnly` Yes-No) — [forms.md](controls/forms.md#checkbox-bocheckbox).
- [ ] **`BoDateField`** for date / date-time — bind **`DateTime?` only** (never `DateOnly`); `Mode` Date or DateTime is UI-only; Date mode still persists midnight — [forms.md](controls/forms.md#date-field-bodatefield).
- [ ] **`BoNumberField`** for numbers — bind **`decimal?` only**; integer/decimals; `IsCurrency` / `IsPercent` mutually exclusive; percent UI 0–100 → bind ÷100; alignment default Right — [forms.md](controls/forms.md#number-field-bonumberfield).
- [ ] **`BoFieldReadOnly`** for display-only scalars (host formats `Value`) — [forms.md](controls/forms.md#read-only-field-bofieldreadonly).
- [ ] **`Weight`** when a field should be wider/narrower than neighbors (default 1) — [layout.md](layout/layout.md).
- [ ] **`BoEmptyField`** for permanent empty slots; **`IsHidden`** + optional **`PreserveLayoutWhenHidden`** for temporary hide — [layout.md](layout/layout.md). Do **not** confuse with Nested View **`PreserveNestedExpansionOnCacheReset`** ([grids.md](controls/grids.md)).
- [ ] Sections that participate in Submit validation set **`SectionKey`** — [sections.md](layout/sections.md).
- [ ] Planning JSON: shipped control names only (`TextField`, `ReadOnlyField`, `EmptyField`, `DateField`, `NumberField`, …; optional `weight` / `hidden` / `preserveLayoutWhenHidden` / `mode` / number flags) — [layout.md](layout/layout.md).

### Validation

- [ ] Deferred mandatory validation pattern respected (asterisk immediately; error chrome **after** attempt) — [forms.md § Deferred mandatory validation](controls/forms.md#deferred-mandatory-validation-locked).
- [ ] Required fields use standard behavior; **Disabled** fields skip required validation.
- [ ] Universal required message (`Validation_FieldRequired`); never field-label-specific.
- [ ] Fields expose `FieldKey` + `ValidationGroup` (tab); sections set `SectionKey` so failures report Field → Sub → Main → Tab.
- [ ] Submit integrates with **`BoValidationContext`** / **`IBoSubmitInterceptor`**. Prefer `Validate(null)` (all keep-alive groups).
- [ ] `Validate(group)` attempts only that group (unrelated groups show no required chrome); `Validate(null)` attempts all — [forms.md](controls/forms.md#deferred-mandatory-validation-locked). Host `ErrorText` marks a field invalid.
- [ ] Format numbers/dates with `IBoLocaleService.FormatCulture`, not ambient `CurrentCulture` — [i18n.md](foundations/i18n.md).
- [ ] Fail badges (`BoValidationFailBadge`) on failed tabs + Main/Sub headers in the **left icon slot** (replaces normal icon while failed); clear live when fields are fixed.
- [ ] Validation fail → **Alert** toast (Main + Body resources); do not open success Submit dialog on fail.
- [ ] New/changed field controls: follow [forms.md § Field component checklist](controls/forms.md#field-component-checklist).

### Localization

- [ ] Labels resolved through the **app’s own** `.resx` (Gallery `BoUi` is **not** a shared glossary for EAC or other apps) — [i18n.md](foundations/i18n.md).
- [ ] `AppTitle` and `Subtitle` localized.
- [ ] Dialog and toast text localized.
- [ ] Long-running ops use **`IBoPageFreezeService`** (`RunAsync` preferred); pass already-localized freeze messages; show outcome toasts **after** Hide; follow when / when-not rules — [overlays.md](shell/overlays.md) § Page freeze.
- [ ] New user-visible strings added to resources in the **same change set**.

### Theming

- [ ] Uses design tokens / CSS variables — [tokens.md](foundations/tokens.md).
- [ ] No ad-hoc hardcoded colors (derive from tokens; update `tokens.md` if a new independent token is intentional).
- [ ] Supports Light and Dark mode via **`IBoThemeModeService`** (dual palettes; same semantic names).
- [ ] Uses semantic Breeze On colors; nav-stable tokens (`nav-selected`, `nav-logo-divider`) stay Light values in both modes.
- [ ] Default typeface **Calibri** — [typography.md](foundations/typography.md).

### Documentation

When page structure introduces or changes **org** standards:

- [ ] Update STANDARDS documentation under `docs/ui/` (and ADRs when architecture changes).
- [ ] Update gallery / product examples where appropriate.
- [ ] Update UI overview indexes when new documentation files are added — [overview.md](overview.md).
- [ ] Same change set as code — [documentation.md](../documentation.md).

## Living document rule

This checklist is expected to evolve.

Whenever a new Breeze On page standard becomes established and is expected to be followed by future pages:

1. Update **this** checklist.
2. Keep it synchronized with implementation and the detailed responsibility docs.
3. Treat updates as part of **Definition of Done**.

This document should remain the quickest way for a human or AI agent to understand what constitutes a **compliant Breeze On page**.
