# Customer Onboarding Master Flow

Owner: Operations

**Audience:** BreezeOn platform operators onboarding a **customer-environment** (DEV / UAT / PRD). Customer Entra administrators perform consent steps when directed.

This is the **first-class end-to-end operational SSOT** for customer onboarding. Slice procedures remain authoritative for their domains:

| Slice | Document |
| --- | --- |
| Auth Workflows A–F | [customer-onboarding-authentication.md](../architecture/identity-and-authentication/customer-onboarding-authentication.md) |
| AuthZ Workflow G | [customer-onboarding-authorization.md](../architecture/authorization/customer-onboarding-authorization.md) |
| Hosted deploy / MI | [hosted-deployment.md](../docs/hosted-deployment.md) |
| Policy / ADRs | [Identity & Authentication](../architecture/identity-and-authentication/README.md), [Authorization](../architecture/authorization/README.md) |

Do **not** treat this document as a second SSOT for architecture or ADRs. When the sequence or checkpoints change, update this file **and** the affected slice docs / DoD in the same change set.

## Scope

- One **customer-environment** at a time (label `DEV` / `UAT` / `PRD`)
- Entra App Registration, customer admin consent, Enterprise Application (as consent result), BreezeOn Identity tenant registration, optional Graph sync, admin bootstrap, smoke tests, go-live sign-off
- BreezeOn **customer-environment provisioning** (Azure App Service, SQL catalog, Managed Identity, Identity + Security schema) — **not** creating the customer’s Entra tenant

## Out of scope

- Local developer setup with `BreezeOn-LOCAL` → [local-development-standard.md](../architecture/identity-and-authentication/local-development-standard.md)
- Inventing UAT/PRD Azure resource inventories that are not yet implemented → [environments.md](../docs/environments.md), [hosted-deployment.md](../docs/hosted-deployment.md)
- Multi-customer shared-infra topology decisions → [landscape.md](../architecture/landscape.md)

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
| **BreezeOn Admin / Platform Ops** | Intake gate; App Registration create/name/secret; App Service `AUTHENTICATION__*`; SQL Identity/Security apply; hosted `IsSyncEnabled`; Workflow G; go-live sign-off |
| **Customer Entra Admin** | Admin consent; owns Enterprise Application in customer tenant |
| **Product Deployer** | Product base URLs; redirect URI requests; product deploy that uses shared ClientId/Secret |
| **System** | OIDC login upsert; tenant discovery (`IsSyncEnabled = 0`); Sync Now; mid-session `IsEnabled` gate |
| **Customer Application Admin** | Ongoing Users/Groups in EAC after Workflow G |

## Customer Information Required

Collect **before** Step 2 (App Registration). Do not create App Registrations or App Service auth settings until this checklist is complete.

| Input | Required | Notes |
| --- | --- | --- |
| Customer name | Yes | Used in App Registration name `{Customer}-{ENV}` |
| Environment | Yes | `DEV` / `UAT` / `PRD` |
| Customer Entra tenant ID (`tid`) | Yes | Home tenant(s) that must be allowed to sign in |
| Customer Entra administrator contact | Yes | Performs admin consent |
| Product list + public HTTPS base URLs | Yes | Every product host in this customer-environment |
| Graph directory synchronization required? | Yes | `Yes` / `No` — drives Step 7 |
| BreezeOn support tenant access needed? | No | If Yes, allowlist BreezeOn home tenant on the App Registration |
| Go-live window / target date | No | Ops planning |
| Secret-expiry owner | Yes | Named BreezeOn operator responsible for rotation tracking |
| Customer database / Identity + Security schema ready? | Yes | Confirmed in Step 1 |

## Flow overview

```text
0 Intake → 1 Provision → 2 App Reg → 3 Redirects → 4 App Service auth
  → 5 Admin consent + EA → 6 Tenant registration → 7 Sync (if Graph=Yes)
  → 8 Bootstrap admin → 9 Smoke + go-live
```

**Enforcement principle (current):** OIDC login is **not** hard-blocked for incomplete onboarding. Operators must not declare an environment live, enable sync, or run Workflow G until prior checkpoints pass. Soft UI readiness indicators may warn; hard product feature gates require a future ADR.

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
| **Actions** | In the BreezeOn Entra tenant, create App Registration **`{Customer}-{ENV}`**; configure supported account types / home tenants for the customer (and optional BreezeOn support) tid(s) **in Entra**; create client secret; record secret id and expiry. Detail: [customer-onboarding-authentication.md](../architecture/identity-and-authentication/customer-onboarding-authentication.md) Workflow A |
| **Expected outcome** | Registration exists; ClientId and secret available to operators; expiry tracked by secret-expiry owner |
| **Failure scenarios and recovery** | Wrong account types → fix Entra allowlisting (not app code). Lost secret → rotate per [configuration-standard.md](../architecture/identity-and-authentication/configuration-standard.md) |
| **Checkpoint** | **Checkpoint A** |
| **Evidence to retain** | App Registration name; Application (client) ID; secret id; expiry date; owner |

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
| **Actions** | On every product App Service set the **same** `AUTHENTICATION__AUTHORITY` (`…/organizations/v2.0`), `AUTHENTICATION__CLIENTID`, `AUTHENTICATION__CLIENTSECRET`. Never commit secrets. Detail: Workflow C |
| **Expected outcome** | All products share identical `AUTHENTICATION__*`; hosts start without auth configuration errors |
| **Failure scenarios and recovery** | Different ClientId per product → align to ADR-011. Authority without `/v2.0` → fix per configuration-standard |
| **Checkpoint** | **Checkpoint C** |
| **Evidence to retain** | Confirmation each App Service setting matches (ClientId equal across products; secret not logged) |

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
| Phase 2 (Step 7) | Only if Graph = Yes | Application permission `User.Read.All` on the App Registration + **customer** admin consent for app-only Graph against the customer tid |

---

## Step 6 — Tenant registration within BreezeOn (Workflow E)

| Field | Content |
| --- | --- |
| **Purpose** | Register the customer Entra tid in `Identity.Tenants` and confirm login upsert |
| **Responsible actor** | System (discovery on first successful login); BreezeOn Admin (optional explicit SQL insert when sync must run before any login) |
| **Preconditions** | Checkpoint D |
| **Actions** | Complete interactive login; verify `Identity.Users`, `Identity.UsersLogins`, `Identity.Tenants` for claim `tid`. Login discovery inserts tenants with `IsSyncEnabled = 0`. Registration ≠ sync enablement ≠ login allowlist. Detail: Workflow E |
| **Expected outcome** | User, login history, and tenant rows exist; cookie session works; `IsSyncEnabled` remains `0` unless Step 7 ran |
| **Failure scenarios and recovery** | No rows → check Entra allowlisting, claims, DB connectivity, `AUTHENTICATION__*`. Wrong tid blocked at Entra → fix App Registration home tenants |
| **Checkpoint** | **Checkpoint E** |
| **Evidence to retain** | Query outputs for Users / UsersLogins / Tenants (or screenshots); [validate-onboarding-readiness.sql](../templates/onboarding/validate-onboarding-readiness.sql) § tenant section |

---

## Step 7 — User synchronization prerequisites (Workflow F)

Run **only** when Customer Information lists Graph synchronization = **Yes**. If Graph = **No**, skip sync enablement; record **Checkpoint F-N/A** on the go-live sheet (deliberate sign-off that sync is not required).

| Field | Content |
| --- | --- |
| **Purpose** | Enable Microsoft Graph directory sync for Users Security |
| **Responsible actor** | BreezeOn Admin (App Reg permission + SQL); Customer Entra Admin (application permission consent); System (Sync Now) |
| **Preconditions** | Checkpoint E (or explicit tenant row); Identity schema present |
| **Actions** | Add application permission `User.Read.All` on the App Registration; obtain **customer** admin consent for app-only Graph; set `IsSyncEnabled = 1` for the customer tid via SQL (hosted — never `IDENTITY__SEEDTENANTIDS` on App Services); run **Sync Now** in EAC. Detail: Workflow F |
| **Expected outcome** | Consent granted; Sync Now Succeeded; Users grid reflects Graph `accountEnabled` → `IsEnabled` |
| **Failure scenarios and recovery** | Graph 403 → missing `User.Read.All` or customer app consent. “No sync-enabled tenant” → set `IsSyncEnabled = 1`. Soft-disable surprises → review directory-sync + session standards |
| **Checkpoint** | **Checkpoint F** (or **F-N/A**) |
| **Evidence to retain** | Sync Now Succeeded (or F-N/A sign-off); SQL `IsSyncEnabled` confirmation |

---

## Step 8 — Admin bootstrap (Workflow G)

| Field | Content |
| --- | --- |
| **Purpose** | Grant the first `GLOBAL-SYSTEM-ADMINISTRATORS` membership so EAC Users Security is usable |
| **Responsible actor** | BreezeOn Admin |
| **Preconditions** | Authentication onboarding through Checkpoint E (and F if Graph=Yes); Security schema + group seed applied; target admin has `Identity.Users` row (`UserGUID`) from login or Sync Now |
| **Actions** | Confirm `Security.Groups` contains `GLOBAL-SYSTEM-ADMINISTRATORS`; run SHARED-UI `sql/security/templates/bootstrap-global-system-administrator.sql` (or equivalent) by **UserGUID**. Do **not** auto-promote the first login. Detail: [customer-onboarding-authorization.md](../architecture/authorization/customer-onboarding-authorization.md) |
| **Expected outcome** | Named admin opens EAC `/users` and can run Sync Now (when page security is enabled) |
| **Failure scenarios and recovery** | Wrong UPN / UserGUID → fix lookup and re-run. Missing group seed → apply Security seed. Never seed hosted memberships via product seed by default |
| **Checkpoint** | **Checkpoint G** |
| **Evidence to retain** | Bootstrap SQL parameters used (UPN/UserGUID); confirmation admin accessed `/users` |

**Local sandbox exception:** EAC `dev-reset` / local bootstrap may grant admins automatically — **local only**; never default-apply to hosted DEV/UAT/PRD.

---

## Step 9 — Validation, smoke-testing, and go-live

| Field | Content |
| --- | --- |
| **Purpose** | Repeatable sign-off that the customer-environment is ready for operational use |
| **Responsible actor** | BreezeOn Admin (+ Customer Entra Admin confirmation of consent) |
| **Preconditions** | Checkpoints 0–1, A–E, F or F-N/A, G |
| **Actions** | Run go-live checklist below; optional second product login; run validation SQL pack; record sign-off |
| **Expected outcome** | Environment marked live for ops handover; evidence retained |
| **Failure scenarios and recovery** | Any red checkpoint → **no go-live**; return to owning step |
| **Checkpoint** | **Checkpoint Go-Live** |
| **Evidence to retain** | Completed checklist; validation query outputs; sign-off name/date; customer consent confirmation |

### Go-live readiness checklist

- [ ] Checkpoint 0 — Intake complete
- [ ] Checkpoint 1 — Hosts + Identity/Security schema
- [ ] Checkpoint A — App Registration + secret tracked
- [ ] Checkpoint B — All product redirect URIs
- [ ] Checkpoint C — Shared `AUTHENTICATION__*` on all products
- [ ] Checkpoint D — Customer consent + Enterprise Application + interactive login
- [ ] Checkpoint E — Identity Users / UsersLogins / Tenants evidence
- [ ] Checkpoint F — Graph sync + Sync Now Succeeded **or** Checkpoint F-N/A (Graph not required) signed
- [ ] Checkpoint G — Named admin in `GLOBAL-SYSTEM-ADMINISTRATORS`; `/users` accessible
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
| Sync Now Graph 403 | Missing `User.Read.All` or customer app consent | Step 7 |
| Sync Now “no sync-enabled tenant” | All `IsSyncEnabled = 0` | Step 7 SQL |
| Hosted seed confusion | `IDENTITY__SEEDTENANTIDS` on App Service | Remove; SQL enablement only |
| Admin cannot open `/users` | Not in GSA / wrong UserGUID | Step 8 |
| Missing `GLOBAL-SYSTEM-ADMINISTRATORS` group | Security seed not applied | Step 1 / Security seed |

---

## Auditability (process)

Retain for each customer-environment onboarding:

1. Customer Information sheet (Step 0)
2. App Registration name, ClientId, secret id + expiry, owner (Step 2)
3. Redirect URI matrix (Step 3)
4. Consent confirmation timestamp + EA evidence (Step 5)
5. Checkpoint E/F/G query outputs or screenshots (Steps 6–8)
6. Go-live checklist with operator + customer sign-off (Step 9)

No dedicated onboarding audit schema is required for the current process.

## Enforcement (current vs planned)

| Layer | Status |
| --- | --- |
| Master Flow checkpoints + go-live sign-off | **Current** — required before declaring live |
| Operator SQL validation pack | **Current** — [templates/onboarding/](../templates/onboarding/) |
| Runtime `IsEnabled` / Sync Now fail-closed / page security | **Current** — not a full onboarding state machine |
| EAC soft readiness indicators on `/users` | **Current** when SHARED-UI readiness queries are registered (read-only; does not block login) |
| Automated consent probe, self-service wizard, cross-env dashboard, hard feature gates | **Planned / not shipped** — [future-roadmap.md](../architecture/identity-and-authentication/future-roadmap.md) |

## Notes for operators

- Standardize `adminconsent` `redirect_uri` on a registered product callback until a dedicated consent-complete page exists.
- Graph = No still requires explicit **F-N/A** on the go-live sheet.
- UAT/PRD follow the same step pattern; use real hostnames from product/architecture docs only when those hosts exist.
- After go-live, secret rotation and session revocation follow configuration-standard and session-management-standard (not this flow).

## Related

- [Customer authentication onboarding](../architecture/identity-and-authentication/customer-onboarding-authentication.md) (Workflows A–F)
- [Customer onboarding — authorization](../architecture/authorization/customer-onboarding-authorization.md) (Workflow G)
- [Directory synchronization standard](../architecture/identity-and-authentication/directory-synchronization-standard.md)
- [Configuration standard](../architecture/identity-and-authentication/configuration-standard.md)
- [hosted-deployment.md](../docs/hosted-deployment.md)
- [ADR-011](../decisions/ADR-011-app-registration-per-customer-environment.md) · [ADR-013](../decisions/ADR-013-microsoft-graph-directory-synchronization.md) · [ADR-014](../decisions/ADR-014-platform-authorization.md)
