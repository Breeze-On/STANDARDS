<!-- Classification: AA; Scope: application:eac -->
# Data Entities — AI Authoring Contract

Owner: Architecture (EAC)

Generate **structurally valid** and **business-shaped** Data Entity definitions. Semantics: [data-entities-standard.md](data-entities-standard.md). Human guide: [authoring-guide.md](authoring-guide.md). Examples: [worked-examples.md](worked-examples.md). Fields: [`docs/data-portability.md`](../../docs/data-portability.md).

---

## Recipe: business requirements → JSON

1. **Decide** — Flat reference list? If Customer/Vendor/Employee/Project/Equipment/Vehicle or transactional → **not** a Data Entity.  
2. **Entity** — `code` (kebab plural), **`description` (required)**, `sortOrder`, `columns` array (required, may be empty).  
3. **Columns** — Author-chosen kebab Codes; types TEXT|DECIMAL|BOOLEAN|DATE|DATETIME; never `code`/`description`/`sort-order`.  
4. **Rows** — **Not** in App Config JSON. Hosted path = Excel Values workbook after definitions sync. Local seed may use Values JSON (fixture only).  
5. **Envelope** — Prefer **export-then-edit**. Leave other App Config sections unchanged when editing only `dataEntities`. When editing only PF/Variables, **keep the exported `dataEntities` array intact** — never omit the key (see hazards).

---

## Required / optional (definitions)

| Field | Required | Notes |
| --- | --- | --- |
| `code` | Yes | Lowercase kebab; unique in Application |
| `description` | Yes | Business name; Excel sheet-name constraints apply |
| `sortOrder` | Yes | Unique among entities |
| `columns` | Yes | Array (may be `[]`) |
| `columns[].code` | Yes | Kebab; not reserved |
| `columns[].description` | Yes | |
| `columns[].type` | Yes | TEXT \| DECIMAL \| BOOLEAN \| DATE \| DATETIME |
| `columns[].sortOrder` | Yes | |
| `columns[].decimals` | When DECIMAL | 0..10; default 2 if omitted |

Type is **immutable** after create (change = remove + recreate).

---

## Hazards

| Hazard | Effect |
| --- | --- |
| Missing `description` | Create / JSON import / Edit fail |
| Column Code `extraN` | Allowed as legacy only — prefer meaningful Codes |
| Reserved column Codes | Rejected |
| `dataEntities: []` | Plans removal of all entities |
| **Missing `dataEntities` key** | Coerced to `[]` → **same full DE synchronize** (not omit=skip). Always include the exported array. |
| Rows in App Config JSON | Not supported — use Excel (hosted); local seed JSON is never hosted |
| Rename DE / row used by PF DDL | UI warns; sync blocks DE removal while DDL columns reference it |
| Excel language | Always **`en-CA`** |

---

## Construct choice (with PF / Variables / BE)

See [data-entities-standard.md § Which construct](data-entities-standard.md#which-construct-do-i-use). Prefer DE for many named flat items; Variable for one setting per context; PF for process routing; BE for org hierarchy.
