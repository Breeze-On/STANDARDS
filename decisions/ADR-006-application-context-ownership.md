<!-- Classification: DEC; Scope: platform; Domain: Engineering; Capability: AdrProcess -->
# ADR-006: Application Context ownership and lifecycle

Status: Accepted

## Context

EAC enables Applications for Business Entities. Entity-specific configuration (roles, permissions, configurations, drop-down values, references, feature flags, future EAC metadata) must hang off a single canonical key rather than duplicating `(ApplicationGUID, BusinessEntityGUID)` pairs across tables.

## Decision

### Application Context

An **Application Context** is the unique operational instance of an Application within a Business Entity. It is stored in `System.EACApplicationsEnabled` and identified by **`ApplicationEnabledGUID`**.

### Ownership Standard

`ApplicationEnabledGUID` is the **root owner** of all entity-specific application configuration. Future tables that scope data to an enabled application **must** reference `ApplicationEnabledGUID` (not a duplicated Application + Business Entity pair).

### Exclusivity Standard

- A Business Entity may enable many Applications.
- An Application may be enabled on many Business Entities.
- A specific Application + Business Entity combination may exist **only once**.

The unique constraint on `(ApplicationGUID, BusinessEntityGUID)` is a **business rule**, not only a technical safeguard.

### Immutability Standard

`ApplicationEnabledGUID` is immutable:

- Generated exactly once on creation.
- Never regenerated, reassigned, or modified.
- If an Application Context is deleted and later re-created, a **new** `ApplicationEnabledGUID` is generated; prior values are never reused.

### Deletion Standard

EAC follows a clean-data model for **configuration** dependents:

- Deleting an Application Context hard-deletes the `EACApplicationsEnabled` row and **all** dependent **configuration** for that `ApplicationEnabledGUID`.
- No soft delete, disabled state, or orphan configuration records.
- Cleanup is implemented as **one centralized deletion workflow** (`System.P_POST_EACApplicationsEnabledDelete` and its service entry point). There is no plugin/registry abstraction.
- Future features that introduce **configuration** tables referencing `ApplicationEnabledGUID` **must directly extend** that centralized workflow in the same change set.

**Runtime process records (fail-closed):** `Global.Process` rows are **runtime** records owned by the platform process root ([ADR-024](ADR-024-platform-process-root.md)). Application Enabled deletion **must fail** when dependent `Global.Process` rows exist for that `ApplicationEnabledGUID`. The platform must **never** silently cascade-delete runtime process records. The centralized delete workflow checks for dependents and raises an error before mutating configuration.

### Mandatory future development rule

A feature that references `ApplicationEnabledGUID` is incomplete until:

1. It is documented as owned by the Application Context.
2. The centralized Application Context deletion workflow is updated.
3. Repositories/services involved in deletion are updated.
4. Validation / automated tests for that feature are updated (when an automated test initiative exists).
5. Architecture and business documentation are updated.

Application-scoped configuration promoted between environments must also follow Application Configuration deployment participation ([ADR-017](ADR-017-application-configuration-deployment.md)): define Export / Import / Synchronization / Code-matching in the same change set when the feature is part of App Configuration.

## Consequences

- Product UI may add enablement relationships from Update dialogs; persisted Application Context deletion is managed from the Applications Nested Grid (not from edit popups).
- Business Entity subtree delete must invoke the same Application Context deletion path before removing entities.
- When Application master-delete is introduced, it must delete all contexts for that `ApplicationGUID` via the centralized workflow.

## Related

- EAC [`docs/db-model.md`](https://github.com/Breeze-On/breezeon-system-admin-eac/blob/main/docs/db-model.md)
- [architecture/applications/eac.md](../architecture/applications/eac.md)
- [docs/database.md](../docs/database.md)
- [docs/glossary.md](../docs/glossary.md)
- [ADR-005](ADR-005-mandatory-transactional-audit-columns.md)
