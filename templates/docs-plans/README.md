<!-- Classification: TPL; Scope: platform; Domain: Engineering; Capability: Stack -->
# Product `docs/plans/` layout

Owner: Documentation

Copy this layout into **product** repositories (not required inside STANDARDS itself unless STANDARDS needs its own temporary plans).

```text
docs/
└─ plans/                         # parent lifecycle folder only
   ├─ README.md                   # optional thin pointer to STANDARDS
   ├─ in-progress/                # new + active plans
   │  ├─ .gitkeep                 # keep empty folder in git clones
   │  └─ <feature-plan>.md
   └─ implemented/                # retained completed plans only when justified
      ├─ .gitkeep                 # optional when folder otherwise empty
      └─ <feature-plan>.md
```

## Rules

- Create **new** plans under `docs/plans/in-progress/`.
- Keep **active** plans under `docs/plans/in-progress/`.
- Track empty lifecycle folders with `.gitkeep` so clones retain `in-progress/` (and `implemented/` when empty).
- After successful implementation + documentation + knowledge transfer: **prefer delete** the plan; retain under `docs/plans/implemented/` only when retention is explicitly justified.
- Do **not** store plan markdown directly in the flat parent `docs/plans/` folder.
- One authoritative active plan per feature.
- When updating an existing plan: **in-place delta updates only** — edit the existing file; do not regenerate, rewrite unchanged sections, or create V2/duplicate plans.
- Never dump plan bodies into chat — see org SSOT:

https://github.com/Breeze-On/STANDARDS/blob/main/docs/ai/planning-and-development-agents.md
