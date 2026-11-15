# Architecture — Authorization

Owner: Architecture

Platform authorization for BreezeOn product applications. Answers: **what exists** for Security Groups, page security, and the SHARED-UI authorization service.

Authentication / Identity remain under [Identity & Authentication](../identity-and-authentication/README.md). Dependency/vuln governance: [`docs/security-governance.md`](../../docs/security-governance.md).

## Index

| Document | Covers |
| --- | --- |
| [Authorization standard](authorization-standard.md) | Groups model, `IBoAuthorizationService`, evaluation, page vs data boundary |
| [Security schema standard](security-schema-standard.md) | `Security.Groups` / `GroupsMembers` |
| [Page security standard](page-security-standard.md) | Code-based page catalog; nav / home / route / Access Denied |
| [Customer onboarding — authorization](customer-onboarding-authorization.md) | Workflow G bootstrap administrator (slice detail) |
| [Customer Onboarding Master Flow](../../runbooks/customer-onboarding-master-flow.md) | End-to-end onboarding (Step 8 = Workflow G) |

Decision: [ADR-014](../../decisions/ADR-014-platform-authorization.md).

## Ownership

| Concern | Owner |
| --- | --- |
| `Security` schema T-SQL + seed | SYSTEM-SHARED-UI (`sql/security/`) |
| `IBoAuthorizationService`, page catalog types, Access Denied | SYSTEM-SHARED-UI (`BreezeOn.UI`) |
| Product page catalogs / Groups admin UI | Product apps (EAC first) |
| Physical tables | Customer database |

## Definition of Done

A change affecting authorization architecture, Security schema, page security, or bootstrap onboarding is incomplete until this tree, related ADR(s), and product thin docs are updated in the **same change set**. When Workflow G or end-to-end onboarding checkpoints change, also update the [Customer Onboarding Master Flow](../../runbooks/customer-onboarding-master-flow.md).
