# BreezeOn AI — Application adoption (ADM reference)

Owner: Documentation

Documents **SYSTEM-ADMIN-ADM** as the first product app that successfully adopts `BreezeOn.UI`. Use this when onboarding another application or extending ADM’s shell. Detail lives in the ADM and Shared UI repos; this file explains the pattern.

Prerequisite: [`BREEZEON-AI-QUICKSTART.md`](BREEZEON-AI-QUICKSTART.md).

---

## Why the adoption was successful

| Factor | Outcome |
| --- | --- |
| Clear goal | Shell + navigation + Home hub only — no premature business UI |
| Approved patterns only | Gallery-shaped host; no Fluent on product pages; locked Home/`BoAppShell` |
| Thin app resources | ADM owns `AdmResources` / `IAdmLocalizer` instead of misusing Gallery `BoUi` |
| Honest auth deferral | Identity removed for this milestone; pages public until a security milestone |
| Docs updated together | STANDARDS landscape/adm/i18n + ADM README_AI + Shared UI README_AI |

Success criterion for adoption: a separate application runs on Interactive Server with `BoAppShell`, BreezeOn branding, localized chrome, and standards-compliant Home cards — without inventing alternate chrome.

---

## Required integration steps

1. **Reference** `BreezeOn.UI` (today: sibling `ProjectReference` to `SYSTEM-SHARED-UI/src/BreezeOn.UI`; NuGet when published).
2. **DI:** `builder.Services.AddBreezeOnUI()` (do not call `AddFluentUIComponents()` in the app).
3. **Localization host:** `RequestLocalizationOptions` for `en`/`fr` + `UseRequestLocalization()`.
4. **Head assets:** Fluent bundle CSS, `breezeon-ui.css`, early `bo-theme-mode.js` / `bo-locale.js` (and other library JS as needed).
5. **Layout:** `BoThemeProvider` → `BoAppShell` (nav + header + body) → `BoProviders`.
6. **Nav:** `BoNavPane` + `BoNavLink` + `BoIcon`; routes = page names.
7. **Home:** `BoNavHub` + one `BoNavCardStyleHyperlink` per destination; `ShowFooter` false on Home.
8. **Titles:** Per-route localized `BoAppHeader` `AppTitle` / `Subtitle` (empty subtitle omits dash).
9. **App resources:** Own `.resx` + locale-aware localizer; subscribe to `IBoLocaleService.Changed`.
10. **CI:** If ProjectReference is used, checkout Shared UI as a sibling (ADM DV workflow pattern).
11. **Docs:** Update product README / README_AI and STANDARDS architecture when the app becomes a Shared UI consumer.

Page construction checklist: [`docs/ui/page-development.md`](../ui/page-development.md).

---

## Typical files modified (ADM)

| Area | Examples |
| --- | --- |
| Project | `BreezeOn.Adm.csproj` — ProjectReference; drop Identity packages when unused |
| Startup | `Program.cs` — `AddBreezeOnUI`, localization, EF (no Identity) |
| Host | `Components/App.razor` — CSS/JS; Interactive Server |
| Imports | `Components/_Imports.razor` — `BreezeOn.UI.*` namespaces |
| Shell | `Components/Layout/MainLayout.razor` — AppShell + nav + header resolution |
| Pages | `Home.razor` (hub); empty destination pages for IA |
| Brand | `wwwroot/brand/home-hero.svg` |
| Resources | `Resources/AdmResources.resx` (+ `.fr`), `IAdmLocalizer` |
| Styles | `wwwroot/app.css` — height/overflow + Calibri / tokens; strip template chrome |
| Deploy | `.github/workflows/deploy-dv.yml` — sibling Shared UI checkout |

Remove when adopting cleanly: default Blazor sidebar/`NavMenu`, Bootstrap-first chrome, Identity Account tree (if not required), any `[Authorize]` that blocks shell validation.

---

## Lessons learned

| Lesson | Guidance for the next app |
| --- | --- |
| Localizer lifetime | Register app localizer **scoped** if it depends on scoped `IBoLocaleService` (not singleton) |
| Marker type name | Avoid a type named `Adm` under namespace `BreezeOn.Adm` — use `AdmResources` |
| Icons | Prefer names/`Size` values known to `BoIcon` resolver (or Size 20/24 known mappings) |
| Home vs forms | Never use Section→Row→Field as the Home layout |
| Identity vs shell | Static Account SSR and interactive AppShell do not mix well — separate layouts or defer Identity |
| EF vs business SQL | ADM keeps SYSADM in `sql/current_model/`; EF `InitialBaseline` only preserves `__EFMigrationsHistory` |
| Docs are part of Done | Landscape must say the app **does** reference Shared UI once true |

---

## Future application onboarding process

```text
1. Read docs/ai/BREEZEON-AI-QUICKSTART.md
2. Read this file + docs/ui/page-development.md
3. Clone / sibling SYSTEM-SHARED-UI for ProjectReference (or consume NuGet when available)
4. Wire host (Program, App.razor, MainLayout) like ADM / Gallery
5. Add app-owned resources (en/fr) — never copy BoUi keys as the product glossary
6. Define IA: Home hub cards + left nav routes (URL = page name)
7. Ship empty or thin destination pages inside BoAppShell
8. Provide `scripts/dev-reset.ps1` + `.env.example` and document Local Development in README (org [local-development-scripts](../local-development-scripts.md) standard — no `dev-up` / `dev-down`)
9. Update product README_AI + STANDARDS architecture/landscape in the same change set
10. Verify: `.\scripts\dev-reset.ps1`, theme/locale switch, nav + Home cards — no Fluent imports in product pages
```

Do **not** invent a second design system. Extend `BreezeOn.UI` (with Gallery + STANDARDS UI docs) when a shared control is missing. Do **not** invent a custom local startup workflow — reuse `dev-reset.ps1`.

---

## References

| Resource | Link |
| --- | --- |
| ADM architecture | [`architecture/adm.md`](../../architecture/adm.md) |
| Landscape / consumers | [`architecture/landscape.md`](../../architecture/landscape.md) |
| ADM agent surface | [SYSTEM-ADMIN-ADM README_AI](https://github.com/Breeze-On/SYSTEM-ADMIN-ADM/blob/main/README_AI.md) |
| Shared UI agents | [SYSTEM-SHARED-UI README_AI](https://github.com/Breeze-On/SYSTEM-SHARED-UI/blob/main/README_AI.md) |
| Gallery host (implementation reference) | `SYSTEM-SHARED-UI` → `src/BreezeOn.UI.Gallery` |
