# ADR-017: Application Configuration deployment (synchronize-by-Code)

Status: Accepted

## Context

EAC Application Configuration is the central configuration platform for BreezeOn applications. Environments need a standard way to promote configuration (Local → DEV → TEST → PP → PROD).

Existing EAC JSON portability for Applications and Business Entities is **merge/upsert by Code** and does **not** remove objects absent from the file ([`docs/data-portability.md`](../docs/data-portability.md)). That semantic is wrong for Application Configuration deployment: the target environment must match the exported configuration state.

GUIDs are environment-local runtime keys. Portable identity for configuration objects must be business `Code` (and Application `UniqueCode` for the envelope), consistent with other BreezeOn JSON patterns.

## Decision

### Deployment, not backup/restore or merge

Exported JSON represents **Application Configuration State**. Import **synchronizes** the target Application so it matches the file: create missing Codes, update matched Codes, **remove** Codes present in the target but absent from the file.

This is not a merge. Partial imports are not allowed.

### Application identity

The portable envelope identifies the Application by **`applicationUniqueCode`** (`System.EACApplications.UniqueCode`). Short `applicationCode` may be exported for humans and, when present on import, must match the selected Application’s short `Code`. Match/validate never uses Application GUID.

### Object identity

Within an Application, configuration objects (Data Entities, Columns, and future Steps / Options / Roles / System Configuration / Security Groups) match by **`Code`**. Never by GUID, database identity, or environment-specific keys.

### No rename detection

A Code change is treated as remove of the old Code and create of the new Code. Import does not infer renames.

### GUIDs never leave the environment

Exported JSON must not contain Application, Data Entity, Column, Role, Group, or other environment GUIDs. Import resolves Codes to target GUIDs before apply.

### SortOrder is configuration

`SortOrder` is exported and synchronized.

### Transactional import

Validate → build execution plan → apply entire import in one transaction, or apply nothing.

### Schema versioning

The Application Configuration kind uses integer `schemaVersion` starting at `1`. Unsupported versions are rejected.

### Relation to Application Context ownership

Application-scoped definitions (for example Data Entity definitions and columns) synchronize under this framework. Instance/runtime data owned by `ApplicationEnabledGUID` (rows, translations, metadata, memberships) is **excluded** from this portable contract ([ADR-016](ADR-016-data-entity-ownership.md), [ADR-006](ADR-006-application-context-ownership.md)).

Removing a Data Entity or Column during sync is blocked when dependents (rows / metadata) exist in any Application Context.

### Mandatory feature participation

Until all Application Configuration sections are implemented, any new App Configuration feature introduced into EAC must define, in the same design/change set:

1. Export behavior  
2. Import behavior  
3. Synchronization behavior  
4. Code matching rules  

and must extend the deployment envelope, planner, apply path, and STANDARDS documentation accordingly. Cross-link: [ADR-006](ADR-006-application-context-ownership.md) mandatory future development rule for `ApplicationEnabledGUID` dependents remains in force for context-owned data.

## Consequences

- EAC implements kind `breezeon.eac.application-configuration` with synchronize semantics, separate from Applications/BE merge portability.
- v1 ships Data Entities + Columns only; other sections are omitted until those features ship.
- Administrators confirm via the standard Import Summary (`BoImportSummaryDialog`: Changes Summary + Errors/Warnings) before synchronize executes. Errors block Synchronize; warnings do not.
- Platform SSOT: [`architecture/app-configuration/`](../architecture/app-configuration/README.md).

## Related

- [ADR-006](ADR-006-application-context-ownership.md)
- [ADR-016](ADR-016-data-entity-ownership.md)
- [architecture/app-configuration/README.md](../architecture/app-configuration/README.md)
- [docs/data-portability.md](../docs/data-portability.md)
- [architecture/eac.md](../architecture/eac.md)
