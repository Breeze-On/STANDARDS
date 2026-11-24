<!-- Classification: AA; Scope: platform; Domain: Platform; Capability: Applications -->
# AE query string standard

Owner: Architecture

## Standard

| Item | Value |
| --- | --- |
| Query parameter | `AE` |
| Value | `ApplicationEnabledGUID` (immutable Application Context id — [ADR-006](../../decisions/ADR-006-application-context-ownership.md)) |
| Examples | `/status-report?AE={guid}` · `/initiation?AE={guid}` |

## Propagation

Product hosts must use SHARED-UI **`IBoApplicationContextNavigation`** to preserve `AE` on in-app links and programmatic navigation (hub cards, left nav, programmatic `NavigateTo`). Do not hand-append `AE` in each product.

`AE` in the URL is the source of truth for deep links, bookmarks, and multi-tab scenarios — do not rely on cookies as the primary Application Context store.

## Related

- [context-resolution.md](context-resolution.md)
- SHARED-UI `BreezeOn.UI.AppContext`
