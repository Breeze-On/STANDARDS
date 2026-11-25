<!-- Classification: AA; Scope: platform; Domain: UI; Capability: Foundations -->
# UI — Accessibility baseline

Owner: UI

Platform accessibility target and baseline for every page and `Bo*` control. Related: [selection-and-navigation.md](../controls/selection-and-navigation.md), [button.md](../controls/button.md), [icons.md](icons.md), [motion.md](motion.md), [tokens.md](tokens.md), [forms.md](../controls/forms.md), [overlays.md](../shell/overlays.md), [grids.md](../controls/grids.md), [normative-tiers.md](normative-tiers.md).

Current reality only.

## Target (Tier 1 — LOCKED)

**WCAG 2.2 Level AA** is the accessibility target for all Breeze On UI built on `BreezeOn.UI`. New controls and pages are designed to meet it; known gaps are recorded as Future Validation (below), not silently accepted.

## Keyboard baseline (Tier 1)

| Concern | Standard |
| --- | --- |
| Operable by keyboard | Every interactive control is reachable and operable with the keyboard alone; no keyboard trap |
| Tab order | Follows visual / reading order. Composite widgets (tabs, toggle, panel navigation) are **one** Tab stop using roving focus; arrow keys move within ([selection-and-navigation.md](../controls/selection-and-navigation.md)) |
| Activation | Native `<button>` / link semantics: Enter / Space activate |
| Dialog | Enter = primary (when configured), Escape = close, focus moves in on open and is restored on close ([overlays.md](../shell/overlays.md)) |
| Popups | Open Drop-Down / Date / People Picker consume Escape first |
| Grid | Sortable headers are focusable (`tabindex="0"`) with `aria-sort`; Nested View Left / Right expand / collapse; Add New moves focus to the first editable field ([grids.md](../controls/grids.md)) |
| Shuffle reorder | Keyboard reorder is **not shipped** (Future Validation FV-004); handle remains pointer-driven |

## Focus (Tier 1 for visibility; Tier 2 for the ring token)

- **Focus must be visible** on every interactive element. The shared ring is `--bo-focus-ring` (`0 0 0 2px var(--bo-color-primary)`) — [tokens.md § Layering and focus tokens](tokens.md#layering-and-focus-tokens-current). Editable fields use the full-border focus model (`--bo-color-field-border-focus`) instead.
- Do not remove outlines (`outline: none`) without an equivalent visible indicator.
- Focus order after a state change: new content that appears because of a user action (Add New row, opened dialog, navigate-to-error) receives focus deliberately; closing an overlay returns focus to its opener.

## Names, roles, and states (Tier 1)

| Concern | Standard |
| --- | --- |
| Accessible name | Every control has one: visible label, `aria-label`, or `aria-labelledby`. Icon-only controls require `AriaLabel` (`BoIconButton` throws without it) |
| Landmarks | `<nav>` for left navigation with localized `aria-label` ([navigation.md](../shell/navigation.md)) |
| State | Expose state, not just color: `aria-selected`, `aria-checked`, `aria-expanded`, `aria-sort`, disabled |
| Decorative icons | `aria-hidden="true"`; meaningful icons need a text alternative ([icons.md](icons.md)) |
| Collapsed nav | Labels are **visually hidden**, not `display: none`, so they stay in the accessibility tree |
| Localization | Accessible names are localized like any visible text ([i18n.md](i18n.md)) |

## Color and contrast (Tier 2)

- Text and meaningful icons meet **4.5:1** (large text **3:1**) against their background; UI component boundaries and focus indicators meet **3:1**.
- Do not convey information by color alone (validation uses icon/badge + text + color; sort uses arrow + weight).
- Use palette tokens only ([tokens.md § Palette rules](tokens.md#palette-rules-locked)); Save / Discard token pairs are specified at ≥ 4.5:1 foreground-on-fill in both modes.
- When Customer Branding supplies `primaryColor` / `secondaryColor` / `tertiaryColor`, the palette generator **must** validate derived foreground/background pairs to WCAG 2.2 AA and document accessible role-specific variants when an exact brand hex cannot safely serve a role — [application-theme-palette.md](application-theme-palette.md).
- **Dark mode contrast across all components is Future Validation** (FV-002) — a full audit (focus ring, toast, field borders on dark surfaces) has not been performed.

## Motion (Tier 1)

Honor `prefers-reduced-motion: reduce` — no travel, FLIP, lift, or settle animation; state changes are instant ([motion.md](motion.md)). No auto-playing motion that cannot be paused.

## Targets and spacing (Tier 3)

Single-line editable controls are ~32px tall; keep pointer targets at least that large for primary actions. Dense row icon actions use 16px glyphs inside padded hit areas ([icons.md](icons.md)).

## Responsive baseline (Tier 3 — recorded reality)

Two shipped breakpoints: **≤ 768px** (Home hub stacks cards then brand — [shell.md](../shell/shell.md#home--navigation-hub-locked-platform-pattern)) and **< 48rem** (workspace `BoPanelHost` stacks Left → Fill → Right — [panels.md](../layout/panels.md)). There is no general mobile layout standard beyond these; the platform is an admin / workspace UI optimized for desktop.

## Validation and errors (Tier 1)

- Required fields: asterisk immediately; error chrome only **after** a validation attempt ([forms.md](../controls/forms.md#deferred-mandatory-validation-locked)).
- Multi-row save failures use the [Validation Summary](../patterns/validation-summary.md) with navigate-to-error.
- Toast and page-state semantics: [page-states.md](../patterns/page-states.md).

## Future Validation

| Id | Item |
| --- | --- |
| FV-002 | Dark-mode focus-ring / toast / border contrast audit |
| FV-004 | Shuffle Card keyboard reorder |
| FV-009 | Automated accessibility checks (axe or equivalent) in Gallery CI |
| FV-012 | Shuffle Card Grid header row is `aria-hidden`; cell editors have no programmatic column name ([shuffle-card-grid.md § Accessibility](../controls/shuffle-card-grid.md#accessibility)) |
