# Cloud architecture — App Registration strategy

Owner: Architecture

## Customer environments

Approved hosting and identity binding:

- **One App Registration per customer-environment.**
- **One application deployment per customer-environment.**
- Each environment has its **own** authentication configuration (`AUTHENTICATION__AUTHORITY`, `AUTHENTICATION__CLIENTID`, `AUTHENTICATION__CLIENTSECRET`).

Illustrative naming:

| Example App Registration | Meaning |
| --- | --- |
| `CustomerA-EAC-DEV` | Customer A, EAC, DEV |
| `CustomerA-EAC-UAT` | Customer A, EAC, UAT |
| `CustomerA-EAC-PRD` | Customer A, EAC, PRD |
| `CustomerB-EAC-DEV` | Customer B, EAC, DEV |
| `CustomerB-EAC-UAT` | Customer B, EAC, UAT |
| `CustomerB-EAC-PRD` | Customer B, EAC, PRD |

BreezeOn owns the App Registration. Customer admin consent creates an Enterprise Application in the customer tenant.

Which home tenants may sign in (for example BreezeOn + Customer A) is configured **on the App Registration in Microsoft Entra**, not in application code. There is no `AUTHENTICATION__TENANTID` and no `Identity.AllowedTenants` table.

## Internal BreezeOn registrations

| App Registration | Purpose |
| --- | --- |
| `BreezeOn-LOCAL` | Shared local development for **all** BreezeOn applications |
| `BreezeOn-DEV` | BreezeOn-operated shared DEV when used |
| `BreezeOn-UAT` | BreezeOn-operated shared UAT when used |
| `BreezeOn-PRD` | BreezeOn-operated shared PRD when used |

Distinguish **customer-environment registrations** from **internal BreezeOn registrations**. Do not reuse a customer-environment ClientId for local development; use `BreezeOn-LOCAL`.

## Related

- [Configuration standard](configuration-standard.md)
- [Local development standard](local-development-standard.md)
- [ADR-011](../../decisions/ADR-011-app-registration-per-customer-environment.md)
