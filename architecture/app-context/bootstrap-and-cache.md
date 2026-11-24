<!-- Classification: AA; Scope: platform; Domain: Platform; Capability: Applications -->
# Application Context Bootstrap and cache

Owner: Architecture

## Bootstrap vs authorization

| Concern | SSOT |
| --- | --- |
| Security group **Code** membership, route authZ, page catalog | **`IBoAuthorizationService`** |
| AE contexts, BE info, AttributeCode membership **facts**, visibility | **`IBoApplicationAccessBootstrap`** |
| Application-required AttributeCodes (declaration) | **Product** via `BoApplicationAccessOptions.RequiredAttributeCodes` |
| Config-before-membership enforcement | **`IBoApplicationContextResolver`** ([context-resolution.md](context-resolution.md)) |

Bootstrap is **not** a second authorization system. It loads facts; the resolver applies **per-AE** Step 1 (required AttributeCodes ⊆ configured on that AE) before Step 2 (memberships). Invalid AEs are excluded; Application Error only when **no** valid AE remains ([context-resolution.md](context-resolution.md) § Per-AE validity).

## Registration

```csharp
services.AddBreezeOnApplicationAccess("BREEZEON-CORP-FIN-INV", options =>
{
    options.RequiredAttributeCodes = ["ADMIN", "INITIATE", "REPORT"];
});
```

`ApplicationUniqueCode` = `repositoryName.ToUpperInvariant()` ([naming.md](../../docs/naming.md)).

Future apps may declare different codes (e.g. `APPROVER`, `REVIEWER`) or an empty list (no required groups).

## Data path

1. `IBoCurrentUser.UserGUID` (required; no UPN fallback)
2. `System.P_GET_EACApplicationAccessContext` via `IBoIdentityConnectionFactory`
3. Derive visible contexts; cache snapshot
4. Resolver validates product `RequiredAttributeCodes` against RS3 **before** membership outcomes

## Cache

| Item | Value |
| --- | --- |
| Store | `IMemoryCache` |
| TTL | **60 seconds** (aligned with `SqlBoAuthorizationService.CacheTtl`) |
| Key | `bo-app-access:{uniqueCode}:{userGuid:D}` |
| Refresh | Absolute expiration — no app restart or logout required |

Bootstrap cache is independent of the group-Code authorization cache. Authorization must never be cached indefinitely.

## SP contract (EAC-owned)

Inputs: `@ApplicationUniqueCode`, `@UserGUID`.

| Result set | Content |
| --- | --- |
| RS1 | All AE contexts for the application |
| RS2 | Caller's APPSG AttributeCode memberships |
| RS3 | Configured AttributeCodes per AE (input to Step 1 config validation) |

`(ApplicationEnabledGUID, AttributeCode)` uniqueness is enforced by EAC (`UQ_EACSecurityGroups_ApplicationEnabled_AttributeCode`). Policy evaluation assumes uniqueness.
