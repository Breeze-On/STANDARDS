<!-- Classification: AA; Scope: application:eac -->
# DEV-001 — Process Framework future engine vision

| Field | Value |
| --- | --- |
| **Id** | DEV-001 |
| **Title** | Process Framework future engine vision |
| **Standard cited** | Current-reality-only policy in [`docs/documentation.md`](../documentation.md); hosting in [`architecture/process-framework/README.md`](../../architecture/process-framework/README.md) |
| **Scope** | application:eac (documentation exception for labeled future **engine** vision adjacent to normative authoring SSOT) |
| **Approved exception** | The Process Framework architecture document may retain a clearly labeled **Business vision (future engine)** section describing a future Process Automation Workflow Engine that is **not** implemented. That section is non-normative for **runtime execution and engine behaviour only**. **Authoring semantics** (Role, Step, Option, Terminal Step, Informational Step, Routing, Outcome, Entry Step, graph rules, expressiveness boundary) are **normative current reality** and are **not** covered by this exception. |
| **Rationale** | Separating unshipped engine behaviour from shipped authoring capability so administrators and AI agents treat PF as a business capability today without mistaking engine runtime for shipped product. |
| **Expiry / review** | Until the engine ships (then promote into AA architecture) or the vision is withdrawn |
| **Owner area** | Architecture |
| **Related** | ADR-019 |

## Approved exception (normative)

See table above. Agents must not treat the vision section as shipped **engine** capability. Agents **must** treat authoring semantics in the Current reality / Business meaning sections as binding.
