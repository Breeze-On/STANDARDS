<!-- Classification: AA; Scope: platform; Domain: Platform; Capability: Applications -->
# AE query string standard

Owner: Architecture

## Standard

| Item | Value |
| --- | --- |
| Query parameter | `AE` |
| Value | `ApplicationEnabledGUID` (immutable Application Context id — [ADR-006](../../decisions/ADR-006-application-context-ownership.md)) |
| Examples | `/status-report?AE={guid}` · `/initiation?AE={guid}` · `/process-view?AE={guid}&PGUID={guid}` |

## Process View companion parameter

| Item | Value |
| --- | --- |
| Query parameter | `PGUID` |
| Value | `ProcessGUID` (platform process identity from `Global.Process` — [ADR-024](../../decisions/ADR-024-platform-process-root.md)) |
| Route | `/process-view?AE={ApplicationEnabledGUID}&PGUID={ProcessGUID}` — [process-view.md](../../docs/ui/patterns/process-view.md) |

Always preserve `AE` when navigating to Process View. `PGUID` alone is not a substitute for Application Context.

## Propagation

Product hosts must use SHARED-UI **`IBoApplicationContextNavigation`** to preserve `AE` on in-app links and programmatic navigation (hub cards, left nav, programmatic `NavigateTo`). Do not hand-append `AE` in each product.

`AE` in the URL is the source of truth for deep links, bookmarks, and multi-tab scenarios — do not rely on cookies as the primary Application Context store.

## Related

- [context-resolution.md](context-resolution.md)
- [process-view.md](../../docs/ui/patterns/process-view.md)
- SHARED-UI `BreezeOn.UI.AppContext`
