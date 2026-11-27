<!-- Classification: AA; Scope: platform; Domain: Engineering; Capability: DocStandards -->
# Architecture — Ecosystem

Owner: Architecture

Current-state description of the Breeze On organization on GitHub.

For a high-level map of repository relationships, UI dependency position, Azure hosting, and SQL (local vs DEV), see [landscape.md](landscape.md).

## Identity

| | |
| --- | --- |
| Display name | Breeze On |
| GitHub org | `Breeze-On` |
| Positioning | Purpose-driven applications; process-driven intelligence |
| Principles | Objective → Process → Decision → Action → Outcome |
| Key message | One ecosystem. Multiple purpose-built applications. Process-driven intelligence. |

## Repository model

Multi-repo: one repository per application or shared concern. Unrelated products are not combined into a single application repository.

## Repositories (existing)

| Repository | Role |
| --- | --- |
| [`Breeze-On/standards`](https://github.com/Breeze-On/standards) | Org standards (`docs/`) and current architecture (`architecture/`) |
| [Breeze-On/.github](https://github.com/Breeze-On/.github) | Organization profile README (`profile/README.md`) |
| [`Breeze-On/breezeon-system-admin-eac`](https://github.com/Breeze-On/breezeon-system-admin-eac) | EAC — administration application (DEV hosted on Azure App Service + Azure SQL) |
| [`Breeze-On/breezeon-system-shared-ui`](https://github.com/Breeze-On/breezeon-system-shared-ui) | Shared UI library (`BreezeOn.UI`): UI + auth + authorization frameworks; Identity/Security SQL definitions; local component gallery — **mandatory** for BreezeOn applications |
| [`Breeze-On/breezeon-system-process-engine`](https://github.com/Breeze-On/breezeon-system-process-engine) | Process Engine shared library (`BreezeOn.ProcessEngine`) |
| [`Breeze-On/breezeon-corp-fin-inv`](https://github.com/Breeze-On/breezeon-corp-fin-inv) | INV — Invoice Approval Request product host |

Repository naming (lowercase kebab-case): [naming.md](../docs/naming.md) § Repositories.

## Governance

`standards` is the single source of truth for conventions, for documenting systems that exist, and for Architecture Decision Records (`decisions/`). Product repos link to `standards`; they do not redefine org-wide rules.

Related: [landscape.md](landscape.md), [application-model.md](../docs/application-model.md), [environments.md](../docs/environments.md), [adr.md](../docs/adr.md), [ADR-001 multi-repository](../decisions/ADR-001-multi-repository-model.md).
