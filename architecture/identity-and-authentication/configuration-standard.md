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
- Never log secret values (or full connection strings that embed secrets).

Configuration section binding: `AUTHENTICATION` → `Authority`, `ClientId`, `ClientSecret`.

## Hosted storage (approved)

**Azure App Service application settings** store `AUTHENTICATION__*` for hosted environments.

This remains the approved approach until a future ADR supersedes it (for example Key Vault references).

## Client secret lifecycle

Preserve client-secret credentials for the current architecture. Certificate-based client credentials are a **future** direction ([future-roadmap.md](future-roadmap.md)); do not migrate as part of routine auth work. Azure Key Vault is **not** required for this lifecycle.

| Concern | Practice |
| --- | --- |
| Expiration monitoring | Track App Registration secret expiry in Entra; alert operators before expiry |
| Rotation responsibility | BreezeOn platform operators own rotation for BreezeOn-managed registrations |
| Rotation procedure | Create a **new** secret on the App Registration; update App Service `AUTHENTICATION__CLIENTSECRET` (or local User Secrets); verify login; remove the old secret after overlap |
| Overlapping credentials | Keep old and new secrets valid during cutover so in-flight instances are not interrupted |
| Emergency revocation | Delete/disable the compromised secret in Entra; deploy a replacement secret immediately; force users to re-authenticate as needed |
| Log exposure | Do not write `ClientSecret` to logs, diagnostics dumps, or source control |

## Redirect URIs

Register on the App Registration (exact paths match the shared endpoint mapper):

- `{base}/signin-oidc`
- `{base}/signout-callback-oidc`

## Related

- [Cloud architecture](cloud-architecture.md)
- [Local development standard](local-development-standard.md)
- [Session management standard](session-management-standard.md)
- [hosted-deployment.md](../../docs/hosted-deployment.md)
