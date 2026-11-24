<!-- Classification: AA; Scope: platform; Domain: Platform; Capability: Applications -->
# AE-scoped fact providers (future seam)

Owner: Architecture

**Status:** Documented seam only — not implemented in SHARED-UI yet.

## Intent

Keep **AE** (`ApplicationEnabledGUID`) as the only runtime Application Context id while allowing future EAC-managed data to load **per AE** without inventing a second context scheme or bloating `P_GET_EACApplicationAccessContext` into a kitchen-sink contract.

## Direction

- Today: `IBoApplicationAccessBootstrap` returns access facts (contexts, AttributeCode memberships, configured AttributeCodes).
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
