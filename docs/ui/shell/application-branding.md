<!-- Classification: AA; Scope: platform; Domain: UI; Capability: ShellBranding -->
# UI — Application branding

Owner: UI

First-class branding concepts for every BreezeOn product host. Related: [shell.md](shell.md) · [navigation.md](navigation.md) · [application-theme-palette.md](../foundations/application-theme-palette.md) · [application-development-process.md](../../ai/application-development-process.md)

These defaults apply to **all** future BreezeOn applications unless a plan explicitly overrides them.

---

## Branding model (locked names)

### Application Branding

| Concept | Standard asset | Meaning | Typical surface |
| --- | --- | --- | --- |
| **Application Display Name** | — | Human-readable application name | Browser titles, header titles, error chrome, product `BrandText` |
| **Application Logo** | **`app-logo.svg`** | Logo that represents **the application** | Home right-panel brand (`BoNavHub` `ApplicationLogoSrc`) |

### Customer / Tenant Branding

| Concept | Standard asset | Meaning | Typical surface |
| --- | --- | --- | --- |
| **Navigation Logo** | **`nav-logo.svg`** | Logo that represents the **customer**, **tenant**, or **environment** | Left nav (`BoNavPane` Navigation Logo bindings) |
| **Browser Favicon** | **`favicon.svg`** | Tab icon; aligns with Navigation Logo branding by default | `<link rel="icon">` via `IBoBrandingService.BrowserFaviconSrc` |

### Branding asset naming (locked)

| Rule | Standard |
| --- | --- |
| Filenames | Always `app-logo.svg`, `nav-logo.svg`, `favicon.svg` |
| User / designer uploads | **Never** retained as permanent names — rename on import |
| Host location | Product `wwwroot/brand/` and/or Shared UI `_content/BreezeOn.UI/brand/` |
| Future apps | Inherit these three names automatically via the application-development process |
| Decoupling | Application Logo, Navigation Logo, and Browser Favicon remain **separate** concepts even when they temporarily use the same visual |

### Theme Configuration

| Concept | Meaning | Typical surface |
| --- | --- | --- |
| **Theme Palette** | Application visual identity (Light + Dark) | [application-theme-palette.md](../foundations/application-theme-palette.md) · `BoThemePaletteConfiguration` |

Use these names consistently across Shared UI, applications, documentation, configuration models, and implementation.

Future applications **must not** require Shared UI source changes to customize these concepts. Configuration is owned by the product host (`BoBrandingOptions` + assets + Theme Palette).

---

## Application Display Name

- Required application-definition input ([application-definition.schema.json](../../ai/application-definition.schema.json); explained in [application-development-process.md](../../ai/application-development-process.md)).
- Used throughout application branding and in **browser titles**.
- Example: `Corporate Finance Investments`.
- Localized chrome may still use resource keys; the **canonical display name** is the product’s human title.
- Distinct from the **platform display name** below.

### Platform display name (org chrome)

| Concern | Standard |
| --- | --- |
| Default expanded-nav / org label | **`Breeze On`** (space between words) |
| Not | `BreezeOn`, `BreezeOn UI`, or other concatenations for default platform chrome |
| Gallery / Shared UI showcase | Use **`Breeze On`** as the default `BrandText` / Application Display Name when representing the platform |
| Product hosts | Prefer **Application Display Name** for product `BrandText` / chrome that identify the app |

---

## Application Logo vs Navigation Logo (hard separation)

| | Application Logo | Navigation Logo |
| --- | --- | --- |
| Bucket | Application Branding | Customer / Tenant Branding |
| Represents | The **application** (EAC, INV, future products) | The **customer / tenant / environment** |
| Primary placement | Home hub right panel | Left navigation (expanded wordmark + minimized icon) |
| Configuration | Independent (`BoBrandingOptions.ApplicationLogoSrc`) | Independent (`NavigationLogoExpandedSrc` / `NavigationLogoMinimizedSrc`) |
| References / bindings | Independent | Independent |
| Replacement path | Replace without changing Navigation Logo | Replace without changing Application Logo |

Even when both temporarily point at the **same image file**, they **must** remain:

- Separate configuration entries
- Separate code references / parameters
- Separate asset bindings
- Separate future replacement paths

**Do not** treat Home logo and nav logos as one shared “brand logo” setting.

### Navigation Logo structure

Navigation Logo retains the **expanded + minimized** pair (wordmark + compact icon) for left nav and page-freeze consumption of the minimized URL ([navigation.md](navigation.md) · [overlays.md](overlays.md)). Both sizes are Navigation Logo assets — not Application Logo.

---

## Browser Favicon

| Rule | Standard |
| --- | --- |
| Asset | **`favicon.svg`** (Customer / Tenant Branding) |
| Alignment | By default aligns with Navigation Logo branding; remains a **separate** configured asset |
| Host script | Product `App.razor` includes `_content/BreezeOn.UI/js/bo-branding.js` |
| Binding | `BoBrandingOptions.BrowserFaviconSrc` → `IBoBrandingService.BrowserFaviconSrc` |

---

## Browser title

| Rule | Standard |
| --- | --- |
| Format | `<Page Title> - <Application Display Name>` |
| Examples | `Home - Corporate Finance Investments`, `New Request - Corporate Finance Investments` |
| Implementation | Shared UI `BoDocumentTitle` + `BoDocumentTitleFormat` |
| Page title | Current page title only (no hardcoded application name prefix) |
| Application name | Configured Application Display Name (`BoBrandingOptions` / branding service) |
| Navigation | Title updates as the user navigates (per-page `BoDocumentTitle`) |

Do **not** hardcode application names into `PageTitle` resource strings.

---

## Home page metadata

| Concern | Standard |
| --- | --- |
| Home `AppTitle` | Application Display Name (localized) |
| Home `Subtitle` | **Omit** — Home pages **must not** display a subtitle by default (`Subtitle` null/whitespace so `BoAppHeader` hides the dash) |

---

## Default destination pages and subtitles

Unless a plan overrides IA, every new BreezeOn application includes:

| Page | Route | Standard subtitle (reusable; not product-specific) | Default icon (`BoIcon` Name, Regular / outlined) |
| --- | --- | --- | --- |
| New Request | `/new-request` | Start a new request and capture the information needed for review and processing. | `AddSquareMultiple` |
| Status Report | `/status-report` | Review the current status of requests and track progress toward completion. | `Dashboard` |
| My Tasks | `/my-tasks` | Open the tasks assigned to you and continue work that needs your attention. | `AppsListDetail` |

Subtitles **must not** name a specific application, UniqueCode, or business workflow.

### Default page icons (locked unless overridden)

- Variant: **`Regular`** (Fluent outlined).
- Catalog `IconName` values above are the **default generated** icons for new applications (nav + Home cards).
- Home cards use Size **32**; left nav uses Size **20** — [icons.md](../foundations/icons.md). `BoIconResolver` must map each default name at both sizes (Fluent often lacks Size 32; fall back to the nearest shipped size).
- Plans may override a page icon only with an explicit justification.

### Navigation card description = page subtitle (locked)

For each Home destination card:

- Card **Label** = page nav / home label
- Card **Description** = **exactly** that page’s header **Subtitle** (same localized string / resource key)

Hosts should bind Home card descriptions and page subtitles from the **same** resource keys (or equivalent single source) so they cannot drift.

---

## Host wiring (current reality)

| Concern | Implementation |
| --- | --- |
| Options | `Configure<BoBrandingOptions>(…)` after `AddBreezeOnUI` |
| Bootstrap | `BoProviders` → `BoBrandingBootstrap` applies options and syncs favicon |
| Application Logo | `app-logo.svg` via `BoNavHub ApplicationLogoSrc` |
| Navigation Logo | `nav-logo.svg` via `BoNavPane` Navigation Logo parameters |
| Browser Favicon | `favicon.svg` via `BrowserFaviconSrc` |
| Browser title | `<BoDocumentTitle PageTitle="…" />` on each page |
| Theme Palette | `Configure<BoThemePaletteConfiguration>(…)` — [application-theme-palette.md](../foundations/application-theme-palette.md) |
