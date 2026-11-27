<!-- Classification: AA; Scope: platform; Domain: UI; Capability: Patterns -->
# UI — Example Governance

Owner: UI

Organization standard for how UI and query-driven standards become **fully implemented**, and for **authority when Gallery and STANDARDS disagree**. Related: [overview.md](overview.md), [documentation.md](../documentation.md), [page-development.md](page-development.md), [ADR-004](../../decisions/ADR-004-breezeon-ui-abstraction-layer.md).

Current reality only.

## Design / composition authority (locked)

**STANDARDS documentation is always the source of truth** for how applications must look, behave, and compose pages.

| Rank | Artifact | Role |
| --- | --- | --- |
| 1 | STANDARDS documentation (`docs/ui/`, process docs) | **Authoritative** UX / composition / process rules |
| 2 | ADRs | Architectural decisions that constrain standards |
| 3 | Architecture documents | Platform shape; not a substitute for `docs/ui/` composition rules |
| 4 | Product / application AA docs | App-owned schema, seed, product contracts |
| 5 | SHARED-UI **implementation** (`BreezeOn.UI` `Bo*` / services) | Reusable assets that **implement** standards |
| 6 | SHARED-UI **Gallery / examples** | **Illustrative only** — demonstrate usage; accelerate copy |

**Conflict rule (locked):** If a Gallery page, sample, or copy-source composition **disagrees** with STANDARDS, **STANDARDS win**. Fix the Gallery (and any app that copied the drift) in the same change set. Do **not** treat Gallery as a de facto standard. Do **not** invent product exceptions to “match Gallery.”

### SHARED-UI vs Gallery

| SHARED-UI owns (reuse these) | Gallery is (not authority) |
| --- | --- |
| Reusable `Bo*` controls and layout primitives | Usage demos and composition samples |
| Reusable services (`IBoPageFreezeService`, lookup queries, …) | Acceleration for developers and agents |
| Library-scoped patterns expressed as components | **Not** architecture standards; **not** overrides of STANDARDS |

**Design order:** new applications and features are designed from **STANDARDS first**, then implemented by consuming SHARED-UI components and services. Gallery may accelerate composition **after** the normative SSOT is confirmed.

## Definition of Done (UI / query standards)

A Breeze On UI or query-driven standard is **not fully implemented** until all three exist **and agree**:

| Layer | Where it lives | Purpose |
| --- | --- | --- |
| **1. Normative standard** | STANDARDS (`docs/ui/…`, ADRs as needed) | Rules, requirements, exceptions, governance (**SSOT**) |
| **2. AI guidance** | Quickstart, AI Standards Summary, and/or repo `README_AI.md` | How Planning / build agents apply the standard |
| **3. Working example** | [breezeon-system-shared-ui](https://github.com/Breeze-On/breezeon-system-shared-ui) Gallery (`BreezeOn.UI.Gallery`) | Real, copyable, **STANDARDS-compliant** behavior |

Missing any layer means the standard is **incomplete**. A Gallery demo that contradicts STANDARDS is a **defect**, not an alternate standard. Prefer completing or correcting the missing/wrong layer over inventing a second document.

## Ownership

| Concern | Owner |
| --- | --- |
| Normative rules | STANDARDS |
| AI onboarding pointers | STANDARDS `docs/ai/` + thin product / Shared UI `README_AI.md` |
| Working examples for **library-scoped** patterns | SHARED-UI Gallery (**must conform** to STANDARDS) |
| Product contracts (SP shapes, EF catalogs, domain pages) | Product repo (`docs/db-model.md`, architecture) — not Gallery |

Gallery is the **primary discoverability** mechanism for developers and agents for `Bo*` / query host patterns. Product pages (for example EAC) are **product reference**, not substitutes for Gallery when the pattern is library-scoped — and neither Gallery nor product pages outrank STANDARDS.

## Planning Agent rules

1. **STANDARDS first.** Read the normative SSOT before copying any Gallery composition.
2. Prefer the **Gallery working example** as the practical copy source for library patterns **only after** confirming it matches the normative SSOT. If they conflict, follow STANDARDS and treat Gallery as broken.
3. **Challenge** standards that exist only as documentation (or only as product-page prose) without a Gallery example — unless an explicit exception below applies.
4. Do **not** treat product `README_AI` mega-bullets or Gallery markup as the normative SSOT; they must link to / obey STANDARDS.
5. Same change set: normative change → AI index update → Gallery update (or a labeled **example pending** note with owner). Same change set when fixing Gallery drift: Gallery + any copied product pages + STANDARDS clarification if the rule was ambiguous.
6. Every UI-bearing plan must include a **UX Standards Compliance Review** subsection before development — peer gate to architecture/data/security. Required fields: Shared UI components reused, Gallery examples reviewed **against STANDARDS**, applicable UX standards, Page Freeze, placeholders, navigation-state, truncation, disabled/read-only, intentional deviations — [ux-conventions.md](patterns/ux-conventions.md).
7. Architecture approval is **not** UX approval. Incomplete UX discovery is a planning defect.

## Development Agent rules

1. Consume SHARED-UI components and services; do not re-implement chrome Fluent already wraps behind `Bo*`.
2. Follow STANDARDS documentation for placement, weight, tabs, freeze, and composition.
3. Do **not** assume a Gallery example is automatically compliant — verify against STANDARDS before / while copying.
4. When fixing a STANDARDS violation that came from Gallery drift, correct Gallery in the same change set when the pattern is library-scoped.

## Gallery coverage and registered gaps

Pattern → Gallery path: [gallery-index.md](gallery-index.md). Patterns **without** a demo are registered as explicit time-boxed exceptions in [DEV-002 § Registry](../deviations/DEV-002-example-governance-approved-exceptions.md#registry).

## Approved exceptions (no Gallery requirement)

| Exception | Where the example lives |
| --- | --- |
| Stored procedure / SQL primary contracts | Product `docs/db-model.md` (+ architecture) |
| Product-domain EF catalogs and enablement UX | Product pages + product docs |
| Hosted deployment / environments / secrets | STANDARDS ops docs (not UI Gallery) |

## Anti-patterns

- Documenting library behavior **only** in a product README
- Duplicating normative Rules into AI summaries (summaries **link**; they do not restate)
- Shipping a Gallery demo that talks to product SQL (violates ADR-004)
- Marking a standard “done” when only the markdown SSOT exists
- Treating Gallery composition as authoritative when it contradicts STANDARDS
- Designing a product page from Gallery alone without opening the STANDARDS SSOT
- Leaving Gallery drift unfixed after an app was corrected to match STANDARDS

## Documentation governance

Update this file, [overview.md](overview.md), and [documentation.md](../documentation.md) in the same change set when Example Governance rules change. Index new Gallery demos from the relevant control SSOT (`grids.md`, `forms.md`, …) and SHARED-UI README.
