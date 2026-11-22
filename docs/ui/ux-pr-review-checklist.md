<!-- Classification: AA; Scope: platform; Domain: UI; Capability: Patterns -->
# UI — UX pull request review checklist

Owner: UI

Short human / agent checklist for UI-bearing PRs. Normative detail: [ux-conventions.md](patterns/ux-conventions.md), [page-development.md](page-development.md), [overlays.md](shell/overlays.md).

## Before review

- [ ] Plan included a **UX Standards Compliance Review** (or this PR is pure non-UI)
- [ ] Gallery / Shared UI / documented pattern was checked before any custom UX

## Reuse and chrome

- [ ] Product pages use `Bo*` only (no Fluent types)
- [ ] No page-local loading overlays (use `IBoPageFreezeService`)
- [ ] No product CSS forks of Shared UI header/track alignment or truncation
- [ ] No product CSS `border-radius` overrides on `.bo-button` (hard standard: `--bo-button-radius` — [button.md](controls/button.md))
- [ ] Actions use `BoButton` / `BoIconButton` (no raw `<button>`); destructive = `Danger`; one Primary per group
- [ ] Selection / navigation control chosen per [selection-and-navigation.md](controls/selection-and-navigation.md); guards use the intent event, not change-then-revert
- [ ] Public API facts taken from `public-component-api.md` (no Razor spelunking); new/changed parameters documented there

## Conventions

- [ ] Placeholders are platform defaults (no label/header echo; semantic exceptions documented)
- [ ] Long closed values truncate; selected values do not resize controls
- [ ] Disabled vs read-only vs N/A (`IsHidden`) used correctly
- [ ] Admin-facing copy has no implementation identifiers
- [ ] Navigation / workspace primary view reset documented when context changes

## Page Freeze

- [ ] Saves / bulk / sync / import / export freeze
- [ ] Perceptible workspace/config hydrations freeze (including tab activation that reloads data)
- [ ] Filter / sort / page / chrome-only tabs do **not** freeze

## Definition of Done (library standards)

If this PR changes a Shared UI / UX standard:

- [ ] Normative STANDARDS updated
- [ ] AI index / agent guidance updated
- [ ] Gallery working example updated (or labeled pending) — [example-governance.md](example-governance.md)
