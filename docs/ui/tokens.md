# UI — Design tokens

Shell and accent tokens currently shipped by `BreezeOn.UI`. Related: [shell.md](shell.md), [navigation.md](navigation.md), [typography.md](typography.md), [overview.md](overview.md).

## Shell tokens (current)

| Token name | CSS variable | Where used |
| --- | --- | --- |
| `background` | `--bo-color-background` | Page/canvas behind floating shell cards |
| `card-container-background` | `--bo-color-card-container-background` | Shell and content card fill |
| `card-container-border` | `--bo-color-card-container-border` | Light card borders |
| `card-container-shadow` | `--bo-shadow-card-container` | Card elevation |
| `shell-margin` | `--bo-space-shell-margin` | Slim margins on shell cards; **nav right margin is 0** (gap from main column left margin) |
| `content-card-margin` | `--bo-space-content-card-margin` | Slightly larger margins for in-body content cards |
| `primary` | `--bo-color-primary` | Accent (`#224D3A`): nav panel fill, primary buttons |
| `primary-hover` | `--bo-color-primary-hover` | Primary button hover |
| `secondary` | `--bo-color-secondary` | Selected header tab rounded bottom border (`#7CF76C`) |
| `tertiary` | `--bo-color-tertiary` | Soft surface (`#D8F3DC`): selected nav, secondary buttons, header tab selected/hover |

Configured via `BoThemeOptions` / `BoThemeProvider`. Font family: [typography.md](typography.md).

Shared accents used by nav and buttons: `PrimaryColor` / `TertiaryColor` (nav panel + primary buttons / selected nav + secondary buttons). Nav color rules: [navigation.md](navigation.md). Header tab fills: [shell.md](shell.md).
