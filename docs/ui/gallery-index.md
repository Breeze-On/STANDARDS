<!-- Classification: AA; Scope: platform; Domain: UI; Capability: Patterns -->
# UI — Gallery index

Owner: UI

**Pattern → Gallery path** index for [SYSTEM-SHARED-UI](https://github.com/Breeze-On/SYSTEM-SHARED-UI) `BreezeOn.UI.Gallery`. "Copy from Gallery" ([example-governance.md](example-governance.md)) starts here. Gaps are registered as exceptions in [DEV-002](../deviations/DEV-002-example-governance-approved-exceptions.md). Related: [overview.md](overview.md), [page-development.md](page-development.md).

Current reality only. Update this table in the same change set as any Gallery demo added, moved, or removed.

## How to read paths

| Notation | Meaning |
| --- | --- |
| **Components** | Route `/components`. Header tabs (`BoTabs`, `TabKey`): Text Field (`text-field`), Drop-Down List (`drop-down-list`), People Picker (`people-picker`), Checkbox (`checkbox`), Date Field (`date-field`), Number Field (`number-field`), **Other** (`other`) |
| **Other → X** | Components → header tab **Other** → left `BoPanelNavigation` item **X**. Items (`Key`): Grid (`grid`), Page Freeze (`page-freeze`), Dialog (`dialog`), Toggle (`toggle`), Import Summary (`import-summary`), Validation Summary (`validation-summary`), Button (`button`) |
| **Theme** | Route `/theme` (tabs per palette color) |
| **Home** | Route `/` |
| **Error Message Page** | Route `/error-message-page` |
| **Context Selection Page** | Route `/context-selection-page` |

> Grid is **not** a top-level header tab. Path: Components → **Other** → **Grid** (panel nav key `grid`).

## Covered patterns

| Pattern | Standard | Gallery path |
| --- | --- | --- |
| Text Field | [forms.md](controls/forms.md) | Components → Text Field |
| Row layout (`Weight`), `BoEmptyField`, hide / preserve layout | [layout.md](layout/layout.md) | Components → Text Field → Row layout (Weight); Components → Parameters rows |
| Read-Only Field | [forms.md](controls/forms.md) | Theme → Attributes; Components → Preview (read-only column) |
| Drop-Down List (static `Items`, `AllowMultiple`, `DisplayCode`) | [forms.md](controls/forms.md) | Components → Drop-Down List |
| Drop-Down List async `ItemsProvider` Top-N | [forms.md](controls/forms.md), [query-driven-retrieval.md](controls/query-driven-retrieval.md) | Components → Drop-Down List → ItemsProvider |
| People Picker | [forms.md](controls/forms.md) | Components → People Picker |
| Checkbox | [forms.md](controls/forms.md) | Components → Checkbox |
| Date Field | [forms.md](controls/forms.md) | Components → Date Field |
| Number Field | [forms.md](controls/forms.md) | Components → Number Field |
| Deferred validation, Submit, fail badges | [forms.md](controls/forms.md) | Components → footer Submit (all field tabs) |
| Design tokens, Light / Dark palettes | [tokens.md](foundations/tokens.md) | Theme |
| Home hub (`BoNavHub`, `BoNavCardStyleHyperlink`) | [shell.md](shell/shell.md) | Home |
| Context Selection (`BoNavHub` brand panel + `BoNavCardStyleStatic` info header + compact icon/label BE cards; Home-style AppTitle) | [context-selection.md](patterns/context-selection.md) | Context Selection Page |
| App shell, left navigation, header actions (theme switch, Settings, profile) | [shell.md](shell/shell.md), [navigation.md](shell/navigation.md) | Every page (`MainLayout`) |
| Navigation motion (route / AE enter; compact AE press) | [navigation-motion.md](shell/navigation-motion.md) | Every `BoAppShell` page; Context Selection showcase |
| Header tabs (`BoTabs` / `BoTabPanels`), keep-alive panels | [shell.md](shell/shell.md#header-tabs-optional-page-sections) | Components, Theme, Error Message Page |
| Tabs keyboard + `TabRequested` veto | [selection-and-navigation.md](controls/selection-and-navigation.md) | Components → Other → Button → Tabs keyboard |
| Toggle | [toggle.md](controls/toggle.md) | Components → Other → Toggle |
| Panel Navigation + `BoKeepAlivePanels` + `BoPanelHost` | [panels.md](layout/panels.md) | Components → Other (the left navigator is the demo) |
| Buttons: Primary / Secondary / Stealth / Danger, `BoIconButton` | [button.md](controls/button.md) | Components → Other → Button |
| `BoGrid` modes (ReadOnly / RowEdit / InlineEdit / NestedView), sort, pagination, selection, filters | [grids.md](controls/grids.md) | Components → Other → Grid |
| Server `QueryMode` + `BoLatestWinsQuery` | [grids.md](controls/grids.md#server-querymode), [query-driven-retrieval.md](controls/query-driven-retrieval.md) | Components → Other → Grid → Server QueryMode |
| Nested View keyword filter (`BoNestedViewKeywordFilter`, `NestedExpandedSeedKeys`) | [grids.md](controls/grids.md#nested-view-keyword-filtering-org-standard) | Components → Other → Grid → Nested keyword |
| Shuffle Card Grid (Add New top + focus, filters, reorder) | [shuffle-card-grid.md](controls/shuffle-card-grid.md) | Components → Other → Grid → Grid Type = Shuffle Card |
| `BoDialog` (Enter / Escape / initial focus / focus restore) | [overlays.md](shell/overlays.md) | Components → Other → Dialog |
| Page Freeze (`IBoPageFreezeService.RunAsync`) + outcome toast | [overlays.md](shell/overlays.md), [page-states.md](patterns/page-states.md) | Components → Other → Page Freeze |
| Toasts | [page-states.md](patterns/page-states.md) | Components → Other → Page Freeze / Dialog; Components Submit (Alert) |
| Import Summary | [import-summary.md](patterns/import-summary.md) | Components → Other → Import Summary |
| Validation Summary | [validation-summary.md](patterns/validation-summary.md) | Components → Other → Validation Summary |
| Error Message Page (`BoAccessDenied`, Access / Support Details) | [error-messages.md](shell/error-messages.md) | Error Message Page |

## Not covered (registered in DEV-002)

No Gallery working example exists yet for the patterns below. Each is an explicit exception in [DEV-002 § Registry](../deviations/DEV-002-example-governance-approved-exceptions.md#registry) until a demo lands (or the owner accepts the exception).

| Pattern | Standard | Exception id |
| --- | --- | --- |
| Section `IsCollapsible` / `Expanded` | [sections.md](layout/sections.md), [expandable-section.md](layout/expandable-section.md) | DEV-002-G01 |
| Standalone `BoExpandableSection` | [expandable-section.md](layout/expandable-section.md) | DEV-002-G01 |
| `BoCard` | [layout.md](layout/layout.md) | DEV-002-G02 |
| `BoDateDisplay` (`Format` / `FormatUtc`) | [i18n.md](foundations/i18n.md) | DEV-002-G03 |
| `BoGrid` `ActionsPlacement`, `ShowDelete`, `ShowSave`, `EnableHorizontalScroll` | [grids.md](controls/grids.md) | DEV-002-G04 |
| Shuffle Card reorder knobs (`AllowReorder`, `ItemReorderable`) | [shuffle-card-grid.md](controls/shuffle-card-grid.md) | DEV-002-G05 |
| Actions area / Save-Discard composition | [actions-area.md](patterns/actions-area.md), [button.md](controls/button.md) | DEV-002-G06 |
| Dirty State (flow + dialog) | [dirty-state.md](patterns/dirty-state.md) | DEV-002-G06 |
| `BoPageHeader` | [layout.md](layout/layout.md) | DEV-002-G07 |
| Page archetypes (List, Detail / Edit, Workspace) as composed pages | [page-archetypes.md](patterns/page-archetypes.md) | DEV-002-G08 |
| Panel Navigation guarded selection (no intent API shipped) | [selection-and-navigation.md](controls/selection-and-navigation.md) | DEV-002-G09 |
| Loading / empty / error state gallery | [page-states.md](patterns/page-states.md) | DEV-002-G10 |

## Maintenance

1. Add a row here when a Gallery demo is added; remove the matching DEV-002 exception in the same change set.
2. The Gallery is monolithic (`Components.razor`, `ComponentsGridDemo.razor`); prefer new patterns as their own demo component under **Other** (like Toggle, Button) so coverage stays addressable.
3. Product pages (EAC) are product reference, never a substitute for a Gallery row ([example-governance.md](example-governance.md)).
