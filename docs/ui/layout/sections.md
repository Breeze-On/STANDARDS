<!-- Classification: AA; Scope: platform; Domain: UI; Capability: Layout -->
# UI — Sections

Owner: UI

Main Section and Sub Section content grouping. Related: [layout.md](layout.md) (Row + page composition), [forms.md](../controls/forms.md), [tokens.md](../foundations/tokens.md), [overview.md](../overview.md), [expandable-section.md](expandable-section.md) (disclosure vs form collapse).

**Composition (hard standard):** Form fields **must** be inside a [`BoRow`](layout.md#row-borow); every `BoRow` **must** be inside a Section. Full rules: [layout.md — Page composition](layout.md#page-composition-locked--hard-standard).

## Optional collapse (`IsCollapsible`)

Form Sections may opt into collapse without changing default behavior:

| Parameter | Default | Notes |
| --- | --- | --- |
| `IsCollapsible` | **`false`** | When false, behavior/visuals match legacy always-open sections (zero migration) |
| `Expanded` / `ExpandedChanged` | **`true`** | Bindable; when unbound, default **true** so content is not hidden by surprise |

When `IsCollapsible=true`, the section header becomes a WAI-ARIA disclosure control; the body uses the **same disclosure engine** as [`BoExpandableSection`](expandable-section.md) (animation, reduced-motion, DOM retention, `inert`/`aria-hidden` when collapsed). Main/Sub typography, header rule, validation badge, `Required`, and `HeaderActions` are retained. `HeaderActions` clicks must not toggle collapse.

### Default expand vs in-page navigation (locked)

| Concern | Rule |
| --- | --- |
| Page default | Initial `Expanded` (or host field default) applies when the **page** loads / the owning page component is created |
| In-page tabs / panels | Changing `BoTabs`, `BoPanelNavigation`, or other in-page chrome **must not** reset section expand/collapse to the page default |
| Host binding | Product hosts that set a constant `Expanded="true"` (or `"false"`) without `@bind-Expanded` will re-apply that value on every parent re-render — **do not** do this for collapsible sections the user can toggle. Use `@bind-Expanded` to a page-owned field; only reassign that field when intentionally resetting (e.g. leaving the page, or a documented context change such as ApplicationGUID for Quick Actions) |
| Remount | Navigating away and back to the route remounts the page and restores the documented default |

### Workspace / context navigation state (locked)

Cross-control rules for major workspace entry, Application / Business Entity (or equivalent) context changes, and sub-state inheritance: [ux-conventions.md](../patterns/ux-conventions.md) § Navigation / workspace state. Section expand/collapse rules above remain the SSOT for in-page chrome; workspace primary-view reset is a separate product concern documented in that conventions file.

**Hard rules:**

- Collapsed content **remains mounted** (visibility only — never `@if (Expanded)` unmount).
- Error Message Pages use **`BoExpandableSection`**, not collapsible Main/Sub.
- Do not invent custom expand/collapse on form pages — use `IsCollapsible` or `BoExpandableSection` as appropriate.
- Do not re-apply page-default expand/collapse on in-page tab or panel changes.

## Main Section (`BoSectionMain`)

**Display name:** Main Section.  
**Component:** `BoSectionMain` in [breezeon-system-shared-ui](https://github.com/Breeze-On/breezeon-system-shared-ui).

A **Main Section** groups related page content. It is intentionally **not** a floating card:

| Concern | Main Section (`BoSectionMain`) | Content card (`BoCard`) |
| --- | --- | --- |
| Outer chrome | No border, no shadow; transparent background | Card-container border / shadow / fill |
| Content body padding | **6px** equal on all four sides | Theme spacing on the card |
| Content body width | Full width of the section (edge-to-edge) | Within card padding |
| Outside bottom margin | **16px** between stacked Main Sections; **0** when the Main Section is `:last-child` (shell body padding provides the bottom inset) | N/A |
| Optional header | Yes (see below) | Simple title/footer (card chrome) |

Header is **optional**. When omitted, only the body content is rendered.

### Optional header

| Concern | Standard |
| --- | --- |
| Label | Bold, **13px**, **uppercase**; color `--bo-color-section-tab-label` (alias of `color-semantic-black`, default `#000000`); top-left aligned — see [tokens.md](../foundations/tokens.md) |
| Icon | Optional; to the **left** of the label; ~13px; tight **2px** gap to label; **vertically center-aligned** with the label; same color as label (prefer `BoIcon` in `IconContent`) |
| Rule | Grey horizontal line **directly under** the header text/icon row; almost no gap (~2px); uses `--bo-color-card-container-border` |
| Flush to body | Content container sits **immediately under** the header rule — **no gap** |
| API | `SectionKey` (stable id for validation ancestry / fail badge); `Title` and/or `TitleContent`; optional `Required` (red asterisk after title — e.g. mandatory [grid](../controls/grids.md)); optional `IconContent`; optional `HeaderActions` (inline after title — e.g. grid Add New / Save); optional `IsCollapsible` / `Expanded` (see above); body via `ChildContent` |
| HeaderActions spacing | When `HeaderActions` is present, the section root gets `bo-section--with-header-actions`: slightly taller header row, rule margin, and **8px** body `padding-top`. Applied only on the section that owns the actions — **not** on ancestors that merely nest a grid |
| Validation fail | After Submit attempt, if `SectionKey` is in `BoValidationContext.FailedSectionMains`, show `BoValidationFailBadge` in the **left icon slot** (replaces `IconContent` while failed) — [forms.md](../controls/forms.md#deferred-mandatory-validation-locked) |

### Content container

The body (`ChildContent`) is the section **content container**: full section width, **6px** inside padding on **all four sides** (equal top/right/bottom/left), flush under the header rule when a header is present.

**Outside bottom margin:** **16px** below the section when another sibling follows (space after the content body / blue-box edge when stacked). When the Main Section is the parent’s `:last-child`, Shared UI sets **0** so it does not stack with `.bo-app-body` padding (keeps bottom inset equal to the top pad and avoids a phantom scrollbar). Do not rely on `BoStack` gap for Main/Sub spacing — use `Gap="0"` (or equivalent) when stacking sections so inter-section margin is not doubled.

Product apps must use `BoSectionMain` for Main Sections — do not reimplement this chrome in page CSS.

**Gallery reference:** Theme page (`/theme`) — header tabs Primary / Secondary / Tertiary / Background / Border / Field Label; each tab stacks Main `{Friendly Name} Color (Light Theme)` then Main `{Friendly Name} Color (Dark Theme)`, each with Sub **Attributes** (`BoFieldReadOnly`) and Sub **Preview** (swatch; no icons on either Sub).

## Sub Section (`BoSectionSub`)

**Display name:** Sub Section.  
**Component:** `BoSectionSub` in [breezeon-system-shared-ui](https://github.com/Breeze-On/breezeon-system-shared-ui).

A **Sub Section** is for nested/subordinate groupings inside a Main Section. It shares the optional header **structure** (flush rule, optional icon) and **6px** body padding with Main, but uses **different** title typography and **outside margins**.

| Concern | Standard |
| --- | --- |
| API | Same as Main: `SectionKey`, `Title` / `TitleContent`, optional `Required` (red asterisk after title), optional `IconContent`, optional `HeaderActions`, `ChildContent` |
| Single-field section label | When the Sub Section title **is** the field label (one mandatory control with `ShowLabel=false`), set `Required=true` on the Sub Section **and** on the field. Section asterisk is the visible mandatory mark; field `Required` still drives deferred validation. See [forms.md](../controls/forms.md) Text Area `ShowLabel` |
| HeaderActions spacing | Same `bo-section--with-header-actions` rules as Main |
| Validation fail | Same badge as Main when `SectionKey` ∈ `FailedSectionSubs`; cascades Main + Sub keys to child fields |
| Content body padding | **6px** equal on all four sides (same as Main) |
| Label | Bold, **11px** (Main 13px − 2), **not uppercase** (sentence / title case as provided); color `--bo-color-section-tab-label` |
| Icon (when present) | ~11px; **2px** gap to label; same alignment rules as Main |
| Outside left / right margin | **6px** each (indent vs Main) |
| Outside top margin | **8px** |
| Outside bottom margin | **4px** (tighter than Main’s 16px) |

Use `BoSectionSub` for nested groupings; use `BoSectionMain` for top-level page sections. When stacking sections, prefer `BoStack Gap="0"` so outside margins are not doubled by stack gap.
