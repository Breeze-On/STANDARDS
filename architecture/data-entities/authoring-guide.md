<!-- Classification: AA; Scope: application:eac -->
# Data Entities — Authoring Guide

Owner: Architecture (EAC)

For Application Administrators and Business Analysts. Normative rules: [data-entities-standard.md](data-entities-standard.md). Examples: [worked-examples.md](worked-examples.md). AI: [ai-authoring-contract.md](ai-authoring-contract.md).

---

## Before you start

1. Confirm the list is **reference data** (flat). If it is Customer/Vendor/Employee/Project/Equipment/Vehicle — **stop**; use application-owned tables until Future Validation capabilities exist.
2. You must be GSA or Application administrator.
3. Open `/app-configuration` → Data Entities.

---

## Authoring sequence

### 1. Create the Data Entity

Quick Action **New Data Entity**:

1. **Code** — lowercase kebab plural (e.g. `cost-centers`).
2. **Description** — **required** business name (also becomes Excel sheet name → ≤31 chars, unique, no `\ / ? * [ ] :`).
3. Save.

### 2. Add Columns (Settings)

Toggle **Settings**:

1. Add columns with meaningful kebab Codes (`expense-limit`, `approver-email`) — not `extraN`.
2. Choose type using the table below.
3. Save Settings.

| Type | Business question | Example |
| --- | --- | --- |
| TEXT | Name, note, short code (≤250) | Approver email |
| DECIMAL (Number) | Quantity or amount | Expense limit |
| BOOLEAN | Yes/no flag | Active (if you invent a flag column — no first-class lifecycle) |
| DATE | Calendar date | Effective from |
| DATETIME | Moment (UTC storage) | Last reviewed |

### 3. Add Rows (Values)

Toggle **Values** for the selected Application Context:

1. Add items: Code (business key), Description (required), optional column values, SortOrder.
2. Descriptions are authored in **`en-CA`**.
3. Save.

Repeat per context as needed (each context has its own item list).

### 4. Cross-environment

1. Promote **definitions + columns** via Application Configuration JSON.
2. Promote **Values** via Excel Tool (definitions must already match). Excel uses **`en-CA`**.
3. If you rename/delete an entity or row referenced by Process Framework DDL, the UI **warns** — you may proceed; update PF afterward.

### 5. Validation expectations

- Description required on create/import/edit.
- Reserved column Codes rejected: `code`, `description`, `sort-order`.
- Delete entity blocked while rows exist.
- PF DDL soft references: warn on UI rename/delete; sync blocks removing a DE still referenced by PF columns.
