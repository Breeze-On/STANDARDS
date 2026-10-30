# Operational runbooks

Owner: Operations

Operational runbooks document repeatable procedures for deploying, recovering, troubleshooting, and maintaining running systems.

## Current state

The organization currently maintains little operational documentation in this repository. This folder is the intended home for runbooks as they are written from real procedures.

**Hosted deployment standard** (App Service stack, publish profile, GitHub Environment secrets, workflow convention): [`docs/hosted-deployment.md`](../docs/hosted-deployment.md). Do not fork that procedure into product repos or into ad-hoc runbooks without updating the standard first.

## Future runbooks

As operational practices are documented from current reality, this area may include runbooks for:

- Environment recovery / incident response (link to hosted-deployment for the deploy standard)
- Troubleshooting
- Secret rotation
- Operational maintenance

## For contributors

Add a runbook only when it describes a procedure that is actually used. Do not invent fictional runbooks. Link new runbooks from this README when they exist.
