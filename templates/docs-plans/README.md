# Product `docs/plans/` layout

Owner: Documentation

Copy this layout into **product** repositories (not required inside STANDARDS itself unless STANDARDS needs its own temporary plans).

```text
docs/
└─ plans/                         # parent lifecycle folder only
   ├─ README.md                   # optional thin pointer to STANDARDS
   ├─ in-progress/                # new + active plans
   │  └─ <feature-plan>.md
   └─ implemented/                # completed plans (Option A archive)
      └─ <feature-plan>.md
```

## Rules

- Create **new** plans under `docs/plans/in-progress/`.
- Keep **active** plans under `docs/plans/in-progress/`.
- After successful implementation + documentation + knowledge transfer: move to `docs/plans/implemented/` (preferred) or delete if fully transferred.
- Do **not** store plan markdown directly in the flat parent `docs/plans/` folder.
- One authoritative active plan per feature.
- When updating an existing plan: **delta updates only** — update the existing file directly; do not regenerate, rewrite unchanged sections, or create V2/duplicate plans.
- Never dump plan bodies into chat — see org SSOT:

https://github.com/Breeze-On/STANDARDS/blob/main/docs/planning-and-development-agents.md
