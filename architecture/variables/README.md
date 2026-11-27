<!-- Classification: AA; Scope: application:eac; Domain: Platform; Capability: Variables -->
# Architecture — Variables

Owner: Architecture (EAC)

**Variables are an EAC configuration capability** — one named, typed setting whose value may differ per Application Context. Not a platform-wide settings API. General multi-application Variables APIs remain **Future Validation**. **Exception (Current Implementation):** Process Engine consumes permanent Variable Codes `sequence-template` / `sequence-display` for Request Number metadata ([process-metadata/README.md](../process-metadata/README.md) · [ADR-027](../../decisions/ADR-027-request-number-and-sequence-allocation.md)); missing → `""`. Implementation of definitions/values lives in breezeon-system-admin-eac; PE reads via EAC Variable TEXT SP.

| Document | Covers |
| --- | --- |
| [variables-standard.md](variables-standard.md) | Business definition, construct selection, expressiveness, ownership, technical rules |
| [authoring-guide.md](authoring-guide.md) | Administrator sequence |
| [ai-authoring-contract.md](ai-authoring-contract.md) | Field contract + hazards |
| [worked-examples.md](worked-examples.md) | Realistic examples |
| [construct-selection.md](../app-configuration/construct-selection.md) | **Normative** Variable vs DE vs PF vs BE vs SG |

JSON: [`docs/data-portability.md`](../../docs/data-portability.md). Deployment: [application-configuration-deployment.md](../app-configuration/application-configuration-deployment.md). Schema: EAC [`docs/db-model.md`](https://github.com/Breeze-On/breezeon-system-admin-eac/blob/main/docs/db-model.md) · thin [`docs/variables.md`](https://github.com/Breeze-On/breezeon-system-admin-eac/blob/main/docs/variables.md).

## Definition of Done

Changes to Variables schema, contracts, or rules incomplete until this tree, portability, deployment docs, EAC `db-model.md`, and thin pointers update in the **same change set**.
