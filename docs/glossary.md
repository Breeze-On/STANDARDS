# Glossary

Owner: Documentation

Central vocabulary for Breeze On documentation and agents. Definitions reflect **current usage only**. Prefer linking here instead of restating terminology in every product README.

When a term’s meaning changes in practice, update this glossary in the **same change set**. Do not add speculative or roadmap-only terms.

Related: [documentation.md](documentation.md), [naming.md](naming.md).

---

## ADR

Architecture Decision Record — documents **why** a significant architectural decision was made (context, decision, consequences). Lives under `decisions/`.

Related:
- [adr.md](adr.md)
- [decisions/README.md](../decisions/README.md)

## AI agent (Breeze On)

An AI coding, planning, or documentation assistant operating in a Breeze-On repository. Treated as a **development assistant** only — not a release manager, cloud operator, or repository administrator. Operational boundaries: [ai-agent-governance.md](ai-agent-governance.md), [ADR-007](../decisions/ADR-007-ai-agent-operational-boundaries.md).

## AI agent operational boundaries

Org-wide deny-by-default limits on agent publish, PR lifecycle, CI/CD triggers, deploy, cloud/infrastructure changes, secrets/permission management, and repository administration. Restricted actions require **explicit authorization in the current prompt**. SSOT: [ai-agent-governance.md](ai-agent-governance.md).

## Application

A deployable software solution represented by a repository / application code. Defines shared software behavior and deployment. In the EAC registry sense, a row in `System.EACApplications`. Distinct from a shared library or the STANDARDS repo.

## Application Context

Application + Business Entity operational instance. Represented by `ApplicationEnabledGUID` in `System.EACApplicationsEnabled`. Root owner of entity-specific application configuration. See [ADR-006](../decisions/ADR-006-application-context-ownership.md).

## ApplicationEnabledGUID

Immutable canonical identifier for an Application Context. Generated once on create; never regenerated, reassigned, or modified. Re-create after delete yields a new GUID; prior values are never reused. See [database.md](database.md), [ADR-006](../decisions/ADR-006-application-context-ownership.md).

## AUTHENTICATION__* (environment variables)

Required end-user authentication settings: `AUTHENTICATION__AUTHORITY`, `AUTHENTICATION__CLIENTID`, `AUTHENTICATION__CLIENTSECRET`. See [configuration-standard.md](../architecture/identity-and-authentication/configuration-standard.md).

## ApplicationGUID

Immutable relationship key for an application (and for future cross-entity links). Column name contains `GUID` → **NOT NULL**; generate once; never regenerate on update. See [database.md](database.md).

## Code (application)

Short business identifier for an application (e.g. `EAC`, `HRM`, `AP`). Distinct from `UniqueCode`. See [naming.md](naming.md), [database.md](database.md).

## EAC

Enterprise Administration Center — centralized hub for system configuration, business drop-down (DDL) / reference data, security access, and role assignments. Repository: `SYSTEM-ADMIN-EAC` (`BreezeOn.Eac`). Owns the SQL schema **`System`** (application registry and related platform tables).

Related:
- [architecture/eac.md](../architecture/eac.md)
- [architecture/landscape.md](../architecture/landscape.md)
- [database.md](database.md)

Related:
- [application-model.md](application-model.md)
- [architecture/landscape.md](../architecture/landscape.md)

## Breeze On

Organization display name. GitHub org login: `Breeze-On`. Code / namespaces: `BreezeOn`.

Related:
- [naming.md](naming.md)
- [architecture/ecosystem.md](../architecture/ecosystem.md)

## BreezeOn.UI

Public shared UI library (`Bo*` components) in `SYSTEM-SHARED-UI`, including the **authentication framework** and platform Identity SQL definitions. Fluent UI Blazor is an internal implementation detail; product apps must not take a direct Fluent dependency. Auth SSOT: [Identity & Authentication](../architecture/identity-and-authentication/README.md).

## BreezeOn-LOCAL

Shared Microsoft Entra App Registration for **local development** of all BreezeOn applications. Same OIDC flow as hosted; no auth bypass. See [local-development-standard.md](../architecture/identity-and-authentication/local-development-standard.md).

## Identity (SQL schema)

Platform schema for `Identity.Users` and `Identity.UsersLogins`. Definitions owned by SYSTEM-SHARED-UI; physical tables in the **customer database** (shared by all products in that customer-environment). Permanent key `(TenantId, ExternalObjectId)`. See [identity-schema-standard.md](../architecture/identity-and-authentication/identity-schema-standard.md).

Related:
- [ui/overview.md](ui/overview.md)
- [ADR-004](../decisions/ADR-004-breezeon-ui-abstraction-layer.md)

## Business Entity

A node within the organizational hierarchy representing an operational context (corporate unit, geography, department, acquisition unit, and similar). Stored in EAC as `System.EACBusinessEntities`.

Related:
- [architecture/eac.md](../architecture/eac.md)
- [domain-modeling.md](domain-modeling.md)
- EAC [`docs/db-model.md`](https://github.com/Breeze-On/SYSTEM-ADMIN-EAC/blob/main/docs/db-model.md)

## Enabled Application

An Application enabled for a specific Business Entity. Stored in `System.EACApplicationsEnabled`. Same as Application Context for that pair. Exclusivity: each Application + Business Entity combination exists at most once.

## Business Reference Data

Configuration / lookup values managed for the ecosystem (often via EAC). In current EAC docs, paired with business drop-down (DDL) management.

Related:
- [architecture/eac.md](../architecture/eac.md)
- [DDL](#ddl)

## Current Reality Only

Documentation philosophy: document implemented functionality, existing architecture, and standards actually in use. Do not document planned features, future architecture, or roadmaps as if they exist. Update docs in the same change set when reality changes.

Related:
- [documentation.md](documentation.md)
- [README.md](../README.md)

## DDL

Business drop-down list values (lookup / configuration lists) managed through EAC. Distinct from the UI control **Drop-Down List** (`BoDropDownList`).

Related:
- [architecture/eac.md](../architecture/eac.md)
- [Drop-Down List](#drop-down-list)

## Domain

Informal term for an application’s business area or ownership boundary (e.g. EAC does not own Shared UI; Shared UI does not own EAC business domains). **Organization-wide domain-modeling standards are not yet formally defined.**

Related:
- [architecture/landscape.md](../architecture/landscape.md)
- [domain-modeling.md](domain-modeling.md)

## Drop-Down List

UI form control display name for `BoDropDownList` in `BreezeOn.UI` — selectable list with the same field chrome as Text Field. Must sit in a Row inside a Section.

Related:
- [ui/controls/forms.md](ui/controls/forms.md)
- [ui/layout/layout.md](ui/layout/layout.md)

## DTO

Typed data / working-model object used with form `@bind-Value` bindings. UI controls bind to DTO or entity properties; they do not own persistence. **Broader org DTO conventions are not yet formally defined** (see domain modeling placeholder).

Related:
- [ui/controls/forms.md](ui/controls/forms.md)
- [domain-modeling.md](domain-modeling.md)

## DEV Environment

Hosted development environment (**DEV**). GitHub Environment name: `DEV`. Azure resource token: **`dev`** (not `dv`). For EAC today: App Service `breezeon-system-admin-eac-dev` + Azure SQL (`BreezeOnDV` is a legacy physical DB name), Managed Identity for the app. Local seed scripts must not be applied to DEV / UAT / PRD by default. Labels and suffixes: [naming.md](naming.md) § Environments.

Related:
- [environments.md](environments.md)
- [hosted-deployment.md](hosted-deployment.md)
- [architecture/eac.md](../architecture/eac.md)

## UAT Environment

Hosted user-acceptance / pre-production label (**UAT**). GitHub Environment name: `UAT`. Azure resource token: **`uat`**. Reserved in seed/governance language; separate UAT Azure resources are not documented as implemented yet.

Related:
- [environments.md](environments.md)
- [hosted-deployment.md](hosted-deployment.md)

## PRD Environment

Hosted production label (**PRD**). GitHub Environment name: `PRD`. Azure resource token: **`prd`**. Reserved in seed/governance language; separate PRD Azure resources are not documented as implemented yet.

Related:
- [environments.md](environments.md)
- [hosted-deployment.md](hosted-deployment.md)

## Local Environment

Developer / agent sandbox on the workstation. For apps with SQL: SQL Server in Docker (`{Logical}Local`, e.g. `BreezeOnLocal`); apply `sql/current_model/` then `sql/seed/`. Default path for routine local runs — not Azure SQL.

Related:
- [environments.md](environments.md)
- [local-database.md](local-database.md)

## Main Section

UI layout display name for `BoSectionMain` — top-level, borderless content grouping with optional header. Form Rows live inside a Section.

Related:
- [ui/layout/sections.md](ui/layout/sections.md)
- [ui/layout/layout.md](ui/layout/layout.md)

## Process

Step in the organization principles chain: Objective → **Process** → Decision → Action → Outcome. Not a formal domain-modeling artifact in STANDARDS today.

Related:
- [architecture/ecosystem.md](../architecture/ecosystem.md)
- [domain-modeling.md](domain-modeling.md)

## Row

UI layout display name for `BoRow` — one horizontal band of proportional field slots inside a Section (default equal shares via `Weight=1`). Every form field must be a direct child of a Row. See **Weight**.

Related:
- [ui/layout/layout.md](ui/layout/layout.md)
- [ui/layout/sections.md](ui/layout/sections.md)

## Weight

Relative `BoRow` width share for a field (default **1**). Share = Weight ÷ sum of layout-participating Weights. Not a 12-column grid. SSOT: [ui/layout/layout.md](ui/layout/layout.md).

## PreserveLayoutWhenHidden

When `IsHidden` is true on a form field, keep the field's Weight share (`visibility: hidden`) so siblings do not reflow. Default **false** (hidden fields collapse). **Unrelated** to Nested View `PreserveNestedExpansionOnCacheReset`. SSOT: [ui/layout/layout.md](ui/layout/layout.md).

## PreserveNestedExpansionOnCacheReset

`BoGrid` Nested View flag: when true, expand/collapse survives cache `ReplaceAll`. Used with keyword search (`false` while searching) and `NestedExpandedSeedKeys`. **Unrelated** to `PreserveLayoutWhenHidden`. SSOT: [ui/controls/grids.md](ui/controls/grids.md).

## Query-driven retrieval

Org standard: one queryable dataset = one primary retrieval contract; Filter → Sort → Page; typed `BoQuery*`; latest-wins; Top-N dropdowns via `ItemsProvider` when large. [ADR-008](../decisions/ADR-008-query-driven-data-retrieval.md) · [ui/controls/query-driven-retrieval.md](ui/controls/query-driven-retrieval.md).

## FilterCatalog

Preferred name for host EF / app-service distinct filter dropdown sources. Avoid `*FilterOptions` type names (echoes the forbidden companion FilterOptions SP anti-pattern). SSOT: [ui/controls/query-driven-retrieval.md](ui/controls/query-driven-retrieval.md).

## Server QueryMode

`BoGrid` mode where the host loads only the current page into cache and re-queries on filter/sort/page. Select-all = current page only. Default remains Client mode. SSOT: [ui/controls/grids.md](ui/controls/grids.md#server-querymode).

## Example Governance

A UI / query standard is fully implemented only when normative STANDARDS + AI guidance + Gallery working example all exist. SSOT: [ui/example-governance.md](ui/example-governance.md).

## System (SQL schema)

EAC-owned SQL schema for platform administration / shared catalog tables (for example `System.EACApplications`). Other apps consume; they do not fork duplicate catalogs. See [database.md](database.md), [architecture/eac.md](../architecture/eac.md).

## UniqueCode

Application technical identifier in the EAC registry; value follows the GitHub **repository name** (e.g. `SYSTEM-ADMIN-EAC`). Distinct from short `Code`. See [naming.md](naming.md), [database.md](database.md).

## Shared Library

Repository kind that ships reusable code without being a full application (today: `SYSTEM-SHARED-UI` / `BreezeOn.UI` — RCL + local gallery; no business database).

Related:
- [application-model.md](application-model.md)
- [architecture/landscape.md](../architecture/landscape.md)

## STANDARDS

Organization single source of truth repository (`Breeze-On/STANDARDS`): how we work (`docs/`), what exists (`architecture/`), why decisions were made (`decisions/`).

Related:
- [README.md](../README.md)
- [README_AI.md](../README_AI.md)

## Sub Section

UI layout display name for `BoSectionSub` — nested grouping inside a Main Section (different label size and outside margins than Main).

Related:
- [ui/layout/sections.md](ui/layout/sections.md)

## Text Field

UI form control display name for `BoTextField` in `BreezeOn.UI`. Must sit in a Row inside a Section.

Related:
- [ui/controls/forms.md](ui/controls/forms.md)
- [ui/layout/layout.md](ui/layout/layout.md)

## Workflow

Term used informally for application procedures and listed for future domain-modeling coverage. **No organization-wide workflow modeling standard exists yet.**

Related:
- [architecture/landscape.md](../architecture/landscape.md)
- [domain-modeling.md](domain-modeling.md)
