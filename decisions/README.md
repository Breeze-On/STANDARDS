# Architecture Decision Records

Owner: Architecture

ADRs document **why** significant architectural decisions were made. Process and template: [`docs/adr.md`](../docs/adr.md).

## Index metadata

| Column | Meaning |
| --- | --- |
| **ADR** | Identifier and link to the decision record |
| **Title** | Short human-readable name |
| **Status** | Lifecycle: Proposed, Accepted, or Superseded |
| **Category** | Primary concern (e.g. Governance, Platform, UI, Data, Hosting, Architecture) |
| **Impact Area** | Where the decision binds practice today |

Categories are discoverability labels for the index; they do not replace reading the ADR. When adding an ADR, update this table in the **same change set**.

## Index (current)

| ADR | Title | Status | Category | Impact Area |
| --- | --- | --- | --- | --- |
| [ADR-001](ADR-001-multi-repository-model.md) | Multi-repository model | Accepted | Governance | Organization / all repositories |
| [ADR-002](ADR-002-blazor-interactive-server.md) | Blazor Interactive Server | Accepted | Platform | Applications, Shared UI gallery |
| [ADR-003](ADR-003-azure-sql-with-local-docker-sql.md) | Azure SQL with local Docker SQL | Accepted | Data | Applications with databases, Hosting |
| [ADR-004](ADR-004-breezeon-ui-abstraction-layer.md) | BreezeOn.UI abstraction layer | Accepted | UI | Shared UI, Product applications |
| [ADR-005](ADR-005-mandatory-transactional-audit-columns.md) | Mandatory transactional audit columns | Accepted | Data | Applications with databases, Transactional business tables |
| [ADR-006](ADR-006-application-context-ownership.md) | Application Context ownership and lifecycle | Accepted | Data | EAC Application Enablement, entity-specific application configuration |
| [ADR-007](ADR-007-ai-agent-operational-boundaries.md) | AI agent operational boundaries | Accepted | Governance | Organization / all repositories / AI agents |
| [ADR-008](ADR-008-query-driven-data-retrieval.md) | Query-driven data retrieval | Accepted | UI + Data | Product applications, Shared UI grids / filters, Applications with databases, Planning Agents |
| [ADR-009](ADR-009-entra-oidc-cookie-authentication.md) | Entra OIDC cookie authentication (SHARED-UI) | Accepted | Authentication | All product applications, SYSTEM-SHARED-UI |
| [ADR-010](ADR-010-platform-identity-schema.md) | Platform Identity schema | Accepted | Identity / Data | Customer databases, SYSTEM-SHARED-UI |
| [ADR-011](ADR-011-app-registration-per-customer-environment.md) | One shared App Registration per customer-environment | Accepted | Hosting / Identity | Azure App Service, Entra, local development |
| [ADR-012](ADR-012-cookie-session-management.md) | Cookie and session management (SHARED-UI) | Accepted | Authentication | All product applications, SYSTEM-SHARED-UI |
| [ADR-013](ADR-013-microsoft-graph-directory-synchronization.md) | Microsoft Graph directory synchronization | Accepted | Identity / Authentication | Customer databases, SYSTEM-SHARED-UI, EAC Users admin |
| [ADR-014](ADR-014-platform-authorization.md) | Platform authorization | Accepted | Authorization | All product applications, SYSTEM-SHARED-UI, customer databases, EAC admin surfaces |
| [ADR-015](ADR-015-object-owned-administrator-groups.md) | Object-owned administrator groups (Applications & Business Entities) | Accepted | Authorization | EAC Applications / Business Entities, SYSTEM-SHARED-UI Security schema, customer databases |
| [ADR-016](ADR-016-data-entity-ownership.md) | Data Entity ownership and scope | Accepted | Data | EAC Data Entities, Application vs Application Context configuration, consumer apps |
| [ADR-017](ADR-017-application-configuration-deployment.md) | Application Configuration deployment (synchronize-by-Code) | Accepted | Data | EAC Application Configuration import/export, environment promotion |
| [ADR-018](ADR-018-data-entity-values-excel-portability.md) | Data Entity Values Excel portability | Accepted | Data | EAC Data Entities Values import/export (Excel Tool), environment data movement, bulk maintenance |
| [ADR-019](ADR-019-process-framework-metadata.md) | Process Framework metadata | Accepted | Data | EAC Application Configuration Process Framework (Roles / Steps / Options), Application Configuration JSON, PeoplePicker identity portability |
| [ADR-020](ADR-020-configuration-session-cache.md) | Application Configuration Session Cache | Accepted | UI + Architecture | EAC Application Configuration workspace cache, Planning / Development agents, Dirty State / Page Freeze interplay |
| [ADR-021](ADR-021-validation-summary-experience.md) | Validation Summary experience (live editors) | Accepted | UI | Shared UI Validation Summary, Grid Family / Shuffle hosts, Planning / Development agents, multi-row Save validation |
