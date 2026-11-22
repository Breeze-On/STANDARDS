<!-- Classification: AA; Scope: application:eac -->
# Architecture — Data Entities

Owner: Architecture (EAC)

**Data Entities are an EAC business capability** for **reference data** — not a generic master-data platform and not a platform-wide consumption API. Multi-application consumption is **Future Validation**. Implementation lives in SYSTEM-ADMIN-EAC.

## Index

| Document | Covers |
| --- | --- |
| [Data Entities standard](data-entities-standard.md) | Business meaning, boundary, flat limits, ownership, technical rules |
| [Authoring guide](authoring-guide.md) | Administrator sequence |
| [AI authoring contract](ai-authoring-contract.md) | Field contract + hazards |
| [Worked examples](worked-examples.md) | Cost Centers, Request Types→DDL, Regions |
| [Data Entities architecture](data-entities-architecture.md) | ERD, constraints, indexing, Excel retrieval |
| [Using Data Entities](using-data-entities.md) | **Non-normative** consumer notes until additional consumers exist |

Decisions: [ADR-016](../../decisions/ADR-016-data-entity-ownership.md); [ADR-018](../../decisions/ADR-018-data-entity-values-excel-portability.md). Product: [eac.md](../applications/eac.md). Schema: EAC [`docs/db-model.md`](https://github.com/Breeze-On/SYSTEM-ADMIN-EAC/blob/main/docs/db-model.md) · thin [`docs/data-entities.md`](https://github.com/Breeze-On/SYSTEM-ADMIN-EAC/blob/main/docs/data-entities.md).

**Only shipped consumer today:** Process Framework `DDL` by **row Code**.

## Ownership

| Concern | Owner |
| --- | --- |
| Tables, SPs, CRUD, validation | SYSTEM-ADMIN-EAC |
| EAC-domain standards / authoring | STANDARDS (`architecture/data-entities/`) |
| Future consumers | Read-only expectations TBD — do not invent |

## Definition of Done

Any change affecting Data Entity **schema**, **SPs**, **contracts**, **business rules**, or **standards** is incomplete until this tree, related ADR(s), EAC `docs/db-model.md`, and thin product pointers are updated in the **same change set**.
