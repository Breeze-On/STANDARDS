<!-- Classification: AN; Scope: platform; Domain: Engineering; Capability: DocStandards -->
# Testing

Owner: Documentation

**Status:** Partially defined (EAC framework sync slice only). Broader org-wide testing standards are not yet formalized.

## EAC framework deploy validation (current)

For EAC framework SQL / allowlist synchronization ([database.md](database.md) § EAC Framework Synchronization):

| Layer | Role |
| --- | --- |
| **Local consolidator fail-fast** | **Primary** — `dev-reset`, `export-current-model`, and consolidation generation fail when a `sql/current_model` source is not allowlisted or an allowlist entry is missing. |
| **Post-reset required-object smoke** | Defense in depth — `OBJECT_ID` checks from `sql/framework-required-objects.json` before seed. |
| **EAC CI (`framework-sync` workflow)** | **Secondary safety net** — allowlist ↔ folder parity, committed `current_model.sql` source coverage, manifest coverage (`scripts/validate-framework-sync.ps1`). |

CI does not replace local fail-fast. Consumer bootstrap must not be the first detector of missing framework objects.

## Scope of future standards

When conventions are established more broadly, this document may also cover:

- Unit testing
- Integration testing
- Smoke testing
- Naming conventions
- Coverage expectations

## Current practice (other areas)

Until organization-wide standards exist for those areas, repositories may implement testing approaches independently. Local test scripts and CI checks in a given repo are that repo’s practice, not org standards, unless documented here.

## For contributors

When testing conventions become agreed and implemented across the organization, update this document to describe **current reality only**. Do not invent testing requirements ahead of adoption.
