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
- [ ] Do not invent free-floating fields or custom grids. For reserved columns use **`IsHidden`** or **`BoEmptyField`** — not `display: none` / not a separate `columnCount` parameter.

Planning agents: emit **`schemaVersion "1"`** JSON per [layout.md](layout/layout.md#page-composition-json-planning-agent-input); nest Sub Sections in Razor even when flat JSON is used.

### Grid (section-level)

When the page includes a data grid:

- [ ] Uses **`BoGrid`** / **`BoGridColumn`** / **`BoGridCache`** — [grids.md](controls/grids.md).
- [ ] Treats the grid as a **section-level** surface (not a `BoRow` child; not Section → Row → Field for the grid body).
- [ ] Binds a typed cache with **`CacheId`**; rows expose **`CacheRowId`** + nullable **`PrimaryKey`**.
- [ ] Chooses **`Mode`**: ReadOnly (default), RowEdit, InlineEdit, or NestedView per requirements.
- [ ] **`IsPagination`** only when required (default false); sort is over the full cache; display order stays frozen while editing.
- [ ] Column **`Align`**: text/date Left; number/currency Right unless the design requires otherwise. Headers always left.
- [ ] Column **`Width`**: leave default **Flex** unless Compact/Hug is intentional; do not invent custom table layouts.
- [ ] **`EnableHorizontalScroll`** only when many columns truly need a horizontal scrollbar (default false).
- [ ] Host loads **`_content/BreezeOn.UI/js/bo-grid.js`** when using truncated display cells (hover full-value title).
- [ ] Cell editors reuse existing **`Bo*`** fields; column / grid **`Required`** follow [grids.md](controls/grids.md).
- [ ] Nested View: set `NodeKey`; same columns → `ChildrenSelector`; different columns → `ChildRowsHaveDifferentColumns` + `ChildGridTemplate` (nested `BoGrid`, not a new component). Optional `DefaultExpansionState`. See [grids.md Nested View](controls/grids.md#nested-view-locked--shipped).

### Controls

- [ ] **`BoTextField`** for text entry — [forms.md](controls/forms.md#text-field-botextfield).
- [ ] **`BoDropDownList`** for Code/Description selection (panel search; `DisplayCode` / `AllowMultiple` as needed) — [forms.md](controls/forms.md#drop-down-list-bodropdownlist).
- [ ] **`BoCheckbox`** for boolean values (`Required` / `ReadOnly` Yes-No) — [forms.md](controls/forms.md#checkbox-bocheckbox).
- [ ] **`BoDateField`** for date / date-time — bind **`DateTime?` only** (never `DateOnly`); `Mode` Date or DateTime is UI-only; Date mode still persists midnight — [forms.md](controls/forms.md#date-field-bodatefield).
- [ ] **`BoNumberField`** for numbers — bind **`decimal?` only**; integer/decimals; `IsCurrency` / `IsPercent` mutually exclusive; percent UI 0–100 → bind ÷100; alignment default Right — [forms.md](controls/forms.md#number-field-bonumberfield).
- [ ] **`BoFieldReadOnly`** for display-only scalars (host formats `Value`) — [forms.md](controls/forms.md#read-only-field-bofieldreadonly).
- [ ] **`BoEmptyField`** / **`IsHidden`** for reserved alignment slots — [layout.md](layout/layout.md).
- [ ] Sections that participate in Submit validation set **`SectionKey`** — [sections.md](layout/sections.md).
- [ ] Planning JSON: shipped control names only (`TextField`, `ReadOnlyField`, `EmptyField`, `DateField`, `NumberField`, …; optional `hidden` / `mode` / number flags) — [layout.md](layout/layout.md).

### Validation

- [ ] Deferred mandatory validation pattern respected (asterisk immediately; error chrome **after** attempt) — [forms.md § Deferred mandatory validation](controls/forms.md#deferred-mandatory-validation-locked).
- [ ] Required fields use standard behavior; **Disabled** fields skip required validation.
- [ ] Universal required message (`Validation_FieldRequired`); never field-label-specific.
- [ ] Fields expose `FieldKey` + `ValidationGroup` (tab); sections set `SectionKey` so failures report Field → Sub → Main → Tab.
- [ ] Submit integrates with **`BoValidationContext`** / **`IBoSubmitInterceptor`**. Prefer `Validate(null)` (all keep-alive groups).
- [ ] Fail badges (`BoValidationFailBadge`) on failed tabs + Main/Sub headers in the **left icon slot** (replaces normal icon while failed); clear live when fields are fixed.
- [ ] Validation fail → **Alert** toast (Main + Body resources); do not open success Submit dialog on fail.
- [ ] New/changed field controls: follow [forms.md § Field component checklist](controls/forms.md#field-component-checklist).

### Localization

- [ ] Labels resolved through the **app’s own** `.resx` (Gallery `BoUi` is **not** a shared glossary for ADM or other apps) — [i18n.md](foundations/i18n.md).
- [ ] `AppTitle` and `Subtitle` localized.
- [ ] Dialog and toast text localized.
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
