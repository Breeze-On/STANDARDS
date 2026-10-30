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

## ADM

Administration application — centralized hub for system configuration, business drop-down (DDL) / reference data, security access, and role assignments. Repository: `SYSTEM-ADMIN-ADM` (`BreezeOn.Adm`).

Related:
- [architecture/adm.md](../architecture/adm.md)
- [architecture/landscape.md](../architecture/landscape.md)

## Application

A purpose-built product repository that hosts a runnable Breeze On app (today: ADM pattern — Blazor Web App, Identity when used, optional SQL ownership and DEV hosting). Distinct from a shared library or the STANDARDS repo.

Related:
- [application-model.md](application-model.md)
- [architecture/landscape.md](../architecture/landscape.md)

## Breeze On

Organization display name. GitHub org login: `Breeze-On`. Code / namespaces: `BreezeOn`.

Related:
- [naming.md](naming.md)
- [architecture/ecosystem.md](../architecture/ecosystem.md)

## BreezeOn.UI

Public shared UI library (`Bo*` components) in `SYSTEM-SHARED-UI`. Fluent UI Blazor is an internal implementation detail; product apps must not take a direct Fluent dependency.

Related:
- [ui/overview.md](ui/overview.md)
- [ADR-004](../decisions/ADR-004-breezeon-ui-abstraction-layer.md)

## Business Entity

Term listed for future domain-modeling coverage. **No organization-wide definition or standard exists yet.**

Related:
- [domain-modeling.md](domain-modeling.md)

## Business Reference Data

Configuration / lookup values managed for the ecosystem (often via ADM). In current ADM docs, paired with business drop-down (DDL) management.

Related:
- [architecture/adm.md](../architecture/adm.md)
- [DDL](#ddl)

## Current Reality Only

Documentation philosophy: document implemented functionality, existing architecture, and standards actually in use. Do not document planned features, future architecture, or roadmaps as if they exist. Update docs in the same change set when reality changes.

Related:
- [documentation.md](documentation.md)
- [README.md](../README.md)

## DDL

Business drop-down list values (lookup / configuration lists) managed through ADM. Distinct from the UI control **Drop-Down List** (`BoDropDownList`).

Related:
- [architecture/adm.md](../architecture/adm.md)
- [Drop-Down List](#drop-down-list)

## Domain

Informal term for an application’s business area or ownership boundary (e.g. ADM does not own Shared UI; Shared UI does not own ADM business domains). **Organization-wide domain-modeling standards are not yet formally defined.**

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

Hosted development environment (**DEV**). GitHub Environment name: `DEV`. For ADM today: Azure App Service + Azure SQL (`BreezeOnDV` physical database name), Managed Identity for the app. Local seed scripts must not be applied to DEV / UAT / PRD by default. Legacy docs may have said DV / PP / PR — use DEV / UAT / PRD going forward.

Related:
- [environments.md](environments.md)
- [architecture/adm.md](../architecture/adm.md)

## UAT Environment

Hosted user-acceptance / pre-production label (**UAT**). GitHub Environment name: `UAT`. Reserved in seed/governance language; separate UAT Azure resources are not documented as implemented yet.

Related:
- [environments.md](environments.md)

## PRD Environment

Hosted production label (**PRD**). GitHub Environment name: `PRD`. Reserved in seed/governance language; separate PRD Azure resources are not documented as implemented yet.

Related:
- [environments.md](environments.md)

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

UI layout display name for `BoRow` — one horizontal band of equal-width field slots inside a Section. Every form field must be a direct child of a Row.

Related:
- [ui/layout/layout.md](ui/layout/layout.md)
- [ui/layout/sections.md](ui/layout/sections.md)

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
