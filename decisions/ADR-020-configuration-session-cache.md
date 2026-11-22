<!-- Classification: DEC; Scope: platform; Domain: Platform; Capability: AppConfiguration -->
# ADR-020: Application Configuration Session Cache

Status: Accepted

## Context

EAC Application Configuration (`/app-configuration`) hosts multiple modules (Data Entities, Security Groups, Process Framework Roles / Steps / Options) behind a shared Application + Business Entity selection. KeepAlive keeps panels mounted, but modules historically reloaded catalogs on every activation (especially Process Framework), causing repeated Page Freeze, backend round-trips, and hydration cost.

Dirty State already matured from “do we need a guard?” to “what is the Dirty State model?” Configuration loading needed the same maturity: not ad hoc “cache or reload,” but a formal session model with classification and invalidation.

## Decision

### EAC-owned Configuration Session

Introduce a circuit-scoped **`EacConfigurationSession`** in SYSTEM-ADMIN-EAC (not SHARED-UI, not Redis / `IMemoryCache`). Session key = `(ApplicationGUID, ApplicationEnabledGUID)`. Host opens / rebuilds / closes the session; modules lazy-fill **baseline** segments and keep **working copies** locally.

### Lazy segments; never eager full hydrate

Segments fill on first need. Data Entity Values pages, Security Group member lists, and import/export envelopes are **Never Cache**. Process Framework entity catalogs, metadata columns, Security Group definitions, Data Entity definitions, and Settings column baselines are **Cache Always** (Settings per visited entity).

### Dirty State and Page Freeze

Session owns baselines; the active workspace owns the working copy; `EacDirtyStateGuard` remains single-registration. Save updates the baseline from the server response; Discard restores from the baseline when warm. Page Freeze applies to cold segment fills and writes; **warm navigation must not freeze**.

### Mandatory Configuration Session Review

Future configuration-heavy BreezeOn applications and modules **must** complete a Configuration Session Review (session key, lifetime, segments, Always/Conditional/Never classification, working copy vs baseline, Dirty State, invalidation matrix, Save/Discard/Import/Export, Page Freeze, rebuild events) before implementation. Outcome may be “no session cache” only with a documented matrix — skipping the review is non-compliant. SSOT: [configuration-session-cache.md](../architecture/app-configuration/configuration-session-cache.md) · [planning-and-development-agents.md](../docs/ai/planning-and-development-agents.md).

## Consequences

- Roles / Steps / Options load once per session key; subsequent card/tab navigation is session-backed without reload or freeze when warm.
- Import sync and selection changes rebuild the session (full invalidation).
- SHARED-UI remains domain-free; promote a generic primitive only if a second product needs it.
- Planning and Development agents treat Configuration Session Review as a peer gate to Dirty State and Page Freeze.

## Related

- [ADR-017](ADR-017-application-configuration-deployment.md) — Application Configuration deployment
- [ADR-019](ADR-019-process-framework-metadata.md) — Process Framework metadata
- [ADR-008](ADR-008-query-driven-data-retrieval.md) — Values remain server-paged (Never Cache)
- Architecture: [configuration-session-cache.md](../architecture/app-configuration/configuration-session-cache.md)
