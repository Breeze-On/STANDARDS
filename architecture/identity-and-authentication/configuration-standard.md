# Configuration standard — authentication

Owner: Architecture

## Required environment variables

Use **uppercase** names for consistency across Azure App Service, local development, containers, and CI/CD. ASP.NET Core maps `__` to nested configuration.

| Variable | Required | Expected / source |
| --- | --- | --- |
| `AUTHENTICATION__AUTHORITY` | Yes | `https://login.microsoftonline.com/organizations/v2.0` |
| `AUTHENTICATION__CLIENTID` | Yes | App Registration application (client) ID |
| `AUTHENTICATION__CLIENTSECRET` | Yes | App Registration client secret |

- Authority is **required configuration**. Do **not** hard-code authority URLs in SYSTEM-SHARED-UI or product applications.
- Use the **`/v2.0`** Authority form. Multi-tenant Authority (`organizations` / `common`) publishes issuer `.../{tenantid}/v2.0`; the shared framework validates the concrete tenant GUID issuer from the ID token (IDX10205 otherwise).
- There is **no** `AUTHENTICATION__TENANTID`. Sync target selection uses `Identity.Tenants.IsSyncEnabled`, not an authentication env var ([directory-synchronization-standard.md](directory-synchronization-standard.md)).
- All product hosts in the **same customer-environment** **must** use the **same** `AUTHENTICATION__AUTHORITY`, `AUTHENTICATION__CLIENTID`, and `AUTHENTICATION__CLIENTSECRET` (one App Registration per customer-environment — [cloud-architecture.md](cloud-architecture.md), [ADR-011](../../decisions/ADR-011-app-registration-per-customer-environment.md)).
- The same ClientId/Secret are used for **app-only** Microsoft Graph tokens (`https://login.microsoftonline.com/{enabledTenantId}/.default`) for directory sync and login-time profile photos. Grant application permission `User.Read.All` and obtain admin consent.
- Never commit secrets to source control.
- Never log secret values (or full connection strings that embed secrets).

Configuration section binding: `AUTHENTICATION` → `Authority`, `ClientId`, `ClientSecret`.

### Local-only Identity seed (not authentication)

| Variable | Scope | Format | Behavior |
| --- | --- | --- | --- |
| `IDENTITY__SEEDTENANTIDS` | Local `.env` / process env only | Comma-separated Entra tenant GUIDs | EAC seed upserts `Identity.Tenants` only; **every** id `IsSyncEnabled = 1`; no users seeded |

Do **not** set `IDENTITY__SEEDTENANTIDS` on hosted App Services. It is not a login allowlist.

## Hosted storage (approved)

**Azure App Service application settings** store `AUTHENTICATION__*` for hosted environments.

This remains the approved approach until a future ADR supersedes it (for example Key Vault references).

## Client secret lifecycle

Preserve client-secret credentials for the current architecture. Certificate-based client credentials are a **future** direction ([future-roadmap.md](future-roadmap.md)); do not migrate as part of routine auth work. Azure Key Vault is **not** required for this lifecycle.

| Concern | Practice |
| --- | --- |
| Expiration monitoring | Track App Registration secret expiry in Entra; alert operators before expiry |
| Rotation responsibility | BreezeOn platform operators own rotation for BreezeOn-managed registrations |
| Rotation procedure | Create a **new** secret on the App Registration; update `AUTHENTICATION__CLIENTSECRET` on **every** product App Service in that customer-environment (and local User Secrets when applicable); verify login on each product; remove the old secret after overlap |
| Overlapping credentials | Keep old and new secrets valid during cutover so in-flight instances are not interrupted |
| Emergency revocation | Delete/disable the compromised secret in Entra; deploy a replacement secret immediately on all product hosts in that customer-environment; force users to re-authenticate as needed |
| Log exposure | Do not write `ClientSecret` to logs, diagnostics dumps, or source control |

## Redirect URIs

Register **all** product host base URLs on the **single** customer-environment App Registration (exact paths match the shared endpoint mapper). Entra allows many redirect URIs on one registration.

For each product base URL `{base}`:

- `{base}/signin-oidc`
- `{base}/signout-callback-oidc`

Example (Customer A DEV with EAC + VMR):

- `https://eac-customer-a-dev.example/signin-oidc`
- `https://eac-customer-a-dev.example/signout-callback-oidc`
- `https://vmr-customer-a-dev.example/signin-oidc`
- `https://vmr-customer-a-dev.example/signout-callback-oidc`

Local multi-app redirects on `BreezeOn-LOCAL` follow the same pattern (one registration, many localhost bases) — see [local-development-standard.md](local-development-standard.md).

## Related

- [Cloud architecture](cloud-architecture.md)
- [Local development standard](local-development-standard.md)
- [Session management standard](session-management-standard.md)
- [hosted-deployment.md](../../docs/hosted-deployment.md)
