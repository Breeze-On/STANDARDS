<!-- Classification: AA; Scope: application:eac; Domain: Platform; Capability: Variables -->
# Variables standard

Owner: Architecture (EAC)

Authoring: [authoring-guide.md](authoring-guide.md) · AI: [ai-authoring-contract.md](ai-authoring-contract.md) · Examples: [worked-examples.md](worked-examples.md) · Construct selection: [construct-selection.md](../app-configuration/construct-selection.md).

---

## What a Variable is

A **Variable** is one named, typed **business or environment setting** that an Application administrator maintains for an Application. Each Application Context may have its own value (or none).

**Problem solved:** configurable parameters without code changes or per-app config tables.

### Construct selection

See the normative table: [construct-selection.md](../app-configuration/construct-selection.md).

---

## What Variables may hold

Variables intentionally support **both**:

| Kind | Examples |
| --- | --- |
| **Environment configuration** | Email Sender, Support Email, Environment Name, Environment Banner, Helpdesk Address |
| **Business configuration** | Approval Limit, Due Days, Tax Percentage, Maximum Attachments, Feature Flags |

Application administrators remain responsible for understanding **deployment behavior** (values fully replace on sync) and promotion impacts. Do **not** invent environment markers, definitions-only promotion, or alternate deployment semantics in v1. Future enhancements = separate evaluation / Future Validation.

### Secrets — prohibited

Variables are **not** a secret store. Do **not** store:

- Passwords, API keys, client secrets, access tokens, certificates, secret-bearing connection strings

Use platform secret-management mechanisms instead ([security-governance.md](../../docs/security-governance.md), [architecture/security.md](../security.md)).

---

## Unset semantics

| State | Meaning |
| --- | --- |
| Value exists | **Configured** |
| No value row | **Unset** (not configured) |

- **No** application-level defaults in v1  
- **No** required values in v1  
- **No** Business Entity inheritance in v1  
- **Consumer** decides behavior when unset (outside the Variables contract)

Defaults / required / inheritance = **Future Validation**.

### BOOLEAN

Three states: **True**, **False**, **Unset**. Unset and False are **not** equivalent. UI supports explicit clear.

---

## What Variables can / cannot express

### Can

- Typed per-context settings (TEXT, NUMBER, BOOLEAN, DATE, DATETIME)
- Grouping hints via freeform Metadata
- Environment and business configuration (see above)

### Cannot

- Conditional rules / rules engines  
- Lists / multi-value / lookup binding (deferred types)  
- Units / currency / min-max enforcement as first-class fields  
- Secrets  
- Process routing (use Process Framework)  
- Reference lists (use Data Entity)

General multi-application Variables consumer APIs = **Future Validation** — do not invent a broad consumer SSOT. **Shipped exception:** Process Engine reads permanent Codes `sequence-template` / `sequence-display` (see [Permanent Variable Codes](#permanent-variable-codes-runtime-contracts)).

---

## Ownership

| Role | Reality |
| --- | --- |
| **Application Administrator** (GSA or `APP_*`) | Custodian of definitions and values for **all** contexts |
| Delegated stewardship / approval workflows | **Future Validation** |

Aligns with Process Framework and Data Entities.

---

## Technical rules (current reality)

| Rule | Detail |
| --- | --- |
| Scope | Definitions → Application; values → Application Context |
| Types | TEXT \| NUMBER \| BOOLEAN \| DATE \| DATETIME — **immutable** after create |
| **Code** | Lowercase kebab; **immutable after create** (portable identity) |
| Description | Required; English plain string on definition |
| Decimals | 0–10; default **0** for NUMBER |
| NUMBER rounding | Values may round to Decimals; Import Summary / Values Save **warn** (do not reject) |
| TEXT language | Authoritative **`en-CA`**; plain-string JSON import **normalizes** to en-CA |
| Sparse values | Absence = Unset |
| Portability | When `variables` present: both `definitions` and `values` required; `values: []` removes all values; omitted section = skip |
| Sync | Application-wide replace for participating Variables (documented blast radius) |

Operating envelope: tens to low hundreds of definitions; large catalogs / concurrency = Future Validation.

Seed JSON = **technical fixture** — prefer [worked-examples.md](worked-examples.md).

---

## Permanent Variable Codes (runtime contracts)

Some Variable **Codes** are permanent contracts consumed by platform runtime (not localization keys or display labels). Do **not** rename or alias them.

| Code | Consumer | Role |
| --- | --- | --- |
| `sequence-template` | Process Engine (Process Metadata Framework runtime) | Allocation stream key after token resolution |
| `sequence-display` | Process Engine | Request Number display prefix after token resolution |

**Missing / unset** at the Application Context → consumers treat the resolved raw string as **`""`** (no error, no platform fallback). Sequence **generation remains allowed** when either or both are missing. SSOT: [ADR-027](../../decisions/ADR-027-request-number-and-sequence-allocation.md) · [process-metadata/README.md](../process-metadata/README.md).

Runtime PE consumption of these Codes is **Current Implementation**. Broader multi-application Variables APIs beyond PE remain subject to the construct / Future Validation notes above.
