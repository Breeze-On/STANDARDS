-- =============================================================================
-- Customer / DEV admin bootstrap (Workflow G + sync-enable listed tenants)
-- =============================================================================
-- SSOT procedure: STANDARDS runbooks/customer-onboarding-master-flow.md Step 7
-- Detail: STANDARDS runbooks/customer-onboarding-authorization.md
-- Operator copy: STANDARDS templates/onboarding/bootstrap-global-system-administrators.sql
--
-- What this script does (idempotent):
--   1) Upsert Identity.Tenants for each listed tid and set IsSyncEnabled = 1
--      (insert if missing; update existing rows so Sync Now can run for those tenants)
--   2) Create Security.Groups GLOBAL-SYSTEM-ADMINISTRATORS if missing
--   3) Grant that group to each listed admin UPN (must already exist in Identity.Users
--      from first login — Master Flow Step 6 — or Graph UPN upsert).
--      Existing GSA members are skipped (no error).
--
-- Matching rules:
--   - Entra tenant ids are parsed as UNIQUEIDENTIFIER (GUID string casing ignored)
--   - Admin UPN / Email lookups are case-insensitive
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
    SET @UpnToken = LOWER(LTRIM(RTRIM(SUBSTRING(@Pair, @Pipe + 1, 320))));
    -- UNIQUEIDENTIFIER parse is case-insensitive for standard GUID string forms.
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
        SELECT 1
        FROM @BootstrapPairs
        WHERE [TenantId] = @TenantId
          AND LOWER([Upn]) = @UpnToken
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
       OR LOWER([Upn]) LIKE N'replace-admin@%'
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
    SELECT COUNT(DISTINCT LOWER([Upn])) FROM @BootstrapPairs
);

PRINT N'Bootstrap pairs: '
    + CONVERT(NVARCHAR(11), @TenantCount)
    + N' tenant(s), '
    + CONVERT(NVARCHAR(11), @AdminCount)
    + N' admin UPN(s).';

-- 1) Identity.Tenants — upsert and ensure IsSyncEnabled = 1 for listed tids.
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
            PRINT N'Identity.Tenants already present with IsSyncEnabled=1: ' + CONVERT(NVARCHAR(36), @TenantId);
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
        [IsManuallyCreated],
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
        0,
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

-- 3) Grant membership for each distinct admin UPN (case-insensitive; skip existing members).
DECLARE @Upn NVARCHAR(320);
DECLARE @UserGUID UNIQUEIDENTIFIER;
DECLARE @Missing INT = 0;
DECLARE @Granted INT = 0;
DECLARE @SkippedExisting INT = 0;

DECLARE admin_cursor CURSOR LOCAL FAST_FORWARD FOR
    SELECT DISTINCT LOWER([Upn]) FROM @BootstrapPairs;

OPEN admin_cursor;
FETCH NEXT FROM admin_cursor INTO @Upn;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @UserGUID =
    (
        SELECT TOP (1) [UserGUID]
        FROM [Identity].[Users]
        WHERE LOWER([UserPrincipalName]) = @Upn
           OR LOWER([Email]) = @Upn
        ORDER BY [UsersId]
    );

    IF @UserGUID IS NULL
    BEGIN
        PRINT N'Missing Identity.Users row for: ' + @Upn;
        SET @Missing = @Missing + 1;
    END
    ELSE IF EXISTS (
        SELECT 1
        FROM [Security].[GroupsMembers]
        WHERE [GroupGUID] = @GroupGUID AND [UserGUID] = @UserGUID
    )
    BEGIN
        PRINT N'Already a GLOBAL-SYSTEM-ADMINISTRATORS member; skipped: ' + @Upn;
        SET @SkippedExisting = @SkippedExisting + 1;
    END
    ELSE
    BEGIN
        BEGIN TRY
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
            SET @Granted = @Granted + 1;
        END TRY
        BEGIN CATCH
            -- Concurrent / re-entrant apply: unique (GroupGUID, UserGUID) means already a member.
            IF ERROR_NUMBER() IN (2627, 2601)
            BEGIN
                PRINT N'Already a GLOBAL-SYSTEM-ADMINISTRATORS member; skipped: ' + @Upn;
                SET @SkippedExisting = @SkippedExisting + 1;
            END
            ELSE
            BEGIN
                THROW;
            END
        END CATCH
    END

    FETCH NEXT FROM admin_cursor INTO @Upn;
END

CLOSE admin_cursor;
DEALLOCATE admin_cursor;

PRINT N'Bootstrap membership summary: granted='
    + CONVERT(NVARCHAR(11), @Granted)
    + N', already-member-skipped='
    + CONVERT(NVARCHAR(11), @SkippedExisting)
    + N', missing='
    + CONVERT(NVARCHAR(11), @Missing)
    + N'.';

IF @Missing > 0
BEGIN
    THROW 50003, N'One or more bootstrap admin UPNs were not found in Identity.Users. Complete Master Flow Step 6 (first login) for each missing admin, then re-run this script. Existing GLOBAL-SYSTEM-ADMINISTRATORS members were skipped safely.', 1;
END

PRINT N'';
PRINT N'Checkpoint G complete (GLOBAL-SYSTEM-ADMINISTRATORS granted/verified; listed tenants IsSyncEnabled=1).';
PRINT N'NEXT — sign in as a bootstrapped admin → EAC /users → Sync Now (when Graph = Yes).';
PRINT N'Authorization cache may lag ~60s; prefer sign out / sign in before opening /users.';
GO
