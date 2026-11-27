<!-- Classification: AA; Scope: platform; Domain: UI; Capability: ProcessView -->
# Process View

Owner: SYSTEM-SHARED-UI (platform capability / shared pattern) · product apps supply field composition

Related: [ADR-024](../../../decisions/ADR-024-platform-process-root.md) · [ADR-025](../../../decisions/ADR-025-process-history.md) · [process-runtime](../../../architecture/process-runtime/README.md) · [process-persistence.md](process-persistence.md) · [process-history.md](process-history.md) · [error-messages.md](../shell/error-messages.md) · [ae-query-string.md](../../../architecture/app-context/ae-query-string.md)

## Purpose

Standardized **read-only** viewing of a persisted process across applications.

## Route contract

```text
/process-view?AE={ApplicationEnabledGUID}&PGUID={ProcessGUID}
```

- Preserve `AE` via `IBoApplicationContextNavigation`.
- `PGUID` is the companion query parameter for platform process identity.

## Ownership

| Concern | Owner |
| --- | --- |
| Platform capability, shared pattern, route contract, loading/error/read-only rules | SYSTEM-SHARED-UI |
| Tabs / sections / fields / layout composition for the application | Product application |

Shared Process View **implementation pattern** is proposed during implementation after evaluating existing SHARED-UI architecture. Do not treat a specific Host/Wrapper/Layout/Archetype name as normative in STANDARDS beyond the behavioral contract below.

## Behavioral contract

| Rule | Contract |
| --- | --- |
| Footer | **No** page footer / sticky action footer (`ShowFooter=false`) |
| Fields | **Read-only display** — **not** `Disabled`. Prefer the **same typed control** as initiation with `ReadOnly=true` so formatting semantics match (Number → `BoNumberField` with same currency/%/decimals; Date → `BoDateField` with same `Mode`; multiline → `BoTextArea`). `BoFieldReadOnly` only for already-formatted scalars / resolved lookup text. See [forms.md § Read-only formatting parity](../controls/forms.md#read-only-formatting-parity-locked) |
| General Information layout | Mirror initiation Request Details composition when the app has one (same rows/fields **and** same field formatting parameters). Do **not** keep a separate Purpose-of-Service section if initiation places Purpose as Request Details Row 4 |
| Tabs | At least **General Information** + **Process History** |
| Tab icons | General Information: `Form` Regular 16. Process History: **`Flowchart` Regular (outlined) 16** — same in every app (`BoProcessViewRoute.ProcessHistoryIconName`). Do **not** use `History`. — [icons.md](../foundations/icons.md) |
| Tab placement | **Header only** — `BoAppHeader.TabsContent` → `BoTabs` / `BoTab`; body hosts **`BoTabPanels` only** (cascade selected key). Do **not** place `BoTabs` inside the shell body / main content card. Same rule as [shell.md](../shell/shell.md#header-tabs-optional-page-sections) · [initiation-experience.md](initiation-experience.md). Gallery copy-source: `/process-view-page`. |
| Process History | (1) Process Request fields (Initiator, Requested Date) — **`BoRow` with exactly two field children**, equal default `Weight = 1` — [process-request-section.md](process-request-section.md). Do **not** pad with `BoEmptyField`. (2) Section-level Process History grid (Role, Name, Response Status, Date, Comments) — [process-history.md](process-history.md). Display values come from EAC `P_GET_ProcessHistoryByProcessGUID`. |
| AuthZ (v1) | All authenticated users may open Process View pages (future authorization out of scope). |

## Validation

1. `PGUID` present and parseable.
2. Row exists in `Global.Process`.
3. `Global.Process.ApplicationEnabledGUID` equals current `AE`.
4. Application extension row exists for that `ProcessGUID`.

On failure: navigate to `/application-error` via `IBoApplicationErrorState` (existing Application Error framework). **Do not** invent custom Process error screens.

## Terminal in v1

Flow: **Create → Save/Submit → Process View**.

Process View is **terminal**. Out of scope: Edit, Resume, Reopen, Withdraw, Delete, return to editable state. Do not design around future editing in v1.

## Page Freeze

Hydrate under `IBoPageFreezeService` (platform consistency). See [overlays.md](../shell/overlays.md).
