<!-- Classification: AA; Scope: platform; Domain: Platform; Capability: AppConfiguration -->
# Architecture — Application Configuration

Owner: Architecture

EAC Application Configuration is the central configuration platform for BreezeOn applications. This tree describes **what exists** for configuration deployment between environments.

## Index

| Document | Covers |
| --- | --- |
| [Application Configuration deployment](application-configuration-deployment.md) | Synchronize-by-Code deployment model, Code matching, exclusions, schema versioning, section participation |
| [Configuration Session Cache](configuration-session-cache.md) | Circuit-scoped session baselines, segment classification, invalidation, Dirty State / Page Freeze, mandatory Configuration Session Review |

Decision: [ADR-017](../../decisions/ADR-017-application-configuration-deployment.md). Session cache: [ADR-020](../../decisions/ADR-020-configuration-session-cache.md). Application Context lifecycle: [ADR-006](../../decisions/ADR-006-application-context-ownership.md). Data Entity ownership: [ADR-016](../../decisions/ADR-016-data-entity-ownership.md). Process Framework (Roles / Steps / Options sections): [ADR-019](../../decisions/ADR-019-process-framework-metadata.md) · [architecture/process-framework](../process-framework/README.md). Product surface: [architecture/applications/eac.md](../applications/eac.md). JSON contract: [`docs/data-portability.md`](../../docs/data-portability.md). Schema inventory: EAC [`docs/db-model.md`](https://github.com/Breeze-On/SYSTEM-ADMIN-EAC/blob/main/docs/db-model.md).

## Ownership

| Concern | Owner |
| --- | --- |
| Import/export UI, validation, sync apply, SPs | SYSTEM-ADMIN-EAC |
| Platform deployment semantics / architecture | STANDARDS (`architecture/app-configuration/`) |
| Portable JSON contract | STANDARDS (`docs/data-portability.md`) |

## Definition of Done

Any change affecting Application Configuration **deployment semantics**, **JSON contract**, **sync apply**, or **section participation** is incomplete until this tree, related ADR(s), [`docs/data-portability.md`](../../docs/data-portability.md), EAC [`docs/db-model.md`](https://github.com/Breeze-On/SYSTEM-ADMIN-EAC/blob/main/docs/db-model.md), and thin product README pointers are updated in the **same change set**.
