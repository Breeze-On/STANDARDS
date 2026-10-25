# UI — Sections

Main Section and Sub Section content grouping. Related: [layout.md](layout.md) (Row + page composition), [forms.md](../controls/forms.md), [tokens.md](../foundations/tokens.md), [overview.md](../overview.md).

**Composition (hard standard):** Form fields **must** be inside a [`BoRow`](layout.md#row-borow); every `BoRow` **must** be inside a Section. Full rules: [layout.md — Page composition](layout.md#page-composition-locked--hard-standard).

## Main Section (`BoSectionMain`)

**Display name:** Main Section.  
**Component:** `BoSectionMain` in [SYSTEM-SHARED-UI](https://github.com/Breeze-On/SYSTEM-SHARED-UI).

A **Main Section** groups related page content. It is intentionally **not** a floating card:

| Concern | Main Section (`BoSectionMain`) | Content card (`BoCard`) |
| --- | --- | --- |
| Outer chrome | No border, no shadow; transparent background | Card-container border / shadow / fill |
| Content body padding | **6px** equal on all four sides | Theme spacing on the card |
| Content body width | Full width of the section (edge-to-edge) | Within card padding |
| Outside bottom margin | **16px** (`BoSectionMain`) | N/A |
| Optional header | Yes (see below) | Simple title/footer (card chrome) |

Header is **optional**. When omitted, only the body content is rendered.

### Optional header

| Concern | Standard |
| --- | --- |
| Label | Bold, **13px**, **uppercase**; color `--bo-color-section-tab-label` (alias of `color-semantic-black`, default `#000000`); top-left aligned — see [tokens.md](../foundations/tokens.md) |
| Icon | Optional; to the **left** of the label; ~13px; tight ~4px gap to label; **vertically center-aligned** with the label; same color as label (prefer `BoIcon` in `IconContent`) |
| Rule | Grey horizontal line **directly under** the header text/icon row; almost no gap (~2px); uses `--bo-color-card-container-border` |
| Flush to body | Content container sits **immediately under** the header rule — **no gap** |
| API | `Title` and/or `TitleContent`; optional `IconContent`; body via `ChildContent` |

### Content container

The body (`ChildContent`) is the section **content container**: full section width, **6px** inside padding on **all four sides** (equal top/right/bottom/left), flush under the header rule when a header is present.

**Outside bottom margin:** **16px** below the section (space after the content body / blue-box edge when stacked). Do not rely on `BoStack` gap for Main/Sub spacing — use `Gap="0"` (or equivalent) when stacking sections so this margin is not doubled.

Product apps must use `BoSectionMain` for Main Sections — do not reimplement this chrome in page CSS.

**Gallery reference:** Theme page (`/theme`) — header tabs Primary / Secondary / Tertiary / Background / Border / Field Label; each tab uses Main Section (`{Friendly Name} Color`) with Sub Sections **Attributes** (fields) and **Preview** (swatch; no icons on either Sub).

## Sub Section (`BoSectionSub`)

**Display name:** Sub Section.  
**Component:** `BoSectionSub` in [SYSTEM-SHARED-UI](https://github.com/Breeze-On/SYSTEM-SHARED-UI).

A **Sub Section** is for nested/subordinate groupings inside a Main Section. It shares the optional header **structure** (flush rule, optional icon) and **6px** body padding with Main, but uses **different** title typography and **outside margins**.

| Concern | Standard |
| --- | --- |
| API | Same as Main: `Title` / `TitleContent`, optional `IconContent`, `ChildContent` |
| Content body padding | **6px** equal on all four sides (same as Main) |
| Label | Bold, **11px** (Main 13px − 2), **not uppercase** (sentence / title case as provided); color `--bo-color-section-tab-label` |
| Icon (when present) | ~11px; same alignment rules as Main |
| Outside left / right margin | **6px** each (indent vs Main) |
| Outside top margin | **8px** |
| Outside bottom margin | **4px** (tighter than Main’s 16px) |

Use `BoSectionSub` for nested groupings; use `BoSectionMain` for top-level page sections. When stacking sections, prefer `BoStack Gap="0"` so outside margins are not doubled by stack gap.
