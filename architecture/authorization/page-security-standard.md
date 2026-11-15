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

## Gallery

UI Gallery does not apply page-security group restrictions (anonymous component gallery today; if authenticated later, required groups remain empty).

## Access Denied

SHARED-UI provides a styled Access Denied experience via `BoAuthorizeRouteView` (replacing bare “Not authorized” text).
