# Customer authentication onboarding

Owner: Architecture

**Audience:** BreezeOn platform operators onboarding a **customer-environment** (DEV / UAT / PRD).

This is an **operational runbook**. Architecture and policy remain in the linked standards and ADRs — do not treat this document as a second SSOT for those topics.

**Out of scope**

- Local developer setup with `BreezeOn-LOCAL` → [local-development-standard.md](local-development-standard.md)
- Azure SQL Managed Identity / App Service deploy mechanics → [hosted-deployment.md](../../docs/hosted-deployment.md)

## Customer Information Required

Collect **before** starting. Do not create App Registrations or App Service settings until this checklist is complete.

| Input | Required | Notes |
| --- | --- | --- |
| Customer name | Yes | Used in App Registration name `{Customer}-{ENV}` |
| Environment | Yes | `DEV` / `UAT` / `PRD` |
| Customer Entra tenant ID (`tid`) | Yes | Home tenant(s) that must be allowed to sign in |
| Customer Entra administrator contact | Yes | Performs admin consent; owns Enterprise Application in their tenant |
| Product list + public HTTPS base URLs | Yes | Every product host in this customer-environment (redirect URI set) |
| Graph directory synchronization required? | Yes | `Yes` / `No` — drives Phase 2 (`User.Read.All`, `IsSyncEnabled`, Sync Now) |
| BreezeOn support tenant access needed? | No | If BreezeOn users must sign into this customer-environment, allowlist that home tenant on the App Registration |
| Customer database / Identity schema ready? | Yes | Catalog exists; platform `Identity.*` scripts applied ([identity-schema-standard.md](identity-schema-standard.md)) |

## Ownership boundaries

| Role | Owns |
| --- | --- |
| BreezeOn platform ops | App Registration create/name/secret; App Service `AUTHENTICATION__*` on all products; hosted `IsSyncEnabled` SQL; secret rotation |
| Customer Entra administrator | Admin consent; Enterprise Application in customer tenant |
| Product deployer | Product base URLs; redirect URI registration requests; deploy that uses shared ClientId/Secret |

Model summary (do not restate tables here): one App Registration per `{Customer}-{ENV}`, shared auth settings, shared Identity DB, separate product cookies — [cloud-architecture.md](cloud-architecture.md), [ADR-011](../../decisions/ADR-011-app-registration-per-customer-environment.md).

---

## Workflow A — Create App Registration

1. In the BreezeOn Entra tenant, create an App Registration named **`{Customer}-{ENV}`** (example: `Contoso-DEV`).
2. Configure supported account types / home tenants so the customer (and optional BreezeOn support) tid(s) may sign in — **in Entra**, not in application code ([cloud-architecture.md](cloud-architecture.md)).
3. Create a **client secret**; record secret id and expiry for rotation tracking ([configuration-standard.md](configuration-standard.md)).
4. Note the **Application (client) ID** for App Service settings.

**Checkpoint A:** Registration exists; ClientId and secret are available to operators; expiry is tracked.

## Workflow B — Redirect URIs

On the **same** App Registration, for **each** product base URL `{base}` in this customer-environment, register:

- `{base}/signin-oidc`
- `{base}/signout-callback-oidc`

Details and examples: [configuration-standard.md](configuration-standard.md) § Redirect URIs.

**Checkpoint B:** Every product in the env has both URIs; no product uses a separate registration.

## Workflow C — Product App Service configuration

On **every** product App Service in this customer-environment, set the **same** values:

| Setting | Value |
| --- | --- |
| `AUTHENTICATION__AUTHORITY` | `https://login.microsoftonline.com/organizations/v2.0` |
| `AUTHENTICATION__CLIENTID` | Shared App Registration client ID |
| `AUTHENTICATION__CLIENTSECRET` | Shared client secret |

Never commit secrets to source control. Do not use a different ClientId per product.

**Checkpoint C:** All products in the env share identical `AUTHENTICATION__*` settings; host starts without auth configuration errors.

## Workflow D — Customer admin consent (interactive / Phase 1)

1. Send the customer Entra administrator the consent request for this App Registration (interactive OIDC / delegated sign-in as required by Entra).
2. Confirm an **Enterprise Application** appears in the **customer** tenant after consent ([business-vision.md](business-vision.md), [cloud-architecture.md](cloud-architecture.md)).
3. Attempt interactive sign-in to one product host; complete Entra challenge and OIDC callback.

**Checkpoint D:** Login reaches the product host callback without redirect/consent errors.

## Workflow E — First login validation

After a successful interactive login, verify in the **customer** database:

| Check | Expectation |
| --- | --- |
| `Identity.Users` | Row for `(TenantId, ExternalObjectId)` from claims; new insert has `IsEnabled = 1` |
| `Identity.UsersLogins` | Successful login row (`IsSuccessful = 1`) |
| `Identity.Tenants` | Row for claim `tid` (**discovered**); `IsSyncEnabled` remains `0` unless Workflow F ran |
| Application cookie | Session established; protected routes work |

Login behaviour SSOT: [authentication-standard.md](authentication-standard.md). Session policy: [session-management-standard.md](session-management-standard.md), [ADR-012](../../decisions/ADR-012-cookie-session-management.md).

**Checkpoint E:** User, login history, and tenant discovery rows exist; cookie session works.

## Workflow F — Optional Graph enablement (Phase 2)

Run **only** when Customer Information lists Graph synchronization = **Yes**.

1. On the App Registration, add application permission **`User.Read.All`** and obtain **admin consent** (customer and/or BreezeOn as required by your consent model) — [configuration-standard.md](configuration-standard.md), [directory-synchronization-standard.md](directory-synchronization-standard.md), [ADR-013](../../decisions/ADR-013-microsoft-graph-directory-synchronization.md).
2. Confirm platform Identity schema (including `Identity.Tenants`) is present in the customer database.
3. Enable sync for the known customer tid (hosted — explicit SQL only):

```sql
UPDATE [Identity].[Tenants]
SET [IsSyncEnabled] = 1
WHERE [TenantId] = '<entra-tid>';
```

4. If the tenant row does not exist yet, either obtain the tid and insert/enable after first login (Workflow E), or insert the tenant row then set `IsSyncEnabled = 1` per directory-sync standard.
5. In EAC (or future admin surface), run **Sync Now**; confirm status Succeeded and users reflect Graph `accountEnabled` → `IsEnabled`.
6. Do **not** set `IDENTITY__SEEDTENANTIDS` on hosted App Services.

**Checkpoint F:** Consent granted; enabled tenant syncs; Users grid shows directory users; SoftDisable / mid-session `IsEnabled` behaviour understood ([session-management-standard.md](session-management-standard.md)).

---

## Verification checklist

Use as a final sign-off for the customer-environment:

- [ ] Customer Information Required complete
- [ ] Checkpoint A — App Registration + secret
- [ ] Checkpoint B — All product redirect URIs
- [ ] Checkpoint C — Shared `AUTHENTICATION__*` on all products
- [ ] Checkpoint D — Customer consent + interactive login
- [ ] Checkpoint E — Identity Users / UsersLogins / Tenants
- [ ] Checkpoint F — Graph sync (if required) + Sync Now
- [ ] Optional: second product host login with same ClientId
- [ ] Optional: login-time profile photo best-effort (does not block login)

## Troubleshooting

| Symptom | Likely cause | Action |
| --- | --- | --- |
| AADSTS redirect / reply URL error | Missing or wrong `{base}/signin-oidc` | Fix Workflow B; match exact HTTPS base |
| Consent / access denied | Enterprise Application not consented | Repeat Workflow D; confirm admin role |
| IDX / authority / issuer errors | Wrong Authority or non-`/v2.0` form | Use `organizations/v2.0` per configuration-standard |
| Wrong tenant blocked at Entra | Home tenant not allowed on App Registration | Adjust Entra allowlisting (not app code) |
| Login fails: `IsEnabled = 0` | Soft-disable or disabled directory user | Check `Identity.Users`; re-sync or correct Graph `accountEnabled`; mid-session rejection within ~60s after disable |
| Sync Now Graph 403 | Missing `User.Read.All` or consent | Workflow F step 1 |
| Sync Now “no sync-enabled tenant” | `IsSyncEnabled = 0` for all rows | Workflow F step 3 |
| Hosted seed confusion | `IDENTITY__SEEDTENANTIDS` on App Service | Remove; use SQL enablement only |

## Ongoing operations

- **Secret rotation / emergency revocation:** [configuration-standard.md](configuration-standard.md) § Client secret lifecycle (update **every** product App Service).
- **Session revocation after disable:** within ≤ 60 seconds per instance — [session-management-standard.md](session-management-standard.md), [ADR-012](../../decisions/ADR-012-cookie-session-management.md).
- **Local development:** not this runbook — [local-development-standard.md](local-development-standard.md).

## Related

- [Business vision](business-vision.md)
- [Cloud architecture](cloud-architecture.md)
- [Configuration standard](configuration-standard.md)
- [Directory synchronization standard](directory-synchronization-standard.md)
- [Authentication standard](authentication-standard.md)
- [Session management standard](session-management-standard.md)
- [ADR-011](../../decisions/ADR-011-app-registration-per-customer-environment.md)
- [ADR-012](../../decisions/ADR-012-cookie-session-management.md)
- [ADR-013](../../decisions/ADR-013-microsoft-graph-directory-synchronization.md)
