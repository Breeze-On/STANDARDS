<!-- Classification: AA; Scope: platform -->
# Review governance — owner-oriented findings

Owner: Architecture

**Mandatory** format when a BreezeOn review raises findings (ad-hoc architecture, domain, code, or application reviews). This is a finding-shape SSOT — **not** authorization for recurring documentation review programs, standing roadmaps, or permanent review corpora.

**Objective:** Optimize reviews for **owner decision-making and implementation clarity**, not audit-style evidence collection alone. The product owner must never have to interpret reviewer intent.

---

## What every review must answer

For each finding, the report must make these questions unnecessary for the owner to reverse-engineer:

1. What exactly should be done?
2. Is implementation required?
3. Is a documentation-only change sufficient?
4. Is an architectural decision required?
5. Can the implementation proceed autonomously?
6. Should the finding be deferred as Future Validation?
7. Should the finding be rejected?

Every finding therefore states an explicit **Recommended Action** and **Expected Outcome**.

---

## Mandatory finding fields

Every finding (all severities) **must** include:

| Field | Requirement |
| --- | --- |
| **Problem** | Plain-English explanation suitable for a solution owner |
| **Evidence** | Concise supporting evidence (paths + short claims) |
| **Recommended Action** | **One** concrete recommendation — not vague |
| **Scope** | Exactly one value from the Scope list below |
| **Owner Decision Required?** | **Yes** (with the exact approval question) or **No** (why the team may proceed) |
| **Reviewer Recommendation** | Exactly one: Implement · Defer · Future Validation · Reject |
| **Expected Outcome** | What the ecosystem looks like after the recommendation is completed |

### Scope (exactly one)

- Documentation Only
- Documentation + Minor Implementation
- Documentation + Major Implementation
- Architecture Decision Required
- Future Validation Only
- Reject Finding

### Recommended Action examples

Correct contradictory documentation · Add explicit exception documentation · Clarify platform versus application ownership · Update an ADR · Implement validation · Future validation only · Architecture decision required · No action required

---

## Completeness gate

A review report is **not complete** unless:

- Every finding includes all mandatory fields above.
- The report ends with an **Executive Summary** (below).

Evidence-only tables without Recommended Action / Scope / Owner Decision / Reviewer Recommendation / Expected Outcome are **incomplete**.

---

## Executive Summary (required)

Every review report must end with:

### Implement Now

Findings recommended for immediate implementation.

### Future Validation

Findings that are valid but must not trigger current work.

### Owner Decision Required

Findings requiring explicit architectural or business approval (include the decision question).

### Potentially Overstated / Recheck

Findings where remediation is unclear, impact is uncertain, or additional verification is recommended before implementation.

### Recommended Disposition

Exactly one concise recommendation:

- Close review and implement approved findings
- Close review and defer findings
- Re-review specific findings only
- Hold open pending owner decision

---

## Severity model

| Severity | Meaning |
| --- | --- |
| **Critical** | Blocks safe addition of another BreezeOn application or creates severe security/data-integrity risk if left unaddressed |
| **Major** | Material architectural or business-model weakness; high cost if a second app inherits it |
| **Medium** | Real risk or contradiction that should be fixed before scale, but not an immediate blocker |
| **Minor** / **Observation** | Record only; **no remediation recommendation** |

Only Critical, Major, and Medium produce remediation recommendations (Reviewer Recommendation **Implement**, or Architecture Decision Required via Scope). Minor / Observation still use the mandatory fields; Recommended Action is often **No action required**, and Reviewer Recommendation is typically **Defer**, **Future Validation**, or **Reject**.

### Approval decision values

Exactly one per review report when an approval decision is recorded:

| Decision | Meaning |
| --- | --- |
| **Approved** | No Critical/Major open; Medium items accepted as deferred with owners/dates or waived with rationale; Future Validation listed explicitly |
| **Approved with Improvements** | Critical none; Major/Medium remediations accepted and scheduled |
| **Needs Rework** | Critical open, or Major findings that invalidate proceeding until rewritten/re-decided |

Do **not** redefine severity or approval values in product plans.

---

## Closed review-report lifecycle

Review reports are temporary plan artifacts.

After a review reaches **Approved** or **Approved with Improvements** (with remediations closed or explicitly deferred):

1. Promote lasting decisions into permanent AA/OPS/DEC/ENT docs in the same remediation change sets.
2. **Prefer delete** the closed report once knowledge is transferred. Keep under `docs/plans/implemented/` (`Classification: H`) only when retention is explicitly justified.
3. Do **not** leave Closed review reports in `in-progress/` indefinitely.
4. Do **not** invent standing content-review roadmaps or retain closed review corpora as long-term inventory.
5. Re-open only with **new evidence** (code/schema change that breaks docs; later AA contradiction; material incident; new app scope change; Critical security finding).

---

## Templates

Finding-bearing reviews may use a short product-local draft under `docs/plans/in-progress/` while open. Any template **must** mirror this SSOT’s finding fields and Executive Summary buckets. Do not maintain a permanent org review-report template library for its own sake.
