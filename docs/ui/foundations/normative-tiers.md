<!-- Classification: AA; Scope: platform; Domain: UI; Capability: Foundations -->
# UI — Normative tiers

Owner: UI

Defines **how strongly** a rule in `docs/ui/` binds, who may change it, and which rule wins when two appear to conflict. Related: [overview.md](../overview.md), [ux-conventions.md](../patterns/ux-conventions.md), [example-governance.md](../example-governance.md), [DEV-002](../../deviations/DEV-002-example-governance-approved-exceptions.md).

Current reality only.

## Tiers

| Tier | Name | What it covers | Compliance | Change control |
| --- | --- | --- | --- | --- |
| **1** | **LOCKED** | Behavior and contract: interaction semantics, selection authority, keyboard and accessibility rules, validation flow, Add New / Dirty State flow, data-contract shape (`DateTime?`, `decimal?`), host contract, `Bo*`-only (no Fluent types in product pages) | **Mandatory.** PR blocker. Product code, Gallery, and agents must comply | STANDARDS change **plus** owner approval (ADR when architectural) **plus** same-change-set updates to [`public-component-api.md`](https://github.com/Breeze-On/SYSTEM-SHARED-UI/blob/main/docs/public-component-api.md) (if API affected), Gallery example, and AI index. Deviation only through a registered [deviation](../../deviations/README.md) entry |
| **2** | **STANDARD** | Org-default visual and structural conventions expressed through **tokens**: radius, spacing, type scale, motion durations, component chrome, default placements | **Required by default.** Deviation allowed when justified in the [UX Standards Compliance Review](../patterns/ux-conventions.md#ux-standards-compliance-review-locked--before-development) | STANDARDS change reviewed by UI owner; Gallery updated in the same change set. No ADR unless the token model itself changes |
| **3** | **GUIDANCE** | Recommendations, rationale, examples, "prefer" / "consider" advice, current-implementation notes | **Advisory.** Deviation needs no review | Edit freely; keep current-reality accurate |

## Precedence

1. **Tier 1 beats Tier 2 beats Tier 3.**
2. Within a tier, the **more specific** control SSOT wins over a general document (for example `button.md` beats `forms.md` for button behavior).
3. For a **visual value** (px, hex, duration), the token in [tokens.md](tokens.md) / [motion.md](motion.md) / [typography.md](typography.md) wins over any literal restated in prose. Prose should cite the token name, not copy the literal.
4. For an **API fact** (parameter, event, type), [`public-component-api.md`](https://github.com/Breeze-On/SYSTEM-SHARED-UI/blob/main/docs/public-component-api.md) wins — see [overview.md § Authority split](../overview.md#authority-split-ux-vs-api).
5. If documented behavior and shipped code disagree, it is a **defect**: fix one side and record which in the same change set. Never silently choose a side.
6. If **Gallery** (or any sample) and STANDARDS disagree on composition / UX, **STANDARDS win** — Gallery is illustrative only and must be corrected ([example-governance.md](../example-governance.md)).

## Legacy vocabulary mapping

Existing documents use older words. Until each file is migrated, read them as follows (do not rewrite every file for this):

| Legacy wording | Tier |
| --- | --- |
| "locked", "(locked)" heading — behavior/contract rules | **1** |
| "hard standard", "hard rule", "Hard", **MUST** / **MUST NOT** | **1** |
| "locked" on a **visual literal** (px, hex, ms) | **2** (the token is the authority; the literal is informative) |
| "org standard", "organization standard" | **2** |
| "(current)" tables of shipped values | Informative of current reality; the cited **token** carries Tier 2 |
| "should", "prefer", "typically", "consider", "e.g." | **3** |
| "EAC reference", "reference implementation" | **3** (see [actions-area.md](../patterns/actions-area.md), [dirty-state.md](../patterns/dirty-state.md)) |
| "Future Validation", "not shipped", "planned" | Not a rule — a recorded gap |

## Rules for authors

- Tag new rules with **Tier 1 / Tier 2 / Tier 3** (or "LOCKED" / "STANDARD" / "GUIDANCE") instead of inventing new emphasis words.
- Put each rule in **one** anchor document; elsewhere link to it. Do not restate a rule in three places.
- Do not put Fluent internals (`::part`, Fluent type names) in normative text.
- A new Tier 1 rule needs a Gallery example or a [DEV-002](../../deviations/DEV-002-example-governance-approved-exceptions.md) exception row ([example-governance.md](../example-governance.md)).
