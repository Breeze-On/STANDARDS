# Customer onboarding — authorization (Workflow G)

Owner: Architecture / Operations

This is the **detailed procedure SSOT for Workflow G** (bootstrap system administrators + sync-enable tenants). End-to-end sequence: **[Customer Onboarding Master Flow](../../runbooks/customer-onboarding-master-flow.md)** Step 7. Intake and go-live checklist live only on the Master Flow.

## Purpose

Ensure each customer Entra tid is sync-enabled and grant `GLOBAL-SYSTEM-ADMINISTRATORS` to **at least one admin UPN per tenant** so operators can use EAC Users Security and run **Sync Now**. The platform does **not** auto-promote the first interactive login — the operator explicitly runs the Step 7 bootstrap script.

## Supported model

1. Each designated admin completes interactive login (Workflow E / Master Flow Step 6) → `Identity.Users` (+ discovered `Identity.Tenants` row) exist.
2. Operator applies [bootstrap-global-system-administrators.sql](../../templates/onboarding/bootstrap-global-system-administrators.sql) with `@TenantAdminPairs` = semicolon-separated `{entra-tid}|{admin-upn}` (**≥1 admin per distinct tenant**).
3. Script upserts `Identity.Tenants` with `IsSyncEnabled = 1`, creates `GLOBAL-SYSTEM-ADMINISTRATORS` if missing, and grants membership for each distinct UPN.
4. Admin opens EAC `/users` (after re-login or ~60s authZ cache — below).
5. If Graph = Yes, admin runs **Sync Now** (Workflow F / Master Flow Step 8) — **immediately after** Checkpoint G.

## Responsible actor

**BreezeOn Admin / Platform Ops** (SQL bootstrap). After bootstrap, the **Customer Application Admin** manages ongoing group membership in EAC.

## Preconditions

- Authentication onboarding complete through first-login validation ([customer-onboarding-authentication.md](../identity-and-authentication/customer-onboarding-authentication.md) Workflows A–E; Master Flow Steps 2–6) for **each** bootstrap admin UPN
- Security schema applied (`Security.Groups` / `GroupsMembers` exist). The Workflow G bootstrap script creates `Code = GLOBAL-SYSTEM-ADMINISTRATORS` if missing (same row as Security seed).
- Each listed admin has an `Identity.Users` row (`UserGUID`) from that first login (not from Sync Now — Sync Now runs after Checkpoint G)

## Actions

1. Build `@TenantAdminPairs`: one `{entra-tid}|{admin-upn}` entry per grant; every distinct tid must appear with **at least one** admin UPN.
2. Apply [bootstrap-global-system-administrators.sql](../../templates/onboarding/bootstrap-global-system-administrators.sql) (EAC apply copy: `SYSTEM-ADMIN-EAC/sql/seed/BootstrapGlobalSystemAdministrators.sql`). Replace placeholders before hosted apply.
3. If an admin UPN would match **more than one** `Identity.Users` row (rare), **stop** — do not guess. Insert membership by explicit `UserGUID` for the intended row (exceptional path only).
4. Verify each admin can open EAC Users Security (`/users`). Prefer **sign out / sign in** after bootstrap, or wait up to ~**60 seconds** for SHARED-UI authorization cache TTL (`SqlBoAuthorizationService.CacheTtl`). SQL bootstrap does not call in-app `InvalidateUser`.
5. When Graph = Yes, proceed to Master Flow Step 8 and run **Sync Now** in EAC `/users`.

Do **not** seed users or memberships into product seed by default for hosted environments. Do **not** auto-promote the first login. Later membership management is in-app (EAC).

## Expected outcome

| Check | Expectation |
| --- | --- |
| `Identity.Tenants` | Each listed tid present with `IsSyncEnabled = 1` |
| `Security.GroupsMembers` | Each listed admin `UserGUID` linked to `GLOBAL-SYSTEM-ADMINISTRATORS` |
| EAC `/users` | Named admin(s) can open Users Security (not Access Denied) after re-login or cache expiry |
| Sync Now | Visible/runnable for those admins when Graph sync is in scope (Master Flow Step 8) |

**Checkpoint G** (Master Flow).

## Failure scenarios and recovery

| Symptom | Likely cause | Recovery |
| --- | --- | --- |
| Placeholder / empty pairs rejected | Sample `@TenantAdminPairs` not replaced | Edit `tid|upn` pairs; ≥1 admin per tenant |
| Bootstrap throws missing users | UPN not in `Identity.Users` | Complete Step 6 first login for that UPN; re-run |
| Group missing after bootstrap | Security schema missing or insert failed | Confirm Security schema applied; re-run Workflow G bootstrap |
| Access Denied on `/users` immediately after bootstrap | AuthZ cache lag or wrong account | Re-login or wait ~60s; re-check membership by `UserGUID` |
| Temptation to auto-promote first login | Process shortcut | Rejected — always explicit Workflow G |
| Sync Now before Step 7 | Admin not granted / tids not sync-enabled | Finish Step 7, then Step 8 |

Wrong-member removal, re-bootstrap, and break-glass: Master Flow **Recovery appendix**.

## Evidence to retain

- Bootstrap `@TenantAdminPairs` used (tids + UPNs); operator name + date
- Confirmation admin opened `/users`
- Optional: validation query admin-count section — [validate-onboarding-readiness.sql](../../templates/onboarding/validate-onboarding-readiness.sql)

## Local sandbox exception

EAC `local-db-seed` / `dev-reset` may run a **targeted** Graph UPN upsert (`BootstrapAdminUpns.json` via `UpsertUsersByPrincipalNamesAsync` — not full Sync Now) then apply `sql/seed/BootstrapGlobalSystemAdministrators.sql` with pairs injected from `IDENTITY__SEEDTENANTIDS` + those UPNs. That path is **local-only** and must never be applied to hosted DEV/UAT/PRD by default.

## Related

- [Customer Onboarding Master Flow](../../runbooks/customer-onboarding-master-flow.md) (Step 7; intake + go-live SSOT)
- [Operator script](../../templates/onboarding/bootstrap-global-system-administrators.sql)
- [Customer authentication onboarding](../identity-and-authentication/customer-onboarding-authentication.md) (Workflows A–F)
- [Authorization standard](authorization-standard.md)
- [Security schema standard](security-schema-standard.md)
- [ADR-014](../../decisions/ADR-014-platform-authorization.md)
