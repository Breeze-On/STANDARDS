<!-- Classification: AA; Scope: platform -->
# Application Configuration — Configuration Session Cache

Owner: Architecture / EAC

Circuit-scoped workspace cache for EAC Application Configuration. Decision: [ADR-020](../../decisions/ADR-020-configuration-session-cache.md). Product implementation: SYSTEM-ADMIN-EAC `EacConfigurationSession`.

## What exists

When the user selects **Application + Business Entity** on `/app-configuration`, the host opens an **Application Configuration Session** keyed by `(ApplicationGUID, ApplicationEnabledGUID)`.

- Modules **lazy-fill** named **baseline** segments on first access.
- Subsequent navigation within the same session **consumes** warm segments (no backend reload, no Page Freeze).
- Tabs own **working copies**; Dirty State remains the single-active-workspace guard (`EacDirtyStateGuard`).
- Session **rebuilds** on selection change, reset, Import sync apply, auth/permission loss, route leave / circuit drop.

This is **not** Redis, ASP.NET session, `IMemoryCache`, or a SHARED-UI domain cache.

## Segment classification (current)

| Classification | Examples |
| --- | --- |
| Cache Always | PF Roles / Steps / Options rows; PF metadata columns; Security Group definitions; Data Entity definitions; Data Entity Settings columns (per visited entity); **Variables definitions** (`variables-definitions`); **Variables values** for the session context (`variables-values:{ApplicationEnabledGUID}`) — current implemented behavior; CanManage flags; **Translations enabled languages** (`translations-languages:{ApplicationEnabledGUID}`) |
| Cache Conditionally | People-picker label map; VisibleContexts (page-level) |
| Never Cache | Data Entity Values pages / Changesets; Security Group member lists; Import/Export envelopes; locale strings; **Translations grid rows / Changesets / Excel envelopes** |

Shipped App Configuration modules represented above: Data Entities, Process Framework, Variables, Security Groups, Translations.

## Invalidation (summary)

| Action | Effect |
| --- | --- |
| Application or Business Entity selected / Reset | Full session rebuild (Open with new key / Close) |
| Import sync apply | `Rebuild()` then module refresh |
| Export | No refresh |
| Catalog Save | Partial — update that segment baseline (+ dependents) |
| Catalog Discard | None — restore working copy from baseline |
| PF Settings Save | Update metadata baseline; invalidate PF entity segments |
| Variables definitions / values Save | Update `variables-definitions` / `variables-values:{guid}` baselines; **invalidate** `translations-languages:{guid}` (stats depend on Variable TEXT) |
| PF Settings / entity Save (metadata values, labels) | Update PF baselines; **invalidate** `translations-languages:{guid}` |
| Data Entity Values Save | Never Cache values; **invalidate** `translations-languages:{guid}` (DE row Description stats) |
| Translations language add/reorder/delete | Invalidate `translations-languages:{guid}` (+ dependents when purge affects PF/Variables) |
| Translations Value Save / Excel import apply | Invalidate translation dependents (Variables values, PF metadata/entity segments, languages stats) |
| Warm tab / card navigation | None |
| Page refresh / new circuit | New session |

Full matrix: EAC plan history / product behavior must stay aligned with this document when modules change.

## Dirty State

- Baseline ownership: session segments
- Working copy ownership: active tab / workspace
- Save → persist → `SetBaseline` from response → clear dirty
- Discard (catalogs) → clone baseline → working copy (no server round-trip when warm)
- Discard (Values) → clear Changeset + reload server page (Never Cache)

## Page Freeze

| Situation | Freeze |
| --- | --- |
| Cold segment hydrate | MUST |
| Save / import / export / sync | MUST |
| Warm tab/card navigation | MUST NOT |
| Discard from warm baseline | MUST NOT |

## Configuration Session Review (mandatory)

For every future **configuration-heavy** BreezeOn application or module, Planning Agents **must** complete a Configuration Session Review before implementation — peer to Dirty State and Page Freeze. Document:

- Session Key · Session Lifetime · Cache Segments
- Cache Classification (Always / Conditionally / Never)
- Working Copy vs Baseline ownership · Dirty State interaction
- Cache Invalidation Matrix
- Save · Discard · Import · Export behavior
- Page Freeze interaction · Session rebuild events

Governing question: **What should be cached, what should not be cached, and when must cache be invalidated?**

Outcome may be “no session cache” only when the matrix and Never Cache rationale are documented. Skipping the review is non-compliant.

SSOT for agent gates: [planning-and-development-agents.md](../../docs/ai/planning-and-development-agents.md).

## Related

- [app-configuration README](README.md)
- [dirty-state.md](../../docs/ui/patterns/dirty-state.md)
- [overlays.md](../../docs/ui/shell/overlays.md) (Page Freeze)
- [ADR-008](../../decisions/ADR-008-query-driven-data-retrieval.md) (Values Never Cache)
