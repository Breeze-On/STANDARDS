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
| No rename detection | Code change = remove old + create new |
| SortOrder | Exported and synchronized |
| Transactional | Validate → plan → confirm → apply all-or-nothing |

## Portable unit (current)

- Deployment identity is the **Application** (`UniqueCode`).
- Business Entity selection on `/app-configuration` gates the workspace; it is not part of the v1 portable identity.
- Definitions owned by `ApplicationGUID` (Data Entities + Columns) are in scope ([ADR-016](../../decisions/ADR-016-data-entity-ownership.md)).

## Included (current)

| Section | Contents |
| --- | --- |
| Data Entities | Definitions, Columns, SortOrder |

## Explicitly excluded

- Data Entity Rows, Translations, Metadata values
- Security Group memberships / user assignments
- Application runtime / operational / audit data
- Environment-specific GUIDs

## Section participation (current)

| Section | In JSON | Synchronized |
| --- | --- | --- |
| `dataEntities` | Yes | Yes |
| `steps` / `options` / `roles` / `systemConfiguration` / `securityGroups` | Omitted | No |

Non-empty not-yet-shipped section keys are rejected as unsupported for the current `schemaVersion`.

## Removal safety

- Removing a Data Entity is blocked when any rows exist for that entity in **any** Application Context.
- Removing a Column is blocked when any row metadata references that column.
- Column `type` is immutable on update; a type change for an existing Code is a validation failure.

## Import UX (current)

1. Upload JSON (in memory; size-limited).
2. Validate (schema, application match, configuration, sync plan safety).
3. Show create / update / remove summary.
4. Administrator confirms **Synchronize**.
5. Apply in one SQL transaction, or apply nothing.

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
