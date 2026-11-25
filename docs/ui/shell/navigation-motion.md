<!-- Classification: AA; Scope: platform; Domain: UI; Capability: NavigationMotion -->
# UI — Navigation Motion Standard

Owner: UI

Platform route / Application Context navigation motion for applications using `BreezeOn.UI`. Current reality. Implementation: [SYSTEM-SHARED-UI](https://github.com/Breeze-On/SYSTEM-SHARED-UI) (`BoAppShell` / `BoAppBody`, `BoNavCardStyleHyperlink`, `breezeon-ui.css`). Related: [motion.md](../foundations/motion.md), [shell.md](shell.md), [navigation.md](navigation.md), [context-selection.md](../patterns/context-selection.md), [overview.md](../overview.md).

## Design principle (locked)

**Users should perceive smoother navigation, not animation.**

Use this as the decision filter for future enhancements. If users actively notice or comment on the animation, it is too strong for the BreezeOn platform — reduce intensity; do not add spectacle.

Motion character: ~95% professional / ~5% delight. Enterprise polish only.

## Shell ownership (locked)

Navigation motion is a **SHARED-UI shell capability**, owned by **`BoAppShell` / `BoAppBody`**.

| Rule | Standard |
| --- | --- |
| Injection | Applied automatically when the host uses `BoAppShell` (`BoAppBody` wraps `BodyContent`) |
| Inheritance | Product apps (EAC, INV, future) receive motion with **no** per-app wiring |
| Forbidden | Product apps must **not** implement competing route-transition systems, custom page-transition CSS/JS, or parallel animation hosts |
| Exceptions | Require documented justification in STANDARDS; none today |

## When motion applies

Application-level navigation only:

- Pathname changes (e.g. Home → Status Report, Detail → Edit, Error → Home)
- Application Context (`AE` query) changes on the same or different path (e.g. `/status-report?AE=Finance` → `/status-report?AE=HumanResources`)
- Context Selection → selected return URL with `AE=`

## When motion does **not** apply

Do **not** animate:

- Grid refreshes, searches, filtering, sorting, pagination
- Form saves, component refreshes, data reloads, table updates
- Toast notifications, expand/collapse
- Query-string updates that are **not** Application Context (`AE`) transitions
- Fragment-only changes
- Full page loads (`forceLoad` / browser navigation)

## Route transition behavior (locked)

Enter-focused transition on the shell body content (chrome — nav, header, footer — stays put):

| Property | Value |
| --- | --- |
| Effect | Fade-in + subtle upward rise |
| Rise | `4px` (`--bo-route-transition-rise`) |
| Duration | `150ms` (`--bo-route-transition-duration`) — Micro band (120–180ms) |
| Easing | `ease-out` (`--bo-route-transition-easing`) |
| Properties | `opacity` + `transform` only |
| Navigation delay | **None** — do not hold `NavigateTo` for the page transition |

### Motion trigger logic

`BoAppBody` listens to `NavigationManager.LocationChanged` and compares a prior snapshot of `(pathname, AE)`:

| Condition | Animate? |
| --- | --- |
| Pathname differs | **Yes** |
| Pathname same; query param **`AE`** value differs (add / remove / change). Param name = `BoApplicationContextResolver.AeQueryParameter` (`"AE"`) | **Yes** |
| Pathname same; only non-`AE` query and/or fragment differ | **No** |
| Initial circuit attach / first paint | **No** (avoid load flash) |

`AE` is compared as a single query key (case-insensitive value). Other query keys are ignored for the trigger decision.

## Application Context (AE) selection press (locked)

Compact Context Selection cards (`BoNavCardStyleHyperlink` with `bo-nav-card--compact`):

| Step | Behavior |
| --- | --- |
| Flow | Hover → click → short pressed state (~**90ms**) → `NavigateTo` → route enter |
| Purpose | Confirm BE / AE selection was accepted before navigation |
| Reduced motion | Skip press delay; navigate immediately |
| Loading | No loading screens, overlays, or spinners |

Home hub (non-compact) cards navigate immediately; they still receive shell route enter via `BoAppBody`.

## Accessibility (locked)

| Concern | Standard |
| --- | --- |
| `prefers-reduced-motion: reduce` | No route enter animation (no fade / rise); no compact-card press delay or press transform |
| Usability | Motion must not block or slow task completion |
| Precedence | Accessibility takes precedence over visual effects |

## Performance (locked)

| Concern | Standard |
| --- | --- |
| Feel | Instantaneous; no perceived slowdown |
| Priority | Navigation speed > animation |
| Complexity | Shell-owned CSS + lightweight location compare only |

## Anti-patterns (locked)

- Slides, zooms, wipes, fly-ins
- Full-page loading overlays or spinner-based navigation
- Consumer-app / playful motion
- Per-application route-transition forks
- Animating non-navigation surfaces listed under “does not apply”

## Tokens

Defined on `.bo-theme-root` in `breezeon-ui.css`. Index: [tokens.md](../foundations/tokens.md). Approved system: [motion.md](../foundations/motion.md).

| CSS variable | Value |
| --- | --- |
| `--bo-route-transition-duration` | `150ms` |
| `--bo-route-transition-easing` | `ease-out` |
| `--bo-route-transition-rise` | `4px` |

## Guidance for future BreezeOn applications

1. Use `BoAppShell` (required) — navigation motion is automatic.
2. Do not add product CSS/JS for page transitions.
3. Use Shared UI Context Selection (`BoContextSelection` / compact nav cards) for multi-AE flows — press feedback is automatic.
4. Keep filter/sort/page/search state out of pathname when possible; non-`AE` query changes stay silent by design.

## Future Consideration (not shipped)

A future shell-level **diagnostic / testing mode** or **motion disable switch** may be useful for UI testing, screenshot generation, automated regression validation, and support/troubleshooting. **Not implemented.** If built later, it remains a SHARED-UI shell concern — not a per-app fork.
