# Naming standards

Owner: Documentation

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
  - `SYSTEM-ADMIN-EAC` — EAC application (Enterprise Administration Center)
  - `SYSTEM-SHARED-UI` — shared Blazor UI library (`BreezeOn.UI`)

## Applications (code)

| Application / library | Repo | Project / namespace |
| --- | --- | --- |
| EAC | `SYSTEM-ADMIN-EAC` | `BreezeOn.Eac` |
| Shared UI | `SYSTEM-SHARED-UI` | `BreezeOn.UI` |

## Application technical identifiers

| Concept | Rule | Examples |
| --- | --- | --- |
| Repository name | The application’s **technical identifier** in GitHub and in the EAC registry `UniqueCode` | `SYSTEM-ADMIN-EAC`, `SYSTEM-HR-HRM`, `SYSTEM-FINANCE-AP` |
| `UniqueCode` | Matches the repository name | same as above |
| `Code` | Short business identifier for the application | `EAC`, `HRM`, `AP` |
| `ApplicationGUID` | Immutable relationship key (see [database.md](database.md)) | generated GUID string |

Do not invent alternate technical ids that diverge from the repository name without an explicit org decision and STANDARDS update.

## Documentation files

- `README.md` — humans
- `README_AI.md` — agents

Prefer clear, stable names. Do not rename established public identifiers without an explicit org decision.

Shared vocabulary beyond naming forms: [glossary.md](glossary.md).
