<!-- Classification: AA; Scope: platform; Domain: UI; Capability: ShellNavigation -->
# UI — App shell

Owner: UI

App chrome standards for applications using `BreezeOn.UI`. Related: [navigation.md](navigation.md), [navigation-motion.md](navigation-motion.md), [tokens.md](../foundations/tokens.md), [overview.md](../overview.md).

## `BoAppShell` (required)

`BoAppShell` is required for apps using this library (Option B: floating nav + header + body + optional footer cards). Product apps compose pages inside the shell; they do not invent alternate chrome.

| Region | Component | Role |
| --- | --- | --- |
| Left nav | `BoNavPane` / `BoNavLink` | Platform navigation — see [navigation.md](navigation.md) |
| Header | `BoAppHeader` | Top header card; **per-page** `AppTitle` / `Subtitle` (host-localized); trailing actions; optional `TabsContent` |
| Body | `BoAppBody` | Body region inside a floating card; card **fills** the available shell viewport slot; when content exceeds the slot, scroll **inside** the body (`overflow: auto` on `BoAppBody`). **Platform rule:** containers must provide scrollbars when content exceeds their bounds — do not use `overflow: hidden` on `BoAppBody` except intentional exceptions (e.g. Home / nav hub; **visible** workspace `BoPanelHost` — see [panels.md](../layout/panels.md)). Home / nav hub / visible panel host: card fills the slot with **no** body scrollbar (panels scroll independently). Hosts inside **hidden** keep-alive tab panels must not disable body scroll for other tabs. **Owns shell navigation motion** (pathname / `AE` enter) — [navigation-motion.md](navigation-motion.md); product apps must not fork route transitions |
| Footer | `BoAppFooter` | Optional per page (`ShowFooter`); when shown, fixed bottom footer card |

### Navigation motion (shell-owned)

Route / Application Context page transitions are injected automatically through `BoAppShell` → `BoAppBody`. Product applications inherit them by consuming SHARED-UI; they must not create competing route-transition implementations. Full standard: [navigation-motion.md](navigation-motion.md).

`BoShellCard` provides floating card chrome (border, shadow, `card-container-background`); margin density Shell/Content/None. Token names: [tokens.md](../foundations/tokens.md).

Public `Bo*` API / host-integration parameters: [SYSTEM-SHARED-UI `docs/public-component-api.md`](https://github.com/Breeze-On/SYSTEM-SHARED-UI/blob/main/docs/public-component-api.md). UX/behavior SSOT remains this STANDARDS `docs/ui/` tree.

## Header actions (locked)

Title row is a flex row: **titles (left)** | **actions (right)**, vertically center-aligned. Default actions via `BoHeaderActions` (override with `BoAppHeader.ActionsContent` when needed).

Order left → right:

| Control | Component | Behavior (current) |
| --- | --- | --- |
| Light / Dark theme | `BoThemeSwitch` | Apple-style switch; `BrightnessLow` (Regular) icon left of track; toggles `IBoThemeModeService` (persists `bo-theme-mode` cookie; see [tokens.md](../foundations/tokens.md)) |
| Settings | Settings icon button in `BoHeaderActions` | Opens centered `BoSettingsDialogHost`: one Main Section **Settings**, two `BoRow`s with `BoDropDownList` (Language, Timezone); apply-on-change via `IBoLocaleService` |
| Profile | `BoProfileMenu` | Circular avatar (initials fallback; platform stores login-refreshed photos in `Identity.UserPhotos`); menu with **Sign out** via SHARED-UI Account endpoints |

Theme mode / dual palettes: [tokens.md](../foundations/tokens.md). Locale prefs: [i18n.md](../foundations/i18n.md).

## Header titles (per-page)

`AppTitle` and `Subtitle` are **per page**, supplied by the host from that app’s resource library (Gallery: `BoUi` keys such as `Home_Header_AppTitle`). Do not hardcode user-visible strings.

| Concern | Standard |
| --- | --- |
| `AppTitle` | Required for normal pages; localized. On **Home**, use the **Application Display Name** — [application-branding.md](application-branding.md) |
| `Subtitle` | Optional on most pages; when null/whitespace, **omit** the `  -  ` separator (implemented in `BoAppHeader`). On **Home**, subtitle is **omitted by default** (do not supply a Home subtitle) — [application-branding.md](application-branding.md) |
| Dash | Shown only between a non-empty title and a non-empty subtitle |

## App shell footer (optional per page)

Footer is **optional per page** via `BoAppShell.ShowFooter` (default `true`). When `ShowFooter` is true, use the fixed bottom footer shell region (`BoAppFooter` / `FooterContent`) — same floating-card chrome family as the header. When false, omit the footer region (gallery: Home and Error Message Page have no footer; Components / Theme keep it).

**Error Message Pages** (Access Denied and future standardized error states) **must** use `ShowFooter = false` to keep focus on the error experience. Product hosts that render `BoAccessDenied` (via `BoAuthorizeRouteView` or in-page) **must** suppress the footer — EAC implements this as the product host reference ([page-development.md](../page-development.md#product-host-contract-required)).

## Header tabs (optional page sections)

Pages **may omit** tabs. When present, use `BoAppHeader.TabsContent` with `BoTabs` / `BoTab` and body `BoTabPanels` / `BoTabPanel`. Tabs are page sections, not left-nav routes. **Choosing Tabs vs Toggle vs Panel Navigation, the selection authority model (`TabRequested` intent / `SelectedTabChanged`), and keyboard / ARIA:** [selection-and-navigation.md](../controls/selection-and-navigation.md). Parameters: [`public-component-api.md` § BoTabs](https://github.com/Breeze-On/SYSTEM-SHARED-UI/blob/main/docs/public-component-api.md#botabs). For large multi-section **workspace** navigation (App Config, onboarding, admin), use `BoPanelNavigation` + `BoKeepAlivePanels` instead — [panels.md](../layout/panels.md). Do not conflate header tabs with workspace panel navigation.

**Section-hosted tabs:** When `BoTabs` is placed inside a `BoSectionMain` / `BoSectionSub` body (e.g. EAC Application Configuration area segmentation), Shared UI applies `margin-bottom: var(--bo-space-md)` (~16px) under `.bo-section .bo-tabs` so content is not flush with the strip. Header `TabsContent` is unaffected. Selection chrome: exactly one `bo-tab--selected` at a time — `BoTabs` notifies all registered `BoTab` instances on change (fixed cascading owner + click re-render only the clicked tab otherwise).

**Gallery Error Message Page:** uses the same tab architecture as Components / Theme **even when only one tab exists** (Access Denied today). This is intentional so future error scenarios are added as tabs on `/error-message-page`, not as separate showcase pages.

| Concern | Standard |
| --- | --- |
| Width | Dynamic / content-hug; label nowrap; strip `overflow-x: auto` when tabs exceed the header |
| Content | Icon (`BoIcon`, **16px**) + label (**13px**); vertically center-aligned |
| Default colors | Black text/icon; transparent background |
| Corner radius | **`--bo-button-radius`** (aliases `--bo-radius-md` / **8px**) — aligned with button chrome; not `--bo-radius-full` |
| Hover (unselected) | Tertiary fill + button-radius chrome + lift; selected has no hover; honor `prefers-reduced-motion` (no lift) |
| Selected | Traveling tertiary **indicator** (`.bo-tabs__indicator`) via shared selection travel ([motion.md](../foundations/motion.md)); host-authoritative `SelectedTab`; enterprise / navigation-reinforcing motion character |
| Host script | `_content/BreezeOn.UI/js/bo-sliding-selection.js` (same module as `BoToggle`; no tabs-specific script) |
| Vertical separator | Border-token rule centered in the gap between tabs (16px gap) |
| Horizontal divider under titles | **None** (tabs sit under the title row with no rule between) |
| Inside padding | Tab hit: 4px vertical / 8px horizontal |
| Outside spacing | 16px gap between tabs; inside header padding |
| Switch behavior | All panels load together and stay mounted; hide inactive with CSS (no remount/reload); indicator travels; panel content still switches instantly |
| `SelectedTab` | Bindable in-memory key (`@bind-SelectedTab`); defaults to first tab; persists across switches |
| Validation fail chrome | After Submit attempt, tabs whose `TabKey` is in `FailedGroups` show `BoValidationFailBadge` in the **left icon slot** (replaces `IconContent` while failed). Clears live when that group no longer fails (`NotifyFieldChanged`) |

Authoritative detail: this section + [motion.md](../foundations/motion.md) § Selection travel; host script SSOT: [page-development.md](../page-development.md#host-script-inventory-ssot). Library inventory: [public-component-api.md](https://github.com/Breeze-On/SYSTEM-SHARED-UI/blob/main/docs/public-component-api.md).

## Home / navigation hub (locked platform pattern)

Use for each product app’s **Home** (or equivalent landing hub). This is **not** a form layout — forms still use Section → Row → Field ([layout.md](../layout/layout.md)).

**Hard rule:** every product app Home uses `BoNavHub` + one or more `BoNavCardStyleHyperlink` children. Do not invent alternate Home chrome (markdown dumps, ad-hoc card grids, Fluent types in product apps).

### Components

| Component | Role |
| --- | --- |
| `BoNavHub` | Full-height two-panel host: left cards + right brand logo |
| `BoNavCardStyleHyperlink` | Destination card (internal SPA or external URL) |

### Shell / body (Home)

| Concern | Standard |
| --- | --- |
| Footer | `ShowFooter` = **false** on Home |
| Body card | Fills the available shell viewport slot; **no** body scrollbar while `.bo-nav-hub` is present |
| Body padding | Hub host clears default body padding; panel padding lives on hub columns |
| Typeface | Org default (**Calibri**) — no per-component override |

### Hub layout (locked)

| Concern | Standard |
| --- | --- |
| Desktop columns | **~33% · ~67%** (`1fr` / `2fr`) — left cards, right brand |
| Mobile (`≤768px`) | Single column: cards first, brand below (`minmax(12rem, ~42%)` brand row) |
| Left column | Transparent over hub background; cards **horizontally + vertically centered** in the column |
| Card stack width | `min(100%, 22rem)`, centered in the left column |
| Gap between cards | Fluid `clamp(~0.75rem … ~2rem)`; thin horizontal rule between cards uses `--bo-color-card-container-border` (~76% of card width, centered in the gap) |
| Left column padding | Fluid `clamp` (vertical ~0.75–2rem, horizontal ~0.5–1rem) |

### Background (locked — theme tokens only)

| Layer | Standard |
| --- | --- |
| Base gradient | Left → right **custom multi-stop** white/card-container → tertiary (not linear). Stops: **0%** solid card-container; **20%** → 40% tertiary mix; **40%** → 55%; **60%** → 70%; **80%** → 85%; **100%** → ~92% tertiary mix (soft, no flat saturated block) |
| Dot texture | 18px dot matrix over the hub; soft mask ramps visibility **0% → 40%** of hub width (peak from 40%); Light opacity ~0.45, Dark ~0.5 |
| Card bloom | Quiet radial behind the card stack (card-container + low tertiary) so cards stay the focal point |
| Dark mode | Same structure; palette via `IBoThemeModeService` / dual tokens |

### Brand / right panel (locked structure; **Application Logo**)

| Concern | Standard |
| --- | --- |
| Concept | **Application Logo** — represents the **application**, not the customer/tenant — [application-branding.md](application-branding.md) |
| Host | `BoNavHub` `LogoSrc` **or** `BrandContent` (custom fragment wins when set) |
| Logo cell | Square sized to **`80cqmin`** (80% of the smaller brand-panel side); `object-fit: contain` |
| Alt text | Required for `LogoSrc` via `LogoAlt` (localized) |
| Asset | Per-app Application Logo under that app’s `wwwroot` — independently configured from Navigation Logo |
| Do not | Hardcode another app’s logo; invent a different right-panel layout; share a single config binding with Navigation Logo |

### `BoNavCardStyleHyperlink` (locked chrome)

| Parameter | Required | Notes |
| --- | --- | --- |
| `Label` | Yes | Primary title — localized |
| `Description` | Yes | Supporting copy — localized; **must equal** the destination page header **Subtitle** (same string / resource key) — [application-branding.md](application-branding.md) |
| `Hyperlink` | Yes | Internal route or absolute URL |
| `IsExternal` | When external | Default `false` |
| `IconContent` | Yes (Home) | Prefer `BoIcon` (~Size **32**); never Fluent types from product apps |
| `Badge` / `Category` / `Footer` | Optional | Extensibility only |

| Concern | Standard |
| --- | --- |
| **Internal** (`IsExternal` false) | SPA: `NavigationManager.NavigateTo`; same-tab; no full browser refresh |
| **External** (`IsExternal` true) | New tab; `rel="noopener noreferrer"` |
| Card chrome | `--bo-color-card-container-*` fill/border/shadow; hover lift ~200ms + light tertiary wash |
| Header row | Icon tile + **large label** on one row, vertically centered |
| Icon tile | Centered glyph; fluid size via `clamp`/`cqi`; Light: primary glyph on tertiary-tinted tile; **Dark: white glyph at rest**; hover → primary fill + scale/rotate |
| In-card rule | ~**90%** width horizontal rule under header |
| Description | Same chrome as Text Field label: **10px**, bold, **uppercase**, `--bo-color-text-field-label` |
| Fluid type | Label / icon / padding use `clamp` + container `cqi` so zoom/narrow columns stay inside the card |
| Focus | Visible primary focus ring |

### Per-app vs locked

| Locked (all apps) | Per-app only |
| --- | --- |
| `BoNavHub` + `BoNavCardStyleHyperlink` composition | **Number of cards** and destination routes |
| ~33/67 split, full-height body, no Home footer | **Card labels**; descriptions **= destination page subtitles** |
| Home header: **no subtitle** | **Application Logo** asset + alt text (independent of Navigation Logo) |
| Gradient stops + dot texture + card bloom | **Card icons** (`BoIcon` Name/Variant) |
| Card chrome, header/rule/description styles | **Application Display Name** as Home `AppTitle` |
| Internal SPA vs external new-tab rules | Theme Palette accents ([application-theme-palette.md](../foundations/application-theme-palette.md)) |
| Dual Light/Dark via theme mode | Left-nav page set + Navigation Logo |

**Not per-app:** inventing a different Home layout, using Fluent UI types in product pages, hardcoding user-visible strings, or putting form Section→Row on Home instead of the hub.

### Gallery reference

SYSTEM-SHARED-UI Gallery Home (`/`): four cards (Components, Theme, Error Message Page, Google external — excludes Home itself); `ApplicationLogoSrc="brand/app-logo.svg"`; `ShowFooter` false. Implementation SSOT for CSS: `breezeon-ui.css` (`.bo-nav-hub*`, `.bo-nav-card*`).

## Error Message Pages

**SSOT:** [error-messages.md](error-messages.md) — framework purpose, enforceable rules (best-effort route metadata, minimal Support Details, application-agnostic shared components, footer off, showcase ≡ production), Access Denied content standard, Access/Support Details, lifecycle for new error types.

SHARED-UI owns `BoAccessDenied` + `.bo-error-message*` foundation; Gallery `/error-message-page` is the authoritative showcase. Do not invent speculative shared base components until a second scenario needs a shared Blazor API.

## Overlays

Dialogs, Settings, toasts, and **page freeze** (`IBoPageFreezeService`) are hosted once in `BoProviders`. Full overlay SSOT (including BoPageFreeze API, z-index, a11y, nesting): [overlays.md](overlays.md).

## Toasts (`IBoToastService`)

Top-right toast stack hosted in `BoProviders` (`BoToastHost`).

| Variant | Accent / icon |
| --- | --- |
| `Success` | Green + `CheckmarkCircle` |
| `Alert` | Amber + `Warning` |
| `Information` | Blue + `Info` |
| `Error` | Danger + `ErrorCircle` |

| Concern | Standard |
| --- | --- |
| API | `ShowAsync(variant, mainLabel, bodyLabel?, autoDismissMs?)` (default ~5s) |
| MainLabel | Bold; `--bo-color-text` (black in Light, near-white in Dark) |
| BodyLabel | Optional; line break under Main; ~13px; field-label grey (`--bo-color-text-field-label`) |
| Layout | Compact horizontal card (~300px max); wider icon column with soft 3D disc + filled glyph; labels right; icon centered on the disc |
| Motion | Slide+fade in/out from the right (~200–220ms) |
| Dismiss | Click toast (or Enter/Space/Escape) dismisses; auto-dismiss remains |

Gallery Submit uses **Alert** (not Error): Main `Validation_MandatoryFieldsToast` (“Mandatory fields are required”); Body `Validation_MandatoryFieldsToastBody` (“Required information is missing. Review and complete all required fields.”) — see [forms.md](../controls/forms.md).
