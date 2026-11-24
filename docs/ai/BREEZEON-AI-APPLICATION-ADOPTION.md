<!-- Classification: AN; Scope: platform; Domain: Engineering; Capability: AiOnboarding -->
# BreezeOn AI — Application adoption (EAC reference)

Owner: Documentation

Documents **SYSTEM-ADMIN-EAC** as the first product app that successfully adopts `BreezeOn.UI`. Use this when onboarding another application or extending EAC’s shell. Detail lives in the EAC and Shared UI repos; this file explains the pattern.

Prerequisite: [`BREEZEON-AI-QUICKSTART.md`](BREEZEON-AI-QUICKSTART.md).

### Two onboarding meanings (do not conflate)

| Meaning | Use when | SSOT |
| --- | --- | --- |
| **Product application onboarding** | Creating the next product application (**App #N** after EAC/INV) consuming SHARED-UI | [`application-development-process.md`](application-development-process.md) (Steps 1–6, including repository transition) + [`application-definition.schema.json`](application-definition.schema.json) (Step 1 inputs) + **This file** (adoption pattern) + [`application-model.md`](../application-model.md) |
| **Customer-environment onboarding** | Provisioning a customer DEV/UAT/PRD environment (Entra, cutover, customer activation) | [`runbooks/customer-onboarding-master-flow.md`](../../runbooks/customer-onboarding-master-flow.md) |

The **Customer Onboarding Master Flow is not used to create new BreezeOn applications.** Do not substitute one path for the other.

---

## Next product application (App #N) kickoff card

**Alias:** older docs said “App #2” for the first product app after EAC. **INV** is the first validated product application ([application-development-process.md](application-development-process.md) worked example). Use **App #N** for the next new product repository. Procedure ownership: process Steps 1–6 + schema — this file is the adoption pattern / reference-host guidance, not a competing procedure.

### Must

- Consume **SHARED-UI** (`BreezeOn.UI`) — interim sibling `ProjectReference`
- Implement **Authentication** (platform Entra OIDC — do not defer)
- Implement **Authorization** + page catalog (do not defer)
- Follow the **Product Host Contract** ([page-development.md](../ui/page-development.md#product-host-contract-required))
- Provide **`scripts/dev-reset.ps1`** and **`scripts/dev-run.ps1`** (+ `.env.example`; OIDC via User Secrets)
- Create thin **`README_AI.md`** and **`AGENTS.md`** (reading-chain to [`docs/ai/README.md`](README.md))
- Configure **Dependabot** from [`templates/dependabot/`](../../templates/dependabot/) (may extend; see [security-governance.md](../security-governance.md))
- Add product **deploy workflow metadata** per [hosted-deployment.md](../hosted-deployment.md) (procedures stay centralized — do not fork)
- Capture Step 1 inputs from [`application-definition.schema.json`](application-definition.schema.json) (schema first; do not copy INV example values as defaults)

### Must not

- Defer Authentication or Authorization
- Fork **Identity** or **Security** schemas / create an independent Identity catalog
- Platformize EAC **Process Framework**, **Data Entities**, or **Variables** (EAC-scoped)
- Require an unshipped platform workflow engine before the next product app can proceed. Process Framework is metadata only; an application-owned runtime is an approved boundary when the product needs execution
- Invent **NuGet** distribution mechanics or **registry** discovery/deploy-order workflows
- Treat INV’s filled definition as the required shape of future applications

### Future Validation

- NuGet packaging / pin / compatibility strategy
- EAC `System` registry registration mechanics
- `UniqueCode` rename / split / retire lifecycle

---

## Why the adoption was successful

| Factor | Outcome |
| --- | --- |
| Clear goal | Shell + navigation + Home hub only — no premature business UI |
| Approved patterns only | Gallery-shaped host; no Fluent on product pages; locked Home/`BoAppShell` |
| Thin app resources | EAC owns `EacResources` / `IEacLocalizer` instead of misusing Gallery `BoUi` |
| Platform foundations | New apps assume Identity / Auth / AuthZ as **mandatory** platform consumption ([application-model.md](../application-model.md)) — historical EAC shell milestones that deferred auth are **not** a template for App #N |
| Docs updated together | STANDARDS landscape/eac/i18n + EAC README_AI + Shared UI README_AI |

Success criterion for adoption: a separate application runs on Interactive Server with `BoAppShell`, BreezeOn branding, localized chrome, standards-compliant Home cards, and **platform authentication + authorization + page catalog** — without inventing alternate chrome or deferring Identity.

---

## Required integration steps

1. **Reference** `BreezeOn.UI` (**mandatory** — interim: sibling `ProjectReference` to `SYSTEM-SHARED-UI/src/BreezeOn.UI`; NuGet/pinning = Future Validation for App #N).
2. **Product Host Contract (AA SSOT):** follow [`page-development.md` § Product Host Contract](../ui/page-development.md#product-host-contract-required) end-to-end — UI + `AddBreezeOnAuthentication` / `MapBreezeOnAuthentication` + `AddBreezeOnAuthorization(pageCatalog)` + `BoAuthorizeRouteView` + Data Protection `SetApplicationName` + `BoErrorMessageOptions.ApplicationDisplayName` + Access Denied footer off + localization + app-owned resources. Gallery = chrome/assets only; **EAC = complete product host reference**.
3. **Head assets:** Fluent bundle CSS, `breezeon-ui.css`, and the **seven** core scripts from the host-script inventory SSOT (`bo-sliding-selection.js`, **not** `bo-toggle.js`; no `?v=` cache-bust).
4. **Nav / Home / titles:** `BoNavPane` + Home hub + per-route localized header titles — see page-development checklist.
5. **CI:** Sibling Shared UI checkout (EAC DEV workflow pattern) per interim cross-repo contract.
6. **Hosted SQL (data-owning apps) — checklist (all required):** (a) `SQLAzureConnection` empty in repo `appsettings.json`; (b) App Service connection string + system-assigned MI; (c) grant via [`templates/azure-sql/`](../../templates/azure-sql/); (d) **MUST** add NuGet **`Microsoft.Data.SqlClient.Extensions.Azure`** + register `ActiveDirectoryAuthenticationProvider` before `Migrate`/first SQL open (SqlClient 7+). Procedure: [hosted-deployment.md](../hosted-deployment.md).
7. **Registry expectation:** plan to register the app in the EAC-owned `System` catalog (`UniqueCode` = repo name); **mechanics = Future Validation** ([application-model.md](../application-model.md)).
8. **Docs:** Update product README / README_AI and STANDARDS architecture for the new Shared UI consumer.

Page construction checklist: [`docs/ui/page-development.md`](../ui/page-development.md).

---

## Typical files modified (EAC)

| Area | Examples |
| --- | --- |
| Project | `BreezeOn.Eac.csproj` — ProjectReference to SHARED-UI |
| Startup | `Program.cs` — `AddBreezeOnUI`, platform auth/authZ, localization, EF |
| Host | `Components/App.razor` — CSS/JS; Interactive Server |
| Imports | `Components/_Imports.razor` — `BreezeOn.UI.*` namespaces |
| Shell | `Components/Layout/MainLayout.razor` — AppShell + nav + header resolution |
| Pages | `Home.razor` (hub); empty destination pages for IA |
| Brand | `wwwroot/brand/app-logo.svg`, `nav-logo.svg`, `favicon.svg` |
| Resources | `Resources/EacResources.resx` (+ `.fr`), `IEacLocalizer` |
| Styles | `wwwroot/app.css` — height/overflow + Calibri / tokens; strip template chrome |
| Deploy | `.github/workflows/deploy-dev.yml` — product metadata + sibling Shared UI checkout; procedures: [hosted-deployment.md](../hosted-deployment.md) |

Remove when adopting cleanly: default Blazor sidebar/`NavMenu`, Bootstrap-first chrome, ASP.NET Core Identity Account trees / `AspNet*` stores. Do **not** ship a new app without platform Entra OIDC auth and page security.

---

## Lessons learned

| Lesson | Guidance for the next app |
| --- | --- |
| Localizer lifetime | Register app localizer **scoped** if it depends on scoped `IBoLocaleService` (not singleton) |
| Marker type name | Avoid a type named `Adm` under namespace `BreezeOn.Eac` — use `EacResources` |
| Icons | Prefer names/`Size` values known to `BoIcon` resolver (or Size 20/24 known mappings) |
| Home vs forms | Never use Section→Row→Field as the Home layout |
| Identity vs shell | **Historical EAC lesson:** static AspNet Account SSR and interactive AppShell do not mix well. **Current rule:** use platform Entra OIDC + SHARED-UI auth — do not defer Identity for new apps |
| EF vs business SQL | EAC keeps SYSADM in `sql/current_model/`; EF `InitialBaseline` only preserves `__EFMigrationsHistory` |
| SqlClient 7 + MI | `Authentication=Active Directory Managed Identity` needs **`Microsoft.Data.SqlClient.Extensions.Azure`** + provider registration; missing it crash-loops App Service and burns Free F1 into **QuotaExceeded** |
| Docs are part of Done | Landscape must say the app **does** reference Shared UI once true |

---

## Future application onboarding (adoption pattern)

**Procedure SSOT:** [`application-development-process.md`](application-development-process.md) Steps 1–6 + [`application-definition.schema.json`](application-definition.schema.json) for Step 1. Do **not** treat the list below as a competing procedure — it is the EAC-derived adoption pattern checklist that maps into those steps.

```text
1. Read docs/ai/BREEZEON-AI-QUICKSTART.md (+ governance reading chain)
2. Step 1: fill application-definition.schema.json instance (schema first); then this kickoff card + docs/application-model.md + docs/ui/page-development.md
3. Steps 2–3: plan + repository transition per application-development-process.md
4. Repo baselines: AGENTS.md + README_AI.md (thin reading-chain pointers); Dependabot from templates/dependabot (may extend); review docs/security-governance.md — do not duplicate governance text
5. Clone / sibling SYSTEM-SHARED-UI for ProjectReference (NuGet/pinning = Future Validation)
6. Wire host (Program, App.razor, MainLayout) with **BoAppShell + platform auth/authZ + page catalog**
7. Add app-owned resources (en/fr) — never copy BoUi keys as the product glossary
8. Define IA from the Step 1 instance: Home hub cards + left nav routes (URL = page name)
9. Ship destination pages inside BoAppShell with catalog registration
10. Provide `scripts/dev-reset.ps1` + `scripts/dev-run.ps1` + `.env.example`; OIDC secrets via User Secrets ([application-model.md](../application-model.md) · [local-development-scripts.md](../local-development-scripts.md))
11. Shared customer DB: Identity + Security schemas are **shared** (SHARED-UI definitions) — never fork. New customer-environment → Master Flow; new product app in an existing environment → consume the existing customer DB ([application-model.md](../application-model.md) § Database ownership)
12. If the app owns Azure SQL: enable App Service MI, set `SQLAzureConnection`, run templates/azure-sql/grant-app-service-mi.sql, and wire **Microsoft.Data.SqlClient.Extensions.Azure** + MI provider registration (SqlClient 7+)
13. Add `.github/workflows/deploy-dev.yml` product metadata + GitHub Environment **DEV** per hosted-deployment.md (Step 6 when authorized — do not fork procedures)
14. Plan EAC `System` registry registration (`uniqueCode` = repositoryName.ToUpperInvariant()); mechanics = Future Validation
15. Update product README_AI + STANDARDS architecture/landscape in the same change set
16. Verify per process Steps 5–6 (local agent stop at Entra; hosted only when authorized)
```

Optional defense-in-depth: copy [`templates/cursor-rules/`](../../templates/cursor-rules/) after the reading-chain pointers exist (not a substitute for AGENTS/README_AI).

Do **not** invent a second design system. Extend `BreezeOn.UI` (with Gallery + STANDARDS UI docs) when a shared control is missing. Do **not** invent a custom local startup workflow — reuse `dev-reset.ps1` + `dev-run.ps1` ([local-development-scripts.md](../local-development-scripts.md)). Do **not** defer platform Identity/Auth/AuthZ for new applications.

---

## References

| Resource | Link |
| --- | --- |
| EAC architecture | [`architecture/applications/eac.md`](../../architecture/applications/eac.md) |
| Landscape / consumers | [`architecture/landscape.md`](../../architecture/landscape.md) |
| EAC agent surface | [SYSTEM-ADMIN-EAC README_AI](https://github.com/Breeze-On/SYSTEM-ADMIN-EAC/blob/main/README_AI.md) |
| Shared UI agents | [SYSTEM-SHARED-UI README_AI](https://github.com/Breeze-On/SYSTEM-SHARED-UI/blob/main/README_AI.md) |
| Gallery host (implementation reference) | `SYSTEM-SHARED-UI` → `src/BreezeOn.UI.Gallery` |
