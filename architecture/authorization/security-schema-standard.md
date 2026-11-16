# Security schema standard

Owner: Architecture

## Ownership

| Concern | Owner |
| --- | --- |
| Schema / table definitions | SYSTEM-SHARED-UI (`sql/security/`) |
| Physical tables | Customer database (with Identity) |
| Groups administration UI | EAC |

## `Security.Groups`

| Column | Type | Notes |
| --- | --- | --- |
| `GroupsId` | `INT` IDENTITY | Physical PK |
| `GroupGUID` | `UNIQUEIDENTIFIER` NOT NULL UNIQUE | Relationship key |
| `Code` | `NVARCHAR(700)` NULL UNIQUE | e.g. `GLOBAL-SYSTEM-ADMINISTRATORS`, `APP_{UniqueCode}`, `BUSENT_{Code}` |
| `Name` | `NVARCHAR(600)` NULL | Immutable when `IsManuallyCreated = 0` |
| `Description` | `NVARCHAR(600)` NULL | |
| `Metadata` | `NVARCHAR(250)` NULL | |
| `IsManuallyCreated` | `BIT` NOT NULL DEFAULT `1` | Lifecycle ownership SSOT: `1` manual; `0` automatic. Never flip after insert. |
| ADR-005 audit ×4 | `NOT NULL` | |

**No `IsEnabled`.** Manually created unused groups may be deleted via Groups API. Automatically created groups are **not** deleted via Groups API (`IsManuallyCreated = 0`); object-owned admin groups are removed only with their Application/BE. **`GLOBAL-SYSTEM-ADMINISTRATORS` is never deleted.**

**Code length:** `NVARCHAR(700)` supports system-generated Codes such as `APP_` + Application UniqueCode (up to 600) without capping business fields, while keeping a single-column unique index under SQL Server’s 1700-byte key limit. Uniqueness is on **`Code` only** (do not rely on a wide `Code`+`Name` composite unique key).

**System Code prefixes:** Reserve `APP_`, `BUSENT_`, and the exact Code `GLOBAL-SYSTEM-ADMINISTRATORS` against manual group create (`allowSystemOwnedCode`). That gate is independent of `IsManuallyCreated`. Membership changes remain Global System Administrator only ([ADR-015](../../decisions/ADR-015-object-owned-administrator-groups.md), [eac-authorization-matrix.md](eac-authorization-matrix.md)).

**Migration (existing DBs):** add column with DEFAULT `1`, then set `0` where Code is GSA or `APP_%` / `BUSENT_%` (one-time classifier). SHARED-UI script: `sql/security/migration_scripts/20261116_add_Groups_IsManuallyCreated.sql`.

## `Security.GroupsMembers`

| Column | Type | Notes |
| --- | --- | --- |
| `GroupsMembersId` | `INT` IDENTITY | Physical PK |
| `GroupMemberGUID` | `UNIQUEIDENTIFIER` NOT NULL UNIQUE | |
| `GroupGUID` | `UNIQUEIDENTIFIER` NOT NULL | FK → `Groups.GroupGUID` |
| `UserGUID` | `UNIQUEIDENTIFIER` NOT NULL | FK → `Identity.Users.UserGUID` |
| ADR-005 audit ×4 | `NOT NULL` | |

Unique `(GroupGUID, UserGUID)`. Indexes on `UserGUID`, `GroupGUID`, and composite `(UserGUID, GroupGUID)` for authorization joins.

## Seed

Idempotent seed of `GLOBAL-SYSTEM-ADMINISTRATORS` only. No memberships. Bootstrap: [customer-onboarding-authorization.md](customer-onboarding-authorization.md).
