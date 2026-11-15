# Operational runbooks

Owner: Operations

Operational runbooks document repeatable procedures for deploying, recovering, troubleshooting, and maintaining running systems.

## Current runbooks

| Runbook | Covers |
| --- | --- |
| [Customer Onboarding Master Flow](customer-onboarding-master-flow.md) | **Primary** end-to-end SSOT (intake + go-live checklist): intake → provisioning → Entra → consent → first login / tenant discovery → admin bootstrap (G) → Sync Now if Graph (F) → go-live |

### Related slice procedures (architecture)

| Document | Covers |
| --- | --- |
| [Customer authentication onboarding](../architecture/identity-and-authentication/customer-onboarding-authentication.md) | Workflows A–F detail |
| [Customer onboarding — authorization](../architecture/authorization/customer-onboarding-authorization.md) | Workflow G detail |

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

Add a runbook only when it describes a procedure that is actually used. Do not invent fictional runbooks. Link new runbooks from this README when they exist.
