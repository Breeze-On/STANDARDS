<!-- Classification: AA; Scope: application:eac; Domain: Platform; Capability: DataEntities -->
# Data Entities standard

Owner: Architecture (EAC)

Authoritative business and platform rules for BreezeOn **Data Entities** — EAC’s **reference-data** capability (not a generic master-data platform, not a platform-wide consumption API).

Authoring: [authoring-guide.md](authoring-guide.md) · AI: [ai-authoring-contract.md](ai-authoring-contract.md) · Examples: [worked-examples.md](worked-examples.md) · Non-normative consumer notes: [using-data-entities.md](using-data-entities.md).

---

## Business meaning (normative)

### What a Data Entity is

A **Data Entity** is an administrator-maintained, **named list of business reference items**. Each item (row) has a **Code**, a **Description** (business name), an order, and optional flat attributes (columns). Each Application Context (Business Entity) keeps its **own copy of the items** under a shared Application-level definition.

**Problem solved:** one governed reference list reused by processes and configuration — without inventing per-application lookup tables.

### What belongs in Data Entities (v1)

| Fits | Examples |
| --- | --- |
| Flat administrator-maintained **reference data** | Cost Centers, Regions, Countries, Request Types, Statuses, Categories, Departments |

### What does **not** belong (today)

| Does not fit | Why |
| --- | --- |
| Customers, Vendors, Employees, Projects, Equipment, Vehicles | Need relationships, lifecycle, constraints, richer modelling — **application-owned** until those capabilities exist |
| Invoices, Purchase Requests, Timesheets, transactions, business events | Transactional / operational documents |

Prefer the term **reference data** (not “master data platform”) throughout.

### v1 limitations (intentionally flat)

| Not in v1 |
| --- |
| Relationships / references between entities |
| Required or unique attribute constraints on columns |
| Person / people-picker column types |
| Advanced row lifecycle (retire / active / effective dating / soft delete) |

Richer capabilities = **Future Validation** only — do not invent them here.

### When to create what

| Action | When |
| --- | --- |
| **New Data Entity** | Distinct business list (owner, vocabulary, or lifecycle of the *list*) |
| **New row** | New member of an existing list |
| **New column** | New flat attribute that describes each item |
| **Not DE** | Item belongs in the [Business Entity](../../docs/glossary.md#business-entity) hierarchy (org node that gets its own context) |

### Which construct do I use?

**Normative SSOT:** [construct-selection.md](../app-configuration/construct-selection.md) (Variable · Data Entity · Process Framework · Business Entity · Security Group).

DE consumers: Process Framework **DDL** metadata (stores Data Entity **row Code**) and product `{UniqueCode}.Process` apps, which read rows only through `System.P_GET_EACDataEntityLookupValues` + SHARED-UI `IBoDataEntityLookupQueries` and persist **`*Code`** ([using-data-entities.md](using-data-entities.md), [ADR-023](../../decisions/ADR-023-consumer-data-entity-lookup.md)).

### Ownership (business)

| Role | Reality |
| --- | --- |
| **Application Administrator** (GSA or `APP_*`) | Custodian of definitions **and** values for **all** contexts |
| Business-owner delegation / approval workflows | **Future Validation** |

### Row lifecycle (v1)

- Row **Code** = stable business key within the entity+context (slug or real number — choose per list and keep stable).
- Renaming a Code affects Excel matching, any PF DDL values that store that Code, and product `*Code` columns — UI **warns**; does not hard-block.
- **Retire = hard delete** today (no soft delete / active flag). Soft delete = Future Validation.
- Each context maintains its own item list; **Excel** is the hosted copy path for Values (rows are excluded from App Config JSON).

### Column Codes

Administrators choose **lowercase kebab-case** Codes (e.g. `country-code`, `approver-email`, `expense-limit`). Do **not** prefer `extraN`. Reserved: `code`, `description`, `sort-order`. Legacy `extraN` columns may still exist.

### Description (business name)

**Required** on Create, JSON import, and Edit. Excel sheet name = Description → also ≤ **31** characters, unique (case-insensitive), no `\ / ? * [ ] :`, not start/end with `'`.

### Display name conventions

Navigation: Description (preferred) else Code. Order by SortOrder.

### Operating envelope

Designed for **thousands of rows** per entity with a few columns. The former “~200k Cities” claim is **unproven**. PF DDL pickers load at most **1000** rows. Load validation = Future Validation.

### Seed / fixtures

Local seed JSON is a **technical fixture**, not modelling guidance — prefer [worked-examples.md](worked-examples.md).

---

## Technical rules (current reality)

### Scope

- Definitions → **Application** (`ApplicationGUID`). Rows → **Application Context**.
- See [ADR-016](../../decisions/ADR-016-data-entity-ownership.md).

### Naming

- Entity Codes: lowercase kebab-case, plural preferred (`cost-centers`).
- Column Codes: lowercase kebab-case, author-chosen (see above).
- Types: `TEXT`, `DECIMAL`, `BOOLEAN`, `DATE`, `DATETIME` — immutable after create.
- DECIMAL `Decimals` 0–10 (default **2**). UI label “Number” = DECIMAL.

### Platform rules

| Rule | Detail |
| --- | --- |
| Sparse metadata | NULL custom value → no metadata row |
| Row identity | `DataEntityRowGUID` immutable; Code editable business/portable key |
| Row Code uniqueness | Within entity + context |
| Column deletion | Always allowed; cascades metadata |
| Data Entity deletion | Blocked while rows exist |
| PF DDL references | Rename/delete of entity or row **warns** when referenced; does **not** hard-block (admin responsibility). Sync still **blocks** removing a DE that PF DDL columns reference. |

### Language authority

Row Description translations: authoritative language **`en-CA`** for Grid **and** Excel (same rule). See [i18n.md](../../docs/ui/foundations/i18n.md) and [ADR-018](../../decisions/ADR-018-data-entity-values-excel-portability.md).

### Values & Settings / Quick Actions / Excel

UI chrome, Quick Actions, Edit dialog, and Excel Tool behaviour remain as shipped (Fill layout, Shuffle Card Edit, Analyze→Confirm Excel). Details previously documented here still apply with these corrections:

- Settings column Codes are **author-chosen kebab**, not auto `extraN`.
- Description required on create/import/edit.
- Excel writes **`en-CA`**, not current UI culture.
- Values grid Description authoring remains en-CA.

Full UI layout tokens stay under [panels.md](../../docs/ui/layout/panels.md) / [shuffle-card-grid.md](../../docs/ui/controls/shuffle-card-grid.md). Excel file contract: [`docs/data-portability.md`](../../docs/data-portability.md).

### SortOrder

Create assigns `MAX+1`. Reorder only via **Edit Data Entities** (1..N). Dedicated reorder SP may remain unused by UI.

## Future scope (documented only)

Soft delete / retire-active, relationships, constraints, person types, delegated stewardship — **Future Validation**. Do not document as shipped.
