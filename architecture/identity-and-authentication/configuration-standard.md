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
- There is **no** `AUTHENTICATION__TENANTID` in Phase 1.
- Never commit secrets to source control.

Configuration section binding: `AUTHENTICATION` → `Authority`, `ClientId`, `ClientSecret`.

## Hosted storage (approved)

**Azure App Service application settings** store `AUTHENTICATION__*` for hosted environments.

This remains the approved approach until a future ADR supersedes it (for example Key Vault references).

## Redirect URIs

Register on the App Registration (exact paths match the shared endpoint mapper):

- `{base}/signin-oidc`
- `{base}/signout-callback-oidc`

## Related

- [Cloud architecture](cloud-architecture.md)
- [Local development standard](local-development-standard.md)
- [hosted-deployment.md](../../docs/hosted-deployment.md)
