<!-- Classification: AA; Scope: platform; Domain: Platform; Capability: Applications -->
# AE-scoped fact providers (future seam)

Owner: Architecture

**Status:** Seam in use for Data Entity lookup only; other fact providers (Variables, Process Framework, etc.) are not implemented in SHARED-UI.

## Intent

Keep **AE** (`ApplicationEnabledGUID`) as the only runtime Application Context id while allowing future EAC-managed data to load **per AE** without inventing a second context scheme or bloating `P_GET_EACApplicationAccessContext` into a kitchen-sink contract.

## Direction

- Today: `IBoApplicationAccessBootstrap` returns access facts (contexts, AttributeCode memberships, configured AttributeCodes).
- Implemented: **Data Entity lookup** is an AE-scoped provider — SHARED-UI `IBoDataEntityLookupQueries` over EAC `System.P_GET_EACDataEntityLookupValues` ([ADR-023](../../decisions/ADR-023-consumer-data-entity-lookup.md), [using-data-entities.md](../data-entities/using-data-entities.md)). It is **not** merged into the access bootstrap or its cache.
- Later: additive **AE-scoped fact providers** keyed by `ApplicationUniqueCode` + `ApplicationEnabledGUID` (and caller identity as required) for Variables, Process Framework, Business Reference Data, localization packs, feature flags, and similar.
- Products continue to read `IBoApplicationContext.ApplicationEnabledGUID` and call the appropriate provider/service — they do not own parallel AE plumbing.

## Constraints

- Bootstrap remains **not** a second authorization system; `IBoAuthorizationService` stays Code-authZ SSOT.
- New fact contracts are EAC-owned (SP/API) + SHARED-UI consumption helpers, registered similarly to application access.
- Do not merge unrelated fact caches into the access bootstrap cache without an explicit design.

## Related

- [README.md](README.md) — canonical AE model
- [bootstrap-and-cache.md](bootstrap-and-cache.md)
- [ADR-022](../../decisions/ADR-022-consumer-application-context-bootstrap.md)
- [ADR-023](../../decisions/ADR-023-consumer-data-entity-lookup.md)
