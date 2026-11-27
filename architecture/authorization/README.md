<!-- Classification: AA; Scope: platform; Domain: Security; Capability: Authorization -->
# Architecture — Authorization

Owner: Architecture

Platform authorization for BreezeOn product applications. Answers: **what exists** for Security Groups, page security, and the SHARED-UI authorization service.

Authentication / Identity remain under [Identity & Authentication](../identity-and-authentication/README.md). Dependency/vuln governance: [`docs/security-governance.md`](../../docs/security-governance.md).

## Index

| Document | Covers |
| --- | --- |
| [Authorization standard](authorization-standard.md) | Groups model, dual evaluation paths, convention-based mutation APIs, named EAC exceptions, page vs data boundary |
| [Security schema standard](security-schema-standard.md) | `Security.Groups` / `GroupsMembers` |
| [Page security standard](page-security-standard.md) | Code-based page catalog; nav / home / route / Access Denied |
| [EAC authorization matrix](../applications/eac-authorization-matrix.md) | Capability × persona for Applications, Business Entities, enablement, groups |
| [Customer onboarding — authorization](../../runbooks/customer-onboarding-authorization.md) | Workflow G bootstrap administrator (slice detail) |
| [Customer Onboarding Master Flow](../../runbooks/customer-onboarding-master-flow.md) | End-to-end onboarding (Step 7 = Workflow G admins only; Step 8 / Workflow F = sole `IsSyncEnabled` + optional Sync Now) |

Decisions: [ADR-014](../../decisions/ADR-014-platform-authorization.md) (platform authorization), [ADR-015](../../decisions/ADR-015-object-owned-administrator-groups.md) (object-owned administrator groups).

## Ownership

| Concern | Owner |
| --- | --- |
| `Security` schema T-SQL + seed | breezeon-system-shared-ui (`sql/security/`) |
| `IBoAuthorizationService`, page catalog types, Access Denied | breezeon-system-shared-ui (`BreezeOn.UI`) |
| Product page catalogs / Groups admin UI | Product apps (EAC first) |
| Physical tables | Customer database |

## Definition of Done

A change affecting authorization architecture, Security schema, page security, or bootstrap onboarding is incomplete until this tree, related ADR(s), and product thin docs are updated in the **same change set**. When Workflow G or end-to-end onboarding checkpoints change, also update the [Customer Onboarding Master Flow](../../runbooks/customer-onboarding-master-flow.md).
