# Architecture — Security

Owner: Architecture

Current-state security posture for implemented Breeze On applications.

## ADM authentication

| | |
| --- | --- |
| Mechanism | ASP.NET Core Identity |
| App | ADM (`SYSTEM-ADMIN-ADM` / `BreezeOn.Adm`) |
| User store (local) | SQL Server Docker database `BreezeOnLocal` (`AspNet*` tables) |
| User store (DV) | Azure SQL database `BreezeOnDV` (`AspNet*` tables) |
| Capabilities in use | Register, login, logout, account manage flows from the Identity UI |
| Email confirmation | Not required in current DV configuration (`RequireConfirmedAccount = false`) |

## Authorization (current)

- Dashboard requires an authenticated user (`[Authorize]`).
- Home and account/login/register routes follow the Identity + Blazor layout shipped in ADM.

## Local SQL access

| Principal | How |
| --- | --- |
| Developer / app (Development) | SQL authentication (`sa`) against `localhost,1433` / `BreezeOnLocal` |
| Password source | Gitignored `.env` (`MSSQL_SA_PASSWORD`) and/or User Secrets `LocalSql:SaPassword` |

Local SQL passwords must never be committed or used against Azure SQL. See [local-database.md](../docs/local-database.md).

## Azure SQL access (DV)

| Principal | How |
| --- | --- |
| Operators (e.g. Entra admin) | Microsoft Entra / Azure CLI token; used for scripts and optional Entra Default overrides |
| App Service `breezeon-system-admin-adm-dv` | System-assigned Managed Identity mapped as SQL user `breezeon-system-admin-adm-dv` with `db_datareader`, `db_datawriter`, `db_ddladmin` |

Connection strings do not embed SQL passwords for the hosted app. Do not commit production secrets.

## Secrets and local data

- Do not commit credentials or production secrets (including `.env`).
- App Service stores `DefaultConnection` as a connection string setting (Managed Identity auth).
- Local Development defaults to Docker SQL with password substitution (`__FROM_ENV__` → `LocalSql:SaPassword` or `MSSQL_SA_PASSWORD`).

## Scope note

This document describes only what is implemented today. Cross-app SSO and Microsoft Entra External ID for end users are not implemented.

Organization-wide **security governance** standards (secret management policy, vulnerability management, etc.) are **not yet formally defined**. See the placeholder [`docs/security-governance.md`](../docs/security-governance.md). Do not confuse that placeholder with this architecture document.
