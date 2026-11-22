<!-- Classification: AA; Scope: platform; Domain: Platform; Capability: Environments -->
# Environments

Owner: Engineering

Central reference for **environment names and models** used across Breeze On documentation and applications. Product repositories should **link here** instead of redefining environment concepts.

Current Reality Only: details below match what is implemented or already defined in STANDARDS and product docs today.

## Three layers (do not conflate)

| Layer | What it is | Values / form |
| --- | --- | --- |
| **Environment Label** | Lifecycle stage used in seed rules, governance, and Azure resource tokens | **`DEV`**, **`UAT`**, **`PRD`** (plus **Local** for workstation sandbox) |
| **Customer-Environment** | SaaS isolation unit: one App Registration + one customer database + N product App Services | **`{Customer}-{ENV}`** (e.g. `CustomerA-DEV`) — [cloud-architecture.md](../architecture/identity-and-authentication/cloud-architecture.md), [ADR-011](../decisions/ADR-011-app-registration-per-customer-environment.md) |
| **GitHub Environment** | Product-repo deploy binding for secrets and workflow `environment:` | Exact names **`DEV`**, **`UAT`**, **`PRD`** — [hosted-deployment.md](hosted-deployment.md) |

An Environment Label is **not** a single global Azure estate. Many customer-environments can share the same label (e.g. many `*-DEV` instances). A GitHub Environment name reuses the label spelling for deploy binding; it does not invent a fourth vocabulary.

**Do not invent** multi-customer provisioning procedures here — use [Customer Onboarding Master Flow](../runbooks/customer-onboarding-master-flow.md) and Identity architecture when onboarding another customer-environment.

## Summary

| Name | Role | Implemented hosting (today) |
| --- | --- | --- |
| **Local** | Developer / agent sandbox | SQL Server Docker on the workstation |
| **DEV** | Hosted development **label** | Azure App Service + Azure SQL (EAC / Shared UI Gallery as documented) — see [Current DEV inventory](#current-dev-inventory) |
| **UAT** | User acceptance / pre-production **label** | Label reserved for hosted UAT; no separate UAT resources documented as implemented yet |
| **PRD** | Production **label** | Label reserved for hosted production; no separate PRD resources documented as implemented yet |

**GitHub Environment names** for deploy workflows must be **`DEV`**, **`UAT`**, and **`PRD`** (exact spelling). Do not use legacy labels `DV` / `PP` / `PR` for new Environments or new docs.

Azure **resource** environment tokens must be lowercase **`dev`**, **`uat`**, and **`prd`** (for example App Service `…-dev`, never `…-dv`). Full naming table: [naming.md](naming.md) § Environments. List physical names as they exist today in architecture / product docs; legacy tokens such as database `BreezeOnDV` are current-reality exceptions until renamed — do not use them as the pattern for new resources.

**Hosted deploy procedures** (App Service stack, publish profile, GitHub secrets, workflows, schema evolution): [hosted-deployment.md](hosted-deployment.md) — not redefined in product repositories.

Scripts and docs name **DEV**, **UAT**, and **PRD** when listing hosted Azure SQL environments that must **not** receive local `sql/seed/` by default ([database.md](database.md), [local-database.md](local-database.md)).

## Current DEV inventory

Today’s hosted DEV Azure inventory (`RG-BREEZEON-DEV`, `breezeon-system-admin-eac-dev`, `breezeon-system-shared-ui-dev`, Azure SQL `BreezeOnDV`, GitHub Environment **`DEV`** on product repos) is **both**:

1. the **internal BreezeOn-operated shared DEV** environment (shared hosted development for the org), **and**
2. the **first implemented customer-environment** under the **DEV** Environment Label (shared customer catalog for platform Identity/Security + EAC `System`).

These two concepts must stay **explicitly distinguished** in documentation even though they currently share one physical inventory. Additional customer-environments under the same label are **not** documented as implemented — do not invent their Azure inventories or provisioning steps here.

---

## Local

| | |
| --- | --- |
| **Name** | Local |
| **Purpose** | Routine development and agent verification without Azure SQL (local SQL Server Docker). End-user sign-in still uses Entra OIDC via `BreezeOn-LOCAL` — **no authentication bypass** |
| **Hosting model** | Developer machine; SQL Server 2022 container via Docker Compose in the application repo |
| **Authentication model** | **Database:** SQL authentication (`sa`); password from gitignored `.env` (`MSSQL_SA_PASSWORD`) and/or User Secrets (`LocalSql:SaPassword`). **End-user / app:** same Entra OIDC + cookie model as hosted via `BreezeOn-LOCAL` ([local-development-standard.md](../architecture/identity-and-authentication/local-development-standard.md)) — not a separate bypass path |
| **Database model** | Physical name `{Logical}Local` (EAC: `BreezeOnLocal` on `localhost,1433`); apply `sql/current_model/` then `sql/seed/` |
| **Intended usage** | Default path for `dotnet run`, local Identity data, and local-ready testing |

Org pattern: [local-database.md](local-database.md). Decision context: [ADR-003](../decisions/ADR-003-azure-sql-with-local-docker-sql.md).

---

## DEV

| | |
| --- | --- |
| **Name** | DEV (hosted development **Environment Label**) |
| **Purpose** | Hosted development stage for BreezeOn products |
| **Current inventory role** | See [Current DEV inventory](#current-dev-inventory) — BreezeOn-operated shared DEV **and** first implemented customer-environment |
| **Hosting model (EAC)** | Azure App Service Linux Free F1 (`breezeon-system-admin-eac-dev`), resource group `RG-BREEZEON-DEV`, stack `DOTNETCORE\|10.0` |
| **Hosting model (Shared UI Gallery)** | Azure App Service Linux (`breezeon-system-shared-ui-dev`), resource group `RG-BREEZEON-DEV`, stack .NET 10 |
| **Authentication model (EAC)** | End-user Entra OIDC + cookies via shared platform ([Identity & Authentication](../architecture/identity-and-authentication/README.md)); App Service `AUTHENTICATION__*` settings; App Service → Azure SQL via **system-assigned Managed Identity**; operators may use Entra Default for scripts |
| **Database model (EAC)** | Azure SQL `sql-breezeon-dev.database.windows.net` / database `BreezeOnDV` (legacy physical name; new DBs should use `{Logical}Dev` / `Uat` / `Prd` per [naming.md](naming.md)); customer catalog holds platform `Identity.*` + business schema under `System` (future products share this customer DB); no `AspNet*` tables |
| **GitHub Environment** | Product deploy workflows bind to GitHub Environment **`DEV`** |
| **Intended usage** | Deployed smoke and shared hosted development |

Details: [architecture/applications/eac.md](../architecture/applications/eac.md), [architecture/security.md](../architecture/security.md), [architecture/landscape.md](../architecture/landscape.md).

---

## UAT

| | |
| --- | --- |
| **Name** | UAT |
| **Purpose** | User acceptance / pre-production hosted instance |
| **Status** | Name reserved in seed/governance language; no UAT App Service / database documented as implemented yet |

---

## PRD

| | |
| --- | --- |
| **Name** | PRD |
| **Purpose** | Production hosted instance |
| **Status** | Name reserved in seed/governance language; no PRD App Service / database documented as implemented yet |

---

## Hosted seed rule (DEV / UAT / PRD)

Local `sql/seed/` is for the **Local** sandbox only. Do **not** apply seed scripts to hosted Azure SQL environments named **DEV**, **UAT**, or **PRD** by default. Product READMEs and seed READMEs use these three labels together for that rule.

---

## Product documentation

- Describe environment-specific URLs, connection settings, and **product deploy metadata** (App Service name, resource group) in the **product** README / README_AI.
- Use this document for shared meaning of Local vs hosted **DEV** / **UAT** / **PRD**, the three layers (label / customer-environment / GitHub Environment), and the hosted seed-exclusion labels.
- Use [hosted-deployment.md](hosted-deployment.md) for deploy procedures (including schema evolution) and conventions; do not duplicate them in product repos.
- Customer-environment Entra / App Registration cutover: [Customer Onboarding Master Flow](../runbooks/customer-onboarding-master-flow.md) · [customer-onboarding-authentication.md](../runbooks/customer-onboarding-authentication.md) (Workflows A–F) · [customer-onboarding-authorization.md](../runbooks/customer-onboarding-authorization.md) (Workflow G).
- Do not duplicate full environment matrices in every product README.
