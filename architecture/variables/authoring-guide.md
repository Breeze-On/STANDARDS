<!-- Classification: AA; Scope: application:eac -->
# Variables — Authoring Guide

Owner: Architecture (EAC)

Normative rules: [variables-standard.md](variables-standard.md). Construct choice: [construct-selection.md](../app-configuration/construct-selection.md). AI: [ai-authoring-contract.md](ai-authoring-contract.md).

---

## Before you start

1. Confirm the need is **one value per context** — not a list (Data Entity), not routing (Process Framework), not an org node (Business Entity), not membership (Security Group).  
2. Do **not** store secrets.  
3. You must be GSA or Application administrator.  
4. Open `/app-configuration` → **Variables**.

UI toggle order: **Variables** (values) | **Settings** (definitions).

---

## Sequence

### 1. Create definitions (Settings)

1. Add Variable: **Code** (kebab — locked after create), **Description** (required), **Data Type**, **Decimals** (NUMBER only; default 0).  
2. Optional Metadata tag (grouping hint only).  
3. Save. Changing Data Type later requires delete+recreate (wipes all context values).

| Type | Use for | Notes |
| --- | --- | --- |
| TEXT | Names, addresses, short labels | en-CA authoritative |
| NUMBER | Limits, days, percentages | Set Decimals at create; over-scale values **warn** then round |
| BOOLEAN | Feature flags | True / False / **Unset** (clearable) |
| DATE | Calendar dates | Year included |
| DATETIME | Moments | UTC storage |

### 2. Set values (Variables / Values)

1. Select Application Context.  
2. Edit values for definitions that apply. Leave blank = **Unset**.  
3. BOOLEAN: choose Yes / No or clear to Unset — Unset ≠ False.  
4. Save. Rounding warnings may appear for NUMBER; you may proceed.

### 3. Import / export

1. Export App Config JSON includes `variables.definitions` + `variables.values`.  
2. Edit carefully: `values: []` **deletes all** values Application-wide.  
3. Environment-specific Variables (email sender, banner) **will overwrite** on promote — review before Synchronize.  
4. Plain TEXT strings in JSON normalize to **en-CA**.

Local seed = fixture only — see [worked-examples.md](worked-examples.md).
