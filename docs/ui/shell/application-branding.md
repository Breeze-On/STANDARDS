<!-- Classification: AA; Scope: platform; Domain: UI; Capability: ShellBranding -->
# UI — Application branding

Owner: UI

First-class branding concepts for every BreezeOn product host. Related: [shell.md](shell.md) · [navigation.md](navigation.md) · [application-theme-palette.md](../foundations/application-theme-palette.md) · [application-development-process.md](../../ai/application-development-process.md) · [application-definition.schema.json](../../ai/application-definition.schema.json)

These defaults apply to **all** future BreezeOn applications unless a plan explicitly overrides them.

---

## Branding packages (locked)

Step 1 branding is two packages. Application Display Name is **not** a member of either package.

### Application Branding package

| Member | Standard asset | Meaning | Typical surface |
| --- | --- | --- | --- |
| **Application Logo** | **`app-logo.svg`** | Logo that represents **the application** | Home right-panel brand (`BoNavHub` `ApplicationLogoSrc`) |

### Customer Branding package

| Member | Standard / input | Meaning | Typical surface |
| --- | --- | --- | --- |
| **Customer Name** | `customerName` (optional; default **`BreezeOn`**) | Human-readable customer / tenant name | Expanded left nav, immediately to the right of the customer logo |
| **Customer Logo** | Source **`customer-logo.svg`** | Logo that represents the **customer** / **tenant** | Left nav + favicon (via generated assets) |
| **Primary / Secondary / Tertiary Color** | Optional `#RRGGBB` triad (all-or-nothing) | Customer brand colors for palette derivation | Theme pipeline — [application-theme-palette.md](../foundations/application-theme-palette.md) |

### Outside branding packages (application-definition)

| Concept | Meaning | Typical surface |
| --- | --- | --- |
| **Application Display Name** | Human-readable product name (`applicationDisplayName`) | Browser titles, Home `AppTitle`, error chrome |

---

## Customer Logo asset model

```text
Customer Branding
└─ customer-logo.svg          (canonical source; user or platform default)
    ├─ nav-logo.svg           (generated — navigation expanded/minimized bindings)
    └─ favicon.svg            (generated — browser tab icon)

Application Branding
└─ app-logo.svg
```

| Rule | Standard |
| --- | --- |
| Source filename | Always **`customer-logo.svg`** for Customer Branding uploads / platform default |
| Generated filenames | Always **`nav-logo.svg`** and **`favicon.svg`** — implementation outputs, never Step 1 user inputs |
| Application Logo | Always **`app-logo.svg`** — independent of Customer Logo |
| User / designer uploads | **Never** retained as permanent names — rename on import to the canonical source name |
| Host location | Product `wwwroot/brand/` and/or Shared UI `_content/BreezeOn.UI/brand/` |
| Runtime bindings | `NavigationLogoExpandedSrc` / `NavigationLogoMinimizedSrc` / `BrowserFaviconSrc` may differ as URLs but **must** resolve from the `customer-logo.svg` derivation pipeline |
| SVG requirements | Source SVG must include an explicit `viewBox`; design for square-safe cropping so minimized nav and favicon remain legible; prefer a single mark that scales cleanly at expanded (~wordmark width) and minimized/favicon (~compact icon) sizes |

### Expanded vs minimized navigation

| State | Customer Logo | Customer Name |
| --- | --- | --- |
| **Expanded** | Show generated nav logo (`nav-logo.svg` / expanded binding) | Show to the **immediate right** of the logo (`BrandText` ← `customerName`, default `BreezeOn`) |
| **Minimized** | Show generated nav logo (minimized binding) | **Do not display** — visually hide (1px clip / equivalent); keep available to assistive tech; **do not** truncate or duplicate the name into the logo mark |

Page freeze consumes the **minimized** nav logo only — never an expanded wordmark ([overlays.md](overlays.md)).

---

## Application Display Name

- Required application-definition input ([application-definition.schema.json](../../ai/application-definition.schema.json); explained in [application-development-process.md](../../ai/application-development-process.md)).
- **Not** part of Application Branding or Customer Branding packages.
- Used in **browser titles**, Home `AppTitle`, and other product chrome that identifies the application.
- Example: `Corporate Finance Investments`.
- Localized chrome may still use resource keys; the **canonical display name** is the product’s human title.
- Distinct from **Customer Name** (`customerName`, default `BreezeOn`) and from the **platform display name** below.

### Platform display name (org chrome)

| Concern | Standard |
| --- | --- |
| Default org / Gallery label | **`Breeze On`** (space between words) |
| Not | `BreezeOn UI` or other concatenations for default platform chrome |
| vs Customer Name default | Customer Name schema default is **`BreezeOn`** (no space); platform display name remains **`Breeze On`** |
| Gallery / Shared UI showcase | Use **`Breeze On`** when representing the platform; product hosts bind expanded-nav `BrandText` to **Customer Name** |

---

## Application Logo vs Customer Logo (hard separation)

| | Application Logo | Customer Logo |
| --- | --- | --- |
| Package | Application Branding | Customer Branding |
| Represents | The **application** (EAC, INV, future products) | The **customer / tenant** |
| Canonical file | `app-logo.svg` | `customer-logo.svg` (generates `nav-logo.svg` + `favicon.svg`) |
| Primary placement | Home hub right panel | Left navigation + favicon |
| Configuration | `BoBrandingOptions.ApplicationLogoSrc` | Customer source → derived nav/favicon bindings |
| Replacement path | Replace without changing Customer Logo | Replace source; regenerate nav + favicon |

**Do not** treat Home logo and customer/nav logos as one shared “brand logo” setting.

---

## Browser Favicon

| Rule | Standard |
| --- | --- |
| Asset | **`favicon.svg`** — **generated** from `customer-logo.svg` |
| Not a Step 1 input | Do not collect favicon separately from Customer Logo |
| Host script | Product `App.razor` includes `_content/BreezeOn.UI/js/bo-branding.js` |
| Binding | Derived `BrowserFaviconSrc` → `IBoBrandingService.BrowserFaviconSrc` |

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

## Theme inputs (Customer Branding)

Only these user-configurable theme inputs may be persisted in application-definition: `primaryColor`, `secondaryColor`, `tertiaryColor`. See [application-theme-palette.md](../foundations/application-theme-palette.md).

---

## Host wiring (current reality)

| Concern | Implementation |
| --- | --- |
| Options | `Configure<BoBrandingOptions>(…)` after `AddBreezeOnUI` |
| Bootstrap | `BoProviders` → `BoBrandingBootstrap` applies options and syncs favicon |
| Customer Name | `customerName` → expanded-nav `BrandText` (default `BreezeOn`); hidden when minimized |
| Application Logo | `app-logo.svg` via `BoNavHub ApplicationLogoSrc` |
| Customer Logo | `customer-logo.svg` → generated `nav-logo.svg` / `favicon.svg` via `BoNavPane` + favicon bindings |
| Browser title | `<BoDocumentTitle PageTitle="…" />` on each page |
| Theme | Three brand colors → derived `BoThemePaletteConfiguration` — [application-theme-palette.md](../foundations/application-theme-palette.md) |
