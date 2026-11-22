<!-- Classification: DEC; Scope: platform; Domain: Engineering; Capability: AdrProcess -->
# ADR-018: Data Entity Values Excel portability

Status: Accepted

## Context

Administrators need to move Data Entity **Values** (rows, row Description, custom-column values) between environments and perform bulk maintenance (large edits, mass add) outside the Values grid.

Application Configuration JSON ([ADR-017](ADR-017-application-configuration-deployment.md)) covers Data Entity **definitions and columns only**. Rows, translations, and metadata are Application Context data ([ADR-016](ADR-016-data-entity-ownership.md), [ADR-006](ADR-006-application-context-ownership.md)) and are excluded from that contract. The Values grid uses server paging and a local Changeset ([ADR-008](ADR-008-query-driven-data-retrieval.md)); it is not a bulk-transfer surface.

GUIDs are environment-local; portable identity for values must be business `Code`.

## Decision

### Format and library

The portable artifact is an official **`.xlsx`** workbook generated and read with **ClosedXML**. Export and import share **one schema** (sheets, headers, column order) built from the Application's Data Entities and Columns, so a file exported from an environment round-trips into any environment with the same definitions. The workbook contains **Data Entity sheets only** — there is no Instructions worksheet; the first sheet is the first Data Entity.

### Workbook identity

| Concern | Rule |
| --- | --- |
| Sheet name | **Data Entity Description** (not Code) — one sheet per Data Entity, in Data Entity order |
| Internal service key | **Data Entity Code** (drives the Excel table name; never shown as the sheet name). Sheet names are the user-facing (UX) identity; once a sheet is resolved to a Data Entity, the **Code** is the stable in-memory key for analysis and apply |
| Row match | **Row `Code`** within the Data Entity (case-insensitive) |
| GUIDs | **Never** in the workbook; import resolves Codes to target GUIDs |
| Columns | `Code`, `Description`, one column per Data Entity Column (Settings order, header = column Description, or Code when empty), `SortOrder` (value optional on import — see [SortOrder on import](#sortorder-on-import)) |

### Scope: one Application Context, one language

Export and import operate on the selected **Application Context** (`ApplicationEnabledGUID`). Row Description uses the authoritative metadata language **`en-CA`** (same rule as the Values grid). Other languages are neither exported nor changed by import.

### Analyze, then confirm

Import never writes on upload. The file is parsed and compared with the destination (analyze), then the administrator reviews a summary (included / excluded Data Entities, new / updated / deleted counts, warnings, errors) and confirms before anything is saved.

### Import modes

| Mode | Behavior |
| --- | --- |
| **Add Missing & Update Existing** | Match by Code; add missing rows, update existing rows; never deletes |
| **Overwrite All Values** | Same, and **deletes** destination rows absent from the sheet — only for Data Entities that have a sheet in the file |

Rows identical to the destination are not counted as updates. Blank cells in custom columns clear the stored value (sparse metadata absence = NULL).

### SortOrder on import

The `SortOrder` column must exist (header contract) but its value is **optional**:

- Value provided → used.
- Blank on a **new** row → auto-assigned `max + 1` in Excel row order (per Data Entity).
- Blank on an **existing** row → the destination `SortOrder` is kept.

### Sheet inclusion

- A Data Entity **with** a sheet is **included**.
- A Data Entity **without** a sheet is **excluded** and left untouched in every mode (including Overwrite).
- A sheet that matches no Data Entity is ignored with a **warning**.
- An import where no sheet matches any Data Entity is an error.

### All-or-nothing

Validation covers workbook structure (exactly one table per sheet starting at A1, expected headers in order, no data outside the table) and every row (Code / Description required, SortOrder optional but a whole number when provided, lengths, types, duplicate Codes). **Any** error blocks the whole import. Apply runs every Data Entity Changeset through the existing Values save path in **one database transaction**; any failure rolls back everything.

### UI

Quick Action **Excel Tool** (`DocumentTable` icon) opens a `BoDialogSize.Default` dialog with Import Mode dropdown, Import, and Export only (no helper labels under the mode). The **Import Mode** dropdown starts empty and **Import** stays disabled until a mode is selected. Confirmation uses the shared **Import Summary** shell (`BoImportSummaryDialog`) with Excel-specific `ChangesSummaryContent` (Data Entity · Included? · New · Updated · Deleted; Deleted shows bold N/A for Add/Update mode and excluded entities) and the standard Errors and Warnings grid (Type · Message). The primary button is **Import** (Save styling); **Cancel** uses Discard styling and closes both the analysis and Excel Tool dialogs. When analysis finds no changes, the UI shows "No changes detected" and **Import** is disabled. After a successful import all Excel dialogs close, Data Entities and Values refresh, and the first Data Entity is selected. Pattern: [import-summary.md](../docs/ui/patterns/import-summary.md).

Authorization follows Values manage rules: Global System Administrator or Application object administrator; enforced server-side per Data Entity.

### Excel-safety rules for Data Entity Description

Because the Description is the sheet name, Excel Tool requires every Data Entity Description in the Application to be:

- non-empty, **≤ 31** characters;
- **unique** (case-insensitive);
- free of `\ / ? * [ ]` `:` and not starting or ending with an apostrophe.

If any Data Entity violates these rules, export and import are blocked with an explanatory error until the Description is corrected (Edit Data Entities). Column headers must also be non-empty, unique per sheet (including Code / Description / SortOrder), and ≤ 255 characters.

### Retrieval exception to ADR-008

Excel export and import analysis remain an approved **full-load exception** to [ADR-008](ADR-008-query-driven-data-retrieval.md) paging via `System.P_GET_EACDataEntitiesRowsForExcel` (portability only; not the Values grid contract).

- **Export** loads every Data Entity in the Application Context.
- **Import analysis** parses the workbook first, then loads destination rows **only for included** Data Entities (matched sheets), via optional `@DataEntityGuidsJson`.
- The procedure returns **two result sets** (rows + sparse metadata) instead of per-row correlated `MetadataJson`.
- Schema load uses `System.P_GET_EACDataEntitiesColumnsByApplication` (one batched columns query) rather than per-entity column round trips.
- Analyze stages are timed as **durable Debug diagnostics** (logger category `BreezeOn.Eac.DataEntities.Excel.Analyze`; fields `OperationId`, `AuthorizationMs`, `SchemaLoadingMs`, `WorkbookParsingMs`, `DestinationLoadingMs`, `AnalysisMs`, `SummaryRenderingMs`, `TotalMs`). Opt-in — not emitted at default Information. Analysis remains in application memory (Analyze → Confirm → Apply); SQL-first analysis is not the architecture. Details: EAC [`README_AI.md`](https://github.com/Breeze-On/SYSTEM-ADMIN-EAC/blob/main/README_AI.md) § Excel Import Analyze — performance diagnostics.

## Consequences

- Values portability is **separate** from App Configuration JSON. Operators synchronize **definitions first** (Application Configuration), then move Values with Excel; files whose headers do not match the target's columns fail validation.
- Description renames change the sheet name; a renamed Data Entity in a file is treated as a missing sheet (excluded) plus an unknown sheet (warning).
- Large workbooks are bounded by `DataEntityExcelImport:MaxFileSizeMb` (default **25**); files are processed in memory only.
- Interactive Analyze targets **hundreds–thousands** of values after schema/destination optimizations; ~200k-row catalogs remain a Values-grid concern and are not a reason to move analysis into T-SQL without measured proof.
- Documentation SSOT: [`docs/data-portability.md`](../docs/data-portability.md) § Data Entity Values Excel; UX and rules: [`architecture/data-entities/data-entities-standard.md`](../architecture/data-entities/data-entities-standard.md).

## Related

- [ADR-006](ADR-006-application-context-ownership.md)
- [ADR-008](ADR-008-query-driven-data-retrieval.md)
- [ADR-016](ADR-016-data-entity-ownership.md)
- [ADR-017](ADR-017-application-configuration-deployment.md)
- [docs/data-portability.md](../docs/data-portability.md)
- [architecture/data-entities/README.md](../architecture/data-entities/README.md)
