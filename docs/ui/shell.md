# UI — App shell

App chrome standards for applications using `BreezeOn.UI`. Related: [navigation.md](navigation.md), [tokens.md](tokens.md), [overview.md](overview.md).

## `BoAppShell` (required)

`BoAppShell` is required for apps using this library (Option B: floating nav + header + body + **footer** cards). Product apps compose pages inside the shell; they do not invent alternate chrome.

| Region | Component | Role |
| --- | --- | --- |
| Left nav | `BoNavPane` / `BoNavLink` | Platform navigation — see [navigation.md](navigation.md) |
| Header | `BoAppHeader` | Top header card; `AppTitle` + `  -  ` + `Subtitle` inline; optional `TabsContent` |
| Body | `BoAppBody` | Scrollable body region (scrolls inside body card) |
| Footer | `BoAppFooter` | Fixed bottom footer card |

`BoShellCard` provides floating card chrome (border, shadow, `card-container-background`); margin density Shell/Content/None. Token names: [tokens.md](tokens.md).

Authoritative product-facing detail also lives in the [SYSTEM-SHARED-UI README](https://github.com/Breeze-On/SYSTEM-SHARED-UI/blob/main/README.md).

## App shell footer (hard standard)

Every application that uses `BoAppShell` **must** include the fixed bottom footer shell region (`BoAppFooter` / `FooterContent`). Do not ship apps with header/body only. Footer chrome matches the floating card family; body content scrolls inside the body card above it.

## Header tabs (optional page sections)

Pages **may omit** tabs. When present, use `BoAppHeader.TabsContent` with `BoTabs` / `BoTab` and body `BoTabPanels` / `BoTabPanel`. Tabs are page sections, not left-nav routes.

| Concern | Standard |
| --- | --- |
| Width | Dynamic / content-hug; label nowrap |
| Content | Icon (`BoIcon`) + label; vertically center-aligned |
| Default colors | Black text/icon; transparent background |
| Hover (unselected) | Tertiary fill + full rounded pill + lift; selected has no hover |
| Selected | Tertiary fill + full rounded pill; no hover |
| Vertical separator | Border-token rule centered in the gap between tabs (16px gap) |
| Horizontal divider | 96% of width inside header padding |
| Inside padding | Tab hit: 4px vertical / 8px horizontal |
| Outside spacing | 16px gap between tabs; inside header padding |
| Switch behavior | All panels load together and stay mounted; hide inactive with CSS (no remount/reload) |
| `SelectedTab` | Bindable in-memory key (`@bind-SelectedTab`); defaults to first tab; persists across switches |

Authoritative detail: [SYSTEM-SHARED-UI README](https://github.com/Breeze-On/SYSTEM-SHARED-UI/blob/main/README.md) (Header tabs standard).
