<!-- Classification: AA; Scope: platform; Domain: UI; Capability: Patterns -->
# UI — Page footer actions

Owner: UI

Default **shell footer** command pattern for initiation and other pages that need Save + Submit in the footer. Related: [initiation-experience.md](initiation-experience.md), [actions-area.md](actions-area.md), [shell.md](../shell/shell.md), [button.md](../controls/button.md), [application-bootstrap-checklist.md](../../application-bootstrap-checklist.md).

## vs Actions area

| Surface | Where | Typical commands |
| --- | --- | --- |
| **Page footer actions** | `BoAppShell` footer → `BoAppFooter` → **`BoPageFooterActions`** | Save (icon) + Submit (Primary) — **default initiation** |
| **Actions area** | Top of editable body (`BoSectionSub` “Actions”) | Save \| Discard — workspace / catalog working copies |
| **Dialog footer** | `BoDialog` | Cancel / Confirm |

Do not reimplement the Save+Submit row per application — use `BoPageFooterActions`.

## Default layout (Tier 2 — STANDARD)

- Right-aligned within the footer content area.
- Order (left → right): **Save** then **Submit**.
- **Save:** `BoIconButton` with **`BoButtonVariant.Save`**, Fluent **Save** **Filled**, no visible text; `AriaLabel` / `Title` required (localized “Save”). Soft Save tokens (`--bo-color-save-button-*`) — not Secondary/Primary fill.
- **Submit:** `BoButton` **Primary** with localized text “Submit”.
- Save and Submit share the same computed height and vertical center (framework CSS on `.bo-page-footer-actions`).

API: SHARED-UI [`public-component-api.md` § BoPageFooterActions](https://github.com/Breeze-On/SYSTEM-SHARED-UI/blob/main/docs/public-component-api.md).

### Why Save variant here

Submit is the Primary workflow command; Save persists progress beside it. A control labeled “Save” does **not** always use `BoButtonVariant.Save` — see [button.md](../controls/button.md) § Save variant. Sole dominant Save on a page typically uses **Primary**.

## Host wiring

1. `BoAppShell.ShowFooter="true"` on pages that use this pattern (Home / Error / Access Denied remain footer off).
2. `FooterContent`: `<BoAppFooter><BoPageFooterActions … /></BoAppFooter>`.
3. Bind `OnSave` / `OnSubmit` (placeholders allowed until persistence/workflow is defined).

## Override guidance

Applications may add trailing commands, disable buttons, or omit Save/Submit when a plan explicitly justifies it. Do not invent a second Save+Submit layout CSS fork or app-local Save button colors.
