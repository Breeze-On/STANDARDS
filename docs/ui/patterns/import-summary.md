<!-- Classification: AA; Scope: platform; Domain: UI; Capability: Patterns -->
# UI — Import Summary

Owner: UI / Architecture

Standard review dialog for import and synchronize workflows. Implementation: `BoImportSummaryDialog` in [breezeon-system-shared-ui](https://github.com/Breeze-On/breezeon-system-shared-ui). Related: [overlays.md](../shell/overlays.md), [grids.md](../controls/grids.md), [data-portability.md](../../data-portability.md).

## Principle (locked)

Import Summary dialogs are **review surfaces**.

| Does | Does not |
| --- | --- |
| Present planned changes, warnings, and errors | Apply modifications during analysis |
| Require explicit user confirmation before execute | Auto-synchronize on upload or analyze |
| Stay presentational in SHARED-UI | Host planners, analyzers, mappers, or appliers |

Nothing is written until the user confirms (Import / Synchronize). Analysis and plan phases are read-only.

### Sibling: Validation Summary (live editors)

Import Summary is **pre-apply** only. Live editable grids/Shuffle after Save/Commit use [Validation Summary](validation-summary.md) (`BoValidationSummary`) — do **not** dual-stack both on the same analyze/confirm path, and do **not** overload `BoImportSummaryDialog` for live editors. Severity concepts align (Error blocks; Warning does not); controls stay separate ([ADR-021](../../../decisions/ADR-021-validation-summary-experience.md)).

## Architecture boundary

- **SHARED-UI:** `BoImportSummaryDialog`, `BoImportChangeSummaryRow`, `BoImportIssueRow`, `BoImportIssueSeverity` — presentation only.
- **Product hosts (e.g. EAC):** analyzers, planners, mappers, appliers, localization of title/primary verb, and domain-specific `ChangesSummaryContent` when needed.
- Do **not** add generic import engines, planners, workflows, or synchronization abstractions to SHARED-UI.

Gallery: Components Library → Other → Import Summary.

## Required sections

1. **Changes Summary** — `BoSectionMain` + read-only client `BoGrid` (or host-supplied content).
2. **Errors and Warnings** — `BoSectionMain` + read-only client `BoGrid` (Type · Message).

Dialog size: `BoDialogSize.Large`. Close control in the first section `HeaderActions` (`BoDialogCloseButton`).

## Standard Changes Summary grid

Default columns (standard imports):

| Column | Notes |
| --- | --- |
| Item Type | Artifact kind (e.g. Data Entity, Column, Security Group) |
| Item Code | Portable code / path |
| New | Count |
| Updated | Count |
| Deleted | Count |

Callers omit rows where New, Updated, and Deleted are all zero.

### `ChangesSummaryContent` (required API capability)

`BoImportSummaryDialog` **must** support `ChangesSummaryContent`:

- Standard imports omit it and use the default Item Type / Item Code / New / Updated / Deleted grid.
- Specialized workflows supply custom columns without forking a second summary dialog. Examples: Data Entities Excel (Data Entity · Included? · New · Updated · Deleted); Application Configuration synchronize (Entity · Item · Type · New · Updated · Deleted).
- Default Item Type / Item Code columns are **not** enforced for every host. Aggregate **measures** (New / Updated / Deleted) remain the shared pattern; column sets are case-specific via `ChangesSummaryContent`.

When using custom content, set `HasChanges` explicitly if the default `ChangeRows` gate does not match domain semantics.

## Validation severity

Issues appear in the single Errors and Warnings grid.

| Severity | Display | Blocks confirmation |
| --- | --- | --- |
| **Error** | Issues grid | Yes |
| **Warning** | Issues grid | No |
| **Information** (future) | May appear in Issues grid | Never |

Confirm is enabled only when there are **no Errors** and **at least one planned change**. Warnings and Information never disable Synchronize/Import.

File-level failures that prevent analysis (bad extension, oversize, unreadable schema) may stay as toasts and never open the summary — same as Excel needing a readable workbook.

## Footer / Synchronize action

- Stealth Cancel + Stealth primary (Import / Synchronize) via `FooterContent` — **not** `BoDialog.PrimaryAction` (standard Primary colors).
- Corner radius: inherits `.bo-button` / `--bo-button-radius` (same hard standard as all buttons; Save/Discard color tokens only).
- Primary disabled when busy, when Errors exist, or when there are no changes.

## Summary data shape (host → shell)

| Type | Fields |
| --- | --- |
| `BoImportChangeSummaryRow` | `ItemType`, `ItemCode`, `NewCount`, `UpdatedCount`, `DeletedCount` |
| `BoImportIssueRow` | `Severity` (`Error` / `Warning` / `Information`), `Message` |

Hosts map domain plans into these rows. The shell does not interpret product envelopes.

## Extensibility

| Adopt | How |
| --- | --- |
| New standard import | Map plan → `ChangeRows` + `Issues`; set Title / PrimaryActionLabel; use default grid |
| Specialized columns | Supply `ChangesSummaryContent`; set `HasChanges` as needed |
| Future Information tips | Emit `BoImportIssueSeverity.Information` — never blocks |

Future candidates (toast-only today): Applications JSON, Business Entities / Types JSON — adopt this pattern when product wants pre-apply confirmation.

## Current consumers (EAC)

| Workflow | Changes Summary | Primary verb |
| --- | --- | --- |
| Application Configuration synchronize | `ChangesSummaryContent` (Entity · Item · Type · New · Updated · Deleted); aggregated business units — not one row per portable code. Model: [application-configuration-deployment.md](../../../architecture/app-configuration/application-configuration-deployment.md#import-analysis-summary) | Synchronize |
| Data Entities Excel import | `ChangesSummaryContent` (Included? / N/A) | Import |
| Security Group Members import | `ChangesSummaryContent` (domain member columns) | Import |
| Translations Excel import | `ChangesSummaryContent` (Entity · Type · New · Updated) | Import |

## Documentation duty

When shipping a new import that needs pre-apply review, use `BoImportSummaryDialog` — do not invent a parallel summary UX.
