# UI — Example Governance

Owner: UI

Organization standard for how UI and query-driven standards become **fully implemented**. Related: [overview.md](overview.md), [documentation.md](../documentation.md), [page-development.md](page-development.md), [ADR-004](../../decisions/ADR-004-breezeon-ui-abstraction-layer.md).

Current reality only.

## Definition of Done (UI / query standards)

A Breeze On UI or query-driven standard is **not fully implemented** until all three exist:

| Layer | Where it lives | Purpose |
| --- | --- | --- |
| **1. Normative standard** | STANDARDS (`docs/ui/…`, ADRs as needed) | Rules, requirements, exceptions, governance |
| **2. AI guidance** | Quickstart, AI Standards Summary, and/or repo `README_AI.md` | How Planning / build agents apply the standard |
| **3. Working example** | [SYSTEM-SHARED-UI](https://github.com/Breeze-On/SYSTEM-SHARED-UI) Gallery (`BreezeOn.UI.Gallery`) | Real, copyable, verified behavior |

Missing any layer means the standard is **incomplete**. Prefer completing the missing layer over inventing a second document.

## Ownership

| Concern | Owner |
| --- | --- |
| Normative rules | STANDARDS |
| AI onboarding pointers | STANDARDS `docs/ai/` + thin product / Shared UI `README_AI.md` |
| Working examples for **library-scoped** patterns | SHARED-UI Gallery |
| Product contracts (SP shapes, EF catalogs, domain pages) | Product repo (`docs/db-model.md`, architecture) — not Gallery |

Gallery is the **primary discoverability** mechanism for developers and agents for `Bo*` / query host patterns. Product pages (for example EAC) are **product reference**, not substitutes for Gallery when the pattern is library-scoped.

## Planning Agent rules

1. When applying a UI / query standard, prefer the **Gallery working example** as the practical copy source, then confirm against the normative SSOT.
2. **Challenge** standards that exist only as documentation (or only as product-page prose) without a Gallery example — unless an explicit exception below applies.
3. Do **not** treat product `README_AI` mega-bullets as the normative SSOT; they must link to STANDARDS.
4. Same change set: normative change → AI index update → Gallery update (or a labeled **example pending** note with owner).

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

## Documentation governance

Update this file, [overview.md](overview.md), and [documentation.md](../documentation.md) in the same change set when Example Governance rules change. Index new Gallery demos from the relevant control SSOT (`grids.md`, `forms.md`, …) and SHARED-UI README.
