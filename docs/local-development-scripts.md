<!-- Classification: AA; Scope: platform; Domain: Engineering; Capability: Stack -->
# BreezeOn Local Development Script Standard

Owner: Engineering

**Decision:** Every BreezeOn application (and the Shared UI Gallery host) exposes **two** developer entry points:

```text
.\scripts\dev-reset.ps1   # destructive full environment reset
.\scripts\dev-run.ps1     # non-destructive application-only launch
```

There is **no** `dev-up.ps1` and **no** `dev-down.ps1`. Do not invent one-off `start.ps1` / `run-local.ps1` entry points. Helpers stay internal; humans and agents use only these two named scripts.

**Developer workflow:**

| Situation | Command |
| --- | --- |
| Morning / fresh environment | `.\scripts\dev-reset.ps1` |
| Day-to-day coding | `.\scripts\dev-run.ps1` |

Related: [local-database.md](local-database.md) (SQL Docker pattern), [application-model.md](application-model.md), AI path [`docs/ai/`](ai/README.md).

## Required layout

```text
scripts/
├─ dev-reset.ps1
└─ dev-run.ps1
```

Optional helpers (e.g. `dev-common.ps1`, `local-db-init.ps1`, `local-db-seed.ps1`) may exist under `scripts/`. They are never the documented human/agent entry points.

A short `scripts/README.md` may point at the product README § Local Development.

## Purpose

Provide a clear two-command local developer experience:

1. Clone the repository  
2. Configure a local gitignored `.env` (from `.env.example`) and User Secrets for **BreezeOn-LOCAL**  
3. Run `.\scripts\dev-reset.ps1` once for a fresh environment (validates first-time startup)  
4. Use `.\scripts\dev-run.ps1` for day-to-day relaunch  

## Responsibilities — `dev-reset.ps1`

`dev-reset.ps1` performs all environment preparation the application needs, including where applicable:

1. Stop existing application processes for this repo  
2. Ensure required Docker containers are up (prefer leaving a healthy SQL container running; do not stop/start unnecessarily)  
3. Load `.env` configuration  
4. Validate required environment variables (fail fast with clear errors)  
5. Verify dependencies are available (e.g. .NET SDK, Docker)  
6. Recreate the local development database (SQL apps)  
7. Build consolidated schema/seed SQL from ordered sources into `generated/`, apply each with one sqlcmd (committed SQL export is a separate maintenance script when used)  
8. Run any local bootstrap required by the product (e.g. targeted directory upsert)  
9. Launch the application (`dotnet run` / host start; prefer app-startup migrate over a separate `dotnet ef database update` when the host already migrates) — validates first-time startup  
10. Display a success / failure summary (URLs, what was reset) and point day-to-day relaunch at `dev-run.ps1`  

Steps that do not apply to a host (e.g. no SQL for Shared UI Gallery) are skipped with clear script output.

`dev-reset` is **destructive** for local data when the app owns a local database. Product READMEs must state that clearly.

## Responsibilities — `dev-run.ps1`

`dev-run.ps1` is the **non-destructive**, application-only launch path. It must:

1. Print a clear banner that this is a non-destructive application-only launch  
2. Verify dependencies available for launch (e.g. .NET SDK)  
3. Verify required User Secrets exist (read-only), matching the keys the host validates on startup where appropriate  
4. Verify a local SQL connection is configured when the host uses local SQL (read-only; do not rewrite secrets from `.env`)  
5. Assume EAC and the local database already exist for EAC-consuming / SQL apps  
6. Stop existing processes for **this** application if necessary  
7. Launch **only** the application being developed (standard local launch: `dotnet run` / host start)  
8. Display a short summary (URLs; reminder that EAC/DB were assumed already running)  

`dev-run.ps1` must **never**:

- Recreate databases  
- Invoke EAC `scripts/dev-reset.ps1`  
- Reset Docker / docker compose down-up as a reset  
- Re-import EAC or other configuration  
- Perform other destructive environment operations  

If prerequisites are missing, fail fast with a clear error that points the developer to `.\scripts\dev-reset.ps1` for a fresh environment.

## Consumer apps and EAC reset

Applications that consume EAC (registry, Application Configuration, Security Groups, Data Entities) share the local SQL container and `BreezeOnLocal` database with **`breezeon-system-admin-eac`** ([local-database.md](local-database.md) § Shared local SQL instance and EAC dependency). For these apps:

1. `dev-reset.ps1` locates the **sibling** EAC checkout (same parent folder as the app repo; folder name `breezeon-system-admin-eac`) and fails fast with a clear error when it is missing.
2. `dev-reset.ps1` invokes EAC `scripts\dev-reset.ps1` as a **subprocess**. EAC owns the destructive work: database drop/recreate, EAC and platform schema (allowlisted `current_model` consolidation with local fail-fast + required-object smoke), discovery/apply of sibling **Process Engine** full Process Runtime SQL pack (`Global.Process` / `ProcessHistory` / sequence counter + SPs — PE **owns**; EAC **deploys**), bootstrap, and import of EAC configuration discovered in sibling `seed/eac/` folders ([data-portability.md](data-portability.md) § Per-application `seed/eac`; [database.md](database.md) § EAC Framework Synchronization · [ADR-026](../decisions/ADR-026-process-engine-and-metadata-framework.md) · [ADR-028](../decisions/ADR-028-process-runtime-ownership-process-engine.md)).
3. After EAC finishes, the consumer applies its own business schema/seed (`sql/current_model/`, `sql/seed/`) when it owns any, then launches itself. After pulling EAC framework DDL or PE Process Runtime SQL changes, use **`dev-reset`** — `dev-run` does not redeploy System / PE Global objects.
4. The consumer script **must not** reimplement EAC database drop, EAC/platform schema apply, bootstrap, or EAC configuration import, and must not keep a private copy of EAC SQL configuration or current-state seeds.
5. `dev-run.ps1` must **not** invoke EAC reset, recreate databases, or re-import configuration. It launches only the consumer application.

## Secrets

- Script-oriented configuration (e.g. `MSSQL_SA_PASSWORD`) comes from a local **gitignored** `.env` at the repo root.  
- OIDC credentials (`AUTHENTICATION__CLIENTID` / `AUTHENTICATION__CLIENTSECRET`) use .NET **User Secrets** locally — not `.env` ([local-development-standard.md](../architecture/identity-and-authentication/local-development-standard.md), [application-model.md](application-model.md)).  
- Ship `.env.example` documenting required script variables (never real secrets).  
- No passwords hardcoded in scripts or docs.  
- No secrets committed.  
- Missing required variables must produce clear errors.  
- `dev-reset.ps1` may write local User Secrets derived from `.env` (e.g. `LocalSql:SaPassword`).  
- `dev-run.ps1` verifies required secrets read-only; it must not rewrite them.  

Apps with no script secrets today still keep `.env` / `.env.example` so the script model is uniform (example may state “no required variables”).

## Application vs Shared UI

| Concern | Application with SQL (e.g. EAC) | Shared UI Gallery |
| --- | --- | --- |
| Docker SQL | Required for `dev-reset` | Not used |
| Required `.env` vars | At least `MSSQL_SA_PASSWORD` | None required today |
| Schema / seed | `sql/current_model/` + `sql/seed/` sources → `generated/*.sql` single sqlcmd (EAC consumers: EAC reset runs first via subprocess on `dev-reset` only) | N/A |
| EF migrations | Apply on recreate as configured | N/A |
| Launch target | Product web project | `BreezeOn.UI.Gallery` |
| `dev-run.ps1` | App-only launch; assume SQL/EAC already up | Gallery-only launch |

Same **script names and UX**; inapplicable steps are no-ops or clearly skipped.

## README requirements

Each product `README.md` must include a **Local Development** section covering:

- Prerequisites (.NET SDK, Docker Desktop when required, local `.env`)  
- Morning / fresh: `.\scripts\dev-reset.ps1` (what it does; destructive when applicable)  
- Day-to-day: `.\scripts\dev-run.ps1` (non-destructive application-only launch)  
- Required `.env` variables and User Secrets  
- Expected outcome (URLs, DB name if any)  
- Common troubleshooting  

Do **not** document invent-your-own startup scripts (`dev-up` / `dev-down` / one-off `start.ps1`). Document only the two standard entry points.

## Maintenance standard

**Whenever local development requirements change, `dev-reset.ps1` and `dev-run.ps1` must be updated in the same change set** (reset for environment preparation; run for launch prerequisites and launch path).

Examples:

- New Docker dependency  
- New database  
- New migration workflow  
- New environment variables / User Secrets  
- New local prerequisite  

`dev-reset.ps1` remains the authoritative **destructive** recreate process. `dev-run.ps1` remains the authoritative **non-destructive** day-to-day launch.

## AI agent standard

When creating or modifying a BreezeOn application:

1. Ship both `dev-reset.ps1` and `dev-run.ps1` (required layout).  
2. Do not invent a custom developer startup workflow (`dev-up` / `dev-down` / one-off start scripts).  
3. Keep README / `README_AI.md` instructions aligned with both scripts.  
4. Keep both scripts updated as development requirements evolve.  
5. For autonomous local verification: prefer `.\scripts\dev-run.ps1` when the environment already exists; use `.\scripts\dev-reset.ps1` only when a destructive recreate is intended.  

Product `README_AI.md` must tell agents which script to use for routine vs fresh-environment verification.

## Recommendations for future applications

1. Copy an existing host’s `scripts/dev-reset.ps1` + `scripts/dev-run.ps1` + `dev-common.ps1` pattern; strip or add SQL/Docker steps as needed.  
2. Add `.env.example` on day one, even if empty of required secrets.  
3. Wire Local Development in `README.md` and Autonomous local test in `README_AI.md` before the first PR that expects humans/agents to run the app.  
4. Do not reintroduce `dev-up` / `dev-down` or one-off “start.ps1” / “run-local.ps1” entry points — use the two required names only.  
5. Keep lower-level helpers internal; never promote them as the human/agent entry point.

## Current reality

Implemented for:

- [`breezeon-corp-fin-inv`](https://github.com/Breeze-On/breezeon-corp-fin-inv) — `scripts/dev-reset.ps1` + `scripts/dev-run.ps1` (EAC-consuming product; first host with both)  
- [`breezeon-system-admin-eac`](https://github.com/Breeze-On/breezeon-system-admin-eac) — `scripts/dev-reset.ps1` + `scripts/dev-run.ps1` (+ SQL helpers; platform reset owner)  
- [`breezeon-system-shared-ui`](https://github.com/Breeze-On/breezeon-system-shared-ui) — `scripts/dev-reset.ps1` (Gallery; no SQL); **`dev-run.ps1` pending adoption**  

Future BreezeOn applications must ship **both** scripts when they add a runnable local host ([application-development-process.md](ai/application-development-process.md) New App Development checklist).
