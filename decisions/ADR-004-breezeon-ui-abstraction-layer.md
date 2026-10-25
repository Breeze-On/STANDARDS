# ADR-004: BreezeOn.UI abstraction layer

Status: Accepted

## Context

Multiple Breeze On Blazor applications need consistent branding, layout, and controls. Building each app directly on Fluent UI Blazor would couple product pages to a third-party component surface and make a future UI-stack change costly. The organization maintains `Breeze-On/SYSTEM-SHARED-UI` with a public `BreezeOn.UI` API (`Bo*` components) implemented on Fluent UI Blazor internally (Option B+).

## Decision

- **`BreezeOn.UI`** is the permanent public UI contract for the ecosystem (`Bo*` components, tokens, `AddBreezeOnUI`, theme/providers).
- **Fluent UI Blazor** is an **internal** implementation detail of `BreezeOn.UI`. Product application pages must not import or use `Microsoft.FluentUI.*` types.
- Shared UI capabilities are added or evolved through `BreezeOn.UI` and documented under [`docs/ui/`](../docs/ui/overview.md) (entry: [overview.md](../docs/ui/overview.md)).
- The Shared UI repository owns the library and gallery only — not ADM business domains or databases.

## Consequences

- Product apps depend on `BreezeOn.UI`; Fluent can be upgraded or replaced behind `Bo*` without rewriting feature pages.
- Gallery in `SYSTEM-SHARED-UI` exercises components locally without a database.
- STANDARDS `docs/ui/` must stay current when `Bo*` components ship (modular docs; update the UI index when structure grows).
- Agents must not expose Fluent types in public APIs or reverse-depend Shared UI on application repos.
