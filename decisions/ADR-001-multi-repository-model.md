# ADR-001: Multi-repository model

Status: Accepted

## Context

Breeze On builds multiple purpose-built products and shared concerns (administration, shared UI, organization standards). Combining unrelated products into a single application repository would blur ownership, release cadence, and documentation boundaries. The organization already operates separate GitHub repositories under `Breeze-On` for standards, the administration app, the shared UI library, and the org profile.

## Decision

Use a **multi-repository** model: one repository per application or shared concern. Do not merge unrelated products into a single application repository. Cross-cutting conventions live in `Breeze-On/STANDARDS`; product and library repos stay thin and link to STANDARDS.

## Consequences

- Clear ownership and boundaries per repository (e.g. ADM vs Shared UI vs STANDARDS).
- Shared UI and other packages are consumed across repos rather than via a monorepo project graph.
- Documentation and ADRs for org-wide decisions belong in STANDARDS; product `README_AI` remains repo-specific.
- Agents must respect repository boundaries and not add unrelated domains into an existing product repo.
