<!-- Classification: AA; Scope: platform; Domain: UI; Capability: Patterns -->
# UI — Default initiation experience

Owner: UI

Default **New Request / process initiation** chrome for BreezeOn product applications. Related: [process-request-section.md](process-request-section.md), [page-footer-actions.md](page-footer-actions.md), [process-persistence.md](process-persistence.md), [process-view.md](process-view.md), [page-archetypes.md](page-archetypes.md), [shell.md](../shell/shell.md), [application-development-process.md](../../ai/application-development-process.md), **[application-bootstrap-checklist.md](../../application-bootstrap-checklist.md)** (New Application Checklist — initiation / footer rows).

These are **platform defaults**. Applications may override only when a plan **explicitly** documents a business requirement. New mandatory initiation requirements must be evaluated for the New Application Checklist in the same change set.

## Default composition (Tier 2 — STANDARD)

| Layer | Default |
| --- | --- |
| Page | New Request (and later open-process Detail/Edit initiation) |
| Header | Title + subtitle + **`BoAppHeader.TabsContent`** (`BoTabs`) |
| First tab | **General Information** |
| Tab icon | Fluent **Form**, `BoIconVariant.Regular` (outlined), Size 16 |
| First section | **Process Request** — [process-request-section.md](process-request-section.md) |
| Shell footer | **On** for initiation pages (`BoAppShell.ShowFooter`) |
| Footer commands | **`BoPageFooterActions`**: Save (`BoButtonVariant.Save`, icon Filled) then Submit (Primary) — [page-footer-actions.md](page-footer-actions.md). **Save renders only when** Process Framework step `00` includes option `va1`. Submit requires step `00` + option `va`. |
| After Save / Submit | Persist per [process-persistence.md](process-persistence.md) (includes Process History row), then navigate to **Process View** (terminal in v1) — [process-view.md](process-view.md) |
| Top Actions area | **Not** used for default initiation (workspace editors keep Actions Save\|Discard) |
| Comments (default) | Final tab **Additional Information** → section **Additional Information** → `BoTextArea` Comments (MaxLength 4000) — persisted on Process History, not on `{UniqueCode}.Process` — [process-history.md](process-history.md) |
| Configuration failure | Missing Entry Step code `00` or missing option `va` on step `00` → **do not render** New Request; Application Error (configuration) — [ADR-025](../../../decisions/ADR-025-process-history.md) |

Apps may add tabs and sections below Process Request. Body panels use `BoTabPanels` / `BoTabPanel` bound to the same selected tab key.

### Initiation option codes (formal PF convention)

| Step | Option | Meaning |
| --- | --- | --- |
| `00` | `va` | Submit (required) |
| `00` | `va1` | Save (optional) |

`va1` has Save meaning **only** on step `00`. Never infer Save from `va1` on any other step.

## People fields

Person controls use **`DisplayName (Email)`** when the user resolves — [forms.md](../controls/forms.md). GUID strings are last-resort fallback only (unresolved / empty profile). Bound PeoplePicker Values match Codes **case-insensitively**.

## Override guidance

| May override when planned | Still required unless formally excepted |
| --- | --- |
| Extra tabs/sections; editable Initiator later | General Information first; Process Request first section |
| Additional footer buttons after Submit | Save icon + Submit present unless workflow omits one with justification |
| Actions area instead of footer | Document why initiation cannot use footer |
| Alternate tab icon | Prefer Form Regular for General Information |

## Implementation ownership

- Process Request **section** remains **application-owned** (no SHARED-UI package).
- Footer action **row** is framework-owned (`BoPageFooterActions`).
- Hosts wire header `TabsContent`, body `BoTabPanels`, `ShowFooter`, `FooterContent`, and `OnSave` / `OnSubmit` → real persistence + redirect to Process View ([process-persistence.md](process-persistence.md)).
