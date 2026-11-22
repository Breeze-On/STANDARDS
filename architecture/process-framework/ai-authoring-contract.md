<!-- Classification: AA; Scope: application:eac -->
# Process Framework — AI Authoring Contract

Owner: Architecture (EAC)

Machine-oriented contract so agents can generate **structurally valid** and **business-shaped** Process Framework JSON. Semantics: [README.md](README.md). Human guide: [authoring-guide.md](authoring-guide.md). Examples: [worked-examples.md](worked-examples.md). Field tables: [`docs/data-portability.md`](../../docs/data-portability.md#process-framework-sections).

---

## Recipe: business requirements → JSON

1. **Decide the unit** — One business process = one Application. If requirements describe two processes, emit two Applications (do not merge graphs).  
2. **Roles** — Extract actor groups; each gets `code`, required `type: "Group"`, `sortOrder`, optional `securityGroupAttributeCode`, metadata `name`/`description`.  
3. **Steps** — Extract activities/states; assign `sortOrder` (lowest = Entry); set `roleCode` only for Actionable Steps; metadata `name`/`description`.  
4. **Options** — For each Actionable Step, one Option per decision; set `stepCode`, `code`, `nextStepCode`, `sortOrder`; metadata `name`/`description`.  
5. **Shapes** — Ensure Terminal Steps have no outgoing Options; never emit Role-less Steps with Options.  
6. **Metadata columns** — Prefer `name` then `description` Codes; then other attributes.  
7. **Envelope** — Nest under `processFramework.{steps|options|roles}.{metadataColumns|values}` in schemaVersion **2**.  
8. **Validate** — Match the field table below; expect graph-lint **warnings** (not hard fails) for broken graphs.

---

## Required / optional (matches validator)

### Role (`processFramework.roles.values[]`)

| Field | Required | Notes |
| --- | --- | --- |
| `code` | Yes | Lowercase kebab-case; unique in Application |
| `type` | Yes | Must be `"Group"` |
| `sortOrder` | Yes | Integer; unique among Roles |
| `securityGroupAttributeCode` | No | `[A-Z0-9_]+` when present; soft ref |
| `metadata` | No | Map of column Code → value; prefer `name`, `description` |

### Step (`processFramework.steps.values[]`)

| Field | Required | Notes |
| --- | --- | --- |
| `code` | Yes | Unique in Application |
| `sortOrder` | Yes | Lowest = Entry Step |
| `roleCode` | No | Must reference an existing Role when set |
| `metadata` | No | Prefer `name`, `description` |

### Option (`processFramework.options.values[]`)

| Field | Required | Notes |
| --- | --- | --- |
| `stepCode` | Yes | Existing Step |
| `code` | Yes | Unique within Step |
| `nextStepCode` | Yes | Existing Step (cycles allowed) |
| `sortOrder` | Yes | Unique within Step in portable file; UI Save may renumber globally |
| `metadata` | No | Prefer `name`, `description` |

### Metadata column (`*.metadataColumns[]`)

| Field | Required | Notes |
| --- | --- | --- |
| `code` | Yes | Prefer convention `name` / `description` for labels |
| `dataType` | Yes | TEXT \| NUMBER \| DATE \| DATETIME \| BOOLEAN \| DDL \| PEOPLEPICKER |
| `description` | Yes | String or language map; en-CA authoritative |
| `displayOrder` | Yes | |
| `isRequired` | No | |
| `decimals` | When NUMBER | 0..10 |
| `dataEntityCode` | When DDL | Must exist in `dataEntities` when that section is synchronized |

---

## Hazards (do not ignore)

| Hazard | What goes wrong |
| --- | --- |
| **`dataEntities` participation** | App Config always synchronizes `dataEntities`. **Missing key ≡ `[]` ≡ full DE sync** (not omit=skip). A PF-only edit that omits `dataEntities` or sets `[]` **plans removal** of all Data Entities. **Recipe:** export full file → edit only `processFramework` → leave `dataEntities` unchanged. Half-skip: under a present PF owner, absent `values`/`metadataColumns` skips that half; `[]` synchronizes (can wipe). |
| **`sortOrder`** | Required and unique per entity set; Entry Step = lowest Step sortOrder. |
| **Security Group refs** | If `securityGroups` is in the file, AttributeCodes should match or Import Summary warns (dangling). |
| **Role `type`** | Omitting `type` fails validation. |
| **Role-less + Options** | Undefined in PF v1 — do not generate. |
| **TEXT language** | Author `en-CA` for TEXT metadata values. |

---

## Graph lint (warnings only)

Agents should self-check and fix before import when practical:

1. At least one Terminal Step (no outgoing Options)  
2. Every Step reachable from Entry Step  
3. Every Step with a Role has ≥1 Option  

Import never fails solely on these warnings.
