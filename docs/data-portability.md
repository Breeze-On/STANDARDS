# Data portability

Owner: Engineering

Current conventions for portable JSON payloads used to import and export application registry data owned by EAC.

## Applications JSON (`breezeon.eac.applications`)

Human-readable, versionable envelope supporting **multiple applications** in one file. Used by EAC Applications import and export. Implementation lives in **SYSTEM-ADMIN-EAC** (not a shared platform service).

### Envelope

| Field | Required | Notes |
| --- | --- | --- |
| `schemaVersion` | Yes | Current: `"1.0"` |
| `kind` | Yes | `"breezeon.eac.applications"` |
| `exportedAt` | No | ISO-8601 UTC on export; import ignores |
| `applications` | Yes | Non-empty array |

### Application item fields

| Field | Required | Notes |
| --- | --- | --- |
| `uniqueCode` | Yes | Technical id (repository name convention); uppercase A–Z, 0–9, hyphen |
| `code` | Yes | Short business code; uppercase A–Z, 0–9 |
| `description` | Yes | Max 250 |
| `metadata` | No | Max 250 |

**Not accepted from files:** `ApplicationGUID`, surrogate ids, audit columns (`CreatedBy`, `CreatedDate`, `LastUpdatedBy`, `LastUpdatedDate`). Those are server-owned.

### Example

```json
{
  "schemaVersion": "1.0",
  "kind": "breezeon.eac.applications",
  "applications": [
    {
      "uniqueCode": "SYSTEM-ADMIN-EAC",
      "code": "EAC",
      "description": "Enterprise Administration Center",
      "metadata": null
    }
  ]
}
```

Import and export use the **same** shape. Unknown properties on read are ignored (forward compatible). Bump `schemaVersion` for breaking changes.

### Import matching (UniqueCode only)

Upsert rules:

- Match by **current** `UniqueCode` in the database.
- Found → **update** `Code`, `Description`, `Metadata` (preserve `ApplicationGUID`).
- Not found → **create** with a new `ApplicationGUID`.

There is **no** rename detection, alias lookup, or historical UniqueCode mapping.

**Example (deliberate create-new):**

| Current DB `UniqueCode` | Imported file `UniqueCode` | Result |
| --- | --- | --- |
| `SYSTEM-ADMIN-EAC` | `SYSTEM-ADMIN-EAC` | Update existing row |
| `SYSTEM-ADMIN-EAC` | `LEGACY-SYSTEM-ADMIN-EAC` | **Create** a new application |

Renaming a `UniqueCode` in the UI is an administrative action. Re-importing a file that still uses the old code creates a new application by design.

### Validation and limits

- Extension: `.json` only.
- File processed **in memory only** — never stored permanently.
- Configurable max size: EAC `ApplicationsImport:MaxFileSizeMb` (default **2**).
- All-or-nothing: any validation failure rejects the whole file before writes.
- In-file duplicate `uniqueCode` values are rejected.

### Related

- EAC architecture: [architecture/eac.md](../architecture/eac.md)
- Audit columns (not in portability files): [database.md](database.md) § Mandatory audit columns
- Registry identity: [database.md](database.md) § Application registry identity columns

---

## Business entity types JSON (`breezeon.eac.business-entity-types`)

Envelope for EAC Entity Types import/export. Business key is `code`. Upsert by current `code`. GUIDs and audit columns are server-owned.

### Envelope

| Field | Required | Notes |
| --- | --- | --- |
| `schemaVersion` | Yes | `"1.0"` |
| `kind` | Yes | `"breezeon.eac.business-entity-types"` |
| `exportedAt` | No | ISO-8601 UTC on export; import ignores |
| `types` | Yes | Non-empty array |

### Item fields

| Field | Required | Notes |
| --- | --- | --- |
| `code` | Yes | Unique business key; uppercase A–Z, 0–9, hyphen, underscore; max 250 |
| `description` | Yes | Max 250 |
| `metadata` | No | Max 250 |

### Example

```json
{
  "schemaVersion": "1.0",
  "kind": "breezeon.eac.business-entity-types",
  "types": [
    { "code": "REGION", "description": "Geographic region", "metadata": null }
  ]
}
```

Configurable max size: EAC `BusinessEntitiesImport:MaxFileSizeMb` (default **10**). Validate then apply in one database transaction; any failure rolls back the entire import. In-memory only.

---

## Business entities JSON (`breezeon.eac.business-entities`)

Envelope for EAC Business Hierarchy import/export. Business keys only (`code`, `parentCode`, `businessEntityTypeCode`). Hierarchy is reconstructable from `code` + `parentCode`. Do **not** include GUIDs or `HierarchyPath`.

### Envelope

| Field | Required | Notes |
| --- | --- | --- |
| `schemaVersion` | Yes | `"1.0"` |
| `kind` | Yes | `"breezeon.eac.business-entities"` |
| `exportedAt` | No | ISO-8601 UTC on export; import ignores |
| `entities` | Yes | Non-empty array |

### Item fields

| Field | Required | Notes |
| --- | --- | --- |
| `code` | Yes | Unique business key; uppercase A–Z, 0–9, hyphen, underscore; max 250 |
| `description` | Yes | Max 250 |
| `metadata` | No | Max 250 |
| `businessEntityTypeCode` | Yes | Must exist in Entity Types (same code format) |
| `parentCode` | No | Null/omit = root; otherwise must exist (DB or earlier in file) |

### Example

```json
{
  "schemaVersion": "1.0",
  "kind": "breezeon.eac.business-entities",
  "entities": [
    {
      "code": "OPS",
      "description": "Operations",
      "metadata": null,
      "businessEntityTypeCode": "DIVISION",
      "parentCode": null
    },
    {
      "code": "OPS-CA",
      "description": "Canada",
      "metadata": null,
      "businessEntityTypeCode": "COUNTRY",
      "parentCode": "OPS"
    }
  ]
}
```

### Import rules

- Upsert by current `code` (preserve `BusinessEntityGUID` on update).
- Validate then apply in **parent-before-child** order.
- Reject unknown `businessEntityTypeCode`, missing `parentCode`, in-file duplicate codes, and circular relationships.
- Fail-fast: any failure aborts the entire import and **rolls back** all rows from that import (single database transaction).
- Max size: `BusinessEntitiesImport:MaxFileSizeMb` (default **10**); in-memory only.

### Export

- Selected nodes only (cascade selection includes descendants when the user selects a parent).
- Do not auto-add unselected ancestors; import fails if a referenced parent is missing.
