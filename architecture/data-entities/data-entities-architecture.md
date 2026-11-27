<!-- Classification: AA; Scope: application:eac; Domain: Platform; Capability: DataEntities -->
# Data Entities architecture

Owner: Architecture (EAC)

Technical architecture for the EAC **reference-data** capability (`System` schema).

## ERD

```mermaid
erDiagram
  EACApplications ||--o{ EACDataEntities : ApplicationGUID
  EACDataEntities ||--o{ EACDataEntitiesColumns : DataEntityGUID
  EACApplicationsEnabled ||--o{ EACDataEntitiesRows : ApplicationEnabledGUID
  EACDataEntities ||--o{ EACDataEntitiesRows : DataEntityGUID
  EACDataEntitiesRows ||--o{ EACDataEntitiesRowsTranslations : DataEntityRowGUID
  EACDataEntitiesRows ||--o{ EACDataEntitiesRowsMetadata : DataEntityRowGUID
  EACDataEntitiesColumns ||--o{ EACDataEntitiesRowsMetadata : DataEntityColumnGUID
```

## Relationships

| Child | Parent key | Notes |
| --- | --- | --- |
| `EACDataEntities` | `ApplicationGUID` | Shared definitions for the Application |
| `EACDataEntitiesColumns` | `DataEntityGUID` | Custom columns only (not code/description/sort-order) |
| `EACDataEntitiesRows` | `ApplicationEnabledGUID` + `DataEntityGUID` | Instance rows per Application Context |
| `EACDataEntitiesRowsTranslations` | `DataEntityRowGUID` | Localized Description only |
| `EACDataEntitiesRowsMetadata` | `DataEntityRowGUID` + `DataEntityColumnGUID` | Sparse typed values |

Logical keys are `NVARCHAR(600)` GUIDs (EAC catalog convention). Physical PKs are `INT IDENTITY`. FKs use `ON DELETE NO ACTION`; cleanup is via centralized delete procedures.

## Constraints (summary)

| Table | Unique |
| --- | --- |
| `EACDataEntities` | `DataEntityGUID`; `(ApplicationGUID, Code)` |
| `EACDataEntitiesColumns` | `DataEntityColumnGUID`; `(DataEntityGUID, Code)`; `Type` CHECK |
| `EACDataEntitiesRows` | `DataEntityRowGUID`; `(ApplicationEnabledGUID, DataEntityGUID, Code)` |
| `EACDataEntitiesRowsTranslations` | `DataEntityRowTranslationGUID`; `(DataEntityRowGUID, LanguageCode)` |
| `EACDataEntitiesRowsMetadata` | `(DataEntityRowGUID, DataEntityColumnGUID)` |

Full column inventory: EAC [`docs/db-model.md`](https://github.com/Breeze-On/breezeon-system-admin-eac/blob/main/docs/db-model.md).

## Indexing strategy

| Index | Purpose |
| --- | --- |
| `IX_EACDataEntities_ApplicationGUID_SortOrder` | Navigation list by SortOrder |
| `IX_EACDataEntitiesColumns_DataEntityGUID_SortOrder` | Column catalog |
| `IX_EACDataEntitiesRows_AppEnabled_DataEntity_SortOrder` (include Code, DataEntityRowGUID) | Primary row browse at scale |
| `IX_EACDataEntitiesRows_DataEntityGUID` | Cross-context maintenance / definition delete checks |
| Translation UQ `(DataEntityRowGUID, LanguageCode)` | Translation lookup |
| `IX_EACDataEntitiesRowsMetadata_RowGUID` | Metadata by row set |
| `IX_EACDataEntitiesRowsMetadata_ColumnGUID` | Column lifecycle checks |

## Performance decisions

- Optimize for configurable **reference data**; designed for thousands of rows per entity. ~200k-scale viability is **unproven** (Future Validation). PF DDL pickers cap at 1000 rows.
- Sparse metadata: no row when value is NULL ([standard](data-entities-standard.md)).
- Prefer indexed filters on `(ApplicationEnabledGUID, DataEntityGUID)` over scanning by Application alone for rows.
- Avoid wide SQL pivots; the consumer lookup contract returns Code + Description only (custom columns are not part of it).

## Values workspace retrieval (locked)

EAC Values UI must **not** load entire large catalogs into memory.

| Concern | Design |
| --- | --- |
| Browsing | Server QueryMode — `System.P_GET_EACDataEntitiesRows` pages/sorts/filters; only the current page + its sparse metadata loads |
| Editing | Local Changeset (Added / Modified / Deleted) — do not switch the grid to Client QueryMode |
| Dirty | Changeset is not empty |
| Save | `System.P_POST_EACDataEntitiesRowsSave` accepts Changeset JSON only (not a full-catalog replace) |
| Discard | Clear Changeset + reload current server page |

Settings (columns) remain a small client working copy via `P_GET` / `P_POST_EACDataEntitiesColumnsSave`.

## Excel Tool (Values portability)

Decision: [ADR-018](../../decisions/ADR-018-data-entity-values-excel-portability.md). UX and rules: [standard](data-entities-standard.md#excel-tool-shipped). Workbook contract: [`docs/data-portability.md`](../../docs/data-portability.md) § Data Entity Values Excel.

| Concern | Design |
| --- | --- |
| Schema load | `P_GET_EACDataEntitiesByApplication` + `P_GET_EACDataEntitiesColumnsByApplication` (one batched columns query; no per-entity column N+1) |
| Export read | `System.P_GET_EACDataEntitiesRowsForExcel` — **full load** of all Data Entities for `@ApplicationEnabledGUID` + `@LanguageCode`. Two result sets: rows, then sparse metadata (no per-row correlated JSON). Approved ADR-008 exception; not the Values grid contract |
| Import analysis read | Same SP with optional `@DataEntityGuidsJson` after workbook parse — destination load **scoped to included** sheets only. Compare/changeset build stays in C# (`DataEntityExcelImportAnalyzer`) |
| Import write | No dedicated import procedure. Analysis builds a per-Data-Entity Changeset; apply calls the existing `System.P_POST_EACDataEntitiesRowsSave` path once per Data Entity inside **one** database transaction (any failure rolls back all entities) |
| Library | ClosedXML (EAC `Components/DataEntities/Excel`) |
| Identity | Sheet names = Data Entity Description (UX); Data Entity **Code** is the stable in-memory key after a sheet is resolved. Workbook has Data Entity sheets only (no Instructions sheet) |
| SortOrder | Optional on import: provided → used; blank new row → `max + 1` in Excel order; blank existing row → destination SortOrder kept |
| Analyze diagnostics | Durable **Debug** timings via EAC `DataEntityExcelAnalyzeTiming`, category `BreezeOn.Eac.DataEntities.Excel.Analyze` (`OperationId` + stage ms + `TotalMs`). Opt-in for performance investigations; silent at default Information. See EAC `README_AI.md` and [ADR-018](../../decisions/ADR-018-data-entity-values-excel-portability.md) |
| Performance stance | Keep Analyze → Confirm → Apply in-app. Do not move analysis into SQL unless measured timings prove the architecture itself is the bottleneck at large catalogs |

## Consumer lookup (product apps)

Decision: [ADR-023](../../decisions/ADR-023-consumer-data-entity-lookup.md). Contract: [using-data-entities.md](using-data-entities.md).

`System.P_GET_EACDataEntityLookupValues` — one result set `Code`, `Description` for one Application Context.

| Parameter | Role |
| --- | --- |
| `@Mode` | `Search` or `Resolve` |
| `@ApplicationEnabledGUID`, `@DataEntityCode`, `@LanguageCode`, `@UserGUID` | AE, Data Entity **Code** (not GUID), display language, caller (authorization fails closed → empty) |
| `@SearchText`, `@MaxItems`, `@SortField` | Search only: Code/Description substring; **TOP 100** (clamped 1–100); `Code` (default) or `Description` |
| `@ResolveCodesJson` | Resolve only: JSON string array, first 100 exact Codes |

Separate from the Values grid (`P_GET_EACDataEntitiesRows`) and Excel full-load SP. SHARED-UI consumes it via `IBoDataEntityLookupQueries`.

## Sparse metadata rules

- Absence of a metadata row means NULL.
- Never insert a metadata row with all typed value columns NULL.
- `TEXT` → `ValueText` only; `ValueRichText` is reserved and unused.
- `DECIMAL` → `ValueNumber` (`DECIMAL(28,10)`); column `Decimals` (0–10) drives UI scale and save rounding.
- `DATE` and `DATETIME` → `ValueDateTime` (`DATETIME2`); DATE persists as calendar date at midnight.
- `BOOLEAN` → `ValueBoolean`.
- Exactly one typed column populated per metadata row, matching `EACDataEntitiesColumns.Type`.

## Translation strategy

- Only **row Description** is translated (`EACDataEntitiesRowsTranslations`).
- Data Entity and Column Description are **not** translated.
- One translation row per `(DataEntityRowGUID, LanguageCode)`.
- EAC Values UI and Excel Tool persist/load row Description with authoritative language **`en-CA`** — aligned with [i18n.md](../../docs/ui/foundations/i18n.md) and [ADR-018](../../decisions/ADR-018-data-entity-values-excel-portability.md).

## Ownership split

Definitions @ `ApplicationGUID`; rows @ `ApplicationEnabledGUID`. See [ADR-016](../../decisions/ADR-016-data-entity-ownership.md) and [ADR-006](../../decisions/ADR-006-application-context-ownership.md).

## Definition reorder contract

The EAC UI reorders definitions only through **Edit Data Entities** (`P_POST_EACDataEntitiesSave`, below). The Change Order Quick Action and `DataEntityDataService.ReorderAsync` were removed; the dedicated procedure remains in the schema but is **not called by the UI**.

`System.P_POST_EACDataEntitiesReorder`:

| Parameter | Role |
| --- | --- |
| `@ApplicationGUID` | Target Application |
| `@OrderedGuidsJson` | JSON string array of `DataEntityGUID` in final UI order |
| `@Actor` | Audit actor |

Rules:

- Complete permutation required: JSON count must equal Data Entity count for the Application; every GUID must belong to that Application; duplicates rejected.
- Assigns `SortOrder = OPENJSON key + 1` (top = 1) in one transaction and stamps `LastUpdated*`.
- Returns the updated definition list ordered by new SortOrder.

## Definition bulk save contract

`System.P_POST_EACDataEntitiesSave`:

| Parameter | Role |
| --- | --- |
| `@ApplicationGUID` | Target Application |
| `@EntitiesJson` | Remaining definitions in visual order: `{ dataEntityGuid, code, description }` |
| `@DeletedGuidsJson` | Staged `DataEntityGUID` deletes |
| `@Actor` | Audit actor |

Rules:

- Updates are **GUID-keyed** (`DataEntityGUID` is immutable FK identity). `Code` is an editable business key; no child-table Code cascade (columns/rows already reference GUID).
- Remaining rows + deletes must account for every definition on the Application exactly once.
- SortOrder rewritten as `OPENJSON key + 1` for remaining rows.
- Code uniqueness and kebab-case enforced; Code swaps use a temporary unique Code first.
- Delete blocked while any `EACDataEntitiesRows` exist for that GUID; otherwise columns (and their metadata) cascade then the definition is removed.
- Returns the updated definition list ordered by new SortOrder.

## Delete chains

- `P_POST_EACDataEntitiesSave` (staged definition delete): when no rows, column metadata → columns → Data Entity.
- `P_POST_EACApplicationsEnabledDelete`: Metadata → Translations → Rows for the context, then enablement.
- `P_POST_EACApplicationDelete`: after enablements, Columns → DataEntities for the Application.
