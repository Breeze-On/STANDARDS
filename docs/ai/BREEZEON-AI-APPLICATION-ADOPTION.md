<!-- Classification: AN; Scope: platform; Domain: Engineering; Capability: AiOnboarding -->
# BreezeOn AI — Application adoption (EAC reference)

Owner: Documentation

Documents **SYSTEM-ADMIN-EAC** as the first product app that successfully adopts `BreezeOn.UI`. Use this when onboarding another application or extending EAC’s shell. Detail lives in the EAC and Shared UI repos; this file explains the pattern.

Prerequisite: [`BREEZEON-AI-QUICKSTART.md`](BREEZEON-AI-QUICKSTART.md).

### Two onboarding meanings (do not conflate)

| Meaning | Use when | SSOT |
| --- | --- | --- |
| **Product application onboarding** | Creating App #2, App #3, … (new BreezeOn product repository consuming SHARED-UI) | **This file** + [`application-model.md`](../application-model.md) |
| **Customer-environment onboarding** | Provisioning a customer DEV/UAT/PRD environment (Entra, cutover, customer activation) | [`runbooks/customer-onboarding-master-flow.md`](../../runbooks/customer-onboarding-master-flow.md) |

The **Customer Onboarding Master Flow is not used to create new BreezeOn applications.** Do not substitute one path for the other.

---

## App #2 kickoff card

### Must

- Consume **SHARED-UI** (`BreezeOn.UI`) — interim sibling `ProjectReference`
- Implement **Authentication** (platform Entra OIDC — do not defer)
- Implement **Authorization** + page catalog (do not defer)
- Follow the **Product Host Contract** ([page-development.md](../ui/page-development.md#product-host-contract-required))
- Provide **`scripts/dev-reset.ps1`** (+ `.env.example`; OIDC via User Secrets)
- Create thin **`README_AI.md`** and **`AGENTS.md`** (reading-chain to [`docs/ai/README.md`](README.md))
- Configure **Dependabot** from [`templates/dependabot/`](../../templates/dependabot/) (may extend; see [security-governance.md](../security-governance.md))
- Add product **deploy workflow metadata** per [hosted-deployment.md](../hosted-deployment.md) (procedures stay centralized — do not fork)

### Must not

- Defer Authentication or Authorization
- Fork **Identity** or **Security** schemas / create an independent Identity catalog
- Platformize EAC **Process Framework**, **Data Entities**, or **Variables** (EAC-scoped)
- Invent **NuGet** distribution mechanics or **registry** discovery/deploy-order workflows

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
| Platform foundations | New apps assume Identity / Auth / AuthZ as **mandatory** platform consumption ([application-model.md](../application-model.md)) — historical EAC shell milestones that deferred auth are **not** a template for app #2 |
| Docs updated together | STANDARDS landscape/eac/i18n + EAC README_AI + Shared UI README_AI |

Success criterion for adoption: a separate application runs on Interactive Server with `BoAppShell`, BreezeOn branding, localized chrome, standards-compliant Home cards, and **platform authentication + authorization + page catalog** — without inventing alternate chrome or deferring Identity.

---

## Required integration steps

1. **Reference** `BreezeOn.UI` (**mandatory** — interim: sibling `ProjectReference` to `SYSTEM-SHARED-UI/src/BreezeOn.UI`; NuGet/pinning = Future Validation at app #2).
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
| Brand | `wwwroot/brand/home-hero.svg` |
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

## Future application onboarding process

```text
1. Read docs/ai/BREEZEON-AI-QUICKSTART.md (+ governance reading chain)
2. Read this file (kickoff card) + docs/application-model.md + docs/ui/page-development.md
3. Repo baselines: AGENTS.md + README_AI.md (thin reading-chain pointers); Dependabot from templates/dependabot (may extend); review docs/security-governance.md — do not duplicate governance text
4. Clone / sibling SYSTEM-SHARED-UI for ProjectReference (NuGet/pinning = Future Validation)
5. Wire host (Program, App.razor, MainLayout) with **BoAppShell + platform auth/authZ + page catalog**
6. Add app-owned resources (en/fr) — never copy BoUi keys as the product glossary
7. Define IA: Home hub cards + left nav routes (URL = page name)
8. Ship destination pages inside BoAppShell with catalog registration
9. Provide `scripts/dev-reset.ps1` + `.env.example`; OIDC secrets via User Secrets ([application-model.md](../application-model.md))
10. Shared customer DB: Identity + Security schemas are **shared** (SHARED-UI definitions) — never fork. New customer-environment → Master Flow; new product app in an existing environment → consume the existing customer DB ([application-model.md](../application-model.md) § Database ownership)
11. If the app owns Azure SQL: enable App Service MI, set `SQLAzureConnection`, run [`templates/azure-sql/grant-app-service-mi.sql`](../../templates/azure-sql/grant-app-service-mi.sql), and wire **`Microsoft.Data.SqlClient.Extensions.Azure`** + MI provider registration (SqlClient 7+)
12. Add `.github/workflows/deploy-dev.yml` product metadata + GitHub Environment **DEV** per [hosted-deployment.md](../hosted-deployment.md) (procedures stay in STANDARDS — do not fork)
13. Plan EAC `System` registry registration (`UniqueCode` = repo name); mechanics = Future Validation
14. Update product README_AI + STANDARDS architecture/landscape in the same change set
15. Verify (split):
    - Agent-completable: `.\scripts\dev-reset.ps1`, build, launch, reach authentication boundary (e.g. 302 to Entra) — stop; hand back
    - Human-assisted: sign-in, navigation, localization, theme, Home cards — no Fluent imports on product pages
```

Optional defense-in-depth: copy [`templates/cursor-rules/`](../../templates/cursor-rules/) after the reading-chain pointers exist (not a substitute for AGENTS/README_AI).

Do **not** invent a second design system. Extend `BreezeOn.UI` (with Gallery + STANDARDS UI docs) when a shared control is missing. Do **not** invent a custom local startup workflow — reuse `dev-reset.ps1`. Do **not** defer platform Identity/Auth/AuthZ for new applications.

---

## References

| Resource | Link |
| --- | --- |
| EAC architecture | [`architecture/applications/eac.md`](../../architecture/applications/eac.md) |
| Landscape / consumers | [`architecture/landscape.md`](../../architecture/landscape.md) |
| EAC agent surface | [SYSTEM-ADMIN-EAC README_AI](https://github.com/Breeze-On/SYSTEM-ADMIN-EAC/blob/main/README_AI.md) |
| Shared UI agents | [SYSTEM-SHARED-UI README_AI](https://github.com/Breeze-On/SYSTEM-SHARED-UI/blob/main/README_AI.md) |
| Gallery host (implementation reference) | `SYSTEM-SHARED-UI` → `src/BreezeOn.UI.Gallery` |
