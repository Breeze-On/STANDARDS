<!-- Classification: AA; Scope: platform; Domain: UI; Capability: Patterns -->
# UI — Page archetypes

Owner: UI

Catalog of the **page shapes** a Breeze On application is built from. Planning and development agents choose an archetype first, then follow its composition. Related: [page-development.md](../page-development.md), [layout.md](../layout/layout.md), [shell.md](../shell/shell.md), [panels.md](../layout/panels.md), [grids.md](../controls/grids.md), [actions-area.md](actions-area.md), [page-states.md](page-states.md), [selection-and-navigation.md](../controls/selection-and-navigation.md), [normative-tiers.md](../foundations/normative-tiers.md).

Current reality only. Every archetype lives inside `BoAppShell` (Option B) with a localized per-page `AppTitle` ([shell.md](../shell/shell.md#header-titles-per-page)); the route equals the page name ([navigation.md](../shell/navigation.md#route--url-hard-standard)).

## Choose an archetype

| If the page is… | Archetype |
| --- | --- |
| The landing hub of the application | [Home](#home) |
| Browse / search / maintain a dataset | [List](#list) |
| View or edit one record or one set of settings | [Detail / Edit](#detail--edit) |
| A large multi-section configuration experience (10–30 sections) | [Workspace](#workspace) |
| A standardized failure state | [Error](#error) / [Access Denied](#access-denied) |

## Summary matrix

| Archetype | Layout core | Footer (`ShowFooter`) | Body scroll | Header tabs | Planning JSON schemaVersion 1 |
| --- | --- | --- | --- | --- | --- |
| Home | `BoNavHub` + `BoNavCardStyleHyperlink` | **false** | None (hub fills the slot) | No | Not expressible |
| List | Filters section + `BoGrid` section | Per page | Body scrolls | Optional | **Partial** — Filters section only |
| Detail / Edit | Section → Row → Field | Per page | Body scrolls | Optional (page segmentation) | **Yes** — the forms-only schema is built for this |
| Workspace | `BoPanelHost` (Left nav + Fill keep-alive) | Per page | Panels scroll independently | No (use Panel Navigation) | **Partial** — field content inside a panel only |
| Error | Error Message framework | **false** (must) | Standard | No (single scenario on the Gallery showcase) | Not expressible |
| Access Denied | `BoAccessDenied` | **false** (must) | Standard | No | Not expressible |

## Home

`BoNavHub` with one `BoNavCardStyleHyperlink` per application destination; `ShowFooter = false`; no body scrollbar; **no Home subtitle**; card **Description** = destination page **Subtitle**; right-panel asset is **Application Logo** (independent of Navigation Logo). Not a form layout — never Section → Row → Field. Per-app only: card count, routes, labels, icons, Application Logo, Theme Palette. Rules: [shell.md § Home](../shell/shell.md#home--navigation-hub-locked-platform-pattern) · [application-branding.md](../shell/application-branding.md). Checklist: [page-development.md § Home pages](../page-development.md#home-pages).

## List

Browse, search, and maintain a dataset.

```text
BoStack Gap="0"
├─ Filters  (BoSectionMain / BoSectionSub + BoRow; no Apply button)   <- optional
└─ Grid section (BoGrid owns Title + header actions [Add New | Save | Filters])
   └─ BoValidationSummary Errors band (only after a failed Save/Commit; editable modes)
```

| Concern | Standard |
| --- | --- |
| Data surface | `BoGrid` section-level (ReadOnly default; RowEdit / InlineEdit for maintenance; NestedView for hierarchy). Not a `BoRow` child — [grids.md](../controls/grids.md) |
| Filtering | Dedicated Filters section above the grid, **no Apply**; ~750 ms text debounce; Client pipeline Filter → Sort → Page, or Server `QueryMode` with one primary retrieval contract — [query-driven-retrieval.md](../controls/query-driven-retrieval.md) |
| Row actions | `BoIconButton` / grid built-in actions; Add New at top + first-editable focus — [button.md](../controls/button.md) |
| Selection | `EnableSelection` when bulk actions exist — [selection-and-navigation.md](../controls/selection-and-navigation.md#grid-selection-brief) |
| Editable list with Save/Discard | [Actions area](actions-area.md) above the grid; grids set `ShowSave="false"`; Dirty State guards abandon points |
| States | Empty body, Page Freeze on load / save, Alert toast on validation fail — [page-states.md](page-states.md) |
| Reorderable cards | Use `BoShuffleCardGrid` instead of `BoGrid` — [shuffle-card-grid.md](../controls/shuffle-card-grid.md) |

Gallery: Components → Other → Grid. EAC reference: Applications, Users Security.

## Detail / Edit

View or edit one record or one settings set.

```text
Page → Body → [Actions area] → BoSectionMain → [BoSectionSub] → BoRow → Field
```

| Concern | Standard |
| --- | --- |
| Composition | Page → Section → Row → Field; every field a direct child of a `BoRow`; every `BoRow` inside a Section — [layout.md](../layout/layout.md#page-composition-locked--hard-standard) |
| Page segmentation | Optional header `BoTabs` (≈2–7 sections) with keep-alive `BoTabPanels`; `SectionKey` + `ValidationGroup` for fail badges — [selection-and-navigation.md](../controls/selection-and-navigation.md) |
| Working copy | [Actions area](actions-area.md) (Save | Discard) at the top; Save runs `Validate(null)`; Dirty State guards navigation and tab/toggle abandon points |
| Small edits | A `BoDialog` (Create / Edit / Confirm) instead of a new page; footer actions, not an Actions area — [overlays.md](../shell/overlays.md) |
| Validation | Deferred required chrome, Alert toast, fail badges; Validation Summary for multi-row editors — [forms.md](../controls/forms.md#deferred-mandatory-validation-locked) |
| Footer | Per page (Gallery Components / Theme keep the Submit footer) |

Gallery: Components field tabs (Text Field … Number Field) and Theme. Planning JSON: [layout.md § Page composition JSON](../layout/layout.md#page-composition-json-planning-agent-input).

## Workspace

A large multi-section configuration experience (App Configuration, onboarding, admin).

```text
BoPanelHost
├─ BoPanel Dock=Left   BoSectionMain "Navigation" → BoPanelNavigation (10–30 items)
└─ BoPanel Dock=Fill   [pinned Actions area]
                       BoKeepAlivePanels → BoKeepAlivePanel per Key (always mounted)
```

| Concern | Standard |
| --- | --- |
| Navigator | `BoPanelNavigation` — **not** header tabs; nav `Key` ≡ field `ValidationGroup` ≡ keep-alive `Key` — [panels.md](../layout/panels.md) |
| Content | `BoKeepAlivePanels` (never `@if` unmount validated sections); Section → Row → Field inside each panel |
| Scrolling | Each panel scrolls independently; body scroll suppressed while the host is visible; Actions pinned above the Fill scroll region ([panels.md § Pinned chrome](../layout/panels.md#pinned-chrome-inside-fill-eac-reference-composition)) |
| Abandon guard | Panel Navigation has no intent callback today — guard via Dirty State in `SelectedItemChanged` (interim; FV-008) — [selection-and-navigation.md](../controls/selection-and-navigation.md#selection-authority-model-tier-1--locked) |
| States | Page Freeze on cold hydration / panel activation that reloads data — [page-states.md](page-states.md) |

Gallery: Components → Other (demo vehicle). EAC reference: App Configuration.

## Error

Standardized failure state using the Error Message framework ([error-messages.md](../shell/error-messages.md)): shared `Bo*` + foundation CSS, application-agnostic copy, `ShowFooter = false`, showcase ≡ production. **Only Access Denied ships**; Not Found, Session Expired, and Maintenance are deferred and must reuse the framework design language.

## Access Denied

`BoAccessDenied` hosted by `BoAuthorizeRouteView` (route deny) or in-page; Access Details and Support Details in `BoExpandableSection`; `ShowFooter = false` on the product host. Gallery: Error Message Page (`/error-message-page`).

## Planning JSON scope

The Planning JSON (`schemaVersion "1"`) describes **form content only** (Sections → Rows → Fields). It does not express `BoGrid`, `BoShuffleCardGrid`, `BoToggle`, `BoTabs`, `BoButton`, panels, or page archetypes. For List and Workspace pages, planning agents describe the archetype and its parts in prose plus the JSON for any form sections. Details and limits: [layout.md § Schema scope](../layout/layout.md#schema-scope-forms-only).

## Adding an archetype

New shared page shapes are added here with composition, footer / scroll rules, planning-JSON support, a Gallery path (or a [DEV-002](../../deviations/DEV-002-example-governance-approved-exceptions.md) row), and a [page-development.md](../page-development.md) checklist entry in the same change set.
