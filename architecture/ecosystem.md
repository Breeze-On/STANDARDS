# Architecture — Ecosystem

Current-state description of the Breeze On organization on GitHub.

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
| [Breeze-On/STANDARDS](https://github.com/Breeze-On/STANDARDS) | Org standards (`docs/`) and current architecture (`architecture/`) |
| [Breeze-On/.github](https://github.com/Breeze-On/.github) | Organization profile README (`profile/README.md`) |
| [Breeze-On/SYSTEM-ADMIN-ADM](https://github.com/Breeze-On/SYSTEM-ADMIN-ADM) | ADM — administration application (DV hosted on Azure App Service + Azure SQL) |
| [Breeze-On/SYSTEM-SHARED-UI](https://github.com/Breeze-On/SYSTEM-SHARED-UI) | Shared UI library (`BreezeOn.UI`) and local component gallery |

## Governance

STANDARDS is the single source of truth for conventions, for documenting systems that exist, and for Architecture Decision Records (`decisions/`). Product repos link to STANDARDS; they do not redefine org-wide rules.

Related: [application-model.md](../docs/application-model.md), [environments.md](../docs/environments.md), [adr.md](../docs/adr.md), [ADR-001 multi-repository](../decisions/ADR-001-multi-repository-model.md).
