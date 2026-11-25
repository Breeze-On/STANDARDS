<!-- Classification: AA; Scope: platform; Domain: UI; Capability: Foundations -->
# UI — Application Theme Palette

Owner: UI

Reusable theming model for per-application visual identity. Does **not** finalize product hex values — it defines which tokens applications may customize, how Light/Dark are structured, and how Step 1 brand colors derive the full palette.

Related: [tokens.md](tokens.md) (full platform token inventory) · [application-branding.md](../shell/application-branding.md) · [application-development-process.md](../../ai/application-development-process.md) · [application-definition.schema.json](../../ai/application-definition.schema.json) · [accessibility.md](accessibility.md)

**Mandatory:** every BreezeOn application supports **Light** and **Dark** themes (`BoThemeMode` / `IBoThemeModeService`). Applications **cannot** add or remove theme modes through Step 1 configuration.

---

## Goals

1. Stable Theme Palette model before App #2
2. Applications customize identity without Shared UI code changes
3. Platform retains control of structural, text, field, and locked-nav chrome tokens
4. Step 1 collects at most three brand colors; all other palette roles are derived

---

## Step 1 theme inputs (application-definition only)

Customer Branding may optionally supply this **all-or-nothing** group:

| Input | Format | Rule |
| --- | --- | --- |
| `primaryColor` | `#RRGGBB` | Six-digit hex only |
| `secondaryColor` | `#RRGGBB` | Six-digit hex only |
| `tertiaryColor` | `#RRGGBB` | Six-digit hex only |

| Omission / validation | Behavior |
| --- | --- |
| All three omitted | Use the complete platform-default Light and Dark palettes from [tokens.md](tokens.md) |
| Any one supplied | Schema requires **all three** — no partial custom palette |
| Modes | Not Step 1 inputs — always Light + Dark |

### Theme persistence protection (locked)

The **only** user-configurable theme inputs that may **ever** be persisted in application-definition are:

- `primaryColor`
- `secondaryColor`
- `tertiaryColor`

Derived values — including hover, pressed, selected, subtle surfaces, borders, foregrounds, dark-mode counterparts, accessibility variants, and any other generated colors — are **implementation outputs only**. They must **never** become application-definition fields. Future requests to customize generated colors must be handled by changing **palette-generation logic**, not by expanding the schema.

---

## Derived Theme Palette roles

From the three brand colors (or platform defaults), the development agent / Shared UI generator produces matching Light and Dark palettes that include at least:

| Role | Platform token(s) | Notes |
| --- | --- | --- |
| Primary | `color-primary` | Nav rail fill, primary actions — Light primary retains the supplied `primaryColor` as the authoritative brand value |
| Primary hover | `color-primary-hover` | **Derived** — never a Step 1 field |
| Secondary | `color-secondary` | Light secondary retains supplied `secondaryColor` |
| Tertiary | `color-tertiary` | Soft surfaces, Home hub wash — Light tertiary retains supplied `tertiaryColor` |
| Pressed / selected / subtle / borders / on-color foregrounds | Implementation roles mapped onto existing tokens where present | **Derived** |

**Primary hover is not a separately supplied Step 1 value.**

### Optional semantic overrides (runtime host only)

Product hosts **may** still override Success / Warning / Error / Info through Shared UI configuration for exceptional cases; Step 1 **does not** collect them. Omitted → platform defaults from [tokens.md](tokens.md). Prefer leaving semantics as platform defaults unless an existing token binding already derives from accents.

| Role | Platform token(s) |
| --- | --- |
| Success | `color-success` |
| Warning | `color-warning` |
| Error | `color-danger` |
| Info | `color-info` |

---

## Evaluated roles — disposition

| Candidate | Disposition |
| --- | --- |
| Primary / Secondary / Tertiary | **Step 1 brand colors** (optional triad) → Light authoritative values |
| Primary hover / pressed / selected / subtle / borders / foregrounds | **Derived** implementation outputs |
| Navigation Background | **Not a separate app token** — bound to **Primary** (`--bo-color-nav-background` → primary) |
| Navigation Text | **Platform-controlled** (`color-nav-text*`) |
| Navigation Accent | **Platform-controlled** for selected fill — `color-nav-selected` remains the locked Light-tertiary-stable token ([tokens.md](tokens.md) § Nav-stable) |
| Home Page Accent | **Not a separate app token** — Home hub derives from **Tertiary** (+ card-container) per [shell.md](../shell/shell.md) |
| Card Accent | **Not a separate app token** — use Tertiary / card-container platform roles |
| Success / Warning / Error / Info | Platform defaults unless host overrides outside Step 1 |

---

## Platform-controlled (not part of Theme Palette)

Remain Shared UI / STANDARDS-owned unless a superseding ADR says otherwise:

- Semantic white / black
- Canvas `color-background`, card-container fill/border/shadow
- Body / muted / field-label / field chrome / caret / selection
- Nav text, nav hover, **nav-selected**, **nav-logo-divider**
- Overlay / page-freeze scrims
- Save / Discard soft action families
- All spacing, radius, type, and motion tokens

Apps customize **identity accents**, not the entire design system. Platform neutrals and semantic status colors remain platform defaults unless the token architecture already requires a derived equivalent (e.g. nav background → primary).

---

## Deterministic palette generation

Same three `#RRGGBB` inputs **always** produce the same Light and Dark palettes (no LLM improvisation).

### Algorithm (normative)

Parse each input as sRGB 0–255 → convert to HSL with stable rounding.

**Light mode (authoritative brand values):**

1. `Primary` = `primaryColor` (exact)
2. `Secondary` = `secondaryColor` (exact)
3. `Tertiary` = `tertiaryColor` (exact)
4. `PrimaryHover` = darken Primary by **12%** relative lightness (clamp 0–100); round channel components to nearest integer hex
5. `Pressed` (when mapped) = darken Primary by **18%** relative lightness
6. `Selected` / subtle surfaces = mix Tertiary toward canvas white at fixed ratios (Tertiary 70% / white 30% for subtle; document in generator tests)
7. Border accents from Primary at **35%** mix toward card-border neutral when a derived border role is required
8. On-color foreground for Primary/Secondary actions = `#FFFFFF` or `#000000`, whichever yields higher contrast against the role background (WCAG 2.2 AA)

**Dark mode:**

1. `Primary` = lighten Light Primary by **8%** relative lightness (clamp); if still failing contrast against dark canvas, continue lightening in **2%** steps until AA for the required fg/bg pair or lightness 85%
2. `Secondary` = Light Secondary with saturation preserved; lightness nudged toward **55%** if outside 40–70%
3. `Tertiary` = darken Light Tertiary toward dark-canvas-compatible surface (target lightness **28–36%**)
4. `PrimaryHover` = lighten Dark Primary by **10%** relative lightness
5. Remaining interaction roles follow the same relative deltas as Light, applied to the Dark base colors

**Authoritative vs accessible variant (locked):**

- Always retain each supplied brand hex as the **authoritative brand color** for documentation and brand identity.
- If that exact hex cannot safely serve a particular role (contrast failure), emit a **role-specific accessible variant** for runtime use and **document** the variant.
- Do **not** silently replace or overwrite the supplied input in application-definition.

### Contrast validation

Validate generated foreground/background pairs to **WCAG 2.2 AA** ([accessibility.md](accessibility.md)): text/icons **4.5:1** (large text **3:1**); UI boundaries/focus **3:1**. Generator tests must include golden vectors and failing-contrast cases that produce documented accessible variants.

---

## Representation in host configuration

Step 1 persists only the three brand colors. The **runtime** Theme Palette object (Shared UI) remains:

```text
ThemePalette
  Light:
    Primary, PrimaryHover, Secondary, Tertiary
    [optional] Success, Warning, Error, Info
  Dark:
    Primary, PrimaryHover, Secondary, Tertiary
    [optional] Success, Warning, Error, Info
```

Rules:

- Light and Dark are **sibling** objects (dual palettes, one semantic name per role — same rule as [tokens.md](tokens.md) § Theme mode).
- Do **not** invent `*-light` / `*-dark` CSS variable name suffixes.
- Omitted brand-color triad → platform default palette for both modes.
- Product hosts apply the derived palette through Shared UI theme APIs (`BoThemePaletteConfiguration` / `BoThemeOptions` / provider) — **no** per-app fork of `breezeon-ui.css`.
- Do **not** write derived roles back into the application-definition instance.

---

## Light and Dark structure

| Rule | Standard |
| --- | --- |
| Modes | Light and Dark both required; not Step 1–configurable |
| Switching | Existing `IBoThemeModeService` + cookie persistence |
| Per-mode values | Derived roles may differ between Light and Dark |
| Derived relationships | Nav background follows Primary; Home wash follows Tertiary; do not duplicate those as separate mandatory app tokens |

---

## Mandatory for every future application

1. Support Light and Dark theme switching
2. Accept three optional brand colors (all-or-nothing) or omit for platform defaults
3. Derive Primary hover and other interaction/presentation roles — never collect them as Step 1 fields
4. Keep Application Branding (`applicationLogo`) and Customer Branding (`customerName`, `customerLogo`, three colors) as separate packages ([application-branding.md](../shell/application-branding.md))

---

## Implementation status

Token **values** for product apps remain platform defaults until a product supplies the three brand colors.

**Shipped configuration surface (Shared UI):**

- Brand-color triad → deterministic generator → `BoThemePaletteConfiguration` with `Light` / `Dark` (`BoThemePaletteModeConfiguration`: Primary, PrimaryHover, Secondary, Tertiary, optional Success / Warning / Error / Info)
- Register via `Configure<BoThemePaletteConfiguration>(…)` after `AddBreezeOnUI` (typically with generator output)
- Applied by `BoThemeModeService` without per-app CSS forks

This file remains the model SSOT for which tokens are app-configurable vs platform-controlled and for Step 1 theme persistence limits.
