-- =============================================================================
-- Customer onboarding — Step 7 / Workflow G (admin + sync-enable bootstrap)
-- =============================================================================
-- SSOT procedure: STANDARDS runbooks/customer-onboarding-master-flow.md Step 7
-- Detail: STANDARDS architecture/authorization/customer-onboarding-authorization.md
-- Operator copy: STANDARDS templates/onboarding/bootstrap-global-system-administrators.sql
--
-- What this script does (idempotent):
--   1) Upsert Identity.Tenants for each listed tid with IsSyncEnabled = 1
--   2) Create Security.Groups GLOBAL-SYSTEM-ADMINISTRATORS if missing
--   3) Grant that group to each listed admin UPN (must already exist in Identity.Users
--      from first login — Master Flow Step 6 — or local Graph UPN upsert)
--
-- After this script succeeds → Master Flow Step 8: bootstrapped admin opens EAC
-- /users and runs Sync Now (when intake Graph = Yes).
--
-- Parameter format (@TenantAdminPairs): semicolon-separated pairs
--   {entra-tenant-id}|{admin-upn}
-- Rules:
--   - Every pair is one tenant + one admin UPN
--   - Every distinct tenant MUST have at least one admin UPN
--   - Same tenant may appear on multiple pairs (multiple admins)
--   - Same admin may appear on multiple tenants
-- Example:
--   N'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee|admin@contoso.com;ffffffff-1111-2222-3333-444444444444|admin@fabrikam.com'
--
-- LocalDirectoryBootstrap may rewrite @TenantAdminPairs from IDENTITY__SEEDTENANTIDS
-- + BootstrapAdminUpns.json before apply. Do not commit real customer tids.
-- =============================================================================

-- Client parameter (edit per customer) — replace placeholders before hosted apply.
DECLARE @TenantAdminPairs NVARCHAR(MAX) = N'00000000-0000-0000-0000-000000000001|replace-admin@tenant1.example;00000000-0000-0000-0000-000000000002|replace-admin@tenant2.example';

-- =============================================================================
-- Runtime
-- =============================================================================

DECLARE @Now DATETIME2 = SYSUTCDATETIME();
DECLARE @Actor NVARCHAR(600) = N'ONBOARDING';

DECLARE @BootstrapPairs TABLE
(
    [TenantId] UNIQUEIDENTIFIER NOT NULL,
    [Upn] NVARCHAR(320) NOT NULL
);

DECLARE @Pair NVARCHAR(700);
DECLARE @Pipe INT;
DECLARE @TenantToken NVARCHAR(100);
DECLARE @UpnToken NVARCHAR(320);
DECLARE @TenantId UNIQUEIDENTIFIER;

DECLARE pair_cursor CURSOR LOCAL FAST_FORWARD FOR
    SELECT LTRIM(RTRIM([value]))
    FROM STRING_SPLIT(@TenantAdminPairs, N';')
    WHERE LTRIM(RTRIM([value])) <> N'';

OPEN pair_cursor;
FETCH NEXT FROM pair_cursor INTO @Pair;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @Pipe = CHARINDEX(N'|', @Pair);
    IF @Pipe < 2 OR @Pipe = LEN(@Pair)
    BEGIN
        CLOSE pair_cursor;
        DEALLOCATE pair_cursor;
        THROW 50004, N'@TenantAdminPairs entries must be tenantId|adminUpn (semicolon-separated).', 1;
    END

    SET @TenantToken = LTRIM(RTRIM(LEFT(@Pair, @Pipe - 1)));
    SET @UpnToken = LTRIM(RTRIM(SUBSTRING(@Pair, @Pipe + 1, 320)));
    SET @TenantId = TRY_CONVERT(UNIQUEIDENTIFIER, @TenantToken);

    IF @TenantId IS NULL
    BEGIN
        CLOSE pair_cursor;
        DEALLOCATE pair_cursor;
        THROW 50005, N'@TenantAdminPairs contains a non-GUID tenant id. Use Entra tid|UPN pairs.', 1;
    END

    IF @UpnToken IS NULL OR @UpnToken = N'' OR CHARINDEX(N'|', @UpnToken) > 0
    BEGIN
        CLOSE pair_cursor;
        DEALLOCATE pair_cursor;
        THROW 50006, N'@TenantAdminPairs contains an empty or invalid admin UPN.', 1;
    END

    IF NOT EXISTS (
        SELECT 1 FROM @BootstrapPairs WHERE [TenantId] = @TenantId AND [Upn] = @UpnToken
    )
    BEGIN
        INSERT INTO @BootstrapPairs ([TenantId], [Upn]) VALUES (@TenantId, @UpnToken);
    END

    FETCH NEXT FROM pair_cursor INTO @Pair;
END

CLOSE pair_cursor;
DEALLOCATE pair_cursor;

IF NOT EXISTS (SELECT 1 FROM @BootstrapPairs)
BEGIN
    THROW 50007, N'@TenantAdminPairs is empty. Provide at least one tenantId|adminUpn pair.', 1;
END

-- Reject committed placeholders so hosted operators do not apply the sample values.
IF EXISTS (
    SELECT 1
    FROM @BootstrapPairs
    WHERE [TenantId] IN
        (
            '00000000-0000-0000-0000-000000000001',
            '00000000-0000-0000-0000-000000000002'
        )
       OR [Upn] LIKE N'replace-admin@%'
)
BEGIN
    THROW 50008, N'Replace placeholder tenant ids and admin UPNs in @TenantAdminPairs before apply (Master Flow Step 7).', 1;
END

-- Every distinct tenant must have ≥ 1 admin UPN (enforced by pair shape; re-check after parse).
IF EXISTS (
    SELECT t.[TenantId]
    FROM (SELECT DISTINCT [TenantId] FROM @BootstrapPairs) AS t
    WHERE NOT EXISTS (
        SELECT 1 FROM @BootstrapPairs AS p WHERE p.[TenantId] = t.[TenantId] AND p.[Upn] <> N''
    )
)
BEGIN
    THROW 50009, N'Each tenant in @TenantAdminPairs must have at least one admin UPN.', 1;
END

DECLARE @TenantCount INT =
(
    SELECT COUNT(DISTINCT [TenantId]) FROM @BootstrapPairs
);
DECLARE @AdminCount INT =
(
    SELECT COUNT(DISTINCT [Upn]) FROM @BootstrapPairs
);

PRINT N'Bootstrap pairs: '
    + CONVERT(NVARCHAR(11), @TenantCount)
    + N' tenant(s), '
    + CONVERT(NVARCHAR(11), @AdminCount)
    + N' admin UPN(s).';

-- 1) Identity.Tenants — insert if missing; force IsSyncEnabled = 1 for listed tids.
DECLARE tenant_cursor CURSOR LOCAL FAST_FORWARD FOR
    SELECT DISTINCT [TenantId] FROM @BootstrapPairs;

OPEN tenant_cursor;
FETCH NEXT FROM tenant_cursor INTO @TenantId;

WHILE @@FETCH_STATUS = 0
BEGIN
    IF NOT EXISTS (SELECT 1 FROM [Identity].[Tenants] WHERE [TenantId] = @TenantId)
    BEGIN
        INSERT INTO [Identity].[Tenants]
        (
            [TenantId],
            [DisplayName],
            [IsSyncEnabled],
            [DiscoveredUtc]
        )
        VALUES
        (
            @TenantId,
            NULL,
            1,
            @Now
        );
        PRINT N'Inserted Identity.Tenants row (IsSyncEnabled=1): ' + CONVERT(NVARCHAR(36), @TenantId);
    END
    ELSE
    BEGIN
        UPDATE [Identity].[Tenants]
        SET [IsSyncEnabled] = 1
        WHERE [TenantId] = @TenantId
          AND [IsSyncEnabled] <> 1;

        IF @@ROWCOUNT > 0
            PRINT N'Updated Identity.Tenants IsSyncEnabled=1: ' + CONVERT(NVARCHAR(36), @TenantId);
        ELSE
            PRINT N'Identity.Tenants already sync-enabled: ' + CONVERT(NVARCHAR(36), @TenantId);
    END

    FETCH NEXT FROM tenant_cursor INTO @TenantId;
END

CLOSE tenant_cursor;
DEALLOCATE tenant_cursor;

-- 2) GLOBAL-SYSTEM-ADMINISTRATORS group
IF NOT EXISTS (SELECT 1 FROM [Security].[Groups] WHERE [Code] = N'GLOBAL-SYSTEM-ADMINISTRATORS')
BEGIN
    INSERT INTO [Security].[Groups]
    (
        [Code],
        [Name],
        [Description],
        [Metadata],
        [CreatedBy],
        [CreatedDate],
        [LastUpdatedBy],
        [LastUpdatedDate]
    )
    VALUES
    (
        N'GLOBAL-SYSTEM-ADMINISTRATORS',
        N'Global System Administrators',
        N'Platform administrators for BreezeOn customer-environment administration surfaces.',
        NULL,
        @Actor,
        @Now,
        @Actor,
        @Now
    );
    PRINT N'Created Security.Groups row GLOBAL-SYSTEM-ADMINISTRATORS.';
END

DECLARE @GroupGUID UNIQUEIDENTIFIER =
(
    SELECT [GroupGUID]
    FROM [Security].[Groups]
    WHERE [Code] = N'GLOBAL-SYSTEM-ADMINISTRATORS'
);

IF @GroupGUID IS NULL
BEGIN
    THROW 50002, N'Security.Groups row GLOBAL-SYSTEM-ADMINISTRATORS could not be resolved after create-if-missing.', 1;
END

-- 3) Grant membership for each distinct admin UPN
DECLARE @Upn NVARCHAR(320);
DECLARE @UserGUID UNIQUEIDENTIFIER;
DECLARE @Missing INT = 0;

DECLARE admin_cursor CURSOR LOCAL FAST_FORWARD FOR
    SELECT DISTINCT [Upn] FROM @BootstrapPairs;

OPEN admin_cursor;
FETCH NEXT FROM admin_cursor INTO @Upn;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @UserGUID =
    (
        SELECT TOP (1) [UserGUID]
        FROM [Identity].[Users]
        WHERE [UserPrincipalName] = @Upn
           OR [Email] = @Upn
    );

    IF @UserGUID IS NULL
    BEGIN
        PRINT N'Missing Identity.Users row for: ' + @Upn;
        SET @Missing = @Missing + 1;
    END
    ELSE IF NOT EXISTS (
        SELECT 1
        FROM [Security].[GroupsMembers]
        WHERE [GroupGUID] = @GroupGUID AND [UserGUID] = @UserGUID
    )
    BEGIN
        INSERT INTO [Security].[GroupsMembers]
        (
            [GroupGUID],
            [UserGUID],
            [CreatedBy],
            [CreatedDate],
            [LastUpdatedBy],
            [LastUpdatedDate]
        )
        VALUES
        (
            @GroupGUID,
            @UserGUID,
            @Actor,
            @Now,
            @Actor,
            @Now
        );
        PRINT N'Granted GLOBAL-SYSTEM-ADMINISTRATORS to: ' + @Upn;
    END
    ELSE
    BEGIN
        PRINT N'Already a member: ' + @Upn;
    END

    FETCH NEXT FROM admin_cursor INTO @Upn;
END

CLOSE admin_cursor;
DEALLOCATE admin_cursor;

IF @Missing > 0
BEGIN
    THROW 50003, N'One or more bootstrap admin UPNs were not found in Identity.Users. Complete Master Flow Step 6 (first login) for each admin, then re-run this script before Sync Now.', 1;
END

PRINT N'';
PRINT N'Checkpoint G complete (tenants sync-enabled + GLOBAL-SYSTEM-ADMINISTRATORS granted).';
PRINT N'NEXT — Master Flow Step 8: sign in as a bootstrapped admin → EAC /users → Sync Now (when Graph = Yes).';
PRINT N'Authorization cache may lag ~60s; prefer sign out / sign in before opening /users.';
GO
