<!-- Classification: AA; Scope: application:inv; Domain: Platform; Capability: Applications -->
# INV — Invoice Approval Request

Owner: Architecture

Current-reality description of **`breezeon-corp-fin-inv`** (UniqueCode `BREEZEON-CORP-FIN-INV`, Code `INV`).

## Role

Thin BreezeOn product host for invoice approval IA. Consumes `BreezeOn.UI` (AuthN, AuthZ, shell). Does **not** own EAC `System` schema.

## Implemented surfaces

| Surface | Behavior |
| --- | --- |
| Home | `BoNavHub` with cards: New Request, Status Report, My Tasks (listed when AE resolved; entry still AttributeCode-gated); links preserve `AE` via `IBoApplicationContextNavigation` |
| `/new-request`, `/status-report`, `/my-tasks` | Empty `BoCard` (`MarginDensity=Content`); footer off; AttributeCode gates **after** AE establishment |
| `/select-context` | Multi-visible-context picker (`BoContextSelection`): Home-style AppTitle + brand panel; informational header card; compact icon/label BE cards |
| `/application-error` | Generic `BoApplicationError` — outside AE bootstrap chain; no title/message query transport |
| AuthN | Platform Entra OIDC (`AddBreezeOnAuthentication`); local **BreezeOn-LOCAL**; hosted registration input **BreezeOn-DEV** (process **Step 6** when requested) |
| AuthZ | Page catalog + `IBoAuthorizationService` (empty `RequiredGroupCodes`); Application Context Bootstrap + INV AttributeCode policy (`ADMIN` / `INITIATE` / `REPORT`; My Tasks = any authenticated) |
| App context | `AddBreezeOnApplicationAccess` with required AttributeCodes `ADMIN`/`INITIATE`/`REPORT` + `BoApplicationContextGate` |
| Local DB | `scripts/dev-reset.ps1` requires the sibling `SYSTEM-ADMIN-EAC` checkout and invokes its `scripts/dev-reset.ps1` as a subprocess (EAC owns drop/schema/bootstrap/import of INV `seed/eac/`), then launches INV; day-to-day relaunch is `scripts/dev-run.ps1` (non-destructive) — [`docs/local-database.md`](../../docs/local-database.md) · [`docs/local-development-scripts.md`](../../docs/local-development-scripts.md) |

## Related

- Process (worked example, not defaults): [`docs/ai/application-development-process.md`](../../docs/ai/application-development-process.md)
- Illustrative Step 1 instance: [`docs/ai/examples/application-definition.inv.json`](../../docs/ai/examples/application-definition.inv.json)
- EAC local configuration for INV: `breezeon-corp-fin-inv/seed/eac/` (imported by EAC `scripts/dev-reset.ps1`; not `SYSTEM-ADMIN-EAC/sql/seed/`) — [`docs/data-portability.md`](../../docs/data-portability.md) § Per-application `seed/eac`
- Landscape: [`../landscape.md`](../landscape.md)
