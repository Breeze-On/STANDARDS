# Using Data Entities

Owner: Architecture

Developer consumption guide for applications that **read** Data Entity data owned by EAC.

Before inventing a custom lookup table, confirm the data qualifies: [What Qualifies as a Data Entity?](data-entities-standard.md#what-qualifies-as-a-data-entity).

## Expectations

| Allowed | Not allowed |
| --- | --- |
| Read / filter / search / display | Create or modify Data Entities or columns |
| Use values in business processes | Insert / update / delete rows, translations, or metadata directly |
| Resolve by `DataEntityGUID` / `Code` + Application Context | Alter Data Entity schema |

All writes belong to EAC.

## Retrieval patterns

### Definitions (Application-scoped)

List Data Entities for an Application ordered by `SortOrder`:

- Contract today: `System.P_GET_EACDataEntitiesByApplication` (`@ApplicationGUID`)
- Use for admin navigation and schema discovery

### Rows (Application Context–scoped)

Recommended filter:

```text
WHERE ApplicationEnabledGUID = @ApplicationEnabledGUID
  AND DataEntityGUID = @DataEntityGUID
ORDER BY SortOrder
```

Use the covering index on `(ApplicationEnabledGUID, DataEntityGUID, SortOrder)`. For large catalogs (e.g. Cities), page or Top-N search rather than loading the full set into UI memory unless an approved full-load exception exists ([ADR-008](../../decisions/ADR-008-query-driven-data-retrieval.md)).

### Translation retrieval

```text
LEFT JOIN System.EACDataEntitiesRowsTranslations t
  ON t.DataEntityRowGUID = r.DataEntityRowGUID
 AND t.LanguageCode = @LanguageCode
```

Fall back to a default language or row `Code` when no translation exists (product rule; document per app if different).

### Metadata retrieval

Batch by row set:

```text
WHERE DataEntityRowGUID IN (…)
```

Join to `EACDataEntitiesColumns` for `Code` / `Type`. Map typed columns:

| Column.Type | Value column |
| --- | --- |
| TEXT | ValueText |
| DECIMAL | ValueNumber |
| DATE | ValueDateTime (date @ midnight) |
| DATETIME | ValueDateTime |
| BOOLEAN | ValueBoolean |

Missing metadata row ⇒ NULL. Do not expect placeholder NULL rows.

## Recommended query patterns

1. Resolve Application Context (`ApplicationEnabledGUID`) for the user’s operational BE + Application.
2. Resolve Data Entity by Application + `Code` (e.g. `regions`).
3. Load rows for that context + entity (paged/search as needed).
4. Attach translations for the UI locale.
5. Optionally attach metadata for displayed custom columns only.

Prefer EAC-owned stored procedures or shared read contracts as they are introduced; do not duplicate write paths in consumer apps.

## Usage examples

- Invoice app: Cost Centers and WBS as Data Entities; invoice headers remain transactional tables that **reference** row codes/GUIDs.
- Timesheet app: Departments as a Data Entity; timesheet entries remain transactional.

## Future app expectations

- Prefer Data Entities for administrator-maintained lookups.
- Do not create `InvoiceRegions`-style tables when a Data Entity already exists or should exist in EAC.
- Treat `DataEntityRowGUID` as the stable reference for integrations; treat `Code` as the human/business key (editable).
