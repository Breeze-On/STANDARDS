<!-- Classification: AA; Scope: platform; Domain: UI; Capability: Layout -->
# UI — Expandable / disclosure content

Owner: UI

**Implementation SSOT:** [Breeze-On/SYSTEM-SHARED-UI](https://github.com/Breeze-On/SYSTEM-SHARED-UI) — `BoExpandableSection`, internal `BoDisclosurePanel`, `.bo-disclosure*` / `.bo-expandable-section*` in `breezeon-ui.css`.

Related: [sections.md](sections.md) (form Sections with optional `IsCollapsible`), [error-messages.md](../shell/error-messages.md), [shell.md](../shell/shell.md) (body scroll).

## Purpose

Platform standard for **disclosure-style** expand/collapse (show/hide auxiliary content). Not a form Section → Row → Field primitive.

## When to use which API

| Use | API |
| --- | --- |
| Error Message panels, support info, advanced filters, settings “advanced” blocks, similar disclosures | **`BoExpandableSection`** |
| Form structure (Section → Row → Field) | **`BoSectionMain` / `BoSectionSub`** |
| Form section that may collapse | **`BoSectionMain` / `BoSectionSub`** with `IsCollapsible="true"` |

Do **not** invent custom page expand/collapse. Do **not** use `BoSectionMain`/`BoSectionSub` for Error Message Pages.

## One disclosure engine

`BoExpandableSection` and collapsible Sections share the same underlying engine (`BoDisclosurePanel` + `.bo-disclosure*`):

- WAI-ARIA disclosure (`aria-expanded`, `aria-controls`, button + region)
- Height animation (`grid-template-rows` 0fr → 1fr) + opacity fade
- `prefers-reduced-motion` (instant toggle; full functionality retained)
- Overflow: local `overflow: hidden` only on the panel wrapper — **never** on `BoAppBody`
- Expanded bindable; **default `Expanded = true`** when unbound
- Page-default expand/collapse resets **only on page load / remount** — not on in-page tab or panel navigation; hosts must `@bind-Expanded` (see [sections.md](sections.md#default-expand-vs-in-page-navigation-locked))

## DOM retention (hard rule)

Collapsed content **remains mounted in the DOM**. Expand/collapse controls visibility only and must **not** destroy or recreate content (`@if (Expanded) { @ChildContent }` is forbidden).

This preserves form state, field values, EditContext, validation state, focus, and component lifecycle. When collapsed, content must not be keyboard-reachable or exposed to assistive technology (`inert` and/or `aria-hidden`).

## `BoExpandableSection`

| Parameter | Notes |
| --- | --- |
| `Title` / `TitleContent` | Trigger label |
| `ChildContent` | Always mounted body |
| `Expanded` / `ExpandedChanged` | `@bind-Expanded`; default **true** |
| `Class` / `Id` / `Style` | Optional |

## Overflow / scrolling

When expanded content exceeds the body card, **`BoAppBody` scrolls** (`overflow: auto`). Do not set `overflow: hidden` on the app body for expandable content.

## Gallery

Error Message Page (`/error-message-page`) is the primary showcase (Access Denied uses `BoExpandableSection`).
