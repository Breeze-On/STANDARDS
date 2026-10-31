# UI — App shell

Owner: UI

App chrome standards for applications using `BreezeOn.UI`. Related: [navigation.md](navigation.md), [tokens.md](../foundations/tokens.md), [overview.md](../overview.md).

## `BoAppShell` (required)

`BoAppShell` is required for apps using this library (Option B: floating nav + header + body + optional footer cards). Product apps compose pages inside the shell; they do not invent alternate chrome.

| Region | Component | Role |
| --- | --- | --- |
| Left nav | `BoNavPane` / `BoNavLink` | Platform navigation — see [navigation.md](navigation.md) |
| Header | `BoAppHeader` | Top header card; **per-page** `AppTitle` / `Subtitle` (host-localized); trailing actions; optional `TabsContent` |
| Body | `BoAppBody` | Body region inside a floating card; card hugs short content; when content exceeds the viewport slot, the card caps and scrolls internally |
| Footer | `BoAppFooter` | Optional per page (`ShowFooter`); when shown, fixed bottom footer card |

`BoShellCard` provides floating card chrome (border, shadow, `card-container-background`); margin density Shell/Content/None. Token names: [tokens.md](../foundations/tokens.md).

Authoritative product-facing detail also lives in the [SYSTEM-SHARED-UI README](https://github.com/Breeze-On/SYSTEM-SHARED-UI/blob/main/README.md).

## Header actions (locked)

Title row is a flex row: **titles (left)** | **actions (right)**, vertically center-aligned. Default actions via `BoHeaderActions` (override with `BoAppHeader.ActionsContent` when needed).

Order left → right:

| Control | Component | Behavior (current) |
| --- | --- | --- |
| Light / Dark theme | `BoThemeSwitch` | Apple-style switch; `BrightnessLow` (Regular) icon left of track; toggles `IBoThemeModeService` (persists `bo-theme-mode` cookie; see [tokens.md](../foundations/tokens.md)) |
| Settings | Settings icon button in `BoHeaderActions` | Opens centered `BoSettingsDialogHost`: one Main Section **Settings**, two `BoRow`s with `BoDropDownList` (Language, Timezone); apply-on-change via `IBoLocaleService` |
| Profile | `BoProfileMenu` | Circular avatar placeholder; menu with **Sign out** (design only — no auth) |

Theme mode / dual palettes: [tokens.md](../foundations/tokens.md). Locale prefs: [i18n.md](../foundations/i18n.md).

## Header titles (per-page)

`AppTitle` and `Subtitle` are **per page**, supplied by the host from that app’s resource library (Gallery: `BoUi` keys such as `Home_Header_AppTitle`). Do not hardcode user-visible strings.

| Concern | Standard |
| --- | --- |
| `AppTitle` | Required for normal pages; localized |
| `Subtitle` | Optional; when null/whitespace, **omit** the `  -  ` separator (implemented in `BoAppHeader`) |
| Dash | Shown only between a non-empty title and a non-empty subtitle |

## App shell footer (optional per page)

Footer is **optional per page** via `BoAppShell.ShowFooter` (default `true`). When `ShowFooter` is true, use the fixed bottom footer shell region (`BoAppFooter` / `FooterContent`) — same floating-card chrome family as the header. When false, omit the footer region (gallery: Home has no footer; Components / Theme keep it).

## Header tabs (optional page sections)

Pages **may omit** tabs. When present, use `BoAppHeader.TabsContent` with `BoTabs` / `BoTab` and body `BoTabPanels` / `BoTabPanel`. Tabs are page sections, not left-nav routes.

| Concern | Standard |
| --- | --- |
| Width | Dynamic / content-hug; label nowrap |
| Content | Icon (`BoIcon`, **16px**) + label (**13px**); vertically center-aligned |
| Default colors | Black text/icon; transparent background |
| Hover (unselected) | Tertiary fill + full rounded pill + lift; selected has no hover |
| Selected | Tertiary fill + full rounded pill; no hover |
| Vertical separator | Border-token rule centered in the gap between tabs (16px gap) |
| Horizontal divider under titles | **None** (tabs sit under the title row with no rule between) |
| Inside padding | Tab hit: 4px vertical / 8px horizontal |
| Outside spacing | 16px gap between tabs; inside header padding |
| Switch behavior | All panels load together and stay mounted; hide inactive with CSS (no remount/reload) |
| `SelectedTab` | Bindable in-memory key (`@bind-SelectedTab`); defaults to first tab; persists across switches |
| Validation fail chrome | After Submit attempt, tabs whose `TabKey` is in `FailedGroups` show `BoValidationFailBadge` in the **left icon slot** (replaces `IconContent` while failed). Clears live when that group no longer fails (`NotifyFieldChanged`) |

Authoritative detail: [SYSTEM-SHARED-UI README](https://github.com/Breeze-On/SYSTEM-SHARED-UI/blob/main/README.md) (Header tabs standard).

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

### Brand / right panel (locked structure; per-app asset)

| Concern | Standard |
| --- | --- |
| Host | `BoNavHub` `LogoSrc` **or** `BrandContent` (custom fragment wins when set) |
| Logo cell | Square sized to **`80cqmin`** (80% of the smaller brand-panel side); `object-fit: contain` |
| Alt text | Required for `LogoSrc` via `LogoAlt` (localized) |
| Asset | Per-app SVG (or equivalent) under that app’s `wwwroot` — gallery: `wwwroot/brand/home-hero.svg` |
| Do not | Hardcode another app’s logo; invent a different right-panel layout |

### `BoNavCardStyleHyperlink` (locked chrome)

| Parameter | Required | Notes |
| --- | --- | --- |
| `Label` | Yes | Primary title — localized |
| `Description` | Yes | Supporting copy — localized |
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
| ~33/67 split, full-height body, no Home footer | **Card labels + descriptions** (each app’s own resource library) |
| Gradient stops + dot texture + card bloom | **Card icons** (`BoIcon` Name/Variant) |
| Card chrome, header/rule/description styles | **Right-panel logo** asset + alt text |
| Internal SPA vs external new-tab rules | Optional primary/tertiary accents (shared token roles) |
| Dual Light/Dark via theme mode | App title / subtitle / left-nav page set |

**Not per-app:** inventing a different Home layout, using Fluent UI types in product pages, hardcoding user-visible strings, or putting form Section→Row on Home instead of the hub.

### Gallery reference

SYSTEM-SHARED-UI Gallery Home (`/`): three cards (Components, Theme, Google external — excludes Home itself); `LogoSrc="brand/home-hero.svg"`; `ShowFooter` false. Implementation SSOT for CSS: `breezeon-ui.css` (`.bo-nav-hub*`, `.bo-nav-card*`).

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
