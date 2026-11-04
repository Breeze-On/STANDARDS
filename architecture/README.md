# Architecture

Owner: Architecture

Descriptions of **implemented** Breeze On systems. Answers: **what exists**.

Current reality only — do not place planned or speculative designs here. How we work: [`docs/`](../docs/). Why decisions were made: [`decisions/`](../decisions/). Shared vocabulary: [`docs/glossary.md`](../docs/glossary.md).

## Index

| Document | Covers |
| --- | --- |
| [Landscape](landscape.md) | Ecosystem map: repos, UI dependency position, Azure hosting, SQL relationships, boundaries |
| [Ecosystem](ecosystem.md) | Org identity and existing repositories |
| [EAC](eac.md) | Enterprise Administration Center (current) |
| [Identity & Authentication](identity-and-authentication/README.md) | **Start here** for end-user OIDC, Identity schema, App Registrations, config, local auth (platform standard) |
| [Security](security.md) | SQL access / MI and secrets posture; end-user auth points to Identity & Authentication (dependency/vuln governance: [`docs/security-governance.md`](../docs/security-governance.md)) |
