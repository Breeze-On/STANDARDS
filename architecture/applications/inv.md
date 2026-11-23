<!-- Classification: AA; Scope: application:inv; Domain: Platform; Capability: Applications -->
# INV — Invoice Approval Request

Owner: Architecture

Current-reality description of **`breezeon-corp-fin-inv`** (UniqueCode `BREEZEON-CORP-FIN-INV`, Code `INV`).

## Role

Thin BreezeOn product host for invoice approval IA. Consumes `BreezeOn.UI` (AuthN, AuthZ, shell). Does **not** own EAC `System` schema.

## Implemented surfaces

| Surface | Behavior |
| --- | --- |
| Home | `BoNavHub` with cards: New Request, Status Report, My Tasks |
| `/new-request`, `/status-report`, `/my-tasks` | Empty `BoCard` (`MarginDensity=Content`); footer off |
| AuthN | Platform Entra OIDC (`AddBreezeOnAuthentication`); local **BreezeOn-LOCAL**; hosted registration input **BreezeOn-DEV** (process **Step 6** when requested) |
| AuthZ | Page catalog + shared Security; empty `RequiredGroupCodes` for current pages |
| Local DB | `scripts/dev-reset.ps1` applies SHARED-UI Identity + Security + GSA bootstrap |

## Related

- Process (worked example, not defaults): [`docs/ai/application-development-process.md`](../../docs/ai/application-development-process.md)
- Illustrative Step 1 instance: [`docs/ai/examples/application-definition.inv.json`](../../docs/ai/examples/application-definition.inv.json)
- EAC sample seed for INV (unchanged): `SYSTEM-ADMIN-EAC/sql/seed/`
- Landscape: [`../landscape.md`](../landscape.md)
