<!-- Classification: AA; Scope: platform; Domain: Platform; Capability: Applications -->
# Architecture — Ecosystem landscape

Owner: Architecture

High-level map of the **implemented** Breeze On ecosystem: repositories, dependency position, hosting, and data relationships as they exist today.

Current-reality only. For org identity and the repository table, see [ecosystem.md](ecosystem.md). For EAC and security detail, see [eac.md](eac.md) and [security.md](security.md).

## Organization

| | |
| --- | --- |
| Display name | Breeze On |
| GitHub org | [`Breeze-On`](https://github.com/Breeze-On) |
| Governance SSOT | [`standards`](https://github.com/Breeze-On/standards) (`docs/` · `architecture/` · `decisions/`) |
| Org profile | [`.github`](https://github.com/Breeze-On/.github) → `profile/README.md` |

```text
                    Breeze-On (GitHub org)
                              |
          +-------------------+-------------------+
          |                   |                   |
     standards            .github          Product / platform
   (SSOT: how we          (profile           repositories
    work, what exists,     README)
    why decisions)
```

## Repositories and boundaries (current)

| Repository | Kind | Owns |
| --- | --- | --- |
| [`standards`](https://github.com/Breeze-On/standards) | Org standards | Conventions, current architecture descriptions, ADRs |
| [.github](https://github.com/Breeze-On/.github) | Org profile | Vision / mission / ecosystem messaging only |
| [`breezeon-system-admin-eac`](https://github.com/Breeze-On/breezeon-system-admin-eac) | Application | EAC Blazor app (no ASP.NET Core Identity), business schema, local SQL sandbox, DEV deploy |
| [`breezeon-corp-fin-inv`](https://github.com/Breeze-On/breezeon-corp-fin-inv) | Application | INV (Invoice Approval Request) thin product host — AuthN/AuthZ + IA shell pages; UniqueCode `BREEZEON-CORP-FIN-INV` |
| [`breezeon-system-shared-ui`](https://github.com/Breeze-On/breezeon-system-shared-ui) | Shared library (mandatory for apps) | `BreezeOn.UI`: UI framework (`Bo*` / shell) + authentication framework + authorization framework + Identity schema definitions + Security schema definitions + local component gallery |
| [`breezeon-system-process-engine`](https://github.com/Breeze-On/breezeon-system-process-engine) | Shared library | `BreezeOn.ProcessEngine`: Process table resolution consumer, token/context, Process Metadata Framework (runtime), sequence allocation, Request Number formatting; counter SQL under `Global` |

**Boundary rules in force today**

- One repository per application or shared concern ([ADR-001](../decisions/ADR-001-multi-repository-model.md)). Repository names: [naming.md](../docs/naming.md) § Repositories.
- Product repos stay thin and **link** to `standards`; they do not redefine org-wide rules.
- `breezeon-system-shared-ui` does not own EAC business domains, workflows, or business databases. It **does** own platform Identity/Security SQL **definitions** and auth/authZ runtime; EAC-named reserved group Code prefixes (`APP_*` / `BUSENT_*` / `APPENA_*` / `APPSG_*`) live in SHARED-UI as collision defense / EAC naming on the shared schema ([ADR-014](../decisions/ADR-014-platform-authorization.md), [ADR-015](../decisions/ADR-015-object-owned-administrator-groups.md)).
- EAC does not own the design-system implementation.
- Schema **`Global`** container is **EAC-owned**; EAC also owns `Global.P_GET_ProcessTable`. Process Runtime objects (`Global.Process` / `ProcessHistory` / sequence counter + SPs) are **owned by Process Engine** and **deployed** by EAC local reset ([ADR-028](../decisions/ADR-028-process-runtime-ownership-process-engine.md)). Product apps (e.g. INV) own `{UniqueCode}.Process` **extension** tables only (including required Sequence\* columns) and consume platform `ProcessGUID` via PE services ([ADR-024](../decisions/ADR-024-platform-process-root.md) · [process-runtime](process-runtime/README.md)).
- Process Engine is consumed via sibling **`ProjectReference`** (interim, same model as SHARED-UI) — [ADR-026](../decisions/ADR-026-process-engine-and-metadata-framework.md) · [process-engine](process-engine/README.md). PE is **not** a workflow engine in Current Implementation.

```text
  standards  <---- link / follow ----  breezeon-system-admin-eac
      ^                                    |
      |                                    | ProjectReference → BreezeOn.UI
      +---- link / follow ----  breezeon-system-shared-ui
      |                                    |
      +---- link / follow ----  breezeon-system-process-engine
                                    |
                                    +-- ProjectReference → BreezeOn.ProcessEngine (product apps)
```

## UI dependency position (`BreezeOn.UI`)

Public UI contract: **`BreezeOn.UI`** in `breezeon-system-shared-ui` ([ADR-004](../decisions/ADR-004-breezeon-ui-abstraction-layer.md)). Fluent UI Blazor is an **internal** implementation detail of that library.

```text
  Product applications
      ->  BreezeOn.UI   (public Bo* API)
          ->  Fluent UI Blazor  (internal)
```

| Consumer | Current state |
| --- | --- |
| `BreezeOn.UI.Gallery` (in `breezeon-system-shared-ui`) | Interactive Server host; consumes `BreezeOn.UI` locally |
| EAC (`breezeon-system-admin-eac`) | Blazor Interactive Server; **ProjectReference** to `BreezeOn.UI` (`BoAppShell` shell, Home `BoNavHub`, Applications `BoGrid` + JSON import/export, Business Entities NestedView + types tabs, other destination shells); **no** ASP.NET Core Identity |
| INV (`breezeon-corp-fin-inv`) | Blazor Interactive Server; **ProjectReference** to `BreezeOn.UI` (`BoAppShell`, Home `BoNavHub`, empty Content Card destinations); platform AuthN/AuthZ; **no** ASP.NET Core Identity |

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
           +---> INV App Service
           |     breezeon-corp-fin-inv-dev
           |     (Linux, .NET 10)
           |     RG: RG-BREEZEON-DEV
           |            |
           |            | Managed Identity (grant when SQL quota allows)
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
| INV App Service | `breezeon-corp-fin-inv-dev` |
| Gallery App Service | `breezeon-system-shared-ui-dev` |
| App Service plan (EAC) | `asp-breezeon-dev` |
| Azure SQL server | `sql-breezeon-dev.database.windows.net` |
| Azure SQL database (shared DEV catalog) | `BreezeOnDV` |
| EAC / INV App DB auth | System-assigned Managed Identity |

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
| [process-runtime/README.md](process-runtime/README.md) | Two-tier Process runtime (`Global.Process`) |
| [process-engine/README.md](process-engine/README.md) | Process Engine shared library (Current Implementation vs Future Direction) |
| [process-metadata/README.md](process-metadata/README.md) | Runtime Process Metadata Framework (disambiguate ADR-019) |
| [security.md](security.md) | Auth and access as implemented |
| [architecture/README.md](README.md) | Architecture index |
