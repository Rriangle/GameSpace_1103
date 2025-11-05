-- ====================================================================
-- MiniGame Area 20 Tables - Complete Schema Extraction
-- ====================================================================

SET NOCOUNT ON;

-- Target tables
DECLARE @targetTables TABLE (TableName NVARCHAR(128));
INSERT INTO @targetTables VALUES
('User_Wallet'),('WalletHistory'),('CouponType'),('Coupon'),
('EVoucherType'),('EVoucher'),('EVoucherToken'),('EVoucherRedeemLog'),
('Pet'),('PetSkinColorCostSettings'),('PetBackgroundCostSettings'),('PetLevelRewardSettings'),
('SignInRule'),('UserSignInStats'),('MiniGame'),('SystemSettings'),
('Users'),('ManagerData'),('ManagerRole'),('ManagerRolePermission');

-- ====================================================================
-- 1. COLUMNS FOR TARGET TABLES
-- ====================================================================
PRINT '=== COLUMNS ===';
SELECT
    c.TABLE_NAME AS [Tbl],
    c.ORDINAL_POSITION AS [#],
    c.COLUMN_NAME AS [Col],
    c.DATA_TYPE +
    CASE
        WHEN c.CHARACTER_MAXIMUM_LENGTH = -1 THEN '(MAX)'
        WHEN c.CHARACTER_MAXIMUM_LENGTH IS NOT NULL THEN '(' + CAST(c.CHARACTER_MAXIMUM_LENGTH AS VARCHAR(10)) + ')'
        WHEN c.NUMERIC_PRECISION IS NOT NULL THEN '(' + CAST(c.NUMERIC_PRECISION AS VARCHAR(10)) + ',' + CAST(ISNULL(c.NUMERIC_SCALE, 0) AS VARCHAR(10)) + ')'
        ELSE ''
    END AS [Type],
    c.IS_NULLABLE AS [Null],
    ISNULL(c.COLUMN_DEFAULT, '') AS [Default],
    CASE WHEN COLUMNPROPERTY(OBJECT_ID(c.TABLE_SCHEMA + '.' + c.TABLE_NAME), c.COLUMN_NAME, 'IsIdentity') = 1 THEN 'Y' ELSE '' END AS [ID]
FROM INFORMATION_SCHEMA.COLUMNS c
WHERE c.TABLE_NAME IN (SELECT TableName FROM @targetTables)
ORDER BY c.TABLE_NAME, c.ORDINAL_POSITION;

-- ====================================================================
-- 2. PRIMARY KEYS
-- ====================================================================
PRINT '';
PRINT '=== PRIMARY KEYS ===';
SELECT
    tc.TABLE_NAME AS [Table],
    kcu.COLUMN_NAME AS [PK_Column]
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
INNER JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu ON tc.CONSTRAINT_NAME = kcu.CONSTRAINT_NAME
WHERE tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
    AND tc.TABLE_NAME IN (SELECT TableName FROM @targetTables)
ORDER BY tc.TABLE_NAME, kcu.ORDINAL_POSITION;

-- ====================================================================
-- 3. FOREIGN KEYS
-- ====================================================================
PRINT '';
PRINT '=== FOREIGN KEYS ===';
SELECT
    OBJECT_NAME(fk.parent_object_id) AS [Source_Table],
    COL_NAME(fkc.parent_object_id, fkc.parent_column_id) AS [Source_Col],
    OBJECT_NAME(fk.referenced_object_id) AS [Target_Table],
    COL_NAME(fkc.referenced_object_id, fkc.referenced_column_id) AS [Target_Col]
FROM sys.foreign_keys fk
INNER JOIN sys.foreign_key_columns fkc ON fk.object_id = fkc.constraint_object_id
WHERE OBJECT_NAME(fk.parent_object_id) IN (SELECT TableName FROM @targetTables)
    OR OBJECT_NAME(fk.referenced_object_id) IN (SELECT TableName FROM @targetTables)
ORDER BY OBJECT_NAME(fk.parent_object_id), fkc.constraint_column_id;

-- ====================================================================
-- 4. UNIQUE CONSTRAINTS
-- ====================================================================
PRINT '';
PRINT '=== UNIQUE CONSTRAINTS ===';
SELECT
    tc.TABLE_NAME AS [Table],
    kcu.COLUMN_NAME AS [Column]
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
INNER JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu ON tc.CONSTRAINT_NAME = kcu.CONSTRAINT_NAME
WHERE tc.CONSTRAINT_TYPE = 'UNIQUE'
    AND tc.TABLE_NAME IN (SELECT TableName FROM @targetTables)
ORDER BY tc.TABLE_NAME, kcu.ORDINAL_POSITION;

-- ====================================================================
-- 5. CHECK CONSTRAINTS
-- ====================================================================
PRINT '';
PRINT '=== CHECK CONSTRAINTS ===';
SELECT
    cc.TABLE_NAME AS [Table],
    LEFT(cc.CHECK_CLAUSE, 100) AS [Check_Clause]
FROM INFORMATION_SCHEMA.CHECK_CONSTRAINTS cc
WHERE cc.TABLE_NAME IN (SELECT TableName FROM @targetTables)
ORDER BY cc.TABLE_NAME, cc.CONSTRAINT_NAME;

-- ====================================================================
-- 6. INDEXES
-- ====================================================================
PRINT '';
PRINT '=== INDEXES ===';
SELECT
    t.name AS [Table],
    i.name AS [Index],
    c.name AS [Column],
    i.type_desc AS [Type],
    CASE WHEN i.is_unique = 1 THEN 'Y' ELSE 'N' END AS [Uniq]
FROM sys.indexes i
INNER JOIN sys.tables t ON i.object_id = t.object_id
INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
INNER JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
WHERE i.name IS NOT NULL
    AND t.name IN (SELECT TableName FROM @targetTables)
ORDER BY t.name, i.name, ic.key_ordinal;

-- ====================================================================
-- 7. ROW COUNTS
-- ====================================================================
PRINT '';
PRINT '=== ROW COUNTS ===';
SELECT
    t.name AS [Table],
    SUM(p.rows) AS [Rows]
FROM sys.tables t
INNER JOIN sys.partitions p ON t.object_id = p.object_id
WHERE p.index_id IN (0, 1)
    AND t.name IN (SELECT TableName FROM @targetTables)
GROUP BY t.name
ORDER BY t.name;
