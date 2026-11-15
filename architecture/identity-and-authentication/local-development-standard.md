# Local development standard — authentication

Owner: Architecture

## Principles

- **`BreezeOn-LOCAL`** is the shared local-development App Registration for **all** BreezeOn applications. It is the local instance of the platform rule: **one App Registration shared by every product** in an environment ([cloud-architecture.md](cloud-architecture.md), [ADR-011](../../decisions/ADR-011-app-registration-per-customer-environment.md)).
- Local development uses the **same OIDC Authorization Code Flow** as hosted environments.
- **No authentication bypass** and no fake/local-only login that skips Entra.

## Required local configuration

| Variable | Local value |
| --- | --- |
| `AUTHENTICATION__AUTHORITY` | `https://login.microsoftonline.com/organizations/v2.0` |
| `AUTHENTICATION__CLIENTID` | BreezeOn-LOCAL application (client) ID |
| `AUTHENTICATION__CLIENTSECRET` | BreezeOn-LOCAL client secret |

## Secrets storage

- **Primary:** .NET **User Secrets** on the product host project for ClientId and ClientSecret.
- Authority may be User Secrets or non-secret local config; it must still be present and not hard-coded.
- Do not commit ClientId/Secret to `appsettings*.json`, `.env`, or seed.

## Redirect URIs

On **BreezeOn-LOCAL**, register HTTPS localhost callbacks for **each** product app port (from `launchSettings.json`) on the **same** App Registration — the same multi-URI pattern as hosted customer-environment registrations. For example EAC:

- `https://localhost:7261/signin-oidc`
- `https://localhost:7261/signout-callback-oidc`

Add the corresponding pair for every other local product host (Gallery, future VMR, etc.). Trust the ASP.NET Core HTTPS development certificate (`dotnet dev-certs https --trust`).

## Verification workflow

1. Apply local SQL (`dev-reset.ps1`) including platform Identity **schema** from SYSTEM-SHARED-UI and optional tenant seed (`IDENTITY__SEEDTENANTIDS` → `Identity.Tenants` only; **no** `Identity.Users` seed).
2. Set the three `AUTHENTICATION__*` values (User Secrets).
3. Confirm BreezeOn-LOCAL redirect URIs match the app HTTPS URL.
4. Run the product app; browse a protected route → Entra challenge → callback.
5. Confirm `Identity.Users` upsert, `Identity.Tenants` discovery (without auto-enabling sync unless seeded), `LastLoginUtc`, and `Identity.UsersLogins` success row in local SQL.
6. Sign out via profile menu → cookie cleared + Entra end-session → re-challenge on next request.

Customer-environment (hosted) onboarding is **not** this document — use [customer-onboarding-authentication.md](customer-onboarding-authentication.md).

### Directory sync (local)

- Optional `.env` `IDENTITY__SEEDTENANTIDS=<guid>[,<guid>…]` — comma-separated **real** Entra tids. EAC `local-db-seed` / `dev-reset` upserts one `Identity.Tenants` row per id with **`IsSyncEnabled = 1` for every configured id**. **No** `Identity.Users` seed.
- Users grid fills from login and/or Graph Sync Now (avoids fake ObjectIds / duplicate rows).
- **Sync Now** remains visible; without a sync-enabled real tenant, app-only `User.Read.All` consent, or reachable Graph it fails with a clear toast.
- Never set `IDENTITY__SEEDTENANTIDS` for hosted environments; never default-apply Identity seed to Azure SQL.

No Azure App Service and no Azure SQL are required for routine local auth testing.

## Related

- [Configuration standard](configuration-standard.md)
- [Cloud architecture](cloud-architecture.md)
