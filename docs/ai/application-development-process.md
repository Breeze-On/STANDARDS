<!-- Classification: AA; Scope: platform; Domain: Engineering; Capability: AiOnboarding -->
# BreezeOn application-development process

Owner: Documentation

Workflow for creating a new BreezeOn **product application**. This is distinct from **customer-environment onboarding** ([Master Flow](../../runbooks/customer-onboarding-master-flow.md)).

Detail for host wiring, UI, auth, and local SQL lives in the linked standards — this file defines the process order and explains the application-definition schema.

Related: [application-bootstrap-checklist.md](../application-bootstrap-checklist.md) (**authoritative New Application Checklist**) · [application-definition.schema.json](application-definition.schema.json) · [BREEZEON-AI-APPLICATION-ADOPTION.md](BREEZEON-AI-APPLICATION-ADOPTION.md) · [application-model.md](../application-model.md) · [page-development.md](../ui/page-development.md) · [application-branding.md](../ui/shell/application-branding.md) · [application-theme-palette.md](../ui/foundations/application-theme-palette.md) · [local-development-scripts.md](../local-development-scripts.md) · [planning-and-development-agents.md](planning-and-development-agents.md)

**Process narrative SSOT:** this file (`STANDARDS/docs/ai/application-development-process.md`).

**Step 1 input authority:** [application-definition.schema.json](application-definition.schema.json) is authoritative for required inputs, optional inputs, default values, and omission behavior. This markdown is the human-readable explanation. If schema and markdown conflict, **the schema wins**. Markdown must never introduce inputs, defaults, or behaviors absent from the schema.

**UI / composition authority:** New applications are designed from **STANDARDS first** (`docs/ui/`, Product Host Contract), then implemented by **reusing SHARED-UI** `Bo*` components and services. Gallery pages are **illustrative examples only** — useful after SSOT confirmation; they do **not** define standards. If Gallery and STANDARDS disagree, **STANDARDS win** and Gallery must be fixed ([example-governance.md](../ui/example-governance.md)).

---

## Required and optional application inputs

**Agents:** consume [application-definition.schema.json](application-definition.schema.json) **first**. Use the tables below as supporting explanation only.

### Required

| Input | Rule |
| --- | --- |
| Repository Name | GitHub repository name; technical identifier (case as created) |
| UniqueCode | `repositoryName.ToUpperInvariant()` for EAC registry storage — must not diverge from the repository name ([naming.md](../naming.md)) |
| Code | Short business identifier |
| Hosted App Registration Name | Shared customer-environment / BreezeOn-operated registration for hosted hosts (no platform default) |
| Local App Registration Name | Always `BreezeOn-LOCAL` for local development (fixed) |
| Pages | Initial IA (schema default: Home + New Request + Status Report + My Tasks unless overridden) |
| Application Display Name | Human-readable product name — [application-branding.md](../ui/shell/application-branding.md) |

Do not invent alternate technical ids that diverge from the repository name ([naming.md](../naming.md)).

### Optional

| Input | Default when omitted | Package |
| --- | --- | --- |
| Application Logo | `app-logo.svg` (platform/default or product asset) | Application Branding (sole member) |
| Customer Name | `BreezeOn` | Customer Branding |
| Customer Logo | `customer-logo.svg` → generates `nav-logo.svg` + `favicon.svg` | Customer Branding |
| Primary / Secondary / Tertiary Color | All omitted → complete platform-default Light/Dark palettes; if any supplied, all three required (`#RRGGBB`) | Customer Branding |

When optional inputs are omitted (schema `x-breezeon.omissionBehavior`):

- Standard default pages and **standard subtitles** are used ([application-branding.md](../ui/shell/application-branding.md))
- Customer Name defaults to **`BreezeOn`**; expanded nav shows Customer Logo + Customer Name; minimized nav shows Customer Logo only
- Customer Logo defaults to **`customer-logo.svg`**; placement assets `nav-logo.svg` and `favicon.svg` are **generated** from that source (never separate Step 1 inputs)
- Brand colors omitted → complete platform-default Light and Dark palettes; derived roles (hover, pressed, selected, borders, foregrounds, dark/accessibility variants) are implementation outputs only and are never application-definition fields
- Application Branding is **`app-logo.svg` only**; Application Display Name remains a required application-definition field outside both branding packages
- Browser title uses `<Page Title> - <Application Display Name>`

---

## New Application Checklist (authoritative bootstrap artifact)

**SSOT:** [application-bootstrap-checklist.md](../application-bootstrap-checklist.md).

Use this checklist as the **first** validation artifact when creating a new BreezeOn application (planning, Build Locally, and Platform bootstrap completion). It consolidates mandatory application-level requirements; linked SSOTs remain authoritative for detail.

### Checklist governance (mandatory)

Whenever a new or changed standard introduces a **mandatory application-level** requirement for new apps, the author **must** evaluate whether it belongs on the New Application Checklist. If yes, update [application-bootstrap-checklist.md](../application-bootstrap-checklist.md) in the **same change set**. Standards changes that add such requirements are incomplete until that checklist review occurs. Also update **Platform bootstrap completion** below when gate categories change.

---

## Default UX rules (all new apps)

Unless a plan explicitly overrides (encoded in schema defaults / omission behavior; detail in branding SSOT). Checklist rows: [application-bootstrap-checklist.md](../application-bootstrap-checklist.md).

| Rule | Standard |
| --- | --- |
| Home subtitle | **None** (omit header subtitle on Home) |
| Default pages | New Request, Status Report, My Tasks (+ Home) |
| Default page icons | New Request → `AddSquareMultiple`; Status Report → `Dashboard`; My Tasks → `AppsListDetail` (all `BoIcon` Regular / outlined) — [application-branding.md](../ui/shell/application-branding.md) |
| Default subtitles | Reusable platform copy in [application-branding.md](../ui/shell/application-branding.md) |
| Home card description | **Equals** the destination page subtitle (same string / resource key) |
| Browser title | `<Page Title> - <Application Display Name>` via `BoDocumentTitle` |
| Customer Logo assets | Source `customer-logo.svg`; generated `nav-logo.svg` + `favicon.svg` — rename customer uploads to the source name |
| Application Logo | `app-logo.svg` — Application Branding package only |
| Themes | Light and Dark both mandatory; not Step 1–configurable; only `primaryColor` / `secondaryColor` / `tertiaryColor` may be persisted as theme inputs |
| Branding packages | Customer Branding (`customerName`, `customerLogo`, three colors) decoupled from Application Branding (`applicationLogo` only); `applicationDisplayName` outside both |
| Platform display name | **`Breeze On`** for org/Gallery chrome (distinct from Customer Name default `BreezeOn`) |
| Process Request section | **Mandatory baseline** on New Request (and later process Detail/Edit): first tab **General Information**, first section **Process Request** (Initiator + Requested Date) — [process-request-section.md](../ui/patterns/process-request-section.md). Implementation is **application-owned** (no SHARED-UI package). |
| Initiation experience | **Default**: header General Information Form (outlined) icon; shell footer Save (`BoButtonVariant.Save` Filled icon) + Submit Primary via `BoPageFooterActions`; no top Actions Save\|Discard — [initiation-experience.md](../ui/patterns/initiation-experience.md) · [page-footer-actions.md](../ui/patterns/page-footer-actions.md) |
| People display | **Default** `DisplayName (Email)` in person controls; GUID last-resort only — [forms.md](../ui/controls/forms.md) |
| Process table | **Mandatory** primary table `{UniqueCode}.Process` with `ProcessId`, `ProcessGUID`, flat fields, and audit columns — [database.md](../database.md) § Process table convention |

---

## Process steps

### Step 1 — Application definition

1. Load [application-definition.schema.json](application-definition.schema.json) for required / optional / defaults / omission behavior.
2. Fill an instance from the user prompt; apply schema defaults for omitted optionals; derive `uniqueCode` from `repositoryName` via `ToUpperInvariant` when not supplied.
3. Ask only for missing **non-defaulted required** fields (`repositoryName`, `uniqueCode`, `code`, `hostedAppRegistrationName`, `applicationDisplayName`).
4. Do not require the user to read this markdown to discover inputs.

Capture the completed instance before planning or coding.

### Step 2 — Implementation planning

Generate a **local-development** roadmap from the inputs and existing standards ([planning-and-development-agents.md](planning-and-development-agents.md)). Anchor validation against [application-bootstrap-checklist.md](../application-bootstrap-checklist.md).

Default plan scope stops when the application can be **built and run locally** and **Platform bootstrap completion** (Step 5) passes, unless the current prompt expands scope.

Include UX Standards Compliance covering Home subtitle omission, card description = page subtitle, Customer vs Application Branding packages, and three-color theme derivation.

Plans may be authored under STANDARDS or another planning workspace while the target application repository does not yet exist. Planning does **not** continue as the implementation workspace after Step 3.

### Step 3 — Repository transition (mandatory checkpoint)

**Transition checkpoint:** immediately after the implementation roadmap is **approved**, and **before** local development (**Build Locally**) begins.

Once the roadmap is approved:

1. Create the target application repository if it does not already exist (implementation agent; not a manual prerequisite).
2. Move the **implementation conversation / agent workspace** to the **target application repository**.
3. Place or continue the active roadmap under that repository’s `docs/plans/in-progress/` when further plan deltas are needed.
4. Perform all subsequent local-development execution from the application repository context.

**Ownership after transition**

| Concern | Owner |
| --- | --- |
| Process authority (this document + linked standards) | **STANDARDS** |
| Step 1 input contract | **[application-definition.schema.json](application-definition.schema.json)** |
| Platform host reference | **SYSTEM-ADMIN-EAC** (EAC) |
| Execution workspace (code, local reset, Build Locally) | **Target application repository** |

**Do not** continue application implementation inside STANDARDS or EAC planning conversations after repository ownership is established. Future applications must follow the same transition pattern unless explicitly overridden.

**Validation for Step 3**

- Target repository exists
- Repository ownership for implementation is established
- Implementation context is transferred to that repository
- Further development is expected from the application repository

After Step 3 succeeds, the next expected command is **Build Locally**.

### Step 4 — Local development implementation

The implementation agent, working **in the application repository**, implements the product host so a developer can:

1. Clone the repository (sibling `SYSTEM-SHARED-UI` for interim `ProjectReference`)
2. Run `.\scripts\dev-reset.ps1` (fresh environment / first-time startup)
3. Configure User Secrets for the **Local App Registration** (`AUTHENTICATION__*`)
4. Run `.\scripts\dev-run.ps1` for day-to-day relaunch (non-destructive application-only)
5. Sign in
6. Navigate the defined pages

Mandatory host contract: [page-development.md](../ui/page-development.md) § Product Host Contract. Branding: [application-branding.md](../ui/shell/application-branding.md). Reference host: `SYSTEM-ADMIN-EAC`. Shared UI: `BreezeOn.UI`. Local entry: [local-development-scripts.md](../local-development-scripts.md) (`dev-reset.ps1` + `dev-run.ps1` required).

Do not fork Identity/Security schemas.

**Mandatory business baseline (all new apps)** — in addition to the IA shell. Full rows: [application-bootstrap-checklist.md](../application-bootstrap-checklist.md).

- [ ] **Process Request** section on New Request: tab **General Information** (first), section **Process Request** (first), Row 1 Initiator + Requested Date per [process-request-section.md](../ui/patterns/process-request-section.md) (application-owned implementation); initiation footer Save+Submit per [initiation-experience.md](../ui/patterns/initiation-experience.md).
- [ ] Primary process table `{UniqueCode}.Process` under product `sql/current_model/` with `ProcessId`, `ProcessGUID`, baseline flat fields, and audit columns — [database.md](../database.md) § Process table convention; `docs/db-model.md` in the same change set.
- [ ] Consumer `dev-reset.ps1` applies the app’s own `sql/current_model/` (and `sql/seed/` when present) **after** the EAC subprocess.

**New App Development checklist (EAC-consuming apps)** — all items required:

- [ ] Sibling **`SYSTEM-ADMIN-EAC`** checkout is required locally (same parent folder as the app repo); `scripts/dev-reset.ps1` fails fast with a clear error when it is missing.
- [ ] `scripts/dev-reset.ps1` **invokes EAC `scripts\dev-reset.ps1` as a subprocess** (EAC owns database drop/recreate, **allowlisted** System + platform schema, required-object smoke, bootstrap, and EAC configuration import), then applies the app's own business schema/seed if any, then launches the app. It does **not** reimplement EAC reset/bootstrap/import ([local-development-scripts.md](../local-development-scripts.md) § Consumer apps and EAC reset). Platform objects come only from EAC reset after allowlisted deploy — not from app `sql/seed/` or `seed/eac/` ([database.md](../database.md) § EAC Framework Synchronization).
- [ ] `scripts/dev-run.ps1` is present: non-destructive application-only launch; verifies required User Secrets / local SQL configuration as appropriate; does **not** invoke EAC reset, recreate databases, reset Docker, or re-import configuration ([local-development-scripts.md](../local-development-scripts.md)).
- [ ] The app repo has a top-level **`seed/eac/`** folder (scaffold creates the folder only — **no** `seed/eac/README.md`) holding the app's portable EAC configuration (JSON / xlsx) that EAC discovers and imports ([data-portability.md](../data-portability.md) § Per-application `seed/eac`).
- [ ] No `System.EAC*` SQL configuration or current-state seeds in the app repo (`sql/seed/` is app business / non-EAC data only — [database.md](../database.md) § `seed/eac/`); no EAC registry seed for the app under `SYSTEM-ADMIN-EAC/sql/seed/`.
- [ ] Shared local SQL instance (`breezeon-sql-local` / `BreezeOnLocal`) is used — [local-database.md](../local-database.md).
- [ ] Product `README.md` / `README_AI.md` document the sibling EAC prerequisite, `seed/eac/`, and both local scripts (morning `dev-reset.ps1` / day-to-day `dev-run.ps1`).

### Step 5 — Local validation

Verify locally:

- Build (and repo tests if present)
- Authentication against the Local App Registration
- Authorization (page catalog + shared Security)
- Navigation (Home cards + destination routes; card descriptions match page subtitles; Home has no subtitle)
- Branding bindings (Application Logo independent; Customer Logo source generates nav + favicon; expanded nav shows Customer Name; browser title format)
- Local bootstrap (including `GLOBAL-SYSTEM-ADMINISTRATORS` when seed tids / bootstrap UPNs are configured)
- Seeding / reset for the product local database path documented in the product README (EAC consumers: EAC reset invoked via sibling checkout, `seed/eac/` imported)

Agents stop at the Entra interactive boundary; humans complete authenticated smoke ([ai-agent-governance.md](ai-agent-governance.md)).

**Platform bootstrap completion** (mandatory gate)

This gate is **new-app platform foundation readiness** — distinct from **Application Context Bootstrap** (one Must-consume capability verified inside the gate).

Default Step 2 / Step 4 scope ends when the host can be **built and run locally** **and** this gate passes. **Business feature development must not begin** until the gate passes. Step 6 (hosted) remains separate and authorization-gated.

Platform foundation is complete only when **all** of the following are true (detail stays in the linked SSOTs — do not restate full tables here):

| # | Category | Authority |
| --- | --- | --- |
| 0 | **New Application Checklist** — all applicable rows complete | [application-bootstrap-checklist.md](../application-bootstrap-checklist.md) |
| 1 | **Product Host Contract** satisfied | [page-development.md](../ui/page-development.md) § Product Host Contract |
| 2 | **Platform consumption** — every row in Must consume | [application-model.md](../application-model.md) § Must consume (SHARED-UI, auth, AuthZ, page catalog, Identity/Security schemas, Application Context Bootstrap, registry expectation) |
| 3 | **Local host contract** — New App Development checklist complete | Step 4 checklist above ([local-development-scripts.md](../local-development-scripts.md), `seed/eac/`, shared local SQL, product README facts) |
| 4 | **Local validation** — Step 5 smoke list passed | This step (agents stop at Entra interactive boundary) |
| 5 | **Repo baselines** — thin `README` / `README_AI` / `AGENTS`, Dependabot from templates, deploy workflow metadata present | [BREEZEON-AI-APPLICATION-ADOPTION.md](BREEZEON-AI-APPLICATION-ADOPTION.md) Must; procedures stay in [hosted-deployment.md](../hosted-deployment.md) (Step 6 execution still separate) |
| 6 | **IA shell** — Home + defined destination routes exist as standards-compliant shell pages | [application-branding.md](../ui/shell/application-branding.md) |
| 7 | **Process Request baseline** — General Information / Process Request section + `{UniqueCode}.Process` table present when the app creates process instances (mandatory for new apps per Default UX rules) | [process-request-section.md](../ui/patterns/process-request-section.md) · [database.md](../database.md) § Process table convention |

**Future Validation** items stay **out** of this gate until they are promoted into Must consume or other mandatory new-app rules.

### Step 6 — Manual and deployment activities (separate request)

Hosted App Registration validation for the new host, App Service provisioning, redirect URIs, Managed Identity grants, Deploy DEV, and hosted promote are **out of the default Build Locally path**.

Perform Step 6 only when the current prompt explicitly requests it. Procedures: [hosted-deployment.md](../hosted-deployment.md), identity runbooks, [customer-onboarding-authentication.md](../../runbooks/customer-onboarding-authentication.md).

---

## Distinctions for agents

### Classification legend (example vs standard)

| Class | Meaning | Where it lives |
| --- | --- | --- |
| **Reusable BreezeOn standard** | Process order, schema inputs/defaults, linked platform AA | This process + [application-definition.schema.json](application-definition.schema.json) + linked standards |
| **Application-specific input/decision** | One product’s Step 1 instance values | That app’s AA / ENT; schema instance for that app |
| **Illustrative example** | Worked example only — **not** defaults | [examples/application-definition.inv.json](examples/application-definition.inv.json) + section below |

1. **Existing platform standards** — follow; do not restate or redesign (STANDARDS remains process authority)
2. **Application-specific inputs** — authoritative shape in [application-definition.schema.json](application-definition.schema.json); tables above explain
3. **Planning vs execution** — planning may start outside the app repo; after Step 3, execution is only in the application repository
4. **Local agent work** — Steps 4–5 in the application repository; business features only after **Platform bootstrap completion**
5. **Manual / hosted work** — Step 6, only when authorized in the current prompt
6. **Reusable process** — this document + schema; refine only when a new app validates a change. Classify newly approved decisions (`inv-specific` / `application-specific` / `shared-app-dev-standard` / `shared-platform-standard`) per [documentation.md](../documentation.md) § Application-development change classifier; **ask** when class is ambiguous
7. **Schema-first Step 1** — consume the schema first; markdown is supporting documentation only

### Auto-update (anti-drift)

When Step 1 inputs, defaults, or omission behavior change: update **schema first**, then sync this markdown in the **same change set**. Schema wins on conflict. Markdown must not invent inputs/defaults/behaviors absent from the schema.

When a capability becomes **mandatory for new BreezeOn applications**, update **Platform bootstrap completion** (Step 5) **and** evaluate [application-bootstrap-checklist.md](../application-bootstrap-checklist.md) in the **same change set** as the owning AA — typically [application-model.md](../application-model.md) § Must consume and/or [page-development.md](../ui/page-development.md) § Product Host Contract. Detail remains in those SSOTs; the checklist and this gate list categories and links only. **Future Validation** stays out of the gate until promoted. Standards changes that add mandatory new-app requirements are incomplete until the checklist review occurs.

---

## Worked example: INV (illustrative instance)

**Agent banner:** INV values are **not** platform defaults. Do **not** copy `BreezeOn-DEV`, display name, Code, repo ids, or other INV fields into new apps. Durable INV current reality: [`architecture/applications/inv.md`](../../architecture/applications/inv.md). Machine instance: [examples/application-definition.inv.json](examples/application-definition.inv.json).

| Input | Value (INV only) |
| --- | --- |
| Repository Name | `breezeon-corp-fin-inv` |
| UniqueCode | `BREEZEON-CORP-FIN-INV` |
| Code | `INV` |
| Hosted App Registration | `BreezeOn-DEV` |
| Local App Registration | `BreezeOn-LOCAL` |
| Pages | Home, New Request, Status Report, My Tasks |
| Default page icons | `AddSquareMultiple` / `Dashboard` / `AppsListDetail` (Regular) |
| Application Display Name | Invoice Approval Request |
| Customer Name | `BreezeOn` (omitted → schema default) |
| Application Logo / Customer Logo | `app-logo.svg` / `customer-logo.svg` (generates `nav-logo.svg` + `favicon.svg`) |
| Brand colors | Omitted → platform default Light/Dark palettes |

**Repository transition:** execution workspace is [`breezeon-corp-fin-inv`](https://github.com/Breeze-On/breezeon-corp-fin-inv). STANDARDS remains process SSOT; EAC remains the platform reference host.

INV's EAC configuration lives in the INV repo under `seed/eac/` and is imported by EAC's local reset. Active roadmap: application repo `docs/plans/in-progress/`.
