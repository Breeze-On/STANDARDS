<!-- Classification: AA; Scope: platform; Domain: UI; Capability: Patterns -->
# Context Selection (Application Enabled)

Owner: UI / Architecture

When a product application has **multiple valid and visible** Application Enabled contexts for the current user, the host shows a Context Selection experience before continuing to the requested route.

## Implementation

| Item | Value |
| --- | --- |
| SHARED-UI | `BoContextSelection` |
| Host route (INV) | `/select-context?returnUrl=` |
| Page header | Same AppTitle behavior as Home (application display name; **no** page-specific title/subtitle) |
| Host chrome | `BoNavHub` — left workflow + right Application Logo / gradient brand panel (same visual identity as Home) |
| Informational header | `BoNavCardStyleStatic` — supportive (≈75–80% of BE row width); **not** clickable; no icon |
| Selection cards | Compact `BoNavCardStyleHyperlink` — **Business Entity icon + Description** only (no secondary description/code); nav-card hover/lift + hyperlink; equal-width responsive grid |
| Layout | Left column: content block centered in the working area (header above BE grid, clear Information → Selection spacing). Right: Application Logo + hub background treatment |
| Selection | Navigate to sanitized return URL with `AE=` via `IBoApplicationContextNavigation` |

## UX hierarchy

1. Left informational header card (guidance)
2. Left Business Entity selection cards (primary action)
3. Right illustration / brand panel (visual balance — not the primary action)

## Rules

- List **valid + visible** contexts only ([context-resolution.md](../../../architecture/app-context/context-resolution.md) § Per-AE validity).
- Reject open redirects (`returnUrl` must be same-app relative).
- Do not silently send users to Home unless `returnUrl` was Home.
- Catalog the route with empty `RequiredGroupCodes`; AE gate exempts `/select-context`.
- Do not invent a page-specific AppTitle for Context Selection.
- Do not omit the brand panel — Context Selection must feel like a BreezeOn page, not a centered wizard.

## Gallery

SHARED-UI Gallery `/context-selection-page` shows the layout pattern (static showcase; not live AE resolution).

Related: [context-resolution.md](../../../architecture/app-context/context-resolution.md) · [shell.md](../shell/shell.md) Home / nav-card chrome · [error-messages.md](../shell/error-messages.md)
