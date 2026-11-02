# ADR-006: Application Context ownership and lifecycle

Status: Accepted

## Context

EAC enables Applications for Business Entities. Entity-specific configuration (roles, permissions, configurations, drop-down values, references, feature flags, future ADM metadata) must hang off a single canonical key rather than duplicating `(ApplicationGUID, BusinessEntityGUID)` pairs across tables.

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

EAC follows a clean-data model:

- Deleting an Application Context hard-deletes the `EACApplicationsEnabled` row and **all** dependent configuration for that `ApplicationEnabledGUID`.
- No soft delete, disabled state, or orphan records.
- Cleanup is implemented as **one centralized deletion workflow** (`System.P_POST_EACApplicationsEnabledDelete` and its service entry point). There is no plugin/registry abstraction.
- Future features that introduce tables referencing `ApplicationEnabledGUID` **must directly extend** that centralized workflow in the same change set.

### Mandatory future development rule

A feature that references `ApplicationEnabledGUID` is incomplete until:

1. It is documented as owned by the Application Context.
2. The centralized Application Context deletion workflow is updated.
3. Repositories/services involved in deletion are updated.
4. Validation / automated tests for that feature are updated (when an automated test initiative exists).
5. Architecture and business documentation are updated.

## Consequences

- Product UI may add enablement relationships from Update dialogs; persisted Application Context deletion is managed from the Applications Nested Grid (not from edit popups).
- Business Entity subtree delete must invoke the same Application Context deletion path before removing entities.
- When Application master-delete is introduced, it must delete all contexts for that `ApplicationGUID` via the centralized workflow.

## Related

- EAC [`docs/db-model.md`](https://github.com/Breeze-On/SYSTEM-ADMIN-EAC/blob/main/docs/db-model.md)
- [architecture/eac.md](../architecture/eac.md)
- [docs/database.md](../docs/database.md)
- [docs/glossary.md](../docs/glossary.md)
- [ADR-005](ADR-005-mandatory-transactional-audit-columns.md)
