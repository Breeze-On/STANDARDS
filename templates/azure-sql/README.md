# Template: grant App Service Managed Identity on Azure SQL

Idempotent T-SQL: [`grant-app-service-mi.sql`](grant-app-service-mi.sql).

## When to use

After creating a data-owning App Service with system-assigned Managed Identity and setting connection string **`SQLAzureConnection`** (see [hosted-deployment.md](../../docs/hosted-deployment.md) § Hosted database connection).

## Steps

1. Set `@AppServiceName` in the script to the App Service name (e.g. `breezeon-system-admin-eac-dev`).
2. Connect to the **target database** as an Entra SQL admin (`az login`, then token-based `sqlcmd` / SSMS).
3. Execute the script.
4. Confirm App Service **`SQLAzureConnection`** uses `Authentication=Active Directory Managed Identity`.
5. Confirm the app references **`Microsoft.Data.SqlClient.Extensions.Azure`** (SqlClient 7+) and registers `ActiveDirectoryAuthenticationProvider` before any SQL open — see [hosted-deployment.md](../../docs/hosted-deployment.md) § Hosted database connection step 5 and [architecture/security.md](../../architecture/security.md).

Access model: [architecture/security.md](../../architecture/security.md).
