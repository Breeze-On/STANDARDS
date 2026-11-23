<!-- Classification: AA; Scope: platform; Domain: Engineering; Capability: AiOnboarding -->
# BreezeOn application-development process

Owner: Documentation

Workflow for creating a new BreezeOn **product application**. This is distinct from **customer-environment onboarding** ([Master Flow](../../runbooks/customer-onboarding-master-flow.md)).

Detail for host wiring, UI, auth, and local SQL lives in the linked standards — this file only defines the process order and required inputs.

Related: [BREEZEON-AI-APPLICATION-ADOPTION.md](BREEZEON-AI-APPLICATION-ADOPTION.md) · [application-model.md](../application-model.md) · [page-development.md](../ui/page-development.md) · [application-branding.md](../ui/shell/application-branding.md) · [application-theme-palette.md](../ui/foundations/application-theme-palette.md) · [local-development-scripts.md](../local-development-scripts.md) · [planning-and-development-agents.md](planning-and-development-agents.md)

**Process SSOT location:** this file (`STANDARDS/docs/ai/application-development-process.md`).

---

## Required and optional application inputs

### Required

| Input | Rule |
| --- | --- |
| Repository Name | GitHub repository name; technical identifier |
| UniqueCode | Matches repository name (EAC registry stores uppercased form) |
| Code | Short business identifier |
| Hosted App Registration Name | Shared customer-environment / BreezeOn-operated registration for hosted hosts |
| Local App Registration Name | Always `BreezeOn-LOCAL` for local development |
| Pages | Initial IA (default: Home + New Request + Status Report + My Tasks unless overridden) |
| Application Display Name | Human-readable product name — [application-branding.md](../ui/shell/application-branding.md) |

Do not invent alternate technical ids that diverge from the repository name ([naming.md](../naming.md)).

### Optional

| Input | Default when omitted |
| --- | --- |
| Application Logo | `app-logo.svg` (platform/default or product asset); independently configurable from Navigation Logo |
| Navigation Logo | `nav-logo.svg`; independently configurable from Application Logo |
| Theme Palette | Platform default Light/Dark accents — [application-theme-palette.md](../ui/foundations/application-theme-palette.md) |

When optional inputs are omitted:

- Standard default pages and **standard subtitles** are used ([application-branding.md](../ui/shell/application-branding.md))
- Standard Theme Palette (platform defaults) is used
- Branding assets use locked filenames **`app-logo.svg`**, **`nav-logo.svg`**, **`favicon.svg`** (user/designer filenames are never retained)
- Application Logo, Navigation Logo, and Browser Favicon **may** initially share visuals while remaining **independently** configured, referenced, and bound
- Browser title uses `<Page Title> - <Application Display Name>`

---

## Default UX rules (all new apps)

Unless a plan explicitly overrides:

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

Capture required inputs (and any optional branding/theme inputs) before planning or coding.

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
2. Run `.\scripts\dev-reset.ps1`
3. Configure User Secrets for the **Local App Registration** (`AUTHENTICATION__*`)
4. Launch the application
5. Sign in
6. Navigate the defined pages

Mandatory host contract: [page-development.md](../ui/page-development.md) § Product Host Contract. Branding: [application-branding.md](../ui/shell/application-branding.md). Reference host: `SYSTEM-ADMIN-EAC`. Shared UI: `BreezeOn.UI`. Local entry: [local-development-scripts.md](../local-development-scripts.md) (`dev-reset.ps1` only).

EAC `System` registry seed for applications that already appear in EAC sample seed remains under EAC ownership — do not fork Identity/Security schemas.

### Step 5 — Local validation

Verify locally:

- Build (and repo tests if present)
- Authentication against the Local App Registration
- Authorization (page catalog + shared Security)
- Navigation (Home cards + destination routes; card descriptions match page subtitles; Home has no subtitle)
- Branding bindings (Application Logo vs Navigation Logo independently configured; favicon tracks Navigation Logo; browser title format)
- Local bootstrap (including `GLOBAL-SYSTEM-ADMINISTRATORS` when seed tids / bootstrap UPNs are configured)
- Seeding / reset for the product local database path documented in the product README

Agents stop at the Entra interactive boundary; humans complete authenticated smoke ([ai-agent-governance.md](ai-agent-governance.md)).

### Step 6 — Manual and deployment activities (separate request)

Hosted App Registration validation for the new host, App Service provisioning, redirect URIs, Managed Identity grants, Deploy DEV, and hosted promote are **out of the default Build Locally path**.

Perform Step 6 only when the current prompt explicitly requests it. Procedures: [hosted-deployment.md](../hosted-deployment.md), identity runbooks, [customer-onboarding-authentication.md](../../runbooks/customer-onboarding-authentication.md).

---

## Distinctions for agents

1. **Existing platform standards** — follow; do not restate or redesign (STANDARDS remains process authority)
2. **Application-specific inputs** — required + optional tables above
3. **Planning vs execution** — planning may start outside the app repo; after Step 3, execution is only in the application repository
4. **Local agent work** — Steps 4–5 in the application repository
5. **Manual / hosted work** — Step 6, only when authorized in the current prompt
6. **Reusable process** — this document; refine only when a new app validates a change

---

## First validated application (App #1)

| Input | Value |
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

EAC sample seed for INV remains **unchanged** in `SYSTEM-ADMIN-EAC`. Active roadmap: application repo `docs/plans/in-progress/`.
