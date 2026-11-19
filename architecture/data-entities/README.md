# Architecture — Data Entities

Owner: Architecture

Platform configurable master-data / reference-data framework owned by EAC. Answers: **what exists** for Data Entity definitions, columns, rows, translations, and metadata.

## Index

| Document | Covers |
| --- | --- |
| [Data Entities standard](data-entities-standard.md) | Purpose, what qualifies, ownership, naming, navigation labels, Quick Actions (incl. Excel Tool), platform rules, performance |
| [Data Entities architecture](data-entities-architecture.md) | ERD, constraints, indexing, sparse metadata, translation strategy, Excel Tool retrieval/apply |
| [Using Data Entities](using-data-entities.md) | Consumer retrieval patterns and future app expectations |

Decisions: [ADR-016](../../decisions/ADR-016-data-entity-ownership.md) (definition vs row ownership); [ADR-018](../../decisions/ADR-018-data-entity-values-excel-portability.md) (Values Excel portability; file contract in [`docs/data-portability.md`](../../docs/data-portability.md)). Application Context lifecycle: [ADR-006](../../decisions/ADR-006-application-context-ownership.md). Product surface: [architecture/eac.md](../eac.md). Schema inventory: EAC [`docs/db-model.md`](https://github.com/Breeze-On/SYSTEM-ADMIN-EAC/blob/main/docs/db-model.md).

## Ownership

| Concern | Owner |
| --- | --- |
| Tables, SPs, CRUD, validation, business rules | SYSTEM-ADMIN-EAC (`System` schema) |
| Platform standards / architecture / consumer guidance | STANDARDS (`architecture/data-entities/`) |
| Consumer applications | Read / filter / search / display only — no direct writes |

## Definition of Done

Any change affecting Data Entity **schema**, **stored procedures**, **API contracts**, **business rules**, **CRUD flows**, or **platform standards** is incomplete until this tree, related ADR(s), EAC [`docs/db-model.md`](https://github.com/Breeze-On/SYSTEM-ADMIN-EAC/blob/main/docs/db-model.md), and thin product `README` / `README_AI` pointers are updated in the **same change set**. Documentation is part of the feature, not a follow-up.
