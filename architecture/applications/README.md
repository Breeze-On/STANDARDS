<!-- Classification: AA; Scope: platform; Domain: Platform; Capability: Applications -->
# Architecture — Applications

Owner: Architecture

Application reference documentation for mature BreezeOn applications that **consume** the platform. These documents are **not** platform-wide standards.

| Application | Docs | Role |
| --- | --- | --- |
| EAC (Enterprise Administration Center) | [`eac.md`](eac.md) · [`eac-authorization-matrix.md`](eac-authorization-matrix.md) | Mature administration application and platform consumer / reference implementation within its defined completed scope |
| INV (Invoice Approval Request) | [`inv.md`](inv.md) | First validated product application host (thin AuthN/AuthZ + IA); **illustrative** of the application-development process — not the required shape of future apps |

Rules:

- Do not promote application-specific behavior into platform standards merely because EAC or INV implements it.
- Future apps add a row and dedicated files here; they consume STANDARDS by link and keep app AA in their own repos.
