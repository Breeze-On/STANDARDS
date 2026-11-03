# UI — Query-driven retrieval

Owner: UI

Normative standard for retrieving **queryable datasets** (filterable / sortable / paged lists and Nested View hierarchies) in Breeze On applications. Decision record: [ADR-008](../../../decisions/ADR-008-query-driven-data-retrieval.md).

Related: [grids.md](grids.md) (Server `QueryMode`), [forms.md](forms.md) (filter controls), [database.md](../../database.md) (query-driven paged list stored procedures), [page-development.md](../page-development.md), [overview.md](../overview.md), [ADR-004](../../../decisions/ADR-004-breezeon-ui-abstraction-layer.md).

Current reality only. Product implementations (for example EAC Applications) are described in [architecture/eac.md](../../../architecture/eac.md).

## Ownership (ADR-004)

| Layer | Owns |
| --- | --- |
| `BreezeOn.UI` | Render surface, filter / sort / paging chrome and typed query types (`BoQuery*`, e.g. `BoQueryFilterOperator`). **Never** talks to SQL or application repositories |
| Host application | The **primary retrieval contract** for each dataset: app service, EF Core, and/or stored procedure; fills `BoGridCache` with the current result |

## One Dataset standard (approved org standard)

**One queryable dataset = one primary retrieval contract.**

The primary contract may return, in one round trip:

- the current page of **rows**;
- **`TotalCount`** (rows matching the filter, before pagination);
- **Nested View children** (roots paged; children attached) when the dataset is hierarchical;
- optional **metadata** (for example filter metadata on initial load).

## Approved retrieval hierarchy

Prefer in this order:

| # | Approach | Rule |
| --- | --- | --- |
| 1 | **Primary contract** | Rows / `TotalCount` / Nested View children / optional metadata |
| 2 | **`@IncludeFilterMetadata`** (optional) | Request filter metadata on the **initial load** only — not on every query |
| 3 | **App service / EF Core** | Preferred for **simple distinct catalogs** (drop-down sources) instead of new stored procedures |
| 4 | **Dedicated secondary contract** | Only when **justified and documented** (rationale in product docs; see [Exceptions](#exceptions)) |

## Anti-pattern

**Do not default to:** Dataset = **Grid stored procedure + FilterOptions stored procedure**.

A companion FilterOptions procedure is not the default shape of a dataset. Challenge it; use the hierarchy above first.

**Forbidden:** generic dynamic filter-options procedures that take a schema, table, and column name and return distinct values. They bypass the typed contract, resist review, and are an injection / permission risk.

## Filter → Sort → Pagination

Server query execution order is fixed:

1. **Filter** (keyword + typed filters)
2. **Sort** (whitelisted column + direction)
3. **Pagination** (page number + page size)

`TotalCount` is the count after Filter, before Pagination.

**Nested View + keyword:** parent/child result selection and path-minimal search expansion follow the org standard in [grids.md — Nested View keyword filtering](grids.md#nested-view-keyword-filtering-org-standard) (primary contract owns child selection; host page owns expand keys = ancestors required to reveal matching rows while keyword is active). Under an approved **full-load** Nested View exception, apply the same Rules 1–2 **client-side** over the loaded tree — do not introduce a paged keyword SP solely to satisfy this standard.

### Typed filter operators

Filters are typed (`BoQueryFilterOperator`):

| Operator | Meaning |
| --- | --- |
| `In` | Value is one of a set (multi-select drop-down) |
| `Equals` | Exact match (single-select drop-down) |
| `Contains` | Substring match (text filter) |

### Sort column whitelist

Sortable columns are a **whitelist** owned by the host / procedure. An unknown column or direction falls back to a **safe default** order; it is never concatenated into SQL unchecked.

## Interaction rules (filters)

| Control | Behavior |
| --- | --- |
| Text filter | Executes after **debounce (~750ms)**, **Enter**, or **blur**. Skip when the value is unchanged. |
| Dropdown filter | Applies **immediately** on change |
| Apply button | **None** — filters are live |

Control detail: [forms.md — Filter execution](forms.md#filter-execution-query-driven).

## Request cancellation / latest-wins

- A new query **cancels** the in-flight query (cancellation token).
- **Latest wins:** only the response for the newest request may update UI state.
- A **stale** response **never** updates the UI (grid cache, total count, dropdown items).

## Top-N and preload

| Dataset size | Behavior |
| --- | --- |
| Small catalog | May **preload** fully |
| Large catalog | **Top-N** rows plus **server search** as the user types |

- Default Top-N recommendation: **100**.
- Top-N is **configurable**, not a hard constant in shared code.

## Exceptions

An exception to the One Dataset standard (for example a justified secondary contract, or a full-tree load) is allowed only when:

1. The need is **justified** (data shape, correctness, or size — not convenience);
2. The rationale is **documented** (product `docs/db-model.md` / architecture doc; ADR if it sets a pattern);
3. The primary-contract default was **challenged** first.

**Known approved exception:** EAC **Business Entities → Business Hierarchy** loads the **full tree** (hierarchy path, cycle checks, cascade selection require it). Keyword filtering on that tab still follows [Nested View keyword filtering](grids.md#nested-view-keyword-filtering-org-standard) with **client-side** result selection over the loaded tree (no server-paged Hierarchy contract). See [architecture/eac.md](../../../architecture/eac.md#business-entities).

## Planning Agent rules

Planning Agents (and build agents) must:

1. Default to **one primary retrieval contract** per dataset.
2. **Challenge** any proposed secondary contract (especially a companion FilterOptions procedure).
3. **Require a rationale** for any secondary contract or exception.
4. **Document exceptions** (see above).
5. Prefer EF / app services for simple distinct catalogs; never propose generic schema / table / column distinct procedures.
6. For Nested View keyword filters, default to [Nested View keyword filtering](grids.md#nested-view-keyword-filtering-org-standard) (parent match → full child context; child match → matching branches only; path-minimal expand = ancestors of matches only) unless a documented exception exists.

Page checklist: [page-development.md](../page-development.md).

## Documentation governance

Update this file, [grids.md](grids.md), [forms.md](forms.md), [database.md](../../database.md), [page-development.md](../page-development.md), and [ADR-008](../../../decisions/ADR-008-query-driven-data-retrieval.md) in the same change set when the standard changes. Current reality only.
