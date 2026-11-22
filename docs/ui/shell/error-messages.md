<!-- Classification: AA; Scope: platform -->
# Error Message Pages (platform standard)

Owner: UI / Architecture

**Implementation SSOT:** [Breeze-On/SYSTEM-SHARED-UI](https://github.com/Breeze-On/SYSTEM-SHARED-UI) — `BoAccessDenied`, `BoErrorMessageContext`, `BoErrorMessageOptions`, `.bo-error-message*` in `breezeon-ui.css`, Gallery `/error-message-page`.

Error Message Pages are a **first-class BreezeOn UI pattern**. SHARED-UI owns shared components and the authoritative gallery showcase. Product apps consume them; they do not invent one-off error pages.

## Purpose

Provide consistent, enterprise-grade full-page error experiences across all BreezeOn applications so users and support share the same mental model: what happened, what was requested, who is signed in, and (when needed) minimal support metadata.

Future scenarios (each a sibling `Bo*` + Gallery tab when introduced):

- Access Denied (shipped)
- Page Not Found (404)
- Session Expired
- Service Unavailable
- Application Error
- Maintenance Mode
- Unexpected Error
- Other standardized experiences as approved

## Design principles

- Modern, professional, clean, enterprise-grade, trustworthy, premium
- Token-aligned (Calibri via shell; primary/tertiary/muted/text/border tokens — Access Denied uses brand primary, not danger)
- No gaming visuals, neon effects, heavy animation, or excessive noise
- Authorization states must read as **authenticated but restricted**, not as system failure (avoid danger-red error glyphs, warning triangles, red X, exclamation marks on Access Denied)
- Header and left navigation remain normal app chrome
- **Footer always suppressed** (`BoAppShell.ShowFooter = false`) so attention stays on the error
- **Top-weighted layout** — content starts near the top of the body with generous top spacing (not a vertically centered empty-state)
- **Intro wider than detail panels** — lead/body may use a wider max-width; Access/Support panels stay narrower for readability
- **Body scrolls when content exceeds the slot** — rely on `BoAppBody` `overflow: auto`; do not set `overflow: hidden` on the body for error pages
- **Clarity over completeness** — Support Details stay intentionally minimal
- Authentication vs authorization must be clear in Access Denied copy

## Visual hierarchy

1. Status icon (layered circular badge; reusable foundation — Access Denied uses `PersonLock` + primary/tertiary badge, not a danger/error glyph)
2. Title
3. Professional explanatory message (lead + body where applicable)
4. Access Details (expandable; **expanded by default**)
5. Support Details (same panel chrome; collapsed by default)

## Shared foundation (CSS)

Reuse these classes for all error-message components — do **not** invent Access Denied–only visual structure:

| Class | Role |
| --- | --- |
| `.bo-error-message` | Root (horizontally centered; **top-aligned** with generous top padding — not vertically centered) |
| `.bo-error-message--access-denied` | Scenario modifier (auth/permission tone for icon color) |
| `.bo-error-message__icon` / `__icon-badge` | Status icon treatment (circular gradient badge + soft elevation) |
| `.bo-error-message__title` | Title |
| `.bo-error-message__message` / `__message-detail` | Lead / body copy |
| `.bo-error-message__panel` | Spacing wrapper around `BoExpandableSection` for Access/Support Details |
| `.bo-error-message__details-list` / `__detail-row` / `__detail-label` / `__detail-value` | Detail rows inside expandable panels |

Access/Support Details use shared [`BoExpandableSection`](../layout/expandable-section.md) (not `BoSectionMain`/`BoSectionSub`). Access Details default expanded; Support Details default collapsed. Collapsed content remains mounted (DOM retention rule).

Future components (`BoPageNotFound`, `BoSessionExpired`, `BoMaintenanceMode`, `BoApplicationError`, …) must reuse this design language.

## Enforceable rules

### 1. Best-effort route-to-page resolution

Route-derived metadata is **best-effort convenience information** and must fail gracefully. Error Message Pages must continue to render correctly even when a Page value cannot be resolved.

Applies to parameterized routes, nested routes, deep links, dynamic pages, and routes not registered in the page catalog (e.g. `/users`, `/users/123`, `/users/123/edit`).

**Required behavior:**

1. Attempt route-to-page resolution (`IBoPageCatalog.FindByRoute` or equivalent).
2. If successful, display the page name/key.
3. If unsuccessful: continue rendering; **omit** the Page field; never show placeholders, “unknown”, or error chrome for missing Page; never block rendering of the error experience.

URL, User, Application, and Support Details remain independent of catalog success.

### 2. Minimal Support Details (Phase 1 ceiling)

Support Details must provide enough information to assist administrators and support without overwhelming business users.

**Approved Support Details fields (Phase 1 maximum):**

- Environment Name
- Tenant ID
- Correlation ID
- Timestamp (UTC)

Do not expand Phase 1 beyond these fields unless a clear support requirement is approved in STANDARDS. Most users care about what happened, what they tried to access, and who they are signed in as. Most support investigations can begin with Correlation ID + Timestamp. Prefer clarity over completeness.

### 3. Shared components must remain application-agnostic

Error Message components must **never** contain application-specific business logic, messaging, workflows, help contacts, or product-specific remediation instructions.

**Allowed** (contextual metadata / platform copy): Application, Page, Tab, Area, Section, User, URL, Environment, Tenant ID, Correlation ID, Timestamp, and generic platform messaging (e.g. “contact your application administrator or support team”).

**Not allowed** in shared components: “Contact your EAC administrator”, “Contact the HR team”, “Contact Finance Operations”, “Submit an LOA request”, open a specific product workflow, or any other host-specific remediation.

Product-specific remediation, if required, must be supplied by the **consuming application** (host composition), not embedded in SHARED-UI. This keeps the framework reusable and prevents product-specific forks.

### 4. Footer suppression

Error Message Pages **must** use `BoAppShell.ShowFooter = false`. Rationale: reduce visual noise and keep focus on the error state. This is a platform UI standard, not a gallery-only detail. Product hosts that render `BoAccessDenied` (via `BoAuthorizeRouteView` or in-page) **must** suppress the footer — **MUST means implemented** on the product host (EAC is the reference).

### 5. Showcase ≡ production

The Access Denied (and future error) experience shown in SHARED-UI Gallery **must be visually identical** to the experience rendered through `BoAuthorizeRouteView` and consuming applications. Gallery hosts the **same** shared component and CSS — no gallery-only skins or alternate markup trees.

## Access Denied (default content standard)

### Status icon (authorization-focused)

| Layer | Standard |
| --- | --- |
| Glyph | Fluent **`PersonLock`** via `BoIcon` — `Filled`, size **48** (maps to Size24 asset scaled). Communicates authenticated user + restricted access in one compound icon. |
| Alternatives registered (not default) | `PersonShield` (policy/protection), `PersonProhibited` (explicit deny) — prefer `PersonLock` for Access Denied. |
| Do not use | `ErrorCircle`, warning triangle, red X, bang/exclamation — those read as system failure. |
| Badge | Circular `.bo-error-message__icon-badge`: soft primary→tertiary radial gradient, inset ring, soft elevation shadow. Dark mode: quieter primary wash + white inset ring so the white glyph stays clean (no mint cast). No continuous animation, neon, or glow. |
| Color | Light: `--bo-color-primary` on the glyph (not `--bo-color-danger`). Dark: `--bo-color-semantic-white` — avoids success-green cue; stronger contrast on the dark badge. |

Showcase ≡ production: Gallery and `BoAuthorizeRouteView` both render `BoAccessDenied` with this treatment.

### Copy

| Element | Standard copy (English) |
| --- | --- |
| Title | Access Denied |
| Lead | You do not have the required permissions to access this content. |
| Body | Your account has successfully authenticated, however your current security permissions do not allow access to the requested resource. If you believe this is incorrect, please contact your application administrator or support team. |

Copy must distinguish authentication from authorization, remain understandable to business users, stay professional/enterprise-grade, and remain suitable across all BreezeOn applications (application-agnostic). Localized via `BoUi` resources (`AccessDenied_*`).

### Access Details

Expandable panel using the same chrome as Support Details; **expanded by default**. Show when values are available. **Omit empty fields** (no blank rows).

| Field | When |
| --- | --- |
| Application | Host `BoErrorMessageOptions.ApplicationDisplayName` or context |
| Page | Best-effort catalog resolve or host-supplied |
| Current URL | Always when known |
| Logged-In User (UPN) | When authenticated identity is known |
| Tab / Area / Section | Only when non-empty (optional context) |

### Support Details

Same expandable panel chrome as Access Details; **collapsed by default**. Phase 1 fields only (see rule 2). Omit empty fields.

## Context API

- `BoErrorMessageContext` — optional string properties for the fields above
- `BoErrorMessageOptions.ApplicationDisplayName` — registered via `Configure<BoErrorMessageOptions>` after `AddBreezeOnUI`
- `BoAccessDenied` accepts optional `Context`; merges over best-effort self-resolved platform values
- `BoAuthorizeRouteView` builds and passes context on deny

## Accessibility

- Root uses `role="alert"`
- Single clear `h1` title; details use `h2` / definition list semantics
- Sufficient contrast via design tokens
- No information conveyed by color alone

## Localization

- Platform strings via `IBoUiLocalizer` / `BoUi` (en + fr)
- Application display name is host-owned configuration (not hardcoded product names inside shared components)
- Never hardcode user-visible labels in shared error components

## Gallery showcase

- Route: `/error-message-page` (nav URL matches page name)
- Uses the same tab architecture as Components / Theme **even when only one tab exists** (Access Denied today). Intentional: future error scenarios are added as tabs on this page, not as separate showcase pages.
- Footer off; header and left nav unchanged
- Sample `Context` may populate demo Access/Support Details for design review — still the same `BoAccessDenied` component

## Introducing a new error type

1. Add a sibling `Bo*` component consuming `.bo-error-message*` (application-agnostic).
2. Follow the same visual hierarchy and details rules.
3. Add a Gallery tab on `/error-message-page`.
4. Update this document + SHARED-UI README / README_AI / AGENTS in the **same change set**.
5. Product apps consume the shared component only; host-only remediation if needed.

Creating one-off product-specific error pages is discouraged unless formally justified in STANDARDS.

## Adoption status

- **Current (implemented):** SHARED-UI foundation, Access Denied, Gallery showcase, this standard; **product hosts must** configure `BoErrorMessageOptions.ApplicationDisplayName` and suppress footer whenever Access Denied is shown. EAC complies as the product host reference.
- **Deferred (explicitly not yet required):** Additional Error Message page types beyond Access Denied (`BoPageNotFound`, session expired, maintenance, etc.); product-specific remediation chrome remains host-only when needed.
- Do **not** use “Phase 2” language to imply EAC may remain intentionally non-compliant with MUST rules above.
