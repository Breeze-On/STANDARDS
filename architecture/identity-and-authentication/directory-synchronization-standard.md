# Directory synchronization standard

Owner: Architecture

Normative rules for Microsoft Graph → `Identity.Users` synchronization. Decision: [ADR-013](../../decisions/ADR-013-microsoft-graph-directory-synchronization.md).

## Ownership

| Concern | Owner |
| --- | --- |
| Graph client, synchronizer, photo refresh, user queries | SYSTEM-SHARED-UI |
| Identity SQL (`Users`, `Tenants`, `UserPhotos`, …) | SYSTEM-SHARED-UI (`sql/identity/`) |
| First admin surface (Users page, Sync Now) | EAC — consumes SHARED-UI APIs only |

## Current state (V1)

| Item | Standard |
| --- | --- |
| Trigger | Manual **Sync Now** (EAC Users); no scheduler |
| Algorithm | **Full** paged Graph `/users` enumeration (no delta) |
| Credentials | Same customer-environment App Registration; application `User.Read.All` |
| Token authority | `https://login.microsoftonline.com/{enabledTenantId}/.default` per tenant |
| Sync target | **All** `Identity.Tenants` rows with `IsSyncEnabled = 1` (sequential) |
| Enablement | Explicit SQL onboarding (no auto-enable on login; no Tenants UI) |
| Missing users | Soft-disable (`IsEnabled = 0`); never delete. Soft-disable watermark is the sync’s `@SyncStartUtc` compared to `Users.LastSyncUtc`; both must use **`datetime2`** (not legacy `datetime`) so just-upserted rows are not falsely treated as missing |
| `accountEnabled` | Graph `accountEnabled` → `Identity.Users.IsEnabled` on upsert; login path does **not** mutate `IsEnabled` |
| Photos | Not during sync — login-time only ([identity-schema-standard.md](identity-schema-standard.md) `UserPhotos`) |
| Authorization | Sync Now requires `GLOBAL-SYSTEM-ADMINISTRATORS` (Users Security page catalog) — [authorization/](../authorization/README.md) |
| Org attributes | Department / JobTitle / Manager **not** synced (deferred) |
| Targeted upsert | `IBoDirectorySynchronizer.UpsertUsersByPrincipalNamesAsync` — Graph get-by-UPN for listed accounts only; **no** soft-disable; does **not** mark a full-tenant sync succeeded. Local bootstrap / tooling only — never a substitute for Sync Now |

### Sync Now preconditions

1. If zero tenants have `IsSyncEnabled = 1` → fail with a clear message.
2. If one or more are enabled → sync each sequentially; stop and fail on the first tenant error (prior tenants keep their completed status).
3. If a sync is already `Running` for a tenant (or host gate busy) → fail (duplicate execution).

### Login discovery

Successful login upserts `Identity.Tenants` for claim `tid` and **must not** set `IsSyncEnabled`.

### Onboarding enablement (V1)

```sql
UPDATE [Identity].[Tenants]
SET [IsSyncEnabled] = 1
WHERE [TenantId] = '<entra-tid>';
```

Enable each tenant that should be synchronized. Login discovery never enables sync.

**Local development:** prefer `.env` `IDENTITY__SEEDTENANTIDS=<guid>[,<guid>…]` so EAC `local-db-seed` / `dev-reset` seeds `Identity.Tenants` only with **`IsSyncEnabled = 1` for every configured id**. Do not seed users or placeholder/fake tenant GUIDs. Hosted remains explicit SQL enablement only (no Identity seed).

## Future state

- Optional scheduled caller of the same synchronizer API (Sync Now remains)
- Optional Tenants administration UI
- Optional delta synchronization
- ~~Optional authorization for Users / Sync Now~~ — shipped via Security Groups / page security
- Optional org attribute columns when a consumer exists

## Related

- [Customer authentication onboarding](customer-onboarding-authentication.md) (Phase 2 Graph consent + `IsSyncEnabled`)
- [identity-schema-standard.md](identity-schema-standard.md)
- [authentication-standard.md](authentication-standard.md)
- [cloud-architecture.md](cloud-architecture.md)
- [ADR-013](../../decisions/ADR-013-microsoft-graph-directory-synchronization.md)
