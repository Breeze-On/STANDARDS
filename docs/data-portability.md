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
