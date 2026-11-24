<!-- Classification: AA; Scope: platform; Domain: Engineering; Capability: AiOnboarding -->
# BreezeOn application-development process

Owner: Documentation

Workflow for creating a new BreezeOn **product application**. This is distinct from **customer-environment onboarding** ([Master Flow](../../runbooks/customer-onboarding-master-flow.md)).

Detail for host wiring, UI, auth, and local SQL lives in the linked standards — this file defines the process order and explains the application-definition schema.

Related: [application-definition.schema.json](application-definition.schema.json) · [BREEZEON-AI-APPLICATION-ADOPTION.md](BREEZEON-AI-APPLICATION-ADOPTION.md) · [application-model.md](../application-model.md) · [page-development.md](../ui/page-development.md) · [application-branding.md](../ui/shell/application-branding.md) · [application-theme-palette.md](../ui/foundations/application-theme-palette.md) · [local-development-scripts.md](../local-development-scripts.md) · [planning-and-development-agents.md](planning-and-development-agents.md)

**Process narrative SSOT:** this file (`STANDARDS/docs/ai/application-development-process.md`).

**Step 1 input authority:** [application-definition.schema.json](application-definition.schema.json) is authoritative for required inputs, optional inputs, default values, and omission behavior. This markdown is the human-readable explanation. If schema and markdown conflict, **the schema wins**. Markdown must never introduce inputs, defaults, or behaviors absent from the schema.

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

| Input | Default when omitted |
| --- | --- |
| Application Logo | `app-logo.svg` (platform/default or product asset); independently configurable from Navigation Logo |
| Navigation Logo | `nav-logo.svg`; independently configurable from Application Logo |
| Theme Palette | Platform default Light/Dark accents — [application-theme-palette.md](../ui/foundations/application-theme-palette.md) |

When optional inputs are omitted (schema `x-breezeon.omissionBehavior`):

- Standard default pages and **standard subtitles** are used ([application-branding.md](../ui/shell/application-branding.md))
- Standard Theme Palette (platform defaults) is used
- Branding assets use locked filenames **`app-logo.svg`**, **`nav-logo.svg`**, **`favicon.svg`** (user/designer filenames are never retained)
- Application Logo, Navigation Logo, and Browser Favicon **may** initially share visuals while remaining **independently** configured, referenced, and bound
- Browser title uses `<Page Title> - <Application Display Name>`

---

## Default UX rules (all new apps)

Unless a plan explicitly overrides (encoded in schema defaults / omission behavior; detail in branding SSOT):

| Rule | Standard |
| --- | --- |
| Home subtitle | **None** (omit header subtitle on Home) |
| Default pages | New Request, Status Report, My Tasks (+ Home) |
| Default page icons | New Request → `AddSquareMultiple`; Status Report → `Dashboard`; My Tasks → `AppsListDetail` (all `BoIcon` Regular / outlined) — [application-branding.md](../ui/shell/application-branding.md) |
| Default subtitles | Reusable platform copy in [application-branding.md](../ui/shell/application-branding.md) |
| Home card description | **Equals** the destination page subtitle (same string / resource key) |
| Browser title | `<Page Title> - <Application Display Name>` via `BoDocumentTitle` |
| Browser Favicon | `favicon.svg` (aligns with Navigation Logo branding by default; separate asset) |
| Branding asset names | `app-logo.svg` / `nav-logo.svg` / `favicon.svg` — rename uploads on import |
| Themes | Light and Dark both mandatory (Theme Palette first-class) |
| Branding split | Application Branding (Display Name + Application Logo) decoupled from Customer/Tenant Branding (Navigation Logo + Favicon) |
| Platform display name | **`Breeze On`** for org/Gallery chrome |

---

## Process steps

### Step 1 — Application definition

1. Load [application-definition.schema.json](application-definition.schema.json) for required / optional / defaults / omission behavior.
2. Fill an instance from the user prompt; apply schema defaults for omitted optionals; derive `uniqueCode` from `repositoryName` via `ToUpperInvariant` when not supplied.
3. Ask only for missing **non-defaulted required** fields (`repositoryName`, `uniqueCode`, `code`, `hostedAppRegistrationName`, `applicationDisplayName`).
4. Do not require the user to read this markdown to discover inputs.

Capture the completed instance before planning or coding.

### Step 2 — Implementation planning

Generate a **local-development** roadmap from the inputs and existing standards ([planning-and-development-agents.md](planning-and-development-agents.md)).

Default plan scope stops when the application can be **built and run locally**, unless the current prompt expands scope.

Include UX Standards Compliance covering Home subtitle omission, card description = page subtitle, branding split, and Theme Palette.

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

**New App Development checklist (EAC-consuming apps)** — all items required:

- [ ] Sibling **`SYSTEM-ADMIN-EAC`** checkout is required locally (same parent folder as the app repo); `scripts/dev-reset.ps1` fails fast with a clear error when it is missing.
- [ ] `scripts/dev-reset.ps1` **invokes EAC `scripts\dev-reset.ps1` as a subprocess** (EAC owns database drop/recreate, schema, bootstrap, and EAC configuration import), then applies the app's own business schema/seed if any, then launches the app. It does **not** reimplement EAC reset/bootstrap/import ([local-development-scripts.md](../local-development-scripts.md) § Consumer apps and EAC reset).
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
- Branding bindings (Application Logo vs Navigation Logo independently configured; favicon tracks Navigation Logo; browser title format)
- Local bootstrap (including `GLOBAL-SYSTEM-ADMINISTRATORS` when seed tids / bootstrap UPNs are configured)
- Seeding / reset for the product local database path documented in the product README (EAC consumers: EAC reset invoked via sibling checkout, `seed/eac/` imported)

Agents stop at the Entra interactive boundary; humans complete authenticated smoke ([ai-agent-governance.md](ai-agent-governance.md)).

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
4. **Local agent work** — Steps 4–5 in the application repository
5. **Manual / hosted work** — Step 6, only when authorized in the current prompt
6. **Reusable process** — this document + schema; refine only when a new app validates a change. Classify newly approved decisions (`inv-specific` / `application-specific` / `shared-app-dev-standard` / `shared-platform-standard`) per [documentation.md](../documentation.md) § Application-development change classifier; **ask** when class is ambiguous
7. **Schema-first Step 1** — consume the schema first; markdown is supporting documentation only

### Auto-update (anti-drift)

When Step 1 inputs, defaults, or omission behavior change: update **schema first**, then sync this markdown in the **same change set**. Schema wins on conflict. Markdown must not invent inputs/defaults/behaviors absent from the schema.

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
| Application Logo / Navigation Logo | Independently configurable (may share image file initially) |
| Theme Palette | Platform defaults until product-specific palette is supplied |

**Repository transition:** execution workspace is [`breezeon-corp-fin-inv`](https://github.com/Breeze-On/breezeon-corp-fin-inv). STANDARDS remains process SSOT; EAC remains the platform reference host.

INV's EAC configuration lives in the INV repo under `seed/eac/` and is imported by EAC's local reset. Active roadmap: application repo `docs/plans/in-progress/`.
