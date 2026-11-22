<!-- Classification: AA; Scope: platform; Domain: UI; Capability: Patterns -->
# DEV-002 — Example Governance approved exceptions

| Field | Value |
| --- | --- |
| **Id** | DEV-002 |
| **Title** | Example Governance approved exceptions |
| **Standard cited** | [`docs/ui/example-governance.md`](../ui/example-governance.md) |
| **Scope** | platform / UI |
| **Approved exception** | Example Governance allows an **approved exception** when a normative UI standard + AI guidance cannot yet be paired with a Gallery working example. Such exceptions must be recorded as individual deviation entries (or rows maintained under this registry) rather than only in chat or plans. |
| **Rationale** | Preserves the Example Governance gate while allowing time-boxed or scoped gaps without weakening the standard. |
| **Expiry / review** | Per-exception; review when Gallery coverage lands |
| **Owner area** | UI |
| **Related** | [`docs/ui/example-governance.md`](../ui/example-governance.md) · [`docs/ui/gallery-index.md`](../ui/gallery-index.md) |

## Coverage

Patterns that **have** Gallery coverage are listed (with paths) in [`docs/ui/gallery-index.md`](../ui/gallery-index.md) § Covered patterns. This registry lists only the **gaps**.

## Registry

Each row is an explicit, time-boxed exception: the standard exists and is normative, but no Gallery working example exists yet. **Status** is *Active — demo scope pending owner decision* until the owner confirms, per gap, **demo** vs **accepted exception**. Remove a row in the same change set that adds the Gallery demo and its [`gallery-index.md`](../ui/gallery-index.md) row.

| Id | Pattern without a Gallery example | Standard | Interim copy source | Review / expiry | Status |
| --- | --- | --- | --- | --- | --- |
| DEV-002-G01 | Section `IsCollapsible` / `Expanded`; standalone `BoExpandableSection` | [sections.md](../ui/layout/sections.md), [expandable-section.md](../ui/layout/expandable-section.md) | Error Message Page Access / Support Details (library-composed); EAC Application Selection section | Next Gallery change, or app #2 | Active — demo scope pending owner decision |
| DEV-002-G02 | `BoCard` | [layout.md](../ui/layout/layout.md) | Shell cards (`BoShellCard`) in every Gallery page | Next Gallery change | Active — demo scope pending owner decision |
| DEV-002-G03 | `BoDateDisplay` (`Format`, `FormatUtc`) | [i18n.md](../ui/foundations/i18n.md) | `BoGrid` pager text / EAC grids that render UTC instants | Next Gallery change | Active — demo scope pending owner decision |
| DEV-002-G04 | `BoGrid` `ActionsPlacement`, `ShowDelete`, `ShowSave`, `EnableHorizontalScroll` | [grids.md](../ui/controls/grids.md) | [public-component-api.md § BoGrid](https://github.com/Breeze-On/SYSTEM-SHARED-UI/blob/main/docs/public-component-api.md#bogrid); EAC grids (`ShowDelete=false` Variables values) | Next Grid demo change | Active — demo scope pending owner decision |
| DEV-002-G05 | Shuffle Card reorder knobs `AllowReorder`, `ItemReorderable` | [shuffle-card-grid.md](../ui/controls/shuffle-card-grid.md) | Gallery Shuffle Card demo (default reorder) + public API table | Next Grid demo change | Active — demo scope pending owner decision |
| DEV-002-G06 | Actions area + Save / Discard composition; Dirty State flow and dialog | [actions-area.md](../ui/patterns/actions-area.md), [button.md](../ui/controls/button.md), [dirty-state.md](../ui/patterns/dirty-state.md) | **EAC reference** (`EacSaveDiscardActions`, `EacDirtyStateGuard`); promotion = FV-001 at app #2 | App #2 | Active — EAC reference only |
| DEV-002-G07 | `BoPageHeader` | [layout.md](../ui/layout/layout.md) | `BoAppHeader` titles (shell standard) | Next Gallery change | Active — demo scope pending owner decision |
| DEV-002-G08 | Composed List / Detail-Edit / Workspace page archetypes | [page-archetypes.md](../ui/patterns/page-archetypes.md) | Components → Other → Grid; Components field tabs; EAC pages | Next Gallery change | Active — demo scope pending owner decision |
| DEV-002-G09 | Panel Navigation guarded selection (intent API not shipped) | [selection-and-navigation.md](../ui/controls/selection-and-navigation.md) | `BoTabs` `TabRequested` demo (Other → Button) shows the intent model | When an intent callback ships (FV-008) | Active — blocked on API |
| DEV-002-G10 | Loading / empty / error page-state showcase | [page-states.md](../ui/patterns/page-states.md) | Page Freeze demo; Grid empty body; Error Message Page | Next Gallery change | Active — demo scope pending owner decision |
