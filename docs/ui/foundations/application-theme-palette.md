<!-- Classification: AA; Scope: platform; Domain: UI; Capability: Foundations -->
# UI — Application Theme Palette

Owner: UI

Reusable theming model for per-application visual identity. Does **not** finalize product hex values — it defines which tokens applications may customize and how Light/Dark are structured.

Related: [tokens.md](tokens.md) (full platform token inventory) · [application-branding.md](../shell/application-branding.md) · [application-development-process.md](../../ai/application-development-process.md)

**Mandatory:** every BreezeOn application supports **Light** and **Dark** themes (`BoThemeMode` / `IBoThemeModeService`). Theme Palette never removes either mode.

---

## Goals

1. Stable Theme Palette model before App #2
2. Applications customize identity without Shared UI code changes
3. Platform retains control of structural, text, field, and locked-nav chrome tokens

---

## Recommended customizable tokens (Theme Palette)

### Mandatory (every application Theme Palette)

Applications **must** be able to supply (or accept platform defaults for) these roles in **both** Light and Dark:

| Role | Platform token(s) | Notes |
| --- | --- | --- |
| Primary | `color-primary` | Nav rail fill, primary actions |
| Primary hover | `color-primary-hover` | Companion to Primary — always paired |
| Secondary | `color-secondary` | Secondary accent |
| Tertiary | `color-tertiary` | Soft surfaces, Home hub wash, secondary chrome |

These four roles are the **minimum mandatory Theme Palette** for every future BreezeOn application.

### Optional semantic overrides

Applications **may** override; omitted → platform defaults from [tokens.md](tokens.md):

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
| Primary / Secondary / Tertiary | **Mandatory app Theme Palette** |
| Navigation Background | **Not a separate app token** — bound to **Primary** (`--bo-color-nav-background` → primary) |
| Navigation Text | **Platform-controlled** (`color-nav-text*`) |
| Navigation Accent | **Platform-controlled** for selected fill — `color-nav-selected` remains the locked Light-tertiary-stable token ([tokens.md](tokens.md) § Nav-stable); do not expose as a free app override |
| Home Page Accent | **Not a separate app token** — Home hub derives from **Tertiary** (+ card-container) per [shell.md](../shell/shell.md) |
| Card Accent | **Not a separate app token** — use Tertiary / card-container platform roles |
| Success / Warning / Error / Info | **Optional** Theme Palette overrides |

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

Apps customize **identity accents**, not the entire design system.

---

## Representation in application configuration

Theme Palette is an **application-owned** configuration object (host options / config section — exact type name is Shared UI implementation detail) with this shape:

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
- Omitted mandatory roles → platform default palette for that mode.
- Product hosts apply the palette through Shared UI theme APIs (`BoThemeOptions` / provider) — **no** per-app fork of `breezeon-ui.css`.

---

## Light and Dark structure

| Rule | Standard |
| --- | --- |
| Modes | Light and Dark both required |
| Switching | Existing `IBoThemeModeService` + cookie persistence |
| Per-mode values | Each customizable role may differ between Light and Dark |
| Derived relationships | Nav background follows Primary; Home wash follows Tertiary; do not duplicate those as separate mandatory app tokens |

---

## Mandatory for every future application

1. Support Light and Dark theme switching
2. Accept Theme Palette configuration (even if empty → platform defaults)
3. Treat Primary + PrimaryHover + Secondary + Tertiary as the mandatory customizable set
4. Keep Application Logo / Navigation Logo / Theme Palette as independent branding inputs ([application-branding.md](../shell/application-branding.md))

---

## Implementation status

Token **values** for product apps are not finalized here (hex remains platform defaults until a product supplies a Theme Palette).

**Shipped configuration surface (Shared UI):**

- `BoThemePaletteConfiguration` with `Light` / `Dark` (`BoThemePaletteModeConfiguration`: Primary, PrimaryHover, Secondary, Tertiary, optional Success / Warning / Error / Info)
- Register via `Configure<BoThemePaletteConfiguration>(…)` after `AddBreezeOnUI`
- Applied by `BoThemeModeService` without per-app CSS forks

This file remains the model SSOT for which tokens are app-configurable vs platform-controlled.
