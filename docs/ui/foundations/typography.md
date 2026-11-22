<!-- Classification: AA; Scope: platform -->
# UI — Typography

Owner: UI

Typeface and type scale for `BreezeOn.UI`. Related: [tokens.md](tokens.md), [icons.md](icons.md), [forms.md](../controls/forms.md), [normative-tiers.md](normative-tiers.md), [overview.md](../overview.md).

## Default typeface (hard standard — Tier 1)

Default UI font for Breeze On applications using `BreezeOn.UI` is **Calibri** (`BoThemeOptions.FontFamily` / `--bo-font-family`, with Segoe UI / system-ui as fallbacks only). Do not change the default typeface without an explicit org decision and STANDARDS update. Do not replace the default with Segoe UI or system-ui-only stacks.

Text Field input text uses Calibri at **14px** — see [forms.md](../controls/forms.md).

## Type scale (Tier 2 — STANDARD)

The sizes below are the sizes the shipped library uses. **Choose from this scale** for custom CSS and new controls; do not introduce new font sizes. Sizes are documented values from `breezeon-ui.css` — there are **no `--bo-font-size-*` tokens yet** (only `--bo-font-family`); a token set is Future Validation (FV-013). Cite the step name, not a one-off literal.

| Step | Size | Typical weight / case | Used for (current) |
| --- | --- | --- | --- |
| **Display** | 28px (1.75rem) | Bold | `BoPageHeader` title |
| **Title** | 24px (1.5rem) | Bold | `BoAppHeader` `AppTitle`; Error Message title |
| **Heading** | 18px (1.125rem) | Bold | `BoCard` title |
| **Subtitle / lead** | 16px (1rem) | Regular | `BoAppHeader` `Subtitle`; Error Message message |
| **Body large** | 15px (0.9375rem) | Regular | Page Freeze message; Error Message detail copy |
| **Body** | 14px (0.875rem) | Regular | Editable field input text; dialog footer error; detail values |
| **Label / control** | 13px (0.8125rem) | Bold for section labels; regular for tab / panel-nav / toast body | Main Section label (**uppercase**); header-tab label; Panel Navigation item label; toast Body; Gallery / admin controls |
| **Meta** | 12px (0.75rem) | Regular | Grid cell text and pager; Drop-Down chips and chevron; profile identity |
| **Caption** | 11px (0.6875rem) | Bold | Sub Section label (**not** uppercase); calendar weekday; Nav-card category / badge |
| **Field label** | 10px | Bold, **uppercase** | Field label chrome (`--bo-color-text-field-label`): Text Field / Drop-Down / Date / Number / Read-Only; grid and Shuffle Card column headers; Nav-card description; validation "required" text |

Rules:

1. **Field-label chrome is 10px bold uppercase** everywhere a field or column label appears — one definition, reused by grid headers and Home card descriptions ([forms.md](../controls/forms.md), [grids.md](../controls/grids.md), [shell.md](../shell/shell.md)).
2. **Main Section = 13px bold uppercase; Sub Section = 11px bold, not uppercase** ([sections.md](../layout/sections.md)).
3. Body text for inputs and read-only values is **14px**; do not shrink to fit — truncate with ellipsis + hover title ([ux-conventions.md](../patterns/ux-conventions.md#control-width-and-truncation-locked)).
4. Icons pair with the 16px step at 13px labels; see [icons.md](icons.md).
5. Fluid sizes (`clamp` / `cqi`) are used only for the Home hub card (label / icon / padding) so zoom and narrow columns stay inside the card ([shell.md § Home](../shell/shell.md#home--navigation-hub-locked-platform-pattern)); do not copy fluid type elsewhere.
6. Color for text comes from tokens (`--bo-color-text`, `--bo-color-text-muted`, `--bo-color-text-field-label`) — [tokens.md](tokens.md).

## Future Validation

| Id | Item |
| --- | --- |
| FV-013 | Emit the type scale as `--bo-font-size-*` tokens and migrate literal sizes in `breezeon-ui.css` (the CSS currently also contains off-scale `rem` / `px` duplicates of these steps) |
