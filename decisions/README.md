# Architecture Decision Records

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
