# Identity schema standard

Owner: Architecture

## Ownership

| Concern | Owner |
| --- | --- |
| Schema / table definitions (T-SQL current model + seed) | SYSTEM-SHARED-UI (`sql/identity/`) |
| Physical tables | **Customer database** (one catalog per customer-environment; shared by all BreezeOn product applications in that environment) |
| Login-time upsert / login insert / tenant discovery | SYSTEM-SHARED-UI default SQL directory writer |
| Directory sync / photo refresh / user queries | SYSTEM-SHARED-UI ([directory-synchronization-standard.md](directory-synchronization-standard.md), [ADR-013](../../decisions/ADR-013-microsoft-graph-directory-synchronization.md)) |
| Competing user stores | **Forbidden** — do not add AspNet Identity tables or alternate user master tables for this purpose |

SYSTEM-SHARED-UI does **not** host a database.

### Topology

- Customer A: EAC, VMR (and other products) share **one** customer database containing one `Identity` schema plus product business schemas.
- Customer B: separate server/database and an independent Identity directory.
- `UsersId` is shared across applications within the same customer database.
- The same Entra identity may have separate database-local rows across different customers.
- Permanent identity key remains `(TenantId, ExternalObjectId)`.
- Product apps apply SHARED-UI Identity scripts idempotently (`IF OBJECT_ID ... IS NULL`) into the customer database; they must not create a second Identity catalog for the same customer-environment.

## Schema: `Identity`

### `Identity.Users`

Master user directory and Microsoft Graph synchronization target.

| Column | Type | Notes |
| --- | --- | --- |
| `UsersId` | `INT` IDENTITY | PK |
| `UsersGuid` | `UNIQUEIDENTIFIER` NOT NULL UNIQUE | Immutable row id |
| `TenantId` | `UNIQUEIDENTIFIER` NOT NULL | Entra `tid` |
| `ExternalObjectId` | `UNIQUEIDENTIFIER` NOT NULL | Entra `oid` |
| `UserPrincipalName` | `NVARCHAR(320)` NULL | Attribute only |
| `Email` | `NVARCHAR(320)` NULL | Attribute only |
| `DisplayName` | `NVARCHAR(256)` NULL | |
| `GivenName` | `NVARCHAR(128)` NULL | |
| `Surname` | `NVARCHAR(128)` NULL | |
| `IsEnabled` | `BIT` NOT NULL | Default 1. Directory enablement: when `0`, login fails (no cookie) **and** ongoing sessions are rejected via `IBoIdentitySessionGate` within the 60s cache SLO ([session-management-standard.md](session-management-standard.md), [ADR-012](../../decisions/ADR-012-cookie-session-management.md)). Login path does not mutate this column. Sync path may set from Graph `accountEnabled` / soft-disable. |
| `LastSyncUtc` | `DATETIME2` NULL | Last time this row was refreshed by Graph sync; null until sync |
| `LastLoginUtc` | `DATETIME2` NULL | Denormalized last successful login |

**Permanent identity key:** `UNIQUE (TenantId, ExternalObjectId)`.

Do **not** build relationships from Email or UserPrincipalName.

**Deferred (not in V1):** `Department`, `JobTitle`, `ManagerExternalObjectId` — no current business consumer; add later via dedicated schema evolution when a consumer exists.

### `Identity.UsersLogins`

Authentication history / login auditing / usage tracking.

| Column | Type | Notes |
| --- | --- | --- |
| `UsersLoginsId` | `INT` IDENTITY | PK |
| `UsersLoginsGuid` | `UNIQUEIDENTIFIER` NOT NULL UNIQUE | |
| `UsersId` | `INT` NOT NULL | FK → `Identity.Users` |
| `LoginUtc` | `DATETIME2` NOT NULL | |
| `AuthenticationProvider` | `NVARCHAR(64)` NOT NULL | e.g. `MicrosoftEntraId` |
| `ClientIpAddress` | `NVARCHAR(64)` NULL | |
| `IsSuccessful` | `BIT` NOT NULL | Successful auth path writes 1 |

Create a login row for every successful authentication. Update `Users.LastLoginUtc` on the same path. Do not write a successful login row when `IsEnabled = 0`.

### `Identity.Tenants`

Observed Entra tenant registry and directory-sync metadata. **Not** a login allowlist (forbidden pattern: `Identity.AllowedTenants` / `AUTHENTICATION__TENANTID`).

| Column | Type | Notes |
| --- | --- | --- |
| `TenantId` | `UNIQUEIDENTIFIER` | PK — Entra `tid` |
| `DisplayName` | `NVARCHAR(256)` NULL | When known |
| `IsSyncEnabled` | `BIT` NOT NULL DEFAULT 0 | Explicit enablement only; login discovery never sets this to 1 |
| `LastSyncUtc` | `DATETIME2` NULL | Last **completed** sync job for this tenant |
| `LastSyncStatus` | `NVARCHAR(32)` NULL | `Succeeded` / `Failed` / `Running` |
| `LastSyncError` | `NVARCHAR(2000)` NULL | Truncated safe message |
| `SyncStartedUtc` | `DATETIME2` NULL | Concurrency / Running |
| `DiscoveredUtc` | `DATETIME2` NOT NULL | First login observation |

Multiple rows may have `IsSyncEnabled = 1`; Sync Now processes each sequentially. No delta cursor columns in V1.

### `Identity.UserPhotos`

Profile photo cache. Populated on **successful login** only (not during directory sync). Consumers must use SHARED-UI photo APIs — do not read storage columns directly from product UI.

| Column | Type | Notes |
| --- | --- | --- |
| `UsersId` | `INT` | PK / FK → `Identity.Users` |
| `StorageProvider` | `NVARCHAR(32)` NOT NULL | V1 constant `Sql`; future e.g. `AzureBlob` |
| `ContentType` | `NVARCHAR(128)` NULL | e.g. `image/jpeg` |
| `PhotoBytes` | `VARBINARY(MAX)` NULL | V1 payload; NULL after future external migration |
| `ExternalUri` | `NVARCHAR(2048)` NULL | NULL in V1; future object-store URI/path |
| `ExternalETag` | `NVARCHAR(128)` NULL | Optional future concurrency/cache |
| `RetrievedUtc` | `DATETIME2` NOT NULL | Last successful refresh |
| `ContentLengthBytes` | `INT` NULL | Optional size |

Failure to retrieve a photo must never block login; existing rows remain.

## Audit columns (ADR-005)

`Identity.Users`, `Identity.UsersLogins`, `Identity.Tenants`, and `Identity.UserPhotos` are **excepted** from mandatory transactional audit columns (`CreatedBy` / `CreatedDate` / `LastUpdatedBy` / `LastUpdatedDate`). They are platform directory / login history / sync metadata / photo cache, not ordinary business transactional entities. See [ADR-005](../../decisions/ADR-005-mandatory-transactional-audit-columns.md) and [ADR-010](../../decisions/ADR-010-platform-identity-schema.md).

## Related

- [Authentication standard](authentication-standard.md)
- [Directory synchronization standard](directory-synchronization-standard.md)
- [Session management standard](session-management-standard.md)
- Canonical scripts: SYSTEM-SHARED-UI `sql/identity/current_model/`
