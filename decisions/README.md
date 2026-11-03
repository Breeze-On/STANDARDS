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
