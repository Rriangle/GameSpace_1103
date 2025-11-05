-- ====================================================================
-- Sample Data Extraction Script
-- Extract first 20 rows from each table
-- ====================================================================

SET NOCOUNT ON;

-- List of all tables to extract
DECLARE @tables TABLE (TableName NVARCHAR(128));

INSERT INTO @tables (TableName) VALUES
('Coupon'),
('CouponType'),
('EVoucher'),
('EVoucherRedeemLog'),
('EVoucherToken'),
('EVoucherType'),
('ManagerData'),
('ManagerRole'),
('ManagerRolePermission'),
('MiniGame'),
('Pet'),
('PetBackgroundCostSettings'),
('PetLevelRewardSettings'),
('PetSkinColorCostSettings'),
('SignInRule'),
('SystemSettings'),
('UserSignInStats'),
('User_Wallet'),
('Users'),
('WalletHistory');

-- Extract data from each table
DECLARE @tableName NVARCHAR(128);
DECLARE @sql NVARCHAR(MAX);

DECLARE table_cursor CURSOR FOR
SELECT TableName FROM @tables ORDER BY TableName;

OPEN table_cursor;
FETCH NEXT FROM table_cursor INTO @tableName;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT '';
    PRINT '=== SAMPLE DATA: ' + @tableName + ' (TOP 20) ===';

    SET @sql = 'SELECT TOP 20 * FROM dbo.' + QUOTENAME(@tableName);
    EXEC sp_executesql @sql;

    FETCH NEXT FROM table_cursor INTO @tableName;
END

CLOSE table_cursor;
DEALLOCATE table_cursor;
