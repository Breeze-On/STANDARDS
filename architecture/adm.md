# Architecture — ADM

Current-state description of the Administration application.

## Identity

| | |
| --- | --- |
| Name | ADM (Administration) |
| Repository | [Breeze-On/SYSTEM-ADMIN-ADM](https://github.com/Breeze-On/SYSTEM-ADMIN-ADM) |
| Project | `src/BreezeOn.Adm` |
| Namespace | `BreezeOn.Adm` |

## Responsibility

ADM is the centralized application for:

- System configuration
- Business drop-down (DDL) values
- Security access
- Role assignments

It is the configuration and access hub for the Breeze On ecosystem.

## Implementation (current)

| Area | State |
| --- | --- |
| UI framework | Blazor Web App, Interactive Server (global interactivity) |
| Runtime | ASP.NET Core / C# / .NET 9 |
| Auth | ASP.NET Core Identity (local SQLite for development) |
| Surfaces | Home (cards), Dashboard (authorized), left navigation, Identity account pages |

## Boundaries

- This application lives only in `SYSTEM-ADMIN-ADM`.
- Org-wide standards and cross-cutting architecture live in `Breeze-On/STANDARDS`, not duplicated here at length.
