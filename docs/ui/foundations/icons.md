<!-- Classification: AA; Scope: platform; Domain: UI; Capability: Foundations -->
# UI — Icons

Owner: UI

Icon technology and the **approved icon sizes** for `BreezeOn.UI`. Related: [tokens.md](tokens.md), [typography.md](typography.md), [navigation.md](../shell/navigation.md), [button.md](../controls/button.md), [accessibility.md](accessibility.md), [normative-tiers.md](normative-tiers.md).

API: [`BoIcon`](https://github.com/Breeze-On/SYSTEM-SHARED-UI/blob/main/docs/public-component-api.md#boicon) (`Name`, `Variant`, `Size`, `Class`).

Current reality only.

## Technology (Tier 1 — LOCKED)

- **Fluent System Icons through `BoIcon` only.** Product pages never reference Fluent icon types ([ADR-004](../../../decisions/ADR-004-breezeon-ui-abstraction-layer.md)) and never use ad-hoc image icons for nav items, buttons, or controls.
- `Name` = Fluent System Icons name without variant/size (for example `Delete`, `Dismiss`, `Edit`). `Variant` = `Regular` (outlined, default) or `Filled`.
- Icon-only controls use `BoIconButton`, which **requires** an accessible name ([button.md](../controls/button.md), [accessibility.md](accessibility.md)).
- Decorative icons that sit next to a visible label are `aria-hidden`; an icon that carries meaning alone needs a text alternative.

## Size scale (Tier 2 — STANDARD)

`BoIcon.Size` is in px. Use **one** of these; do not invent others.

| Size | Use | Paired text |
| --- | --- | --- |
| **16** | In-control and inline icons: header / section tabs, section header icons, dense row actions, Import Summary severity glyphs, buttons with a leading icon | **13px** label (tabs) / field and body text |
| **20** | **`BoIcon` default**; left-nav page icons; `BoIconButton` default (`IconSize` 20) | Nav label |
| **24** | Larger standalone actions where 20 is too small (rare; `BoIconButton.IconSize` allows 16 / 20 / 24) | — |
| **32** | Home hub destination cards (`BoNavCardStyleHyperlink.IconContent`) | Large card label |
| **48** | Error Message Page state badge ([error-messages.md](../shell/error-messages.md)) | Page-level message |

Rules:

1. **Tabs, section headers, buttons with leading icon, grid / card row actions:** 16.
2. **Left nav and default icon buttons:** 20.
3. **Home cards:** 32. **Error state badges:** 48.
4. Icon and label are **vertically center-aligned**; an empty icon slot collapses (no reserved gap).
5. Do not resize icons with CSS to hit an off-scale size — change `Size` to a scale value.
6. Failed-validation badges replace the normal icon in the **left icon slot** ([forms.md](../controls/forms.md#fail-badges)).

## Color

Icons inherit `currentColor` from their control (nav: white / black-selected; buttons: variant foreground). Do not set per-icon hex ([tokens.md](tokens.md) palette rule).

## Variants

- Prefer `Regular`. Use `Filled` for status glyphs where the Fluent filled form is the recognized symbol (for example Import Summary severity icons) and for selected / emphasized states defined by a control SSOT.
- Rotated glyphs use the shared modifier (`bo-icon--rotate-90`) rather than a different icon name (Panel Navigation title icon — [panels.md](../layout/panels.md)).

## Default new-application page icons (Tier 2 — STANDARD)

Unless a plan explicitly overrides IA icons, new product catalogs use these `BoIcon` **Regular** names (see [application-branding.md](../shell/application-branding.md) · [application-development-process.md](../../ai/application-development-process.md)):

| Page | `Name` |
| --- | --- |
| New Request | `AddSquareMultiple` |
| Status Report | `Dashboard` |
| My Tasks | `AppsListDetail` |

Resolver note: Home cards request Size **32**. Many Fluent Regular glyphs ship only at 16/20/24 (Dashboard Regular in Icons 5.0.1 is Size **20** only). `BoIconResolver` must include explicit Size **32** (and nav Size **20**) entries that fall back to the nearest available Fluent size — convention reflection alone will not find a missing Size32 type and the icon will render blank.

## Future Validation

| Id | Item |
| --- | --- |
| FV-003 | Fluent coupling through icon names — upgrades may rename glyphs; consider an alias layer |
