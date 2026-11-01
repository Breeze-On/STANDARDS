# Architecture — Ecosystem landscape

Owner: Architecture

High-level map of the **implemented** Breeze On ecosystem: repositories, dependency position, hosting, and data relationships as they exist today.

Current-reality only. For org identity and the repository table, see [ecosystem.md](ecosystem.md). For EAC and security detail, see [eac.md](eac.md) and [security.md](security.md).

## Organization

| | |
| --- | --- |
| Display name | Breeze On |
| GitHub org | [`Breeze-On`](https://github.com/Breeze-On) |
| Governance SSOT | [`STANDARDS`](https://github.com/Breeze-On/STANDARDS) (`docs/` · `architecture/` · `decisions/`) |
| Org profile | [`.github`](https://github.com/Breeze-On/.github) → `profile/README.md` |

```text
                    Breeze-On (GitHub org)
                              |
          +-------------------+-------------------+
          |                   |                   |
     STANDARDS            .github          Product / platform
   (SSOT: how we          (profile           repositories
    work, what exists,     README)
    why decisions)
```

## Repositories and boundaries (current)

| Repository | Kind | Owns |
| --- | --- | --- |
| [STANDARDS](https://github.com/Breeze-On/STANDARDS) | Org standards | Conventions, current architecture descriptions, ADRs |
| [.github](https://github.com/Breeze-On/.github) | Org profile | Vision / mission / ecosystem messaging only |
| [SYSTEM-ADMIN-EAC](https://github.com/Breeze-On/SYSTEM-ADMIN-EAC) | Application | EAC Blazor app (no ASP.NET Core Identity), business schema, local SQL sandbox, DEV deploy |
| [SYSTEM-SHARED-UI](https://github.com/Breeze-On/SYSTEM-SHARED-UI) | Shared library | `BreezeOn.UI` (`Bo*`) + local component gallery |

**Boundary rules in force today**

- One repository per application or shared concern ([ADR-001](../decisions/ADR-001-multi-repository-model.md)).
- Product repos stay thin and **link** to STANDARDS; they do not redefine org-wide rules.
- `SYSTEM-SHARED-UI` does not own EAC business domains, workflows, or databases.
- EAC does not own the design-system implementation.

```text
  STANDARDS  <---- link / follow ----  SYSTEM-ADMIN-EAC
      ^                                    |
      |                                    | ProjectReference → BreezeOn.UI
      +---- link / follow ----  SYSTEM-SHARED-UI
                                    |
                                    +-- gallery host + EAC consume BreezeOn.UI
```

## UI dependency position (`BreezeOn.UI`)

Public UI contract: **`BreezeOn.UI`** in `SYSTEM-SHARED-UI` ([ADR-004](../decisions/ADR-004-breezeon-ui-abstraction-layer.md)). Fluent UI Blazor is an **internal** implementation detail of that library.

```text
  Product applications
      ->  BreezeOn.UI   (public Bo* API)
          ->  Fluent UI Blazor  (internal)
```

| Consumer | Current state |
| --- | --- |
| `BreezeOn.UI.Gallery` (in SYSTEM-SHARED-UI) | Interactive Server host; consumes `BreezeOn.UI` locally |
| EAC (`SYSTEM-ADMIN-EAC`) | Blazor Interactive Server; **ProjectReference** to `BreezeOn.UI` (`BoAppShell` shell, Home `BoNavHub`, Applications `BoGrid` + JSON import/export, Business Entities NestedView + types tabs, other destination shells); **no** ASP.NET Core Identity |

UI conventions: [`docs/ui/overview.md`](../docs/ui/overview.md).

## Azure hosting (implemented — DEV)

Hosted **DEV** infrastructure documented today (GitHub Environment name: **`DEV`**).

```text
  GitHub Actions (manual DEV deploy)
           |
           +---> EAC App Service
           |     breezeon-system-admin-eac-dev
           |     (Linux, Free F1, .NET 10)
           |     plan: asp-breezeon-dev
           |     RG: RG-BREEZEON-DEV
           |            |
           |            | Managed Identity
           |            v
           |     Azure SQL BreezeOnDV
           |
           +---> Shared UI Gallery App Service
                 breezeon-system-shared-ui-dev
                 (Linux, .NET 10; no database)
```

| Resource | Value |
| --- | --- |
| Resource group | `RG-BREEZEON-DEV` |
| EAC App Service | `breezeon-system-admin-eac-dev` |
| Gallery App Service | `breezeon-system-shared-ui-dev` |
| App Service plan (EAC) | `asp-breezeon-dev` |
| Azure SQL server | `sql-breezeon-dev.database.windows.net` |
| Azure SQL database (EAC) | `BreezeOnDV` |
| EAC App DB auth | System-assigned Managed Identity |

`BreezeOn.UI` remains a library consumed by product apps; the Gallery is also hosted on DEV for shared UI smoke.

Detail: [eac.md](eac.md), [environments.md](../docs/environments.md).

## Azure SQL and local SQL relationship

```text
  Local (default for routine development)
  -----------------------------------------
  Docker SQL Server  -->  physical DB BreezeOnLocal
  Auth: SQL sa (gitignored .env / User Secrets)
  Schema: sql/current_model/   Seed: sql/seed/ (local only)

  Hosted DEV (EAC)
  -----------------------------------------
  Azure SQL BreezeOnDV
  App: Managed Identity
  Operators: Microsoft Entra (as documented)
```

| Concern | Local | DEV (EAC) |
| --- | --- | --- |
| Engine | SQL Server in Docker | Azure SQL |
| Database | `BreezeOnLocal` | `BreezeOnDV` |
| App auth | SQL `sa` | Managed Identity |
| Seed scripts | Applied locally | Not default-applied to Azure SQL |

Decision record: [ADR-003](../decisions/ADR-003-azure-sql-with-local-docker-sql.md). Security: [security.md](security.md). Local pattern: [local-database.md](../docs/local-database.md).

## Application runtime (current)

| Surface | Runtime |
| --- | --- |
| EAC | Blazor Web App, Interactive Server, .NET 10 ([ADR-002](../decisions/ADR-002-blazor-interactive-server.md)) |
| Shared UI gallery | Same Interactive Server pattern; no database |

## Related architecture docs

| Document | Covers |
| --- | --- |
| [ecosystem.md](ecosystem.md) | Org identity and repository list |
| [eac.md](eac.md) | Enterprise Administration Center |
| [security.md](security.md) | Auth and access as implemented |
| [architecture/README.md](README.md) | Architecture index |
