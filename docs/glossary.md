<!-- Classification: AA; Scope: platform; Domain: Engineering; Capability: Glossary -->
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

## Development Agent

AI agent role that implements from an active plan under `docs/plans/in-progress/` (especially on **Build Locally**), updates permanent documentation, transfers lasting knowledge out of the plan, and moves the plan to `docs/plans/implemented/` (or deletes it) only after completion criteria are met. SSOT: [planning-and-development-agents.md](planning-and-development-agents.md).

## Implementation plan

Temporary markdown working artifact. New/active plans live under `docs/plans/in-progress/`; successfully completed plans move to `docs/plans/implemented/` (or are deleted when fully transferred). Not permanent documentation; chat is not the plan store. Updates are in-place and delta-only. SSOT: [planning-and-development-agents.md](planning-and-development-agents.md).

## Planning Agent

AI agent role responsible for feature, architecture, refactoring, technical design, migration, and performance plans. Writes plans only to `docs/plans/in-progress/*.md`, updates existing plans **in place** with **delta updates only** (never V2/duplicates), and must not render plan content in chat. SSOT: [planning-and-development-agents.md](planning-and-development-agents.md).

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
- [architecture/applications/eac.md](../architecture/applications/eac.md)
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

Shared Microsoft Entra App Registration for **local development** of all BreezeOn applications (local instance of one registration shared by every product in an environment). Same OIDC flow as hosted; no auth bypass. See [local-development-standard.md](../architecture/identity-and-authentication/local-development-standard.md) and [cloud-architecture.md](../architecture/identity-and-authentication/cloud-architecture.md).

## Identity (SQL schema)

Platform schema for `Identity.Users`, `Identity.UsersLogins`, `Identity.Tenants`, and `Identity.UserPhotos`. Definitions owned by SYSTEM-SHARED-UI; physical tables in the **customer database** (shared by all products in that customer-environment). Authoritative Entra resolution key `(TenantId, ExternalObjectId)`. Canonical BreezeOn user identifier: **`UserGUID`** (`UsersId` is physical PK only). `Identity.Tenants` is a sync/metadata registry — not a login allowlist. See [identity-schema-standard.md](../architecture/identity-and-authentication/identity-schema-standard.md), [ADR-010](../decisions/ADR-010-platform-identity-schema.md), and [ADR-013](../decisions/ADR-013-microsoft-graph-directory-synchronization.md).

## UserGUID

Canonical BreezeOn platform user identifier (`Identity.Users.UserGUID`). Hierarchy: Entra `(TenantId, ExternalObjectId)` → `UserGUID` → physical `UsersId`. Used for authorization, relationships, and integrations.

## Security (SQL schema)

Platform authorization schema (`Security.Groups`, `Security.GroupsMembers`) owned by SYSTEM-SHARED-UI; physical tables in the customer database. Relationships use `GroupGUID` / `UserGUID`. See [architecture/authorization/](../architecture/authorization/README.md) and [ADR-014](../decisions/ADR-014-platform-authorization.md).

## Page security

Code-based product page catalog (`BoPageDefinition`) driving nav, Home cards, routes, and Access Denied via `IBoAuthorizationService`. Not database-configurable.

Related:
- [ui/overview.md](ui/overview.md)
- [ADR-004](../decisions/ADR-004-breezeon-ui-abstraction-layer.md)

## Business Entity

A node within the organizational hierarchy representing an operational context (corporate unit, geography, department, acquisition unit, and similar). Stored in EAC as `System.EACBusinessEntities`.

Related:
- [architecture/applications/eac.md](../architecture/applications/eac.md)
- [domain-modeling.md](domain-modeling.md)
- EAC [`docs/db-model.md`](https://github.com/Breeze-On/SYSTEM-ADMIN-EAC/blob/main/docs/db-model.md)

## Enabled Application

An Application enabled for a specific Business Entity. Stored in `System.EACApplicationsEnabled`. Same as Application Context for that pair. Exclusivity: each Application + Business Entity combination exists at most once.

## Business Reference Data

Administrator-maintained **reference** lists (lookups) managed in EAC. Implemented as [Data Entities](#data-entity). Prefer “reference data” over “master data platform.” Distinct from [Variable](#variable) (one setting per context) and transactional tables.

Related:
- [architecture/applications/eac.md](../architecture/applications/eac.md)
- [Data Entity](#data-entity)
- [DDL](#ddl)

## Variable

One named, typed Application setting whose value may differ per Application Context (or be Unset). May hold business or environment configuration — **not** secrets. Distinct from [Data Entity](#data-entity) (many items) and [Process Framework](#process-framework) (routing). SSOT: [architecture/variables/](../architecture/variables/README.md) · [construct-selection.md](../architecture/app-configuration/construct-selection.md).

## Current Reality Only

Documentation philosophy: document implemented functionality, existing architecture, and standards actually in use. Do not document planned features, future architecture, or roadmaps as if they exist. Update docs in the same change set when reality changes.

Related:
- [documentation.md](documentation.md)
- [README.md](../README.md)

## Data Entity

EAC **reference-data** list: administrator-maintained named items (Code, Description, order, optional flat attributes). Definitions are Application-scoped; rows are Application Context–scoped. Distinct from [Business Entity](#business-entity) (org hierarchy). Not for Customer/Vendor/Employee/Project/Equipment/Vehicle until richer modelling exists. SSOT: [architecture/data-entities/](../architecture/data-entities/README.md).

Related:
- [architecture/data-entities/README.md](../architecture/data-entities/README.md)
- [ADR-016](../decisions/ADR-016-data-entity-ownership.md)
- [DDL](#ddl)
- [Business Reference Data](#business-reference-data)
- [Row (Data Entity)](#row-data-entity)
- [Column (Data Entity)](#column-data-entity)

## Row (Data Entity)

One item in a Data Entity list for an Application Context (Values). Portable via Excel on hosted environments; excluded from App Config JSON.

## Column (Data Entity)

One flat attribute on a Data Entity (Settings). Author-chosen kebab Code; types TEXT / DECIMAL / BOOLEAN / DATE / DATETIME. UI “Settings” = Columns; UI “Values” = Rows.

## DDL

Business drop-down list backed by a [Data Entity](#data-entity) (especially Process Framework metadata type `DDL`, which stores a row **Code**). Distinct from the UI control **Drop-Down List** (`BoDropDownList`).

Related:
- [architecture/applications/eac.md](../architecture/applications/eac.md)
- [Data Entity](#data-entity)
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

## Environment Label

Lifecycle stage vocabulary used across seed rules, governance, and Azure resource tokens: **`DEV`**, **`UAT`**, **`PRD`** (plus **Local** for the workstation sandbox). An Environment Label is **not** one global Azure estate — many [Customer-Environments](#customer-environment) may share the same label. SSOT: [environments.md](environments.md).

Related:
- [environments.md](environments.md)
- [naming.md](naming.md)

## Customer-Environment

SaaS isolation unit for a customer at a given Environment Label: **one** App Registration (`{Customer}-{ENV}`), **one** shared customer database, and **N** product App Services. Distinct from the Environment Label and from the [GitHub Environment](#github-environment) deploy binding. Topology: [cloud-architecture.md](../architecture/identity-and-authentication/cloud-architecture.md), [ADR-011](../decisions/ADR-011-app-registration-per-customer-environment.md).

Related:
- [environments.md](environments.md)
- [Customer Onboarding Master Flow](../runbooks/customer-onboarding-master-flow.md)

## GitHub Environment

Product-repository deploy binding for GitHub Actions secrets and workflow `environment:` — exact names **`DEV`**, **`UAT`**, **`PRD`**. Spelling matches the Environment Label but the object is the repo’s credential/environment binding, not the Azure customer estate. SSOT: [hosted-deployment.md](hosted-deployment.md).

Related:
- [hosted-deployment.md](hosted-deployment.md)
- [environments.md](environments.md)

## DEV Environment

Hosted development **Environment Label** (**DEV**). Azure resource token: **`dev`** (not `dv`). GitHub Environment name for product deploy binding: `DEV`. Today’s physical inventory (`breezeon-system-admin-eac-dev`, `BreezeOnDV`, `RG-BREEZEON-DEV`) is **both** the internal BreezeOn-operated shared DEV **and** the first implemented [Customer-Environment](#customer-environment) — keep those concepts distinct in docs ([environments.md](environments.md) § Current DEV inventory). Local seed scripts must not be applied to DEV / UAT / PRD by default.

Related:
- [environments.md](environments.md)
- [hosted-deployment.md](hosted-deployment.md)
- [architecture/applications/eac.md](../architecture/applications/eac.md)

## UAT Environment

Hosted user-acceptance / pre-production **Environment Label** (**UAT**). GitHub Environment name: `UAT`. Azure resource token: **`uat`**. Reserved in seed/governance language; separate UAT Azure resources / customer-environments are not documented as implemented yet.

Related:
- [environments.md](environments.md)
- [hosted-deployment.md](hosted-deployment.md)

## PRD Environment

Hosted production **Environment Label** (**PRD**). GitHub Environment name: `PRD`. Azure resource token: **`prd`**. Reserved in seed/governance language; separate PRD Azure resources / customer-environments are not documented as implemented yet.

Related:
- [environments.md](environments.md)
- [hosted-deployment.md](hosted-deployment.md)

## Local Environment

Developer / agent sandbox on the workstation (not an Environment Label for hosted Azure). For apps with SQL: SQL Server in Docker (`{Logical}Local`, e.g. `BreezeOnLocal`); apply `sql/current_model/` then `sql/seed/`. Default path for routine local runs — not Azure SQL.

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

**Disambiguation:** This organization-principles “Process” is **not** a [Process Framework](#process-framework) process definition, not [Global.Process](#globalprocess), and not an application `{UniqueCode}.Process` extension row. In PF v1, the process definition is the Application itself (see [Process (Process Framework)](#process-process-framework)).

Related:
- [architecture/ecosystem.md](../architecture/ecosystem.md)
- [domain-modeling.md](domain-modeling.md)

## Global.Process

Platform **runtime** process root table in schema `Global` (EAC-owned). Holds `ProcessGUID`, `ApplicationEnabledGUID`, and audit only — no workflow/lifecycle columns. Created only via `Global.P_POST_Process`. Application business fields live in `{UniqueCode}.Process`. SSOT: [ADR-024](../decisions/ADR-024-platform-process-root.md) · [process-runtime](../architecture/process-runtime/README.md) · [database.md](database.md) § Process table convention.

## Global.ProcessHistory

Platform **runtime** append-only ledger of business decisions and workflow actions for a `ProcessGUID` (EAC-owned). Not a field-level audit trail. Created via `Global.P_POST_ProcessHistory`; display-ready read via `Global.P_GET_ProcessHistoryByProcessGUID` (EAC projects Role, Name, Response Status). Comments for an action live on the history row. SSOT: [ADR-025](../decisions/ADR-025-process-history.md) · [process-history.md](ui/patterns/process-history.md).

## ProcessGUID (platform)

Universal platform process identifier from `Global.Process` (SQL-generated; apps must not mint). Used in URLs (`PGUID`), FKs, and consumers. Distinct from internal `ProcessId`. See [ADR-024](../decisions/ADR-024-platform-process-root.md) · [ae-query-string.md](../architecture/app-context/ae-query-string.md).

## Process View

Terminal read-only process page after Save/Submit (`/process-view?AE=…&PGUID=…`). All fields display (not Disabled); no footer actions; hydrate failures use Application Error. SSOT: [process-view.md](ui/patterns/process-view.md) · [process-persistence.md](ui/patterns/process-persistence.md).

## Process Framework

EAC business capability for defining **one process definition per Application**: who acts ([Role](#role-process-framework)), what happens ([Step](#step-process-framework)), and how work moves ([Option](#option-process-framework) / [Route](#route-process-framework)). Not a platform workflow engine; runtime engine is Future Validation. Orthogonal to runtime [Global.Process](#globalprocess). SSOT: [architecture/process-framework/README.md](../architecture/process-framework/README.md).

## Process (Process Framework)

In Process Framework v1: the **Application** is the single process definition. There is no separate Process entity. Multiple business processes require multiple Applications. Distinct from organization-principles [Process](#process) and from runtime [Global.Process](#globalprocess).

## Step (Process Framework)

Business activity or state in a Process Framework definition. Valid shapes: Actionable (Role + Options), Terminal (no Options), Informational (no Role). See [architecture/process-framework/README.md](../architecture/process-framework/README.md).

## Option (Process Framework)

Business decision or response on a Step; routes to a Next Step ([Route](#route-process-framework)).

## Role (Process Framework)

Business actor group — who is expected to act. **Not** an authorization permission grant. Soft-links to an App Config Security Group via Attribute Code.

## Route (Process Framework)

Directed edge from an Option to its Next Step (explicit routing).

## Entry Step

In Process Framework: the Step with the **lowest `sortOrder`**. Start of the authored flow.

## Terminal Step

Process Framework Step with **no outgoing Options** — an outcome / end state.

## Informational Step

Process Framework Step with **no Role** and no action required (state / notice).

## Outcome (Process Framework)

Reaching a [Terminal Step](#terminal-step) in a Process Framework definition (business end state).

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

## Global (SQL schema)

EAC-owned SQL schema for platform runtime assets (today: `Global.Process` + `Global.P_POST_Process`). Distinct from [System (SQL schema)](#system-sql-schema) (catalog / PF metadata). See [ADR-024](../decisions/ADR-024-platform-process-root.md), [database.md](database.md).

## System (SQL schema)

EAC-owned SQL schema for platform administration / shared catalog tables (for example `System.EACApplications`). Other apps consume; they do not fork duplicate catalogs. See [database.md](database.md), [architecture/applications/eac.md](../architecture/applications/eac.md).

## UniqueCode

Application technical identifier in the EAC registry; `repositoryName.ToUpperInvariant()` (e.g. repo `breezeon-corp-fin-inv` → `BREEZEON-CORP-FIN-INV`). Distinct from short `Code`. See [naming.md](naming.md), [application-definition.schema.json](ai/application-definition.schema.json), [database.md](database.md).

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
