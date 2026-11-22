<!-- Classification: ENT; Scope: platform; Domain: Engineering; Capability: DocStandards -->
# Breeze On — STANDARDS

Organization-wide **standards** and **current-state architecture** for every Breeze On repository.

**Canonical repo:** [Breeze-On/STANDARDS](https://github.com/Breeze-On/STANDARDS)

This repository is the single source of truth for how Breeze On builds and documents software. Documentation must represent **current reality only** — full rules: [`docs/documentation.md`](docs/documentation.md) (classification banners, precedence, category contracts, deviations, README allow-lists). Glossary: [`docs/glossary.md`](docs/glossary.md).

## How this repository answers questions

| Question | Where |
| --- | --- |
| Where should an AI agent start? | [`docs/ai/README.md`](docs/ai/README.md) (Quickstart first) |
| What may AI agents do? | [`docs/ai/ai-agent-governance.md`](docs/ai/ai-agent-governance.md) |
| Planning / Development Agents? | [`docs/ai/planning-and-development-agents.md`](docs/ai/planning-and-development-agents.md) |
| What exists (platform)? | [`architecture/`](architecture/) — start at [landscape](architecture/landscape.md) |
| Application references (e.g. EAC)? | [`architecture/applications/`](architecture/applications/README.md) |
| How do we work? | [`docs/`](docs/) |
| Approved exceptions? | [`docs/deviations/`](docs/deviations/README.md) |
| Why was this decided? | [`decisions/`](decisions/) |
| Operational procedures? | [`runbooks/README.md`](runbooks/README.md) |
| UI behavioral standards? | [`docs/ui/overview.md`](docs/ui/overview.md) |

## Repository structure

```text
STANDARDS/
├─ README.md / README_AI.md     # Entry points (ENT)
├─ docs/                        # Standards (how we work)
│  ├─ documentation.md          # Meta-SSOT (classification, precedence, contracts)
│  ├─ ai/                       # AI onboarding + AI process SSOT
│  ├─ deviations/               # First-class approved exceptions
│  ├─ plans/                    # in-progress / implemented (temporary / historical)
│  └─ ui/                       # UI behavioral standards
├─ architecture/                # What exists (platform)
│  └─ applications/             # Mature app references (not platform definitions)
├─ decisions/                   # ADRs (why)
├─ runbooks/                    # Operational procedures
└─ templates/                   # Copy-starters
```

## Related

- Agents: [`README_AI.md`](README_AI.md)
- Org profile: [Breeze-On/.github `profile/README.md`](https://github.com/Breeze-On/.github/blob/main/profile/README.md)
