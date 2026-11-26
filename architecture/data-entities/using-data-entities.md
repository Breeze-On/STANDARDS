<!-- Classification: AA; Scope: platform; Domain: Platform; Capability: DataEntities -->
# Using Data Entities (consumer contract)

Owner: Architecture (EAC + SHARED-UI)

Normative contract for **product applications** that consume Data Entity rows. Decision: [ADR-023](../../decisions/ADR-023-consumer-data-entity-lookup.md).

## Consumers

| Consumer | Contract |
| --- | --- |
| Process Framework `DDL` metadata (EAC) | Stores Data Entity **row Code** (never GUID) |
| Product Process apps (e.g. INV) | EAC `System.P_GET_EACDataEntityLookupValues` via SHARED-UI `IBoDataEntityLookupQueries` |

Definitions are Application-scoped (portable via App Config JSON by **Code**). Rows are Application Context (AE) scoped (portable via Excel / local `seed/eac/` Values JSON).

## Lookup contract

| Concern | Rule |
| --- | --- |
| EAC owner | `System.P_GET_EACDataEntityLookupValues` — `@Mode` (`Search` / `Resolve`), `@ApplicationEnabledGUID`, `@DataEntityCode` (Code, not GUID), `@LanguageCode`, `@UserGUID` |
| SHARED-UI owner | `IBoDataEntityLookupQueries.SearchAsync` / `ResolveAsync` |
| **Search** | `TOP 100` typeahead; `SearchText` matches row Code or display Description |
| **Resolve** | Exact Codes for already-saved values (max 100); independent of the Search window; unknown Codes omitted |
| Result | `Code` + `Description` (requested language → `en-CA` → Code; never blank) |
| Sort | Default **Code**. Description is an **explicit** `SortField` override. Resolve is always Code order |
| Approved override | INV Supplier / `suppliers` sorts by localized Description |
| Authorization | Fails closed to an empty set (Global System Administrator or Security Group member of the AE) |

Do not use Search to hydrate saved values; do not use Resolve for open-ended search.

## Persistence

- Product apps persist DE selections as **`*Code`** columns on `{UniqueCode}.Process` — **never** Description, never `DataEntityRowGUID` (GUIDs are environment-local).
- Flat Process field: typed property name = database column name ([database.md](../../docs/database.md) § Process table convention, [naming.md](../../docs/naming.md)).
- Bound control value is the Code ([forms.md](../../docs/ui/controls/forms.md) § Drop-Down List).

## Prohibited

- Querying `System.EACDataEntities*` tables from a product app.
- Reusing `P_GET_EACDataEntitiesRows` (Values grid) or `P_GET_EACDataEntitiesRowsForExcel` for typeahead.
- Authoring per-app DE lookup stored procedures.

## Seed ownership

EAC owns the platform baseline and the importer; the app repo owns its `seed/eac/` payloads (Applications, BE delta, App Config, DE Values, Translations) — [data-portability.md](../../docs/data-portability.md) § Per-application `seed/eac`.

## Related

[data-entities-architecture.md](data-entities-architecture.md) § Consumer lookup · [ae-fact-providers.md](../app-context/ae-fact-providers.md) · [database.md](../../docs/database.md) § Consumer Data Entity lookup
