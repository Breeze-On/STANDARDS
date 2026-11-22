<!-- Classification: AA; Scope: application:eac -->
# Construct selection — Variables, Data Entities, Process Framework, Business Entities, Security Groups

Owner: Architecture (EAC)

**Normative** table for administrators and AI agents. Cross-linked from Variables, Data Entities, Process Framework, Business Entities, and Security Groups documentation.

| Construct | One-line meaning | Use when | Example |
| --- | --- | --- | --- |
| **Variable** | **One** configurable value for **one** Application Context | A single typed setting that may differ per context | Approval Limit |
| **Data Entity** | **Many** reference-data items (flat list) | A governed list of named items with optional flat attributes | Cost Centers |
| **Process Framework** | Workflow routing and process definition (one per Application) | Who acts, what happens, which decision goes where | Invoice Approval Workflow |
| **Business Entity** | Organizational hierarchy and scope | Org unit / geography / department node that gets its own context | Finance Department |
| **Security Group** | Access control and assignment | Grants and membership (AttributeCode soft-refs) | Approvers |

### Quick disambiguation

| Requirement | Choose |
| --- | --- |
| Approval Limit (one number per context) | **Variable** |
| Cost Centers list | **Data Entity** |
| Invoice Approval Workflow | **Process Framework** |
| Finance Department (org node) | **Business Entity** |
| Approvers (who may act / membership) | **Security Group** |
| Per-role approval limit | Prefer **PF Role metadata**, not a Variable |
| Company / department display name | Prefer **Business Entity** Description, not a Variable |
| Passwords / API keys / tokens | **None of the above** — platform secret management only |

Related: [variables-standard.md](../variables/variables-standard.md) · [data-entities-standard.md](../data-entities/data-entities-standard.md) · [process-framework/README.md](../process-framework/README.md) · [eac.md](../applications/eac.md) · field tables [`docs/data-portability.md`](../../docs/data-portability.md).

---

## Envelope-level hazards (App Config JSON)

Authoring Application Configuration JSON files locally is an **allowed** development activity. **Executing** hosted Import / Sync against a non-local environment requires **current-prompt** authorization ([ai-agent-governance.md](../../docs/ai/ai-agent-governance.md)).

When a section key is **present**, synchronize is complete for that section (omit = skip). Empty arrays inside a present section are destructive:

| Present section / shape | Effect when synchronized |
| --- | --- |
| `variables.values: []` | Deletes **all** Variable values Application-wide |
| `dataEntities: []` (or empty entities list when section present) | Plans removal of all Data Entities |
| PF `processFramework` edit that also sets `dataEntities: []` | Same DE removal hazard — export full file → edit only `processFramework` → leave `dataEntities` unchanged |
| Other present section with empty child arrays | Treat as full-section sync for that participation — see PF/DE/Variables [ai-authoring-contract.md](../variables/ai-authoring-contract.md) siblings |

SSOT hazards + kind catalog + promote sequence: [`docs/data-portability.md`](../../docs/data-portability.md). Spoke contracts: [variables](../variables/ai-authoring-contract.md) · [data-entities](../data-entities/ai-authoring-contract.md) · [process-framework](../process-framework/ai-authoring-contract.md).
