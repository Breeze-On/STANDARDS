<!-- Classification: AA; Scope: platform; Domain: UI; Capability: Patterns -->
# UI — UX conventions (cross-control)

Owner: UI

Organization standards that apply across `Bo*` controls and product pages. Control-specific details remain in [forms.md](../controls/forms.md), [grids.md](../controls/grids.md), [shuffle-card-grid.md](../controls/shuffle-card-grid.md), [validation-summary.md](validation-summary.md), and [overlays.md](../shell/overlays.md). Related: [page-development.md](../page-development.md), [example-governance.md](../example-governance.md).

Current reality only. Incomplete without Gallery working examples for library-scoped patterns ([example-governance.md](../example-governance.md); index: [gallery-index.md](../gallery-index.md)).

**Rule strength:** headings marked "(locked)" here are **Tier 1 — LOCKED** for behavior rules and **Tier 2 — STANDARD** for any visual literal they quote (the token is the authority). Definitions, change control, and precedence: [normative-tiers.md](../foundations/normative-tiers.md). Chrome-level deviation is justified in the Compliance Review below; behavior deviation needs a [registered deviation](../../deviations/README.md).

## UX Standards Compliance Review (locked — before development)

Every UI-bearing feature must pass a **UX Standards Compliance Review** before development begins. This gate has the **same weight** as schema, security, portability, and reusability challenges. Architecture approval is **not** UX approval. Incomplete UX discovery is a **planning defect**, not a build-time surprise.

Planning Agents must document a **UX Standards Compliance** subsection in every UI plan:

| Item | Required content |
| --- | --- |
| Shared UI reuse | Which `Bo*` components are reused |
| Gallery | Which Gallery examples were reviewed **against STANDARDS** (STANDARDS win on conflict) |
| Applicable standards | Links to `page-development.md`, this file, and control SSOTs |
| Page Freeze | When freeze is used / not used; Process Save/Submit **minimum 1500ms** then redirect ([process-persistence.md](process-persistence.md)) |
| Placeholders | Default resources vs documented semantic exceptions |
| Navigation state | Reset vs keep-alive intent |
| Truncation | How long values stay stable (ellipsis + hover title) |
| Disabled / read-only | Which path for each non-editable value; **Process View = read-only display (not Disabled)** ([process-view.md](process-view.md)) |
| Deviations | Any intentional deviation with justification |
| Validation Summary Adoption Matrix | Required / Optional / Not Recommended for Save/Commit validation UX ([validation-summary.md](validation-summary.md)) |
| Selection / navigation control | Which control and why, per the [decision matrix](../controls/selection-and-navigation.md); intent event used for guarded surfaces |
| Buttons / Actions | Variants per [button.md](../controls/button.md); [Actions area](actions-area.md) when a working copy exists |
| Page archetype / states | [page-archetypes.md](page-archetypes.md) shape chosen; [page-states.md](page-states.md) mechanisms; Process View **terminal** after Create → Save/Submit |

Development Agents must confirm an existing Shared UI component or documented STANDARDS pattern does **not** already solve the problem before introducing custom UX. Prefer Gallery as copy source **only after** SSOT confirmation ([example-governance.md](../example-governance.md)). Undocumented deviations in a plan are refused at Build Locally. Multi-row Save validation always uses field chrome + toast; use `BoValidationSummary` when the Adoption Matrix says Required or the product opts in — do not invent host error lists, and do not enable summary by default on product Inline Edit.

## Button corner radius (locked)

Single authority: [button.md § Corner radius](../controls/button.md#corner-radius--single-authority-tier-2) (behavior) and [tokens.md § Corner radius](../foundations/tokens.md#corner-radius-tokens-current) (value). All buttons and Shared UI action chrome — and header / section `BoTabs` — use `--bo-button-radius`; product apps must not fork `border-radius` on `.bo-button`. Not restated here.

## Buttons, selection, and page states (cross-reference)

| Concern | SSOT |
| --- | --- |
| Button hierarchy, ordering, destructive, icon-only, Save / Discard | [button.md](../controls/button.md) |
| Tabs vs Toggle vs Panel Navigation vs Drop-Down; selection authority; keyboard | [selection-and-navigation.md](../controls/selection-and-navigation.md) |
| Empty / loading / error / toast semantics | [page-states.md](page-states.md) |
| Page / workspace Actions area | [actions-area.md](actions-area.md) |
| Process Request section (mandatory baseline) | [process-request-section.md](process-request-section.md) |
| Default initiation experience | [initiation-experience.md](initiation-experience.md) |
| Page footer Save + Submit | [page-footer-actions.md](page-footer-actions.md) |
| Process persistence (Save/Submit → Process View) | [process-persistence.md](process-persistence.md) |
| Process View (terminal read-only) | [process-view.md](process-view.md) |
| New Application Checklist | [application-bootstrap-checklist.md](../../application-bootstrap-checklist.md) |

## Column header alignment (locked)

| Surface | Header alignment | Value / cell alignment |
| --- | --- | --- |
| `BoGrid` | **Always left** | Column `Align` (text/date Left; number/currency Right by default) |
| `BoShuffleCardGrid` | Follows column `Align` (Left / Center / Right) | Same `Align` on the cell |

- Shuffle Card header and row tracks **must** share the same `WidthTrack` definition; product CSS must not fork header/row track alignment.
- Shuffle Card reorder handle + row-action icons are **always leading** (first track) — end-of-row placement is not supported ([shuffle-card-grid.md](../controls/shuffle-card-grid.md)).
- Checkbox-only Shuffle columns use `Align="Center"`.
- This Grid vs Shuffle header difference is **intentional** (table thead vs card-track headers).

## Control width and truncation (locked)

| Concern | Standard |
| --- | --- |
| Layout stability | Host declares `BoRow` `Weight` or Shuffle/Grid track widths. **Selected values must not change control width** or skew columns |
| Truncation | Long closed values **truncate** with ellipsis; hover `title` (or equivalent) exposes the full value when truncated |
| Surfaces | `BoDropDownList` closed single value; `BoFieldReadOnly` / dense display text; `BoGrid` display cells (existing). Edit cells may scroll/wrap only when a control standard explicitly allows it. **`BoTextArea`** soft-wraps with `pre-wrap` (no single-line ellipsis); read-only clamps to the 6-row max with shared **Read more** when taller ([forms.md § Text Area](../controls/forms.md#text-area-botextarea)). Process History Comments reuse the same `BoClampedPlainText` pattern (2-line clamp) |
| Shuffle tracks | **MUST** use `minmax(0, …fr)` tracks (never `minmax(8rem, 1fr)` / bare `1fr`) so content cannot force horizontal growth past the track. Shared UI sets `min-width: 0` on cols and fields; header and rows must resolve identical tracks (no content-derived `min-width`) |
| Anti-pattern | Sizing controls from selected text length; custom product CSS that disables Shared UI truncation |

## Placeholder standards (locked)

| Concern | Standard |
| --- | --- |
| Default | When `Placeholder` is null/whitespace, use the control’s platform resource (`Field_Placeholder_Default`, `Field_DropDown_Placeholder_Default`, `Field_Date_Placeholder_Default`, `Field_DateTime_Placeholder_Default`, `Field_Number_Placeholder_Default`, `Field_PeoplePicker_Placeholder_Default`) |
| Overrides | **Forbidden** to echo the field label, column header, or section title |
| Semantic exceptions | Allowed only when the placeholder carries meaning that is **not** an echo of the field label/column title or a restatement of “empty”, and the justification is documented in the product docs. Optional single-select fields (e.g. an optional Role on a Step) use the platform default placeholder plus the platform clear affordance — do not invent “None (…)” strings |
| Grid Family filter row | Documented exception: use **`Grid_Filter_Placeholder`** (`Search...`) — not the column title and not `Field_Placeholder_Default` ([grids.md § Filtering](../controls/grids.md#filtering-lightweight--locked)) |
| Disabled | Placeholder is **always omitted** when `Disabled` (all editable `Bo*` inputs, including Text Field, Text Area, Drop-Down List and People Picker) |
| Grid / Shuffle cells | Same rules — do not pass column titles as `Placeholder` |

## Disabled vs read-only vs N/A (locked)

| Mode | Use when | Visual / behavior |
| --- | --- | --- |
| **Disabled** | Temporarily non-interactive editable control (busy, permission, **type-conditional columns that keep their grid/shuffle track** — e.g. Decimals when type ≠ Number/Decimal, Data Entity when type ≠ Data Entity) | Shared disabled chrome: greyer fill (`--bo-color-background`), muted text (same token family as disabled Text Field), no placeholder, no mandatory asterisk, no character count, skip required validation; clear value visually when not applicable |
| **ReadOnly** / Display / `BoFieldReadOnly` | Value is inherently non-editable on this surface | Prefer `BoFieldReadOnly` or a Display template — **not** a permanently disabled editor that looks broken |
| **N/A (`IsHidden`)** | Field must not occupy layout for this row/type (no dedicated column/track) | Hide with `IsHidden` (collapse unless `PreserveLayoutWhenHidden`) |

All editable inputs (`BoTextField`, `BoDropDownList`, `BoNumberField`, `BoDateField`, `BoPeoplePicker`) share the same disabled visual contract.

## Navigation / workspace state (locked)

| Concern | Standard |
| --- | --- |
| Major workspace entry | Opening a major product workspace (or changing Application / Business Entity / equivalent context) opens the **documented primary view** |
| Sub-state inheritance | Do **not** inherit prior tab, panel, toggle, or filter sub-state across major workspace / context changes unless the page **explicitly documents** keep-alive intent. Grid Family column-filter visibility and terms are **component-instance only** (cleared on leave) |
| In-page chrome | Tab / panel / toggle changes within the same workspace follow existing section expand rules — [sections.md](../layout/sections.md#default-expand-vs-in-page-navigation-locked) |
| Route remount | Navigating away and back remounts the page and restores documented defaults |
| Shell navigation motion | Pathname or `AE` query changes receive shell-owned enter motion via `BoAppBody`; other query-only updates stay silent — [navigation-motion.md](../shell/navigation-motion.md). Product apps must not fork route transitions |
| In-page Configuration Session | Allowed for EAC Application Configuration: circuit-scoped baselines keyed by Application + Business Entity while the page stays mounted; cross-route remount still rebuilds ([configuration-session-cache.md](../../../architecture/app-configuration/configuration-session-cache.md)) |
| Product docs | Each workspace documents its primary view and any intentional keep-alive exceptions |

## Page Freeze (summary)

Full rules: [overlays.md](../shell/overlays.md) § Page freeze.

| MUST | MUST NOT |
| --- | --- |
| Saves / deletes / imports / exports / sync / bulk ops | Grid filter / sort / page / search |
| Process Save / Submit: freeze immediately (“Processing...”), paint before validation, **≥1500ms only on success**, then redirect to Process View | Leaving initiation editable after successful Save/Submit; holding 1500ms after validation failure |
| Workspace or configuration hydration with perceptible backend work (including panel/tab **activation that reloads data**) | Chrome-only tab / accordion / dialog open without backend work |
| Perceptible lookup loads before edit dialogs | Validation-only / local UI / sub-second work |
| | Ordinary route navigation that paints chrome before optional secondary fetches |

Prefer `IBoPageFreezeService.RunAsync`. Do **not** invent page-local loading overlays.

## Admin surface language (locked)

| Concern | Standard |
| --- | --- |
| Identifiers | Persist Codes / GUIDs as required by data standards; **do not** expose implementation property names (`ExternalObjectId`, table/column names, CLR type names) in admin-facing copy |
| Technical Settings columns | Allowed when they are the administrator’s configuration contract; label them in **product language** |
| Messages | Validation and toast text stay user-facing; no raw schema or API tokens |

## Enforcement

- Shared UI owns CSS/behavior defaults where possible.
- [page-development.md](../page-development.md) checklist items cover these conventions.
- Planning / Dev agent rules require the Compliance Review and reuse-first checks — [planning-and-development-agents.md](../../ai/planning-and-development-agents.md).
- Human / agent PR gate: [ux-pr-review-checklist.md](../ux-pr-review-checklist.md).
