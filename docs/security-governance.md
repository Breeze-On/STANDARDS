<!-- Classification: AA; Scope: platform; Domain: Security; Capability: DependencyGovernance -->
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
3. Else add a **documented temporary pin** of the patched package (direct `PackageReference` or CPM entry) with owner, expiry, and reason next to the pin (see [Suppressions and temporary pins](#suppressions-and-temporary-pins)).
4. **Never suppress** advisories (`NoWarn` for `NU19xx`, `NuGetAuditSuppress`, audit ignore lists) without a greppable, time-boxed record (owner, expiry, reason) — see [Suppressions and temporary pins](#suppressions-and-temporary-pins).

Example (EAC): transitive `System.Security.Cryptography.Pkcs` via EF Core SqlServer → SqlClient was cleared by a direct `Microsoft.Data.SqlClient` servicing upgrade, not by removing Pkcs.

### SqlClient 7+ and `Extensions.Azure`

When bumping **`Microsoft.Data.SqlClient` to 7+** on a **data-owning hosted application** that uses Managed Identity / Entra auth, also add matching **`Microsoft.Data.SqlClient.Extensions.Azure`** and register `ActiveDirectoryAuthenticationProvider` before SQL open — see [hosted-deployment.md](hosted-deployment.md) and [architecture/security.md](../architecture/security.md). A SqlClient-only bump can crash App Service startup and burn Free F1 into **QuotaExceeded**.

**Applicability:** This MUST applies only to **data-owning applications** (for example EAC). It does **not** apply to the SHARED-UI Gallery host (or other non–data-owning hosts that reference SqlClient only as a library dependency).

### Dependency update-wave convention

Coordinate version movement without extra governance:

1. **Library first** (SYSTEM-SHARED-UI / shared packages)
2. **Then consumer applications** (SYSTEM-ADMIN-EAC and future hosts)
3. **Same upgrade wave** — bump the library, verify, then bump consumers in the same wave so Phase 2 / High+ posture does not diverge

Optional later maturity (not required today): Central Package Management, `packages.lock.json`.

---

## Repository expectations

Every Breeze On application and shared library that restores NuGet packages or runs GitHub Actions:

| Expectation | Detail |
| --- | --- |
| Dependabot | Enable version updates for `nuget` and `github-actions` (weekly). Start from [`templates/dependabot/dependabot.yml`](../templates/dependabot/dependabot.yml). **Templates are baselines** — product repos **may extend** with greppable ignores, pins, or supply-chain exceptions (owner + reason). Do **not** wipe documented product extensions when refreshing from the template without owner review. |
| NuGet audit | Leave SDK audit enabled on restore. See [Phase 1 and Phase 2](#phase-1-and-phase-2). |
| Product docs | Thin pointer from `README_AI.md` / `AGENTS.md` to this document. Do not restate severity tables in product repos. |
| Verification | After High+ fixes: `dotnet list package --vulnerable --include-transitive` must report no vulnerable packages (or only documented exceptions). |

### Repository conformance (current)

Repos expected to carry Dependabot and a thin pointer today:

| Repository | Role |
| --- | --- |
| `SYSTEM-ADMIN-EAC` | Data-owning application |
| `SYSTEM-SHARED-UI` | Shared UI library (+ Gallery host) |

STANDARDS is documentation-only (no NuGet restore / Actions deploy). Org profile (`.github`) has no package restore.

---

## Phase 1 and Phase 2

### Phase 1 (current default)

- `NU19xx` remain **visible warnings**.
- Merge / deploy obligations for Critical/High are **manual** (human remembers; no mechanical restore failure).
- Do **not** fail builds on Medium/Low.

### Phase 2 (optional, readiness-based)

Phase 2 is a **per-repository** decision. There is **no calendar-driven** enforcement. A repository may enter Phase 2 **only** when it is ready.

#### Entry criteria

All of the following must be true for **that repository**:

1. `dotnet list package --vulnerable --include-transitive` is clean at **High and Critical** (or only documented time-boxed exceptions).
2. Phase 2 MSBuild settings are prepared (see mechanism below).
3. The Platform Owner has explicitly approved the transition for that repository.

#### Approval authority

Only the **Platform Owner** may approve a repository’s Phase 2 transition.

#### Recording requirements

Record the decision in **this policy** (Phase 2 adoption table below) **or** in the approval PR body (repository, date, approver, verification command result). Do not flip settings silently.

#### Per-repository adoption

| Repository | Phase | Notes |
| --- | --- | --- |
| `SYSTEM-ADMIN-EAC` | **Phase 1** | Not approved for Phase 2 |
| `SYSTEM-SHARED-UI` | **Phase 1** | Not approved for Phase 2 |

Nobody should discover Phase 2 by breaking builds. Until a row says Phase 2, treat that repo as Phase 1.

#### Phase 2 technical mechanism

| Control | Role |
| --- | --- |
| `NuGetAuditLevel` | Controls **reporting** (minimum severity NuGet reports). Keep at `low` or `moderate` so **Medium** stays visible. |
| `WarningsAsErrors` | Controls **enforcement**. Add `NU1903` (High) and `NU1904` (Critical) so restore/build **fails** on High/Critical. |

Preferred model:

- **Medium** remains visible (warning; do not put `NU1902` in `WarningsAsErrors`)
- **High** fails (`NU1903`)
- **Critical** fails (`NU1904`)

Expected configuration location: repo-level `Directory.Build.props` (preferred) or each csproj. Example:

```xml
<PropertyGroup>
  <!-- Reporting: keep Medium visible. Do not set NuGetAuditLevel to high/critical. -->
  <NuGetAuditLevel>moderate</NuGetAuditLevel>
  <!-- Enforcement: High + Critical fail restore/build -->
  <WarningsAsErrors>$(WarningsAsErrors);NU1903;NU1904</WarningsAsErrors>
</PropertyGroup>
```

Do **not** claim that `NuGetAuditLevel` alone fails restore — it only filters what is reported.

---

## Vulnerability severity policy

Aligned to GitHub / NuGet severity. Times are calendar days for a solo-maintained platform.

**Enforcement reality:** Until a repository is on Phase 2, “Blocked” / “Do not release” below are **manual obligations** (developer / Platform Owner). They are **not** enforced by CI or deploy workflows. After Phase 2, High/Critical become **mechanical** via restore/`WarningsAsErrors` (NU1903/NU1904); no separate deploy-step vulnerability gate is required if `dotnet publish` already fails.

| Severity | Development | Merge to main | Release / deploy (DEV+) | Production expectation |
| --- | --- | --- | --- | --- |
| **Critical** | Stop feature work that expands exposure; fix or pin same day when practical | **Manual block** until remediated or documented time-boxed exception (mechanical after Phase 2) | **Do not release** knowingly (manual today; mechanical after Phase 2) | Remediate immediately; redeploy after fix |
| **High** | Fix in the active working branch when discovered | **Manual block** for new merges that leave High unresolved in that repo (mechanical after Phase 2) | Prefer fix before deploy; documented exception ≤ **7 days** if exploitability is clearly out of reach | Clear within **7 days** or document residual risk |
| **Medium** | Track; bundle with nearby dependency work | Allowed with note if no easy fix | Allowed | Clear within **30 days** |
| **Low** | Opportunistic | Allowed | Allowed | Clear within **90 days** or next routine bump |

**Exploitability:** if the vulnerable API is not reachable from the app’s threat surface, still upgrade when a patch exists. Use SLAs for scheduling — not for ignoring NuGet audit forever.

---

## Suppressions and temporary pins

No separate exception register. Every suppression or temporary pin must be **discoverable by repository search** and must record:

| Field | Required |
| --- | --- |
| **Owner** | Who owns removal (usually Platform Owner / maintainer) |
| **Expiry date** | When the exception must be revisited or removed |
| **Reason** | Why upgrade/pin was not used |

**Where to store:**

- Next to a temporary `PackageReference` pin: XML comment with Owner / Expiry / Reason.
- Next to `NuGetAuditSuppress`: XML comment with Owner / Expiry / Reason (and the advisory URL in the item).
- Dependabot `ignore` entries: treat as **version policy**, not security suppressions; the comment must name a **review trigger** (for example “until deliberate .NET / EF major upgrade”).

Example:

```xml
<!-- Owner: Platform Owner; Expiry: 2026-12-31; Reason: Graph SDK has not pulled Kiota >= 1.22.0 yet; remove pin when Graph bumps -->
<PackageReference Include="Microsoft.Kiota.Abstractions" Version="1.22.2" />
```

---

## Sibling shared-library consumption (ProjectReference)

Today, data-owning apps (EAC) consume SYSTEM-SHARED-UI via sibling `ProjectReference`. Deploy workflows may check out SHARED-UI for restore/publish.

**Current approach:** SHARED-UI checkout tracks the **default branch** (no ref/tag pin).

**Accepted rationale:** Platform Builder and Primary Consumer are effectively the same organization today; independent release-management overhead is not yet justified.

**Remediation ownership:** Transitive vulnerabilities introduced by the shared library are remediated in the **library repo first**; consuming apps then verify with `dotnet list package --vulnerable --include-transitive` **with the sibling checkout present**.

**Do not** introduce package distribution or release-management infrastructure at this time.

**Future Validation triggers** (revisit pinning / versioned artifacts when any of these occur):

- Application #2 exists as a SHARED-UI consumer
- Production environments exist
- SHARED-UI gains an independent release cadence

---

## Trigger events

### Mandatory

- NuGet restore/build reports **NU1903** / **NU1904** (High / Critical), or `dotnet list package --vulnerable` is non-empty at High+.
- New Dependabot / Security alert at **Critical** or **High**.
- Before any hosted deploy that would ship a known High/Critical unresolved package (unless a documented exception applies).
- When adding or upgrading a **direct** package major version — re-run the vulnerable list.

### Recommended

- Weekly Dependabot PR triage (batch Low / Medium).
- After EF Core / ASP.NET / SqlClient / shared-framework bumps — follow the [update-wave convention](#dependency-update-wave-convention).
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
| GitHub Security / Dependabot alerts | Enable; treat Critical/High per severity policy (**manual** until Phase 2) |
| Dependabot version updates | Weekly `nuget` + `github-actions`; limit open PRs (~5) |
| Build warnings (`NU19xx`) | Phase 1: visible. Phase 2: High/Critical fail via `WarningsAsErrors` (NU1903/NU1904); Medium stays a warning |
| Build failures | Do not fail on Medium/Low; no enterprise SCA required |
| Deploy workflows | Keep simple. Phase 1: no vulnerability gate step. Phase 2: restore/`dotnet publish` already fails on High/Critical — no extra gate required |
| Actions versioning | Prefer major tags (`@v4`) unless pinning is required |
| Deferred | CodeQL, dependency-review Action, container scan, NPM audit — when those asset classes exist |

---

## Secrets and access (pointer)

Secret handling, Managed Identity SQL access, and auth implementation remain in [architecture/security.md](../architecture/security.md) and product runbooks. This document does not redefine those practices.

---

## Product vs STANDARDS

- **STANDARDS** owns this policy, remediation order, severity table, Phase 2 readiness, triggers, and the Dependabot template.
- **Product / library repos** own `.github/dependabot.yml`, package version pins in project files, and thin documentation links.

---

## Related

- [architecture/security.md](../architecture/security.md) — implemented security posture
- [engineering.md](engineering.md) — stack defaults
- [hosted-deployment.md](hosted-deployment.md) — deploy workflows
- [application-model.md](application-model.md) — repository shape
- [templates/dependabot/dependabot.yml](../templates/dependabot/dependabot.yml) — copy into product repos
