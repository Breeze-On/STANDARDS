<!-- Classification: AA; Scope: platform; Domain: Security; Capability: Authorization -->
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

Code-based page evaluation goes through **`IBoAuthorizationService`**. Host shells may short-circuit empty `RequiredGroupCodes` for registered pages but must stay semantically identical to the service.

**Fail closed on catalog miss:** authenticated navigation to a page **key** not present in the catalog is **denied**. For **routes**, `BoPageCatalog.FindByRoute` resolves an exact match first, then **longest-prefix inheritance** for nested paths (e.g. `/users/…` inherits the `/users` catalog entry). A path that does not match any catalog route (exact or as a child of a catalogued prefix) is **denied**. Empty `RequiredGroupCodes` remains intentional any-authenticated access for registered pages (and their nested descendants under prefix inheritance). Products must register every authenticated route they expose (redirect targets included); do not rely on an any-authenticated parent to cover unrelated undeclared siblings.

**Duplicate routes:** registering two catalog entries with the same normalized route is a **startup error** (`BoPageCatalog` throws). Last-wins silent overwrite is not allowed.

**Privileged mutations** on restricted surfaces (for example EAC Users Security writes) must also call `EnsureInGroupAsync` (or a named product exception) — see [authorization-standard.md](authorization-standard.md) § Privileged writes. Mutation APIs themselves are convention-based ([ADR-014](../../decisions/ADR-014-platform-authorization.md)).

## Gallery

UI Gallery does not apply page-security group restrictions (anonymous component gallery today; if authenticated later, required groups remain empty).

## Access Denied

SHARED-UI provides the styled Access Denied experience via `BoAccessDenied` (localized lead/body, Access Details + minimal Support Details, `.bo-error-message*` foundation), rendered by `BoAuthorizeRouteView` when a catalog route is denied **or the route is uncatalogued** (fail closed). Context is built with **best-effort** page-catalog resolution (omit Page on miss). Gallery showcase: `/error-message-page` hosts the **same** component. Full UI standard: [docs/ui/shell/error-messages.md](../../docs/ui/shell/error-messages.md). Product hosts **must** suppress footer (`ShowFooter = false`) and set `BoErrorMessageOptions.ApplicationDisplayName` — EAC implements this ([page-development.md](../../docs/ui/page-development.md#product-host-contract-required)).
