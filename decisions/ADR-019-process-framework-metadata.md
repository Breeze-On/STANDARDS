<!-- Classification: DEC; Scope: application:eac; Domain: Platform; Capability: ProcessFramework -->
# ADR-019: Process Framework metadata

Status: Accepted

## Context

EAC Application Configuration includes the **Process Framework** (EAC business capability — not a platform workflow engine): Application-scoped **Roles**, **Steps**, and **Options** — one process definition per Application — that a future workflow engine may consume ([architecture/process-framework](../architecture/process-framework/README.md)). Each of the three entities needs administrator-defined extra fields (labels, categories, thresholds, a data-entity-backed choice, a responsible person).

Data Entity custom columns ([ADR-016](ADR-016-data-entity-ownership.md)) already provide a sparse-metadata pattern, but their type set (`TEXT` / `DECIMAL` / `BOOLEAN` / `DATE` / `DATETIME`) is deliberately about master-data values and must not change. Process Framework metadata additionally needs a **reference to a Data Entity row** and a **reference to a person**, and every definition must remain deployable across environments through Application Configuration JSON ([ADR-017](ADR-017-application-configuration-deployment.md)). GUIDs are environment-local ([ADR-006](ADR-006-application-context-ownership.md)); `Identity.Users.UserGUID` is minted per database and can change on an Identity rebuild, while the Entra object id (`ExternalObjectId`) is stable ([identity-schema-standard](../architecture/identity-and-authentication/identity-schema-standard.md)).

## Decision

### Ownership: Application-scoped

Roles, Steps, Options, and the metadata column catalog are owned by **`ApplicationGUID`** (like Data Entity definitions), not by an Application Context. Application Context delete does not remove Process Framework data; Application delete does.

### One shared metadata engine (single-entity ownership)

One metadata column catalog table per Application (`System.EACProcessMetadataColumns`) serves Roles, Steps, and Options. Each catalog row belongs to **exactly one** Process Framework entity via `ProcessFrameworkEntity` (`ROLE` | `STEP` | `OPTION`, aligned with `EACProcessMetadataValues.OwnerType`). The same logical `Code` may exist once per entity as **separate rows** (independent definitions, each with its own `MetadataColumnGUID`). Values are sparse typed EAV rows (`System.EACProcessMetadataValues`, polymorphic `OwnerType` + `OwnerGUID`; no row when the value is NULL). Translations (`System.EACProcessMetadataTranslations`) exist for `TEXT` columns only. There are not three parallel column systems or multi-flag applicability bits.

### Process Framework metadata type set (separate from Data Entity types)

Allowed `DataType`: `TEXT` | `NUMBER` | `DATE` | `DATETIME` | `BOOLEAN` | `DDL` | `PEOPLEPICKER`. Type is immutable after create.

- `DDL` and `PEOPLEPICKER` are valid **only** on Process Framework columns. The Data Entity column type set ([ADR-016](ADR-016-data-entity-ownership.md), [data-entities-standard](../architecture/data-entities/data-entities-standard.md)) is **unchanged**.
- `NUMBER` carries `Decimals` 0..10 (default 2); `DDL` requires `DataEntityCode`.

### Code vs GUID split

| Layer | Identity |
| --- | --- |
| Database relationships | GUID foreign keys (`RoleGUID`, `StepGUID`, `NextStepGUID`, `MetadataColumnGUID`) |
| Portable JSON, UI references, soft references | **Codes** (`Role.Code` ← `Step.roleCode`; `Step.Code` ← `Option.stepCode` / `nextStepCode`; column `Code`; `DataEntityCode`; Data Entity row Code for `DDL` values; `securityGroupAttributeCode`) |

GUIDs never appear in Application Configuration JSON; import resolves Codes to target GUIDs inside the sync transaction. Soft references (`securityGroupAttributeCode`, `DataEntityCode`, DDL row Codes, `OwnerGUID`) have no foreign key.

### PeoplePicker portable identity = `ExternalObjectId`

`PEOPLEPICKER` values are persisted and exported as **`Identity.Users.ExternalObjectId`** (Entra `oid`, GUID string), never `UserGUID`, UPN, or email. The UI still binds `BoPeoplePicker` to platform `UserGUID`; an EAC adapter (`ProcessPeoplePickerIdentityAdapter`) maps `UserGUID` ↔ `ExternalObjectId` on load and save. The shared control contract is unchanged. Import does not require the user to exist locally; an unresolved id shows as empty until directory sync creates the user.

### Column delete cascades

Deleting a metadata column is **always allowed** and deletes translations → values → column in one transaction (UI Settings Save and Application Configuration sync alike). It is never blocked by existing values. Settings delete always removes that entity’s catalog row (no soft “clear applicability on a shared row”). Entity-level deletes remain guarded: a Role referenced by Steps, and a Step referenced by Options (as `StepGUID` or `NextStepGUID`), cannot be deleted.

### Deployment participation

Application Configuration JSON uses nested `processFramework.{steps|options|roles}.{metadataColumns|values}` (schemaVersion **2**). Legacy schemaVersion **1** dual-read accepts flat root keys `processMetadataColumns`, `roles`, `steps`, `options`. Synchronize by `(code, owner)` for columns (and by Code for roles/steps; options by stepCode+code); key absent = skipped, present (including `[]`) = synchronized. No separate import/export feature exists for Process Framework.

Import Analysis may emit **non-blocking warnings** for graph lint (no terminal Step, unreachable Steps, Role Step with zero Options) and dangling `securityGroupAttributeCode` when Security Groups participate in the same file.

### Display name conventions

Metadata column Codes **`name`** and **`description`** are the conventional display labels for Roles, Steps, and Options (not first-class fields). TEXT metadata authoring uses authoritative language **`en-CA`**.

### Not in scope

No workflow engine, task assignment, or **Process Framework** instance/runtime tables. Role `Type` is `Group` only. No multi-application PF consumption contract (Future Validation). No Process entity table in v1 (one process definition per Application).

**Clarification:** Platform runtime process identity lives in **`Global.Process`** ([ADR-024](ADR-024-platform-process-root.md)) — orthogonal to Process Framework **definition** metadata. This ADR does not prohibit `Global.Process`; it prohibits treating PF tables as runtime instance stores.

## Consequences

- Process Framework definitions promote between environments with the existing Application Configuration deployment mechanism; metadata for `PEOPLEPICKER` survives Identity rebuilds and works across environments that sync the same Entra tenant.
- Adding a Process Framework metadata type is a Process Framework decision (amend this ADR); it does not widen Data Entity column types.
- Resolving `ExternalObjectId` → `UserGUID` is an environment-local lookup (`(TenantId, ExternalObjectId)` within the target tenant registry) performed by EAC UI and, in future, the workflow engine.
- Column delete cascade deliberately favors configuration cleanup over preserving orphaned values.
- EAC-domain SSOT: [`architecture/process-framework/`](../architecture/process-framework/README.md). JSON contract: [`docs/data-portability.md`](../docs/data-portability.md). Schema inventory: EAC [`docs/db-model.md`](https://github.com/Breeze-On/breezeon-system-admin-eac/blob/main/docs/db-model.md).

## Related

- [ADR-006](ADR-006-application-context-ownership.md)
- [ADR-016](ADR-016-data-entity-ownership.md)
- [ADR-017](ADR-017-application-configuration-deployment.md)
- [architecture/process-framework/README.md](../architecture/process-framework/README.md)
- [architecture/app-configuration/application-configuration-deployment.md](../architecture/app-configuration/application-configuration-deployment.md)
