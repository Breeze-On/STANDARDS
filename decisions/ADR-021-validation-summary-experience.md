<!-- Classification: DEC; Scope: platform; Domain: Engineering; Capability: AdrProcess -->
# ADR-021: Validation Summary experience (live editors)

Status: Accepted

## Context

Large editable grids and Shuffle Card surfaces (Process Framework, Security Groups, configuration settings, and similar administrative tooling) surfaced validation failures mainly through field chrome, Alert toasts, and ad-hoc host bullet lists. Users often could not tell which row or field failed without hunting.

Import Summary already provides an Errors and Warnings review pattern for **pre-apply** workflows, but that dialog is not a live-editor Save surface. Deferred field chrome and section/tab fail badges remain correct for forms, yet they do not scale alone for multi-row editors.

## Decision

### Platform Validation Summary

Introduce a SHARED-UI presentational contract:

- `BoValidationIssue` / `BoValidationIssueSeverity`
- `BoValidationSummary` (collapsible, above-grid, navigate-to-error)
- Grid-family focus helpers for row/field navigation

Product hosts map domain validators into issues. SHARED-UI does not own product validators or SQL.

### Separate from Import Summary

Validation Summary is for **live Save/Commit** editors. Import Summary remains the **pre-apply** review dialog. Severity concepts align (Error blocks; Warning does not); controls do not merge.

### Co-required chrome

For Adoption Matrix **Required** experiences, failed Save/Commit must provide Validation Summary + deferred field chrome + Alert toast + navigate-to-error. Toast alone or host `<ul>` lists alone are non-compliant.

### Adoption Matrix

STANDARDS publish a Validation Summary Adoption Matrix (Required / Optional / Not Recommended). Planning Agents must evaluate summary vs field chrome vs toast vs navigate-to-error using that matrix before inventing validation UX.

### Grid Family ownership

- `BoGrid` surfaces Validation Summary above the table after failed attempts when failures exist.
- `BoShuffleCardGrid` remains host-owned for validation/Dirty/Save; hosts **must** compose Validation Summary above multi-row editable Shuffle editors.

## Consequences

- Configuration and Process Framework-style editors replace ad-hoc error lists with `BoValidationSummary`.
- Gallery ships a Validation Summary example (Example Governance).
- Planning / Development agents treat Adoption Matrix evaluation as a peer gate to Dirty State and UX Standards Compliance for multi-row validation UX.
- Field chrome SSOT stays in forms.md; summary does not introduce row washes.

## Related

- [ADR-004](ADR-004-breezeon-ui-abstraction-layer.md) — Bo* UI contract
- [ADR-017](ADR-017-application-configuration-deployment.md) / [ADR-018](ADR-018-data-entity-values-excel-portability.md) — Import Summary consumers
- SSOT: [validation-summary.md](../docs/ui/patterns/validation-summary.md)
- Sibling: [import-summary.md](../docs/ui/patterns/import-summary.md)
