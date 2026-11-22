<!-- Classification: AA; Scope: platform -->
# Review governance — owner-oriented findings

Owner: Architecture

**Mandatory** format for BreezeOn reviews: documentation content reviews, code reviews that raise findings, architecture reviews, domain reviews (D01+), and future application reviews.

**Objective:** Optimize reviews for **owner decision-making and implementation clarity**, not audit-style evidence collection alone. The product owner must never have to interpret reviewer intent.

**Related:** Content-review execution roadmap lives in each product’s `docs/plans/` (e.g. SYSTEM-ADMIN-EAC). This file is the **org SSOT** for finding shape and Executive Summary; roadmaps and templates must reference it.

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

Correct contradictory documentation · Add explicit exception documentation · Clarify platform versus EAC ownership · Update an ADR · Implement validation · Future validation only · Architecture decision required · No action required

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

- Close domain/review and implement approved findings
- Close domain/review and defer findings
- Re-review specific findings only
- Hold open pending owner decision

---

## Severity model (domain content reviews)

| Severity | Meaning |
| --- | --- |
| **Critical** | Blocks safe addition of another BreezeOn application or creates severe security/data-integrity risk if left unaddressed |
| **Major** | Material architectural or business-model weakness; high cost if a second app inherits it |
| **Medium** | Real risk or contradiction that should be fixed before scale, but not an immediate blocker |
| **Minor** / **Observation** | Record only; **no remediation recommendation** |

Only Critical, Major, and Medium produce remediation recommendations (Reviewer Recommendation **Implement**, or Architecture Decision Required via Scope). Minor / Observation still use the mandatory fields; Recommended Action is often **No action required**, and Reviewer Recommendation is typically **Defer**, **Future Validation**, or **Reject**.

### Approval decision values

Exactly one per domain review report:

| Decision | Meaning |
| --- | --- |
| **Approved** | No Critical/Major open; Medium items accepted as deferred with owners/dates or waived with rationale; Future Validation listed explicitly |
| **Approved with Improvements** | Critical none; Major/Medium remediations accepted and scheduled; domain usable for downstream reviews |
| **Needs Rework** | Critical open, or Major findings that invalidate downstream sequencing until rewritten/re-decided |

Product roadmaps may cite this section; they must **not** redefine severity or approval values.

---

## Closed review-report lifecycle

Domain content-review reports are temporary plan artifacts (`Classification` may become **H** when archived).

After a domain reaches **Approved** or **Approved with Improvements** (with remediations closed or explicitly deferred):

1. Move the Closed report from `docs/plans/in-progress/` to `docs/plans/implemented/` (H-class archive), **or** delete only if every lasting decision already lives in permanent AA docs.
2. Do **not** leave Closed review reports in `in-progress/` indefinitely.
3. Re-open only with **new evidence** (code/schema change that breaks docs; later AA contradiction; material incident; new app scope change; Critical security finding).

Active/in-flight review reports and the content-review roadmap stay under `docs/plans/in-progress/` until Closed.

---

## Templates

Domain content reviews: product `docs/plans/in-progress/domain-content-review-report-TEMPLATE.md` (must mirror this SSOT).

Other review types (PR / architecture / app kickoff) may use a shorter header but **must** use the same finding fields and Executive Summary buckets when they raise findings.
