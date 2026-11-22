<!-- Classification: AN; Scope: platform -->
# Business vision — Identity & Authentication

Owner: Architecture

## Model

- BreezeOn hosts SaaS applications within the **BreezeOn Azure tenant**.
- Customers authenticate using **their own Microsoft Entra tenants**.
- Customers are **not** managed as BreezeOn guest users.
- Authentication uses **OpenID Connect (OIDC)** against Microsoft Entra ID.
- BreezeOn **owns and manages App Registrations**.
- Customer consent creates an **Enterprise Application** in the customer tenant.
- Authentication is a **shared BreezeOn platform capability**. Product applications consume SYSTEM-SHARED-UI; they must not independently redesign authentication.

## Support access

BreezeOn administrators may access customer environments when the environment’s App Registration allows the BreezeOn tenant (configured in Entra). Application code does not maintain tenant allowlists.

## Related

- [Customer Onboarding Master Flow](../../runbooks/customer-onboarding-master-flow.md) (end-to-end operator SSOT)
- [Customer authentication onboarding](../../runbooks/customer-onboarding-authentication.md) (Workflows A–F)
- [Cloud architecture](cloud-architecture.md)
- [Authentication standard](authentication-standard.md)
