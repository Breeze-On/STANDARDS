# UI — App shell

App chrome standards for applications using `BreezeOn.UI`. Related: [navigation.md](navigation.md), [tokens.md](tokens.md), [overview.md](overview.md).

## `BoAppShell` (required)

`BoAppShell` is required for apps using this library (Option B: floating nav + header + body + optional footer cards). Product apps compose pages inside the shell; they do not invent alternate chrome.

| Region | Component | Role |
| --- | --- | --- |
| Left nav | `BoNavPane` / `BoNavLink` | Platform navigation — see [navigation.md](navigation.md) |
| Header | `BoAppHeader` | Top header card; `AppTitle` + `  -  ` + `Subtitle` inline; trailing actions; optional `TabsContent` |
| Body | `BoAppBody` | Body region inside a floating card; card hugs short content; when content exceeds the viewport slot, the card caps and scrolls internally |
| Footer | `BoAppFooter` | Optional per page (`ShowFooter`); when shown, fixed bottom footer card |

`BoShellCard` provides floating card chrome (border, shadow, `card-container-background`); margin density Shell/Content/None. Token names: [tokens.md](tokens.md).

Authoritative product-facing detail also lives in the [SYSTEM-SHARED-UI README](https://github.com/Breeze-On/SYSTEM-SHARED-UI/blob/main/README.md).

## Header actions (locked)

Title row is a flex row: **titles (left)** | **actions (right)**, vertically center-aligned. Default actions via `BoHeaderActions` (override with `BoAppHeader.ActionsContent` when needed).

Order left → right:

| Control | Component | Behavior (current) |
| --- | --- | --- |
| Light / Dark theme | `BoThemeSwitch` | Apple-style switch; `BrightnessLow` (Regular) icon left of track; toggles `IBoThemeModeService` (in-memory) |
| Settings | Settings icon button in `BoHeaderActions` | Opens centered `BoSettingsDialogHost` with Language / Timezone placeholders (non-functional) |
| Profile | `BoProfileMenu` | Circular avatar placeholder; menu with **Sign out** (design only — no auth) |

Theme mode / dual palettes: [tokens.md](tokens.md). Cookie persistence for theme is not shipped yet.

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
