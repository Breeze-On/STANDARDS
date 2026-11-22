<!-- Classification: AA; Scope: platform; Domain: UI; Capability: Controls -->
# UI — Parameter reference (authority model)

Owner: UI

Defines where the **complete, authoritative parameter model** for `Bo*` components lives and how it is kept correct. Related: [overview.md § Authority split](../overview.md#authority-split-ux-vs-api), [normative-tiers.md](../foundations/normative-tiers.md), [example-governance.md](../example-governance.md).

Current reality only.

## Authority model (Tier 1 — LOCKED)

| Concern | Authority |
| --- | --- |
| Complete public API: every `[Parameter]` (name, type, default), events, enums, services, public methods | SYSTEM-SHARED-UI [`docs/public-component-api.md`](https://github.com/Breeze-On/SYSTEM-SHARED-UI/blob/main/docs/public-component-api.md) — **API only** |
| UX, behavior, visuals, decision matrices, accessibility | STANDARDS `docs/ui/` (this tree) |

**The parameter model is generated or CI-validated against SHARED-UI source. Agents must not inspect Razor / C# source to learn the public API.** If a parameter is missing from `public-component-api.md`, that is a documentation defect — report or fix it; do not work around it by reading `.razor` files.

### Maintenance duty (same change set)

Any change to a public `[Parameter]` (add, remove, rename, retype, change default) **must** update the matching table in `public-component-api.md` in the same change set, together with the STANDARDS behavior text if semantics change.

### Current status

| Item | Status |
| --- | --- |
| `public-component-api.md` parameter tables | Complete for every component listed in its [Parameter reference](https://github.com/Breeze-On/SYSTEM-SHARED-UI/blob/main/docs/public-component-api.md#parameter-reference); extracted from `[Parameter]` members of `BreezeOn.UI` and spot-verified by per-component counts |
| Automated regeneration / CI diff against source | **Future Validation (FV-007)** — not yet automated; the same-change-set duty above is the control until it is |
| Hand-written parameter tables inside STANDARDS control docs | **Informative only** — see below |

## STANDARDS control docs defer to the API doc

Parameter tables that appear in STANDARDS control docs (`grids.md`, `shuffle-card-grid.md`, `forms.md`, `toggle.md`, `panels.md`, `button.md`) explain **why and how** a parameter is used. They may be incomplete. For completeness, defaults, types, and events, **defer to `public-component-api.md`**. When the two disagree on an API fact, `public-component-api.md` wins and the STANDARDS table is corrected ([normative-tiers.md § Precedence](../foundations/normative-tiers.md#precedence)).

## Component to API section map

All links target [`public-component-api.md`](https://github.com/Breeze-On/SYSTEM-SHARED-UI/blob/main/docs/public-component-api.md) headings. UX SSOT is the STANDARDS document in the right column.

| Component | API section | UX SSOT |
| --- | --- | --- |
| `BoGrid` / `BoGridColumn` | [BoGrid](https://github.com/Breeze-On/SYSTEM-SHARED-UI/blob/main/docs/public-component-api.md#bogrid) · [BoGridColumn](https://github.com/Breeze-On/SYSTEM-SHARED-UI/blob/main/docs/public-component-api.md#bogridcolumn) | [grids.md](grids.md) |
| `BoShuffleCardGrid` / `BoShuffleCardGridColumn` | [BoShuffleCardGrid](https://github.com/Breeze-On/SYSTEM-SHARED-UI/blob/main/docs/public-component-api.md#boshufflecardgrid) · [BoShuffleCardGridColumn](https://github.com/Breeze-On/SYSTEM-SHARED-UI/blob/main/docs/public-component-api.md#boshufflecardgridcolumn) | [shuffle-card-grid.md](shuffle-card-grid.md) |
| `BoButton` / `BoIconButton` | [BoButton](https://github.com/Breeze-On/SYSTEM-SHARED-UI/blob/main/docs/public-component-api.md#bobutton) · [BoIconButton](https://github.com/Breeze-On/SYSTEM-SHARED-UI/blob/main/docs/public-component-api.md#boiconbutton) | [button.md](button.md) |
| `BoToggle` | [BoToggle](https://github.com/Breeze-On/SYSTEM-SHARED-UI/blob/main/docs/public-component-api.md#botoggle) | [toggle.md](toggle.md) · [selection-and-navigation.md](selection-and-navigation.md) |
| `BoTabs` / `BoTab` / `BoTabPanels` / `BoTabPanel` | [BoTabs](https://github.com/Breeze-On/SYSTEM-SHARED-UI/blob/main/docs/public-component-api.md#botabs) · [BoTab](https://github.com/Breeze-On/SYSTEM-SHARED-UI/blob/main/docs/public-component-api.md#botab) · [BoTabPanels](https://github.com/Breeze-On/SYSTEM-SHARED-UI/blob/main/docs/public-component-api.md#botabpanels) · [BoTabPanel](https://github.com/Breeze-On/SYSTEM-SHARED-UI/blob/main/docs/public-component-api.md#botabpanel) | [shell.md § Header tabs](../shell/shell.md#header-tabs-optional-page-sections) · [selection-and-navigation.md](selection-and-navigation.md) |
| `BoPanelNavigation` / `BoKeepAlivePanels` / `BoKeepAlivePanel` / `BoPanelHost` / `BoPanel` | [BoPanelNavigation](https://github.com/Breeze-On/SYSTEM-SHARED-UI/blob/main/docs/public-component-api.md#bopanelnavigation) · [BoKeepAlivePanels](https://github.com/Breeze-On/SYSTEM-SHARED-UI/blob/main/docs/public-component-api.md#bokeepalivepanels) · [BoPanelHost](https://github.com/Breeze-On/SYSTEM-SHARED-UI/blob/main/docs/public-component-api.md#bopanelhost) · [BoPanel](https://github.com/Breeze-On/SYSTEM-SHARED-UI/blob/main/docs/public-component-api.md#bopanel) | [panels.md](../layout/panels.md) · [selection-and-navigation.md](selection-and-navigation.md) |
| `BoTextField`, `BoDropDownList`, `BoPeoplePicker`, `BoCheckbox`, `BoDateField`, `BoNumberField`, `BoFieldReadOnly`, `BoEmptyField` | [Form fields](https://github.com/Breeze-On/SYSTEM-SHARED-UI/blob/main/docs/public-component-api.md#form-fields) | [forms.md](forms.md) |
| `BoSectionMain` / `BoSectionSub` / `BoExpandableSection` / `BoRow` / `BoCard` / `BoStack` / `BoPageHeader` | [Layout and sections](https://github.com/Breeze-On/SYSTEM-SHARED-UI/blob/main/docs/public-component-api.md#layout-and-sections) | [sections.md](../layout/sections.md) · [layout.md](../layout/layout.md) · [expandable-section.md](../layout/expandable-section.md) |
| `BoAppShell`, `BoAppHeader`, `BoNavPane`, `BoNavLink`, `BoNavHub`, `BoNavCardStyleHyperlink` | [Shell and navigation](https://github.com/Breeze-On/SYSTEM-SHARED-UI/blob/main/docs/public-component-api.md#shell-and-navigation) | [shell.md](../shell/shell.md) · [navigation.md](../shell/navigation.md) |
| `BoDialog`, `BoImportSummaryDialog`, `BoValidationSummary`, `BoIcon`, `BoAccessDenied` | [Overlays, validation, and other](https://github.com/Breeze-On/SYSTEM-SHARED-UI/blob/main/docs/public-component-api.md#overlays-validation-and-other) | [overlays.md](../shell/overlays.md) · [import-summary.md](../patterns/import-summary.md) · [validation-summary.md](../patterns/validation-summary.md) · [icons.md](../foundations/icons.md) · [error-messages.md](../shell/error-messages.md) |
| Services (`IBoToastService`, `IBoPageFreezeService`, `IBoLocaleService`, …), enums, query contracts | [Services and non-visual API](https://github.com/Breeze-On/SYSTEM-SHARED-UI/blob/main/docs/public-component-api.md#services-and-non-visual-api) · [Enumerations](https://github.com/Breeze-On/SYSTEM-SHARED-UI/blob/main/docs/public-component-api.md#enumerations) | [overlays.md](../shell/overlays.md) · [i18n.md](../foundations/i18n.md) · [query-driven-retrieval.md](query-driven-retrieval.md) |

## For agents

1. Need a parameter, event, enum, or default? Open `public-component-api.md` (table above). Do not open Razor.
2. Need to know whether to use it, where, or how it must look/behave? Open the UX SSOT.
3. Parameter missing or table disagrees with your compiler? Report the documentation defect; the code is the tiebreaker for the **fix**, never a substitute for the **doc** ([normative-tiers.md](../foundations/normative-tiers.md)).
