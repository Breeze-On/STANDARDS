<!-- Classification: AA; Scope: platform; Domain: UI; Capability: PageDevelopment -->
# UI — Page development checklist

Owner: UI

Single-page **implementation checklist** for developers and AI agents creating or modifying Breeze On pages that use `BreezeOn.UI`.

This document does **not** replace detailed standards. It is the authoritative **page-construction checklist** that points to the responsibility docs under `docs/ui/`. Current reality only.

**Entry / inventory:** [overview.md](overview.md). **Library:** [SYSTEM-SHARED-UI](https://github.com/Breeze-On/SYSTEM-SHARED-UI) (`BreezeOn.UI`). **Decision:** [ADR-004](../../decisions/ADR-004-breezeon-ui-abstraction-layer.md).

**Before you build:** pick the page shape in [page-archetypes.md](patterns/page-archetypes.md) (Home / List / Detail-Edit / Workspace / Error / Access Denied). **Parameters, events, and types** come from SHARED-UI [`public-component-api.md`](https://github.com/Breeze-On/SYSTEM-SHARED-UI/blob/main/docs/public-component-api.md) — do **not** read Razor for API ([parameter-reference.md](controls/parameter-reference.md)). **Working examples:** [gallery-index.md](gallery-index.md). **How strongly a rule binds:** [normative-tiers.md](foundations/normative-tiers.md) (Tier 1 LOCKED / 2 STANDARD / 3 GUIDANCE).

## Goals

- Improve consistency across applications.
- Reduce AI agent mistakes.
- Centralize page creation guidance.
- Ensure new pages follow Breeze On UI standards.
- Stay useful for both humans and AI agents.

## Product Host Contract (required)

**This section is the AA Product Host Contract** for every BreezeOn application that consumes `BreezeOn.UI`. Do not leave host onboarding spread only across architecture trees — wire the checklist here, then follow deep links for Identity/Auth/AuthZ detail.

### Reference model

| Reference | Role |
| --- | --- |
| **Gallery** (`SYSTEM-SHARED-UI` `App.razor` + `MainLayout`) | **UI chrome / asset reference only** — providers, shell, CSS/JS inventory. Does **not** demonstrate product authentication or authorization. |
| **EAC** (`SYSTEM-ADMIN-EAC` `Program.cs`, `App.razor`, `MainLayout`, `Routes`, page catalog) | **Complete product host reference** — UI + auth + AuthZ + page catalog + Data Protection + Error Message options + app-owned resources. |

### UI host requirements

| Concern | Requirement |
| --- | --- |
| Services | `services.AddBreezeOnUI()` or `AddBreezeOnUI(opts => …)` — registers Fluent internally; `configureTheme` via `IOptions<BoThemeOptions>` ([tokens.md](foundations/tokens.md#theme-options-addbreezeonuiconfiguretheme)) |
| Layout | **`BoThemeProvider`** → **`BoAppShell`** (nav + header + body + optional footer) → **`BoProviders`** (Fluent providers, theme/locale bootstrap, dialog + toast + **page-freeze**) |
| CSS (in `<head>`) | Fluent bundle CSS + `_content/BreezeOn.UI/breezeon-ui.css` |
| JS (in `<head>`) | **Seven** core scripts in the host-script inventory below; Shuffle optionals when used |

### Host-script inventory (SSOT)

**This table is the single authoritative host-script inventory.** Summaries elsewhere must match it. Do **not** load `bo-toggle.js` (retired).

| Script | Needed for |
| --- | --- |
| `bo-theme-mode.js` | Theme-mode cookie helpers; sets `document.documentElement.dataset.boThemeMode` |
| `bo-locale.js` | Locale cookie helpers for `bo-culture` / `bo-timezone` |
| `bo-popup.js` | Fixed-position panels for `BoDropDownList`, `BoPeoplePicker`, and `BoDateField` |
| `bo-number-field.js` | **Required for `BoNumberField`** (key filter, focus/blur bridge, display sync) |
| `bo-grid.js` | `BoGrid` truncated-cell hover titles + Add New first-editable focus |
| `bo-dialog.js` | **Required for `BoDialog`** |
| `bo-sliding-selection.js` | **Required for sliding `BoToggle` / `BoTabs` selection** (shared `boSlidingSelection`) |
| `js/lib/sortable.min.js` + `bo-sortable.js` | **Required for `BoShuffleCardGrid`** only |

Include **all seven** core `bo-*.js` scripts even if a page does not use every control. Paths: `_content/BreezeOn.UI/js/…`.

**Cache-busting:** Do **not** append `?v=` (or similar) query strings to Shared UI host scripts in product/Gallery `App.razor`. Script identity is the library file path; cache invalidation follows Shared UI package / ProjectReference updates. Remove any legacy `?v=` attributes when touching host markup.

**Maintenance DoD (same change set):** any host script **addition, removal, or rename** must update:

1. This section (`page-development.md` — SSOT)
2. [`overview.md`](overview.md) Host requirements summary
3. SHARED-UI [`public-component-api.md`](https://github.com/Breeze-On/SYSTEM-SHARED-UI/blob/main/docs/public-component-api.md) host assets list
4. Gallery `Components/App.razor`
5. EAC `Components/App.razor`

### Authentication requirements

| Concern | Requirement | Deep SSOT |
| --- | --- | --- |
| Registration | `AddBreezeOnAuthentication(configuration, …)` | [Identity & Authentication](../../architecture/identity-and-authentication/README.md) |
| Config | `AUTHENTICATION__AUTHORITY` / `CLIENTID` / `CLIENTSECRET` (User Secrets local; App Service hosted) | [configuration-standard.md](../../architecture/identity-and-authentication/configuration-standard.md) |
| Identity DB | Register `IBoIdentityConnectionFactory` (e.g. `AddBreezeOnSqlIdentityConnection`) against the shared customer database | [identity-schema-standard.md](../../architecture/identity-and-authentication/identity-schema-standard.md) |
| Endpoints | `MapBreezeOnAuthentication()` | [authentication-standard.md](../../architecture/identity-and-authentication/authentication-standard.md) |

### Authorization requirements

| Concern | Requirement | Deep SSOT |
| --- | --- | --- |
| Registration | `AddBreezeOnAuthorization(pageCatalog)` with the app’s page definitions | [Authorization](../../architecture/authorization/README.md) |
| Page catalog | Register **every** authenticated route; fail closed on miss | [page-security-standard.md](../../architecture/authorization/page-security-standard.md) |
| Route view | Host authenticated routing through **`BoAuthorizeRouteView`** | Same |
| Required groups | `RequiredGroupCodes` use platform Codes; empty = any authenticated user | Same |

### Product host requirements

| Concern | Requirement | Deep SSOT |
| --- | --- | --- |
| Data Protection | `AddDataProtection().SetApplicationName("<Product>")` (isolate purpose strings per app) | [session-standard.md](../../architecture/identity-and-authentication/session-standard.md) |
| Error Message options | `Configure<BoErrorMessageOptions>(o => o.ApplicationDisplayName = "…")` after `AddBreezeOnUI` | [error-messages.md](shell/error-messages.md) |
| Access Denied footer | Whenever `BoAccessDenied` is shown (route deny or in-page), **`BoAppShell.ShowFooter = false`** — MUST means implemented on the product host | [error-messages.md](shell/error-messages.md) |
| Localization | Supported cultures `en` / `fr` + `UseRequestLocalization()` | [i18n.md](foundations/i18n.md) |
| App-owned resources | Product `.resx` + locale-aware localizer; never use Gallery `BoUi` as the product glossary | [i18n.md](foundations/i18n.md) |

Platform consumption summary: [application-model.md](../application-model.md). Note: early scripts reduce theme/locale flash only partly; CSS variables are still emitted by `BoThemeProvider` after the circuit renders (see [tokens.md](foundations/tokens.md)).

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
- [ ] Footer behavior follows standards (`ShowFooter`; Home typically **false**; Error Message Pages **must** be **false**) — [shell.md](shell/shell.md), [error-messages.md](shell/error-messages.md).
- [ ] Error Message Pages follow the Error Message framework (shared `Bo*` + foundation CSS; no product-specific remediation in shared components; showcase ≡ production) — [error-messages.md](shell/error-messages.md).

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

Planning agents: emit **`schemaVersion "1"`** JSON per [layout.md](layout/layout.md#page-composition-json-planning-agent-input) (optional `weight` / `preserveLayoutWhenHidden`). The schema is **forms-only** ([layout.md § Schema scope](layout/layout.md#schema-scope-forms-only)): a `"sub"` section nests under the nearest preceding `"main"` section in Razor. Grids, Shuffle, Toggle, Tabs, Buttons, and panels are described in prose per [page-archetypes.md](patterns/page-archetypes.md), not in the JSON.

### Selection and navigation controls

Contract: [selection-and-navigation.md](controls/selection-and-navigation.md) (decision matrix, Selection Authority Model, keyboard / ARIA).

- [ ] Control chosen with the **decision matrix** — Left nav (routes) vs Drop-Down (record value) vs Toggle (2–4 modes) vs Tabs (page sections) vs Panel Navigation (10–30 workspace sections). Do **not** use Toggle as navigation or Tabs for field values.
- [ ] **Host owns selected state** (`SelectedToggleKey` / `SelectedTab` / `SelectedItem`); no optimistic UI.
- [ ] Guarded abandon points (Dirty State, permissions) use the **intent event** — `ToggleRequested` / `TabRequested` (`Cancel`) — **not** change-then-revert. Panel Navigation has no intent callback yet: keep the guard in one method (interim; FV-008).
- [ ] Tabs: `SelectedTab` bound on `BoTabs` **and** `BoTabPanels`; `TabKey` ≡ `ValidationGroup`; optional `AriaLabel`; keep `RenderAriaControls` on when panels exist.
- [ ] Toggle: **≥ 2** items, each with icon + label.
- [ ] Keyboard and ARIA behavior is the platform default — do not re-implement key handling in product code ([accessibility.md](foundations/accessibility.md)).

### Buttons and actions

Contract: [button.md](controls/button.md). Page-level Save / Discard: [actions-area.md](patterns/actions-area.md).

- [ ] Actions use `BoButton` / **`BoIconButton`** only — no raw `<button>`, no hex `BackgroundColor` for semantic roles.
- [ ] **One Primary per action group**; Secondary / Stealth for the rest; **Danger** (`BoButtonVariant.Danger`) for destructive actions; icon-only controls set `AriaLabel`.
- [ ] Order per [button.md § Ordering](controls/button.md#ordering-tier-2--standard) (dialog footer: Secondary then Primary; section / Actions area: Primary first).
- [ ] Editable working copy: **Actions area** with Save (Primary) + Discard (Secondary) above any Validation Summary; grids on that page set `ShowSave="false"`.
- [ ] Immediate irreversible deletes confirm in a `BoDialog` with a Danger confirm.

### Page states

- [ ] Empty / loading / error / toast mechanism per [page-states.md](patterns/page-states.md) — Page Freeze for perceptible work, Alert toast for validation failure, Error toast for system failure, no page-local overlays.

### Workspace panels (App Config / onboarding / admin)

When the page is a large multi-section **workspace** (not short header-tab page sections) — [panels.md](layout/panels.md):

- [ ] Chooses **`BoPanelNavigation`** (not header `BoTabs`) for 10–30 workspace sections.
- [ ] Uses **`BoPanelHost`** + **`BoPanel`** (`Dock` Left/Fill/Right) for independently scrolling regions.
- [ ] Pairs navigator with **`BoKeepAlivePanels` / `BoKeepAlivePanel`** (always mounted). **Do not** use `@if (SelectedItem == …)` for validated / long-lived sections.
- [ ] Sets nav item `Key` ≡ field `ValidationGroup` ≡ keep-alive `Key`.
- [ ] Does **not** invent a second Tabs framework or put content ownership on `BoPanelNavigation`.

### Grid Family (Planning / Dev — read first)

- [ ] Follow **[Grid Family Standards](controls/grids.md#grid-family-standards-locked)** for any Grid-family surface (`BoGrid`, `BoShuffleCardGrid`, future): reuse-first, Add New at top + first-editable focus, deferred validation, sort vs uncommitted precedence, accessibility.
- [ ] Do **not** invent a parallel Add New / focus / placement UX when a shipped helper already exists.

### Grid (section-level)

When the page includes a data grid:

- [ ] Uses **`BoGrid`** / **`BoGridColumn`** / **`BoGridCache`** — [grids.md](controls/grids.md).
- [ ] Lightweight column filters (optional): set `ShowFiltersButton` when needed; supply `FilterText` with the **displayed** string for textual columns; Client pipeline Filter → Sort → Page; Server hosts bind `ColumnFilters` → `BoQueryFilter` Contains — [grids.md § Filtering](controls/grids.md#filtering-lightweight--locked).
- [ ] Treats the grid as a **section-level** surface (not a `BoRow` child; not Section → Row → Field for the grid body).
- [ ] If multi-select is needed: `EnableSelection` (flat: Select All on the **column-header** row; scope = the **filtered working set** when column filters are active, otherwise all cache rows; Server mode = current page; Nested Scenario 1: `SelectedNodeKeys` + cascade select/expand) — [grids.md](controls/grids.md#row-selection), [selection-and-navigation.md](controls/selection-and-navigation.md#grid-selection-brief).
- [ ] Binds a typed cache with **`CacheId`**; rows expose **`CacheRowId`** + nullable **`PrimaryKey`**.
- [ ] Chooses **`Mode`**: ReadOnly (default), RowEdit, InlineEdit, or NestedView per requirements.
- [ ] **`IsPagination`** only when required (default false); sort is over the full cache; display order stays frozen while editing; uncommitted Add New stays at **top** — [grids.md § Sort](controls/grids.md#sort-locked).
- [ ] Column **`Align`**: text/date Left; number/currency Right unless the design requires otherwise. Headers always left.
- [ ] Column **`Width`**: leave default **Flex** unless Compact/Hug is intentional; do not invent custom table layouts.
- [ ] **Action / icon columns** (`Hug` row actions): `Title=""` — never a header label; keep `title` / `aria-label` on icon buttons — [grids.md](controls/grids.md).
- [ ] **`EnableHorizontalScroll`** only when many columns truly need a horizontal scrollbar (default false).
- [ ] Host loads **`_content/BreezeOn.UI/js/bo-grid.js`** when using `BoGrid` (truncated-cell hover titles + Add New first-editable focus).
- [ ] Cell editors reuse existing **`Bo*`** fields (inherit browser autocomplete **off**); do **not** put raw `<input>` in `Edit` — [grids.md](controls/grids.md), [forms.md § Browser autocomplete](controls/forms.md#browser-autocomplete-locked); column / grid **`Required`** follow [grids.md](controls/grids.md).
- [ ] Nested View: set `NodeKey`; same columns → `ChildrenSelector`; different columns → `ChildRowsHaveDifferentColumns` + `ChildGridTemplate` (nested `BoGrid`, not a new component). Optional `DefaultExpansionState`. Same-column Nested View may use `EnableSelection` with cascade. Keyword filters: follow [Nested View keyword filtering](controls/grids.md#nested-view-keyword-filtering-org-standard) unless a documented exception. See [grids.md Nested View](controls/grids.md#nested-view-locked--shipped).

### Shuffle Card Grid (section-level)

When the page needs **header + editable card rows + optional reorder** (not a table `BoGrid`):

- [ ] Uses **`BoShuffleCardGrid`** / **`BoShuffleCardGridColumn`** — [shuffle-card-grid.md](controls/shuffle-card-grid.md); inherits [Grid Family Standards](controls/grids.md#grid-family-standards-locked).
- [ ] Shuffle filtering (optional): `ShowFiltersButton` + `FieldKey`/`FilterText`; place Filters in section `HeaderActions` (rightmost after Add New) with `@bind-FiltersVisible` / `ToggleFiltersAsync()`; filter **card** chrome; reorder handle disabled while filters are active — [shuffle-card-grid.md § Filtering](controls/shuffle-card-grid.md#filtering-lightweight--locked).
- [ ] Treats it as a **section-level** surface (page-first; dialog hosts compose the same control).
- [ ] **Add New** (if any) lives in section **`HeaderActions`** and calls **`InsertNewAtTopAsync`** (not `_items.Add`) — [shuffle-card-grid.md](controls/shuffle-card-grid.md).
- [ ] Column headers: uppercase (CSS) + required `*` when needed; shared `WidthTrack` aligns header and fields; column `Align` applies to header **and** cell ([shuffle-card-grid.md](controls/shuffle-card-grid.md)).
- [ ] Reorder handle + row-action icons are **always leading** (first track) — no end-of-row / `ActionsPlacement` override ([shuffle-card-grid.md](controls/shuffle-card-grid.md)).
- [ ] Reorder motion follows platform tokens (`--bo-reorder-*`) — live FLIP while dragging; do not CSS-transition `transform` on rows; honor reduced-motion ([motion.md](foundations/motion.md)).
- [ ] Prefer `minmax(0, …)` tracks; cell editors reuse **`Bo*`** fields with **platform default placeholders** (not column titles); host owns validation and Dirty State.
- [ ] Host loads **`sortable.min.js`** + **`bo-sortable.js`** for reorder and **`bo-grid.js`** for Add New focus.

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

### UX conventions (Planning / Dev — read first)

Cross-control SSOT: [ux-conventions.md](patterns/ux-conventions.md). UI plans require a **UX Standards Compliance Review** before development.

- [ ] **Placeholders:** platform defaults only; do **not** echo labels/column titles; omit when Disabled — [ux-conventions.md](patterns/ux-conventions.md).
- [ ] **Truncation / width:** long closed values truncate (ellipsis + hover title); selected values must not resize controls or skew columns.
- [ ] **Disabled vs read-only vs N/A:** Disabled = temporary; prefer `BoFieldReadOnly` / Display for inherent read-only; hide N/A with `IsHidden`.
- [ ] **Navigation state:** major workspace / context change opens documented primary view; no inherited sub-state unless documented keep-alive.
- [ ] **Admin language:** no implementation identifiers in admin-facing copy.
- [ ] Before custom UX: confirm no existing Shared UI component, Gallery example, or documented pattern already solves the problem.

### Controls

- [ ] **`BoTextField`** for text entry — [forms.md](controls/forms.md#text-field-botextfield).
- [ ] **`BoDropDownList`** for Code/Description selection (panel search; `DisplayCode` / `AllowMultiple` as needed) — [forms.md](controls/forms.md#drop-down-list-bodropdownlist).
- [ ] **`BoPeoplePicker`** for BreezeOn **user** selection (Value = `UserGUID` / `;`-joined; active users only; Top-N 100) — [forms.md](controls/forms.md#people-picker-bopeoplepicker).
- [ ] **`BoCheckbox`** for boolean values (`Required` / `ReadOnly` Yes-No) — [forms.md](controls/forms.md#checkbox-bocheckbox).
- [ ] **`BoDateField`** for date / date-time — bind **`DateTime?` only** (never `DateOnly`); `Mode` Date or DateTime is UI-only; Date mode still persists midnight — [forms.md](controls/forms.md#date-field-bodatefield).
- [ ] **`BoNumberField`** for numbers — bind **`decimal?` only**; integer/decimals; `IsCurrency` / `IsPercent` mutually exclusive; percent UI 0–100 → bind ÷100; alignment default Right — [forms.md](controls/forms.md#number-field-bonumberfield).
- [ ] **`BoFieldReadOnly`** for display-only scalars (host formats `Value`) — [forms.md](controls/forms.md#read-only-field-bofieldreadonly).
- [ ] Browser autocomplete stays **off** by default on editable `Bo*` fields (`AutoComplete` opt-in only when needed) — [forms.md § Browser autocomplete](controls/forms.md#browser-autocomplete-locked).
- [ ] **`Weight`** when a field should be wider/narrower than neighbors (default 1) — [layout.md](layout/layout.md).
- [ ] **`BoEmptyField`** for permanent empty slots; **`IsHidden`** + optional **`PreserveLayoutWhenHidden`** for temporary hide — [layout.md](layout/layout.md). Do **not** confuse with Nested View **`PreserveNestedExpansionOnCacheReset`** ([grids.md](controls/grids.md)).
- [ ] Sections that participate in Submit validation set **`SectionKey`** — [sections.md](layout/sections.md).
- [ ] Planning JSON: shipped control names only (`TextField`, `ReadOnlyField`, `EmptyField`, `DateField`, `NumberField`, …; optional `weight` / `hidden` / `preserveLayoutWhenHidden` / `mode` / number flags) — [layout.md](layout/layout.md).

### Validation

- [ ] Deferred mandatory validation pattern respected (asterisk immediately; error chrome **after** attempt) — [forms.md § Deferred mandatory validation](controls/forms.md#deferred-mandatory-validation-locked).
- [ ] Multi-row editable BoGrid / Shuffle / bulk-edit Save failures use [Validation Summary](patterns/validation-summary.md) when the **Adoption Matrix** says Required (summary + chrome + Alert toast + navigate-to-error). Do not invent host `<ul>` error lists.
- [ ] Required fields use standard behavior; **Disabled** fields skip required validation.
- [ ] Universal required message (`Validation_FieldRequired`); never field-label-specific.
- [ ] Fields expose `FieldKey` + `ValidationGroup` (header tab **or** workspace panel-nav key); sections set `SectionKey` so failures report Field → Sub → Main → Tab/Panel.
- [ ] Submit integrates with **`BoValidationContext`** / **`IBoSubmitInterceptor`**. Prefer `Validate(null)` (all keep-alive groups, including inactive panel-nav sections).
- [ ] `Validate(group)` attempts only that group (unrelated groups show no required chrome); `Validate(null)` attempts all — [forms.md](controls/forms.md#deferred-mandatory-validation-locked). Host `ErrorText` marks a field invalid.
- [ ] Format numbers/dates with `IBoLocaleService.FormatCulture`, not ambient `CurrentCulture` — [i18n.md](foundations/i18n.md).
- [ ] Fail badges (`BoValidationFailBadge`) on failed tabs **or** `BoPanelNavigation` items + Main/Sub headers in the **left icon slot** (replaces normal icon while failed); clear live when fields are fixed.
- [ ] Validation fail → **Alert** toast (Main + Body resources); do not open success Submit dialog on fail.
- [ ] New/changed field controls: follow [forms.md § Field component checklist](controls/forms.md#field-component-checklist).

### Localization

- [ ] Labels resolved through the **app’s own** `.resx` (Gallery `BoUi` is **not** a shared glossary for EAC or other apps) — [i18n.md](foundations/i18n.md).
- [ ] `AppTitle` and `Subtitle` localized.
- [ ] Dialog and toast text localized.
- [ ] Product Create/Edit/Confirm/management dialogs use **`BoDialog`** (Enter = primary, Escape = `OnClose`, optional `InitialFocusFieldKey`, default focus restore). No local dialog chrome or autofocus JS — [overlays.md](shell/overlays.md) § Dialog.
- [ ] Long-running ops and **perceptible workspace/config hydrations** (including tab/panel activation that reloads data) use **`IBoPageFreezeService`** (`RunAsync` preferred); pass already-localized freeze messages; show outcome toasts **after** Hide; follow MUST / MUST NOT rules — [overlays.md](shell/overlays.md) § Page freeze; [ux-conventions.md](patterns/ux-conventions.md).
- [ ] Do **not** invent page-local loading overlays.
- [ ] New user-visible strings added to resources in the **same change set**.

### Theming

- [ ] Uses design tokens / CSS variables — [tokens.md](foundations/tokens.md).
- [ ] No ad-hoc hardcoded colors (derive from tokens; update `tokens.md` if a new independent token is intentional).
- [ ] Supports Light and Dark mode via **`IBoThemeModeService`** (dual palettes; same semantic names).
- [ ] Uses semantic Breeze On colors; nav-stable tokens (`nav-selected`, `nav-logo-divider`) stay Light values in both modes.
- [ ] **Button corner radius:** use Shared UI default (`--bo-button-radius`); do **not** override `border-radius` on `.bo-button` in product/page CSS — SSOT [button.md § Corner radius](controls/button.md#corner-radius--single-authority-tier-2).
- [ ] Default typeface **Calibri**; sizes from the type scale — [typography.md](foundations/typography.md). Spacing from `--bo-space-*` — [tokens.md § Spacing scale](foundations/tokens.md#spacing-scale). Motion from approved duration tokens — [motion.md](foundations/motion.md#approved-motion-tokens-tier-2).
- [ ] Icons through `BoIcon` at an approved size (16 / 20 / 24 / 32 / 48) — [icons.md](foundations/icons.md).
- [ ] Accessibility baseline (WCAG 2.2 AA; visible focus; accessible names; reduced motion) — [accessibility.md](foundations/accessibility.md).

### Documentation

When page structure introduces or changes **org** standards:

- [ ] Update STANDARDS documentation under `docs/ui/` (and ADRs when architecture changes).
- [ ] Update gallery / product examples where appropriate, and the [gallery-index.md](gallery-index.md) row (or [DEV-002](../deviations/DEV-002-example-governance-approved-exceptions.md) exception).
- [ ] Public API change → update SHARED-UI `public-component-api.md` in the same change set ([parameter-reference.md](controls/parameter-reference.md)).
- [ ] Update UI overview indexes when new documentation files are added — [overview.md](overview.md).
- [ ] Same change set as code — [documentation.md](../documentation.md).
- [ ] UI-bearing PRs: run [ux-pr-review-checklist.md](ux-pr-review-checklist.md).

## Living document rule

This checklist is expected to evolve.

Whenever a new Breeze On page standard becomes established and is expected to be followed by future pages:

1. Update **this** checklist.
2. Keep it synchronized with implementation and the detailed responsibility docs.
3. Treat updates as part of **Definition of Done**.

This document should remain the quickest way for a human or AI agent to understand what constitutes a **compliant Breeze On page**.
