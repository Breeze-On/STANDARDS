<!-- Classification: AA; Scope: application:eac; Domain: Platform; Capability: ProcessFramework -->
# Process Framework — Authoring Guide

Owner: Architecture (EAC)

For Application Administrators and Business Analysts who need to author a process definition **without** reading schema or Razor. Normative semantics: [README.md](README.md). Worked examples: [worked-examples.md](worked-examples.md). AI contract: [ai-authoring-contract.md](ai-authoring-contract.md).

---

## Before you start

1. Confirm you need a **new process** → that means a **new Application** (PF v1 = one process definition per Application).
2. You must be Global System Administrator or an Application administrator (`APP_*`).
3. Open EAC → `/app-configuration` → select Application + Business Entity context → **Process Framework** tab.

**UI card order (authoring order in the product):** Steps → Options → Roles.  
**Recommended design order (think first, then click):** Roles → Steps → Options → Metadata columns → validate → export/import.

---

## Step-by-step

### 1. Create Roles

On **Roles** (Entity view):

1. Add a Role for each **business actor group** (who is expected to act).
2. Set **Code** (kebab-case), **Type** = `Group`, optional **Security Group** (Attribute Code for the selected context).
3. Add metadata columns **`name`** and **`description`** under Settings (conventions — see README).
4. Save.

Role is **not** a permission grant — it names who should receive work.

### 2. Create Steps

On **Steps** (Entity view):

1. Add Steps for each activity or state.
2. Set **Code**, optional **Role**, **sortOrder** (the **lowest sortOrder is the Entry Step**).
3. Use metadata `name` / `description`.
4. Shape check:
   - Actionable → Role + later Options  
   - Terminal → no Options  
   - Informational → no Role  
   - Do **not** create Role-less Steps that still have Options (undefined in v1)

### Process History initiation (when the app uses Process History)

| Requirement | Detail |
| --- | --- |
| Entry Step code | **`00`** (lowest `sortOrder`) |
| Submit | Option **`va`** on step `00` (required) |
| Save | Option **`va1`** on step `00` (optional). **Save meaning only on step `00`** — do not reuse `va1` elsewhere to mean Save |
| Response Status | Option metadata **`response-status`** required on every option that can generate Process History |

See [ADR-025](../../decisions/ADR-025-process-history.md).

### 3. Create Options

On **Options** (Entity view):

1. For each Actionable Step, add one Option per business decision.
2. Set **Step**, **Code**, **Next Step**, sort order.
3. Use metadata `name` / `description` and **`response-status`** (required for Process History).
4. Loops are allowed (Next Step can point earlier in the flow).

### 4. Create Metadata (Settings)

For each of Steps / Options / Roles → **Settings**:

1. Prefer convention columns `name` and `description` first; on Options also add **`response-status`** (`isRequired`).
2. Add other business attributes (TEXT, NUMBER, DATE, BOOLEAN, Data Entity DDL, People Picker) as needed.
3. TEXT values are authored in **`en-CA`** (authoritative).
4. Save sends the full Application catalog.

### 5. Validation expectations

Import Analysis / planning may **warn** (never block) when:

- No terminal Step exists  
- Some Steps are unreachable from the Entry Step  
- A Step has a Role but zero Options  
- A Role’s Security Group Attribute Code is missing from the import file’s Security Groups (when that section participates)

Fix warnings before promoting to hosted environments when possible.

### 6. Import / export lifecycle

1. Export Application Configuration JSON from a known-good Application.  
2. Edit only the `processFramework` subtree (see AI contract hazards for `dataEntities`).  
3. Import → review Import Summary (creates/updates/removes + warnings) → confirm.  
4. Sync is replace semantics for participating sections.

Local seed JSON under EAC `sql/seed/` is a **technical fixture**, not business modelling guidance — prefer [worked-examples.md](worked-examples.md).
