# UX Standards Enforcement Review & Remediation

**Status:** implemented  
**Repos:** STANDARDS (normative), SYSTEM-SHARED-UI (component enforcement), SYSTEM-ADMIN-EAC (retroactive consumer remediation)  
**Out of scope for early phases:** Feature redesign of Process Framework; this plan prevents recurrence and defines later remediations.

## Locked decisions (defaults)

- **Page Freeze:** Mandatory for perceptible multi-query workspace/config hydrations (including tab activation that reloads backend data). "Tab changes" in [overlays.md](../../ui/shell/overlays.md) means chrome-only flips with no backend reload. Keep filter/sort/page and sub-second UI exempt. Prefer `RunAsync`; ban page-local overlays. No automatic framework freeze in Phases 1–3—explicit calls + checklist/agent enforcement first.
- **Placeholders:** Platform default resource keys only unless a documented semantic exception exists (must not echo labels or restate "empty"; see ux-conventions.md § Placeholders). Column-title-as-placeholder is forbidden.
- **Control width / truncation:** Layout tracks stay stable; long closed values truncate with ellipsis + hover title; values never expand controls or skew columns. Enforce in Shared UI (`BoDropDownList` closed value, field display companions, Shuffle Card tracks already `minmax(0, …)`).
- **Disabled styling:** One shared disabled chrome contract across `BoTextField`, `BoDropDownList`, Number, Date, PeoplePicker (muted text, grey fill, placeholder omit when disabled).
- **Navigation state:** Entering a major EAC workspace (or changing Application / Business Entity) opens the documented primary view; do not inherit prior sub-state unless the page explicitly documents keep-alive intent.
- **Admin surface language:** No implementation identifiers in admin-facing copy (e.g. `ExternalObjectId`); technical Settings columns allowed only when they are the admin's configuration contract and labeled in product language.

## 1. Root cause analysis

Deviations were not primarily "Process Framework complexity." They cluster into six causes:

1. **Standards exist but are hard to discover for agents** — UI rules live under `docs/ui/` and [page-development.md](../../ui/page-development.md), but [planning-and-development-agents.md](../../planning-and-development-agents.md) and Cursor Planning/Dev rules contain **no UI checklist mandate**. Discovery depends on a long quickstart link chain.
2. **Cross-control conventions are underspecified** — Placeholders, disabled chrome, and truncation are per-control notes, not a single UX conventions standard.
3. **Reusable components do not fully enforce the intended UX** — `BoGrid` truncates display cells; `BoDropDownList` closed value and Shuffle Card cells do not. Disabled DDL still shows placeholder (unlike Text). Shuffle header/cell alignment relied on host discipline.
4. **Ambiguous freeze guidance** — Freeze "SHOULD" for perceptible lookups but "SHOULD NOT" for tab changes / routine navigation. Tab-activated multi-query reloads fall in the grey zone.
5. **Product patterns copy product patterns** — Product apps copied local habits instead of Gallery + STANDARDS.
6. **No mandatory UX/UI research gate before implementation** — Architecture/schema/security/reusability are challenged before build; UX/UI discovery was not a peer gate. Plans can pass architecture review while skipping Gallery, Shared UI reuse, placeholder/alignment/freeze/navigation/disabled/truncation conventions.

## 2. Process Framework findings (classification)

Platform signals (not Phase 1–3 code fixes):

- Shuffle header misalignment — reusable gap / incomplete component fix
- Custom placeholders — existing standard not followed + docs gap
- Disabled DDL vs Text — reusable gap + docs gap
- Value-driven resize / long-value layout break — missing standard + reusable gap
- Navigation sub-state inheritance — missing standard
- Missing Page Freeze on large config loads — docs gap / not followed
- Implementation-specific admin columns/copy — missing standard + defect
- Reusable concepts bypassed — reusable gap + not followed

## 3. Standards gap analysis

Add **`docs/ui/patterns/ux-conventions.md`** (SSOT for cross-control rules). Cover column header alignment, control width/truncation, placeholders, disabled vs read-only, navigation state, Page Freeze matrix, admin surface language.

## 4. Page Freeze strategy

**MUST:** saves/deletes/imports/exports/sync/bulk; workspace/config hydration with perceptible backend work (including tab activation that reloads data); perceptible lookup loads before edit dialogs.

**MUST NOT:** grid filter/sort/page/search; chrome-only tab/accordion/dialog; validation-only/local/sub-second; ordinary route navigation that paints chrome before optional secondary fetches.

**Optional:** single fast lookup when latency unlikely; prefer freeze if unsure and multi-second class.

Prefer `RunAsync`; ban page-local overlays; no automatic framework freeze in Phases 1–3.

## 5. Shared component review (Phase 3)

`BoShuffleCardGrid` Align + track parity; `BoDropDownList` truncation + disabled placeholder omit; unified field disabled chrome; promote `BoFieldReadOnly`; Gallery demos.

## 6. Documentation and agent guidance

Quickstart, AI summary, planning/dev agents, Cursor rules: mandatory UX Standards Compliance Review subsection; Dev Agent must confirm existing component/Gallery/pattern before custom UX.

## 7. Enforcement strategy

1. Component-level defaults in Shared UI
2. Development checklist items
3. **UX Standards Compliance Review (mandatory before development)** — peer gate to architecture/data/security
4. Planning Agent — UX Standards Compliance subsection (components, Gallery, standards, freeze, placeholders, nav-state, truncation, disabled/read-only, deviations)
5. Dev Agent — validate existing pattern before custom UX; refuse undocumented deviations
6. Code review checklist including pre-dev UX compliance confirmation
7. Documentation indexes; product READMEs not SSOT
8. Architecture review gates — Example Governance DoD; UX compliance peer gate

## 8. Retroactive remediation phases

1. Standards updates
2. Documentation and agent guidance
3. Shared UI corrections + Gallery
4. EAC feature corrections (Process Framework + sibling tabs; not domain redesign)
5. Validation and governance; move plan to `docs/plans/implemented/`

## 9. Risks

Over-aggressive freeze; truncation hiding codes (mitigate with hover title); intentional BoGrid vs Shuffle header Align difference; Phase 4 scope creep into domain v1 gaps.

## Implementation notes

Completed across STANDARDS (ux-conventions, freeze matrix, agent rules, PR checklist), SYSTEM-SHARED-UI (DDL truncation/disabled placeholder omit, Shuffle Align, Gallery docs), and SYSTEM-ADMIN-EAC (Process Framework + sibling placeholder/freeze/read-only/N/A remediations). Knowledge lives in permanent docs; this file is historical.

