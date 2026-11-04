# Identity schema standard

Owner: Architecture

## Ownership

| Concern | Owner |
| --- | --- |
| Schema / table definitions (T-SQL current model + seed placeholders) | SYSTEM-SHARED-UI (`sql/identity/`) |
| Physical tables | Each application database |
| Login-time upsert / login insert | SYSTEM-SHARED-UI default SQL directory writer |
| Competing user stores | **Forbidden** — do not add AspNet Identity tables or alternate user master tables for this purpose |

SYSTEM-SHARED-UI does **not** host a database.

## Schema: `Identity`

### `Identity.Users`

Master user directory and future Microsoft Graph synchronization target.

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
| `IsEnabled` | `BIT` NOT NULL | Default 1 |
| `LastSyncUtc` | `DATETIME2` NULL | Future Graph; null until sync |
| `LastLoginUtc` | `DATETIME2` NULL | Denormalized last successful login |

**Permanent identity key:** `UNIQUE (TenantId, ExternalObjectId)`.

Do **not** build relationships from Email or UserPrincipalName.

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

Create a login row for every successful authentication. Update `Users.LastLoginUtc` on the same path.

## Audit columns (ADR-005)

`Identity.Users` and `Identity.UsersLogins` are **excepted** from mandatory transactional audit columns (`CreatedBy` / `CreatedDate` / `LastUpdatedBy` / `LastUpdatedDate`). They are platform directory / append-only login history, not ordinary business transactional entities. See [ADR-005](../../decisions/ADR-005-mandatory-transactional-audit-columns.md) and [ADR-010](../../decisions/ADR-010-platform-identity-schema.md).

## Related

- [Authentication standard](authentication-standard.md)
- Canonical scripts: SYSTEM-SHARED-UI `sql/identity/current_model/`
