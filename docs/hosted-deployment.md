<!-- Classification: AA; Scope: platform; Domain: Platform; Capability: Hosting -->
# Hosted deployment

Owner: Engineering

Canonical Breeze On standard for **hosted application deployment**. Product repositories must not become the source of truth for deployment procedures. Deployment standards are maintained centrally within STANDARDS and referenced by applications.

Current Reality Only: documents the **approved implementation in use today**. Future mechanisms (OIDC federated credentials, deployment slots, containers, Front Door, etc.) are absorbed here first — see [Governance](#governance).

---

## Purpose

- Give humans and AI agents **one** authoritative place for hosted deploy conventions.
- Separate **org procedure** (this document) from **product metadata** (App Service name, resource group, workflow path, app-specific checkout notes).
- Keep deploy docs scalable as more Breeze On applications are added.

---

## Scope

**In scope**

- GitHub Environment naming and secrets used for deploy
- Azure App Service configuration required for the current publish-profile path
- Workflow file naming and trigger convention
- **Full hosted deployment flow** — including **mandatory schema evolution** for data-owning apps, then publish, then smoke test
- What product repos may document vs must link here

**Out of scope**

- Local development (`dev-reset.ps1` / `dev-run.ps1`, Docker SQL) — see [local-development-scripts.md](local-development-scripts.md), [local-database.md](local-database.md)
- Application data model and end-user Identity auth / Entra customer onboarding — see [Customer Onboarding Master Flow](../runbooks/customer-onboarding-master-flow.md), [customer-onboarding-authentication.md](../runbooks/customer-onboarding-authentication.md), and product `docs/` (this document is App Service / SQL MI / schema-gate deploy, not Entra cutover)
- UAT / PRD Azure resource inventories (those hosts are not documented as implemented yet) — naming pattern only
- Multi-customer provisioning procedures — Master Flow / Identity architecture; do not invent here
- Deep migration script authorship rules — [database.md](database.md) § Platform schema evolution; this document owns the **deploy-time gate**

**In this document for data-owning apps:** App Service connection string name **`SQLAzureConnection`** and how to set it; **schema evolution before publish**. SQL Managed Identity **grant script** lives under [`templates/azure-sql/`](../templates/azure-sql/); access model: [architecture/security.md](../architecture/security.md).

---

## Hosted Deployment Principles

1. **STANDARDS owns deployment standards** — procedures, secret names, workflow conventions, App Service stack rules.
2. **Product repositories own only product-specific deployment metadata** — physical App Service name, resource group, public URL, which workflow file publishes which project, sibling-checkout needs.
3. **Do not duplicate procedures** across product READMEs, README_AI, or AGENTS.
4. **Mechanism changes land here first** — OIDC, slots, containers, Front Door, secret rotation models, etc. must update this document before adoption elsewhere.
5. **AI discovery is centralized** — agents follow [README_AI.md](../README_AI.md) and this file; they do not invent alternate deploy recipes from product repos.

---

## Environment Standards

Three layers — do **not** conflate ([environments.md](environments.md), [glossary.md](glossary.md)):

| Layer | Role in deploy |
| --- | --- |
| **Environment Label** | Lifecycle stage: **`DEV`**, **`UAT`**, **`PRD`** (seed exclusion, Azure tokens) |
| **Customer-Environment** | Isolation unit `{Customer}-{ENV}` (App Registration + customer DB + product hosts) |
| **GitHub Environment** | Product-repo deploy binding / secrets: exact names **`DEV`**, **`UAT`**, **`PRD`** |

Today’s physical DEV inventory is **both** the internal BreezeOn-operated shared DEV **and** the first implemented customer-environment — see [environments.md](environments.md) § Current DEV inventory. Do not invent multi-customer Azure inventories here.

Azure **resource** environment tokens are always **`dev`**, **`uat`**, and **`prd`** (never `dv` / `pp` / `pr`). Naming table: [naming.md](naming.md) § Environments. List physical names as they exist in product or architecture docs; legacy names (for example database `BreezeOnDV`) are exceptions until renamed.

UAT and PRD follow the **same deploy pattern** when those App Services and GitHub Environments exist. Do not invent UAT/PRD hosting inventories here until they are implemented.

---

## GitHub Environment Convention (DEV / UAT / PRD)

| Rule | Detail |
| --- | --- |
| Names | Exact: `DEV`, `UAT`, `PRD` |
| Legacy | Do not create new Environments named `DV`, `PP`, or `PR` |
| Binding | Workflow `environment:` must match the GitHub Environment name (e.g. `environment: DEV`) |
| Secrets | Live on the **Environment**, not (by default) as repository-level substitutes for this convention |

Today’s implemented hosted deploys use Environment **`DEV`**.

---

## Azure Hosted Platform (current implementation: Azure App Service)

Approved platform for hosted Blazor Interactive Server apps and the Shared UI Gallery:

| Setting | Required value / practice |
| --- | --- |
| Platform | **Azure App Service** |
| OS | **Linux** |
| Runtime stack | **.NET 10** — `DOTNETCORE\|10.0` |
| Publish path (today) | **Publish Profile** via `azure/webapps-deploy` |
| SCM / Basic auth | **Enabled** so a publish profile can be downloaded from the App Service |

Operators must set the App Service stack to **.NET 10** before expecting a successful hosted run. A mismatched stack (older .NET) breaks runtime even if zip deploy succeeds.

**SCM Basic authentication / publish-profile access** must remain enabled for the current credential model. Disable only after this standard is updated to a replacement auth strategy (see [Governance](#governance)).

Product-specific App Service names and resource groups are listed in product READMEs and [architecture/landscape.md](../architecture/landscape.md) — not repeated as procedure here.

---

## GitHub Secret Convention

| Secret name | Where | Value |
| --- | --- | --- |
| **`AZURE_WEBAPP_PUBLISH_PROFILE`** | GitHub Environment (`DEV` today; `UAT` / `PRD` when used) | Full Azure App Service **publish profile** XML |
| **`SHARED_UI_CHECKOUT_TOKEN`** | GitHub Environment (same as above), **when** the workflow checks out private `SYSTEM-SHARED-UI` | Fine-grained PAT (or GitHub App installation token) with **Contents: Read** on `Breeze-On/SYSTEM-SHARED-UI`. Pass as `token:` on that `actions/checkout` step. Default `GITHUB_TOKEN` cannot read other private repos (API returns **Not Found**). |

### Obtaining the publish profile (manual, once per App Service / Environment)

1. In Azure Portal, open the target App Service.
2. Confirm **Linux** and stack **.NET 10** (`DOTNETCORE|10.0`).
3. Ensure **SCM / Basic auth** (publish profile) access is enabled for that app.
4. Download the **Publish profile**.
5. In GitHub → repository → **Settings** → **Environments** → **`DEV`** (or UAT/PRD), create or update secret **`AZURE_WEBAPP_PUBLISH_PROFILE`** with the full XML contents.

Do not commit publish profiles to git. Do not document alternate secret names in product repos.

---

## Hosted database connection (data-owning apps)

Repo `appsettings.json` keeps **`ConnectionStrings:SQLAzureConnection`** empty. Local Docker SQL belongs in `appsettings.Development.json` under the **same key**. Hosted overrides come from Azure App Service — never commit Azure SQL connection strings.

| Step | Action |
| --- | --- |
| 1 | Enable **system-assigned Managed Identity** on the App Service (Identity → System assigned → On). |
| 2 | App Service → **Settings → Environment variables → Connection strings** (or `az webapp config connection-string set`). |
| 3 | Add name **`SQLAzureConnection`**, type **SQLAzure**, value: `Server=tcp:<sql-server>.database.windows.net,1433;Initial Catalog=<database>;Authentication=Active Directory Managed Identity;Encrypt=True;TrustServerCertificate=False;` |
| 4 | Grant the App Service MI as a SQL user (name = App Service name) — template [`templates/azure-sql/grant-app-service-mi.sql`](../templates/azure-sql/grant-app-service-mi.sql). |
| 5 | **MUST (SqlClient 7+) — not optional for data-owning apps:** applications that own a business database and use `Authentication=Active Directory Managed Identity` (or other Entra modes) **must** reference **`Microsoft.Data.SqlClient.Extensions.Azure`** at the same major/minor as `Microsoft.Data.SqlClient`, **and** register `ActiveDirectoryAuthenticationProvider` before any SQL open (including EF `Database.Migrate()`). Do not treat the connection string + MI SQL grant as complete without this package. Without it, startup throws `Cannot find an authentication provider for 'ActiveDirectoryManagedIdentity'` and the App Service container exits — on Free F1 that quickly becomes **QuotaExceeded**. **Does not apply** to the SHARED-UI Gallery host (or other non–data-owning hosts). Supply-chain policy: [security-governance.md](security-governance.md). |

Equivalent app setting name: `ConnectionStrings__SQLAzureConnection`. Apps without a business database skip this section. Full access model: [architecture/security.md](../architecture/security.md). Environment suffixes: [naming.md](naming.md).

### Sibling SHARED-UI checkout (when used)

When a product workflow checks out SYSTEM-SHARED-UI for `ProjectReference` restore/publish: the checkout tracks the **default branch** (accepted risk today). Do not invent package distribution. Pinning / versioned artifacts are Future Validation when app #2, production environments, or an independent SHARED-UI release cadence appear — see [security-governance.md § Sibling shared-library consumption](security-governance.md#sibling-shared-library-consumption-projectreference).

### Dependency update waves

Bump SYSTEM-SHARED-UI first, then consumer applications, in the **same upgrade wave** — [security-governance.md § Dependency update-wave convention](security-governance.md#dependency-update-wave-convention).

---

## Workflow Convention

| Convention | Current standard |
| --- | --- |
| File | `.github/workflows/deploy-dev.yml` for DEV (future: `deploy-uat.yml` / `deploy-prd.yml` when those Environments exist) |
| Trigger | **`workflow_dispatch` only** — not on push/PR by default |
| Environment | `environment: DEV` (exact match to GitHub Environment) |
| Deploy action | `azure/webapps-deploy` (or current org-approved equivalent) using `publish-profile: ${{ secrets.AZURE_WEBAPP_PUBLISH_PROFILE }}` |
| Display name | Workflow `name:` should read clearly as **Deploy DEV** (or Deploy UAT / Deploy PRD) |

Product workflows may include app-specific steps (e.g. checkout a sibling Shared UI repo for `ProjectReference` restore). Which repos/paths to check out are **product metadata**; the **`SHARED_UI_CHECKOUT_TOKEN`** secret name and private-repo token requirement above are part of this standard when that checkout is used.

---

## Manual Deployment Procedure

Schema evolution is a **mandatory** part of hosted deployment for **data-owning** apps. This document is the deployment SSOT — do not treat migrations as an optional side runbook disconnected from publish.

### Rules (populated hosted databases)

- **`sql/current_model/` is not used** to evolve a **populated** hosted / customer database.
- Hosted environments use **`sql/migration_scripts/`** (SHARED-UI platform scripts + product scripts) recorded in **`dbo.BreezeOnSchemaVersions`**.
- First-time **empty** catalog bootstrap (or full reset) follows Master Flow Step 1 / [database.md](database.md) — then this procedure for subsequent releases.

Detail SSOT for migration authorship, ledger, and bootstrap-vs-migration doctrine: [database.md](database.md) § Platform schema evolution (hosted). First-time customer-environment catalog: [Customer Onboarding Master Flow](../runbooks/customer-onboarding-master-flow.md) Step 1.

### Deployment flow (data-owning apps)

After Azure App Service, GitHub Environment, secrets, MI SQL access, and workflow are configured:

1. **Evaluate pending migrations** — compare SHARED-UI and product `migration_scripts/` to applied rows in `dbo.BreezeOnSchemaVersions` for the target customer database.
2. **Apply required SHARED-UI migrations** — platform ledger / Identity / Security (and any other SHARED-UI-owned scripts) in documented ownership order: platform → Identity → Security (see [database.md](database.md)).
3. **Apply required product migrations** — application schemas (e.g. EAC `System`) from the product repo `sql/migration_scripts/`. EAC System object evolution must include the matching `current_model` source **and** deploy allowlist update for local reset parity ([database.md](database.md) § EAC Framework Synchronization) — migrations alone do not update the local allowlist path.
4. **Validate `BreezeOnSchemaVersions` state** — confirm expected scripts are recorded; do not publish if required migrations failed or remain pending. Prefer also verifying required framework objects from EAC `sql/framework-required-objects.json` (`OBJECT_ID`) after System migrations.
5. **Publish application** — GitHub Actions:
   - Open the product repository → **Actions**.
   - Select **Deploy DEV** (workflow from `deploy-dev.yml`; same pattern for UAT/PRD when those Environments exist).
   - **Run workflow** on the intended branch (usually `main`).
   - Confirm the job uses the matching GitHub Environment (e.g. **`DEV`**) and completes publish + deploy.
6. **Execute smoke testing** — hit the App Service public URL; confirm sign-in / critical routes as applicable.

### Ordered migration checklist (minimal)

| Order | Apply from | Notes |
| --- | --- | --- |
| 1 | SHARED-UI `sql/platform/migration_scripts/` | Includes schema-version ledger when not yet present |
| 2 | SHARED-UI `sql/identity/migration_scripts/` | Platform Identity |
| 3 | SHARED-UI `sql/security/migration_scripts/` | Platform Security |
| 4 | Product `sql/migration_scripts/` | Application schemas only |

Apps **without** a business / customer database skip steps 1–4 and publish + smoke only (Gallery pattern).

Failures such as **“No credentials found”** usually mean the workflow’s `environment:` name does not match a GitHub Environment that holds `AZURE_WEBAPP_PUBLISH_PROFILE`, or the secret is missing/empty.

---

## Product Repository Responsibilities

Product repositories **may** document:

| Metadata | Example |
| --- | --- |
| App Service name | `breezeon-system-shared-ui-dev` |
| Resource group | `RG-BREEZEON-DEV` |
| Public URL | App Service default hostname |
| Workflow path | `.github/workflows/deploy-dev.yml` |
| App-specific build notes | Sibling checkout of `SYSTEM-SHARED-UI`, which `.csproj` is published |

Product repositories **must**:

- Link to this document for procedures, stack rules, SCM/publish-profile setup, secret naming, and workflow conventions.
- Keep `README` / `README_AI` / `AGENTS` thin on deploy — no portal cookbooks, no duplicate secret how-tos.

Product repositories **must not**:

- Become the source of truth for deployment procedures.
- Redefine Environment names, secret names, or trigger policy independently of this standard.

---

## Governance

Changes to any of the following **must be reflected in this document first**, in the same change set as adoption elsewhere:

- Deployment mechanism (publish profile → OIDC, containers, slots, Front Door, etc.)
- Secret conventions or credential storage
- Workflow naming, triggers, or required Actions
- Environment naming (`DEV` / `UAT` / `PRD`)
- Authentication strategies for deploy (SCM Basic auth, federated identity, etc.)
- Publishing strategies (zip deploy, container image, static artifacts, etc.)

Do not update only a product README or a one-off workflow comment and leave this standard stale. Index links in [README.md](../README.md) and [README_AI.md](../README_AI.md) stay in the same change set when this file is added, renamed, or removed.

---

## Future Evolution / Notes

- **Not current reality:** OIDC / federated credentials to Azure, deployment slots, container-based App Service, Front Door, auto-deploy on push. When adopted, update this file and then product workflows/metadata.
- **UAT / PRD:** Same conventions (`deploy-uat.yml` / `deploy-prd.yml`, Environments `UAT` / `PRD`, same secret name per Environment) when those hosts exist.
- **Publish credential scaling (Future Validation):** today’s model is one `AZURE_WEBAPP_PUBLISH_PROFILE` per GitHub Environment bound to a single hard-coded App Service per product repo. Do **not** choose OIDC vs parameterized secrets vs Environment naming changes until **customer-environment #2** exists **or** a **second App Service target** is required under the same Environment Label. Trigger an ADR / this-document update at that time.
- Operational incident runbooks may appear under [`runbooks/`](../runbooks/README.md); they link here for the deploy standard rather than forking procedure.

---

## References

| Document | Role |
| --- | --- |
| [environments.md](environments.md) | Environment Label / customer-environment / GitHub Environment; seed exclusion; current DEV inventory |
| [glossary.md](glossary.md) | Term definitions for the three layers |
| [database.md](database.md) | Hosted schema evolution; `BreezeOnSchemaVersions`; bootstrap vs migrations |
| [Customer Onboarding Master Flow](../runbooks/customer-onboarding-master-flow.md) | First-time catalog bootstrap (Step 1) |
| [application-model.md](application-model.md) | What a Breeze On app includes; deploy expectations point here |
| [engineering.md](engineering.md) | Runtime stack (.NET 10) |
| [architecture/landscape.md](../architecture/landscape.md) | Implemented hosted topology |
| [architecture/applications/eac.md](../architecture/applications/eac.md) | EAC DEV App Service / SQL names |
| [ADR-002](../decisions/ADR-002-blazor-interactive-server.md) | Interactive Server hosting model |
| [documentation.md](documentation.md) | Current-reality and same-change-set rules |
