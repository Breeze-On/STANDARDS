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
- Manual operator deploy steps (GitHub Actions)
- What product repos may document vs must link here

**Out of scope**

- Local development (`dev-reset.ps1`, Docker SQL) — see [local-development-scripts.md](local-development-scripts.md), [local-database.md](local-database.md)
- Application data model and end-user Identity auth — see [architecture/](../architecture/) and product `docs/`
- UAT / PRD Azure resource inventories (those hosts are not documented as implemented yet) — naming pattern only

**In this document for data-owning apps:** App Service connection string name **`SQLAzureConnection`** and how to set it. SQL Managed Identity **grant script** lives under [`templates/azure-sql/`](../templates/azure-sql/); access model: [architecture/security.md](../architecture/security.md).

---

## Hosted Deployment Principles

1. **STANDARDS owns deployment standards** — procedures, secret names, workflow conventions, App Service stack rules.
2. **Product repositories own only product-specific deployment metadata** — physical App Service name, resource group, public URL, which workflow file publishes which project, sibling-checkout needs.
3. **Do not duplicate procedures** across product READMEs, README_AI, or AGENTS.
4. **Mechanism changes land here first** — OIDC, slots, containers, Front Door, secret rotation models, etc. must update this document before adoption elsewhere.
5. **AI discovery is centralized** — agents follow [README_AI.md](../README_AI.md) and this file; they do not invent alternate deploy recipes from product repos.

---

## Environment Standards

Hosted environment **labels** and GitHub Environment **names** are **`DEV`**, **`UAT`**, and **`PRD`**. Meaning and seed rules: [environments.md](environments.md).

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

Equivalent app setting name: `ConnectionStrings__SQLAzureConnection`. Apps without a business database skip this section. Full access model: [architecture/security.md](../architecture/security.md). Environment suffixes: [naming.md](naming.md).

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

After Azure App Service, GitHub Environment, secret, and workflow are configured:

1. Open the product repository on GitHub → **Actions**.
2. Select **Deploy DEV** (workflow from `deploy-dev.yml`).
3. **Run workflow** on the intended branch (usually `main`).
4. Confirm the job uses Environment **`DEV`** and completes publish + deploy.
5. Smoke-check the App Service public URL.

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
- Operational incident runbooks may appear under [`runbooks/`](../runbooks/README.md); they link here for the deploy standard rather than forking procedure.

---

## References

| Document | Role |
| --- | --- |
| [environments.md](environments.md) | Environment meaning; seed exclusion; GitHub name spelling |
| [application-model.md](application-model.md) | What a Breeze On app includes; deploy expectations point here |
| [engineering.md](engineering.md) | Runtime stack (.NET 10) |
| [architecture/landscape.md](../architecture/landscape.md) | Implemented hosted topology |
| [architecture/eac.md](../architecture/eac.md) | EAC DEV App Service / SQL names |
| [ADR-002](../decisions/ADR-002-blazor-interactive-server.md) | Interactive Server hosting model |
| [documentation.md](documentation.md) | Current-reality and same-change-set rules |
