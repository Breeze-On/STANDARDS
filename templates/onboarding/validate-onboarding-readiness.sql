/*
  BreezeOn — Customer onboarding readiness validation (READ-ONLY)

  Run against the customer database after Master Flow checkpoints.
  Typical order: Step 1 schema → Checkpoint E (login discovery) →
  Checkpoint G (Step 7 bootstrap) → Checkpoint F / F-N/A (Step 8 sync).
  Docs: runbooks/customer-onboarding-master-flow.md
        templates/onboarding/README.md

  Does NOT modify data. Does NOT enable sync or bootstrap admins.
  Does NOT create Identity.Tenants rows (login discovery is required).
*/

DECLARE @ExpectedTenantId uniqueidentifier = NULL; /* set to customer Entra tid when known */
DECLARE @ExpectGraphSync bit = 0; /* 1 = Graph Yes at intake; 0 = Graph No (F-N/A) */

/* --- Schema presence --- */
SELECT
    N'Identity.Users' AS [ObjectName],
    CASE WHEN OBJECT_ID(N'[Identity].[Users]', N'U') IS NOT NULL THEN 1 ELSE 0 END AS [Exists]
UNION ALL
SELECT N'Identity.UsersLogins',
    CASE WHEN OBJECT_ID(N'[Identity].[UsersLogins]', N'U') IS NOT NULL THEN 1 ELSE 0 END
UNION ALL
SELECT N'Identity.Tenants',
    CASE WHEN OBJECT_ID(N'[Identity].[Tenants]', N'U') IS NOT NULL THEN 1 ELSE 0 END
UNION ALL
SELECT N'Security.Groups',
    CASE WHEN OBJECT_ID(N'[Security].[Groups]', N'U') IS NOT NULL THEN 1 ELSE 0 END
UNION ALL
SELECT N'Security.GroupsMembers',
    CASE WHEN OBJECT_ID(N'[Security].[GroupsMembers]', N'U') IS NOT NULL THEN 1 ELSE 0 END;

IF OBJECT_ID(N'[Identity].[Tenants]', N'U') IS NULL
   OR OBJECT_ID(N'[Security].[Groups]', N'U') IS NULL
BEGIN
    SELECT N'Schema incomplete — stop; Master Flow Step 1' AS [ReadinessMessage];
    RETURN;
END;

/* --- Tenant registry --- */
SELECT
    COUNT(1) AS [TenantCount],
    SUM(CASE WHEN [IsSyncEnabled] = 1 THEN 1 ELSE 0 END) AS [SyncEnabledCount],
    MAX([LastSyncUtc]) AS [MaxLastSyncUtc],
    MAX([DiscoveredUtc]) AS [MaxDiscoveredUtc]
FROM [Identity].[Tenants];

SELECT
    [TenantId],
    [DisplayName],
    [IsSyncEnabled],
    [LastSyncStatus],
    [LastSyncUtc],
    [LastSyncError],
    [SyncStartedUtc],
    [DiscoveredUtc]
FROM [Identity].[Tenants]
ORDER BY [DiscoveredUtc];

IF @ExpectedTenantId IS NOT NULL
BEGIN
    SELECT
        CASE WHEN EXISTS (
            SELECT 1 FROM [Identity].[Tenants] WHERE [TenantId] = @ExpectedTenantId
        ) THEN 1 ELSE 0 END AS [ExpectedTenantRegistered],
        CASE WHEN EXISTS (
            SELECT 1 FROM [Identity].[Tenants]
            WHERE [TenantId] = @ExpectedTenantId AND [IsSyncEnabled] = 1
        ) THEN 1 ELSE 0 END AS [ExpectedTenantSyncEnabled];
END;

/* --- Sync expectation vs intake --- */
SELECT
    @ExpectGraphSync AS [ExpectGraphSync],
    (SELECT COUNT(1) FROM [Identity].[Tenants] WHERE [IsSyncEnabled] = 1) AS [SyncEnabledCount],
    CASE
        WHEN @ExpectGraphSync = 1
             AND NOT EXISTS (SELECT 1 FROM [Identity].[Tenants] WHERE [IsSyncEnabled] = 1)
            THEN N'FAIL: Graph required but no sync-enabled tenant (Checkpoint F)'
        WHEN @ExpectGraphSync = 0
             AND EXISTS (SELECT 1 FROM [Identity].[Tenants] WHERE [IsSyncEnabled] = 1)
            THEN N'WARN: Graph not required but IsSyncEnabled=1 present — confirm intentional'
        WHEN @ExpectGraphSync = 1
             AND EXISTS (
                SELECT 1 FROM [Identity].[Tenants]
                WHERE [IsSyncEnabled] = 1 AND [LastSyncStatus] = N'Failed'
             )
            THEN N'FAIL: sync-enabled tenant LastSyncStatus=Failed'
        WHEN @ExpectGraphSync = 1
             AND EXISTS (
                SELECT 1 FROM [Identity].[Tenants]
                WHERE [IsSyncEnabled] = 1 AND [LastSyncStatus] = N'Running'
             )
            THEN N'WARN: sync Running — wait or investigate stuck sync'
        WHEN @ExpectGraphSync = 1
             AND EXISTS (
                SELECT 1 FROM [Identity].[Tenants]
                WHERE [IsSyncEnabled] = 1 AND [LastSyncStatus] = N'Succeeded'
             )
            THEN N'PASS: at least one Succeeded sync on enabled tenant'
        WHEN @ExpectGraphSync = 0
            THEN N'PASS: Graph not required (record Checkpoint F-N/A on go-live sheet)'
        ELSE N'WARN: sync enabled but no Succeeded status yet — run Sync Now'
    END AS [SyncReadiness];

/* --- GLOBAL-SYSTEM-ADMINISTRATORS --- */
SELECT
    CASE WHEN EXISTS (
        SELECT 1 FROM [Security].[Groups] WHERE [Code] = N'GLOBAL-SYSTEM-ADMINISTRATORS'
    ) THEN 1 ELSE 0 END AS [GsaGroupExists],
    (
        SELECT COUNT(1)
        FROM [Security].[GroupsMembers] AS m
        INNER JOIN [Security].[Groups] AS g ON g.[GroupGUID] = m.[GroupGUID]
        WHERE g.[Code] = N'GLOBAL-SYSTEM-ADMINISTRATORS'
    ) AS [GlobalSystemAdministratorCount];

SELECT
    CASE
        WHEN NOT EXISTS (
            SELECT 1 FROM [Security].[Groups] WHERE [Code] = N'GLOBAL-SYSTEM-ADMINISTRATORS'
        ) THEN N'FAIL: GSA group missing — apply Security seed (Step 1)'
        WHEN NOT EXISTS (
            SELECT 1
            FROM [Security].[GroupsMembers] AS m
            INNER JOIN [Security].[Groups] AS g ON g.[GroupGUID] = m.[GroupGUID]
            WHERE g.[Code] = N'GLOBAL-SYSTEM-ADMINISTRATORS'
        ) THEN N'FAIL: no GSA members — Workflow G / Master Flow Step 7'
        ELSE N'PASS: at least one GLOBAL-SYSTEM-ADMINISTRATORS member'
    END AS [AdminBootstrapReadiness];

/* --- Recent successful logins (smoke hint) --- */
IF OBJECT_ID(N'[Identity].[UsersLogins]', N'U') IS NOT NULL
BEGIN
    SELECT TOP (5)
        l.[LoginUtc],
        l.[IsSuccessful],
        u.[UserPrincipalName],
        u.[TenantId]
    FROM [Identity].[UsersLogins] AS l
    INNER JOIN [Identity].[Users] AS u ON u.[UserGUID] = l.[UserGUID]
    WHERE l.[IsSuccessful] = 1
    ORDER BY l.[LoginUtc] DESC;
END;
