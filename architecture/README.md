<!-- Classification: AA; Scope: platform; Domain: Engineering; Capability: DocStandards -->
# Architecture

Owner: Architecture

Descriptions of **implemented** Breeze On systems. Answers: **what exists**.

Current reality only — do not place planned or speculative designs here. How we work: [`docs/`](../docs/). Why decisions were made: [`decisions/`](../decisions/). Shared vocabulary: [`docs/glossary.md`](../docs/glossary.md).

## Index

| Document | Covers |
| --- | --- |
| [Landscape](landscape.md) | Ecosystem map: repos, UI dependency position, Azure hosting, SQL relationships, boundaries |
| [Ecosystem](ecosystem.md) | Org identity and existing repositories |
| [EAC](applications/eac.md) | Enterprise Administration Center (current) |
| [Data Entities](data-entities/README.md) | Configurable master / reference data framework owned by EAC ([ADR-016](../decisions/ADR-016-data-entity-ownership.md)) |
| [Process Framework](process-framework/README.md) | Roles / Steps / Options configuration metadata (vision for the future Workflow Engine + current reality) owned by EAC ([ADR-019](../decisions/ADR-019-process-framework-metadata.md)) |
| [Process runtime](process-runtime/README.md) | Two-tier `Global.Process` + `{UniqueCode}.Process` + Process History; PE owns runtime ([ADR-024](../decisions/ADR-024-platform-process-root.md) · [ADR-025](../decisions/ADR-025-process-history.md) · [ADR-028](../decisions/ADR-028-process-runtime-ownership-process-engine.md)) |
| [Process Engine](process-engine/README.md) | Shared library `BreezeOn.ProcessEngine` — Current Implementation vs Future Direction ([ADR-026](../decisions/ADR-026-process-engine-and-metadata-framework.md)) |
| [Process Metadata Framework (runtime)](process-metadata/README.md) | Variable templates → tokens → Sequence\* → Request Number; disambiguate ADR-019 ([ADR-027](../decisions/ADR-027-request-number-and-sequence-allocation.md)) |
| [Application Configuration](app-configuration/README.md) | Application Configuration deployment between environments ([ADR-017](../decisions/ADR-017-application-configuration-deployment.md)) |
| [Identity & Authentication](identity-and-authentication/README.md) | **Start here** for end-user OIDC, Identity schema, App Registrations, config, local auth (platform standard) |
| [Authorization](authorization/README.md) | Security Groups, page security, `IBoAuthorizationService` (platform standard; [ADR-014](../decisions/ADR-014-platform-authorization.md)) |
| [Security](security.md) | SQL access / MI and secrets posture; end-user auth and authorization point to Identity & Authorization trees (dependency/vuln governance: [`docs/security-governance.md`](../docs/security-governance.md)) |
