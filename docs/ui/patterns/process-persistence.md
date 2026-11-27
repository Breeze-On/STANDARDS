<!-- Classification: AA; Scope: platform; Domain: UI; Capability: ProcessPersistence -->
# Process persistence (Save / Submit)

Owner: Architecture · product application services · [ADR-024](../../../decisions/ADR-024-platform-process-root.md)

Related: [process-view.md](process-view.md) · [process-history.md](process-history.md) · [process-runtime](../../../architecture/process-runtime/README.md) · [ADR-025](../../../decisions/ADR-025-process-history.md) · [page-footer-actions.md](page-footer-actions.md) · [overlays.md](../shell/overlays.md) · [initiation-experience.md](initiation-experience.md)

## Single persistence path

Save and Submit share the same persistence behavior:

| Operation | Persist | Create process records | Redirect to Process View | Mandatory validation |
| --- | --- | --- | --- | --- |
| **Save** | Yes | Yes | Yes | No |
| **Submit** | Yes | Yes | Yes | Yes |

No workflow engine / step-transition execution in v1. Initiation Save/Submit **do** write a Process History row for the completed option (`00`/`va` or `00`/`va1`) — [ADR-025](../../../decisions/ADR-025-process-history.md).

## Layering

```text
UI → Application Service → Persistence Orchestration → Database
```

The UI must not persist Process tables directly.

## Mandatory create order

1. Create `Global.Process` via `Global.P_POST_Process`.
2. Database generates `ProcessGUID`.
3. Create `{UniqueCode}.Process` with that `ProcessGUID`.
4. Create `Global.ProcessHistory` via `Global.P_POST_ProcessHistory` for step `00` + `va` (Submit) or `va1` (Save), including optional Comments.
5. Commit transaction.
6. Return `ProcessGUID`.
7. Redirect to Process View (terminal).

Application repositories **must not** mint `ProcessGUID` values. History create uses the shared CompleteAsync / `IBoProcessHistoryQueries` path — apps must not INSERT into `Global.ProcessHistory`.

## Page Freeze

On Save or Submit:

- Freeze the page **immediately** (`IBoPageFreezeService.RunAsync`) with message **“Processing...”** (`PageFreeze_PleaseWait` / `message: null`) — [overlays.md](../shell/overlays.md).
- `RunAsync` paints the overlay **before** mandatory/domain validation and persistence (no intentional delay). Validation may run under the freeze; on validation failure Hide immediately and show the Alert toast (do **not** enforce the 1500ms minimum on failed validation).
- Prevent all interaction and duplicate actions.
- On **successful** persistence, keep the page frozen for a **minimum of 1500ms**, then redirect (toast after Hide per overlays rules).

## Post-persist

Navigate to `/process-view?AE=…&PGUID=…`. Process View is terminal in v1 — see [process-view.md](process-view.md).
