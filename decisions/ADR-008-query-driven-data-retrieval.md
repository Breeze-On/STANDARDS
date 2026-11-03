# ADR-008: Query-driven data retrieval

Status: Accepted

Category: UI + Data

## Context

Breeze On applications present searchable, filterable, sortable, paged lists (grids, Nested View hierarchies, drop-down catalogs). Without an org standard, each page tends to add its own retrieval shape: a grid stored procedure **plus** a companion “filter options” procedure, generic “distinct values for any schema / table / column” procedures, Apply buttons, per-keystroke queries, and UI code that talks to SQL. That multiplies contracts per dataset, makes behavior inconsistent (debounce, stale responses, sorting rules), and invites unsafe dynamic SQL.

[ADR-004](ADR-004-breezeon-ui-abstraction-layer.md) already establishes that the UI library (`BreezeOn.UI`) never talks to SQL or application repositories; the host application owns persistence and load. [database.md](../docs/database.md) already requires a documented need before introducing stored procedures. Neither defined how a **queryable dataset** should be retrieved end-to-end.

## Decision

Adopt the **Query-Driven Data Retrieval Standard** ([docs/ui/controls/query-driven-retrieval.md](../docs/ui/controls/query-driven-retrieval.md)):

- **One queryable dataset = one primary retrieval contract.** This is the approved org standard. The contract is owned by the **host application** (ADR-004); `BreezeOn.UI` never calls SQL.
- **Approved retrieval hierarchy** (prefer in this order):
  1. **Primary contract** — one contract may return the page of rows, `TotalCount`, Nested View children, and optional metadata.
  2. **Optional `@IncludeFilterMetadata`** — filter metadata may be requested on **initial load** only, not on every query.
  3. **App-service / EF Core** for simple distinct catalogs (drop-down sources) — preferred over new stored procedures.
  4. **Dedicated secondary contracts** only when justified **and** documented (rationale recorded; see exceptions).
- **Anti-pattern:** a dataset implemented as **Grid stored procedure + FilterOptions stored procedure** as the default shape. Companion filter-options procedures are not the default and must be challenged.
- **Forbidden:** generic dynamic filter-options procedures that accept schema / table / column names and return distinct values.
- **Pipeline:** every query applies **Filter → Sort → Pagination** in that order, on the server for server query grids.
- **Typed filters:** filters are expressed as typed filter operators (`BoQueryFilterOperator`: `In`, `Equals`, `Contains`) — a typed contract, not ad-hoc strings per page.
- **Sort governance:** sortable columns use a **whitelist**; unknown sort columns fall back to a safe default (never concatenated into SQL).
- **Interaction rules:** text filters execute after **debounce (~750ms)**, **Enter**, or **blur**; dropdown filters apply **immediately** on change; **no Apply button**. Requests use **cancellation / latest-wins**; a stale response **never** updates the UI.
- **Top-N for large drop-down sources:** default recommendation **100**, **configurable**, not a hard constant; **small** sets may preload fully.
- **Exceptions framework:** deviations are allowed only when justified, documented (product docs; ADR when it sets a pattern), and approved. **Known approved exception:** EAC **Business Entities → Business Hierarchy** full-tree load (hierarchy path, cycle checks, and cascade selection need the whole tree).
- **Planning Agents** must default to **one primary retrieval contract per dataset**, **challenge** any proposed secondary contract, **require rationale**, and **document exceptions**.

## Consequences

- Fewer SQL objects per dataset; one contract to test, document in `docs/db-model.md`, and evolve.
- Consistent UX across apps: same filter execution, sort, pagination, and cancellation behavior.
- Simple catalogs stay in EF / app services; stored procedures remain for justified needs (consistent with [database.md](../docs/database.md)).
- Pages with full-tree or small preloaded datasets remain valid when documented as exceptions or as small-set preloads.
- Existing companion FilterOptions procedures in products are migration candidates; new work must not introduce them by default.
- `BoGrid` Client mode (full cache) remains the default; Server `QueryMode` is documented in [grids.md](../docs/ui/controls/grids.md#server-querymode).
- Planning Agents get a short default rule in [BREEZEON-AI-QUICKSTART.md](../docs/ai/BREEZEON-AI-QUICKSTART.md) and [README_AI.md](../README_AI.md).
