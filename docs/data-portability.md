<!-- Classification: AA; Scope: platform; Domain: Platform; Capability: DataPortability -->
# Data portability

Owner: Engineering

Current conventions for portable payloads used to import and export application registry data, Application Configuration (JSON), and Data Entity Values (Excel) owned by EAC.

## Kind catalog (semantic families)

| Kind / path | Semantics | Empty / missing behavior | Primary surface | Hosted? |
| --- | --- | --- | --- | --- |
| `breezeon.eac.applications` | **Merge/upsert** by `uniqueCode` | Enablement is **additive only** (never disables contexts) | EAC Applications Import/Export | Yes |
| `breezeon.eac.business-entity-types` | **Merge/upsert** by `code` | Absent codes in DB are **retained** (never synchronize-delete) | EAC Business Entity Types | Yes |
| `breezeon.eac.business-entities` | **Merge/upsert** by `code` (parent-before-child) | Absent codes in DB are **retained** | EAC Business Entities | Yes |
| `breezeon.eac.application-configuration` | **Synchronize** participating sections (create/update/**remove** by Code) | Optional keys **omit = skip**; present incl. `[]` = full section sync. **`dataEntities` always syncs** — missing key ≡ `[]` (see hazards) | EAC App Config Import/Export | Yes |
| `breezeon.eac.security-group-members` (+ Excel) | Membership-only Add Missing / Overwrite | Groups omitted from file = untouched; Overwrite + `members: []` clears that group (JSON) | EAC SG Bulk Actions | Yes |
| Data Entity Values Excel | Add/Update or Overwrite by row Code | Overwrite deletes rows absent from sheet for included entities | EAC Data Entities Excel Tool | Yes |
| Translations Excel | Catalog dual-path with JSON language maps | See path-by-kind matrix below / Translations section | EAC Translations | Yes |
| `breezeon.eac.data-entity-values` (local seed JSON) | Synchronize-by-Code at **local Docker seed** only | N/A as product import/export | EAC local reset importing consumer `seed/eac/` | **Never hosted** |

**`schemaVersion` typing (do not unify without a breaking bump):** Applications / BE Types / BE / SG members use string **`"1.0"`**. Application Configuration uses integer **`3`** (import also accepts `1` legacy flat PF and `2` nested PF / legacy BE-keyed securityGroups). AI authors must emit the type shown for that kind.

### Promote sequence (operators / AI)

1. Applications JSON (registry)  
2. Business Entity Types + Business Entities JSON (hierarchy)  
3. Application enablement (Applications JSON `BusinessEntitiesEnabled` — **additive**)  
4. Application Configuration JSON (definitions + PF + Variables + SG defs + languages)  
5. Data Entity Values Excel (rows) — definitions must already exist  
6. Security Group Members JSON/Excel (memberships)  
7. Translations Excel as needed (dual path with JSON maps for PF/Variable TEXT)

Prefer **export-then-edit** for Application Configuration: export the full envelope, change only the intended section, leave other sections intact (especially `dataEntities`).

### Envelope hazards (destructive shapes)

| Shape | Effect |
| --- | --- |
| **Missing `dataEntities` key** | Coerced to **`[]`** → **full Data Entity synchronize** (remove Codes absent from file). **Not** omit=skip. Documented intentional behavior; reject-missing = Future Validation (schema bump only). |
| `dataEntities: []` | Same as missing key — plans removal of all DE definitions (blocked when rows exist). |
| `variables` present + `values: []` | Deletes **all** Variable values Application-wide |
| `variables` / `securityGroups` / `processFramework` / `languages` **omitted** | Section **skipped** (target unchanged) |
| `securityGroups: []` | Synchronize removes all App Config SG definitions for the Application (delete-with-config) |
| PF owner present + `values: []` or `metadataColumns: []` | Synchronizes that half (can wipe); **absent** half under a present owner = skip that half only |
| SG members Overwrite + `members: []` | Clears membership for that group (JSON only) |
| Values Excel Overwrite | Deletes destination rows absent from included sheets |

Authoring JSON locally is allowed. Executing hosted Import/Sync requires current-prompt authorization ([ai-agent-governance.md](ai/ai-agent-governance.md)). Construct-level pointer: [construct-selection.md](../architecture/app-configuration/construct-selection.md).

## Per-application `seed/eac` (local Docker)

Portable EAC configuration used to make an EAC-consuming application runnable on a developer machine is **owned by that application's repository**, in a top-level **`seed/eac/`** folder (no per-app `seed/eac/README.md`; the product README / `README_AI.md` document it).

| Concern | Rule |
| --- | --- |
| Owner | The consuming application repo (e.g. `breezeon-corp-fin-inv/seed/eac/`). **Not** `SYSTEM-ADMIN-EAC/sql/seed/`. |
| Importer | **EAC** (`SYSTEM-ADMIN-EAC` `scripts/dev-reset.ps1`) — consumer apps invoke it as a subprocess ([local-development-scripts.md](local-development-scripts.md) § Consumer apps and EAC reset) and never import EAC configuration themselves. |
| Discovery | EAC discovers **sibling** repositories under the same parent folder and imports each one's `seed/eac/` when present. A sibling without `seed/eac/` is skipped. |
| Contents | Portable payloads only (JSON envelopes / `.xlsx`), using the existing kinds: `breezeon.eac.applications` (the app's registry entry and enablement), `breezeon.eac.application-configuration` (Data Entity definitions, Process Framework, Variables, Security Group definitions, languages), `breezeon.eac.data-entity-values` (local Values JSON) or Data Entity Values Excel, `breezeon.eac.security-group-members`, and Translations Excel as needed. Business Entity Types / Business Entities JSON only when the app needs hierarchy rows that the EAC baseline does not provide. |
| Order | Import follows the [Promote sequence](#promote-sequence-operators--ai): registry → hierarchy → enablement → Application Configuration → Values → members → translations. |
| Hosted | **Never** applied to DEV / UAT / PRD. Hosted promote uses the normal import surfaces. |

Product apps must **not** carry `System.EAC*` SQL configuration or current-state seeds (e.g. `INSERT` into EAC tables, `P_POST_EAC*` calls) in their own `sql/seed/`; EAC configuration is expressed only as portable payloads under `seed/eac/` ([database.md](database.md) § `seed/eac/`).

---

## Applications JSON (`breezeon.eac.applications`)

Human-readable, versionable envelope supporting **multiple applications** in one file. Used by EAC Applications import and export. Implementation lives in **SYSTEM-ADMIN-EAC** (not a shared platform service).

### Envelope

| Field | Required | Notes |
| --- | --- | --- |
| `schemaVersion` | Yes | String **`"1.0"`** (not an integer — see Kind catalog) |
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
| `BusinessEntitiesEnabled` | No | **PascalCase** property name (not `businessEntitiesEnabled`). Array of Business Entity **Code** values (not GUIDs). Portable Application Context links. Omitted when empty on export. Unknown camelCase property names are ignored — enablements would silently not apply. |

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
- After application upsert: for each Code in `BusinessEntitiesEnabled`, resolve to `BusinessEntityGUID`, create missing Application Contexts; ignore Codes already enabled; skip Codes that do not resolve to an existing Business Entity. Exclusivity `(ApplicationGUID, BusinessEntityGUID)` still applies. Application Enabled mutations on import are **Global System Administrator** only ([eac-authorization-matrix.md](../architecture/applications/eac-authorization-matrix.md)).
- **Enablement is additive only.** Omitting `BusinessEntitiesEnabled`, or supplying `[]` / null, does **not** disable existing Application Contexts. Disabling a context is an interactive/admin action — not portable via this kind.

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

- EAC architecture: [architecture/applications/eac.md](../architecture/applications/eac.md)
- Audit columns (not in portability files): [database.md](database.md) § Mandatory audit columns
- Registry identity: [database.md](database.md) § Application registry identity columns

---

## Business entity types JSON (`breezeon.eac.business-entity-types`)

Envelope for EAC Entity Types import/export. Business key is `code`. Upsert by current `code`. GUIDs and audit columns are server-owned. **Merge/upsert only — never synchronize-delete** (absent target codes are retained).

### Envelope

| Field | Required | Notes |
| --- | --- | --- |
| `schemaVersion` | Yes | String **`"1.0"`** |
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
| `schemaVersion` | Yes | String **`"1.0"`** |
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
- **Merge/upsert only — never synchronize-delete.** Codes present only in the target database are **retained**. This is not Application Configuration synchronize.
- Fail-fast: any failure aborts the entire import and **rolls back** all rows from that import (single database transaction). Import is **Global System Administrator** only.
- Max size: `BusinessEntitiesImport:MaxFileSizeMb` (default **10**); in-memory only.

### Export

- Selected nodes only (cascade selection includes descendants when the user selects a parent).
- Do not auto-add unselected ancestors; import fails if a referenced parent is missing.

---

## Application Configuration JSON (`breezeon.eac.application-configuration`)

Environment **deployment** envelope for Application Configuration State. Import **synchronizes** participating sections of the target Application to match the file (create / update / **remove** by Code). This is **not** merge/upsert and **not** backup/restore. Synchronize is **section-participation based**: omitted optional keys are skipped; a present section synchronizes completely (“no partial imports” = no subset-of-Codes inside a present section). Semantic SSOT: [architecture/app-configuration/application-configuration-deployment.md](../architecture/app-configuration/application-configuration-deployment.md) · [ADR-017](../decisions/ADR-017-application-configuration-deployment.md).

Implementation lives in **SYSTEM-ADMIN-EAC** (not a shared platform service).

### Envelope

| Field | Required | Notes |
| --- | --- | --- |
| `schemaVersion` | Yes | **Integer** (not a string). **Current export: `3`**. Import accepts `1` (legacy flat Process Framework), `2` (nested `processFramework`; BE-keyed `securityGroups`), and `3` (AttributeCode-only `securityGroups`). |
| `kind` | Yes | `"breezeon.eac.application-configuration"` |
| `exportedAt` | No | ISO-8601 UTC on export; import ignores |
| `applicationUniqueCode` | Yes | Match key = Application `UniqueCode` (must equal selected Application on import) |
| `applicationCode` | Export: yes; Import: when present | Short Application `Code`; when present on import must match selected Application |
| `dataEntities` | Yes | Array (may be empty). **Always synchronized.** Missing property ≡ `[]` ≡ full DE sync (remove Codes absent from file) — **not** omit=skip. Prefer export-then-edit; never omit this key for “PF-only” files. |
| `securityGroups` | Export: yes; Import: when present | Array of portable definitions (may be empty). When **present** (including `[]`), definitions are materialized onto **every enabled** Business Entity for the Application. When **omitted**, security-group sync is skipped (backward compatible). Export fails if the same `attributeCode` has drifted portable fields across contexts. |
| `variables` | Export: yes; Import: when present | Object with required `definitions` + `values` arrays (may be empty). When **present**, both are synchronized. When **omitted**, Variables sync is skipped. See below. |
| `processFramework` | Export: yes; Import: when present | Object. Canonical Process Framework node (schemaVersion **2**). Absent = skip all Process Framework sync. See below. |
| `languages` | Export: yes; Import: when present | Array of `{ businessEntityCode, languageCode, sortOrder }`. When **present**, enabled languages are **replaced** per listed Application Context (`en-CA` required). When **omitted**, language enablement is skipped. |

**Legacy flat keys (schemaVersion 1 import only):** `processMetadataColumns`, `roles`, `steps`, `options` at the root. Dual-read normalizes them into the nested ownership model. **Reject** files that mix flat Process Framework keys with `processFramework`. Export never writes the flat keys.

### Included / Excluded / Separate deployment

| Classification | Contents |
| --- | --- |
| **Included** (when section participates) | Data Entity configuration (definitions + columns); Process Framework Roles / Steps / Options + metadata columns + **metadata values** (incl. TEXT language maps); Variables **definitions** + **values** (incl. TEXT language maps); Security Groups **definitions** (portable Name; no memberships) |
| **Excluded** from this kind | Data Entity **row** data; Security Group **memberships**; environment GUIDs; runtime / audit |
| **Separate path** | Translations Excel (DE row Descriptions Excel-only; PF labels / PF TEXT metadata / Variable TEXT also editable via Excel — dual path with JSON language maps). SG members: `breezeon.eac.security-group-members`. DE Values Excel: ADR-018. |

**Not accepted from files:** Application/Data Entity/Column/SecurityGroup/Variable/Role/Step/Option/metadata-column GUIDs, surrogate ids, audit columns, Data Entity rows, Data Entity row translations (Excel), group members.

**Legacy reject:** non-empty `systemConfiguration` — still rejected if present with items (replaced by `variables`; never shipped with rows).

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

### Security group item

Portable **definitions** keyed by `attributeCode` only (Application-scoped in the file). On synchronize they **materialize** into per–Business Entity `EACSecurityGroups` + configuration-owned `Security.Groups` for every enabled context.

| Field | Required | Notes |
| --- | --- | --- |
| `attributeCode` | Yes | `[A-Z0-9_]+`; unique within `securityGroups`; **mutable** (portable rename = remove+create match-key change) |
| `name` | No (export always; import optional) | Authoritative portable Name metadata as stored (max 600). Export emits the stored value with **no** convention-based rewriting; cross-context drift on Name (or other portable fields) **fails export**. Not applied as runtime `Security.Groups.Name` on sync create. |
| `description` | Yes | Written to `Security.Groups.Description` on create/update (max 600) |
| `metadata` | No | Stored on `EACSecurityGroups.Metadata` (max 250). **Export always emits** the property (`null` when unset) so round-trip matches import. |
| `sortOrder` | Yes | Positive integer; unique within `securityGroups` |
| `businessEntityCode` | Legacy only | schemaVersion ≤ 2 import: ignored for identity; duplicate AttributeCodes with conflicting portable fields → validation error. Never exported on schemaVersion **3**. |

**Materialization:** create/update/remove for each enabled Business Entity × each file `attributeCode`. Runtime Name on **create** = `{ApplicationCode} / {BusinessEntityCode} — {AttributeCode}`. **Update** syncs Description / Metadata / SortOrder (and keeps APPSG Code in convention) and **does not overwrite** an existing Name. Code = `APPSG_{UniqueCode}_{BusinessEntityCode}_{AttributeCode}` (**`IsManuallyCreated = 0`**). **Code length budget** ≤ 700 (hard-fail). Memberships are never imported via this kind. **Delete-with-config:** removing a definition deletes matching EAC rows **and** linked APPSG groups + memberships in every context for that AttributeCode.

### Variables

Application-scoped definitions; values per Application Enabled context (resolved via `businessEntityCode`). Export always emits `variables` with both arrays. Import: key absent = skip; present = sync both (both keys required when `variables` is present). No GUIDs / audit in the file. DataType is immutable on update for an existing Code.

#### `variables.definitions` item

| Field | Required | Notes |
| --- | --- | --- |
| `code` | Yes | Lowercase kebab-case; unique within Application |
| `description` | Yes | Plain English string only (administrative metadata; language maps are rejected) |
| `dataType` | Yes | `TEXT` \| `NUMBER` \| `BOOLEAN` \| `DATE` \| `DATETIME` (immutable on update) |
| `decimals` | Conditional | Integer **0–10**. NUMBER only (omit → default **0**). Must be omitted for other types. |
| `metadata` | No | Freeform organizational text ≤250. Export always emits (`null` when unset). |
| `sortOrder` | Yes | Positive integer; unique within `definitions` |

#### `variables.values` item

| Field | Required | Notes |
| --- | --- | --- |
| `businessEntityCode` | Yes | Must be enabled for the Application; resolves to ApplicationEnabledGUID |
| `code` | Yes | Must match a definition in the file |
| `value` | Yes | Typed per definition DataType: TEXT = string or language map; NUMBER = number; BOOLEAN = boolean; DATE / DATETIME = ISO string. Sparse: omit the entry when unset. |

Removing a definition cascades all contexts’ values + TEXT translations. When `variables` is present, values are a **full sync** across enablements for this Application’s variables (absent entries are removed).

### Process Framework sections

Application-scoped; Codes only (lowercase kebab-case, max 100). Decision: [ADR-019](../decisions/ADR-019-process-framework-metadata.md). Architecture: [architecture/process-framework](../architecture/process-framework/README.md).

#### Canonical shape (`schemaVersion` 2) — ownership model

Metadata columns are **not** a standalone top-level artifact. They belong to Steps, Options, or Roles:

```text
processFramework.steps.metadataColumns   → Settings for Steps
processFramework.steps.values            → Step rows (Values)
processFramework.options.metadataColumns → Settings for Options
processFramework.options.values          → Option rows (Values)
processFramework.roles.metadataColumns   → Settings for Roles
processFramework.roles.values            → Role rows (Values)
```

| Child | Present / omit |
| --- | --- |
| `processFramework` absent | Skip all Process Framework sync |
| Owner (`steps` / `options` / `roles`) absent | Skip that owner (both Settings and Values) |
| `metadataColumns` / `values` absent under a present owner | Skip that half only; present including `[]` = synchronize (**can wipe** that half) |

**Half-skip hazard:** Under a present owner, do **not** copy example `"values": []` / `"metadataColumns": []` into production promotes unless wipe is intended. Prefer export-then-edit of the full tree. See [Envelope hazards](#envelope-hazards-destructive-shapes).

Export always writes the full `processFramework` tree (all three owners, both arrays).

**`metadataColumns` item** (match key `(code, owner)` after normalize; ownership is **path-implied** — omit `processFrameworkEntity` and `appliesTo` in nested JSON)

| Field | Required | Notes |
| --- | --- | --- |
| `code` | Yes | Unique within Application **and** owner (same Code may exist once per owner as separate items); reserved: `code`, `type`, `sort-order`, `security-group-attribute-code`, `role-code`, `step-code`, `next-step-code` |
| `description` | Yes | Max 250 (admin label). String **or** language map object (`{"en-CA":"...","fr-CA":"..."}`, like TEXT metadata); non-empty. Export writes the map when translations exist, else a string |
| `dataType` | Yes | `TEXT` \| `NUMBER` \| `DATE` \| `DATETIME` \| `BOOLEAN` \| `DDL` \| `PEOPLEPICKER` (immutable on update for an existing `(code, owner)`) |
| `decimals` | Conditional | **0–10**, `NUMBER` only (default 2 when omitted); omit for other types |
| `isRequired` | Yes | Boolean |
| `displayOrder` | Yes | Positive integer; unique within the same owner’s `metadataColumns` |
| `dataEntityCode` | Conditional | Required for `DDL` (must match a Data Entity Code of the Application); omit otherwise |

**`roles.values` item** (match key `code`): `code` (required), `type` (`Group` only), `securityGroupAttributeCode` (optional, `[A-Z0-9_]+`, max 100; soft reference — no foreign key), `sortOrder` (required, positive, unique within roles values), `metadata` (optional object, see below).

**`steps.values` item** (match key `code`): `code` (required), `roleCode` (optional; must match a Role Code; omitted/null = informational Step), `sortOrder` (required, unique within steps values), `metadata`.

**`options.values` item** (match key `stepCode` + `code`): `stepCode` (required, Step Code), `code` (required, unique within its Step), `nextStepCode` (required, Step Code), `sortOrder` (required, positive, unique within its Step), `metadata`.

**`metadata` object:** keys are metadata column Codes (column must exist for that owner); `null` or absent = no value; required columns must have a value (required `BOOLEAN` defaults to `false`). Value shape by `dataType`:

| `dataType` | JSON value |
| --- | --- |
| `TEXT` | String, or a language map `{ "en-CA": "...", "fr-CA": "..." }` (max 250 per value) |
| `NUMBER` | Number |
| `DATE` | `yyyy-MM-dd` |
| `DATETIME` | ISO-8601 date-time |
| `BOOLEAN` | Boolean |
| `DDL` | Data Entity row **Code** string |
| `PEOPLEPICKER` | **`externalObjectId`** GUID string (Entra `oid`) — never `userGuid` / UPN |

Import does not require a `PEOPLEPICKER` user to exist locally; the id is stored as written.

#### Legacy flat import (`schemaVersion` 1)

Root keys `processMetadataColumns`, `roles`, `steps`, `options` (present/omit semantics unchanged). Column items require `processFrameworkEntity` (`roles`\|`steps`\|`options`) or legacy `appliesTo` (expanded to one row per listed entity). Export never writes flat keys or `appliesTo`. Sync SP payload remains flat; EAC normalizes nested ↔ flat in process — **no database migration**.

### Example

```json
{
  "schemaVersion": 3,
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
  ],
  "processFramework": {
    "steps": {
      "metadataColumns": [
        { "code": "name", "description": "Display name", "dataType": "TEXT", "isRequired": true, "displayOrder": 1 },
        { "code": "description", "description": "What happens", "dataType": "TEXT", "isRequired": false, "displayOrder": 2 }
      ],
      "values": []
    },
    "options": {
      "metadataColumns": [
        { "code": "name", "description": "Display name", "dataType": "TEXT", "isRequired": true, "displayOrder": 1 },
        { "code": "description", "description": "Decision meaning", "dataType": "TEXT", "isRequired": false, "displayOrder": 2 }
      ],
      "values": []
    },
    "roles": {
      "metadataColumns": [
        { "code": "name", "description": "Display name", "dataType": "TEXT", "isRequired": true, "displayOrder": 1 },
        { "code": "description", "description": "Purpose", "dataType": "TEXT", "isRequired": false, "displayOrder": 2 }
      ],
      "values": [
        {
          "code": "initiator",
          "type": "Group",
          "sortOrder": 1,
          "securityGroupAttributeCode": "INITIATE",
          "metadata": { "name": { "en-CA": "Initiator" }, "description": { "en-CA": "Submits requests" } }
        }
      ]
    }
  },
  "securityGroups": [
    {
      "attributeCode": "INITIATE",
      "name": "Initiate",
      "description": "Users permitted to create and submit requests.",
      "metadata": null,
      "sortOrder": 1
    }
  ]
}
```

### Import matching and synchronize

- Validate selected Application `UniqueCode` == `applicationUniqueCode` (blocking).
- Match Data Entities and Columns by **current** `Code` within the Application.
- Create missing Codes; update matched Codes (description, sortOrder); **remove** Codes in the target that are absent from the file.
- When `securityGroups` is present: treat items as portable definitions by `attributeCode`; materialize onto **every enabled** Business Entity (create missing APPSG + EAC rows with convention Name; update Description/Metadata/SortOrder without overwriting Name; remove AttributeCodes absent from the file with **delete-with-config**). Legacy `businessEntityCode` is ignored after collapse. Code length > 700 hard-fails.
- When Process Framework sections are present (nested or legacy flat): match metadata columns by `(code, owner)`; roles/steps by `code`; options by `stepCode` + `code`; sync order metadata columns → roles → steps → options, removals in reverse. Removing a metadata column is always allowed (cascades translations → values → column); removing a Step / Role is blocked while a remaining Option / Step references it; a Data Entity referenced by a `DDL` column cannot be removed.
- No rename detection.
- Removing a Data Entity is blocked when any rows exist in any Application Context.
- Removing a Column is **always allowed**; synchronize deletes associated metadata values first, then the column (same rule as Settings Save).
- All-or-nothing: validate → Import Summary (`BoImportSummaryDialog` with App Config **custom** Changes Summary: Entity · Item · Type · New · Updated · Deleted — aggregated business units, not object codes; Errors block Synchronize) → confirm → single SQL transaction (`P_POST_EACApplicationConfigurationSync`). Aggregation model: [application-configuration-deployment.md](../architecture/app-configuration/application-configuration-deployment.md#import-analysis-summary). Pattern: [import-summary.md](../docs/ui/patterns/import-summary.md).
- Authorization: Global System Administrator or Application administrator group (`APP_*`) for the selected Application.
- Max size: EAC `ApplicationConfigurationImport:MaxFileSizeMb` (default **5**); in-memory only.
- Filename on export: `{applicationUniqueCode}.application-configuration.json`.
- Local Docker may seed the same envelope after Applications/BE SQL: EAC's reset (`SYSTEM-ADMIN-EAC` `scripts/dev-reset.ps1` + `tools/BreezeOn.Eac.LocalAppConfigurationSeed`) discovers and imports each consuming application's file from that application's own `seed/eac/` folder ([§ Per-application `seed/eac`](#per-application-seedeac-local-docker)); never hosted environments.

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
| Local Values JSON (`breezeon.eac.data-entity-values`) | Rows for local Docker seed | Synchronize-by-Code at seed time; lives in the consuming app's `seed/eac/`; **local only**, **never hosted**; **not** a product import/export feature |

**Never hosted:** Do not attempt to import `breezeon.eac.data-entity-values` into DEV/UAT/PRD. Hosted Values travel via Excel only.

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
- Flow: upload → choose mode → **analyze** (nothing written) → shared **Import Summary** (`BoImportSummaryDialog`) with Excel `ChangesSummaryContent` — **Changes Summary** (Data Entity · Included? · New · Updated · Deleted; Deleted shows bold N/A for Add/Update mode and excluded entities) and **Errors and Warnings** (Type · Message; missing-worksheet warning for excluded Data Entities) → **Import**. When nothing differs, the UI reports "No changes detected" and Import is disabled. After a successful import all Excel dialogs close, Data Entities/Values refresh, and the first Data Entity is selected. Pattern: [import-summary.md](../docs/ui/patterns/import-summary.md).
- **All-or-nothing:** any structure or row error rejects the whole file; apply saves every Data Entity through the existing Values save path in **one database transaction**.
- Authorization: Global System Administrator or Application object administrator.

### Validation and limits

- Extension: `.xlsx` only (official OOXML workbook).
- File processed **in memory only** — never stored permanently.
- Configurable max size: EAC `DataEntityExcelImport:MaxFileSizeMb` (default **25**).
- Export loads all context rows via `System.P_GET_EACDataEntitiesRowsForExcel` (approved full-load exception to [ADR-008](../decisions/ADR-008-query-driven-data-retrieval.md)). Import analysis **parses first**, then loads destination rows only for **included** Data Entities (`@DataEntityGuidsJson`). The SP returns two result sets (rows + sparse metadata). Schema uses `P_GET_EACDataEntitiesColumnsByApplication`. Analyze latency diagnostics: **Debug** logger category `BreezeOn.Eac.DataEntities.Excel.Analyze` (stage breakdown + `OperationId`; opt-in). See [data-entities-architecture.md](../architecture/data-entities/data-entities-architecture.md#excel-tool-values-portability) and EAC `README_AI.md`.

---

## Security Group Members (`breezeon.eac.security-group-members` + Excel)

Bulk **membership-only** portability for Application Configuration → Security Groups. Surfaced by EAC Actions **Bulk Actions** → **Manage Group Members** dialog (**Format** = JSON | Excel; **Import Type** = Add Missing | Overwrite Members). Implementation lives in **SYSTEM-ADMIN-EAC** (`Components/SecurityGroups/MembersPortability`). JSON and Excel share one import contract → validation → analysis → summary → apply path after parse.

**Does not** create, delete, rename, or edit Security Group metadata (AttributeCode, Name, Description, Metadata, SortOrder, GroupCode). Application Configuration JSON (`breezeon.eac.application-configuration`) still **excludes** members — keep the kinds separate.

### JSON envelope

| Field | Required | Notes |
| --- | --- | --- |
| `schemaVersion` | Yes | String. Current: `"1.0"` |
| `kind` | Yes | `"breezeon.eac.security-group-members"` |
| `groups` | Yes | Array (may be empty) |

### Group item

| Field | Required | Notes |
| --- | --- | --- |
| `attributeCode` | Yes | Business identifier; resolve to existing context Security Group. **Do not** include GroupCode. |
| `members` | Yes | Array of strings — Identity `UserPrincipalName` values (UPN only; not `Email`) |

### Example

```json
{
  "schemaVersion": "1.0",
  "kind": "breezeon.eac.security-group-members",
  "groups": [
    {
      "attributeCode": "APPROVERS",
      "members": [
        "user1@company.com",
        "user2@company.com"
      ]
    },
    {
      "attributeCode": "FINANCE",
      "members": []
    }
  ]
}
```

### Scope and matching

- Scoped to the **selected Application Context** only.
- Match groups by **AttributeCode** (case-sensitive as stored; normalize only for UPN matching).
- Member match: `Identity.Users.UserPrincipalName` only — `Trim()` + `ToLowerInvariant()`. Do not match `Email`.
- Groups omitted from the file are **untouched** in every mode.
- Unknown AttributeCode → warning; skip that group; never create a Security Group.
- Unknown / disabled UPN → warning; skip that user; continue.
- Duplicate UPNs within a group → warning; dedupe; continue.
- Ambiguous duplicate normalized UPNs in Identity → warning; skip that address.

### Import modes

- **Add Missing:** union destination with import members; never removes. Warn when existing members are absent from the file (removals ignored).
- **Overwrite Members:** replace destination membership with resolved import members. For **JSON**, empty `members: []` clears that group. For **Excel**, clearing a group is **not representable** (empty UPN is a blocking error; missing Attribute Code means omit/untouched) — use JSON to clear. Groups themselves are never removed.

Flow: upload → parse (JSON or Excel) → shared document → validate → bulk-load groups/members/UPNs once → in-memory delta → **Import Summary** (`BoImportSummaryDialog` custom Changes Summary: Attribute Code · Group Code · Group Description · New · Removed · Not Found · Duplicates · Total Members After Import; Errors/Warnings) → confirm → `System.P_POST_EACSecurityGroupMembersBulk` in one transaction → `InvalidateUser` for each affected user. Pattern: [import-summary.md](../docs/ui/patterns/import-summary.md).

**Download Template** / **Export** require Format selected. Template includes all context groups (JSON empty arrays / Excel empty UPN placeholder rows; first group sample UPN `sample.user@company.com`). Filenames: `Security Group Members.json` or `Security Group Members.xlsx`. Blocking file/schema validation failures surface as **Errors** in the Import Summary (Import disabled); they are not toast-only.

### Excel workbook (`*.xlsx`)

| Item | Rule |
| --- | --- |
| Sheet | `Group Members` (required) |
| Table | `GroupMembers` (**required**; no header-only fallback) |
| Columns | `Attribute Code`, `UPN` |
| Row grain | One row per member |
| Export | Only groups with ≥1 member (no rows for empty groups) |
| Template | All groups; first sample UPN; others Attribute Code + empty UPN |
| UX | AutoFilter, freeze header row, auto-sized columns (ClosedXML) |
| Import empty UPN | Attribute Code present + empty UPN → **blocking Error** |

### Authorization and limits

- Authorization: same as Security Groups Save — Global System Administrator **or** Application administrator for the context (`CanManage`).
- Extensions: `.json` or `.xlsx` per selected Format; in-memory only.
- Max size: EAC `SecurityGroupMembersImport:MaxFileSizeMb` (default **5**) for both formats.
- Analyze diagnostics: Debug logger category `BreezeOn.Eac.SecurityGroups.Members.Analyze`.

---

## Translations Excel (EAC-owned catalog)

Bulk maintenance for **EAC-owned** translations only. Surfaced by Application Configuration → **Translations** → **Bulk Actions**. Implementation: **SYSTEM-ADMIN-EAC** (`Components/Translations/Excel`, ClosedXML).

| Kind | App Config JSON | Translations Excel |
| --- | --- | --- |
| Data Entity row Description | No (excluded) | Yes |
| Process Framework column labels | Yes (`description` language map when PF participates) | Yes |
| Process Framework TEXT metadata | Yes (in Role/Step/Option `metadata` when PF participates) | Yes |
| Variable TEXT values | Yes (in `variables.values` when Variables participates) | Yes |
| Enabled languages | Yes (`languages` when section participates — replace) | No (Settings UI / portable JSON) |

**Authoritative language:** `en-CA` source required; clearing `en-CA` blocked. Status in Excel/grid: **Translated** / **Missing** only.

**Excel concurrency:** **Last Writer Wins**. No export baseline token. Import Summary warns that a stale workbook can overwrite newer values (including `en-CA`). Default-language column remains writable.

**JSON promote:** Replace (not merge). When Variables / Process Framework / Languages participate, target-only translation maps or languages for those sections are removed. Import Summary warns about replacement semantics.

**Scale:** Intended for PF, Variables, and moderate DE volumes; very large DE catalogs are Future Validation.

**SourceKey** natural-key cross-environment import: Future Validation (environment-local GUIDs today).

**Ownership boundary:** business-application string catalogs and EAC UI `.resx` chrome are out of scope.

### Workbook

| Item | Rule |
| --- | --- |
| Sheet | `Translations` (required) |
| Table | `TranslationsTable` (required; AutoFilter) |
| Row grain | One row per translatable item |
| Fixed columns | `SourceKey` (protected write token), `Entity`, `Type`, `Item`, `Identifier`, `ApplyTo`, `Status` |
| Language columns | One column per enabled language for the Application Context (`en-CA`, `fr-CA`, …) |
| Status | Export-only review rollup (`Matched` / `Unmatched`); ignored on import |
| Last Modified | Omitted from Excel |

### Import safeguards

- **Import Type** (required before Import; same pattern as Data Entity Excel / Security Groups Members):
  - **Add Missing & Update Existing** — only non-blank language cells write; blank cells leave destination values untouched.
  - **Overwrite Translations** — true overwrite; blank language cells clear the corresponding destination value (`P_POST_EACTranslationsSave` empty/null Value).
- Identity columns (`SourceKey` + Entity/Type/Item/Identifier/ApplyTo) must match the destination; changing them is a blocking Error.
- Only language value cells may change (per Import Type rules above).
- Unknown / not-enabled language headers → Errors. Unknown `SourceKey` → Warning (ignored).
- Flow: choose Import Type → upload → parse → analyze → **Import Summary** (Entity · Type · New · Updated) → confirm → `P_POST_EACTranslationsSave` one transaction.
- Max size: EAC `TranslationExcelImport:MaxFileSizeMb` (default **25**). Authorization: Application Configuration manage (GSA or `APP_*`).

### Export layout

- Word wrap off; metadata columns width **12**; language columns width **25**.
- Language columns use a soft primary header/data tint so editable columns are visually distinct from metadata.
