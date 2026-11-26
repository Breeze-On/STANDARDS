<!-- Classification: DEC; Scope: platform; Domain: Security; Capability: Authorization -->
# ADR-022 — Consumer Application Context Bootstrap

## Status

Accepted

## Context

Product applications need a reusable way to resolve EAC Application Enabled contexts, derive per-user visibility from APPSG AttributeCode memberships, propagate `AE` query state, and separate configuration/resolution failures from authorization denials — without forking EAC App Configuration visibility Paths A/B/C or duplicating platform Code-based authorization.

## Decision

1. EAC owns `System.P_GET_EACApplicationAccessContext` (`@ApplicationUniqueCode`, `@UserGUID`) returning facts only (contexts, memberships, configured AttributeCodes).
2. SHARED-UI owns Application Context Bootstrap (`IBoApplicationAccessBootstrap`, 60s cache), AE resolution, `IBoApplicationContextNavigation`, `BoApplicationContextGate`, `BoApplicationError`, and `BoContextSelection`.
3. `IBoAuthorizationService` remains the authoritative platform service for Security group Code membership, route authorization, and page catalog authorization.
4. Product applications own AttributeCode page policy (e.g. INV `ADMIN` / `INITIATE` / `REPORT`).
5. **Config before membership:** products declare `RequiredAttributeCodes` at registration (platform stays agnostic). Missing required AttributeCodes in EAC → Application Error (stop). Only then evaluate memberships (Access Denied when configuration is valid but the user lacks permission). Missing AE uses **configured + visible** counts for auto-select / Context Selection.
6. `/application-error` sits outside the bootstrap dependency chain (recursion-safe); generic Application Error copy — no title/message query transport.

## Consequences

- Future apps integrate by registering UniqueCode, consuming shared AE helpers, and defining AttributeCode maps — without custom bootstrap SPs or parallel Code authZ.
- EAC App Configuration visibility remains EAC-specific; consumer visibility is AttributeCode-membership-based.
- AE remains the join key for future EAC-scoped facts ([ae-fact-providers.md](../architecture/app-context/ae-fact-providers.md)).
- Changes to `System.P_GET_EACApplicationAccessContext` (or its deploy path) must satisfy [database.md](../docs/database.md) § **EAC Framework Synchronization**: allowlist (`Get-EacCurrentModelScriptNames`), committed consolidation, migration scripts, and required-objects manifest in the same change set. Local fail-fast is primary; consumer bootstrap must not be the first detector of a missing framework procedure.

## Related

- [ADR-006](ADR-006-application-context-ownership.md)
- [architecture/app-context/](../architecture/app-context/README.md)
- [authorization-standard.md](../architecture/authorization/authorization-standard.md)
- [docs/database.md](../docs/database.md) § EAC Framework Synchronization
