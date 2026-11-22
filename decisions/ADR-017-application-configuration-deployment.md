<!-- Classification: DEC; Scope: platform -->
# ADR-017: Application Configuration deployment (synchronize-by-Code)

Status: Accepted

## Context

EAC Application Configuration is the central configuration platform for BreezeOn applications. Environments need a standard way to promote configuration (Local → DEV → TEST → PP → PROD).

Existing EAC JSON portability for Applications and Business Entities is **merge/upsert by Code** and does **not** remove objects absent from the file ([`docs/data-portability.md`](../docs/data-portability.md)). That semantic is wrong for Application Configuration deployment: the target environment must match the exported configuration state.

GUIDs are environment-local runtime keys. Portable identity for configuration objects must be business `Code` (and Application `UniqueCode` for the envelope), consistent with other BreezeOn JSON patterns.

## Decision

### Deployment, not backup/restore or merge

Exported JSON represents **Application Configuration State**. Import **synchronizes** the target Application so it matches the file: create missing Codes, update matched Codes, **remove** Codes present in the target but absent from the file.

This is not a merge. Synchronize is **section-participation based**.

**“No partial imports” means:**

- A **participating** section (JSON key present, including empty) synchronizes **completely** — create / update / remove by Code for that section. Importing only a subset of Codes within a present section, or merge-style behavior inside a section, is **not** allowed.
- An **omitted** section (JSON key absent) does **not** participate — that section is intentionally skipped and left unchanged on the target.

**Allowed (omit = skip):** `dataEntities` present while `variables` omitted; `variables` present while `securityGroups` omitted; `processFramework` present while other optional sections omitted.

**Not allowed:** synchronizing a subset of Codes within a present section; merge/upsert inside a participating section.

### Application identity

The portable envelope identifies the Application by **`applicationUniqueCode`** (`System.EACApplications.UniqueCode`). Short `applicationCode` may be exported for humans and, when present on import, must match the selected Application’s short `Code`. Match/validate never uses Application GUID.

### Object identity

Within an Application, configuration objects (Data Entities, Columns, Security Groups, Variables, Process Framework metadata columns / Roles / Steps / Options) match by **`Code`**. Never by GUID, database identity, or environment-specific keys. Variable values additionally match by (`businessEntityCode`, `code`) for Application Enabled contexts.

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

Application-scoped definitions (for example Data Entity definitions and columns, Variables definitions, and Process Framework Roles / Steps / Options with their metadata) synchronize under this framework. Instance/runtime Data Entity data owned by `ApplicationEnabledGUID` (rows, translations, metadata) and Security Group memberships remain **excluded** ([ADR-016](ADR-016-data-entity-ownership.md), [ADR-006](ADR-006-application-context-ownership.md)). **Exceptions that do ship context-scoped portable rows:** Security Groups configuration and **Variable values** (resolved by `businessEntityCode`).

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
- `schemaVersion` 1 ships Data Entities + Columns, optional Security Groups, and the optional Process Framework sections `processMetadataColumns`, `roles`, `steps`, `options` ([ADR-019](ADR-019-process-framework-metadata.md)). Current export (`schemaVersion` 2) also ships optional nested `processFramework` and optional `variables` (`definitions` + `values`). Legacy non-empty `systemConfiguration` is rejected. Optional sections: key absent = skipped; present (including empty arrays / empty nested trees) = synchronized **completely** (see “No partial imports” above).
- Administrators confirm via the standard Import Summary (`BoImportSummaryDialog`: Changes Summary + Errors/Warnings) before synchronize executes. Errors block Synchronize; warnings do not. Import Summary **must** warn when optional sections are omitted and when Application-scoped sections affect enablements beyond the selected Business Entity.
- Platform SSOT: [`architecture/app-configuration/`](../architecture/app-configuration/README.md).

## Related

- [ADR-006](ADR-006-application-context-ownership.md)
- [ADR-016](ADR-016-data-entity-ownership.md)
- [ADR-019](ADR-019-process-framework-metadata.md)
- [architecture/app-configuration/README.md](../architecture/app-configuration/README.md)
- [docs/data-portability.md](../docs/data-portability.md)
- [architecture/applications/eac.md](../architecture/applications/eac.md)
