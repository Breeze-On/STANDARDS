<!-- Classification: OPS; Scope: platform; Domain: Operations; Capability: CustomerOnboarding -->
# Operational runbooks

Owner: Operations

Operational runbooks document repeatable procedures for deploying, recovering, troubleshooting, and maintaining running systems.

**Customer-environment onboarding** (this folder’s Master Flow) provisions and activates customer DEV/UAT/PRD environments. It is **not** used to create new BreezeOn product applications (App #2 / App #3). Product application onboarding: [`docs/ai/BREEZEON-AI-APPLICATION-ADOPTION.md`](../docs/ai/BREEZEON-AI-APPLICATION-ADOPTION.md) · [`docs/application-model.md`](../docs/application-model.md).

## Current runbooks

| Runbook | Covers |
| --- | --- |
| [Customer Onboarding Master Flow](customer-onboarding-master-flow.md) | **Primary** end-to-end SSOT (intake + go-live checklist): intake → provisioning → Entra → consent → first login / tenant discovery → admin bootstrap (G) → Sync Now if Graph (F) → go-live |
| [EAC Application Configuration deployment](eac-application-configuration-deployment.md) | Export/import synchronize of Application Configuration between environments. Cross-kind promote order + envelope hazards: [`docs/data-portability.md` Kind catalog](../docs/data-portability.md#kind-catalog-semantic-families) (do not duplicate here). |

### Related slice procedures (architecture)

| Document | Covers |
| --- | --- |
| [Customer authentication onboarding](customer-onboarding-authentication.md) | Workflows A–F detail |
| [Customer onboarding — authorization](customer-onboarding-authorization.md) | Workflow G detail |

### Operator templates

| Template | Covers |
| --- | --- |
| [validate-onboarding-readiness.sql](../templates/onboarding/validate-onboarding-readiness.sql) | Read-only SQL checks for schema, tenants, sync, admin membership |
| [README — onboarding templates](../templates/onboarding/README.md) | How to run validation; consent URL copy-paste; App Service config checklist |

**Hosted deployment standard** (App Service stack, publish profile, GitHub Environment secrets, workflow convention): [`docs/hosted-deployment.md`](../docs/hosted-deployment.md). Do not fork that procedure into product repos or into ad-hoc runbooks without updating the standard first.

## Future runbooks

As operational practices are documented from current reality, this area may include runbooks for:

- Environment recovery / incident response (link to hosted-deployment for the deploy standard)
- Troubleshooting
- Secret rotation
- Operational maintenance

## For contributors

Add a runbook only when it describes a procedure that is actually used. Do not invent fictional runbooks. Link new runbooks from this README when they exist. Relative links must resolve from `runbooks/` (peer runbooks = same-folder filenames; AA under `../architecture/…`). Verify Workflow A–G navigation after edits.
