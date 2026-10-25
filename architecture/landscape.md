# Architecture — Ecosystem landscape

Owner: Architecture

High-level map of the **implemented** Breeze On ecosystem: repositories, dependency position, hosting, and data relationships as they exist today.

Current-reality only. For org identity and the repository table, see [ecosystem.md](ecosystem.md). For ADM and security detail, see [adm.md](adm.md) and [security.md](security.md).

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
| [SYSTEM-ADMIN-ADM](https://github.com/Breeze-On/SYSTEM-ADMIN-ADM) | Application | ADM Blazor app, Identity, business schema, local SQL sandbox, DV deploy |
| [SYSTEM-SHARED-UI](https://github.com/Breeze-On/SYSTEM-SHARED-UI) | Shared library | `BreezeOn.UI` (`Bo*`) + local component gallery |

**Boundary rules in force today**

- One repository per application or shared concern ([ADR-001](../decisions/ADR-001-multi-repository-model.md)).
- Product repos stay thin and **link** to STANDARDS; they do not redefine org-wide rules.
- `SYSTEM-SHARED-UI` does not own ADM business domains, workflows, or databases.
- ADM does not own the design-system implementation.

```text
  STANDARDS  <---- link / follow ----  SYSTEM-ADMIN-ADM
      ^                                    |
      |                                    | (no Shared UI package reference today)
      +---- link / follow ----  SYSTEM-SHARED-UI
                                    |
                                    +-- gallery host consumes BreezeOn.UI
```

## UI dependency position (`BreezeOn.UI`)

Public UI contract: **`BreezeOn.UI`** in `SYSTEM-SHARED-UI` ([ADR-004](../decisions/ADR-004-breezeon-ui-abstraction-layer.md)). Fluent UI Blazor is an **internal** implementation detail of that library.

```text
  Product applications (when adopting the shared design system)
      ->  BreezeOn.UI   (public Bo* API)
          ->  Fluent UI Blazor  (internal)
```

| Consumer | Current state |
| --- | --- |
| `BreezeOn.UI.Gallery` (in SYSTEM-SHARED-UI) | Interactive Server host; consumes `BreezeOn.UI` locally |
| ADM (`SYSTEM-ADMIN-ADM`) | Blazor Interactive Server app with its own UI + Identity; **does not** reference `BreezeOn.UI` yet |

UI conventions: [`docs/ui/overview.md`](../docs/ui/overview.md).

## Azure hosting (implemented — ADM DV)

Only ADM has hosted DV infrastructure documented today.

```text
  GitHub Actions (manual DV deploy)
           |
           v
  Azure App Service
  breezeon-system-admin-adm-dv
  (Linux, Free F1, .NET 10)
  plan: asp-breezeon-dev
  RG: RG-BREEZEON-DEV
           |
           | Managed Identity
           v
  Azure SQL
  sql-breezeon-dev.database.windows.net
  database: BreezeOnDV
```

| Resource | Value |
| --- | --- |
| Resource group | `RG-BREEZEON-DEV` |
| App Service | `breezeon-system-admin-adm-dv` |
| App Service plan | `asp-breezeon-dev` |
| Azure SQL server | `sql-breezeon-dev.database.windows.net` |
| Azure SQL database | `BreezeOnDV` |
| App DB auth | System-assigned Managed Identity |

Shared UI is **not** hosted as a production web app; it is consumed as a library (gallery is local only).

Detail: [adm.md](adm.md), [environments.md](../docs/environments.md).

## Azure SQL and local SQL relationship

```text
  Local (default for routine development)
  -----------------------------------------
  Docker SQL Server  -->  physical DB BreezeOnLocal
  Auth: SQL sa (gitignored .env / User Secrets)
  Schema: sql/current_model/   Seed: sql/seed/ (local only)

  Hosted DV (ADM)
  -----------------------------------------
  Azure SQL BreezeOnDV
  App: Managed Identity
  Operators: Microsoft Entra (as documented)
```

| Concern | Local | DV (ADM) |
| --- | --- | --- |
| Engine | SQL Server in Docker | Azure SQL |
| Database | `BreezeOnLocal` | `BreezeOnDV` |
| App auth | SQL `sa` | Managed Identity |
| Seed scripts | Applied locally | Not default-applied to Azure SQL |

Decision record: [ADR-003](../decisions/ADR-003-azure-sql-with-local-docker-sql.md). Security: [security.md](security.md). Local pattern: [local-database.md](../docs/local-database.md).

## Application runtime (current)

| Surface | Runtime |
| --- | --- |
| ADM | Blazor Web App, Interactive Server, .NET 10 ([ADR-002](../decisions/ADR-002-blazor-interactive-server.md)) |
| Shared UI gallery | Same Interactive Server pattern; no database |

## Related architecture docs

| Document | Covers |
| --- | --- |
| [ecosystem.md](ecosystem.md) | Org identity and repository list |
| [adm.md](adm.md) | Administration application |
| [security.md](security.md) | Auth and access as implemented |
| [architecture/README.md](README.md) | Architecture index |
