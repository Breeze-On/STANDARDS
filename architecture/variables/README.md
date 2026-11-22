<!-- Classification: AA; Scope: application:eac -->
# Architecture — Variables

Owner: Architecture (EAC)

**Variables are an EAC configuration capability** — one named, typed setting whose value may differ per Application Context. Not a platform-wide settings API. Multi-application runtime consumption is **Future Validation**. Implementation lives in SYSTEM-ADMIN-EAC.

| Document | Covers |
| --- | --- |
| [variables-standard.md](variables-standard.md) | Business definition, construct selection, expressiveness, ownership, technical rules |
| [authoring-guide.md](authoring-guide.md) | Administrator sequence |
| [ai-authoring-contract.md](ai-authoring-contract.md) | Field contract + hazards |
| [worked-examples.md](worked-examples.md) | Realistic examples |
| [construct-selection.md](../app-configuration/construct-selection.md) | **Normative** Variable vs DE vs PF vs BE vs SG |

JSON: [`docs/data-portability.md`](../../docs/data-portability.md). Deployment: [application-configuration-deployment.md](../app-configuration/application-configuration-deployment.md). Schema: EAC [`docs/db-model.md`](https://github.com/Breeze-On/SYSTEM-ADMIN-EAC/blob/main/docs/db-model.md) · thin [`docs/variables.md`](https://github.com/Breeze-On/SYSTEM-ADMIN-EAC/blob/main/docs/variables.md).

## Definition of Done

Changes to Variables schema, contracts, or rules incomplete until this tree, portability, deployment docs, EAC `db-model.md`, and thin pointers update in the **same change set**.
