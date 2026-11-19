# Overlays

Shared UI overlays hosted once in `BoProviders` (under `BoThemeProvider`, beside `BoAppShell`). Product apps must not mount these hosts themselves.

Related: [shell.md](shell.md), [tokens.md](../foundations/tokens.md), [i18n.md](../foundations/i18n.md), [page-development.md](../page-development.md), [forms.md](../controls/forms.md).

## Hosting (locked)

| Concern | Standard |
| --- | --- |
| Mount | `BoProviders` renders `BoMessageDialogHost`, `BoSettingsDialogHost`, `BoToastHost`, `BoPageFreezeHost` |
| Lifetime | All overlay services are **scoped** (Blazor Server circuit-local) |
| Theme | Under `BoThemeProvider` so Light/Dark tokens apply |
| Stack | profile `900/901` → dialog `1000` → popup `9998/10000` → toast `11000` → **page freeze `12000`** |

## Dialog (`BoDialog`) — platform product dialogs (locked)

Presentational shell for Create / Edit / Confirm / management dialogs. Product apps **must** compose `BoDialog` — do **not** copy local host/backdrop/footer chrome.

| Concern | Standard |
| --- | --- |
| Ownership | `BreezeOn.UI` (`Overlays/BoDialog`); keyboard + focus lifecycle owned by the shell |
| Host JS | `_content/BreezeOn.UI/js/bo-dialog.js` required (initial focus + focus restore + Enter suppress checks) |
| Size | `BoDialogSize.Default` (~52rem form/management), `Compact` (~28rem message/confirm), or `Large` (~76rem analysis / wide summary) |
| Close (X) | Place `BoDialogCloseButton` in `BoSectionMain` `HeaderActions` so X shares `OnClose` with Escape / backdrop |
| Primary / Secondary | Footer buttons via `PrimaryActionLabel` / `PrimaryAction` and optional Secondary; no duplicate business paths for keyboard |
| Error | `ErrorText` (or `FooterError`) under actions |

### Keyboard

| Key | Behavior |
| --- | --- |
| **Enter** / **NumpadEnter** | Invokes `PrimaryAction` when configured, enabled, and not suppressed |
| **Escape** | Invokes the **same** `OnClose` path as Close (X) and backdrop (when `CloseOnBackdropClick`) |
| Nested popups | Open `BoDropDownList` / Date / People Picker consume Escape first |
| `SuppressEnterPrimary` | Required when there is no meaningful primary (members / view-only) |
| Multiline / editors | `textarea`, `contenteditable`, and `[data-bo-suppress-enter]` never submit on Enter |

### Initial focus (`InitialFocusFieldKey`)

| Concern | Standard |
| --- | --- |
| Purpose | Immediate typing on Create/Edit (e.g. New Data Entity → Code) |
| API | Optional `InitialFocusFieldKey` matching a child field `FieldKey` (`[data-bo-field-key]`) |
| Lifecycle | Applied after open render (Blazor `OnAfterRender`); retries for Fluent upgrade timing |
| Fallback | Missing / non-focusable key → focus dialog panel; never throw |
| When unset | Focus moves to the dialog panel (a11y baseline); no silent “first field” heuristic |
| Anti-pattern | Product-local autofocus JS (e.g. former EAC `eacFocusFieldByKey`) |

### Focus restoration

| Concern | Standard |
| --- | --- |
| Default | `RestoreFocusOnClose=true` — capture opener on open; restore on any close path |
| Rationale | Keyboard round-trip: trigger → dialog → back to trigger |
| Soft fail | Opener detached / not focusable → no-op |
| Escape hatch | `RestoreFocusOnClose=false` only when a consumer proves need |

### Gallery validation (gate)

Before adopting `BoDialog` in a product app, Gallery **Components → Other → Dialog** must demonstrate: Enter primary, Escape close, disabled primary, confirm Proceed, `SuppressEnterPrimary`, `InitialFocusFieldKey`, and focus restoration.

### Message dialog (`BoDialogService`)

| Concern | Standard |
| --- | --- |
| API | `ShowMessageAsync(message, closeLabel?)` — awaits until Close; default close label `Dialog_Close` |
| UI | Implemented via `BoDialog` (`Compact`); backdrop + Primary Close; Enter/Escape → `Close()` |
| A11y | `role="dialog"` + `aria-modal="true"` + `Chrome_Aria_Message`; focus restore to opener |

### Settings dialog (`BoSettingsDialogService`)

Centered Language / Timezone dialog opened from header Settings — hosted via `BoDialog` (`Compact`, `InitialFocusFieldKey=Language`). Details: [shell.md](shell.md), [i18n.md](../foundations/i18n.md).

## Toasts (`IBoToastService`)

Top-right toast stack (`BoToastHost`). Full rules: [shell.md § Toasts](shell.md#toasts-ibotoastservice).

## Page freeze (`IBoPageFreezeService`)

Full-viewport busy overlay for multi-second operations (import/export, bulk save, hierarchy processing). **Not** page-local and **not** embedded in `BoButton`.

### API

| Member | Behavior |
| --- | --- |
| `Show(message?)` | Pushes a freeze level; null/whitespace → `PageFreeze_PleaseWait` (“Please wait...”) |
| `Hide()` | Pops one level; no-op when clear |
| `HideAll()` | Clears the stack (fault handlers) |
| `IsVisible` / `CurrentMessage` / `Depth` | Observable state |
| `Changed` | `event Action?` — host re-renders |
| `RunAsync(message, operation)` | `Show` → try/finally `Hide` (preferred) |
| `RunAsync<T>(...)` | Same with result |

Nesting is **reference-counted**: nested Import→Save keeps the overlay until `Depth` returns to zero.

### Visual

| Element | Standard |
| --- | --- |
| Backdrop | `--bo-page-freeze-scrim` + `backdrop-filter: blur(var(--bo-page-freeze-blur))` (default `6px`) |
| Indicator | Application **minimized** logo from `IBoBrandingService.LogoMinimizedSrc` (same URL as `BoNavPane.LogoMinimizedSrc`; falls back to BreezeOn default icon) with soft primary/tertiary glow + opacity/scale pulse (~1.6s). Does **not** use `LogoExpandedSrc`. |
| Message | Optional; centered under icon; `--bo-color-text`; Calibri |
| Reduced motion | Pulse/glow disabled under `prefers-reduced-motion: reduce` |
| Z-index | `--bo-z-page-freeze: 12000` (above toast) |

### Branding

| Concern | Standard |
| --- | --- |
| Ownership | App sets logos once on `BoNavPane`; service is SSOT for other chrome |
| Freeze logo | Always `IBoBrandingService.LogoMinimizedSrc` (nav minimized icon) |
| Expanded logo | Nav wordmark only — never used by page freeze |
| Fallback | If nav logos unset → `BoBrandingDefaults.LogoMinimizedSrc` |
| Themes | Logo asset is app-supplied; freeze chrome (scrim/glow) follows Light/Dark tokens |

See also [navigation.md § Branding ownership](navigation.md#branding-ownership-current).

### Interaction / a11y

| Concern | Standard |
| --- | --- |
| Blocking | Blocks clicks, scroll, dialogs, popups, and toasts while visible |
| Dismiss | **Not** user-dismissible (no Escape, no backdrop click) |
| Focus | Panel `tabindex="-1"`; focus moved on show; focus restored on focusout |
| Announce | `role="alertdialog"` + `aria-modal="true"` + `aria-busy="true"`; message `aria-live="assertive"` |
| Scroll lock | `html` / `body` / `.bo-theme-root` overflow hidden via `:has(.bo-page-freeze-host:not([hidden]))` |

### When to use

`IBoPageFreezeService` **SHOULD** be used when:

- Database writes occur (create, update, delete)
- Import or export operations occur
- Bulk operations occur
- Synchronization or other background processing is expected to take noticeable time
- Users might otherwise attempt duplicate actions
- User interaction should be prevented until completion
- Loading lookups that hit the backend at a scale users can perceive (e.g. full hierarchy fetch before an edit dialog)

### When not to use

`IBoPageFreezeService` **SHOULD NOT** be used for:

- Grid filtering, sorting, paging, or searching
- Tab changes
- Accordion expand/collapse
- Dialog open/close chrome alone (without backend work)
- Validation-only actions (e.g. field blur format checks)
- Local UI state changes
- Fast in-memory operations
- Routine navigation / initial page navigation loads that are part of ordinary browsing

### Principle

Page freeze is for **meaningful backend work** or operations users perceive as “loading.” It improves confidence and prevents duplicate actions. It must **not** be used so aggressively that the application feels blocked during normal interaction.

### Messaging

- Pass **already-localized** short contextual gerunds (e.g. “Importing Applications...”, “Saving Changes...”, “Deleting Business Entity...”).
- Prefer a specific message over the default `PageFreeze_PleaseWait` whenever the operation is known.
- Keep copy concise; one line under the minimized logo.

### Usage pattern

```csharp
await PageFreeze.RunAsync(L["Import_Busy"], async () =>
{
    await ImportAsync();
});
await Toasts.ShowAsync(BoToastVariant.Success, L["Import_Done"]);
```

Prefer `RunAsync` so `Hide` always runs in `finally`. Nesting is reference-counted when one long op starts another.

### Anti-patterns

- Do **not** raise toasts while freeze is active — show outcome toasts **after** `Hide`
- Do **not** add `IsBusy` / spinner chrome to `BoButton` for long ops — keep the button thin
- Do **not** mount a second freeze host in product layouts
- Do **not** use freeze for sub-second work or the “when not to use” cases above
- Do **not** invent page-local loading overlays — use this shared service only

### Gallery

Components **Page Freeze** tab: Parameters (message + duration) → Preview trigger (`RunAsync` then Success toast) → Documentation.
