<!-- Classification: ENT; Scope: platform; Domain: Engineering; Capability: DocStandards -->
# README_AI — STANDARDS

## Mandatory AI reading order

**Always** follow [`docs/ai/README.md`](docs/ai/README.md) first (Quickstart → governance → planning → summary → adoption → product `README_AI`).

## Document precedence

See [`docs/documentation.md`](docs/documentation.md) § Source-of-truth and precedence. Summary:

1. Code / SQL in owning repo  
2. STANDARDS AA  
3. Approved deviations (`docs/deviations/`)  
4. Shared-library AA / application AA  
5. Runbooks → ADRs → entry files → plans/history  

## This repository

Owns org-wide standards, platform architecture, ADRs, runbooks, deviations, and AI process docs. Does **not** host product business code.

## Task → doc routing

| Task | Read |
| --- | --- |
| Doc architecture / classification / README rules | [`docs/documentation.md`](docs/documentation.md) |
| AI doc catalog (Domain → Entry Point → Capability) | [`docs/ai/ai-catalog.json`](docs/ai/ai-catalog.json) · schema [`ai-catalog.schema.json`](docs/ai/ai-catalog.schema.json) |
| Review finding format (ad-hoc) | [`docs/review-governance.md`](docs/review-governance.md) |
| New Application Checklist (bootstrap gate) | [`docs/application-bootstrap-checklist.md`](docs/application-bootstrap-checklist.md) · [`docs/ai/application-development-process.md`](docs/ai/application-development-process.md) |
| UI behavior / page construction | [`docs/ui/overview.md`](docs/ui/overview.md) · [`page-development.md`](docs/ui/page-development.md) |
| Process View / Save·Submit persistence | [`docs/ui/patterns/process-view.md`](docs/ui/patterns/process-view.md) · [`process-persistence.md`](docs/ui/patterns/process-persistence.md) · [`process-history.md`](docs/ui/patterns/process-history.md) |
| Process runtime (`Global.Process` / `ProcessHistory`, two-tier) | [`architecture/process-runtime/README.md`](architecture/process-runtime/README.md) · [ADR-024](decisions/ADR-024-platform-process-root.md) · [ADR-025](decisions/ADR-025-process-history.md) · [`docs/database.md`](docs/database.md) § Process table convention |
| Database / seed | [`docs/database.md`](docs/database.md) · [`local-database.md`](docs/local-database.md) |
| Identity / auth | [`architecture/identity-and-authentication/`](architecture/identity-and-authentication/README.md) |
| Authorization | [`architecture/authorization/`](architecture/authorization/README.md) |
| EAC (application reference) | [`architecture/applications/`](architecture/applications/README.md) |
| Construct selection / App Config JSON hazards (**EAC-scoped**) | [`architecture/app-configuration/construct-selection.md`](architecture/app-configuration/construct-selection.md) |
| Variables / DE / PF AI authoring (**EAC-scoped**) | [`variables/ai-authoring-contract.md`](architecture/variables/ai-authoring-contract.md) · [`data-entities/ai-authoring-contract.md`](architecture/data-entities/ai-authoring-contract.md) · [`process-framework/ai-authoring-contract.md`](architecture/process-framework/ai-authoring-contract.md) |
| Dependency / vulnerability policy (Phase 1 gates) | [`docs/security-governance.md`](docs/security-governance.md) |
| Runbooks (OPS procedures index) | [`runbooks/README.md`](runbooks/README.md) |
| Templates (operator / agent / SQL / Dependabot starters) | [`templates/`](templates/) · [`templates/onboarding/`](templates/onboarding/README.md) · [`templates/cursor-rules/`](templates/cursor-rules/README.md) · [`templates/dependabot/`](templates/dependabot/dependabot.yml) |
| Exceptions | [`docs/deviations/`](docs/deviations/README.md) |
| ADRs | [`decisions/README.md`](decisions/README.md) |

## Documentation duty

Update AA docs in the **same change set** as reality changes. Entry files stay thin — no new technical contracts here.
