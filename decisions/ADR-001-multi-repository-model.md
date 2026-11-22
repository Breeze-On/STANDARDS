<!-- Classification: DEC; Scope: platform; Domain: Engineering; Capability: AdrProcess -->
# ADR-001: Multi-repository model

Status: Accepted

## Context

Breeze On builds multiple purpose-built products and shared concerns (administration, shared UI, organization standards). Combining unrelated products into a single application repository would blur ownership, release cadence, and documentation boundaries. The organization already operates separate GitHub repositories under `Breeze-On` for standards, the administration app, the shared UI library, and the org profile.

## Decision

Use a **multi-repository** model: one repository per application or shared concern. Do not merge unrelated products into a single application repository. Cross-cutting conventions live in `Breeze-On/STANDARDS`; product and library repos stay thin and link to STANDARDS.

## Consequences

- Clear ownership and boundaries per repository (e.g. EAC vs Shared UI vs STANDARDS).
- **Interim cross-repo consumption of SHARED-UI (current reality):** product apps use a **sibling repository checkout** and a **`ProjectReference`** to `SYSTEM-SHARED-UI` sources; CI typically checks out the **unpinned default branch HEAD**. This is **not** a NuGet/versioned package graph yet. Package versioning, pinning, and compatibility policy are **Future Validation** at application #2 kickoff — see [application-model.md](../docs/application-model.md) § Cross-repo consumption.
- Documentation and ADRs for org-wide decisions belong in STANDARDS; product `README_AI` remains repo-specific.
- Agents must respect repository boundaries and not add unrelated domains into an existing product repo.
- Every BreezeOn application **must consume** `BreezeOn.UI` (shell, `Bo*`, auth, authZ, page catalog) — mandatory, not optional ([application-model.md](../docs/application-model.md) § Platform consumption requirements).
