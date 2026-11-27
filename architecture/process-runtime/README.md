<!-- Classification: AA; Scope: platform; Domain: Platform; Capability: ProcessRuntime -->
# Process runtime (platform)

Owner: Architecture · SYSTEM-ADMIN-EAC (`Global`) · product apps (`{UniqueCode}.Process`)

SSOT for the **two-tier** runtime Process model. Decision record: [ADR-024](../../decisions/ADR-024-platform-process-root.md).

## Model

| Tier | Qualified name | Role |
| --- | --- | --- |
| Platform root | `Global.Process` | Universal process identity (`ProcessGUID`) + Application Context binding |
| Application extension | `{UniqueCode}.Process` | Application-specific flat business fields |

`ProcessGUID` is the platform identity. Application processes **consume** it; they do **not** generate it.

## Create path

Authoritative SP: **`Global.P_POST_Process`** (`@ApplicationEnabledGUID`, `@Actor` → returns `ProcessGUID`).

Products must not insert into `Global.Process` via ad-hoc SQL/EF.

### Mandatory order

1. `Global.P_POST_Process` (SQL generates `ProcessGUID`)
2. Insert `{UniqueCode}.Process` with that `ProcessGUID`
3. Commit one shared-database transaction
4. Return `ProcessGUID`
5. Redirect to Process View

UI → Application Service → Persistence Orchestration → Database. The UI must not persist Process tables directly.

## AE delete

`Global.Process` rows are runtime records. Application Enabled deletion **fails** when dependents exist. Never silent cascade. See [ADR-006](../../decisions/ADR-006-application-context-ownership.md) and [ADR-024](../../decisions/ADR-024-platform-process-root.md).

## Related UI

- [process-persistence.md](../../docs/ui/patterns/process-persistence.md) — Save/Submit orchestration, Page Freeze ≥1500ms
- [process-view.md](../../docs/ui/patterns/process-view.md) — terminal read-only Process View (v1)
- [process-request-section.md](../../docs/ui/patterns/process-request-section.md) — initiation Process Request fields

## Distinct from Process Framework

PF under `System` = definition metadata only ([ADR-019](../../decisions/ADR-019-process-framework-metadata.md)). Runtime root = `Global.Process`.
