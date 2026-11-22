<!-- Classification: AA; Scope: application:eac; Domain: Platform; Capability: ProcessFramework -->
# Process Framework — Worked Examples

Owner: Architecture (EAC)

Business narratives → Roles / Steps / Options → routing → JSON. Normative rules: [README.md](README.md).

**Seed / sample configs** under EAC `sql/seed/` are **technical fixtures**, not modelling guidance. Prefer these examples.

Each example assumes **one Application = one process definition**.

---

## 1. Purchase Approval

### Business narrative

Finance needs a purchase request flow: an initiator submits; a manager reviews; if returned, the initiator corrects; otherwise finance approves or rejects. Outcomes are Approved or Rejected.

### Roles

| Code | Name | Meaning |
| --- | --- | --- |
| `initiator` | Initiator | Person who submits / corrects the request |
| `manager` | Manager | First-line review |
| `finance` | Finance Approver | Final approval |

### Steps and Options

| Sort | Step | Role | Options → Next |
| --- | --- | --- | --- |
| 1 | `submit` (Entry) | initiator | `send` → `manager-review` |
| 2 | `manager-review` | manager | `approve` → `finance-review`; `return` → `submit` |
| 3 | `finance-review` | finance | `approve` → `approved`; `reject` → `rejected` |
| 4 | `approved` | — | *(terminal)* |
| 5 | `rejected` | — | *(terminal)* |

Loops: `manager-review` / `return` → `submit` is valid.

### JSON (excerpt)

```json
{
  "schemaVersion": 2,
  "processFramework": {
    "roles": {
      "metadataColumns": [
        { "code": "name", "dataType": "TEXT", "description": "Display name", "displayOrder": 1, "isRequired": true },
        { "code": "description", "dataType": "TEXT", "description": "Purpose", "displayOrder": 2, "isRequired": false }
      ],
      "values": [
        { "code": "initiator", "type": "Group", "sortOrder": 1, "securityGroupAttributeCode": "INITIATE", "metadata": { "name": { "en-CA": "Initiator" }, "description": { "en-CA": "Submits and corrects purchase requests" } } },
        { "code": "manager", "type": "Group", "sortOrder": 2, "securityGroupAttributeCode": "REPORT", "metadata": { "name": { "en-CA": "Manager" }, "description": { "en-CA": "First-line review" } } },
        { "code": "finance", "type": "Group", "sortOrder": 3, "securityGroupAttributeCode": "ADMIN", "metadata": { "name": { "en-CA": "Finance Approver" }, "description": { "en-CA": "Final approval" } } }
      ]
    },
    "steps": {
      "metadataColumns": [
        { "code": "name", "dataType": "TEXT", "description": "Display name", "displayOrder": 1, "isRequired": true },
        { "code": "description", "dataType": "TEXT", "description": "What happens", "displayOrder": 2, "isRequired": false }
      ],
      "values": [
        { "code": "submit", "roleCode": "initiator", "sortOrder": 1, "metadata": { "name": { "en-CA": "Submit request" }, "description": { "en-CA": "Create or correct the purchase request" } } },
        { "code": "manager-review", "roleCode": "manager", "sortOrder": 2, "metadata": { "name": { "en-CA": "Manager review" }, "description": { "en-CA": "Review and approve or return" } } },
        { "code": "finance-review", "roleCode": "finance", "sortOrder": 3, "metadata": { "name": { "en-CA": "Finance review" }, "description": { "en-CA": "Final finance decision" } } },
        { "code": "approved", "sortOrder": 4, "metadata": { "name": { "en-CA": "Approved" }, "description": { "en-CA": "Purchase approved" } } },
        { "code": "rejected", "sortOrder": 5, "metadata": { "name": { "en-CA": "Rejected" }, "description": { "en-CA": "Purchase rejected" } } }
      ]
    },
    "options": {
      "metadataColumns": [
        { "code": "name", "dataType": "TEXT", "description": "Display name", "displayOrder": 1, "isRequired": true },
        { "code": "description", "dataType": "TEXT", "description": "Decision meaning", "displayOrder": 2, "isRequired": false }
      ],
      "values": [
        { "stepCode": "submit", "code": "send", "nextStepCode": "manager-review", "sortOrder": 1, "metadata": { "name": { "en-CA": "Send for review" } } },
        { "stepCode": "manager-review", "code": "approve", "nextStepCode": "finance-review", "sortOrder": 1, "metadata": { "name": { "en-CA": "Approve to finance" } } },
        { "stepCode": "manager-review", "code": "return", "nextStepCode": "submit", "sortOrder": 2, "metadata": { "name": { "en-CA": "Return to initiator" } } },
        { "stepCode": "finance-review", "code": "approve", "nextStepCode": "approved", "sortOrder": 1, "metadata": { "name": { "en-CA": "Approve" } } },
        { "stepCode": "finance-review", "code": "reject", "nextStepCode": "rejected", "sortOrder": 2, "metadata": { "name": { "en-CA": "Reject" } } }
      ]
    }
  }
}
```

**Not expressible in v1:** amount-based auto-routing (conditions) — every request follows explicit Options.

---

## 2. Employee Onboarding

### Business narrative

HR starts onboarding; IT provisions access; facilities assigns a desk; HR closes. v1 can only model this as a **sequence** (not parallel HR/IT/Facilities).

### Roles

| Code | Name |
| --- | --- |
| `hr` | HR Coordinator |
| `it` | IT Provisioner |
| `facilities` | Facilities |

### Steps and Options (sequential)

| Sort | Step | Role | Options → Next |
| --- | --- | --- | --- |
| 1 | `hr-start` (Entry) | hr | `ready` → `it-provision` |
| 2 | `it-provision` | it | `done` → `facilities-desk` |
| 3 | `facilities-desk` | facilities | `done` → `hr-close` |
| 4 | `hr-close` | hr | `complete` → `completed` |
| 5 | `completed` | — | *(terminal)* |

### JSON (excerpt)

```json
{
  "schemaVersion": 2,
  "processFramework": {
    "roles": {
      "metadataColumns": [
        { "code": "name", "dataType": "TEXT", "description": "Display name", "displayOrder": 1, "isRequired": true },
        { "code": "description", "dataType": "TEXT", "description": "Purpose", "displayOrder": 2, "isRequired": false }
      ],
      "values": [
        { "code": "hr", "type": "Group", "sortOrder": 1, "metadata": { "name": { "en-CA": "HR Coordinator" } } },
        { "code": "it", "type": "Group", "sortOrder": 2, "metadata": { "name": { "en-CA": "IT Provisioner" } } },
        { "code": "facilities", "type": "Group", "sortOrder": 3, "metadata": { "name": { "en-CA": "Facilities" } } }
      ]
    },
    "steps": {
      "metadataColumns": [
        { "code": "name", "dataType": "TEXT", "description": "Display name", "displayOrder": 1, "isRequired": true },
        { "code": "description", "dataType": "TEXT", "description": "What happens", "displayOrder": 2, "isRequired": false }
      ],
      "values": [
        { "code": "hr-start", "roleCode": "hr", "sortOrder": 1, "metadata": { "name": { "en-CA": "Start onboarding" } } },
        { "code": "it-provision", "roleCode": "it", "sortOrder": 2, "metadata": { "name": { "en-CA": "Provision access" } } },
        { "code": "facilities-desk", "roleCode": "facilities", "sortOrder": 3, "metadata": { "name": { "en-CA": "Assign desk" } } },
        { "code": "hr-close", "roleCode": "hr", "sortOrder": 4, "metadata": { "name": { "en-CA": "Close onboarding" } } },
        { "code": "completed", "sortOrder": 5, "metadata": { "name": { "en-CA": "Completed" } } }
      ]
    },
    "options": {
      "metadataColumns": [
        { "code": "name", "dataType": "TEXT", "description": "Display name", "displayOrder": 1, "isRequired": true },
        { "code": "description", "dataType": "TEXT", "description": "Decision meaning", "displayOrder": 2, "isRequired": false }
      ],
      "values": [
        { "stepCode": "hr-start", "code": "ready", "nextStepCode": "it-provision", "sortOrder": 1, "metadata": { "name": { "en-CA": "Ready for IT" } } },
        { "stepCode": "it-provision", "code": "done", "nextStepCode": "facilities-desk", "sortOrder": 1, "metadata": { "name": { "en-CA": "Access ready" } } },
        { "stepCode": "facilities-desk", "code": "done", "nextStepCode": "hr-close", "sortOrder": 1, "metadata": { "name": { "en-CA": "Desk ready" } } },
        { "stepCode": "hr-close", "code": "complete", "nextStepCode": "completed", "sortOrder": 1, "metadata": { "name": { "en-CA": "Mark complete" } } }
      ]
    }
  }
}
```

**Not expressible in v1:** parallel IT + Facilities tasks.

---

## 3. Vendor Review (recommended pattern)

**Narrative:** Procurement submits a vendor; compliance reviews; risk can return or approve; terminal Approved / Declined.

**Pattern:** Same as Purchase Approval (Actionable → Actionable → Terminals) with Roles `procurement`, `compliance`, `risk`. Use explicit Options for approve / return / decline. **Cannot** model risk-score branching without conditions (v1).

---

## 4. Change Request Routing (recommended pattern)

**Narrative:** Requester submits; change board chooses Standard vs Emergency path; both paths end at Implemented or Cancelled.

**Pattern:** Entry Step with Options `standard` → `cab-standard` and `emergency` → `cab-emergency`; each CAB Step Options to `implemented` / `cancelled` terminals. Routing is **manual Option choice**, not dynamic rules.
