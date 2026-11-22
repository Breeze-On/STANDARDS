<!-- Classification: AA; Scope: application:eac -->
# Data Entities — Worked Examples

Owner: Architecture (EAC)

**Seed JSON is a technical fixture** — prefer these examples. Rules: [data-entities-standard.md](data-entities-standard.md).

---

## 1. Cost Centers (reference list)

**Why a DE:** flat list of cost centers with a few attributes. **Not** Customer/Vendor.

| Code | Description | Columns |
| --- | --- | --- |
| `cost-centers` | Cost Centers | `owner-email` TEXT, `expense-limit` DECIMAL(2), `active-flag` BOOLEAN, `effective-from` DATE |

Sample rows (per context, via Excel/Values): `ops-core` / Operations — Core; `fin-close` / Finance — Period Close.

```json
{
  "code": "cost-centers",
  "description": "Cost Centers",
  "sortOrder": 1,
  "columns": [
    { "code": "owner-email", "description": "Owner email", "type": "TEXT", "sortOrder": 1 },
    { "code": "expense-limit", "description": "Expense limit", "type": "DECIMAL", "decimals": 2, "sortOrder": 2 },
    { "code": "active-flag", "description": "Active", "type": "BOOLEAN", "sortOrder": 3 },
    { "code": "effective-from", "description": "Effective from", "type": "DATE", "sortOrder": 4 }
  ]
}
```

---

## 2. Request Types → Process Framework DDL

**Why a DE:** statuses/types picked on a PF Step/Option. **Shipped consumer:** PF `DDL` stores the **row Code**.

| Code | Description |
| --- | --- |
| `request-types` | Request Types |

Rows: `standard`, `urgent`, `informational`.

PF metadata column example: `dataType: "DDL"`, `dataEntityCode: "request-types"`, value = `"urgent"`.

---

## 3. Regions (cleaned reference)

| Code | Description | Columns |
| --- | --- | --- |
| `regions` | Regions | `approver-email` TEXT, `loa-threshold` DECIMAL(2), `net-days` DECIMAL(0) |

**Caveat:** “City → Country” relationships are **not** modelable in v1 — keep separate flat lists or encode naming conventions only.

---

## Counter-examples (do **not** model as DE)

| Object | Use instead |
| --- | --- |
| Customer / Vendor / Employee | Application-owned tables (until relationships/lifecycle exist) |
| Invoice / Purchase Request | Transactional application tables |
| Project / Equipment / Vehicle | Application-owned (need status, ownership, links) |
