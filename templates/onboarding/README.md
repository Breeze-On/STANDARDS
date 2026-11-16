# Onboarding operator templates

Owner: Operations

Operator aids for the [Customer Onboarding Master Flow](../../runbooks/customer-onboarding-master-flow.md). These are **not** product features and must not be applied as hosted product seed.

Typical run order after cutover steps: schema (Step 1) → tenant discovery / first login (Checkpoint E / Step 6) → **admin + sync-enable bootstrap** (Checkpoint G / Step 7) → **Sync Now** when Graph = Yes (Checkpoint F / Step 8).

## bootstrap-global-system-administrators.sql

**Master Flow Step 7 / Workflow G apply script.** Edit `@TenantAdminPairs` (`{entra-tid}|{admin-upn}` semicolon-separated; **≥1 admin per tenant**), apply to the customer database, then proceed to Sync Now (Step 8) when Graph = Yes. Detail: [customer-onboarding-authorization.md](../../architecture/authorization/customer-onboarding-authorization.md).

Same script body is maintained for EAC local bootstrap at `SYSTEM-ADMIN-EAC/sql/seed/BootstrapGlobalSystemAdministrators.sql`.

## validate-onboarding-readiness.sql

Run against the **customer** database (Azure SQL or local Docker) with a read-capable principal.

1. Set `@ExpectedTenantId` to the customer Entra tid (or leave NULL to skip tid match checks).
2. Set `@ExpectGraphSync = 1` when intake Graph = Yes; `0` when Graph = No (F-N/A).
3. Review each result set: schema presence, tenant counts, sync flags/status, GSA member count.

Interpret failures using the Master Flow failure catalog. Do not enable `IsSyncEnabled` or bootstrap admins from this script — it is validation only.

## Admin consent URL (copy-paste)

```text
https://login.microsoftonline.com/{customer-tid}/v2.0/adminconsent?client_id={application-client-id}&redirect_uri={url-encoded-redirect-uri}&scope=.default
```

Full guidance: Master Flow Step 5 and [customer-onboarding-authentication.md](../../architecture/identity-and-authentication/customer-onboarding-authentication.md) Workflow D.

## App Service configuration checklist

Confirm **every** product App Service in the customer-environment has the **same**:

| Setting | Expected |
| --- | --- |
| `AUTHENTICATION__AUTHORITY` | `https://login.microsoftonline.com/organizations/v2.0` |
| `AUTHENTICATION__CLIENTID` | Shared App Registration client ID |
| `AUTHENTICATION__CLIENTSECRET` | Shared client secret (presence only; value not logged — Master Flow secret handling) |

Confirm `IDENTITY__SEEDTENANTIDS` is **absent** on hosted App Services.

## Related

- [Customer Onboarding Master Flow](../../runbooks/customer-onboarding-master-flow.md)
- [hosted-deployment.md](../../docs/hosted-deployment.md)
