# Customer onboarding — authorization (Workflow G)

Owner: Architecture / Operations

Prerequisites: authentication onboarding complete ([customer-onboarding-authentication.md](../identity-and-authentication/customer-onboarding-authentication.md)); Security schema + group seed applied; target admin has an `Identity.Users` row (`UserGUID`) from first login or Sync Now.

## Workflow G — Bootstrap system administrator

1. Confirm `Security.Groups` contains `Code = GLOBAL-SYSTEM-ADMINISTRATORS`.
2. Identify the admin’s UPN/email (or Entra oid) that matches `Identity.Users`.
3. Run the SHARED-UI template script `sql/security/templates/bootstrap-global-system-administrator.sql` (set `@LookupUpn`), or equivalent idempotent SQL inserting `Security.GroupsMembers` by **`UserGUID`**.
4. Verify the admin can open EAC Users Security and run Sync Now (once page security is enabled).

Do **not** seed users or memberships into product seed by default for hosted environments. Do **not** auto-promote the first login. Later membership management is in-app (EAC).

**Local sandbox exception:** EAC `local-db-seed` / `dev-reset` may run Graph Sync Now then grant `GLOBAL-SYSTEM-ADMINISTRATORS` to documented local bootstrap UPNs (`sql/seed/BootstrapGlobalSystemAdministrators.sql`) after `IDENTITY__SEEDTENANTIDS` tenants are seeded. That path is local-only and must never be applied to hosted DEV/UAT/PRD by default.
