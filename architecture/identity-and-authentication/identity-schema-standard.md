# Identity schema standard

Owner: Architecture

## Ownership

| Concern | Owner |
| --- | --- |
| Schema / table definitions (T-SQL current model + seed placeholders) | SYSTEM-SHARED-UI (`sql/identity/`) |
| Physical tables | **Customer database** (one catalog per customer-environment; shared by all BreezeOn product applications in that environment) |
| Login-time upsert / login insert | SYSTEM-SHARED-UI default SQL directory writer |
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
| `IsEnabled` | `BIT` NOT NULL | Default 1. Directory enablement: when `0`, login fails and no application cookie is issued. Does **not** immediately revoke existing cookies (see [session-management-standard.md](session-management-standard.md)). Login path does not mutate this column. |
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

Create a login row for every successful authentication. Update `Users.LastLoginUtc` on the same path. Do not write a successful login row when `IsEnabled = 0`.

## Audit columns (ADR-005)

`Identity.Users` and `Identity.UsersLogins` are **excepted** from mandatory transactional audit columns (`CreatedBy` / `CreatedDate` / `LastUpdatedBy` / `LastUpdatedDate`). They are platform directory / append-only login history, not ordinary business transactional entities. See [ADR-005](../../decisions/ADR-005-mandatory-transactional-audit-columns.md) and [ADR-010](../../decisions/ADR-010-platform-identity-schema.md).

## Related

- [Authentication standard](authentication-standard.md)
- [Session management standard](session-management-standard.md)
- Canonical scripts: SYSTEM-SHARED-UI `sql/identity/current_model/`
