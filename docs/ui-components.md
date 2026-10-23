# UI component standards

Shared UI conventions for Breeze On applications.

## Shared library (current)

| | |
| --- | --- |
| Repository | [Breeze-On/SYSTEM-SHARED-UI](https://github.com/Breeze-On/SYSTEM-SHARED-UI) |
| Package / project | `BreezeOn.UI` (`src/BreezeOn.UI`) |
| Approach | Option B+: BreezeOn public API on top of Fluent UI Blazor (Fluent is internal) |
| Registration | `services.AddBreezeOnUI()` |
| Host requirements | Render `BoThemeProvider` and `BoProviders` in the app layout |

Product applications must use **`BreezeOn.UI`** components (`Bo*`). Do not reference `Microsoft.FluentUI.AspNetCore.Components` types from product pages.

### Shipped components

| Component | Purpose |
| --- | --- |
| Design tokens / `BoThemeProvider` | CSS variables and theme options (palette, spacing, radius, typography) |
| `BoProviders` | Hosts Fluent providers (dialogs, tooltips, etc.) without exposing Fluent |
| `BoCard` | Card surface with optional title and footer |
| `BoStack` | Vertical or horizontal stack layout |
| `BoPageHeader` | Page title and description |
| `BoTextField` | Text input |
| `BoSelect` | Drop-down list (DDL) |
| `BoCheckbox` | Checkbox |
| `BoButton` | Button (primary / secondary / stealth) |
| `BoDialog` | Declarative panel dialog |
| `BoDialogService` | Message / confirmation dialogs (Fluent-backed facade) |
| `BoTooltip` | Tooltip |

### Local gallery

`src/BreezeOn.UI.Gallery` in SYSTEM-SHARED-UI runs a local Interactive Server host to preview components (`dotnet run` in that project).

## When new shared components are introduced

Document each shared component here (name, purpose, repo/package, usage expectations) at the time it exists, and keep this file current-state only.
