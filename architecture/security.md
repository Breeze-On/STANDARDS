# Architecture — Security

Current-state security posture for implemented Breeze On applications.

## ADM authentication

| | |
| --- | --- |
| Mechanism | ASP.NET Core Identity |
| App | ADM (`SYSTEM-ADMIN-ADM` / `BreezeOn.Adm`) |
| User store | Azure SQL database `BreezeOnDV` (`AspNet*` tables) |
| Capabilities in use | Register, login, logout, account manage flows from the Identity UI |
| Email confirmation | Not required in current DV configuration (`RequireConfirmedAccount = false`) |

## Authorization (current)

- Dashboard requires an authenticated user (`[Authorize]`).
- Home and account/login/register routes follow the Identity + Blazor layout shipped in ADM.

## Azure SQL access (DV)

| Principal | How |
| --- | --- |
| Operators (e.g. Entra admin) | Microsoft Entra / Azure CLI token; used for scripts and local `Active Directory Default` |
| App Service `breezeon-system-admin-adm-dv` | System-assigned Managed Identity mapped as SQL user `breezeon-system-admin-adm-dv` with `db_datareader`, `db_datawriter`, `db_ddladmin` |

Connection strings do not embed SQL passwords for the hosted app. Do not commit production secrets.

## Secrets and local data

- Do not commit credentials or production secrets.
- App Service stores `DefaultConnection` as a connection string setting (Managed Identity auth).
- Local development uses `appsettings.Development.json` with Entra Default auth (no password).

## Scope note

This document describes only what is implemented today. Cross-app SSO and Microsoft Entra External ID for end users are not implemented.
