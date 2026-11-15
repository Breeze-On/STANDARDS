# Customer onboarding — authorization (Workflow G)

Owner: Architecture / Operations

This is the **detailed procedure SSOT for Workflow G** (bootstrap system administrator). End-to-end sequence: **[Customer Onboarding Master Flow](../../runbooks/customer-onboarding-master-flow.md)** Step 7. Intake and go-live checklist live only on the Master Flow.

## Purpose

Grant the first `GLOBAL-SYSTEM-ADMINISTRATORS` membership so a named operator can use EAC Users Security (and Sync Now) under page security. The platform does **not** auto-promote the first interactive login — the operator explicitly bootstraps the **first logged-in** admin.

## Supported model

1. Designated customer admin completes interactive login (Workflow E / Master Flow Step 6) → `Identity.Users` + discovered `Identity.Tenants` row exist.
2. Operator runs Workflow G with `@LookupUpn` = that user’s `UserPrincipalName` (or Email) from `Identity.Users`.
3. Admin opens EAC `/users` (after re-login or ~60s authZ cache — below).
4. If Graph = Yes, admin runs Sync Now (Workflow F / Master Flow Step 8) — **after** this bootstrap.

## Responsible actor

**BreezeOn Admin / Platform Ops** (SQL bootstrap). After bootstrap, the **Customer Application Admin** manages ongoing group membership in EAC.

## Preconditions

- Authentication onboarding complete through first-login validation ([customer-onboarding-authentication.md](../identity-and-authentication/customer-onboarding-authentication.md) Workflows A–E; Master Flow Steps 2–6)
- Security schema + group seed applied (`Security.Groups` contains `Code = GLOBAL-SYSTEM-ADMINISTRATORS`)
- Target admin has an `Identity.Users` row (`UserGUID`) from **that** first login (not from Sync Now — Sync Now runs after Checkpoint G)

## Actions

1. Confirm `Security.Groups` contains `Code = GLOBAL-SYSTEM-ADMINISTRATORS`.
2. Identify the first logged-in admin’s `UserPrincipalName` or Email in `Identity.Users` (verify a single match).
3. Run the SHARED-UI template script `sql/security/templates/bootstrap-global-system-administrator.sql` (set `@LookupUpn`). The script resolves to `UserGUID` and inserts `Security.GroupsMembers` idempotently.
4. If the lookup would match **more than one** `Identity.Users` row (rare Email collision or multi-tenant logins), **stop** — do not guess. Insert membership by explicit `UserGUID` for the intended row (exceptional path only).
5. Verify the admin can open EAC Users Security (`/users`). Prefer **sign out / sign in** after bootstrap, or wait up to ~**60 seconds** for SHARED-UI authorization cache TTL (`SqlBoAuthorizationService.CacheTtl`). SQL bootstrap does not call in-app `InvalidateUser`.

Do **not** seed users or memberships into product seed by default for hosted environments. Do **not** auto-promote the first login. Later membership management is in-app (EAC).

## Expected outcome

| Check | Expectation |
| --- | --- |
| `Security.GroupsMembers` | Row linking admin `UserGUID` to `GLOBAL-SYSTEM-ADMINISTRATORS` |
| EAC `/users` | Named admin can open Users Security (not Access Denied) after re-login or cache expiry |
| Sync Now | Visible/runnable for that admin when Graph sync is in scope (Master Flow Step 8) |

**Checkpoint G** (Master Flow).

## Failure scenarios and recovery

| Symptom | Likely cause | Recovery |
| --- | --- | --- |
| Bootstrap inserts 0 rows / throws no match | UPN/Email does not match `Identity.Users` | Confirm user logged in once; fix `@LookupUpn` |
| Bootstrap throws multi-match | More than one `Identity.Users` row matches lookup | Stop; grant by explicit `UserGUID` for the intended tenant/user |
| Group missing | Security seed not applied | Apply SHARED-UI Security schema + seed (Master Flow Step 1) |
| Access Denied on `/users` immediately after bootstrap | AuthZ cache lag or wrong account | Re-login or wait ~60s; re-check membership by `UserGUID` |
| Temptation to auto-promote first login | Process shortcut | Rejected — always explicit Workflow G |

Wrong-member removal, re-bootstrap, and break-glass: Master Flow **Recovery appendix**.

## Evidence to retain

- Bootstrap `@LookupUpn` used; operator name + date
- Confirmation admin opened `/users`
- Optional: validation query admin-count section — [validate-onboarding-readiness.sql](../../templates/onboarding/validate-onboarding-readiness.sql)

## Local sandbox exception

EAC `local-db-seed` / `dev-reset` may run a **targeted** Graph UPN upsert (`BootstrapAdminUpns.json` via `UpsertUsersByPrincipalNamesAsync` — not full Sync Now) then grant `GLOBAL-SYSTEM-ADMINISTRATORS` (`sql/seed/BootstrapGlobalSystemAdministrators.sql`) after `IDENTITY__SEEDTENANTIDS` tenants are seeded. That path is **local-only** and must never be applied to hosted DEV/UAT/PRD by default.

## Related

- [Customer Onboarding Master Flow](../../runbooks/customer-onboarding-master-flow.md) (Step 7; intake + go-live SSOT)
- [Customer authentication onboarding](../identity-and-authentication/customer-onboarding-authentication.md) (Workflows A–F)
- [Authorization standard](authorization-standard.md)
- [Security schema standard](security-schema-standard.md)
- [ADR-014](../../decisions/ADR-014-platform-authorization.md)
