# Naming standards

Current conventions across the organization.

## Organization

| Use | Form |
| --- | --- |
| Display name | **Breeze On** |
| GitHub org login | `Breeze-On` |
| Code / namespaces | `BreezeOn` (no space, no hyphen) |

## Repositories

- Org-owned repos under `Breeze-On/…`.
- Established repos:
  - `STANDARDS` — organization standards (`docs/`) and current architecture (`architecture/`)
  - `.github` — org profile README
  - `SYSTEM-ADMIN-ADM` — ADM application
  - `SYSTEM-SHARED-UI` — shared Blazor UI library (`BreezeOn.UI`)

## Applications (code)

| Application / library | Repo | Project / namespace |
| --- | --- | --- |
| ADM | `SYSTEM-ADMIN-ADM` | `BreezeOn.Adm` |
| Shared UI | `SYSTEM-SHARED-UI` | `BreezeOn.UI` |

## Documentation files

- `README.md` — humans
- `README_AI.md` — agents

Prefer clear, stable names. Do not rename established public identifiers without an explicit org decision.
