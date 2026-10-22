# Documentation standards

Applies to every Breeze On repository.

## README.md (humans)

- Professional, concise, current-state only.
- Describe what the repo/application **is** and how to run or use what exists today.
- Do **not** include roadmaps, “coming soon,” planned environments, or speculative architecture.
- Link to [Breeze-On/STANDARDS](https://github.com/Breeze-On/STANDARDS) and to that repo’s `README_AI.md` when useful.

## README_AI.md (agents)

Required in every product/platform repo.

Must clearly state that agents shall:

1. Follow organization **STANDARDS** (`Breeze-On/STANDARDS`).
2. **Update documentation** whenever a task changes product behavior, scope, setup, or architecture (README, README_AI, and STANDARDS as applicable).
3. Treat documentation as **current state only** — never write future work as present fact.
4. Stay within the repo’s stated role and boundaries.

Keep `README_AI.md` high-level: role, stack locks that exist, surface that exists, agent rules. Not a tutorial or full design essay.

## Org profile

The organization landing README lives in `Breeze-On/.github` → `profile/README.md`. Same current-state rule applies.

## Change rule

Documentation updates are part of the Definition of Done for any change that alters shared understanding of the system.
