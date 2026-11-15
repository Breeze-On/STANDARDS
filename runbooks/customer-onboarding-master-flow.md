# Customer Onboarding Master Flow

Owner: Operations

**Audience:** BreezeOn platform operators onboarding a **customer-environment** (DEV / UAT / PRD). Customer Entra administrators perform consent steps when directed.

This is the **first-class end-to-end operational SSOT** for customer onboarding — including **Customer Information Required** (intake) and the **go-live checklist**. Slice procedures remain authoritative for domain detail only; they must **not** maintain competing intake tables or go-live checklists.

| Slice | Document |
| --- | --- |
| Auth Workflows A–F | [customer-onboarding-authentication.md](../architecture/identity-and-authentication/customer-onboarding-authentication.md) |
| AuthZ Workflow G | [customer-onboarding-authorization.md](../architecture/authorization/customer-onboarding-authorization.md) |
| Hosted deploy / MI | [hosted-deployment.md](../docs/hosted-deployment.md) |
| Policy / ADRs | [Identity & Authentication](../architecture/identity-and-authentication/README.md), [Authorization](../architecture/authorization/README.md) |

Do **not** treat this document as a second SSOT for architecture or ADRs. When the sequence or checkpoints change, update this file **and** the affected slice docs / DoD in the same change set.

## Scope

- One **customer-environment** at a time (label `DEV` / `UAT` / `PRD`)
- Entra App Registration, customer admin consent, Enterprise Application (as consent result), first-login tenant discovery, admin bootstrap, optional Graph sync, smoke tests, go-live sign-off
- BreezeOn **customer-environment provisioning** (Azure App Service, SQL catalog, Managed Identity, Identity + Security schema) — **not** creating the customer’s Entra tenant

## Out of scope

- Local developer setup with `BreezeOn-LOCAL` → [local-development-standard.md](../architecture/identity-and-authentication/local-development-standard.md)
- Inventing UAT/PRD Azure resource inventories that are not yet implemented → [environments.md](../docs/environments.md), [hosted-deployment.md](../docs/hosted-deployment.md)
- Multi-customer shared-infra topology decisions → [landscape.md](../architecture/landscape.md)
- Manual `Identity.Tenants` insert as a normal cutover step (login discovery is required; see Recovery appendix for exceptional troubleshooting only)

## Glossary (onboarding)

| Term | Meaning |
| --- | --- |
| Customer-environment | One customer × one env label (DEV/UAT/PRD): shared App Registration, shared Identity DB, product hosts |
| App Registration | BreezeOn-owned Entra app named `{Customer}-{ENV}` ([ADR-011](../decisions/ADR-011-app-registration-per-customer-environment.md)) |
| Enterprise Application | Service principal created **in the customer tenant** when the customer admin consents — BreezeOn does not create it directly |
| `Identity.Tenants` | Platform registry of observed/registered Entra tids + `IsSyncEnabled` — **not** a login allowlist (Entra App Registration owns allowlisting) |

## Actors (RACI)

| Actor | Owns |
| --- | --- |
| **BreezeOn Admin / Platform Ops** | Intake gate; App Registration create/name/secret; App Service `AUTHENTICATION__*`; SQL Identity/Security apply; Workflow G; hosted `IsSyncEnabled`; go-live sign-off |
| **Customer Entra Admin** | Admin consent; owns Enterprise Application in customer tenant |
| **Product Deployer** | Product base URLs; redirect URI requests; product deploy that uses shared ClientId/Secret |
| **System** | OIDC login upsert; tenant discovery (`IsSyncEnabled = 0`); Sync Now; mid-session `IsEnabled` gate |
| **Customer Application Admin** | Ongoing Users/Groups in EAC after Workflow G |

## Customer Information Required

**This Master Flow owns the intake SSOT.** Collect **before** Step 2 (App Registration). Do not create App Registrations or App Service auth settings until this checklist is complete. Slice docs link here; they do not maintain a parallel intake table.

| Input | Required | Notes |
| --- | --- | --- |
| Customer name | Yes | Used in App Registration name `{Customer}-{ENV}` |
| Environment | Yes | `DEV` / `UAT` / `PRD` |
| Customer Entra tenant ID (`tid`) | Yes | Home tenant(s) that must be allowed to sign in |
| Customer Entra administrator contact | Yes | Performs admin consent; typically the first-login / Workflow G bootstrap target |
| Product list + public HTTPS base URLs | Yes | Every product host in this customer-environment |
| Graph directory synchronization required? | Yes | `Yes` / `No` — drives Step 8 |
| BreezeOn support tenant access needed? | No | If Yes, allowlist BreezeOn home tenant on the App Registration |
| Go-live window / target date | No | Ops planning |
| Secret-expiry owner | Yes | Named BreezeOn operator responsible for rotation tracking |
| Customer database / Identity + Security schema ready? | Yes | Confirmed in Step 1 |

## Flow overview

```text
0 Intake → 1 Provision → 2 App Reg → 3 Redirects → 4 App Service auth
  → 5 Admin consent + EA → 6 First login / tenant discovery
  → 7 Bootstrap admin (Workflow G) → 8 Sync (if Graph=Yes)
  → 9 Smoke + go-live
```

**Enforcement principle (current):** OIDC login is **not** hard-blocked for incomplete onboarding. Operators must not declare an environment live, run Workflow G, or enable sync until prior checkpoints pass. Soft UI readiness indicators may warn; hard product feature gates require a future ADR.

**Operator validation queries:** [templates/onboarding/validate-onboarding-readiness.sql](../templates/onboarding/validate-onboarding-readiness.sql).

---

## Step 0 — Intake and customer information

| Field | Content |
| --- | --- |
| **Purpose** | Freeze inputs so App Registration, URLs, and sync scope are correct before Entra or Azure cutover work |
| **Responsible actor** | BreezeOn Admin (+ customer contact for tid/admin/URLs) |
| **Preconditions** | Commercial / environment decision exists for this customer-environment |
| **Actions** | Complete Customer Information Required; confirm Graph Yes/No; confirm product URL list; name secret-expiry owner |
| **Expected outcome** | Signed or dated intake record; all Required rows filled |
| **Failure scenarios and recovery** | Missing tid, admin contact, or product URLs → **stop**; do not proceed to Step 2 |
| **Checkpoint** | **Checkpoint 0** |
| **Evidence to retain** | Completed Customer Information sheet (or ticket) with date and operator name |

---

## Step 1 — Customer-environment provisioning

| Field | Content |
| --- | --- |
| **Purpose** | Runnable product hosts and platform Identity + Security schema in the customer database |
| **Responsible actor** | BreezeOn Admin / Product Deployer |
| **Preconditions** | Checkpoint 0 complete |
| **Actions** | Provision or confirm App Service(s) and SQL catalog; grant App Service Managed Identity to SQL ([templates/azure-sql/](../templates/azure-sql/)); apply SHARED-UI Identity + Security scripts to the customer DB; deploy products per [hosted-deployment.md](../docs/hosted-deployment.md). This step does **not** create the customer’s Entra tenant. |
| **Expected outcome** | HTTPS product hosts respond; `Identity.*` and `Security.*` tables present; hosts may still lack final `AUTHENTICATION__*` until Step 4 |
| **Failure scenarios and recovery** | MI / SQL connection failures → fix grant and connection string before Step 2. Missing Identity/Security schema → re-apply SHARED-UI scripts; do not start Entra cutover |
| **Checkpoint** | **Checkpoint 1** |
| **Evidence to retain** | Host URLs; confirmation Identity/Security schema applied (query pack § schema checks) |

**Note:** Identity schema readiness (this step) is distinct from tenant **discovery** on first login (Step 6).

---

## Step 2 — App Registration create / ownership (Workflow A)

| Field | Content |
| --- | --- |
| **Purpose** | Create the BreezeOn-owned Entra App Registration for this customer-environment |
| **Responsible actor** | BreezeOn Admin |
| **Preconditions** | Checkpoints 0–1; customer name + env + tid known |
| **Actions** | In the BreezeOn Entra tenant, create App Registration **`{Customer}-{ENV}`**; configure supported account types / home tenants for the customer (and optional BreezeOn support) tid(s) **in Entra**; create client secret; record secret id and expiry. Handle the secret value per **Secret handling** below. Detail: [customer-onboarding-authentication.md](../architecture/identity-and-authentication/customer-onboarding-authentication.md) Workflow A |
| **Expected outcome** | Registration exists; ClientId available; secret value transferred only via approved channels; expiry tracked by secret-expiry owner |
| **Failure scenarios and recovery** | Wrong account types → fix Entra allowlisting (not app code). Lost or compromised secret → rotate per [configuration-standard.md](../architecture/identity-and-authentication/configuration-standard.md) and Recovery appendix |
| **Checkpoint** | **Checkpoint A** |
| **Evidence to retain** | App Registration name; Application (client) ID; secret **id**; expiry date; owner — **never** the secret value |

---

## Step 3 — Redirect URIs (Workflow B)

| Field | Content |
| --- | --- |
| **Purpose** | Register OIDC callback URIs for every product in the customer-environment |
| **Responsible actor** | BreezeOn Admin (+ Product Deployer for URL truth) |
| **Preconditions** | Checkpoint A; final HTTPS base URLs known |
| **Actions** | On the same App Registration, for each product `{base}`, register `{base}/signin-oidc` and `{base}/signout-callback-oidc`. Detail: Workflow B / configuration-standard |
| **Expected outcome** | Every product has both URIs; no product uses a separate registration |
| **Failure scenarios and recovery** | AADSTS reply URL errors → fix exact HTTPS bases (no trailing slash mismatch) |
| **Checkpoint** | **Checkpoint B** |
| **Evidence to retain** | Redirect URI matrix (product → two URIs) |

---

## Step 4 — Product App Service authentication configuration (Workflow C)

| Field | Content |
| --- | --- |
| **Purpose** | Apply shared OIDC credentials on every product host |
| **Responsible actor** | BreezeOn Admin |
| **Preconditions** | Checkpoints A–B |
| **Actions** | On every product App Service set the **same** `AUTHENTICATION__AUTHORITY` (`…/organizations/v2.0`), `AUTHENTICATION__CLIENTID`, `AUTHENTICATION__CLIENTSECRET` per **Secret handling**. Never commit secrets. Detail: Workflow C |
| **Expected outcome** | All products share identical `AUTHENTICATION__*`; hosts start without auth configuration errors |
| **Failure scenarios and recovery** | Different ClientId per product → align to ADR-011. Authority without `/v2.0` → fix per configuration-standard |
| **Checkpoint** | **Checkpoint C** |
| **Evidence to retain** | Confirmation each App Service has matching ClientId/Authority and that `CLIENTSECRET` is set (presence only; secret value not logged or pasted into tickets) |

### Secret handling (current architecture)

Aligned with [configuration-standard.md](../architecture/identity-and-authentication/configuration-standard.md). Do **not** require Azure Key Vault or certificate credentials for this flow (those remain **planned / not shipped**).

| Topic | Practice |
| --- | --- |
| **Approved storage** | Hosted: Azure App Service **application settings** for `AUTHENTICATION__CLIENTSECRET` (same value on every product host in the customer-environment). Local only: .NET User Secrets / local `.env` — never for hosted DEV/UAT/PRD cutover. |
| **Approved process** | Create the client secret in the Entra portal → in the **same operator session**, paste the value directly into each product App Service setting (Entra + Azure portals side-by-side is fine). Do not store the value in intermediate files. |
| **Prohibited transmission** | Email, chat/IM, SMS, screenshots, shared docs/wikis, tickets/attachments, source control, CI logs, or any channel that retains the secret value. |
| **Rotation** | Follow configuration-standard § Client secret lifecycle: create new secret → update **every** product App Service → verify login → remove old secret after overlap. Named secret-expiry owner tracks expiry. |
| **Onboarding evidence** | Retain secret **id**, expiry date, and owner name; confirm settings exist on each host. **Never** retain the secret **value** as evidence. |

---

## Step 5 — Admin consent and Enterprise Application (Workflow D)

| Field | Content |
| --- | --- |
| **Purpose** | Establish customer trust; create Enterprise Application in the **customer** tenant via consent |
| **Responsible actor** | Customer Entra Admin (consent); BreezeOn Admin (send URL, verify) |
| **Preconditions** | Checkpoints A–C |
| **Actions** | 1. Send the customer Entra administrator the **admin consent** URL (Phase 1 — interactive / delegated as required). 2. Confirm an **Enterprise Application** appears in the **customer** tenant after consent. 3. Attempt interactive sign-in to one product host. Detail: Workflow D |
| **Expected outcome** | Consent granted; EA present in customer tenant; login reaches product callback without redirect/consent errors |
| **Failure scenarios and recovery** | Consent denied / insufficient admin role → escalate to a Global Administrator (or equivalent) in the customer tenant; re-send URL. EA missing → consent not completed; do not proceed |
| **Checkpoint** | **Checkpoint D** |
| **Evidence to retain** | Consent confirmation timestamp; EA display name / object id in customer tenant (customer-provided or screenshot); successful login note |

### Admin consent URL template (copy-paste)

Replace placeholders. Until a dedicated consent-complete page exists, `redirect_uri` may be a registered product `{base}/signin-oidc` or another URI registered on the App Registration for operator confirmation.

```text
https://login.microsoftonline.com/{customer-tid}/v2.0/adminconsent
  ?client_id={application-client-id}
  &redirect_uri={url-encoded-redirect-uri}
  &scope=.default
```

Example (single line):

```text
https://login.microsoftonline.com/aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee/v2.0/adminconsent?client_id=11111111-2222-3333-4444-555555555555&redirect_uri=https%3A%2F%2Feac-customer-dev.example%2Fsignin-oidc&scope=.default
```

**Phase 1 vs Phase 2 consent**

| Phase | When | What |
| --- | --- | --- |
| Phase 1 (this step) | Always | Interactive OIDC / admin consent so users can sign in; EA created in customer tenant |
| Phase 2 (Step 8) | Only if Graph = Yes | Application permission `User.Read.All` on the App Registration + **customer** admin consent for app-only Graph against the customer tid |

---

## Step 6 — First login and tenant discovery (Workflow E)

| Field | Content |
| --- | --- |
| **Purpose** | Confirm OIDC login upsert and **automatic** `Identity.Tenants` discovery for the customer tid |
| **Responsible actor** | System (discovery on first successful login); BreezeOn Admin (verify); designated customer admin (performs the login) |
| **Preconditions** | Checkpoint D |
| **Actions** | Have the designated customer admin complete interactive login; verify `Identity.Users`, `Identity.UsersLogins`, and `Identity.Tenants` for claim `tid`. Login discovery inserts tenants with `IsSyncEnabled = 0`. Do **not** manually insert `Identity.Tenants` as part of normal onboarding. Registration ≠ sync enablement ≠ login allowlist. Detail: Workflow E |
| **Expected outcome** | User, login history, and tenant rows exist from platform discovery; cookie session works; `IsSyncEnabled` remains `0` until Step 8 (if Graph=Yes) |
| **Failure scenarios and recovery** | No rows → check Entra allowlisting, claims, DB connectivity, `AUTHENTICATION__*`. Wrong tid blocked at Entra → fix App Registration home tenants. Missing tenant row → complete a successful login; do not invent a row in the normative path |
| **Checkpoint** | **Checkpoint E** |
| **Evidence to retain** | Query outputs for Users / UsersLogins / Tenants (or screenshots); [validate-onboarding-readiness.sql](../templates/onboarding/validate-onboarding-readiness.sql) § tenant section |

---

## Step 7 — Admin bootstrap (Workflow G)

| Field | Content |
| --- | --- |
| **Purpose** | Grant the first `GLOBAL-SYSTEM-ADMINISTRATORS` membership to the **first logged-in** admin so EAC Users Security (and Sync Now) is usable under page security |
| **Responsible actor** | BreezeOn Admin |
| **Preconditions** | Checkpoint E; Security schema + group seed applied; target admin has an `Identity.Users` row from **that** first login |
| **Actions** | Confirm `Security.Groups` contains `GLOBAL-SYSTEM-ADMINISTRATORS`; run SHARED-UI `sql/security/templates/bootstrap-global-system-administrator.sql` with `@LookupUpn` = that user’s `UserPrincipalName` (or Email). Verify the resolved user before relying on the grant. Do **not** auto-promote the first login without this explicit SQL step. Detail: [customer-onboarding-authorization.md](../architecture/authorization/customer-onboarding-authorization.md) |
| **Expected outcome** | Named admin opens EAC `/users` (after re-login or authZ cache expiry — see below) |
| **Failure scenarios and recovery** | Wrong UPN → fix `@LookupUpn` and re-run (or remove wrong membership — Recovery appendix). Multiple rows match lookup → **stop**; insert by explicit `UserGUID` (exceptional). Missing group seed → apply Security seed. Never seed hosted memberships via product seed by default |
| **Checkpoint** | **Checkpoint G** |
| **Evidence to retain** | Bootstrap `@LookupUpn` used; operator name + date; confirmation admin accessed `/users` |

**Authorization cache:** SHARED-UI caches group memberships for about **60 seconds** per user. After SQL bootstrap, the admin may need to **sign out and sign in again**, or wait up to ~60s, before `/users` authorization succeeds. Access Denied immediately after bootstrap is often cache lag, not a failed grant.

**Local sandbox exception:** EAC `dev-reset` / local bootstrap may grant admins automatically — **local only**; never default-apply to hosted DEV/UAT/PRD.

---

## Step 8 — User synchronization prerequisites (Workflow F)

Run **only** when Customer Information lists Graph synchronization = **Yes**. If Graph = **No**, skip sync enablement; record **Checkpoint F-N/A** on the go-live sheet (deliberate sign-off that sync is not required). Soft readiness indicators on EAC `/users` may still show attention when no sync-enabled tenants exist (Graph=No) until a later product change; that does **not** block F-N/A go-live sign-off.

| Field | Content |
| --- | --- |
| **Purpose** | Enable Microsoft Graph directory sync for Users Security |
| **Responsible actor** | BreezeOn Admin (App Reg permission + SQL); Customer Entra Admin (application permission consent); System (Sync Now); bootstrapped admin (runs Sync Now in EAC) |
| **Preconditions** | Checkpoint G (so `/users` and Sync Now are reachable under page security); Checkpoint E tenant row exists from login discovery; Identity schema present |
| **Actions** | Add application permission `User.Read.All` on the App Registration; obtain **customer** admin consent for app-only Graph; set `IsSyncEnabled = 1` for the **discovered** customer tid via SQL (hosted — never `IDENTITY__SEEDTENANTIDS` on App Services); bootstrapped admin runs **Sync Now** in EAC. Detail: Workflow F |
| **Expected outcome** | Consent granted; Sync Now Succeeded; Users grid reflects Graph `accountEnabled` → `IsEnabled` |
| **Failure scenarios and recovery** | Graph 403 → missing `User.Read.All` or customer app consent. “No sync-enabled tenant” → set `IsSyncEnabled = 1` on the discovered row. Soft-disable surprises → review directory-sync + session standards. Access Denied on `/users` → return to Step 7 |
| **Checkpoint** | **Checkpoint F** (or **F-N/A**) |
| **Evidence to retain** | Sync Now Succeeded (or F-N/A sign-off); SQL `IsSyncEnabled` confirmation |

---

## Step 9 — Validation, smoke-testing, and go-live

| Field | Content |
| --- | --- |
| **Purpose** | Repeatable sign-off that the customer-environment is ready for operational use |
| **Responsible actor** | BreezeOn Admin (+ Customer Entra Admin confirmation of consent) |
| **Preconditions** | Checkpoints 0–1, A–E, G, F or F-N/A |
| **Actions** | Run go-live checklist below; optional second product login; run validation SQL pack; record sign-off |
| **Expected outcome** | Environment marked live for ops handover; evidence retained |
| **Failure scenarios and recovery** | Any red checkpoint → **no go-live**; return to owning step |
| **Checkpoint** | **Checkpoint Go-Live** |
| **Evidence to retain** | Completed checklist; validation query outputs; sign-off name/date; customer consent confirmation |

### Go-live readiness checklist

**This Master Flow owns the only go-live checklist.** Slice docs link here instead of duplicating checkboxes.

- [ ] Checkpoint 0 — Intake complete
- [ ] Checkpoint 1 — Hosts + Identity/Security schema
- [ ] Checkpoint A — App Registration + secret id/expiry/owner tracked (value not retained)
- [ ] Checkpoint B — All product redirect URIs
- [ ] Checkpoint C — Shared `AUTHENTICATION__*` on all products (secret handling followed)
- [ ] Checkpoint D — Customer consent + Enterprise Application + interactive login
- [ ] Checkpoint E — Identity Users / UsersLogins / Tenants evidence (login discovery)
- [ ] Checkpoint G — Named admin in `GLOBAL-SYSTEM-ADMINISTRATORS`; `/users` accessible
- [ ] Checkpoint F — Graph sync + Sync Now Succeeded **or** Checkpoint F-N/A (Graph not required) signed
- [ ] Optional: second product host login with same ClientId
- [ ] Optional: login-time profile photo best-effort (does not block go-live)
- [ ] Secret expiry recorded; support contacts recorded
- [ ] Validation SQL pack reviewed ([validate-onboarding-readiness.sql](../templates/onboarding/validate-onboarding-readiness.sql))
- [ ] **Sign-off:** BreezeOn operator name + date
- [ ] **Sign-off:** Customer Entra admin confirmation of consent (name + date)

---

## Failure catalog (consolidated)

| Symptom | Likely cause | Recovery |
| --- | --- | --- |
| Cannot start Entra work | Incomplete intake | Step 0 |
| App Service cannot reach SQL | MI / connection string | Step 1; azure-sql templates |
| Missing `Identity.*` / `Security.*` | Schema not applied | Step 1 |
| AADSTS redirect / reply URL | Missing/wrong URI | Step 3 |
| Consent / access denied | EA not consented | Step 5; confirm admin role |
| IDX / authority / issuer errors | Wrong Authority | Step 4; use `organizations/v2.0` |
| Wrong tenant blocked at Entra | Home tenant not allowlisted | Step 2 (Entra, not app code) |
| Login fails: `IsEnabled = 0` | Soft-disable or directory disable | Check `Identity.Users`; re-sync or Graph `accountEnabled` |
| Admin cannot open `/users` | Not in GSA / wrong UserGUID / authZ cache | Step 7; re-login or wait ~60s |
| Missing `GLOBAL-SYSTEM-ADMINISTRATORS` group | Security seed not applied | Step 1 / Security seed |
| Sync Now Graph 403 | Missing `User.Read.All` or customer app consent | Step 8 |
| Sync Now “no sync-enabled tenant” | All `IsSyncEnabled = 0` | Step 8 SQL |
| Hosted seed confusion | `IDENTITY__SEEDTENANTIDS` on App Service | Remove; SQL enablement only |

---

## Recovery appendix (concise)

Use after go-live or when a step fails in a recoverable way. Normative cutover still follows Steps 0–9.

### Incorrect administrator assignment

1. Identify the wrong `UserGUID` in `Security.GroupsMembers` for `GLOBAL-SYSTEM-ADMINISTRATORS`.
2. `DELETE` that membership row (operator SQL; retain ticket evidence).
3. Confirm the correct admin has an `Identity.Users` row from login (Step 6).
4. Re-run Workflow G bootstrap with the correct `@LookupUpn`.

### Re-bootstrap procedure

- Template is idempotent for the same `(GroupGUID, UserGUID)`.
- Target admin must have logged in at least once (Checkpoint E).
- After SQL, admin re-logins or waits ~60s for authZ cache.

### Consent revocation

- Customer removes admin consent / Enterprise Application grants in their tenant → interactive login and/or Graph app-only calls fail until re-consent.
- Re-run Workflow D (Phase 1) and, if Graph=Yes, Phase 2 consent in Step 8.
- Do not invent workarounds in application code.

### Secret compromise remediation

- Follow [configuration-standard.md](../architecture/identity-and-authentication/configuration-standard.md) emergency revocation: create a new secret → update **every** product App Service `AUTHENTICATION__CLIENTSECRET` → verify login → delete/disable the compromised secret in Entra.
- Force re-authentication as needed. Update secret id/expiry/owner evidence; never store the new value in tickets.

### Break-glass (no remaining GSA members)

1. Have a known trusted user complete interactive login (creates/updates `Identity.Users`).
2. Operator runs Workflow G SQL bootstrap for that user.
3. Do **not** apply EAC local `dev-reset` / `IDENTITY__SEEDTENANTIDS` / LocalDirectoryBootstrap to hosted DEV/UAT/PRD.

### Manual `Identity.Tenants` insert (exceptional only)

**Not** part of normal onboarding. Login discovery (Step 6) is required. Manual insert is reserved for internal troubleshooting, local seed/test, or a future multi-tenant admin exception — document the ticket and prefer fixing login/discovery instead.

---

## Auditability (process)

Retain for each customer-environment onboarding:

1. Customer Information sheet (Step 0)
2. App Registration name, ClientId, secret id + expiry, owner (Step 2) — not the secret value
3. Redirect URI matrix (Step 3)
4. Consent confirmation timestamp + EA evidence (Step 5)
5. Checkpoint E/G/F query outputs or screenshots (Steps 6–8)
6. Go-live checklist with operator + customer sign-off (Step 9)

No dedicated onboarding audit schema is required for the current process.

## Enforcement (current vs planned)

| Layer | Status |
| --- | --- |
| Master Flow checkpoints + go-live sign-off | **Current** — required before declaring live |
| Operator SQL validation pack | **Current** — [templates/onboarding/](../templates/onboarding/) |
| Runtime `IsEnabled` / Sync Now fail-closed / page security | **Current** — not a full onboarding state machine |
| EAC soft readiness indicators on `/users` | **Current** when SHARED-UI readiness queries are registered (read-only; does not block login; Graph=No may still show attention — see Step 8) |
| Automated consent probe, self-service wizard, cross-env dashboard, hard feature gates | **Planned / not shipped** — [future-roadmap.md](../architecture/identity-and-authentication/future-roadmap.md) |

## Notes for operators

- Standardize `adminconsent` `redirect_uri` on a registered product callback until a dedicated consent-complete page exists.
- Graph = No still requires explicit **F-N/A** on the go-live sheet.
- UAT/PRD follow the same step pattern; use real hostnames from product/architecture docs only when those hosts exist.
- After go-live, secret rotation and session revocation follow configuration-standard and session-management-standard (not this flow’s happy path).

## Related

- [Customer authentication onboarding](../architecture/identity-and-authentication/customer-onboarding-authentication.md) (Workflows A–F)
- [Customer onboarding — authorization](../architecture/authorization/customer-onboarding-authorization.md) (Workflow G)
- [Directory synchronization standard](../architecture/identity-and-authentication/directory-synchronization-standard.md)
- [Configuration standard](../architecture/identity-and-authentication/configuration-standard.md)
- [hosted-deployment.md](../docs/hosted-deployment.md)
- [ADR-011](../decisions/ADR-011-app-registration-per-customer-environment.md) · [ADR-013](../decisions/ADR-013-microsoft-graph-directory-synchronization.md) · [ADR-014](../decisions/ADR-014-platform-authorization.md)
