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
| `Code` | `NVARCHAR(30)` NULL UNIQUE | e.g. `GLOBAL-SYSTEM-ADMINISTRATORS` |
| `Name` | `NVARCHAR(600)` NULL | |
| `Description` | `NVARCHAR(600)` NULL | |
| `Metadata` | `NVARCHAR(250)` NULL | |
| ADR-005 audit ×4 | `NOT NULL` | |

**No `IsEnabled`.** Unused groups may be deleted.

## `Security.GroupsMembers`

| Column | Type | Notes |
| --- | --- | --- |
| `GroupsMembersId` | `INT` IDENTITY | Physical PK |
| `GroupMemberGUID` | `UNIQUEIDENTIFIER` NOT NULL UNIQUE | |
| `GroupGUID` | `UNIQUEIDENTIFIER` NOT NULL | FK → `Groups.GroupGUID` |
| `UserGUID` | `UNIQUEIDENTIFIER` NOT NULL | FK → `Identity.Users.UserGUID` |
| ADR-005 audit ×4 | `NOT NULL` | |

Unique `(GroupGUID, UserGUID)`. Indexes on `UserGUID` and `GroupGUID`.

## Seed

Idempotent seed of `GLOBAL-SYSTEM-ADMINISTRATORS` only. No memberships. Bootstrap: [customer-onboarding-authorization.md](customer-onboarding-authorization.md).
