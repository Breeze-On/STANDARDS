# Local development standard — authentication

Owner: Architecture

## Principles

- **`BreezeOn-LOCAL`** is the shared local-development App Registration for **all** BreezeOn applications.
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

On **BreezeOn-LOCAL**, register HTTPS localhost callbacks for each app port (from `launchSettings.json`), for example EAC:

- `https://localhost:7261/signin-oidc`
- `https://localhost:7261/signout-callback-oidc`

Trust the ASP.NET Core HTTPS development certificate (`dotnet dev-certs https --trust`).

## Verification workflow

1. Apply local SQL (`dev-reset.ps1`) including platform Identity scripts from SYSTEM-SHARED-UI.
2. Set the three `AUTHENTICATION__*` values (User Secrets).
3. Confirm BreezeOn-LOCAL redirect URIs match the app HTTPS URL.
4. Run the product app; browse a protected route → Entra challenge → callback.
5. Confirm `Identity.Users` upsert, `LastLoginUtc`, and `Identity.UsersLogins` success row in local SQL.
6. Sign out via profile menu → cookie cleared + Entra end-session → re-challenge on next request.

No Azure App Service and no Azure SQL are required for routine local auth testing.

## Related

- [Configuration standard](configuration-standard.md)
- [Cloud architecture](cloud-architecture.md)
