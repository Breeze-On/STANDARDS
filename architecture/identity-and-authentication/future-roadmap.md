# Future roadmap — Identity & Authentication

Owner: Architecture

## Planned / not shipped

The following are **not** part of the current platform implementation. Headings reserve structure only; do not treat as available APIs or product behaviour.

| Topic | Notes |
| --- | --- |
| Microsoft Graph directory synchronization | Future writer into `Identity.Users` (`LastSyncUtc`); typically **app-only** credentials — additive to cookie login |
| SCIM provisioning | Not designed |
| Role management / authorization beyond authenticated | Not designed |
| Entra group / claims mapping | Not designed |
| Certificate-based App Registration credentials | Not designed; secrets remain current ([configuration-standard.md](configuration-standard.md)) |
| Microsoft.Identity.Web for delegated Graph | Optional future layer beside cookie auth; not required for Phase 1 |
| Key Vault for `AUTHENTICATION__*` | Would require a superseding ADR; App Service settings remain approved |
| Mid-session revocation / DB recheck of `IsEnabled` | Login-time gate only today; cookie remains valid until idle/absolute expiry ([session-management-standard.md](session-management-standard.md)) |
| External Data Protection key ring (Blob / Redis) | Needed only for slot-independent keys or non–App Service farms; would require a superseding ADR |
| Cross-app SSO productization | Shared Identity directory is **not** cross-app SSO. Separate product hosts keep separate cookies. Productized SSO beyond shared library reuse is not shipped |

When any item ships, update the relevant Identity & Authentication documents and ADR(s) in the **same change set**, and remove or narrow the corresponding row here.
