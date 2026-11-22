<!-- Classification: DEC; Scope: platform; Domain: Security; Capability: Authorization -->
# ADR-014: Platform authorization

Status: Accepted

## Context

Authentication (Entra OIDC + Identity directory) is established ([ADR-009](ADR-009-entra-oidc-cookie-authentication.md)–[ADR-013](ADR-013-microsoft-graph-directory-synchronization.md)). Product hosts only required an authenticated user. Role-based authorization, Security Groups, and page security were not designed.

EAC is the administration surface for security access. Authorization must be a platform capability (SHARED-UI + customer DB), not an EAC-only fork. Page security must not be database-configurable. Logical relationships must use `UserGUID` ([ADR-010](ADR-010-platform-identity-schema.md)).

## Decision

- Platform schema **`Security`** in the customer database, owned by **SYSTEM-SHARED-UI** (`sql/security/`):
  - **`Security.Groups`** — `GroupsId`, `GroupGUID`, `Code`, `Name`, `Description`, `Metadata`, **`IsManuallyCreated`** (`BIT NOT NULL`, default `1`; lifecycle ownership SSOT: `1` manual, `0` automatic), ADR-005 audit columns. **No `IsEnabled`.** Column details: [security-schema-standard.md](../architecture/authorization/security-schema-standard.md).
  - **`Security.GroupsMembers`** — `GroupsMembersId`, `GroupMemberGUID`, `GroupGUID`, `UserGUID`, ADR-005 audit columns. Relationships by GUID only.
- Seed group **`GLOBAL-SYSTEM-ADMINISTRATORS`**. First membership is operator **Workflow G** (SQL bootstrap by `UserGUID`); no user/membership seed by default.
- Platform-global groups remain the foundation. **Object-owned administrator groups** (Applications, Business Entities, Application Enabled) — including Codes `APP_*` / `BUSENT_*` / `APPENA_*`, delete/edit rules, and data-security filters — are defined only in [ADR-015](ADR-015-object-owned-administrator-groups.md). Do not duplicate that decision here. Those Codes are **EAC naming** on the shared platform schema; other products are not required to adopt them. Application Context–scoped permissions beyond enablement visibility remain future work under [ADR-006](ADR-006-application-context-ownership.md).
- **Page security is code-based** — single product page catalog (`BoPageDefinition`). Do **not** create `Security.Pages` / `Security.PagesGroups`. Nav, Home cards, routes, and Access Denied derive from the same catalog.
- SHARED-UI **`IBoAuthorizationService`** is the sole **Code-based / page-catalog** authorization evaluation entry point. Products must not implement ad-hoc Code/page checks. Hybrid evaluation: load by `UserGUID` at login / short TTL cache — not a DB roundtrip every page render. **Object-admin data security** uses product GroupGUID membership checks (immediate SQL) — documented dual path in [authorization-standard.md](../architecture/authorization/authorization-standard.md).
- **Page security** (platform) vs **data security** (product SPs / retrieval contracts) remain separate concerns.
- UI Gallery does not apply page-security group restrictions.
- **Convention-based Security Group mutation APIs (accepted):** SHARED-UI `IBoSecurityGroupQueries` create/update/delete/member APIs **do not** enforce the calling actor’s group membership. **Authorization enforcement remains the responsibility of consuming applications** (typically `EnsureInGroupAsync` for GSA-gated operations, or named product exceptions such as EAC APPSG members portability). **Do not** add actor-based enforcement to SHARED-UI mutation APIs. Rationale: products own privileged-write surfaces and named exceptions; library-level actor parameters would either hard-code GSA-only or invent a parallel policy engine. Documented in [authorization-standard.md](../architecture/authorization/authorization-standard.md) § Privileged writes.

## Consequences

- Deploy order: Identity → Security → product schemas. Seed order includes Security groups after optional Identity tenants.
- EAC administers Groups UI; all products consume membership via SHARED-UI.
- Second (and later) product hosts **must** enforce authorization before calling SHARED-UI group mutation APIs; skipping that convention can grant GSA or mutate membership incorrectly.
- Docs: [architecture/authorization/](../architecture/authorization/README.md). Same-change-set updates with schema and SHARED-UI APIs.
- Sync Now / Users Security surfaces require `GLOBAL-SYSTEM-ADMINISTRATORS` once page security is wired.
- Object-scoped authorization SSOT: [ADR-015](ADR-015-object-owned-administrator-groups.md), [eac-authorization-matrix.md](../architecture/applications/eac-authorization-matrix.md).
