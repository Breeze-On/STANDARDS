# Customer onboarding — authorization (Workflow G)

Owner: Architecture / Operations

This is the **detailed procedure SSOT for Workflow G** (bootstrap system administrator). End-to-end sequence: **[Customer Onboarding Master Flow](../../runbooks/customer-onboarding-master-flow.md)** Step 8.

## Purpose

Grant the first `GLOBAL-SYSTEM-ADMINISTRATORS` membership so a named operator can use EAC Users Security (and Sync Now) under page security. The platform does **not** auto-promote the first interactive login.

## Responsible actor

**BreezeOn Admin / Platform Ops** (SQL bootstrap). After bootstrap, the **Customer Application Admin** manages ongoing group membership in EAC.

## Preconditions

- Authentication onboarding complete through first-login validation ([customer-onboarding-authentication.md](../identity-and-authentication/customer-onboarding-authentication.md) Workflows A–E; Master Flow Steps 2–6)
- If Graph sync was required at intake: Workflow F complete (or Sync Now already populated the admin user)
- Security schema + group seed applied (`Security.Groups` contains `Code = GLOBAL-SYSTEM-ADMINISTRATORS`)
- Target admin has an `Identity.Users` row (`UserGUID`) from first login or Sync Now

## Actions

1. Confirm `Security.Groups` contains `Code = GLOBAL-SYSTEM-ADMINISTRATORS`.
2. Identify the admin’s UPN/email (or Entra oid) that matches `Identity.Users`.
3. Run the SHARED-UI template script `sql/security/templates/bootstrap-global-system-administrator.sql` (set `@LookupUpn`), or equivalent idempotent SQL inserting `Security.GroupsMembers` by **`UserGUID`**.
4. Verify the admin can open EAC Users Security (`/users`) and run Sync Now (once page security is enabled).

Do **not** seed users or memberships into product seed by default for hosted environments. Do **not** auto-promote the first login. Later membership management is in-app (EAC).

## Expected outcome

| Check | Expectation |
| --- | --- |
| `Security.GroupsMembers` | Row linking admin `UserGUID` to `GLOBAL-SYSTEM-ADMINISTRATORS` |
| EAC `/users` | Named admin can open Users Security (not Access Denied) |
| Sync Now | Visible/runnable for that admin when Graph sync is in scope |

**Checkpoint G** (Master Flow).

## Failure scenarios and recovery

| Symptom | Likely cause | Recovery |
| --- | --- | --- |
| Bootstrap inserts 0 rows | UPN/oid does not match `Identity.Users` | Confirm user exists (login or Sync Now); fix `@LookupUpn` / UserGUID |
| Group missing | Security seed not applied | Apply SHARED-UI Security schema + seed (Master Flow Step 1) |
| Access Denied on `/users` | User not in GSA or wrong account | Re-check membership by `UserGUID`; sign in as the bootstrapped account |
| Temptation to auto-promote first login | Process shortcut | Rejected — always explicit Workflow G |

## Evidence to retain

- Bootstrap parameters used (UPN / UserGUID)
- Confirmation admin opened `/users`
- Optional: validation query admin-count section — [validate-onboarding-readiness.sql](../../templates/onboarding/validate-onboarding-readiness.sql)

## Local sandbox exception

EAC `local-db-seed` / `dev-reset` may run a **targeted** Graph UPN upsert (`BootstrapAdminUpns.json` via `UpsertUsersByPrincipalNamesAsync` — not full Sync Now) then grant `GLOBAL-SYSTEM-ADMINISTRATORS` (`sql/seed/BootstrapGlobalSystemAdministrators.sql`) after `IDENTITY__SEEDTENANTIDS` tenants are seeded. That path is **local-only** and must never be applied to hosted DEV/UAT/PRD by default.

## Related

- [Customer Onboarding Master Flow](../../runbooks/customer-onboarding-master-flow.md)
- [Customer authentication onboarding](../identity-and-authentication/customer-onboarding-authentication.md) (Workflows A–F)
- [Authorization standard](authorization-standard.md)
- [Security schema standard](security-schema-standard.md)
- [ADR-014](../../decisions/ADR-014-platform-authorization.md)
