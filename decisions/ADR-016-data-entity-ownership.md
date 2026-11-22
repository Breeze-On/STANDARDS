<!-- Classification: DEC; Scope: platform; Domain: Engineering; Capability: AdrProcess -->
# ADR-016: Data Entity ownership and scope

Status: Accepted

## Context

EAC owns BreezeOn’s configurable master-data framework (**Data Entities**). Definitions (entity and custom columns) are shared by every Application Context for a given Application (codebase). Instance values (rows, translations, metadata) are entity-specific configuration and must follow Application Context ownership ([ADR-006](ADR-006-application-context-ownership.md)).

Without an explicit split, implementers may hang definitions on `ApplicationEnabledGUID` (forcing duplicate schemas per enablement) or hang rows only on `ApplicationGUID` (breaking per-context data and ADR-006 delete cleanup).

## Decision

### Definitions (Application-scoped)

`System.EACDataEntities` and `System.EACDataEntitiesColumns` reference **`ApplicationGUID`** (via the Data Entity → Application relationship for columns). Every Application Context for that Application inherits the same definitions. There is no schema versioning per enablement.

### Instance data (Application Context–scoped)

`System.EACDataEntitiesRows`, `System.EACDataEntitiesRowsTranslations`, and `System.EACDataEntitiesRowsMetadata` are owned by **`ApplicationEnabledGUID`** for row scope (rows also reference `DataEntityGUID`). Consumer apps may read/filter/search/display; they must not create or mutate Data Entity schema or rows outside EAC CRUD.

### CRUD ownership

EAC exclusively owns Data Entity definitions, columns, rows, translations, validation, stored procedures, business rules, standards, and documentation. Extending `P_POST_EACApplicationsEnabledDelete` / Application delete workflows for Data Entity dependents is mandatory in the same change set that introduces referencing tables ([ADR-006](ADR-006-application-context-ownership.md)).

## Consequences

- Creating or editing a Data Entity definition applies to all enablements of that Application.
- Deleting an Application Context removes that context’s rows (and translations/metadata), not the shared definitions.
- Deleting an Application removes definitions (and columns) after enablements/rows are cleared.
- Platform standards live under [`architecture/data-entities/`](../architecture/data-entities/README.md).

## Related

- [ADR-006](ADR-006-application-context-ownership.md)
- [architecture/data-entities/README.md](../architecture/data-entities/README.md)
- [architecture/applications/eac.md](../architecture/applications/eac.md)
- EAC [`docs/db-model.md`](https://github.com/Breeze-On/SYSTEM-ADMIN-EAC/blob/main/docs/db-model.md)
