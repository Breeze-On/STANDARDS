# Runbook — Application Configuration deployment

Owner: Operations

Promote Application Configuration between environments using EAC Import/Export JSON (synchronize-by-Code).

Platform semantics: [architecture/app-configuration/application-configuration-deployment.md](../architecture/app-configuration/application-configuration-deployment.md). JSON contract: [docs/data-portability.md](../docs/data-portability.md) § Application Configuration JSON.

## Prerequisites

- Source and target environments both have the Application registered with the **same** `UniqueCode`.
- Operator can manage the Application on the target (Global System Administrator or Application `APP_*` administrator).
- On `/app-configuration`, select the Application and a Business Entity context (workspace gate). Deployment identity is the Application `UniqueCode`, not the Business Entity.

## Export (source environment)

1. Open **Application Configuration**.
2. Select Application + Business Entity.
3. Footer **Export JSON**.
4. Save `{UniqueCode}.application-configuration.json` (source-control friendly).

## Import / synchronize (target environment)

1. Open **Application Configuration** on the target.
2. Select the **same** Application (by UniqueCode) + a Business Entity context.
3. Footer **Import JSON** → choose the file.
4. Review validation errors if any (nothing is applied until Synchronize succeeds).
5. Review the summary (**Will Create / Update / Remove**).
6. Confirm **Synchronize**.
7. Verify Data Entities tab reflects the file.

## Important behaviors

- Synchronize **removes** target definitions absent from the file.
- Removals are blocked when Data Entity rows or column metadata exist in any Application Context.
- Rows, translations, metadata, and group memberships are **not** deployed by this file.
- Applications / Business Entities JSON remain separate merge/upsert contracts — do not use those for App Config promotion.

## Failure handling

- Validation or plan failure → zero writes.
- Apply failure → SQL transaction rolls back; fix the blocker (for example remove rows that prevent entity deletion) and retry.
