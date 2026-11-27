<!-- Classification: AA; Scope: platform; Domain: Security; Capability: Authentication -->
# Identity schema standard

Owner: Architecture

## Ownership

| Concern | Owner |
| --- | --- |
| Schema / table / People Picker procedure definitions (T-SQL current model + seed) | breezeon-system-shared-ui (`sql/identity/`) |
| Physical tables | **Customer database** (one catalog per customer-environment; shared by all BreezeOn product applications in that environment) |
| Login-time upsert / login insert / tenant discovery | breezeon-system-shared-ui default SQL directory writer |
| Directory sync / photo refresh / user queries | breezeon-system-shared-ui ([directory-synchronization-standard.md](directory-synchronization-standard.md), [ADR-013](../../decisions/ADR-013-microsoft-graph-directory-synchronization.md)) |
| Competing user stores | **Forbidden** — do not add AspNet Identity tables or alternate user master tables for this purpose |

breezeon-system-shared-ui does **not** host a database.

### Topology

- Customer A: EAC, VMR (and other products) share **one** customer database containing one `Identity` schema plus product business schemas.
- Customer B: separate server/database and an independent Identity directory.
- **`UserGUID` is the canonical BreezeOn platform user identifier** shared across applications within the same customer database. `UsersId` is the physical primary key only and must not be used as a cross-product or authorization reference.
- The same Entra identity may have separate database-local rows across different customers.
- Authoritative Entra resolution key remains `(TenantId, ExternalObjectId)`.
- Product apps apply SHARED-UI Identity scripts into the customer database; they must not create a second Identity catalog for the same customer-environment.

### Identity hierarchy

```text
Entra Identity
  → (TenantId, ExternalObjectId)   # authoritative resolution / upsert natural key
  → UserGUID                       # BreezeOn platform identifier
  → physical Users row (UsersId)   # storage only
```

## Schema: `Identity`

### `Identity.Users`

Master user directory and Microsoft Graph synchronization target.

| Column | Type | Notes |
| --- | --- | --- |
| `UsersId` | `INT` IDENTITY | Physical PK only |
| `UserGUID` | `UNIQUEIDENTIFIER` NOT NULL UNIQUE | **Canonical BreezeOn platform user identifier**; default `NEWSEQUENTIALID()` |
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

**Permanent Entra resolution key:** `UNIQUE (TenantId, ExternalObjectId)`.

Do **not** build relationships from Email, UserPrincipalName, or `UsersId`. Logical relationships use **`UserGUID`**.

**Deferred (not in V1):** `Department`, `JobTitle`, `ManagerExternalObjectId` — no current business consumer; add later via dedicated schema evolution when a consumer exists.

**Supporting index:** `IX_Identity_Users_IsEnabled_DisplayName` on `(IsEnabled, DisplayName)` INCLUDE `(Email, UserPrincipalName, UserGUID)` — ordered Top-N of active users for People Picker empty search (does not accelerate `%term%` contains).

### `Identity.P_GET_UsersComponentValues`

One-off platform read procedure for `BoPeoplePicker` (breezeon-system-shared-ui). **Not** a `*ComponentValues` naming family.

| Parameter | Role |
| --- | --- |
| `@SearchText` | Keyword on DisplayName / Email / UserPrincipalName |
| `@MaxItems` | Clamped 1..100 |
| `@TenantId` | Optional; NULL = all tenants in the customer database |
| `@ExcludeUserGuids` | JSON array of UserGUID strings to exclude |
| `@ResolveUserGuids` | JSON array for hydration of selected GUIDs |

Always filters `IsEnabled = 1`. Projection: `UserGUID`, `DisplayName`, `Email`, `UserPrincipalName`, `DisplayText` (`DisplayName (Email)` with null-safe fallback). Bound UI value is always **`UserGUID`**. Detail: STANDARDS [forms.md — People Picker](../../docs/ui/controls/forms.md#people-picker-bopeoplepicker) · [database.md](../../docs/database.md#platform-identity-procedure-people-picker--one-off).

### `Identity.UsersLogins`

Authentication history / login auditing / usage tracking.

| Column | Type | Notes |
| --- | --- | --- |
| `UsersLoginsId` | `INT` IDENTITY | Physical PK |
| `UserLoginGUID` | `UNIQUEIDENTIFIER` NOT NULL UNIQUE | |
| `UserGUID` | `UNIQUEIDENTIFIER` NOT NULL | FK → `Identity.Users.UserGUID` |
| `LoginUtc` | `DATETIME2` NOT NULL | |
| `AuthenticationProvider` | `NVARCHAR(64)` NOT NULL | e.g. `MicrosoftEntraId` |
| `ClientIpAddress` | `NVARCHAR(64)` NULL | |
| `IsSuccessful` | `BIT` NOT NULL | Successful auth path writes 1 |

Index: `(UserGUID, LoginUtc DESC)`.

Create a login row for every successful authentication. Update `Users.LastLoginUtc` on the same path. Do not write a successful login row when `IsEnabled = 0`.

### `Identity.Tenants`

Observed Entra tenant registry and directory-sync metadata. **Not** a login allowlist (forbidden pattern: `Identity.AllowedTenants` / `AUTHENTICATION__TENANTID`).

| Column | Type | Notes |
| --- | --- | --- |
| `TenantsId` | `INT` IDENTITY | Physical PK |
| `TenantGUID` | `UNIQUEIDENTIFIER` NOT NULL UNIQUE | BreezeOn platform tenant identifier |
| `TenantId` | `UNIQUEIDENTIFIER` NOT NULL UNIQUE | Entra `tid` (external resolution key; not the table PK) |
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
| `UserPhotosId` | `INT` IDENTITY | Physical PK |
| `UserPhotoGUID` | `UNIQUEIDENTIFIER` NOT NULL UNIQUE | |
| `UserGUID` | `UNIQUEIDENTIFIER` NOT NULL UNIQUE | FK → `Identity.Users.UserGUID` (1:1) |
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
- [Platform authorization](../authorization/README.md)
- Canonical scripts: breezeon-system-shared-ui `sql/identity/current_model/`
