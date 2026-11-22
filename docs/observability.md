<!-- Classification: AN; Scope: platform -->
# Observability

Owner: Documentation

**Status:** Not yet formally defined.

Breeze On does not currently maintain organization-wide observability standards.

## Scope of future standards

When conventions are established, this document may cover areas such as:

- Logging
- Telemetry
- Monitoring
- Metrics
- Health checks
- Alerting

## Current practice

Until organization-wide standards exist, repositories may implement logging and related practices independently. Do not treat one repo’s approach as an org standard unless it is written here.

**Example (repository practice, not org-wide):** SYSTEM-ADMIN-EAC Excel Import Analyze emits opt-in **Debug** stage timings under logger category `BreezeOn.Eac.DataEntities.Excel.Analyze` (`OperationId` + stage milliseconds). See EAC `README_AI.md` § Excel Import Analyze — performance diagnostics and [ADR-018](../decisions/ADR-018-data-entity-values-excel-portability.md).

## For contributors

When observability conventions become agreed and implemented across the organization, update this document to describe **current reality only**. Do not create requirements or implementation mandates ahead of adoption.
