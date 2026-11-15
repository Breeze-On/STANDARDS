# Page security standard

Owner: Architecture

## Rule

Page security is **not** database-configurable. Do **not** create `Security.Pages`, `Security.PagesGroups`, or front-end page-security configuration tables.

## Single source of truth

Each product registers a **page catalog** of `BoPageDefinition` entries (SHARED-UI types):

- Key, route
- Nav / Home / header resource metadata
- `RequiredGroupCodes[]` — empty means any authenticated user

The **same** catalog drives:

1. Navigation visibility
2. Home card visibility
3. Route authorization
4. Access Denied page

All checks go through **`IBoAuthorizationService`** — not duplicated product conditionals.

**Fail closed on catalog miss:** authenticated navigation to a path (or page key) **not** present in the product page catalog is **denied**. Empty `RequiredGroupCodes` remains intentional any-authenticated access for registered pages. Products must register every authenticated route they expose (redirect targets included).

**Privileged mutations** on restricted surfaces (for example EAC Users Security writes) must also call `EnsureInGroupAsync` — see [authorization-standard.md](authorization-standard.md) § Privileged writes.

## Gallery

UI Gallery does not apply page-security group restrictions (anonymous component gallery today; if authenticated later, required groups remain empty).

## Access Denied

SHARED-UI provides the styled Access Denied experience via `BoAccessDenied` (localized lead/body, Access Details + minimal Support Details, `.bo-error-message*` foundation), rendered by `BoAuthorizeRouteView` when a catalog route is denied **or the route is uncatalogued** (fail closed). Context is built with **best-effort** page-catalog resolution (omit Page on miss). Gallery showcase: `/error-message-page` hosts the **same** component. Full UI standard: [docs/ui/shell/error-messages.md](../../docs/ui/shell/error-messages.md). Footer suppression (`ShowFooter = false`) and product adoption (e.g. EAC) are Phase 2 host concerns.
