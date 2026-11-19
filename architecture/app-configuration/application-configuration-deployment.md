# Application Configuration deployment

Owner: Architecture

Standard mechanism for promoting Application Configuration between environments (Local → DEV → TEST → PP → PROD).

Decision: [ADR-017](../../decisions/ADR-017-application-configuration-deployment.md). Portable JSON: [`docs/data-portability.md`](../../docs/data-portability.md) § Application Configuration JSON.

## Purpose

Exported JSON is **Application Configuration State**. Import **synchronizes** the selected Application so the target matches the file.

This is **not** backup/restore and **not** merge. Applications and Business Entities JSON remain merge/upsert; Application Configuration is a separate semantic family.

## Principles

| Principle | Rule |
| --- | --- |
| Synchronize | Create Codes in file not in target; update matched Codes; remove Codes in target not in file |
| Code is identity | Match configuration objects by `Code` within the Application |
| Application identity | Envelope uses `applicationUniqueCode` (`UniqueCode`); never Application GUID |
| GUIDs stay local | Never export environment GUIDs; resolve Codes → target GUIDs on import |
| No rename detection | In portable JSON, a Code change = remove old + create new. EAC **Edit Data Entities** can rename `Code` in place (GUID stable); update deployment/seed JSON deliberately after such renames so sync still matches |
| SortOrder | Exported and synchronized |
| Transactional | Validate → plan → confirm → apply all-or-nothing |

## Portable unit (current)

- Deployment identity is the **Application** (`UniqueCode`).
- Business Entity selection on `/app-configuration` gates the workspace; it is not part of the v1 portable identity.
- Definitions owned by `ApplicationGUID` (Data Entities + Columns, Process Framework Roles / Steps / Options + metadata columns) are in scope ([ADR-016](../../decisions/ADR-016-data-entity-ownership.md), [ADR-019](../../decisions/ADR-019-process-framework-metadata.md)).

## Included (current)

| Section | Contents |
| --- | --- |
| Data Entities | Definitions, Columns, SortOrder |
| Security Groups | AttributeCode configuration per Business Entity (Application Context); synchronized Security.Groups Code/Name/Description; no memberships |
| Process Framework | Metadata column catalog, Roles, Steps, Options (with metadata values + `TEXT` translations); Application-scoped; Codes only — [process-framework](../process-framework/README.md) |

## Explicitly excluded

- Data Entity Rows, Translations, Metadata values (Data Entity row data; Process Framework metadata values **are** included, nested under their Role / Step / Option)
- Security Group memberships / user assignments
- Application runtime / operational / audit data
- Environment-specific GUIDs

## Section participation (current)

| Section | In JSON | Synchronized |
| --- | --- | --- |
| `dataEntities` | Yes | Yes |
| `securityGroups` | Yes (export always; import when present) | Yes when key present; skipped when omitted |
| `processMetadataColumns` | Yes (export always; import when present) | Yes when key present; skipped when omitted or `null` |
| `roles` | Yes (export always; import when present) | Yes when key present; skipped when omitted or `null` |
| `steps` | Yes (export always; import when present) | Yes when key present; skipped when omitted or `null` |
| `options` | Yes (export always; import when present) | Yes when key present; skipped when omitted or `null` |
| `systemConfiguration` | Omitted | No |

Non-empty not-yet-shipped section keys (`systemConfiguration`) are rejected as unsupported for the current `schemaVersion`.

### Process Framework sections

- Match keys: `processMetadataColumns`, `roles`, `steps` by `code`; `options` by (`stepCode`, `code`). Cross references are Codes (`roleCode`, `stepCode`, `nextStepCode`, `dataEntityCode`); GUIDs are never in the file.
- Sync order in the single transaction: metadata columns → roles → steps → options; removals run in reverse. Removing a metadata column is **always allowed** and cascades translations → values → column (no in-use block). Removing a Step / Role is blocked while a remaining Option / Step references it. A `DDL` column's `dataEntityCode` must match a Data Entity of the Application, and that Data Entity cannot be removed while a `DDL` column references it.
- Metadata values travel in each Role / Step / Option `metadata` object keyed by column Code. `PEOPLEPICKER` values are `externalObjectId` strings (never `userGuid`); `DDL` values are Data Entity row Codes; `TEXT` is a language map. Decision: [ADR-019](../../decisions/ADR-019-process-framework-metadata.md). Field tables: [`docs/data-portability.md`](../../docs/data-portability.md#process-framework-sections).

## Removal safety

- Removing a Data Entity is blocked when any rows exist for that entity in **any** Application Context.
- Removing a Column is **always allowed**; associated row metadata is deleted, then the column (same cascade as Settings Save).
- Column `type` is immutable on update; a type change for an existing Code is a validation failure.
- Column `decimals` (0–10) applies to `DECIMAL` only (default 2 when omitted); `DATE` is a first-class type alongside `DATETIME`.

## Import UX (current)

1. Upload JSON (in memory; size-limited).
2. Validate file-level schema / application match (toasts on hard file failures — summary never opens).
3. Build sync plan; open standard **Import Summary** (`BoImportSummaryDialog`): Changes Summary grid (Item Type · Item Code · New · Updated · Deleted; one row per planned code) + Errors and Warnings. Planner blocking issues (e.g. column type change, entity with rows) appear as Errors and disable Synchronize. Removals show only as Deleted counts.
4. Administrator confirms **Synchronize** (disabled when Errors exist or there are no changes). Warnings do not block.
5. Apply in one SQL transaction, or apply nothing.

Pattern: [import-summary.md](../../docs/ui/patterns/import-summary.md).

## Planned / not shipped — feature participation rule

Until every Application Configuration section is implemented, any **new** App Configuration feature introduced into EAC must define in the same design/change set:

1. Export behavior  
2. Import behavior  
3. Synchronization behavior  
4. Code matching rules  

and must extend the envelope, planner, apply path, and this documentation. Shrink or remove this subsection as sections become current reality. Normative decisions: [ADR-017](../../decisions/ADR-017-application-configuration-deployment.md), [ADR-006](../../decisions/ADR-006-application-context-ownership.md).

## Local Docker seed

EAC local `dev-reset` / `local-db-seed` may apply the same deployment JSON after Applications/BE/enablement SQL, via `tools/BreezeOn.Eac.LocalAppConfigurationSeed` (validator + synchronizer + `P_POST_EACApplicationConfigurationSync`). This is **local sandbox only** — never hosted DEV/TEST/PP/PROD. Product details: EAC [`sql/seed/README.md`](https://github.com/Breeze-On/SYSTEM-ADMIN-EAC/blob/main/sql/seed/README.md).

## Related

- Operations: [`runbooks/eac-application-configuration-deployment.md`](../../runbooks/eac-application-configuration-deployment.md)
- Product surface: [architecture/eac.md](../eac.md)
- Data Entities: [architecture/data-entities/README.md](../data-entities/README.md)
- Process Framework: [architecture/process-framework/README.md](../process-framework/README.md)
