<!-- Classification: AA; Scope: platform; Domain: UI; Capability: PageDevelopment -->
# UI standards — overview

Owner: UI

Entry point for Breeze On shared UI conventions. Standards are organized by **responsibility** under `docs/ui/` so the tree can grow without a single ever-expanding document.

Current reality only. Implementation lives in [SYSTEM-SHARED-UI](https://github.com/Breeze-On/SYSTEM-SHARED-UI) (`BreezeOn.UI`). Decision record: [ADR-004](../../decisions/ADR-004-breezeon-ui-abstraction-layer.md).

## Authority split (UX vs API)

Two documents, two jobs. Each fact has **one** home.

| Authority | Owns | Does **not** own |
| --- | --- | --- |
| **STANDARDS `docs/ui/`** (this tree) | UX, behavior, visual design, decision matrices ("which control?"), accessibility, page composition, tokens | The complete parameter / event / type list |
| **SHARED-UI [`docs/public-component-api.md`](https://github.com/Breeze-On/SYSTEM-SHARED-UI/blob/main/docs/public-component-api.md)** | **API surface only**: component inventory, every `[Parameter]` (name, type, default), events, enums, services, public methods, host assets | Any UX, behavior, visual, or accessibility rule |

**Gallery** (`BreezeOn.UI.Gallery`) demonstrates SHARED-UI usage. It is **not** a third authority for UX rules. STANDARDS remain SSOT; Gallery must match them — [example-governance.md](example-governance.md).

Consequences:

1. **Agents must not inspect Razor / C# source** to learn the public API — the parameter model is generated or CI-validated against SHARED-UI source ([controls/parameter-reference.md](controls/parameter-reference.md)).
2. STANDARDS control docs explain *why and how* a parameter is used; for completeness they **defer** to `public-component-api.md`.
3. The SHARED-UI README holds neither. Left navigation UX is [shell/navigation.md](shell/navigation.md).
4. Conflicts among STANDARDS docs are resolved by [Normative tiers § Precedence](foundations/normative-tiers.md#precedence). Conflicts between **Gallery and STANDARDS** are resolved by STANDARDS ([example-governance.md](example-governance.md)).

## Normative tiers

Every rule in `docs/ui/` binds at one of three tiers — full definition, change control, and precedence in [foundations/normative-tiers.md](foundations/normative-tiers.md):

| Tier | Name | Expectation | Compliance | Change |
| --- | --- | --- | --- | --- |
| **1** | **LOCKED** | Behavior / contract rules (selection authority, keyboard, validation flow, host contract, `Bo*`-only) | Mandatory; PR blocker | STANDARDS + owner approval + same-change-set API / Gallery / AI index; deviation only via [registered deviation](../deviations/README.md) |
| **2** | **STANDARD** | Org-default visual / structural conventions via tokens | Required by default; justified deviation in the UX Compliance Review | STANDARDS review + Gallery update |
| **3** | **GUIDANCE** | Recommendations, rationale, examples | Advisory | Edit freely |

Legacy words map onto tiers: "locked" / "hard standard" / **MUST** → Tier 1; "org standard" → Tier 2; "should" / "prefer" → Tier 3; a "locked" visual literal is Tier 2 with the **token** as authority.

## UI documentation index

| Document | Responsibility |
| --- | --- |
| [overview.md](overview.md) (this file) | Library contract, shipped inventory, gallery, documentation governance |
| [example-governance.md](example-governance.md) | Example Governance — normative + AI guidance + Gallery working example DoD |
| [page-development.md](page-development.md) | Page-construction checklist for humans and AI agents (links to detailed standards) |
| [application-bootstrap-checklist.md](../application-bootstrap-checklist.md) | **New Application Checklist** — authoritative bootstrap gate for new product apps |
| [ux-pr-review-checklist.md](ux-pr-review-checklist.md) | Short UX PR review checklist (Compliance Review, freeze, placeholders, truncation) |
| [gallery-index.md](gallery-index.md) | Pattern → Gallery path index; patterns without a demo (DEV-002) |
| **Foundations** | |
| [foundations/normative-tiers.md](foundations/normative-tiers.md) | Tier 1 LOCKED / Tier 2 STANDARD / Tier 3 GUIDANCE — compliance, change control, precedence |
| [foundations/tokens.md](foundations/tokens.md) | Design / shell tokens; spacing scale; corner radius; motion token index |
| [foundations/application-theme-palette.md](foundations/application-theme-palette.md) | Per-app Theme Palette model (three Step 1 brand colors → derived Light/Dark roles; platform-controlled tokens) |
| [foundations/motion.md](foundations/motion.md) | Platform motion — approved duration tokens, reorder FLIP / settle, selection travel, route transition tokens; reduced-motion; anti-patterns |
| [foundations/typography.md](foundations/typography.md) | Default typeface and type scale |
| [foundations/icons.md](foundations/icons.md) | Icon technology and approved sizes (16 / 20 / 24 / 32 / 48) |
| [foundations/accessibility.md](foundations/accessibility.md) | WCAG 2.2 AA target; keyboard / focus / contrast baseline |
| [foundations/i18n.md](foundations/i18n.md) | Culture / timezone cookies; per-app resource libraries; no hardcoded labels |
| **Shell** | |
| [shell/shell.md](shell/shell.md) | App shell chrome, footer, header tabs |
| [shell/application-branding.md](shell/application-branding.md) | Application Display Name (outside packages), Application Branding vs Customer Branding, Customer Logo asset model, Home subtitle rules, default page subtitles |
| [shell/error-messages.md](shell/error-messages.md) | Error Message Pages framework (Access Denied + future scenarios) |
| [layout/expandable-section.md](layout/expandable-section.md) | `BoExpandableSection` + shared disclosure engine; Section `IsCollapsible`; page-default expand only on page load |
| [shell/overlays.md](shell/overlays.md) | `BoDialog` (Enter/Escape, initial focus, focus restore), Settings, toasts, page freeze (`IBoPageFreezeService`) |
| [shell/navigation.md](shell/navigation.md) | Left navigation, route/URL matching |
| [shell/navigation-motion.md](shell/navigation-motion.md) | Navigation Motion Standard — shell-owned route / AE enter; compact AE press; reduced-motion |
| **Layout** | |
| [layout/sections.md](layout/sections.md) | Main Section / Sub Section |
| [layout/layout.md](layout/layout.md) | Row (`BoRow`) Weight + hidden/preserve layout, page composition, planning JSON schema |
| [layout/panels.md](layout/panels.md) | Workspace panels (`BoPanelHost` / `BoPanel` / `BoPanelNavigation` / `BoKeepAlivePanels`) |
| **Controls** | |
| [controls/forms.md](controls/forms.md) | Text Field, Text Area, Drop-Down List, People Picker, Date Field, and form controls |
| [controls/toggle.md](controls/toggle.md) | Segmented Toggle (`BoToggle`) — presentation-only; host-owned selection |
| [controls/selection-and-navigation.md](controls/selection-and-navigation.md) | Tabs vs Toggle vs Panel Navigation vs Drop-Down decision matrix; Selection Authority Model (intent-based); keyboard / ARIA |
| [controls/button.md](controls/button.md) | Buttons — hierarchy (Primary / Secondary / Danger / Stealth / Icon-only), ordering, destructive guidance, Save / Discard, radius authority |
| [controls/parameter-reference.md](controls/parameter-reference.md) | Parameter-model authority: complete API in `public-component-api.md`; component → API section map |
| [patterns/actions-area.md](patterns/actions-area.md) | Definition of the page / workspace **Actions** area (Save / Discard) |
| [patterns/page-states.md](patterns/page-states.md) | Empty / loading / error mechanisms; toast variant semantics |
| [patterns/page-archetypes.md](patterns/page-archetypes.md) | Home, List, Detail / Edit, Workspace, Error, Access Denied |
| [patterns/dirty-state.md](patterns/dirty-state.md) | Centralized unsaved-changes gate (Save / Discard / Cancel) — platform concept, EAC reference implementation |
| [patterns/import-summary.md](patterns/import-summary.md) | Import Summary review dialog (`BoImportSummaryDialog`) — Changes Summary + Errors/Warnings; explicit confirm |
| [patterns/validation-summary.md](patterns/validation-summary.md) | Validation Summary (`BoValidationSummary`) — live-editor collapsible errors above grids/Shuffle; Adoption Matrix; [ADR-021](../../decisions/ADR-021-validation-summary-experience.md) |
| [patterns/ux-conventions.md](patterns/ux-conventions.md) | Cross-control UX conventions — placeholders, truncation, disabled/read-only, navigation state, Page Freeze summary, UX Compliance Review |
| [patterns/process-request-section.md](patterns/process-request-section.md) | Mandatory **Process Request** section (General Information tab; Initiator + Requested Date); application-owned implementation |
| [patterns/initiation-experience.md](patterns/initiation-experience.md) | Default New Request initiation chrome (Form icon, footer Save+Submit, Process Request) |
| [patterns/page-footer-actions.md](patterns/page-footer-actions.md) | Shell footer **`BoPageFooterActions`** (Save Filled icon + Submit Primary) |
| [patterns/process-persistence.md](patterns/process-persistence.md) | Save/Submit → `Global.Process` + extension; freeze ≥1500ms; redirect to Process View |
| [patterns/process-view.md](patterns/process-view.md) | Terminal read-only Process View (`AE` + `PGUID`); Application Error on hydrate failure |
| [controls/grids.md](controls/grids.md) | Grid Family Standards + `BoGrid` — Read-Only / Row Edit / Inline Edit / Nested View; Server `QueryMode`; Add New top + focus |
| [controls/shuffle-card-grid.md](controls/shuffle-card-grid.md) | Shuffle Card Grid (`BoShuffleCardGrid`) — Grid-family card + DnD; premium reorder motion ([motion.md](foundations/motion.md)); `InsertNewAtTopAsync`; inherits Family Standards |
| [controls/query-driven-retrieval.md](controls/query-driven-retrieval.md) | Query-driven retrieval — one primary contract per dataset; Filter → Sort → Page; debounce, cancellation, Top-N, exceptions ([ADR-008](../../decisions/ADR-008-query-driven-data-retrieval.md)) |

Former single file [`docs/ui-components.md`](../ui-components.md) redirects here. Flat paths under `docs/ui/*.md` (e.g. `docs/ui/tokens.md`) redirect to the hierarchical files above.

## Shared library (current)

| | |
| --- | --- |
| Repository | [Breeze-On/SYSTEM-SHARED-UI](https://github.com/Breeze-On/SYSTEM-SHARED-UI) |
| Package / project | `BreezeOn.UI` (`src/BreezeOn.UI`) |
| Approach | Option B+: BreezeOn public API on top of Fluent UI Blazor (Fluent is internal) |
| Registration | `services.AddBreezeOnUI()` or `AddBreezeOnUI(configureTheme)` — `configureTheme` is honored via `IOptions<BoThemeOptions>` ([tokens.md § Theme options](foundations/tokens.md#theme-options-addbreezeonuiconfiguretheme)) |
| Host requirements | **Product Host Contract** (UI + auth + AuthZ + catalog + branding + Error Message options): [page-development.md § Product Host Contract](page-development.md#product-host-contract-required). UI assets: `BoThemeProvider` / `BoProviders` / `BoAppShell`; Fluent + `breezeon-ui.css`; **eight** core scripts (`bo-theme-mode`, `bo-branding`, `bo-locale`, `bo-popup`, `bo-number-field`, `bo-grid`, `bo-dialog`, `bo-sliding-selection`; plus Sortable + `bo-sortable` when using Shuffle Card). Gallery = chrome/assets reference; EAC = complete product host. |
| Decision record | [ADR-004](../../decisions/ADR-004-breezeon-ui-abstraction-layer.md) |

Product applications must use **`BreezeOn.UI`** components (`Bo*`). Do not reference `Microsoft.FluentUI.AspNetCore.Components` types from product pages.

Dependency position (landscape): [architecture/landscape.md](../../architecture/landscape.md).

## Shipped components

Inventory with UX pointers only. **Parameters, events, and types** for every component below: SHARED-UI [`public-component-api.md`](https://github.com/Breeze-On/SYSTEM-SHARED-UI/blob/main/docs/public-component-api.md) ([Authority split](#authority-split-ux-vs-api)).

| Component | Purpose | Detail |
| --- | --- | --- |
| Design tokens / `BoThemeProvider` | CSS variables and theme options (palette, spacing, radius, typography, shell tokens, warning/info/scrim, z-index, focus ring); dual Light/Dark palettes; `configureTheme` via `IOptions<BoThemeOptions>` | [tokens.md](foundations/tokens.md), [typography.md](foundations/typography.md) |
| `IBoThemeModeService` | `ThemeMode` + active palette; cookie `bo-theme-mode` restore via `BoProviders` bootstrap | [tokens.md](foundations/tokens.md) |
| `BoProviders` | Hosts Fluent providers, theme/locale bootstrap, dialog / toast / page-freeze hosts | [tokens.md](foundations/tokens.md), [i18n.md](foundations/i18n.md), [shell.md](shell/shell.md), [overlays.md](shell/overlays.md) |
| `IBoLocaleService` | Culture + IANA timezone; cookies `bo-culture` / `bo-timezone`; `FormatCulture` (en-CA / fr-CA) + `UiCulture`; no process-wide culture mutation | [i18n.md](foundations/i18n.md) |
| `IBoBrandingService` | Customer Name + Customer/Application logos (`CustomerLogoSrc` → nav/favicon; `LogoMinimizedSrc` for page freeze) | [navigation.md](shell/navigation.md), [overlays.md](shell/overlays.md), [application-branding.md](shell/application-branding.md) |
| `BoAppShell` | Option B app chrome: full-height nav + header / body / footer column | [shell.md](shell/shell.md) |
| `BoShellCard` | Floating card chrome (border, shadow, `card-container-background`); margin density Shell/Content/None | [shell.md](shell/shell.md), [tokens.md](foundations/tokens.md) |
| `BoNavPane` / `BoNavLink` | Left navigation; collapses to a narrow icon rail (labels visually hidden; `BoNavLink.Title` tooltip when collapsed; localized `Chrome_Aria_Nav*`); bottom collapse control; prefer `IconContent` with `BoIcon` | [navigation.md](shell/navigation.md) |
| `BoIcon` | Public icon API (`Name`, `BoIconVariant`, `Size`); resolves Fluent System Icons internally | [navigation.md](shell/navigation.md) |
| `BoAppHeader` | Top header card; titles + trailing actions; optional `TabsContent` / `ActionsContent` | [shell.md](shell/shell.md) |
| `BoHeaderActions` | Theme switch + Settings + Profile cluster | [shell.md](shell/shell.md) |
| `BoThemeSwitch` | Apple-style Light/Dark switch (`BrightnessLow` icon) | [shell.md](shell/shell.md), [tokens.md](foundations/tokens.md) |
| `BoProfileMenu` | Avatar (initials; photo store via Identity) + Sign out via Account endpoints | [shell.md](shell/shell.md) |
| `BoTabs` / `BoTab` | Optional page-section tabs under the header title row; `TabRequested` intent (veto) + `SelectedTabChanged`; keyboard roving focus | [shell.md](shell/shell.md), [selection-and-navigation.md](controls/selection-and-navigation.md) |
| `BoTabPanels` / `BoTabPanel` | Keep-alive body sections keyed to tabs (`SelectedTab`) | [shell.md](shell/shell.md) |
| `BoPanelHost` / `BoPanel` | Independently scrolling workspace layout regions (`Dock` Left/Right/Fill); not coupled to `BoAppBody` | [panels.md](layout/panels.md) |
| `BoPanelNavigation` | Navigator-only workspace section list (card chrome + validation badges); 10–30 items | [panels.md](layout/panels.md) |
| `BoKeepAlivePanels` / `BoKeepAlivePanel` | Generic keyed keep-alive content host (pair with panel nav; not a second Tabs framework) | [panels.md](layout/panels.md) |
| `BoAppBody` | Scrollable body region content host (scrolls inside body card) | [shell.md](shell/shell.md) |
| `BoAppFooter` | Bottom footer card (optional per page via `ShowFooter`; shorter inside padding) | [shell.md](shell/shell.md) |
| `BoAccessDenied` | Styled Access Denied body (`.bo-error-message*` foundation; Access/Support Details; localized); used by `BoAuthorizeRouteView` and Gallery Error Message Page | [error-messages.md](shell/error-messages.md) |
| `BoCard` | Content card with optional title/footer; uses `card-container-*` tokens; optional `MarginDensity` | [tokens.md](foundations/tokens.md) |
| `BoNavHub` | Home hub host (~33%·67%, gradient + dots, brand logo `80cqmin`) | [shell.md](shell/shell.md#home--navigation-hub-locked-platform-pattern) |
| `BoNavCardStyleHyperlink` | Home destination card (internal SPA or external new-tab); card chrome Tier 2 (tokens), internal / external link behavior Tier 1 | [shell.md](shell/shell.md#home--navigation-hub-locked-platform-pattern) |
| `BoSectionMain` | **Main Section** — optional header; `SectionKey` for validation fail badge / ancestry; optional `IsCollapsible` / `Expanded` | [sections.md](layout/sections.md) |
| `BoSectionSub` | **Sub Section** — nested grouping; `SectionKey` + cascaded Main/Sub keys to fields; optional `IsCollapsible` / `Expanded` | [sections.md](layout/sections.md) |
| `BoExpandableSection` | Disclosure expand/collapse (Error Message, filters, support blocks); shared engine with Section collapse | [expandable-section.md](layout/expandable-section.md) |
| `BoRow` | **Row** — proportional `Weight` field slots inside a section (default equal) | [layout.md](layout/layout.md) |
| `BoStack` | Vertical or horizontal stack layout | [sections.md](layout/sections.md) |
| `BoPageHeader` | Page title and description | — |
| `BoFieldReadOnly` | Flat read-only display field (pre-formatted string `Value`; same label chrome as Text Field; `Alignment`; optional `LinkifyUrls`) | [forms.md](controls/forms.md) |
| `BoEmptyField` | Empty `BoRow` alignment slot (no label/value) | [layout.md](layout/layout.md), [forms.md](controls/forms.md) |
| `BoTextField` | Text input (default Placeholder; `ReadOnly`; deferred mandatory validation; `ErrorText` → invalid) | [forms.md](controls/forms.md) |
| `BoTextArea` | Multiline plain-text area (MaxLength default 4000; character count default on; fixed 6-row initial height; vertical resize; read-only linkify; read-only + `ShowLabel` → section-header-matching label divider) | [forms.md](controls/forms.md#text-area-botextarea) |
| `BoDropDownList` | Searchable Code/Description Drop-Down (`Items` or async `ItemsProvider` Top-N; `DisplayCode`, `AllowMultiple` chips, panel search) | [forms.md](controls/forms.md) |
| `BoPeoplePicker` | Platform user selector (composes Drop-Down List; Value = `UserGUID` / `;`-joined; active users only; Top-N 100) | [forms.md](controls/forms.md) |
| `BoLatestWinsQuery` | Host latest-wins / cancel / optional signature skip for queries and FilterCatalog loads | [query-driven-retrieval.md](controls/query-driven-retrieval.md) |
| `BoNestedViewKeywordFilter` | Client Nested View keyword Rules 1–3 (filtered tree + path-minimal expand keys) | [grids.md](controls/grids.md#nested-view-keyword-filtering-org-standard) |
| `BoCheckbox` | Boolean (`Required` / `ReadOnly` Yes-No) | [forms.md](controls/forms.md) |
| `BoDateField` | Date / DateTime UI; bound type always `DateTime?` (never `DateOnly`); `ReadOnly`; locale (`FormatCulture`) + fixed calendar popover | [forms.md](controls/forms.md) |
| `BoDateDisplay` | Format culture for wall-clock values (`Format`); UTC→user timezone + culture for instants (`FormatUtc`) — standard for grids / read-only datetime text | [i18n.md](foundations/i18n.md) |
| `BoNumberField` | Number UI; bound type always `decimal?`; integer/decimals; currency/% (mutex); focus raw / blur formatted; `ReadOnly` flat display uses same `BoNumberDisplay.Format`; alignment default Right; needs host `bo-number-field.js` when editable | [forms.md](controls/forms.md) |
| `BoButton` | Button (`BoButtonVariant`: Primary / Secondary / Stealth / **Danger**); corner radius `--bo-button-radius`; `HtmlType` (`BoButtonType`); optional icon | [button.md](controls/button.md) |
| `BoIconButton` | Icon-only button (required `AriaLabel`; default Stealth; any `BoButtonVariant`) | [button.md](controls/button.md) |
| `BoToggle` | Presentation-only segmented toggle; host-owned `SelectedToggleKey`; `ToggleRequested` intent; required icon+label per item; sliding selection pill via shared `bo-sliding-selection.js` | [toggle.md](controls/toggle.md), [selection-and-navigation.md](controls/selection-and-navigation.md) |
| `BoDialog` / `BoDialogCloseButton` | Product dialog shell (Enter/Escape, `InitialFocusFieldKey`, focus restore) | [overlays.md](shell/overlays.md) |
| `BoImportSummaryDialog` | Presentational Import Summary (Changes Summary + Errors/Warnings; Stealth confirm; `ChangesSummaryContent`) | [import-summary.md](patterns/import-summary.md) |
| `BoValidationSummary` / `BoValidationIssue` | Live-editor collapsible validation summary above grids/Shuffle; navigate-to-error; Adoption Matrix | [validation-summary.md](patterns/validation-summary.md) |
| `BoDialogService` | Message dialog facade (`ShowMessageAsync`; hosted via `BoDialog`) | [overlays.md](shell/overlays.md) |
| `IBoToastService` / `BoToastHost` | Top-right toasts (Main/Body; Success / Alert / Information / Error; click dismiss) | [shell.md](shell/shell.md), [overlays.md](shell/overlays.md) |
| `IBoPageFreezeService` / `BoPageFreezeHost` | Full-viewport busy freeze (branded pulse + frosted scrim; `Show`/`Hide`/`RunAsync`; ref-counted) | [overlays.md](shell/overlays.md) |
| `BoValidationContext` / `IBoSubmitInterceptor` | Deferred validation; `Validate(null)` attempts all groups, `Validate(group)` only that group (`IsAttempted(group)`); live fail badges; Field→Sub→Main→Tab failures | [forms.md](controls/forms.md) |
| `BoValidationFailBadge` | Red disc + white “!” (tabs + section headers) | [forms.md](controls/forms.md) |
| `BoSettingsDialogService` | Centered Settings dialog (Language / Timezone via `BoDropDownList`) | [shell.md](shell/shell.md), [i18n.md](foundations/i18n.md), [overlays.md](shell/overlays.md) |
| `BoGrid` / `BoGridColumn` / `BoGridCache` | Section-level grid (ReadOnly / RowEdit / InlineEdit / NestedView); optional `EnableSelection`; typed cache; frozen sort with uncommitted Add New at top; Nested View; Add New → first-editable focus; **Grid Family Standards** SSOT | [grids.md](controls/grids.md#grid-family-standards-locked) |
| `BoShuffleCardGrid` / `BoShuffleCardGridColumn` | Grid-family card + DnD renderer; inherits Family Standards; host Add → `InsertNewAtTopAsync`; leading-only handle/icons; page-first; `sortable.min.js` + `bo-sortable.js` + `bo-grid.js` | [shuffle-card-grid.md](controls/shuffle-card-grid.md) |
| `BoSectionMain` / `BoSectionSub` `Required` | Optional red asterisk after section title (e.g. mandatory grid) | [sections.md](layout/sections.md), [grids.md](controls/grids.md) |

## Local gallery

`src/BreezeOn.UI.Gallery` in SYSTEM-SHARED-UI runs a local Interactive Server host (`dotnet run` in that project). Full **pattern → Gallery path** index (including patterns without a demo): **[gallery-index.md](gallery-index.md)**.

| Gallery page | Route | Contents | Standards |
| --- | --- | --- | --- |
| **Home** | `/` | `BoNavHub` hub; footer off | [shell.md](shell/shell.md) |
| **Components** | `/components` | Header tabs: Text Field, Text Area, Drop-Down List, People Picker, Checkbox, Date Field, Number Field, **Other**. Main → Parameters / Preview / Documentation; Parameters rows have 6 `BoRow` slots (pad with `BoEmptyField`); Preview = editable \| read-only \| Backend Value; Submit = `Validate(null)` + Alert toast + fail badges | [forms.md](controls/forms.md), [layout.md](layout/layout.md) |
| **Components → Other** | `/components` | Workspace `BoPanelHost` + `BoPanelNavigation` + `BoKeepAlivePanels` (demo vehicle for [panels.md](layout/panels.md), not the design target). Items: **Grid** (incl. Server `QueryMode`, Filters, Nested keyword, Grid Type = Shuffle Card), **Page Freeze**, **Dialog**, **Toggle**, **Import Summary**, **Validation Summary**, **Button** (variants, `BoIconButton`, Tabs keyboard + `TabRequested`) | [grids.md](controls/grids.md), [overlays.md](shell/overlays.md), [toggle.md](controls/toggle.md), [button.md](controls/button.md) |
| **Theme** | `/theme` | Light + Dark Main sections per palette color | [tokens.md](foundations/tokens.md) |
| **Error Message Page** | `/error-message-page` | Access Denied tab (shared `BoAccessDenied`); footer off | [error-messages.md](shell/error-messages.md) |

Nav: Home / Components / Theme / Error Message Page (starts collapsed). URL = page name — [navigation.md](shell/navigation.md).

**Ownership:** Gallery is the primary working-example host for library-scoped UI / query patterns. Product pages are product reference only. Full rules: [example-governance.md](example-governance.md).

## Documentation governance

Documentation is part of **completion criteria** (same change set as code). Current reality only — never document planned components as shipped. Org DoD: [documentation.md](../documentation.md#definition-of-done). UI / query standards also follow [Example Governance](example-governance.md) (normative + AI guidance + Gallery example).

### When new shared components are introduced

For every new or changed public `Bo*` surface:

1. Add or update the inventory row in this overview.
2. Document rules in the appropriate responsibility file under `foundations/`, `shell/`, `layout/`, or `controls/` (create a focused sibling if needed).
3. Update [page-development.md](page-development.md) when the change affects how pages must be built (checklist living-document rule).
4. Update the gallery when the component is previewable ([example-governance.md](example-governance.md)).
5. Update STANDARDS indexes (`README.md`, `README_AI.md`, this overview) and any product README / README_AI links in the same change set.
6. New feature / parameter / UX or design-standard change / behavior-affecting refactor → documentation in the **same change set** (UI component DoD).

### Organic structure rule

When a UI document becomes too large or covers multiple independent concerns, split by responsibility under the folders above and update this index. Prefer deepening the hierarchy over a flat list of ever-larger files.
