<!-- Classification: AA; Scope: platform; Domain: Platform; Capability: Applications -->
# Application Context (consumer apps)

Owner: Architecture

## Canonical model

```text
Application
  -> ApplicationUniqueCode          (product identity; naming SSOT)
  -> ApplicationEnabledGUID (AE)    (immutable runtime context id)
  -> EAC Application Enabled row    (ties app ↔ business entity)
  -> All future EAC-scoped facts      (security groups, variables, process,
                                       reference data, localization, flags, …)
```

**AE is the join key.** Product UIs and services should consume `IBoApplicationContext.ApplicationEnabledGUID` as the runtime Application Context handle. Future EAC-managed capabilities resolve *through AE*, not through parallel ad-hoc context schemes.

Establish a valid AE **before** evaluating permissions ([context-resolution.md](context-resolution.md)).

## Documents

| Doc | Topic |
| --- | --- |
| [ae-query-string.md](ae-query-string.md) | `AE` query parameter standard |
| [context-resolution.md](context-resolution.md) | Establish AE first; then authorize; Error vs Access Denied |
| [bootstrap-and-cache.md](bootstrap-and-cache.md) | Application Context Bootstrap + 60s cache vs `IBoAuthorizationService` |
| [ae-fact-providers.md](ae-fact-providers.md) | Future AE-scoped fact providers (Variables, flags, …) — **doc seam only** |

## Adoption (product apps)

1. `services.AddBreezeOnApplicationAccess("<UNIQUE-CODE>", o => { o.RequiredAttributeCodes = [...]; });` — declare **product** required AttributeCodes (or leave empty).
2. Wrap shell body in `BoApplicationContextGate` (same-AE in-app navigation keeps gated content mounted — no teardown/remount).
3. Propagate AE with `IBoApplicationContextNavigation` (no hand-rolled `AE` append).
4. Read `IBoApplicationContext.ApplicationEnabledGUID` for business work.
5. Optionally define **product** AttributeCode → page policy (not platform).

Platform never hardcodes application AttributeCodes. Configuration validity is evaluated **per AE** (required ⊆ configured on that AE) **before** membership evaluation. A single invalid AE does not break the application; Application Error only when no valid AE remains — [context-resolution.md](context-resolution.md).

Related: [ADR-006](../../decisions/ADR-006-application-context-ownership.md) · [ADR-022](../../decisions/ADR-022-consumer-application-context-bootstrap.md) · [authorization-standard.md](../authorization/authorization-standard.md) · EAC `docs/db-model.md` (`P_GET_EACApplicationAccessContext`) · [database.md](../../docs/database.md) § EAC Framework Synchronization (allowlist + local fail-fast)
