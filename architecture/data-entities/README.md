<!-- Classification: AA; Scope: application:eac; Domain: Platform; Capability: DataEntities -->
# Architecture — Data Entities

Owner: Architecture (EAC)

**Data Entities are an EAC business capability** for **reference data** — not a generic master-data platform and not a general-purpose query API. Product Process apps consume rows only through the EAC lookup SP + SHARED-UI helper ([using-data-entities.md](using-data-entities.md)). Implementation lives in breezeon-system-admin-eac (SHARED-UI owns the consumer helper).

## Index

| Document | Covers |
| --- | --- |
| [Data Entities standard](data-entities-standard.md) | Business meaning, boundary, flat limits, ownership, technical rules |
| [Authoring guide](authoring-guide.md) | Administrator sequence |
| [AI authoring contract](ai-authoring-contract.md) | Field contract + hazards |
| [Worked examples](worked-examples.md) | Cost Centers, Request Types→DDL, Regions |
| [Data Entities architecture](data-entities-architecture.md) | ERD, constraints, indexing, Excel retrieval |
| [Using Data Entities](using-data-entities.md) | **Normative** consumer contract: Search / Resolve / **batch resolve**, sort default, Code persistence |

Decisions: [ADR-016](../../decisions/ADR-016-data-entity-ownership.md); [ADR-018](../../decisions/ADR-018-data-entity-values-excel-portability.md); [ADR-023](../../decisions/ADR-023-consumer-data-entity-lookup.md). Product: [eac.md](../applications/eac.md). Schema: EAC [`docs/db-model.md`](https://github.com/Breeze-On/breezeon-system-admin-eac/blob/main/docs/db-model.md) · thin [`docs/data-entities.md`](https://github.com/Breeze-On/breezeon-system-admin-eac/blob/main/docs/data-entities.md).

**Consumers:** Process Framework `DDL` (by **row Code**) and product `{UniqueCode}.Process` apps via `System.P_GET_EACDataEntityLookupValues` + SHARED-UI `IBoDataEntityLookupQueries` (persist `*Code`). Process View hydrate **must** use batch resolve — see [using-data-entities.md](using-data-entities.md) § batch.

## Ownership

| Concern | Owner |
| --- | --- |
| Tables, SPs, CRUD, validation | breezeon-system-admin-eac |
| EAC-domain standards / authoring | STANDARDS (`architecture/data-entities/`) |
| Consumer lookup SP (`P_GET_EACDataEntityLookupValues`) | breezeon-system-admin-eac |
| Consumer helper (`IBoDataEntityLookupQueries`) | breezeon-system-shared-ui |
| Product `*Code` columns + `seed/eac/` payloads | Product application repo |

## Definition of Done

Any change affecting Data Entity **schema**, **SPs**, **contracts**, **business rules**, or **standards** is incomplete until this tree, related ADR(s), EAC `docs/db-model.md`, and thin product pointers are updated in the **same change set**.
