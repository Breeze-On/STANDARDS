<!-- Classification: AA; Scope: platform; Domain: UI; Capability: ProcessView -->
# Process View

Owner: breezeon-system-shared-ui (platform capability / shared pattern) · product apps supply field composition and header **values/configuration**

Related: [ADR-024](../../../decisions/ADR-024-platform-process-root.md) · [ADR-025](../../../decisions/ADR-025-process-history.md) · [ADR-027](../../../decisions/ADR-027-request-number-and-sequence-allocation.md) · [ADR-028](../../../decisions/ADR-028-process-runtime-ownership-process-engine.md) · [process-runtime](../../../architecture/process-runtime/README.md) · [process-persistence.md](process-persistence.md) · [process-history.md](process-history.md) · [error-messages.md](../shell/error-messages.md) · [ae-query-string.md](../../../architecture/app-context/ae-query-string.md) · [shell.md](../shell/shell.md) · [tokens.md](../foundations/tokens.md)

## Purpose

Standardized **read-only** viewing of a persisted process across applications.

## Route contract

```text
/process-view?AE={ApplicationEnabledGUID}&PGUID={ProcessGUID}
```

- Preserve `AE` via `IBoApplicationContextNavigation`.
- `PGUID` is the companion query parameter for platform process identity.

## Ownership

| Concern | Owner |
| --- | --- |
| Platform capability, shared pattern, route contract, loading/error/read-only rules | breezeon-system-shared-ui |
| Process-View **header** framework — rendering, layout, interactions, responsive behavior, collapse, accessibility, visual styling | breezeon-system-shared-ui |
| Which Context Cards appear; card order; Icon / Label / Value; **Accent selection** (including Neutral, repeats, or branding-aligned SHARED-UI accents) | Product application |
| Tabs / sections / fields / body layout composition for the application | Product application |

Applications provide **configuration and data only**. Applications must **not** customize Context Card visuals (fonts, colors, borders, shadows, radii, templates, or card CSS). Branding-aligned accents are delivered through SHARED-UI accent families / theme tokens — not app-level style forks.

## Behavioral contract

| Rule | Contract |
| --- | --- |
| App Title | **`[Request Number] - [Application Name]`** — Request Number via Process Engine formatter ([ADR-027](../../../decisions/ADR-027-request-number-and-sequence-allocation.md)); Application Name = Application Display Name. This is the **Process-View header standard** (exception to inline Home/other-page title patterns). |
| Browser document title | **Request Number only** (not the composite App Title) so branding does not emit `RN - App - App` — [application-branding.md](../shell/application-branding.md) |
| SubTitle | Contextual information line **stacked beneath** App Title (`BoAppHeader` `TitleLayout=Stacked`); **no** `  -  ` separator. Concise value summary without field labels (e.g. `PO323409 \| Supplier 001 \| Budget A_0001`). Truncate with ellipsis + native `title` when overflowing. |
| Context Cards | SHARED-UI `BoContextCards` + `BoCardContext` under SubTitle, above header tabs. Apps configure Icon / Label / Value / optional Accent — [§ Process-View header](#process-view-header-locked). |
| Footer | **No** page footer / sticky action footer (`ShowFooter=false`) |
| Fields | **Read-only display** — **not** `Disabled`. Prefer the **same typed control** as initiation with `ReadOnly=true` so formatting semantics match (Number → `BoNumberField` with same currency/%/decimals; Date → `BoDateField` with same `Mode`; multiline → `BoTextArea`). Request Number uses `BoFieldReadOnly` on Process View (initiation uses Disabled `BoTextField` — [process-request-section.md](process-request-section.md)). `BoFieldReadOnly` otherwise for already-formatted scalars / resolved lookup text. See [forms.md § Read-only formatting parity](../controls/forms.md#read-only-formatting-parity-locked) |
| General Information layout | Mirror initiation **business** sections (e.g. Request Details) when the app has them — **same rows/fields and formatting**. Do **not** place **Process Request** on this tab. Do **not** keep a separate Purpose-of-Service section if initiation places Purpose as Request Details Row 4 |
| Tabs | At least **General Information** + **Process History** |
| Tab icons | General Information: `Form` Regular 16. Process History: **`Flowchart` Regular (outlined) 16** — same in every app (`BoProcessViewRoute.ProcessHistoryIconName`). Do **not** use `History`. — [icons.md](../foundations/icons.md) |
| Tab placement | **Header only** — `BoAppHeader.TabsContent` → `BoTabs` / `BoTab`; body hosts **`BoTabPanels` only** (cascade selected key). Do **not** place `BoTabs` inside the shell body / main content card. Same rule as [shell.md](../shell/shell.md#header-tabs-optional-page-sections) · [initiation-experience.md](initiation-experience.md). Gallery copy-source: `/process-view-page`. |
| Process History | **Locked composition:** (1) **Process Request** first (Request Number, Initiator, Requested Date) — **`BoRow` with exactly three field children**, equal default `Weight = 1` — [process-request-section.md](process-request-section.md). Do **not** pad with `BoEmptyField`. Do **not** move Process Request to General Information. (2) Section-level Process History grid (Role, Name, Response Status, Date, Comments) — [process-history.md](process-history.md). Display values come from Process Engine `P_GET_ProcessHistoryByProcessGUID` (SHARED-UI display models only). |
| AuthZ (v1) | All authenticated users may open Process View pages (future authorization out of scope). |

## Process-View header (locked)

Vertical order inside `BoAppHeader` on Process View:

1. **AppTitle** (stacked)
2. **SubTitle** (stacked, no dash)
3. **Context Cards** (`ContextCardsContent` → `BoContextCards` / `BoCardContext`) + collapse control
4. **Tabs** (`TabsContent`)
5. Header **actions** remain top-right (unchanged)

Use `BoAppHeader` `TitleLayout=Stacked` and `ContextCardsContent`. Hosts push titles and cards through SHARED-UI `BoProcessViewHeaderState` (or equivalent chrome bridge). Clear state when leaving Process View.

### AppTitle / SubTitle

| Concern | Standard |
| --- | --- |
| AppTitle format | `[Request Number] - [Application Name]` |
| SubTitle | Contextual line only; never Application Name (moved into AppTitle); never leading `-` |
| Non–Process View pages | Keep shell **Inline** title layout (`AppTitle  -  Subtitle`) — [shell.md](../shell/shell.md#header-titles-per-page) |

### Context Cards (`BoCardContext` / `BoContextCards`)

Context Cards are a **lightweight contextual layer** (process identification facts). They are **not** KPI cards and **not** a dashboard.

**Framework standardizes (behavior / structure):** layout; hierarchy (label vs value); accent **placement** and **usage** (subtle left accent + icon tile soft fill — no large colored surfaces); responsive wrap; order stability; collapse; accessibility; SHARED-UI visual chrome.

**Framework does not standardize specific hues.** Accent is a **configurable mechanism**. Product apps choose accents (or Neutral). Blue / Turquoise / Purple / Green shipped by SHARED-UI are **starter families** and **INV’s product choice** — not required Process-View colors. Future apps (blue-, red-, orange-, or customer-branded themes) align accents with approved branding via SHARED-UI accent / theme tokens **without** forking Process-View framework code or app-local card CSS.

| Concern | Standard |
| --- | --- |
| Visual ownership | **SHARED-UI exclusively.** Apps may set **Icon**, **Label**, **Value**, and optional **Accent** only. Forbidden: font sizes, colors, borders, shadows, radii, layout variations, custom templates, custom card CSS. |
| Layout | Horizontal card: icon tile left; **LABEL** (all caps) + **Value** (bold, larger, primary focus) stacked right. Value uses standard theme text color. |
| Accent | **Optional.** `BoCardContextAccent` selects a SHARED-UI accent family (including `Neutral`). Apps may omit differentiation (Neutral), repeat accents, or assign distinct accents. Unique accents per card are **not** required. Branding-aligned families are added/selected through SHARED-UI — [tokens.md](../foundations/tokens.md#context-card-accent-mechanism). |
| Order | **Configured order is stable.** Responsive wrap onto additional rows is allowed; **never** reorder cards by viewport, importance, or density. |
| Collapse | SHARED-UI only. Chevron Up when expanded, Chevron Down when collapsed; control on the **tabs row** (far right, vertically centered with tabs). Expanded: titles + cards visible. Collapsed: titles visible, cards hidden. Do **not** collapse AppTitle or SubTitle. Keep children mounted (height/visibility only). Default expanded; bind survives in-page tab changes; resets on route remount (no session/cookie store in v1). |
| Icons | Fluent Regular via `BoIcon` (typically Size **24**) — [icons.md](../foundations/icons.md) |

### INV note (application decision)

INV Process View Context Cards use Blue, Turquoise, Purple, and Green as **INV’s** accent selection. That palette is not a platform Process-View color standard.

### Context Cards vs future Summary tab

Header Context Cards provide **process context**. A future Summary tab would provide **process dashboards / analytical summaries**. These are intentionally separate responsibilities. The Context Card framework must remain independent so both can coexist without duplicating roles.

## Validation

1. `PGUID` present and parseable.
2. Row exists in `Global.Process`.
3. `Global.Process.ApplicationEnabledGUID` equals current `AE`.
4. Application extension row exists for that `ProcessGUID`.

On failure: navigate to `/application-error` via `IBoApplicationErrorState` (existing Application Error framework). **Do not** invent custom Process error screens.

## Terminal in v1

Flow: **Create → Save/Submit → Process View**.

Process View is **terminal**. Out of scope: Edit, Resume, Reopen, Withdraw, Delete, return to editable state. Do not design around future editing in v1.

## Page Freeze

Hydrate under `IBoPageFreezeService` (platform consistency). See [overlays.md](../shell/overlays.md).
