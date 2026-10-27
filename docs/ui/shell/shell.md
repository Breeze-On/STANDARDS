# UI — App shell

Owner: UI

App chrome standards for applications using `BreezeOn.UI`. Related: [navigation.md](navigation.md), [tokens.md](../foundations/tokens.md), [overview.md](../overview.md).

## `BoAppShell` (required)

`BoAppShell` is required for apps using this library (Option B: floating nav + header + body + optional footer cards). Product apps compose pages inside the shell; they do not invent alternate chrome.

| Region | Component | Role |
| --- | --- | --- |
| Left nav | `BoNavPane` / `BoNavLink` | Platform navigation — see [navigation.md](navigation.md) |
| Header | `BoAppHeader` | Top header card; `AppTitle` + `  -  ` + `Subtitle` inline; trailing actions; optional `TabsContent` |
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

Authoritative detail: [SYSTEM-SHARED-UI README](https://github.com/Breeze-On/SYSTEM-SHARED-UI/blob/main/README.md) (Header tabs standard).

## Navigation hub cards (landing / dashboard)

Use for app Home (or similar) **page hubs** — not for form fields (forms still use Section → Row → Field; see [layout.md](../layout/layout.md)).

| Component | Role |
| --- | --- |
| `BoNavHub` | Full-height two-panel host: left cards on canvas background (no texture); right brand panel with texture + large logo (`LogoSrc` / `BrandContent`) |
| `BoNavCardStyleHyperlink` | Destination card: `Label`, `Description`, `Hyperlink`, `IsExternal`, optional `IconContent` / `Badge` / `Category` / `Footer` |

| Concern | Standard |
| --- | --- |
| Internal links | SPA navigation (`NavigationManager.NavigateTo`) — no full browser refresh |
| External links | New tab; `rel="noopener noreferrer"` |
| Body card (Home) | Fills available shell height; **no** body scrollbar while the hub is present |
| Hub layout | Desktop: 50/50 columns; mobile: cards then brand stack |
| Card header | Icon tile + large label on one row (vertically centered); ~90% width rule; description uses Text Field label chrome (10px bold uppercase field-label color) |
| Card icon | Centered in tile; larger glyph; hover scales/rotates tile and fills primary |
| Visual | Token-driven card fill/border/shadow; hover lift ~200ms; Calibri via theme |
| Typography | Org default (**Calibri**) — no per-component typeface override |
| Gallery | Home lists Components + Theme cards (excludes Home itself); hero SVG at `wwwroot/brand/home-hero.svg`; `ShowFooter` false |

## Toasts (`IBoToastService`)

Top-right toast stack hosted in `BoProviders` (`BoToastHost`).

| Variant | Accent / icon |
| --- | --- |
| `Success` | Green + `CheckmarkCircle` |
| `Alert` | Amber + `Warning` |
| `Information` | Blue + `Info` |
| `Error` | Danger + `ErrorCircle` |

API: `ShowAsync(variant, message, autoDismissMs?)` (default ~5s). Gallery Submit uses **Error** with **"Mandatory fields are required"** when deferred validation fails (see [forms.md](../controls/forms.md)).
