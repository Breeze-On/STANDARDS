-- Grant Azure App Service system-assigned Managed Identity access to this database.
--
-- Model:
--   1. Custom role [breezeon_app] holds the runtime permission set (do not customize built-in roles).
--   2. Role is a member of db_datareader / db_datawriter / db_ddladmin.
--   3. Database-level EXECUTE on the role (all schemas, current and future).
--   4. App Service MI user is created FROM EXTERNAL PROVIDER and added only to [breezeon_app].
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
DECLARE @AppRole sysname = N'breezeon_app';
DECLARE @sql nvarchar(max);

IF NOT EXISTS (
    SELECT 1
    FROM sys.database_principals
    WHERE name = @AppRole
      AND type = N'R'
)
BEGIN
    SET @sql = N'CREATE ROLE ' + QUOTENAME(@AppRole) + N';';
    EXEC sp_executesql @sql;
END;

IF IS_ROLEMEMBER(N'db_datareader', @AppRole) <> 1
    ALTER ROLE [db_datareader] ADD MEMBER [breezeon_app];

IF IS_ROLEMEMBER(N'db_datawriter', @AppRole) <> 1
    ALTER ROLE [db_datawriter] ADD MEMBER [breezeon_app];

IF IS_ROLEMEMBER(N'db_ddladmin', @AppRole) <> 1
    ALTER ROLE [db_ddladmin] ADD MEMBER [breezeon_app];

-- Database-level EXECUTE: all schemas (System, dbo, future app schemas).
GRANT EXECUTE TO [breezeon_app];

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = @AppServiceName)
BEGIN
    SET @sql = N'CREATE USER ' + QUOTENAME(@AppServiceName) + N' FROM EXTERNAL PROVIDER;';
    EXEC sp_executesql @sql;
END;

IF IS_ROLEMEMBER(@AppRole, @AppServiceName) <> 1
BEGIN
    SET @sql = N'ALTER ROLE ' + QUOTENAME(@AppRole) + N' ADD MEMBER ' + QUOTENAME(@AppServiceName) + N';';
    EXEC sp_executesql @sql;
END;
