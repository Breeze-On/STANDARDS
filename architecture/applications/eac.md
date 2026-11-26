<!-- Classification: AA; Scope: application:eac; Domain: Platform; Capability: Applications -->
# Architecture — EAC

Owner: Architecture

Current-state description of the Enterprise Administration Center application.

## Identity

| | |
| --- | --- |
| Name | EAC (Enterprise Administration Center) |
| Repository | [Breeze-On/SYSTEM-ADMIN-EAC](https://github.com/Breeze-On/SYSTEM-ADMIN-EAC) |
| Project | `src/BreezeOn.Eac` |
| Namespace | `BreezeOn.Eac` |

## Responsibility

EAC is the centralized application for:

- System configuration
- Business drop-down (DDL) values / **Data Entities** (configurable master / reference data — [data-entities](../data-entities/README.md), [ADR-016](../../decisions/ADR-016-data-entity-ownership.md))
- Application **Process Framework** metadata — Roles / Steps / Options configuration ([process-framework](../process-framework/README.md), [ADR-019](../../decisions/ADR-019-process-framework-metadata.md))
- Security access
- Role assignments
- Application registry (`System` schema)

It is the configuration and access hub for the Breeze On ecosystem.

## Implementation (current)

| Area | State |
| --- | --- |
| UI framework | Blazor Web App, Interactive Server (global interactivity) |
| Runtime | ASP.NET Core / C# / .NET 10 (App Service stack: `DOTNETCORE|10.0`) |
| Shared UI | ProjectReference to `SYSTEM-SHARED-UI` / `BreezeOn.UI` (`Bo*` only; [ADR-004](../../decisions/ADR-004-breezeon-ui-abstraction-layer.md)) |
| Auth | Entra OIDC + cookies via SYSTEM-SHARED-UI; platform `Identity.*` + `Security.*` in the customer database; page security via `IBoAuthorizationService` + EAC page catalog. Object-owned admin groups and capabilities: [ADR-015](../../decisions/ADR-015-object-owned-administrator-groups.md), [eac-authorization-matrix.md](../applications/eac-authorization-matrix.md). Schema: [security-schema-standard.md](../authorization/security-schema-standard.md). See [Identity & Authentication](../identity-and-authentication/README.md) and [Authorization](../authorization/README.md). |
| Surfaces | `BoAppShell` + left nav; Home (`BoNavHub`); Applications (NestedView + enablement child grid; JSON I/O); Business Entities (Hierarchy + Entity Types; JSON I/O); **Users Security** (`/users`: Users + Groups; Users Action **View Group Memberships** → `GetGroupsForUserAsync`); **App Configuration** (`/app-configuration`: grant-driven `VisibleContexts`; zero contexts → standard `BoAccessDenied`; otherwise Application + Business Entity selection (Application Selection collapsible; default Expanded on page load only — preserved across Configuration tab changes per [sections.md](../../docs/ui/layout/sections.md#default-expand-vs-in-page-navigation-locked)), section-scoped Configuration tabs; **Data Entities** tab = collapsible Quick Actions (command cards aligned with nav ecosystem: New + Edit Data Entities + **Excel Tool**; Edit/Excel Tool enabled when count>=1; smart default Expanded when entity count is 0 else Collapsed; expand state preserved across dialogs) + Navigation (`BoPanelNavigation`, Description-preferred labels) + create dialog + Edit Data Entities dialog (GUID RO, Code/Description edit, handle DnD, staged delete; `P_POST_EACDataEntitiesSave` — the only UI reorder path; Change Order Quick Action removed) + Excel Tool (Values `.xlsx` import/export; [ADR-018](../../decisions/ADR-018-data-entity-values-excel-portability.md)) + Actions (`EacSaveDiscardActions` + presentation-only `BoToggle`) + Values (Server QueryMode + Changeset) / Settings (column working copy; Delete Column confirm); Dirty State via `EacDirtyStateGuard`; create dialog uses `BoDialog` with `InitialFocusFieldKey=Code`; **Process Framework** tab (Application-scoped; `BoPanelNavigation` Roles / Steps / Options, each with an Entity \| Settings `BoToggle`; entity mode = `BoShuffleCardGrid` Save/Discard with fixed fields + dynamic metadata columns; Settings mode = one shared metadata-column catalog workspace; no Manage Members, no separate import/export; PEOPLEPICKER metadata binds `UserGUID` in the UI and persists `ExternalObjectId`); Configuration tabs: **Data Entities**, **Process Framework**, **Variables**, **Security Groups**, **Translations**. Import/Export JSON promotes Application Configuration State (synchronize-by-Code; section participation) — SSOT: [application-configuration-deployment.md](../app-configuration/application-configuration-deployment.md) · [data-portability.md](../../docs/data-portability.md) § Application Configuration JSON. Who can do what: [eac-authorization-matrix.md](eac-authorization-matrix.md). |
| Application Context | `System.EACApplicationsEnabled` — `ApplicationEnabledGUID` owns entity-specific configuration; exclusivity on `(ApplicationGUID, BusinessEntityGUID)`; centralized hard-delete workflow ([ADR-006](../../decisions/ADR-006-application-context-ownership.md)). App Configuration requires ≥1 visible context from a grant-driven `VisibleContexts` projection (Application / BE+descendants / APPENA union) — not Applications/BE page RLS; empty projection uses Access Denied (context visibility, not route denial). |
| Configuration Session Cache | Circuit-scoped `EacConfigurationSession` baselines for App Configuration modules after Application + Business Entity selection; lazy segments; Values Never Cache; warm nav without freeze ([ADR-020](../../decisions/ADR-020-configuration-session-cache.md) · [configuration-session-cache.md](../app-configuration/configuration-session-cache.md)). |
| Localization | EAC `EacResources.resx` / `EacResources.fr.resx` via `IEacLocalizer` (not Gallery `BoUi`) |
| Data access | EF Core + SQL Server provider (`ApplicationDbContext` + empty `InitialBaseline` for `__EFMigrationsHistory`; business schema via SQL scripts; audit stamps via `IAuditActorProvider` → authenticated actor (UPN/oid)) |
| SQL scripts | Platform Identity + Security from SHARED-UI `sql/identity/` + `sql/security/` + EAC `sql/current_model/` (`System` tables/procedures) |
| DB model doc | [`docs/db-model.md`](https://github.com/Breeze-On/SYSTEM-ADMIN-EAC/blob/main/docs/db-model.md) |
| Portability | Applications + Business Entity Types + Business Entities JSON (merge/upsert) + Application Configuration JSON (synchronize; includes Process Framework sections) — [data-portability.md](../../docs/data-portability.md) (EAC-owned; not a shared service) |
| Local database | SQL Server Docker (`BreezeOnLocal`); see [local-database.md](../../docs/local-database.md) |

## Application Configuration authorization boundary

App Configuration selector composition is not the authorization boundary. DataService reads **must enforce** the grant at the service boundary through the shared App Configuration authorization checks:

- Application-scoped reads require the Application to appear in `VisibleContexts`, or the actor to be an Application administrator / GSA.
- Application Context–scoped reads require the requested `ApplicationEnabledGUID` to appear in `VisibleContexts`, or the actor to administer the owning Application / be a GSA.
- Writes continue to require their operation-specific Application or Context management grant.

This prevents a caller-controlled Application or Application Enabled GUID from bypassing the page's filtered selectors. Platform rule: [authorization-standard.md](../authorization/authorization-standard.md#service-boundary-read-authorization).

## Application Configuration catalog retrieval

The following are approved [ADR-008](../../decisions/ADR-008-query-driven-data-retrieval.md) full-load exceptions:

- Process Framework **Roles / Steps / Options** load each catalog in full for the `BoShuffleCardGrid` working copy.
- **Variable Values** load all values for the selected Application Context into the client working copy.

These are relatively small-cardinality configuration catalogs. **No paging is required at this time.** Revisit the exceptions if catalog sizes materially exceed that operating envelope or stop being practical as a single-response, in-memory working set. **Business Entities → Business Hierarchy** remains the separate approved full-tree exception documented below.

## Applications: selection, import, export

Applications import/export is **owned by EAC** (`SYSTEM-ADMIN-EAC`). It is **not** a shared service. File format: [data-portability.md](../../docs/data-portability.md). Audit columns: [database.md](../../docs/database.md#mandatory-audit-columns) / [ADR-005](../../decisions/ADR-005-mandatory-transactional-audit-columns.md) (actor = logged-in user).

| Concern | Behavior |
| --- | --- |
| Grid selection | `BoGrid.EnableSelection` — compact unlabeled first column; select-all = all rows in **BoGrid cache**, not the database ([grids.md](../../docs/ui/controls/grids.md#row-selection)) |
| Import | Footer **Import from JSON** (GSA) → validate → upsert by `UniqueCode` with central admin-group provisioner on create → create missing Application Contexts from `BusinessEntitiesEnabled` → reload + toast |
| Export | Footer **Export JSON** (far right) → selected rows only → browser download (`ApplicationGUID` / audit omitted; `BusinessEntitiesEnabled` = Business Entity Codes) |
| Match rule | Found = update; not found = create. No rename detection / aliases / history |
| Rename example | DB `SYSTEM-ADMIN-EAC` + file `LEGACY-SYSTEM-ADMIN-EAC` → **creates** new application |
| Size limit | `ApplicationsImport:MaxFileSizeMb` (default 2); uploads never persisted |

## Applications: query-driven list

The Applications page has a **Filters** section and a **server-paged Nested View** (Server `QueryMode`; roots paged, Enabled Business Entities as children). The **primary retrieval contract** is `System.P_GET_EACApplicationsGrid` (`@UserGUID` authorization filter; rows, `TotalCount`, children, `GroupGUID`). Filter drop-down catalogs come from **EF Core FilterCatalog** (app services), not a companion FilterOptions procedure. Host concurrency uses **`BoLatestWinsQuery`** for grid queries and catalog loads. Select-all applies to the **current page** in cache only. Standard: [query-driven-retrieval.md](../../docs/ui/controls/query-driven-retrieval.md) · [ADR-008](../../decisions/ADR-008-query-driven-data-retrieval.md).

## Business Entities

Route `/business-entities` (legacy `/organisation-entities` redirects). Header tabs: **Business Hierarchy** (NestedView + cascade `SelectedNodeKeys`) then **Entity Types** (flat ReadOnly grid; non-GSA → Access Denied). Each tab has a **Filters** section with a single Keyword field (`BoTextField`, `Weight=1`, debounce 750ms / Enter / blur). Writes use `System.P_GET_*` / `P_POST_*` (hierarchy path, cycle checks, recursive delete + admin-group cleanup). Hierarchy create provisions `BUSENT_*` groups via `IEacAdminGroupProvisioner`. Portability kinds `breezeon.eac.business-entity-types` and `breezeon.eac.business-entities` — [data-portability.md](../../docs/data-portability.md). Size limit `BusinessEntitiesImport:MaxFileSizeMb` (default **10**).

**Business Hierarchy remains the approved full-load exception** to server-paged retrieval: the authorized forest is loaded (`P_GET_EACBusinessEntitiesHierarchy` with `@UserGUID`) — [ADR-008](../../decisions/ADR-008-query-driven-data-retrieval.md) exceptions framework. Forest visibility / `CanManage` / edit scope: [eac-authorization-matrix.md](../applications/eac-authorization-matrix.md) and [ADR-015](../../decisions/ADR-015-object-owned-administrator-groups.md). Keyword filtering on Hierarchy applies [Nested View keyword filtering](../../docs/ui/controls/grids.md#nested-view-keyword-filtering-org-standard) **client-side** via **`BoNestedViewKeywordFilter`** (Rules 1–2 + Rule 3 path-minimal `NestedExpandedSeedKeys` = ancestors of matches only); loads use **`BoLatestWinsQuery`**; do not force a paged Hierarchy SP. **Entity Types** Keyword filters the already-loaded catalog client-side, then existing client pagination (GSA only).

## Local development (current)

| Resource | Value |
| --- | --- |
| Engine | SQL Server 2022 container (`docker-compose.yml` in EAC repo) |
| Physical database | `BreezeOnLocal` |
| Auth | SQL `sa` (password via `.env` / `LocalSql:SaPassword` or `MSSQL_SA_PASSWORD`) |
| Init | `scripts/local-db-init.ps1` / `dev-reset` builds `generated/current-model.sql` from **allowlisted** `sql/current_model/` sources (`Get-EacCurrentModelScriptNames`) → one `sqlcmd`; consolidator fails on orphan/missing scripts; post-deploy required-object smoke ([database.md](../../docs/database.md) § EAC Framework Synchronization) |
| Seed | `scripts/local-db-seed.ps1` builds `generated/seed.sql` from `sql/seed/` (+ JSON→T-SQL) → one `sqlcmd` (required local fake data for EAC itself; keep in sync with schema) |
| Consumer app configuration | EAC `scripts/dev-reset.ps1` owns the destructive reset of the shared `BreezeOnLocal` database and imports each sibling consuming application's `seed/eac/` (portable JSON / xlsx). Consumer apps invoke EAC `scripts/dev-reset.ps1` as a subprocess; EAC does not hold other apps' configuration under `sql/seed/` — [data-portability.md](../../docs/data-portability.md) § Per-application `seed/eac` |

Routine local runs do **not** use Azure SQL. Org pattern: [local-database.md](../../docs/local-database.md). Human runbook and agent steps: EAC [`README.md`](https://github.com/Breeze-On/SYSTEM-ADMIN-EAC/blob/main/README.md) / [`README_AI.md`](https://github.com/Breeze-On/SYSTEM-ADMIN-EAC/blob/main/README_AI.md).

## DEV environment (current)

GitHub Environment name: **`DEV`**. Physical Azure resource names below reflect current reality.

| Resource | Value |
| --- | --- |
| Resource group | `RG-BREEZEON-DEV` |
| Azure SQL server | `sql-breezeon-dev.database.windows.net` |
| Azure SQL database | `BreezeOnDV` (legacy physical name; convention for new DBs is `{Logical}Dev`) |
| App Service | `breezeon-system-admin-eac-dev` (Linux Free F1) |
| App Service plan | `asp-breezeon-dev` |
| App Service DB auth | Managed Identity (`Authentication=Active Directory Managed Identity`) |

## Boundaries

- This application lives only in `SYSTEM-ADMIN-EAC`.
- Org-wide standards and cross-cutting architecture live in `Breeze-On/STANDARDS`, not duplicated here at length.
- Ecosystem map (repos, hosting, SQL, UI position): [landscape.md](landscape.md).
- Application expectations: [application-model.md](../../docs/application-model.md). Environments: [environments.md](../../docs/environments.md).
