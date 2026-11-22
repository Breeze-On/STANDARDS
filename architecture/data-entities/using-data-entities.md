<!-- Classification: AN; Scope: application:eac; Domain: Platform; Capability: DataEntities -->
# Using Data Entities (non-normative)

Owner: Architecture (EAC)

**Status: non-normative guidance** until a second consumer beyond EAC Process Framework exists. Do **not** treat this document as a platform API contract.

## Current reality

| Fact | Detail |
| --- | --- |
| Only shipped consumer | Process Framework **DDL** metadata — stores Data Entity **row Code** (never GUID) |
| Definitions | Application-scoped; portable via App Config JSON by **Code** |
| Rows | Application Context–scoped; portable via **Excel** on hosted environments |
| Multi-app consumption | **Future Validation** — do not invent |

## Retrieval notes (EAC-internal)

Product UI uses paged Values SPs and Excel full-load paths. There is **no** org-wide consumer row-read SSOT. Prefer Codes for portable references.

If you previously saw guidance to treat `DataEntityRowGUID` as the integration key: that does **not** match the shipped PF DDL contract (Code). GUIDs are environment-local.

## Expectations for a future second consumer

When a second app needs DE data, define a read contract in the same change set as first real usage — and update this document from non-normative to AA. Until then, keep consumption inside EAC.
