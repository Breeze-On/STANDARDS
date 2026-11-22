<!-- Classification: OPS; Scope: platform; Domain: Operations; Capability: ConfigPromote -->
# Runbook — Application Configuration deployment

Owner: Operations

Promote Application Configuration between environments using EAC Import/Export JSON (synchronize-by-Code).

Platform semantics: [architecture/app-configuration/application-configuration-deployment.md](../architecture/app-configuration/application-configuration-deployment.md). JSON contract: [docs/data-portability.md](../docs/data-portability.md) § Application Configuration JSON.

## Prerequisites

- Source and target environments both have the Application registered with the **same** `UniqueCode`.
- Operator can manage the Application on the target (Global System Administrator or Application `APP_*` administrator).
- On `/app-configuration`, select the Application and a Business Entity context (workspace gate). Deployment identity is the Application `UniqueCode`, **not** the Business Entity. Synchronize is **Application-scoped** — it is not limited to the selected Business Entity.

## Export (source environment)

1. Open **Application Configuration**.
2. Select Application + Business Entity.
3. Footer **Export JSON**.
4. Save `{UniqueCode}.application-configuration.json` (source-control friendly). Current export includes `dataEntities`, `processFramework`, `variables`, `securityGroups`, and `languages` (schemaVersion **2** integer). Prefer **export-then-edit** — do not hand-author a minimal file that omits `dataEntities` (missing key ≡ `[]` ≡ full DE synchronize).

## Import / synchronize (target environment)

1. Open **Application Configuration** on the target.
2. Select the **same** Application (by UniqueCode) + a Business Entity context (workspace gate only).
3. Footer **Import JSON** → choose the file.
4. Review file-level validation errors if any (toasts; nothing is applied).
5. Review the **Import Summary**:
   - **Changes Summary** columns: **Entity · Item · Type · New · Updated · Deleted** (aggregated business units — object Codes never appear as Item).
   - **Errors** block Synchronize; **Warnings** do not.
   - **Omitted-section warnings** when optional keys are absent (for example “Variables will not be updated.”).
   - **Application-scope warnings** when Variables or Security Groups participate (values/groups sync across enablements — not only the selected Business Entity).
6. Confirm **Synchronize**.
7. Verify participating tabs reflect the file (Data Entities / Process Framework / Variables / Security Groups as applicable).

## Important behaviors

- Synchronize is **section-participation based**: a present section synchronizes **completely**; an omitted section is **skipped** (target unchanged for that section). “No partial imports” means no subset-of-Codes inside a present section — not “all section keys required.”
- When a participating section syncs, target Codes **absent from the file are removed** for that section.
- Data Entity removals are blocked when rows exist in any Application Context. Column removals cascade-delete metadata, then the column.
- **Deployed by this file (when section participates):** Data Entity configuration; Process Framework metadata values; Variable definitions and values; Security Group definitions; **enabled languages** (`languages` — replace per listed context; `en-CA` required).
- **Not deployed by this file:** Data Entity row data; Security Group memberships; Translations Excel catalogs (separate path). PF/Variable TEXT language maps that travel in JSON are replaced when those sections participate — translator work only in the target can be lost if the file lacks those languages.
- Applications / Business Entities JSON remain separate merge/upsert contracts — do not use those for App Config promotion. Cross-kind order: [data-portability.md Kind catalog](../docs/data-portability.md#kind-catalog-semantic-families).

## Failure handling

- Validation or plan failure → zero writes.
- Apply failure → SQL transaction rolls back; fix the blocker (for example remove rows that prevent entity deletion) and retry.
