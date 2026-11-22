<!-- Classification: AA; Scope: platform -->
# Approved deviations

Owner: Documentation

Deviations are **first-class citizens** of BreezeOn documentation governance. This folder is the permanent home for approved exceptions to platform standards — required from day one even when the inventory is small, and expected to grow as the platform matures.

## Rules

1. An exception to a standard is authoritative **only** if recorded here (using [`TEMPLATE.md`](TEMPLATE.md)).
2. Each entry must cite the standard clause it excepts, define scope, state the approved exception text, and include rationale.
3. Do not bury exceptions only in plans, `README_AI`, or unlabeled architecture prose.
4. Application-specific behavior that never claimed to be a platform standard belongs under [`architecture/applications/`](../../architecture/applications/README.md), not here.
5. Sparse index is acceptable; absence of this folder is not.
6. Classification banner on every entry: `AA` (authoritative for the exception) or as otherwise appropriate; Scope usually `platform` or `application:<app>`.

Related meta-SSOT: [`../documentation.md`](../documentation.md) § Approved deviations · Precedence.

## Index

| Id | Title | Standard cited | Scope | Status |
| --- | --- | --- | --- | --- |
| [`DEV-001`](DEV-001-process-framework-future-engine-vision.md) | Process Framework future engine vision | [`architecture/process-framework/README.md`](../../architecture/process-framework/README.md) | platform (documentation exception) | Active |
| [`DEV-002`](DEV-002-example-governance-approved-exceptions.md) | Example Governance approved exceptions | [`docs/ui/example-governance.md`](../ui/example-governance.md) | platform / UI | Active (registry) |
