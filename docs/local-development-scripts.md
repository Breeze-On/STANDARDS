# BreezeOn Local Development Script Standard

Owner: Engineering

**Decision:** Every BreezeOn application (and the Shared UI Gallery host) exposes a **single** developer entry point:

```text
.\scripts\dev-reset.ps1
```

There is **no** `dev-up.ps1` and **no** `dev-down.ps1`. `dev-reset.ps1` is the authoritative local environment initialization and recreation process.

Related: [local-database.md](local-database.md) (SQL Docker pattern), [application-model.md](application-model.md), AI path [`docs/ai/`](ai/README.md).

## Required layout

```text
scripts/
└─ dev-reset.ps1
```

Optional helpers (e.g. `dev-common.ps1`, `local-db-init.ps1`, `local-db-seed.ps1`) may exist under `scripts/`. Humans and agents must still use **`dev-reset.ps1`** as the only documented startup command.

A short `scripts/README.md` may point at the product README § Local Development.

## Purpose

Provide a **one-command** local developer experience.

A developer should be able to:

1. Clone the repository  
2. Configure a local gitignored `.env` (from `.env.example`)  
3. Run `.\scripts\dev-reset.ps1`  
4. Begin development  

## Responsibilities

`dev-reset.ps1` performs all environment preparation the application needs, including where applicable:

1. Stop existing application processes for this repo  
2. Stop existing Docker resources owned by this repo (then start what is required)  
3. Start required Docker containers  
4. Load `.env` configuration  
5. Validate required environment variables (fail fast with clear errors)  
6. Verify dependencies are available (e.g. .NET SDK, Docker)  
7. Recreate the local development database (SQL apps)  
8. Apply schema / seed scripts and EF migrations as configured  
9. Build the solution / host project  
10. Launch the application  
11. Display a success / failure summary (URLs, what was reset)  

Steps that do not apply to a host (e.g. no SQL for Shared UI Gallery) are skipped with clear script output.

`dev-reset` is **destructive** for local data when the app owns a local database. Product READMEs must state that clearly.

## Secrets

- All secrets come from a local **gitignored** `.env` at the repo root.  
- Ship `.env.example` documenting required variables (never real secrets).  
- No passwords hardcoded in scripts or docs.  
- No secrets committed.  
- Missing required variables must produce clear errors.  

Apps with no local secrets today still keep `.env` / `.env.example` so the script model is uniform (example may state “no required variables”).

## Application vs Shared UI

| Concern | Application with SQL (e.g. ADM) | Shared UI Gallery |
| --- | --- | --- |
| Docker SQL | Required | Not used |
| Required `.env` vars | At least `MSSQL_SA_PASSWORD` | None required today |
| Schema / seed | `sql/current_model/` + `sql/seed/` | N/A |
| EF migrations | Apply on recreate as configured | N/A |
| Launch target | Product web project | `BreezeOn.UI.Gallery` |

Same **script name and UX**; inapplicable steps are no-ops or clearly skipped.

## README requirements

Each product `README.md` must include a **Local Development** section covering:

- Prerequisites (.NET SDK, Docker Desktop when required, local `.env`)  
- Example: `.\scripts\dev-reset.ps1`  
- What the script does  
- Required `.env` variables  
- Expected outcome (URLs, DB name if any)  
- Common troubleshooting  

Do **not** document alternate startup workflows that bypass `dev-reset.ps1`.

## Maintenance standard

**Whenever local development requirements change, `dev-reset.ps1` must be updated in the same change set.**

Examples:

- New Docker dependency  
- New database  
- New migration workflow  
- New environment variables  
- New local prerequisite  

The script must always remain the authoritative local startup process. Prefer modifying the existing script over introducing additional entry-point scripts.

## AI agent standard

When creating or modifying a BreezeOn application:

1. Reuse the existing `dev-reset.ps1` pattern.  
2. Do not invent a custom developer startup workflow.  
3. Keep README instructions aligned with the script.  
4. Keep the script updated as development requirements evolve.  
5. Prefer modifying the existing script rather than introducing additional scripts.  

Product `README_AI.md` must tell agents to use `.\scripts\dev-reset.ps1` for autonomous local verification.

## Recommendations for future applications

1. Copy the ADM or Shared UI `scripts/dev-reset.ps1` + `dev-common.ps1` pattern; strip or add SQL/Docker steps as needed.  
2. Add `.env.example` on day one, even if empty of required secrets.  
3. Wire Local Development in `README.md` and Autonomous local test in `README_AI.md` before the first PR that expects humans/agents to run the app.  
4. Do not reintroduce `dev-up` / `dev-down` or one-off “start.ps1” / “run-local.ps1” entry points.  
5. Keep lower-level helpers internal; never promote them as the human/agent entry point.

## Current reality

Implemented for:

- [SYSTEM-ADMIN-ADM](https://github.com/Breeze-On/SYSTEM-ADMIN-ADM) — `scripts/dev-reset.ps1` (+ SQL helpers)  
- [SYSTEM-SHARED-UI](https://github.com/Breeze-On/SYSTEM-SHARED-UI) — `scripts/dev-reset.ps1` (Gallery; no SQL)  

Future BreezeOn applications must ship this model when they add a runnable local host.
