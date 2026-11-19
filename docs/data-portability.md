# Data portability

Owner: Engineering

Current conventions for portable payloads used to import and export application registry data, Application Configuration (JSON), and Data Entity Values (Excel) owned by EAC.

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
| `BusinessEntitiesEnabled` | No | Array of Business Entity **Code** values (not GUIDs). Portable Application Context links. Omitted when empty on export. |

**Not accepted from files:** `ApplicationGUID`, `ApplicationEnabledGUID`, `BusinessEntityGUID`, surrogate ids, audit columns (`CreatedBy`, `CreatedDate`, `LastUpdatedBy`, `LastUpdatedDate`). Those are server-owned.

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
      "metadata": null,
      "BusinessEntitiesEnabled": [
        "CANADA",
        "RETAIL",
        "MONTREAL"
      ]
    }
  ]
}
```

Import and export use the **same** shape. Unknown properties on read are ignored (forward compatible). Bump `schemaVersion` for breaking changes.

### Import matching (UniqueCode only)

Upsert rules:

- Match by **current** `UniqueCode` in the database.
- Found → **update** `Code`, `Description`, `Metadata` (preserve `ApplicationGUID` and `GroupGUID`; never reassign the administrator group).
- Not found → **create** with a new `ApplicationGUID` and provision/reuse administrator group `APP_{UniqueCode}` via the same central provisioner as UI create (reuse existing group by Code without renaming, description overwrite, membership, or metadata changes; no auto-members).
- After application upsert: for each Code in `BusinessEntitiesEnabled`, resolve to `BusinessEntityGUID`, create missing Application Contexts; ignore Codes already enabled; skip Codes that do not resolve to an existing Business Entity. Exclusivity `(ApplicationGUID, BusinessEntityGUID)` still applies. Application Enabled mutations on import are **Global System Administrator** only ([eac-authorization-matrix.md](../architecture/authorization/eac-authorization-matrix.md)).

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

- Upsert by current `code` (preserve `BusinessEntityGUID` and `GroupGUID` on update; never reassign the administrator group).
- Create provisions/reuses `BUSENT_{Code}` via the same central provisioner as UI create (reuse by Code without mutation; no auto-members).
- Validate then apply in **parent-before-child** order.
- Reject unknown `businessEntityTypeCode`, missing `parentCode`, in-file duplicate codes, and circular relationships.
- Fail-fast: any failure aborts the entire import and **rolls back** all rows from that import (single database transaction). Import is **Global System Administrator** only.
- Max size: `BusinessEntitiesImport:MaxFileSizeMb` (default **10**); in-memory only.

### Export

- Selected nodes only (cascade selection includes descendants when the user selects a parent).
- Do not auto-add unselected ancestors; import fails if a referenced parent is missing.

---

## Application Configuration JSON (`breezeon.eac.application-configuration`)

Environment **deployment** envelope for Application Configuration State. Import **synchronizes** the target Application to match the file (create / update / **remove** by Code). This is **not** merge/upsert and **not** backup/restore. Semantic SSOT: [architecture/app-configuration/application-configuration-deployment.md](../architecture/app-configuration/application-configuration-deployment.md) · [ADR-017](../decisions/ADR-017-application-configuration-deployment.md).

Implementation lives in **SYSTEM-ADMIN-EAC** (not a shared platform service).

### Envelope

| Field | Required | Notes |
| --- | --- | --- |
| `schemaVersion` | Yes | Integer. Current: `1` |
| `kind` | Yes | `"breezeon.eac.application-configuration"` |
| `exportedAt` | No | ISO-8601 UTC on export; import ignores |
| `applicationUniqueCode` | Yes | Match key = Application `UniqueCode` (must equal selected Application on import) |
| `applicationCode` | Export: yes; Import: when present | Short Application `Code`; when present on import must match selected Application |
| `dataEntities` | Yes | Array (may be empty). Synchronized |

**Not accepted from files:** Application/Data Entity/Column GUIDs, surrogate ids, audit columns, rows, translations, metadata values, group members.

**Not shipped in schemaVersion 1:** non-empty `steps`, `options`, `roles`, `systemConfiguration`, `securityGroups` — rejected if present with items.

### Data entity item

| Field | Required | Notes |
| --- | --- | --- |
| `code` | Yes | Lowercase kebab-case; unique within Application |
| `description` | No | Max 250 |
| `sortOrder` | Yes | Positive integer; unique within `dataEntities` |
| `columns` | Yes | Array (may be empty) |

### Column item

| Field | Required | Notes |
| --- | --- | --- |
| `code` | Yes | Lowercase kebab-case; unique within parent entity |
| `description` | No | Max 250 |
| `type` | Yes | `TEXT` \| `DECIMAL` \| `BOOLEAN` \| `DATE` \| `DATETIME` (immutable on update for an existing Code) |
| `decimals` | Conditional | Integer **0–10**. Required semantics for `DECIMAL` (omit → default **2** on import). Must be omitted for non-DECIMAL types. Export emits only for DECIMAL. |
| `sortOrder` | Yes | Positive integer; unique within parent `columns` |

### Example

```json
{
  "schemaVersion": 1,
  "kind": "breezeon.eac.application-configuration",
  "applicationUniqueCode": "INVOICE-APPROVAL",
  "applicationCode": "INV",
  "dataEntities": [
    {
      "code": "regions",
      "description": "Regions",
      "sortOrder": 1,
      "columns": [
        {
          "code": "iso-code",
          "description": "ISO code",
          "type": "TEXT",
          "sortOrder": 1
        }
      ]
    }
  ]
}
```

### Import matching and synchronize

- Validate selected Application `UniqueCode` == `applicationUniqueCode` (blocking).
- Match Data Entities and Columns by **current** `Code` within the Application.
- Create missing Codes; update matched Codes (description, sortOrder); **remove** Codes in the target that are absent from the file.
- No rename detection.
- Removing a Data Entity is blocked when any rows exist in any Application Context.
- Removing a Column is **always allowed**; synchronize deletes associated metadata values first, then the column (same rule as Settings Save).
- All-or-nothing: validate → plan summary → confirm → single SQL transaction (`P_POST_EACApplicationConfigurationSync`).
- Authorization: Global System Administrator or Application administrator group (`APP_*`) for the selected Application.
- Max size: EAC `ApplicationConfigurationImport:MaxFileSizeMb` (default **5**); in-memory only.
- Filename on export: `{applicationUniqueCode}.application-configuration.json`.
- Local Docker may seed the same envelope after Applications/BE SQL (`SYSTEM-ADMIN-EAC` `sql/seed/` + `tools/BreezeOn.Eac.LocalAppConfigurationSeed`); never hosted environments.

### Related

- [architecture/app-configuration/README.md](../architecture/app-configuration/README.md)
- Operations: [runbooks/eac-application-configuration-deployment.md](../runbooks/eac-application-configuration-deployment.md)

---

## Data Entity Values Excel (`*.data-entity-values.xlsx`)

Excel workbook for moving Data Entity **Values** (rows, row Description, custom-column values) of one **Application Context** and for bulk maintenance. Surfaced by the EAC Data Entities Quick Action **Excel Tool**. Decision: [ADR-018](../decisions/ADR-018-data-entity-values-excel-portability.md). UX and rules: [data-entities-standard.md](../architecture/data-entities/data-entities-standard.md#excel-tool-shipped). Implementation lives in **SYSTEM-ADMIN-EAC** (`Components/DataEntities/Excel`, library **ClosedXML**).

Distinct from other Data Entity payloads:

| Payload | Carries | Semantics |
| --- | --- | --- |
| Application Configuration JSON (`breezeon.eac.application-configuration`) | Data Entity definitions + columns | Synchronize (create / update / remove by Code) — [above](#application-configuration-json-breezeoneacapplication-configuration) |
| **Values Excel** (`.xlsx`, this section) | Rows, row Description (one language), custom-column values | Analyze → confirm; Add/Update or Overwrite by row Code |
| Local Values JSON (`breezeon.eac.data-entity-values`) | Rows for local Docker seed | Synchronize-by-Code at seed time; **local only**, never hosted; not an import/export feature |

Synchronize definitions (Application Configuration) **before** importing Values into a target environment.

### Workbook structure

- One sheet per Data Entity of the Application, in Data Entity order — **Data Entity sheets only** (no Instructions worksheet; the first sheet is the first Data Entity). **Sheet name = Data Entity Description** (user-facing identity). The Data Entity **Code** is the internal service key (Excel table name `tbl` + PascalCase of the Code; never the sheet name) and the stable in-memory key once a sheet is resolved.
- Each sheet holds exactly **one Excel table starting at A1** with a header row (no totals row); nothing may exist outside the table.
- Columns, in order: `Code` · `Description` · one column per Data Entity Column in Settings order (header = column Description, else column Code) · `SortOrder`. Headers must keep their text and order; they must be unique per sheet and ≤ 255 characters.
- **No GUIDs** and no audit columns appear in the file.
- Cell formats follow column type: `DECIMAL` numeric with the column `Decimals`; `BOOLEAN` TRUE/FALSE; `DATE` `yyyy-mm-dd`; `DATETIME` `yyyy-mm-dd hh:mm:ss` (UTC); `TEXT` max 250. An empty cell clears the stored value.
- Row limits: `Code` required, ≤ 100; `Description` required, ≤ 250; `SortOrder` optional whole number (the column and header must exist; see [SortOrder on import](#import-modes-and-matching)).
- Export filename: `{applicationUniqueCode}.{businessEntityCode|context}.data-entity-values.xlsx`.

### Description sheet-name prerequisites

Every Data Entity Description in the Application must be non-empty, **≤ 31** characters, unique (case-insensitive), free of `\ / ? * [ ] :`, and not start/end with an apostrophe. Otherwise export and import are blocked with an error naming the offending Data Entity.

### Translation scope

Row Description is the translation for **one language** — the current UI language (`en-CA` / `fr-CA`). Other languages are not exported and not changed by import.

### Import modes and matching

- Rows match by **row `Code`** within the Data Entity (case-insensitive). Never by GUID.
- **Add Missing & Update Existing:** add missing rows, update existing rows (Description, SortOrder, custom columns); never deletes. Identical rows count as unchanged.
- **Overwrite All Values:** same, plus delete destination rows absent from the sheet — only for Data Entities that have a sheet in the file.
- **SortOrder is optional:** value provided → used; blank on a **new** row → auto-assigned `max + 1` in Excel row order; blank on an **existing** row → destination `SortOrder` kept.
- **Mode selection:** the Import Mode dropdown starts empty and Import stays disabled until a mode is chosen (no helper labels under the dropdown — mode option text is self-explanatory). Overwrite deletes are expected and appear only in the Changes Summary Deleted column (not as warnings). Add/Update may warn when destination rows absent from the sheet will be retained.
- **Included** = sheet present. A Data Entity with no sheet is **excluded** and left untouched in every mode. A sheet matching no Data Entity is ignored with a **warning**; no matching sheet at all is an error.
- Flow: upload → choose mode → **analyze** (nothing written) → two standard `BoSectionMain` + read-only `BoGrid` sections — **Changes Summary** (Data Entity · Included? · New · Updated · Deleted; Deleted shows bold N/A for Add/Update mode and excluded entities) and **Errors and Warnings** (Type · Message; missing-worksheet warning for excluded Data Entities) → **Import**. When nothing differs, the UI reports "No changes detected" and Import is disabled. After a successful import all Excel dialogs close, Data Entities/Values refresh, and the first Data Entity is selected.
- **All-or-nothing:** any structure or row error rejects the whole file; apply saves every Data Entity through the existing Values save path in **one database transaction**.
- Authorization: Global System Administrator or Application object administrator.

### Validation and limits

- Extension: `.xlsx` only (official OOXML workbook).
- File processed **in memory only** — never stored permanently.
- Configurable max size: EAC `DataEntityExcelImport:MaxFileSizeMb` (default **25**).
- Export loads all context rows via `System.P_GET_EACDataEntitiesRowsForExcel` (approved full-load exception to [ADR-008](../decisions/ADR-008-query-driven-data-retrieval.md)). Import analysis **parses first**, then loads destination rows only for **included** Data Entities (`@DataEntityGuidsJson`). The SP returns two result sets (rows + sparse metadata). Schema uses `P_GET_EACDataEntitiesColumnsByApplication`. Analyze latency diagnostics: **Debug** logger category `BreezeOn.Eac.DataEntities.Excel.Analyze` (stage breakdown + `OperationId`; opt-in). See [data-entities-architecture.md](../architecture/data-entities/data-entities-architecture.md#excel-tool-values-portability) and EAC `README_AI.md`.
