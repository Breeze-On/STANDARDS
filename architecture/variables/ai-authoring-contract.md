<!-- Classification: AA; Scope: application:eac -->
# Variables — AI Authoring Contract

Owner: Architecture (EAC)

Semantics: [variables-standard.md](variables-standard.md). Construct choice: [construct-selection.md](../app-configuration/construct-selection.md). Guide: [authoring-guide.md](authoring-guide.md). Fields: [`docs/data-portability.md`](../../docs/data-portability.md).

---

## Recipe: requirements → JSON

1. **Choose construct** via [construct-selection.md](../app-configuration/construct-selection.md).  
2. **Definitions** — `code`, `description` (plain string), `dataType`, `sortOrder`, optional `decimals` / `metadata`.  
3. **Values** — only for configured contexts; omit entry = Unset.  
4. **Secrets** — never.  
5. **Envelope** — when `variables` present, include **both** `definitions` and `values`. Leave other App Config sections unchanged unless intentionally syncing them.

---

## Required / optional

### Definition

| Field | Required | Notes |
| --- | --- | --- |
| `code` | Yes | Kebab; **immutable after create** |
| `description` | Yes | Plain string (not language map) |
| `dataType` | Yes | TEXT \| NUMBER \| BOOLEAN \| DATE \| DATETIME — immutable after create |
| `sortOrder` | Yes | |
| `decimals` | When NUMBER | 0–10; default **0** if omitted |
| `metadata` | No | Freeform tag |

### Value

| Field | Required | Notes |
| --- | --- | --- |
| `businessEntityCode` | Yes | Must be enabled for the Application |
| `code` | Yes | Definition Code |
| Typed value | Yes when present | TEXT (string or language map → en-CA); NUMBER; BOOLEAN; DATE; DATETIME |

---

## Hazards

| Hazard | Effect |
| --- | --- |
| `variables` with only definitions | Invalid — both arrays required |
| `values: []` | Deletes **all** Variable values Application-wide |
| `variables` omitted | Skip (omit=skip) |
| Description as language map | Rejected — plain string only |
| Plain TEXT string | Normalized to **en-CA** translation |
| NUMBER scale > Decimals | **Warning**; value still rounded |
| DataType change | Two-step: remove then recreate |
| Secrets in TEXT | **Prohibited** |
| Env-specific values on promote | Overwrite target — intentional; admin responsibility |

Shared envelope hazards + kind catalog: [`docs/data-portability.md`](../../docs/data-portability.md). Also: missing/`[]` `dataEntities` = full DE sync (not omit=skip); export-then-edit.
