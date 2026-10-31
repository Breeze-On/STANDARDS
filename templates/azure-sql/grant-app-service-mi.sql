-- Grant Azure App Service system-assigned Managed Identity access to this database.
--
-- Prerequisites:
--   - Run against the TARGET database (e.g. BreezeOnDV), not master.
--   - Caller is an Azure SQL Entra admin (az login + AAD token / SSMS Entra).
--   - App Service system-assigned Managed Identity is enabled.
--
-- Replace @AppServiceName with the App Service resource name (SQL user must match).
-- Example: breezeon-system-admin-eac-dev
--
-- Docs: architecture/security.md · docs/hosted-deployment.md § Hosted database connection

DECLARE @AppServiceName sysname = N'breezeon-system-admin-eac-dev'; -- <-- set per app
DECLARE @sql nvarchar(max);

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = @AppServiceName)
BEGIN
    SET @sql = N'CREATE USER ' + QUOTENAME(@AppServiceName) + N' FROM EXTERNAL PROVIDER;';
    EXEC sp_executesql @sql;
END;

IF IS_ROLEMEMBER(N'db_datareader', @AppServiceName) <> 1
    EXEC sp_addrolemember N'db_datareader', @AppServiceName;

IF IS_ROLEMEMBER(N'db_datawriter', @AppServiceName) <> 1
    EXEC sp_addrolemember N'db_datawriter', @AppServiceName;

IF IS_ROLEMEMBER(N'db_ddladmin', @AppServiceName) <> 1
    EXEC sp_addrolemember N'db_ddladmin', @AppServiceName;
