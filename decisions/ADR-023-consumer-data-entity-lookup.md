<!-- Classification: DEC; Scope: platform; Domain: Platform; Capability: DataEntities -->
# ADR-023 — Consumer Data Entity Lookup

## Status

Accepted

## Context

Product applications persist Data Entity (DE) selections on their own `{UniqueCode}.Process` rows and need bounded typeahead plus hydration of already-saved values. The only previously shipped DE consumer was EAC Process Framework `DDL` metadata. EAC's paged Values procedure (`P_GET_EACDataEntitiesRows`) is the Values-grid contract, not a typeahead contract, and product apps must not couple to EAC `System.EACDataEntities*` table shapes.

## Decision

1. EAC owns `System.P_GET_EACDataEntityLookupValues` — a single consumer read contract with two modes:
   - **Search** — `TOP 100` (`@MaxItems` clamped 1–100) by Application Context (AE, `@ApplicationEnabledGUID`) + Data Entity **Code** + language + `@SearchText` (substring on row Code or display Description).
   - **Resolve** — exact row Codes (`@ResolveCodesJson`, first 100) for already-selected values; independent of the Search window.
2. SHARED-UI owns `IBoDataEntityLookupQueries` (`SearchAsync` / `ResolveAsync`) as the only product-facing helper over that procedure.
3. **Search and Resolve stay separate.** Typeahead must not be used to hydrate saved values (a saved Code can fall outside the Top-N window); Resolve must not be used for open-ended search.
4. **Sort:** default `SortField = Code`. Description sort (localized display text, then Code as tie-breaker) is an **explicit caller override**. Resolve always orders by Code.
5. **Approved exception:** the INV Supplier / `suppliers` lookup overrides to Description because users recognize suppliers by name. Any other Description override requires its own justification in the product's docs.
6. Result shape is `Code` + `Description` (requested language → `en-CA` → Code; never blank) + **`MetadataJson`** (`[{ "code", "value" }]` by column Code). Controls bind **Code**.
7. **Persist Code only.** Product apps store DE selections as `*Code` columns on `{UniqueCode}.Process` — never Description, never `DataEntityRowGUID`. Do not snapshot Descriptions; resolve current EAC values at read time.
8. Products must **not** query `System.EACDataEntities*` tables directly, and must **not** reuse `P_GET_EACDataEntitiesRows` (or the Excel full-load SP) for typeahead or Process View hydrate.
9. Authorization fails closed inside the procedure (empty result, no `RAISERROR`): Global System Administrator or any Security Group member of the Application Context. This is not a replacement for `IBoAuthorizationService` page authorization.
10. **Seed ownership:** EAC owns the platform baseline and the importer; each application repo owns its `seed/eac/` payloads (Applications, Business Entity delta, Application Configuration, Data Entity Values, Translations) — [data-portability.md](../docs/data-portability.md) § Per-application `seed/eac`.
11. **Batch resolve:** EAC owns `System.P_GET_EACDataEntityValuesBatch` for multi-entity multi-code hydrate (Process View). SHARED-UI exposes `ResolveBatchAsync`. Caps ≤20 entities / ≤100 codes. No consumer-owned batch contracts.

## Consequences

- Product dropdowns on Process forms integrate through one helper; no per-app lookup SPs and no EAC table coupling.
- `System.P_GET_EACDataEntityLookupValues` is a documented justified lookup procedure — **not** the start of a `P_GET_*ComponentValues` family ([database.md](../docs/database.md) § Consumer Data Entity lookup).
- Renaming a Code in EAC affects saved `*Code` values the same way it affects PF DDL values (EAC UI warns; no hard block) — [data-entities-standard.md](../architecture/data-entities/data-entities-standard.md).
- Changes to the procedure must satisfy [database.md](../docs/database.md) § **EAC Framework Synchronization** in the same change set.

## Related

- [ADR-016](ADR-016-data-entity-ownership.md)
- [ADR-018](ADR-018-data-entity-values-excel-portability.md)
- [ADR-022](ADR-022-consumer-application-context-bootstrap.md)
- [using-data-entities.md](../architecture/data-entities/using-data-entities.md)
- [ae-fact-providers.md](../architecture/app-context/ae-fact-providers.md)
- [forms.md](../docs/ui/controls/forms.md) § Drop-Down List
