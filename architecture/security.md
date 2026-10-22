# Architecture — Security

Current-state security posture for implemented Breeze On applications.

## ADM authentication

| | |
| --- | --- |
| Mechanism | ASP.NET Core Identity |
| App | ADM (`SYSTEM-ADMIN-ADM` / `BreezeOn.Adm`) |
| Local store | SQLite (development) |
| Capabilities in use | Register, login, logout, account manage flows from the Identity UI |

## Authorization (current)

- Dashboard requires an authenticated user (`[Authorize]`).
- Home and account/login/register routes follow the Identity + Blazor layout shipped in ADM.

## Secrets and local data

- Do not commit credentials or production secrets.
- Local Identity database files are gitignored in ADM.

## Scope note

This document describes only what is implemented today in existing applications. It does not define unimplemented identity providers or cross-app SSO.
