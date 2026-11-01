# Security governance

Owner: Engineering

Lightweight organization-wide standards for **dependency and vulnerability management** across Breeze On. Distinct from implemented security architecture:

| Document | Role |
|----------|------|
| [architecture/security.md](../architecture/security.md) | **Current reality** — how authentication, authorization, SQL access, and secrets are implemented today |
| **This file** | How we manage dependency vulnerabilities, advisories, and related supply-chain hygiene |

No approval boards, security committees, or mandatory paperwork. Prefer platform defaults (NuGet audit, GitHub Dependabot, GitHub Security alerts) over custom scanners.

---

## Purpose

- Give humans and AI agents **one** place for dependency vulnerability policy and remediation order.
- Keep product repositories thin: they link here and hold only repo automation (e.g. `.github/dependabot.yml`).
- Stay extensible so NPM, containers, and infrastructure can adopt the **same severity policy and triggers** later without redesign.

---

## Asset classes

| Asset class | Status | Primary finding sources |
| --- | --- | --- |
| NuGet packages | **In use** | NuGet audit (`NU19xx`), `dotnet list package --vulnerable`, Dependabot (nuget), GitHub Security advisories |
| GitHub Actions dependencies | **In use** | Dependabot (`github-actions`), action security advisories |
| NPM packages | Deferred | Same severity policy when an app adopts Node |
| Container images | Deferred | Same severity policy when images are built/published in CI |
| Infrastructure modules | Deferred | Same severity policy when IaC is checked into org repos |

When a deferred class is adopted, add its finding sources to this table in the **same change set** as the first real usage. Do not invent scanners before the stack exists.

---

## Sources of truth for findings

1. **NuGet audit** during restore/build (`NU1901`–`NU1904`).
2. **`dotnet list package --vulnerable --include-transitive`** for explicit verification.
3. **GitHub Dependabot alerts** and the repository **Security** tab.
4. **GitHub Advisory Database** (linked from NuGet/Dependabot).

Do not invent parallel vulnerability databases or enterprise SCA products for the current ecosystem size.

---

## Remediation order

Always follow this order:

1. **Upgrade the owning direct package** that introduced or pins the vulnerable version.
2. Else **upgrade the nearest upstream** package that pulls a patched transitive (preferred over pinning leaves).
3. Else add a **documented temporary pin** of the patched package (direct `PackageReference` or CPM entry) and note in the PR/commit when to remove it.
4. **Never suppress** advisories (`NoWarn` for `NU19xx`, audit ignore lists) without a written time-boxed exception in the PR/commit body (why, expiry, owner = maintainer).

Example (EAC): transitive `System.Security.Cryptography.Pkcs` via EF Core SqlServer → SqlClient was cleared by a direct `Microsoft.Data.SqlClient` servicing upgrade, not by removing Pkcs.

When bumping **`Microsoft.Data.SqlClient` to 7+** on a data-owning hosted app that uses Managed Identity / Entra auth, also add matching **`Microsoft.Data.SqlClient.Extensions.Azure`** and register `ActiveDirectoryAuthenticationProvider` before SQL open — see [hosted-deployment.md](hosted-deployment.md) and [architecture/security.md](../architecture/security.md). A SqlClient-only bump can crash App Service startup and burn Free F1 into **QuotaExceeded**.

---

## Repository expectations

Every Breeze On application and shared library that restores NuGet packages or runs GitHub Actions:

| Expectation | Detail |
| --- | --- |
| Dependabot | Enable version updates for `nuget` and `github-actions` (weekly). Copy [`templates/dependabot/dependabot.yml`](../templates/dependabot/dependabot.yml) into `.github/dependabot.yml`. |
| NuGet audit | Leave SDK audit enabled on restore. **Phase 1 (now):** treat `NU19xx` as visible warnings. **Phase 2:** set `NuGetAuditLevel` so **Critical/High** fail restore locally and in publish/deploy. Do **not** fail builds on Medium/Low. |
| Product docs | Thin pointer from `README_AI.md` / `AGENTS.md` to this document. Do not restate severity tables in product repos. |
| Verification | After High+ fixes: `dotnet list package --vulnerable --include-transitive` must report no vulnerable packages (or only documented exceptions). |

Optional later maturity (not required today): Central Package Management, `packages.lock.json`, deploy-step vulnerable-package gate after Phase 2.

---

## Vulnerability severity policy

Aligned to GitHub / NuGet severity. Times are calendar days for a solo-maintained platform.

| Severity | Development | Merge to main | Release / deploy (DEV+) | Production expectation |
| --- | --- | --- | --- | --- |
| **Critical** | Stop feature work that expands exposure; fix or pin same day when practical | **Blocked** until remediated or documented time-boxed exception | **Do not release** knowingly | Remediate immediately; redeploy after fix |
| **High** | Fix in the active working branch when discovered | **Blocked** for new merges that leave High unresolved in that repo | Prefer fix before deploy; documented exception ≤ **7 days** if exploitability is clearly out of reach | Clear within **7 days** or document residual risk |
| **Medium** | Track; bundle with nearby dependency work | Allowed with note if no easy fix | Allowed | Clear within **30 days** |
| **Low** | Opportunistic | Allowed | Allowed | Clear within **90 days** or next routine bump |

**Exploitability:** if the vulnerable API is not reachable from the app’s threat surface, still upgrade when a patch exists. Use SLAs for scheduling — not for ignoring NuGet audit forever.

**Exceptions:** short note in PR/commit (why, expiry, owner). No separate exception register.

---

## Trigger events

### Mandatory

- NuGet restore/build reports **NU1903** / **NU1904** (High / Critical), or `dotnet list package --vulnerable` is non-empty at High+.
- New Dependabot / Security alert at **Critical** or **High**.
- Before any hosted deploy that would ship a known High/Critical unresolved package (unless a documented exception applies).
- When adding or upgrading a **direct** package major version — re-run the vulnerable list.

### Recommended

- Weekly Dependabot PR triage (batch Low / Medium).
- After EF Core / ASP.NET / SqlClient / shared-framework bumps.
- When adopting a new asset class (first NPM app, first container image).

### Unnecessary (noise)

- Full SCA / SBOM gates on docs-only or content-only commits.
- CodeQL or container scanning before those stacks exist in the ecosystem.
- Failing CI on **Low** advisories.
- Custom vulnerability databases beyond NuGet + GitHub.

---

## CI/CD stance

Matched to current maturity (manual `workflow_dispatch` deploy; limited PR CI):

| Mechanism | Stance |
| --- | --- |
| GitHub Security / Dependabot alerts | Enable; treat Critical/High per severity policy |
| Dependabot version updates | Weekly `nuget` + `github-actions`; limit open PRs (~5) |
| Build warnings (`NU19xx`) | Visible now; Phase 2 fails Critical/High only |
| Build failures | Do not fail on Medium/Low; no enterprise SCA required |
| Deploy workflows | Keep simple; optional vulnerable-package check after Phase 2 |
| Actions versioning | Prefer major tags (`@v4`) unless pinning is required |
| Deferred | CodeQL, dependency-review Action, container scan, NPM audit — when those asset classes exist |

---

## Secrets and access (pointer)

Secret handling, Managed Identity SQL access, and auth implementation remain in [architecture/security.md](../architecture/security.md) and product runbooks. This document does not redefine those practices.

---

## Product vs STANDARDS

- **STANDARDS** owns this policy, remediation order, severity table, triggers, and the Dependabot template.
- **Product / library repos** own `.github/dependabot.yml`, package version pins in project files, and thin documentation links.

---

## Related

- [architecture/security.md](../architecture/security.md) — implemented security posture
- [engineering.md](engineering.md) — stack defaults
- [hosted-deployment.md](hosted-deployment.md) — deploy workflows
- [application-model.md](application-model.md) — repository shape
- [templates/dependabot/dependabot.yml](../templates/dependabot/dependabot.yml) — copy into product repos
