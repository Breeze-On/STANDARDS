<!-- Classification: AA; Scope: platform; Domain: Engineering; Capability: ApplicationModel -->
# Application model

Owner: Engineering

Defines what constitutes a **standard Breeze On application** based on patterns already implemented in the ecosystem (primarily EAC). Shared libraries (e.g. `BreezeOn.UI`) follow related documentation and boundary rules but are not full applications.

### Product application vs customer-environment onboarding

| Concern | Meaning | SSOT |
| --- | --- | --- |
| **Product application onboarding** | Creating the next product application (**App #N**) | [`application-development-process.md`](ai/application-development-process.md) · [`application-definition.schema.json`](ai/application-definition.schema.json) · [`BREEZEON-AI-APPLICATION-ADOPTION.md`](ai/BREEZEON-AI-APPLICATION-ADOPTION.md) |
| **Customer-environment onboarding** | Provisioning / activating a customer DEV/UAT/PRD environment | [`runbooks/customer-onboarding-master-flow.md`](../runbooks/customer-onboarding-master-flow.md) |

The Customer Onboarding Master Flow does **not** create new BreezeOn application repositories.

## What exists today

| Kind | Example repository | Notes |
| --- | --- | --- |
| Application | [SYSTEM-ADMIN-EAC](https://github.com/Breeze-On/SYSTEM-ADMIN-EAC) | Blazor Web App, SQL ownership, DEV hosting, `scripts/dev-*.ps1` |
| Shared library | [SYSTEM-SHARED-UI](https://github.com/Breeze-On/SYSTEM-SHARED-UI) | RCL + gallery; design system + auth/authZ framework + Identity/Security SQL definitions; no business DB |
| Org standards | [STANDARDS](https://github.com/Breeze-On/STANDARDS) | Not an application |

## Dedicated repository ownership

- One **GitHub repository** per application or shared concern ([ADR-001](../decisions/ADR-001-multi-repository-model.md)).
- Application code uses the `BreezeOn.*` namespace and `src/<Project>` layout (e.g. `src/BreezeOn.Eac`).
- The **repository name** is the application technical identifier; EAC registry `UniqueCode` is `repositoryName.ToUpperInvariant()` ([application-definition.schema.json](ai/application-definition.schema.json)); short `Code` and `ApplicationGUID` conventions: [naming.md](naming.md), [database.md](database.md).
- Do not add unrelated products or business domains into an existing application repository.

## Platform consumption requirements

**`BreezeOn.UI` (SYSTEM-SHARED-UI) is mandatory** for every BreezeOn application. Adoption is **not** optional. This includes the shell, `Bo*` components, platform authentication, platform authorization, and the page catalog / page-security model.

### Must consume

| Capability | Requirement | SSOT |
| --- | --- | --- |
| **Product Host Contract** | Full host wiring once per app: UI + auth + AuthZ + page catalog + Data Protection + Error Message options + localization/resources — [page-development.md § Product Host Contract](ui/page-development.md#product-host-contract-required) (Gallery = chrome/assets; EAC = complete product host) | [ui/page-development.md](ui/page-development.md), [ui/overview.md](ui/overview.md) |
| **`BoAppShell` + `Bo*` UI** | Product pages use the public Shared UI API only — no Fluent UI types in product pages | [public-component-api.md](https://github.com/Breeze-On/SYSTEM-SHARED-UI/blob/main/docs/public-component-api.md), [ADR-004](../decisions/ADR-004-breezeon-ui-abstraction-layer.md) |
| **Authentication framework** | Entra OIDC + cookie auth via SHARED-UI; shared App Registration per customer-environment | [Identity & Authentication](../architecture/identity-and-authentication/README.md), [ADR-009](../decisions/ADR-009-entra-oidc-cookie-authentication.md) |
| **Authorization framework** | `IBoAuthorizationService`, Security Groups, convention-based mutation guards | [Authorization](../architecture/authorization/README.md), [ADR-014](../decisions/ADR-014-platform-authorization.md) |
| **Page catalog / page security** | Register every authenticated route; fail closed on miss; Code-based `RequiredGroupCodes` | [page-security-standard.md](../architecture/authorization/page-security-standard.md) |
| **Platform Identity + Security schemas** | Apply SHARED-UI definitions into the **one shared customer database** per customer-environment. **Identity remains shared. Security remains shared.** Applications must **not** create independent Identity catalogs or fork Security schemas. New customer-environment → [Master Flow](../runbooks/customer-onboarding-master-flow.md); new product app in an existing environment → consume the existing customer DB | [database.md](database.md), [ADR-010](../decisions/ADR-010-platform-identity-schema.md) |
| **Shared catalog registration** | Every BreezeOn application is **expected to be registered** in the EAC-owned `System` application registry (`UniqueCode` = `repositoryName.ToUpperInvariant()`). **Registration / discovery / deploy-order mechanics are Future Validation** for subsequent apps — do not invent workflows or runtime consumption patterns here | [database.md](database.md) § Shared System schema, [naming.md](naming.md), [application-definition.schema.json](ai/application-definition.schema.json) |

### Must not own

| Concern | Rule |
| --- | --- |
| Design-system implementation | Do not fork Fluent wrappers or parallel design tokens outside SHARED-UI |
| Independent OIDC / AspNet Identity | Do not redesign auth; do not revive `AspNet*` user stores |
| Parallel AuthZ evaluators for page/Code checks | Do not invent product-local replacements for `IBoAuthorizationService` page evaluation |
| Duplicate Identity / Security / application-catalog tables | One customer DB per customer-environment; no forked `Identity` / `Security` / application registry |
| Org-wide deploy procedures | Product repos hold metadata only; procedures live in [hosted-deployment.md](hosted-deployment.md) |

### Application-owned responsibilities

| Concern | Owns |
| --- | --- |
| Product UI pages and page catalog entries | Application repo |
| Business schema (`docs/db-model.md`, `sql/current_model/`, `sql/seed/`) when the app owns data | Application repo |
| Host wiring (DI, `AUTHENTICATION__*` / connection config, MI SqlClient registration) | Application repo |
| Local `scripts/dev-reset.ps1` + `scripts/dev-run.ps1` and product-specific sandbox | Application repo |
| Product deploy workflow + App Service metadata | Application repo |
| Object-admin / domain AuthZ beyond platform Codes (e.g. GroupGUID data checks) | Application / domain (EAC pattern) |

## Cross-repo consumption of SHARED-UI (interim contract)

**Current reality (interim):** product apps consume `BreezeOn.UI` via a **sibling repository checkout** and a **`ProjectReference`** to `SYSTEM-SHARED-UI` sources. CI typically checks out SHARED-UI at the **unpinned default branch HEAD**. There is **no** NuGet package versioning, pin policy, or compatibility contract yet.

This is the accepted interim multi-repo contract ([ADR-001](../decisions/ADR-001-multi-repository-model.md)). **Future Validation (triggered by application #2):** NuGet (or pinned ref), compatibility policy, and release versioning — do not invent those decisions now.

## Required documentation files

| File | Role |
| --- | --- |
| `README.md` | Humans — purpose, run/deploy as implemented, links to STANDARDS and org profile |
| `README_AI.md` | Agents — thin repo-specific context; references STANDARDS; update duties |
| `AGENTS.md` | Short pointer to STANDARDS and critical repo facts |

Product READMEs stay **thin**: link to STANDARDS for org-wide rules; do not duplicate vision (org profile) or full standards.

## STANDARDS references

Every application repository must:

1. Follow [Breeze-On/STANDARDS](https://github.com/Breeze-On/STANDARDS) (start at [`README_AI.md`](../README_AI.md)).
2. Keep product docs synchronized with implementation (**Current Reality Only**).
3. Update STANDARDS `architecture/` (and ADRs when required) when org-visible reality changes.

## Documentation requirements

- Document **implemented** behavior only ([documentation.md](documentation.md)).
- Same change set: code + affected product docs + STANDARDS/ADRs as applicable.
- Apps that own business schema: maintain `docs/db-model.md`, `sql/current_model/`, and `sql/seed/` together ([database.md](database.md)).

## Local development expectations

**Script standard (all runnable hosts):** every application and the Shared UI gallery must expose [`scripts/dev-reset.ps1`](local-development-scripts.md) (destructive fresh environment) and [`scripts/dev-run.ps1`](local-development-scripts.md) (non-destructive day-to-day launch). No `dev-up` / `dev-down` or invent-your-own start scripts.

**Secrets split:**

| Kind | Store |
| --- | --- |
| Script-oriented config (e.g. `MSSQL_SA_PASSWORD`) | Gitignored **`.env`** |
| OIDC credentials (`AUTHENTICATION__CLIENTID` / `AUTHENTICATION__CLIENTSECRET`) | .NET **User Secrets** (local) — not `.env` ([local-development-standard.md](../architecture/identity-and-authentication/local-development-standard.md)) |

Details: [local-development-scripts.md](local-development-scripts.md).

For applications with a database (EAC pattern):

- Default local engine: SQL Server Docker sandbox ([local-database.md](local-database.md)).
- Repo typically includes `docker-compose.yml`, `.env.example`, init/seed scripts, and README steps.
- Do not default Development to Azure SQL.
- Agents prefer `.\scripts\dev-run.ps1` for routine local verification; use `.\scripts\dev-reset.ps1` only when a destructive recreate is intended.

For the Shared UI gallery: same script names; no database — scripts build and launch `BreezeOn.UI.Gallery`.

## Deployment expectations

Org deploy standard (procedures, secrets, workflow conventions, App Service stack): **[hosted-deployment.md](hosted-deployment.md)**.

Product repositories must **not** become the source of truth for deployment procedures. They document only product-specific metadata (App Service name, resource group, URL, workflow path, sibling-checkout notes) and link to that standard.

As implemented today:

- Hosted **DEV** on Azure App Service (Linux, .NET 10) for EAC and the Shared UI Gallery; EAC also uses Azure SQL with Managed Identity.
- Manual `workflow_dispatch` via `.github/workflows/deploy-dev.yml` and GitHub Environment **`DEV`**.
- Environment naming and meaning: [environments.md](environments.md).
- **Data-owning apps (required):** with `SQLAzureConnection` + Managed Identity, the app **MUST** reference **`Microsoft.Data.SqlClient.Extensions.Azure`** and register `ActiveDirectoryAuthenticationProvider` before any SQL open (SqlClient 7+). See [hosted-deployment.md](hosted-deployment.md) § Hosted database connection step 5 and [architecture/security.md](../architecture/security.md).

`BreezeOn.UI` is consumed as a library per the interim sibling-checkout contract above; the Gallery host may be deployed separately for smoke/demo.

## Database ownership expectations

Applications that own business tables:

| Path | Role |
| --- | --- |
| `sql/current_model/` | Executable schema SSOT (T-SQL) — bootstrap / full reset only on populated DBs use migrations ([database.md](database.md)) |
| `docs/db-model.md` | Human-readable business model |
| `sql/seed/` | Local-only sample data (required; not default-applied to hosted Azure SQL) |

Platform **`Identity.*`** / **`Security.*`** tables are **not** ASP.NET Core Identity. Definitions are owned by SYSTEM-SHARED-UI; physical tables live in the **one customer database per customer-environment**, shared by all product applications in that environment (not a separate Identity catalog per app). Intended layout:

```text
Customer
└─ One customer database
    ├─ Identity schema
    ├─ Security schema
    ├─ System schema
    ├─ EAC data
    └─ Future application data
```

Identity and Security are shared across applications within that customer database. Product `db-model.md` should reference platform Identity/Security as applied from SHARED-UI. Do not revive `AspNet*` user stores. SSOT: [Identity & Authentication](../architecture/identity-and-authentication/README.md), [Authorization](../architecture/authorization/README.md), [ADR-010](../decisions/ADR-010-platform-identity-schema.md).

Shared **System** schema ownership (EAC catalog) and application identity columns: [database.md](database.md). Every app is expected to be **registered** in that catalog; mechanics remain Future Validation (see Platform consumption). Repository-as-technical-id: [naming.md](naming.md).

## Documentation update responsibilities

When behavior, setup, schema, or architecture changes:

1. Update implementation.
2. Update product `README` / `README_AI` / `AGENTS` as needed.
3. Update `db-model` / `current_model` / `seed` together when schema changes.
4. Update STANDARDS (`docs/`, `architecture/`, `decisions/`) when the change is org-wide or architectural.
5. Treat documentation (including ADRs) as part of **Definition of Done**.

## Repository boundaries

| Repository | Owns |
| --- | --- |
| Application repo (e.g. EAC) | That app’s UI, host wiring, business schema, local sandbox, deploy for that app |
| SYSTEM-SHARED-UI | `BreezeOn.UI` — **UI framework** + **authentication framework** + **authorization framework** + **Identity schema definitions** + **Security schema definitions**; gallery test host; no hosted business database |
| STANDARDS | How we work, what exists org-wide, ADRs |
| `.github` profile | Vision / mission / ecosystem messaging only |

Current topology: [architecture/landscape.md](../architecture/landscape.md). UI standards: [docs/ui/overview.md](ui/overview.md).
