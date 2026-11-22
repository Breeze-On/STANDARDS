<!-- Classification: AA; Scope: application:eac; Domain: Platform; Capability: Variables -->
# Variables — Worked Examples

Owner: Architecture (EAC)

**Seed JSON is a technical fixture.** Prefer these patterns. Construct choice: [construct-selection.md](../app-configuration/construct-selection.md).

---

## 1. Approval Limit (business NUMBER)

```json
{
  "code": "approval-limit",
  "description": "Approval limit (CAD)",
  "dataType": "NUMBER",
  "decimals": 2,
  "sortOrder": 1,
  "metadata": "Finance"
}
```

Value per context: `{ "businessEntityCode": "FIN", "code": "approval-limit", "valueNumber": 100000 }`.

**Not:** per-role limit → PF Role metadata. **Unit/currency** documented in Description (no first-class unit field).

---

## 2. Feature Flag (BOOLEAN with Unset)

```json
{ "code": "enable-excel-export", "description": "Enable Excel export", "dataType": "BOOLEAN", "sortOrder": 2 }
```

- Configured true/false = on/off.  
- Omit value = **Unset** (consumer decides) — not the same as false.

---

## 3. Support Email (environment TEXT)

```json
{ "code": "support-email", "description": "Support email address", "dataType": "TEXT", "sortOrder": 3 }
```

Value: `"support@example.com"` or `{ "en-CA": "support@example.com" }` — plain string normalizes to en-CA.

**Promotion:** overwrites target on sync — review before promoting DEV→other environments.

---

## 4. Tax Percentage (NUMBER + Decimals warning)

```json
{ "code": "tax-percentage", "description": "Tax percentage", "dataType": "NUMBER", "decimals": 2, "sortOrder": 4 }
```

If `decimals` were `0` and value `7.5`, import/save **warns** and stores `8`. Set Decimals correctly at create.

---

## Counter-examples

| Need | Use instead |
| --- | --- |
| Cost Centers list | Data Entity |
| Invoice approval routing | Process Framework |
| Finance Department node | Business Entity |
| Approver membership | Security Group |
| API key / password | Platform secrets — **never** a Variable |
