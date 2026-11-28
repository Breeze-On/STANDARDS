<!-- Classification: AA; Scope: platform; Domain: Engineering; Capability: ApplicationModel -->
# New Application Checklist

Owner: Architecture / Standards

**Authoritative bootstrap checklist** for every new BreezeOn **product application**. This is the primary validation artifact for platform compliance at application onboarding — for developers, planning agents, and AI implementation agents.

Related process: [application-development-process.md](ai/application-development-process.md) · Step 1 schema: [application-definition.schema.json](ai/application-definition.schema.json) · Adoption: [BREEZEON-AI-APPLICATION-ADOPTION.md](ai/BREEZEON-AI-APPLICATION-ADOPTION.md) · Host contract: [page-development.md](ui/page-development.md) · Initiation: [initiation-experience.md](ui/patterns/initiation-experience.md) · Process Request: [process-request-section.md](ui/patterns/process-request-section.md) · Footer: [page-footer-actions.md](ui/patterns/page-footer-actions.md) · Process View / persistence / history: [process-view.md](ui/patterns/process-view.md) · [process-persistence.md](ui/patterns/process-persistence.md) · [process-history.md](ui/patterns/process-history.md) · Process table: [database.md](database.md) § Process table convention · [ADR-024](../decisions/ADR-024-platform-process-root.md) · [ADR-025](../decisions/ADR-025-process-history.md).

Detail remains in the linked SSOTs. This checklist consolidates **mandatory application-level** requirements into one gate artifact. It does **not** replace Product Host Contract tables, Must-consume rows, or schema Step 1 inputs.

---

## Governance (mandatory)

### Living document

Whenever a new or changed standard introduces a **mandatory application-level** requirement for new BreezeOn applications, the author **must** evaluate whether that requirement belongs in this checklist.

| Outcome | Same-change-set duty |
| --- | --- |
| Belongs on the checklist | Update **this file** in the **same change set** as the owning AA / process gate |
| Does not belong (library-only, Future Validation, single-app) | Document why in the owning AA; do not inflate this checklist |

A standards change that adds a mandatory new-app requirement is **incomplete** until this checklist review has occurred (update or explicit “not applicable” in the owning AA / PR description).

Also update [application-development-process.md](ai/application-development-process.md) § **Platform bootstrap completion** when the gate categories change — [documentation.md](documentation.md) § Anti-drift (Platform bootstrap completion / New Application Checklist).

### Authority for agents

| Audience | Use |
| --- | --- |
| Planning agents | First review before / while drafting new-app roadmaps |
| Development / Build Locally agents | Validate Step 4–5 work against this checklist |
| New developers | Onboarding map into linked SSOTs |
| PR / completion review | Evidence that bootstrap compliance was considered |

**Platform bootstrap completion** (process Step 5) is not satisfied until the applicable rows below are complete (or formally excepted in an approved plan).

---

## Application Foundation

- [ ] Application registered in EAC (registry / portable `seed/eac/` config as applicable)
- [ ] `UniqueCode` defined (`repositoryName.ToUpperInvariant()` — [naming.md](naming.md) · schema)
- [ ] Navigation entry configured (page catalog + left nav / Home cards)
- [ ] Security groups configured (app AttributeCodes / membership seeds as required)
- [ ] Seed data configured (`seed/eac/` for EAC config; `sql/seed/` for app business data when needed)
- [ ] Admin access configured (local/admin membership path documented and seeded)
- [ ] Local scripts present: `dev-reset.ps1` (orchestrates sibling EAC reset) + `dev-run.ps1` — [local-development-scripts.md](local-development-scripts.md)
- [ ] Sibling `breezeon-system-admin-eac` + `breezeon-system-shared-ui` (+ `breezeon-system-process-engine` when Request Number / sequences are in scope) prerequisites documented in product README / README_AI — standard names per [naming.md](naming.md); local folders may still use GitHub legacy names until rename

## Pages

- [ ] Home page implemented (`BoNavHub` / Product Host Contract)
- [ ] New Request page implemented
- [ ] Status Report page implemented (default IA unless plan overrides)
- [ ] My Tasks page implemented (default IA unless plan overrides)
- [ ] Error / Application Error page implemented
- [ ] Access Denied page implemented (`ShowFooter=false` on error surfaces)

## New Request Experience

Authority: [initiation-experience.md](ui/patterns/initiation-experience.md) · [page-footer-actions.md](ui/patterns/page-footer-actions.md) · [shell.md](ui/shell/shell.md)

- [ ] **General Information** tab exists
- [ ] General Information is the **first** tab
- [ ] General Information uses Fluent **Form** Regular (outlined) icon, Size 16
- [ ] Tabs live in header `BoAppHeader.TabsContent`; body uses matching `BoTabPanels`
- [ ] **Process Request** section exists
- [ ] Initiation: Process Request is the **first** section under General Information
- [ ] Process View: Process Request is the **first** section under **Process History** (not under General Information)
- [ ] Shell footer **enabled** on New Request (`BoAppShell.ShowFooter`)
- [ ] **`BoPageFooterActions`** implemented in `BoAppFooter` (no Actions-area Save\|Discard on default initiation)
- [ ] Save uses platform **Save** pattern (`BoButtonVariant.Save`, Filled Save icon, AriaLabel)
- [ ] Submit uses **Primary** pattern
- [ ] PF initiation: Entry Step code **`00`** with option **`va`** (Submit); option **`va1`** (Save) only on step `00` — hide Save when `va1` absent; never infer Save from non-00 `va1`
- [ ] Missing step `00` or `va` → New Request does **not** render (Application Error configuration)
- [ ] Default **Additional Information** tab with Comments (`BoTextArea` 4000) unless app overrides placement — Comments persist on Process History only
- [ ] Option metadata **`response-status`** required on every history-capable PF option

## Process Request Fields

Authority: [process-request-section.md](ui/patterns/process-request-section.md) · [forms.md](ui/controls/forms.md) · [ADR-027](../decisions/ADR-027-request-number-and-sequence-allocation.md)

- [ ] **Request Number** field implemented (`BoFieldReadOnly`, **left** of Initiator) — computed; never a persisted column
- [ ] Initiator field implemented (`BoPeoplePicker`, single, Disabled, not Required)
- [ ] `InitiatorUserGUID` field mapped (persist UserGUID only; Value `"D"` format)
- [ ] Requested Date field implemented (`BoDateField`, Date mode, `DateTime?`, Disabled)
- [ ] `RequestedDate` field mapped
- [ ] Row uses **exactly three** field children (Request Number, Initiator, Requested Date)
- [ ] Initiator auto-population implemented (authenticated user)
- [ ] Requested Date auto-population implemented (current **local** calendar date)
- [ ] People display **`DisplayName (Email)`** when resolve succeeds (GUID last resort only)
- [ ] Process View **App Title = `[Request Number] - [Application Name]`**; stacked SubTitle + Context Cards via SHARED-UI; browser document title = Request Number only — [process-view.md](ui/patterns/process-view.md)

## Database

Authority: [database.md](database.md) § Process table convention (two-tier) · [ADR-024](../decisions/ADR-024-platform-process-root.md) · [ADR-027](../decisions/ADR-027-request-number-and-sequence-allocation.md) · [ADR-028](../decisions/ADR-028-process-runtime-ownership-process-engine.md) · [process-runtime](../architecture/process-runtime/README.md)

- [ ] Platform root: Process Engine owns `Global.Process` + `Global.P_POST_Process`; EAC owns `Global.P_GET_ProcessTable` + schema container (consumer does **not** invent these)
- [ ] Process History: Process Engine owns `Global.ProcessHistory` + `P_POST_ProcessHistory` + display-ready `P_GET_ProcessHistoryByProcessGUID` (consumer does **not** invent projection)
- [ ] `{UniqueCode}.Process` **extension** table created under product `sql/current_model/`
- [ ] `ProcessId` implemented (`INT IDENTITY` PK) on the extension table
- [ ] `ProcessGUID` on extension is `UNIQUEIDENTIFIER NOT NULL` UNIQUE — value from Process Engine `CreateProcessAsync` / `Global.Process`
- [ ] Required Sequence columns on extension: `SequenceTemplate`, `SequenceDisplay`, `Sequence` — **never** persist `RequestNumber` / `SequenceDigits`
- [ ] Application **must not mint** `ProcessGUID` (SQL generates on Global create via PE)
- [ ] Create order: `CreateProcessAsync` → insert `{UniqueCode}.Process` → resolve SequenceTemplate/Display on Save → `RecordProcessHistoryAsync` (`00`/`va` or `00`/`va1`) → `GenerateProcessSequence` (app-chosen; typically after Submit) → one transaction → redirect to Process View
- [ ] Flat fields mapped to extension Process table (baseline: `InitiatorUserGUID`, `RequestedDate`) — **no** Comments column on extension
- [ ] Mandatory audit columns present
- [ ] Consumer `dev-reset.ps1` applies app `sql/current_model/` **after** EAC subprocess (Global schema + PE full runtime pack before consumer Process FK)
- [ ] Process View History tab: Process Request (three fields) + Process History grid consuming PE-projected columns (SHARED-UI display models only)

## Architecture

- [ ] Process Request remains **application-owned** (no SHARED-UI `BoProcessRequest` package)
- [ ] Sibling **`ProjectReference`** to `BreezeOn.ProcessEngine` (`breezeon-system-process-engine`) for Process Runtime create/history/sequence — [ADR-026](../decisions/ADR-026-process-engine-and-metadata-framework.md) · [ADR-028](../decisions/ADR-028-process-runtime-ownership-process-engine.md)
- [ ] `ProcessSequence:Digits` host config (default 4); permanent Variable Codes `sequence-template` / `sequence-display` in AE config (missing → `""`)
- [ ] Save/Submit persistence per [process-persistence.md](ui/patterns/process-persistence.md); Process View is **terminal** ([process-view.md](ui/patterns/process-view.md))
- [ ] No application forks of shared UI controls / chrome (use `Bo*` + tokens)
- [ ] Shared UI standards followed ([ui/overview.md](ui/overview.md) · Product Host Contract)
- [ ] [page-development.md](ui/page-development.md) reviewed for the pages shipped
- [ ] UI designed from **STANDARDS first**, then SHARED-UI; Gallery treated as illustrative only ([example-governance.md](ui/example-governance.md))
- [ ] Must-consume platform capabilities satisfied — [application-model.md](application-model.md)

## Documentation

- [ ] `docs/db-model.md` updated (Process table current reality)
- [ ] Application `README.md` / `README_AI.md` / `AGENTS.md` updated (thin ENT trio)
- [ ] Architecture / landscape application AA updated when the app is registered in STANDARDS
- [ ] Standards compliance reviewed (this checklist + Platform bootstrap completion)

---

## Completion

Mark the application bootstrap **complete** only when all applicable items above are checked (or an approved plan documents an explicit, justified exception). Business feature work beyond the IA / Process Request baseline should wait until [Platform bootstrap completion](ai/application-development-process.md#platform-bootstrap-completion-mandatory-gate) passes.
