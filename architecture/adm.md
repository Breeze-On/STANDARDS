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
| Runtime | ASP.NET Core / C# / .NET 10 (App Service stack: `DOTNETCORE|10.0`) |
| Auth | ASP.NET Core Identity on Azure SQL (`AspNet*` tables) |
| Surfaces | Home (cards), Dashboard (authorized), left navigation, Identity account pages |
| Data access | EF Core + SQL Server provider |
| SQL scripts | `sql/current_model/` (T-SQL): schema `SYSADM`, table `SYSADM.ADMApplications` |

## DV environment (current)

| Resource | Value |
| --- | --- |
| Resource group | `RG-BREEZEON-DEV` |
| Azure SQL server | `sql-breezeon-dev.database.windows.net` |
| Azure SQL database | `BreezeOnDV` |
| App Service | `breezeon-system-admin-adm-dv` (Linux, Free F1, stack .NET 10) |
| App Service plan | `asp-breezeon-dev` |
| Hostname | `breezeon-system-admin-adm-dv-e4gwcgd7aqdegvgx.canadaeast-01.azurewebsites.net` |
| Managed Identity | System-assigned; principal `0100ae8a-b5c1-4c4f-84e9-517db2e5815e` |
| Local / operator DB auth | Microsoft Entra (`Authentication=Active Directory Default`) |
| App Service DB auth | Managed Identity (`Authentication=Active Directory Managed Identity`) |

## Boundaries

- This application lives only in `SYSTEM-ADMIN-ADM`.
- Org-wide standards and cross-cutting architecture live in `Breeze-On/STANDARDS`, not duplicated here at length.
