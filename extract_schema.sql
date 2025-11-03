-- ====================================================================
-- SQL Server Schema Extraction Script
-- Database: GameSpacedatabase
-- Server: DESKTOP-8HQIS1S\SQLEXPRESS
-- ====================================================================

USE GameSpacedatabase;
GO

-- Set to display results in text format for easier parsing
SET NOCOUNT ON;
GO

-- ====================================================================
-- Table: Coupon
-- ====================================================================
PRINT '=== TABLE: Coupon ===';
PRINT '';
PRINT '--- Columns ---';
SELECT
    c.COLUMN_NAME,
    c.DATA_TYPE,
    c.CHARACTER_MAXIMUM_LENGTH,
    c.NUMERIC_PRECISION,
    c.NUMERIC_SCALE,
    c.IS_NULLABLE,
    c.COLUMN_DEFAULT,
    COLUMNPROPERTY(OBJECT_ID(c.TABLE_SCHEMA + '.' + c.TABLE_NAME), c.COLUMN_NAME, 'IsIdentity') AS IS_IDENTITY
FROM INFORMATION_SCHEMA.COLUMNS c
WHERE c.TABLE_NAME = 'Coupon'
ORDER BY c.ORDINAL_POSITION;

PRINT '';
PRINT '--- Primary Key ---';
SELECT kcu.COLUMN_NAME
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu ON tc.CONSTRAINT_NAME = kcu.CONSTRAINT_NAME
WHERE tc.TABLE_NAME = 'Coupon' AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY';

PRINT '';
PRINT '--- Foreign Keys ---';
SELECT
    fk.name AS FK_NAME,
    OBJECT_NAME(fk.parent_object_id) AS TABLE_NAME,
    COL_NAME(fc.parent_object_id, fc.parent_column_id) AS COLUMN_NAME,
    OBJECT_NAME(fk.referenced_object_id) AS REFERENCED_TABLE,
    COL_NAME(fc.referenced_object_id, fc.referenced_column_id) AS REFERENCED_COLUMN
FROM sys.foreign_keys AS fk
INNER JOIN sys.foreign_key_columns AS fc ON fk.object_id = fc.constraint_object_id
WHERE OBJECT_NAME(fk.parent_object_id) = 'Coupon';

PRINT '';
PRINT '--- Indexes ---';
SELECT
    i.name AS INDEX_NAME,
    i.type_desc,
    i.is_unique,
    COL_NAME(ic.object_id, ic.column_id) AS COLUMN_NAME
FROM sys.indexes i
INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
WHERE OBJECT_NAME(i.object_id) = 'Coupon' AND i.name IS NOT NULL
ORDER BY i.name, ic.key_ordinal;

PRINT '';
PRINT '--- Check Constraints ---';
SELECT
    cc.name AS CONSTRAINT_NAME,
    cc.definition
FROM sys.check_constraints cc
WHERE OBJECT_NAME(cc.parent_object_id) = 'Coupon';

PRINT '';
PRINT '';

-- ====================================================================
-- Table: CouponType
-- ====================================================================
PRINT '=== TABLE: CouponType ===';
PRINT '';
PRINT '--- Columns ---';
SELECT
    c.COLUMN_NAME,
    c.DATA_TYPE,
    c.CHARACTER_MAXIMUM_LENGTH,
    c.NUMERIC_PRECISION,
    c.NUMERIC_SCALE,
    c.IS_NULLABLE,
    c.COLUMN_DEFAULT,
    COLUMNPROPERTY(OBJECT_ID(c.TABLE_SCHEMA + '.' + c.TABLE_NAME), c.COLUMN_NAME, 'IsIdentity') AS IS_IDENTITY
FROM INFORMATION_SCHEMA.COLUMNS c
WHERE c.TABLE_NAME = 'CouponType'
ORDER BY c.ORDINAL_POSITION;

PRINT '';
PRINT '--- Primary Key ---';
SELECT kcu.COLUMN_NAME
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu ON tc.CONSTRAINT_NAME = kcu.CONSTRAINT_NAME
WHERE tc.TABLE_NAME = 'CouponType' AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY';

PRINT '';
PRINT '--- Foreign Keys ---';
SELECT
    fk.name AS FK_NAME,
    OBJECT_NAME(fk.parent_object_id) AS TABLE_NAME,
    COL_NAME(fc.parent_object_id, fc.parent_column_id) AS COLUMN_NAME,
    OBJECT_NAME(fk.referenced_object_id) AS REFERENCED_TABLE,
    COL_NAME(fc.referenced_object_id, fc.referenced_column_id) AS REFERENCED_COLUMN
FROM sys.foreign_keys AS fk
INNER JOIN sys.foreign_key_columns AS fc ON fk.object_id = fc.constraint_object_id
WHERE OBJECT_NAME(fk.parent_object_id) = 'CouponType';

PRINT '';
PRINT '--- Indexes ---';
SELECT
    i.name AS INDEX_NAME,
    i.type_desc,
    i.is_unique,
    COL_NAME(ic.object_id, ic.column_id) AS COLUMN_NAME
FROM sys.indexes i
INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
WHERE OBJECT_NAME(i.object_id) = 'CouponType' AND i.name IS NOT NULL
ORDER BY i.name, ic.key_ordinal;

PRINT '';
PRINT '--- Check Constraints ---';
SELECT
    cc.name AS CONSTRAINT_NAME,
    cc.definition
FROM sys.check_constraints cc
WHERE OBJECT_NAME(cc.parent_object_id) = 'CouponType';

PRINT '';
PRINT '';

-- ====================================================================
-- Table: EVoucher
-- ====================================================================
PRINT '=== TABLE: EVoucher ===';
PRINT '';
PRINT '--- Columns ---';
SELECT
    c.COLUMN_NAME,
    c.DATA_TYPE,
    c.CHARACTER_MAXIMUM_LENGTH,
    c.NUMERIC_PRECISION,
    c.NUMERIC_SCALE,
    c.IS_NULLABLE,
    c.COLUMN_DEFAULT,
    COLUMNPROPERTY(OBJECT_ID(c.TABLE_SCHEMA + '.' + c.TABLE_NAME), c.COLUMN_NAME, 'IsIdentity') AS IS_IDENTITY
FROM INFORMATION_SCHEMA.COLUMNS c
WHERE c.TABLE_NAME = 'EVoucher'
ORDER BY c.ORDINAL_POSITION;

PRINT '';
PRINT '--- Primary Key ---';
SELECT kcu.COLUMN_NAME
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu ON tc.CONSTRAINT_NAME = kcu.CONSTRAINT_NAME
WHERE tc.TABLE_NAME = 'EVoucher' AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY';

PRINT '';
PRINT '--- Foreign Keys ---';
SELECT
    fk.name AS FK_NAME,
    OBJECT_NAME(fk.parent_object_id) AS TABLE_NAME,
    COL_NAME(fc.parent_object_id, fc.parent_column_id) AS COLUMN_NAME,
    OBJECT_NAME(fk.referenced_object_id) AS REFERENCED_TABLE,
    COL_NAME(fc.referenced_object_id, fc.referenced_column_id) AS REFERENCED_COLUMN
FROM sys.foreign_keys AS fk
INNER JOIN sys.foreign_key_columns AS fc ON fk.object_id = fc.constraint_object_id
WHERE OBJECT_NAME(fk.parent_object_id) = 'EVoucher';

PRINT '';
PRINT '--- Indexes ---';
SELECT
    i.name AS INDEX_NAME,
    i.type_desc,
    i.is_unique,
    COL_NAME(ic.object_id, ic.column_id) AS COLUMN_NAME
FROM sys.indexes i
INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
WHERE OBJECT_NAME(i.object_id) = 'EVoucher' AND i.name IS NOT NULL
ORDER BY i.name, ic.key_ordinal;

PRINT '';
PRINT '--- Check Constraints ---';
SELECT
    cc.name AS CONSTRAINT_NAME,
    cc.definition
FROM sys.check_constraints cc
WHERE OBJECT_NAME(cc.parent_object_id) = 'EVoucher';

PRINT '';
PRINT '';

-- ====================================================================
-- Table: EVoucherRedeemLog
-- ====================================================================
PRINT '=== TABLE: EVoucherRedeemLog ===';
PRINT '';
PRINT '--- Columns ---';
SELECT
    c.COLUMN_NAME,
    c.DATA_TYPE,
    c.CHARACTER_MAXIMUM_LENGTH,
    c.NUMERIC_PRECISION,
    c.NUMERIC_SCALE,
    c.IS_NULLABLE,
    c.COLUMN_DEFAULT,
    COLUMNPROPERTY(OBJECT_ID(c.TABLE_SCHEMA + '.' + c.TABLE_NAME), c.COLUMN_NAME, 'IsIdentity') AS IS_IDENTITY
FROM INFORMATION_SCHEMA.COLUMNS c
WHERE c.TABLE_NAME = 'EVoucherRedeemLog'
ORDER BY c.ORDINAL_POSITION;

PRINT '';
PRINT '--- Primary Key ---';
SELECT kcu.COLUMN_NAME
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu ON tc.CONSTRAINT_NAME = kcu.CONSTRAINT_NAME
WHERE tc.TABLE_NAME = 'EVoucherRedeemLog' AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY';

PRINT '';
PRINT '--- Foreign Keys ---';
SELECT
    fk.name AS FK_NAME,
    OBJECT_NAME(fk.parent_object_id) AS TABLE_NAME,
    COL_NAME(fc.parent_object_id, fc.parent_column_id) AS COLUMN_NAME,
    OBJECT_NAME(fk.referenced_object_id) AS REFERENCED_TABLE,
    COL_NAME(fc.referenced_object_id, fc.referenced_column_id) AS REFERENCED_COLUMN
FROM sys.foreign_keys AS fk
INNER JOIN sys.foreign_key_columns AS fc ON fk.object_id = fc.constraint_object_id
WHERE OBJECT_NAME(fk.parent_object_id) = 'EVoucherRedeemLog';

PRINT '';
PRINT '--- Indexes ---';
SELECT
    i.name AS INDEX_NAME,
    i.type_desc,
    i.is_unique,
    COL_NAME(ic.object_id, ic.column_id) AS COLUMN_NAME
FROM sys.indexes i
INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
WHERE OBJECT_NAME(i.object_id) = 'EVoucherRedeemLog' AND i.name IS NOT NULL
ORDER BY i.name, ic.key_ordinal;

PRINT '';
PRINT '--- Check Constraints ---';
SELECT
    cc.name AS CONSTRAINT_NAME,
    cc.definition
FROM sys.check_constraints cc
WHERE OBJECT_NAME(cc.parent_object_id) = 'EVoucherRedeemLog';

PRINT '';
PRINT '';

-- ====================================================================
-- Table: EVoucherToken
-- ====================================================================
PRINT '=== TABLE: EVoucherToken ===';
PRINT '';
PRINT '--- Columns ---';
SELECT
    c.COLUMN_NAME,
    c.DATA_TYPE,
    c.CHARACTER_MAXIMUM_LENGTH,
    c.NUMERIC_PRECISION,
    c.NUMERIC_SCALE,
    c.IS_NULLABLE,
    c.COLUMN_DEFAULT,
    COLUMNPROPERTY(OBJECT_ID(c.TABLE_SCHEMA + '.' + c.TABLE_NAME), c.COLUMN_NAME, 'IsIdentity') AS IS_IDENTITY
FROM INFORMATION_SCHEMA.COLUMNS c
WHERE c.TABLE_NAME = 'EVoucherToken'
ORDER BY c.ORDINAL_POSITION;

PRINT '';
PRINT '--- Primary Key ---';
SELECT kcu.COLUMN_NAME
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu ON tc.CONSTRAINT_NAME = kcu.CONSTRAINT_NAME
WHERE tc.TABLE_NAME = 'EVoucherToken' AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY';

PRINT '';
PRINT '--- Foreign Keys ---';
SELECT
    fk.name AS FK_NAME,
    OBJECT_NAME(fk.parent_object_id) AS TABLE_NAME,
    COL_NAME(fc.parent_object_id, fc.parent_column_id) AS COLUMN_NAME,
    OBJECT_NAME(fk.referenced_object_id) AS REFERENCED_TABLE,
    COL_NAME(fc.referenced_object_id, fc.referenced_column_id) AS REFERENCED_COLUMN
FROM sys.foreign_keys AS fk
INNER JOIN sys.foreign_key_columns AS fc ON fk.object_id = fc.constraint_object_id
WHERE OBJECT_NAME(fk.parent_object_id) = 'EVoucherToken';

PRINT '';
PRINT '--- Indexes ---';
SELECT
    i.name AS INDEX_NAME,
    i.type_desc,
    i.is_unique,
    COL_NAME(ic.object_id, ic.column_id) AS COLUMN_NAME
FROM sys.indexes i
INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
WHERE OBJECT_NAME(i.object_id) = 'EVoucherToken' AND i.name IS NOT NULL
ORDER BY i.name, ic.key_ordinal;

PRINT '';
PRINT '--- Check Constraints ---';
SELECT
    cc.name AS CONSTRAINT_NAME,
    cc.definition
FROM sys.check_constraints cc
WHERE OBJECT_NAME(cc.parent_object_id) = 'EVoucherToken';

PRINT '';
PRINT '';

-- ====================================================================
-- Table: EVoucherType
-- ====================================================================
PRINT '=== TABLE: EVoucherType ===';
PRINT '';
PRINT '--- Columns ---';
SELECT
    c.COLUMN_NAME,
    c.DATA_TYPE,
    c.CHARACTER_MAXIMUM_LENGTH,
    c.NUMERIC_PRECISION,
    c.NUMERIC_SCALE,
    c.IS_NULLABLE,
    c.COLUMN_DEFAULT,
    COLUMNPROPERTY(OBJECT_ID(c.TABLE_SCHEMA + '.' + c.TABLE_NAME), c.COLUMN_NAME, 'IsIdentity') AS IS_IDENTITY
FROM INFORMATION_SCHEMA.COLUMNS c
WHERE c.TABLE_NAME = 'EVoucherType'
ORDER BY c.ORDINAL_POSITION;

PRINT '';
PRINT '--- Primary Key ---';
SELECT kcu.COLUMN_NAME
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu ON tc.CONSTRAINT_NAME = kcu.CONSTRAINT_NAME
WHERE tc.TABLE_NAME = 'EVoucherType' AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY';

PRINT '';
PRINT '--- Foreign Keys ---';
SELECT
    fk.name AS FK_NAME,
    OBJECT_NAME(fk.parent_object_id) AS TABLE_NAME,
    COL_NAME(fc.parent_object_id, fc.parent_column_id) AS COLUMN_NAME,
    OBJECT_NAME(fk.referenced_object_id) AS REFERENCED_TABLE,
    COL_NAME(fc.referenced_object_id, fc.referenced_column_id) AS REFERENCED_COLUMN
FROM sys.foreign_keys AS fk
INNER JOIN sys.foreign_key_columns AS fc ON fk.object_id = fc.constraint_object_id
WHERE OBJECT_NAME(fk.parent_object_id) = 'EVoucherType';

PRINT '';
PRINT '--- Indexes ---';
SELECT
    i.name AS INDEX_NAME,
    i.type_desc,
    i.is_unique,
    COL_NAME(ic.object_id, ic.column_id) AS COLUMN_NAME
FROM sys.indexes i
INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
WHERE OBJECT_NAME(i.object_id) = 'EVoucherType' AND i.name IS NOT NULL
ORDER BY i.name, ic.key_ordinal;

PRINT '';
PRINT '--- Check Constraints ---';
SELECT
    cc.name AS CONSTRAINT_NAME,
    cc.definition
FROM sys.check_constraints cc
WHERE OBJECT_NAME(cc.parent_object_id) = 'EVoucherType';

PRINT '';
PRINT '';

-- ====================================================================
-- Table: MiniGame
-- ====================================================================
PRINT '=== TABLE: MiniGame ===';
PRINT '';
PRINT '--- Columns ---';
SELECT
    c.COLUMN_NAME,
    c.DATA_TYPE,
    c.CHARACTER_MAXIMUM_LENGTH,
    c.NUMERIC_PRECISION,
    c.NUMERIC_SCALE,
    c.IS_NULLABLE,
    c.COLUMN_DEFAULT,
    COLUMNPROPERTY(OBJECT_ID(c.TABLE_SCHEMA + '.' + c.TABLE_NAME), c.COLUMN_NAME, 'IsIdentity') AS IS_IDENTITY
FROM INFORMATION_SCHEMA.COLUMNS c
WHERE c.TABLE_NAME = 'MiniGame'
ORDER BY c.ORDINAL_POSITION;

PRINT '';
PRINT '--- Primary Key ---';
SELECT kcu.COLUMN_NAME
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu ON tc.CONSTRAINT_NAME = kcu.CONSTRAINT_NAME
WHERE tc.TABLE_NAME = 'MiniGame' AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY';

PRINT '';
PRINT '--- Foreign Keys ---';
SELECT
    fk.name AS FK_NAME,
    OBJECT_NAME(fk.parent_object_id) AS TABLE_NAME,
    COL_NAME(fc.parent_object_id, fc.parent_column_id) AS COLUMN_NAME,
    OBJECT_NAME(fk.referenced_object_id) AS REFERENCED_TABLE,
    COL_NAME(fc.referenced_object_id, fc.referenced_column_id) AS REFERENCED_COLUMN
FROM sys.foreign_keys AS fk
INNER JOIN sys.foreign_key_columns AS fc ON fk.object_id = fc.constraint_object_id
WHERE OBJECT_NAME(fk.parent_object_id) = 'MiniGame';

PRINT '';
PRINT '--- Indexes ---';
SELECT
    i.name AS INDEX_NAME,
    i.type_desc,
    i.is_unique,
    COL_NAME(ic.object_id, ic.column_id) AS COLUMN_NAME
FROM sys.indexes i
INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
WHERE OBJECT_NAME(i.object_id) = 'MiniGame' AND i.name IS NOT NULL
ORDER BY i.name, ic.key_ordinal;

PRINT '';
PRINT '--- Check Constraints ---';
SELECT
    cc.name AS CONSTRAINT_NAME,
    cc.definition
FROM sys.check_constraints cc
WHERE OBJECT_NAME(cc.parent_object_id) = 'MiniGame';

PRINT '';
PRINT '';

-- ====================================================================
-- Table: Pet
-- ====================================================================
PRINT '=== TABLE: Pet ===';
PRINT '';
PRINT '--- Columns ---';
SELECT
    c.COLUMN_NAME,
    c.DATA_TYPE,
    c.CHARACTER_MAXIMUM_LENGTH,
    c.NUMERIC_PRECISION,
    c.NUMERIC_SCALE,
    c.IS_NULLABLE,
    c.COLUMN_DEFAULT,
    COLUMNPROPERTY(OBJECT_ID(c.TABLE_SCHEMA + '.' + c.TABLE_NAME), c.COLUMN_NAME, 'IsIdentity') AS IS_IDENTITY
FROM INFORMATION_SCHEMA.COLUMNS c
WHERE c.TABLE_NAME = 'Pet'
ORDER BY c.ORDINAL_POSITION;

PRINT '';
PRINT '--- Primary Key ---';
SELECT kcu.COLUMN_NAME
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu ON tc.CONSTRAINT_NAME = kcu.CONSTRAINT_NAME
WHERE tc.TABLE_NAME = 'Pet' AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY';

PRINT '';
PRINT '--- Foreign Keys ---';
SELECT
    fk.name AS FK_NAME,
    OBJECT_NAME(fk.parent_object_id) AS TABLE_NAME,
    COL_NAME(fc.parent_object_id, fc.parent_column_id) AS COLUMN_NAME,
    OBJECT_NAME(fk.referenced_object_id) AS REFERENCED_TABLE,
    COL_NAME(fc.referenced_object_id, fc.referenced_column_id) AS REFERENCED_COLUMN
FROM sys.foreign_keys AS fk
INNER JOIN sys.foreign_key_columns AS fc ON fk.object_id = fc.constraint_object_id
WHERE OBJECT_NAME(fk.parent_object_id) = 'Pet';

PRINT '';
PRINT '--- Indexes ---';
SELECT
    i.name AS INDEX_NAME,
    i.type_desc,
    i.is_unique,
    COL_NAME(ic.object_id, ic.column_id) AS COLUMN_NAME
FROM sys.indexes i
INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
WHERE OBJECT_NAME(i.object_id) = 'Pet' AND i.name IS NOT NULL
ORDER BY i.name, ic.key_ordinal;

PRINT '';
PRINT '--- Check Constraints ---';
SELECT
    cc.name AS CONSTRAINT_NAME,
    cc.definition
FROM sys.check_constraints cc
WHERE OBJECT_NAME(cc.parent_object_id) = 'Pet';

PRINT '';
PRINT '';

-- ====================================================================
-- Table: PetBackgroundCostSettings
-- ====================================================================
PRINT '=== TABLE: PetBackgroundCostSettings ===';
PRINT '';
PRINT '--- Columns ---';
SELECT
    c.COLUMN_NAME,
    c.DATA_TYPE,
    c.CHARACTER_MAXIMUM_LENGTH,
    c.NUMERIC_PRECISION,
    c.NUMERIC_SCALE,
    c.IS_NULLABLE,
    c.COLUMN_DEFAULT,
    COLUMNPROPERTY(OBJECT_ID(c.TABLE_SCHEMA + '.' + c.TABLE_NAME), c.COLUMN_NAME, 'IsIdentity') AS IS_IDENTITY
FROM INFORMATION_SCHEMA.COLUMNS c
WHERE c.TABLE_NAME = 'PetBackgroundCostSettings'
ORDER BY c.ORDINAL_POSITION;

PRINT '';
PRINT '--- Primary Key ---';
SELECT kcu.COLUMN_NAME
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu ON tc.CONSTRAINT_NAME = kcu.CONSTRAINT_NAME
WHERE tc.TABLE_NAME = 'PetBackgroundCostSettings' AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY';

PRINT '';
PRINT '--- Foreign Keys ---';
SELECT
    fk.name AS FK_NAME,
    OBJECT_NAME(fk.parent_object_id) AS TABLE_NAME,
    COL_NAME(fc.parent_object_id, fc.parent_column_id) AS COLUMN_NAME,
    OBJECT_NAME(fk.referenced_object_id) AS REFERENCED_TABLE,
    COL_NAME(fc.referenced_object_id, fc.referenced_column_id) AS REFERENCED_COLUMN
FROM sys.foreign_keys AS fk
INNER JOIN sys.foreign_key_columns AS fc ON fk.object_id = fc.constraint_object_id
WHERE OBJECT_NAME(fk.parent_object_id) = 'PetBackgroundCostSettings';

PRINT '';
PRINT '--- Indexes ---';
SELECT
    i.name AS INDEX_NAME,
    i.type_desc,
    i.is_unique,
    COL_NAME(ic.object_id, ic.column_id) AS COLUMN_NAME
FROM sys.indexes i
INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
WHERE OBJECT_NAME(i.object_id) = 'PetBackgroundCostSettings' AND i.name IS NOT NULL
ORDER BY i.name, ic.key_ordinal;

PRINT '';
PRINT '--- Check Constraints ---';
SELECT
    cc.name AS CONSTRAINT_NAME,
    cc.definition
FROM sys.check_constraints cc
WHERE OBJECT_NAME(cc.parent_object_id) = 'PetBackgroundCostSettings';

PRINT '';
PRINT '';

-- ====================================================================
-- Table: PetLevelRewardSettings
-- ====================================================================
PRINT '=== TABLE: PetLevelRewardSettings ===';
PRINT '';
PRINT '--- Columns ---';
SELECT
    c.COLUMN_NAME,
    c.DATA_TYPE,
    c.CHARACTER_MAXIMUM_LENGTH,
    c.NUMERIC_PRECISION,
    c.NUMERIC_SCALE,
    c.IS_NULLABLE,
    c.COLUMN_DEFAULT,
    COLUMNPROPERTY(OBJECT_ID(c.TABLE_SCHEMA + '.' + c.TABLE_NAME), c.COLUMN_NAME, 'IsIdentity') AS IS_IDENTITY
FROM INFORMATION_SCHEMA.COLUMNS c
WHERE c.TABLE_NAME = 'PetLevelRewardSettings'
ORDER BY c.ORDINAL_POSITION;

PRINT '';
PRINT '--- Primary Key ---';
SELECT kcu.COLUMN_NAME
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu ON tc.CONSTRAINT_NAME = kcu.CONSTRAINT_NAME
WHERE tc.TABLE_NAME = 'PetLevelRewardSettings' AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY';

PRINT '';
PRINT '--- Foreign Keys ---';
SELECT
    fk.name AS FK_NAME,
    OBJECT_NAME(fk.parent_object_id) AS TABLE_NAME,
    COL_NAME(fc.parent_object_id, fc.parent_column_id) AS COLUMN_NAME,
    OBJECT_NAME(fk.referenced_object_id) AS REFERENCED_TABLE,
    COL_NAME(fc.referenced_object_id, fc.referenced_column_id) AS REFERENCED_COLUMN
FROM sys.foreign_keys AS fk
INNER JOIN sys.foreign_key_columns AS fc ON fk.object_id = fc.constraint_object_id
WHERE OBJECT_NAME(fk.parent_object_id) = 'PetLevelRewardSettings';

PRINT '';
PRINT '--- Indexes ---';
SELECT
    i.name AS INDEX_NAME,
    i.type_desc,
    i.is_unique,
    COL_NAME(ic.object_id, ic.column_id) AS COLUMN_NAME
FROM sys.indexes i
INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
WHERE OBJECT_NAME(i.object_id) = 'PetLevelRewardSettings' AND i.name IS NOT NULL
ORDER BY i.name, ic.key_ordinal;

PRINT '';
PRINT '--- Check Constraints ---';
SELECT
    cc.name AS CONSTRAINT_NAME,
    cc.definition
FROM sys.check_constraints cc
WHERE OBJECT_NAME(cc.parent_object_id) = 'PetLevelRewardSettings';

PRINT '';
PRINT '';

-- ====================================================================
-- Table: PetSkinColorCostSettings
-- ====================================================================
PRINT '=== TABLE: PetSkinColorCostSettings ===';
PRINT '';
PRINT '--- Columns ---';
SELECT
    c.COLUMN_NAME,
    c.DATA_TYPE,
    c.CHARACTER_MAXIMUM_LENGTH,
    c.NUMERIC_PRECISION,
    c.NUMERIC_SCALE,
    c.IS_NULLABLE,
    c.COLUMN_DEFAULT,
    COLUMNPROPERTY(OBJECT_ID(c.TABLE_SCHEMA + '.' + c.TABLE_NAME), c.COLUMN_NAME, 'IsIdentity') AS IS_IDENTITY
FROM INFORMATION_SCHEMA.COLUMNS c
WHERE c.TABLE_NAME = 'PetSkinColorCostSettings'
ORDER BY c.ORDINAL_POSITION;

PRINT '';
PRINT '--- Primary Key ---';
SELECT kcu.COLUMN_NAME
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu ON tc.CONSTRAINT_NAME = kcu.CONSTRAINT_NAME
WHERE tc.TABLE_NAME = 'PetSkinColorCostSettings' AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY';

PRINT '';
PRINT '--- Foreign Keys ---';
SELECT
    fk.name AS FK_NAME,
    OBJECT_NAME(fk.parent_object_id) AS TABLE_NAME,
    COL_NAME(fc.parent_object_id, fc.parent_column_id) AS COLUMN_NAME,
    OBJECT_NAME(fk.referenced_object_id) AS REFERENCED_TABLE,
    COL_NAME(fc.referenced_object_id, fc.referenced_column_id) AS REFERENCED_COLUMN
FROM sys.foreign_keys AS fk
INNER JOIN sys.foreign_key_columns AS fc ON fk.object_id = fc.constraint_object_id
WHERE OBJECT_NAME(fk.parent_object_id) = 'PetSkinColorCostSettings';

PRINT '';
PRINT '--- Indexes ---';
SELECT
    i.name AS INDEX_NAME,
    i.type_desc,
    i.is_unique,
    COL_NAME(ic.object_id, ic.column_id) AS COLUMN_NAME
FROM sys.indexes i
INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
WHERE OBJECT_NAME(i.object_id) = 'PetSkinColorCostSettings' AND i.name IS NOT NULL
ORDER BY i.name, ic.key_ordinal;

PRINT '';
PRINT '--- Check Constraints ---';
SELECT
    cc.name AS CONSTRAINT_NAME,
    cc.definition
FROM sys.check_constraints cc
WHERE OBJECT_NAME(cc.parent_object_id) = 'PetSkinColorCostSettings';

PRINT '';
PRINT '';

-- ====================================================================
-- Table: SignInRule
-- ====================================================================
PRINT '=== TABLE: SignInRule ===';
PRINT '';
PRINT '--- Columns ---';
SELECT
    c.COLUMN_NAME,
    c.DATA_TYPE,
    c.CHARACTER_MAXIMUM_LENGTH,
    c.NUMERIC_PRECISION,
    c.NUMERIC_SCALE,
    c.IS_NULLABLE,
    c.COLUMN_DEFAULT,
    COLUMNPROPERTY(OBJECT_ID(c.TABLE_SCHEMA + '.' + c.TABLE_NAME), c.COLUMN_NAME, 'IsIdentity') AS IS_IDENTITY
FROM INFORMATION_SCHEMA.COLUMNS c
WHERE c.TABLE_NAME = 'SignInRule'
ORDER BY c.ORDINAL_POSITION;

PRINT '';
PRINT '--- Primary Key ---';
SELECT kcu.COLUMN_NAME
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu ON tc.CONSTRAINT_NAME = kcu.CONSTRAINT_NAME
WHERE tc.TABLE_NAME = 'SignInRule' AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY';

PRINT '';
PRINT '--- Foreign Keys ---';
SELECT
    fk.name AS FK_NAME,
    OBJECT_NAME(fk.parent_object_id) AS TABLE_NAME,
    COL_NAME(fc.parent_object_id, fc.parent_column_id) AS COLUMN_NAME,
    OBJECT_NAME(fk.referenced_object_id) AS REFERENCED_TABLE,
    COL_NAME(fc.referenced_object_id, fc.referenced_column_id) AS REFERENCED_COLUMN
FROM sys.foreign_keys AS fk
INNER JOIN sys.foreign_key_columns AS fc ON fk.object_id = fc.constraint_object_id
WHERE OBJECT_NAME(fk.parent_object_id) = 'SignInRule';

PRINT '';
PRINT '--- Indexes ---';
SELECT
    i.name AS INDEX_NAME,
    i.type_desc,
    i.is_unique,
    COL_NAME(ic.object_id, ic.column_id) AS COLUMN_NAME
FROM sys.indexes i
INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
WHERE OBJECT_NAME(i.object_id) = 'SignInRule' AND i.name IS NOT NULL
ORDER BY i.name, ic.key_ordinal;

PRINT '';
PRINT '--- Check Constraints ---';
SELECT
    cc.name AS CONSTRAINT_NAME,
    cc.definition
FROM sys.check_constraints cc
WHERE OBJECT_NAME(cc.parent_object_id) = 'SignInRule';

PRINT '';
PRINT '';

-- ====================================================================
-- Table: SystemSettings
-- ====================================================================
PRINT '=== TABLE: SystemSettings ===';
PRINT '';
PRINT '--- Columns ---';
SELECT
    c.COLUMN_NAME,
    c.DATA_TYPE,
    c.CHARACTER_MAXIMUM_LENGTH,
    c.NUMERIC_PRECISION,
    c.NUMERIC_SCALE,
    c.IS_NULLABLE,
    c.COLUMN_DEFAULT,
    COLUMNPROPERTY(OBJECT_ID(c.TABLE_SCHEMA + '.' + c.TABLE_NAME), c.COLUMN_NAME, 'IsIdentity') AS IS_IDENTITY
FROM INFORMATION_SCHEMA.COLUMNS c
WHERE c.TABLE_NAME = 'SystemSettings'
ORDER BY c.ORDINAL_POSITION;

PRINT '';
PRINT '--- Primary Key ---';
SELECT kcu.COLUMN_NAME
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu ON tc.CONSTRAINT_NAME = kcu.CONSTRAINT_NAME
WHERE tc.TABLE_NAME = 'SystemSettings' AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY';

PRINT '';
PRINT '--- Foreign Keys ---';
SELECT
    fk.name AS FK_NAME,
    OBJECT_NAME(fk.parent_object_id) AS TABLE_NAME,
    COL_NAME(fc.parent_object_id, fc.parent_column_id) AS COLUMN_NAME,
    OBJECT_NAME(fk.referenced_object_id) AS REFERENCED_TABLE,
    COL_NAME(fc.referenced_object_id, fc.referenced_column_id) AS REFERENCED_COLUMN
FROM sys.foreign_keys AS fk
INNER JOIN sys.foreign_key_columns AS fc ON fk.object_id = fc.constraint_object_id
WHERE OBJECT_NAME(fk.parent_object_id) = 'SystemSettings';

PRINT '';
PRINT '--- Indexes ---';
SELECT
    i.name AS INDEX_NAME,
    i.type_desc,
    i.is_unique,
    COL_NAME(ic.object_id, ic.column_id) AS COLUMN_NAME
FROM sys.indexes i
INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
WHERE OBJECT_NAME(i.object_id) = 'SystemSettings' AND i.name IS NOT NULL
ORDER BY i.name, ic.key_ordinal;

PRINT '';
PRINT '--- Check Constraints ---';
SELECT
    cc.name AS CONSTRAINT_NAME,
    cc.definition
FROM sys.check_constraints cc
WHERE OBJECT_NAME(cc.parent_object_id) = 'SystemSettings';

PRINT '';
PRINT '';

-- ====================================================================
-- Table: User_Wallet
-- ====================================================================
PRINT '=== TABLE: User_Wallet ===';
PRINT '';
PRINT '--- Columns ---';
SELECT
    c.COLUMN_NAME,
    c.DATA_TYPE,
    c.CHARACTER_MAXIMUM_LENGTH,
    c.NUMERIC_PRECISION,
    c.NUMERIC_SCALE,
    c.IS_NULLABLE,
    c.COLUMN_DEFAULT,
    COLUMNPROPERTY(OBJECT_ID(c.TABLE_SCHEMA + '.' + c.TABLE_NAME), c.COLUMN_NAME, 'IsIdentity') AS IS_IDENTITY
FROM INFORMATION_SCHEMA.COLUMNS c
WHERE c.TABLE_NAME = 'User_Wallet'
ORDER BY c.ORDINAL_POSITION;

PRINT '';
PRINT '--- Primary Key ---';
SELECT kcu.COLUMN_NAME
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu ON tc.CONSTRAINT_NAME = kcu.CONSTRAINT_NAME
WHERE tc.TABLE_NAME = 'User_Wallet' AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY';

PRINT '';
PRINT '--- Foreign Keys ---';
SELECT
    fk.name AS FK_NAME,
    OBJECT_NAME(fk.parent_object_id) AS TABLE_NAME,
    COL_NAME(fc.parent_object_id, fc.parent_column_id) AS COLUMN_NAME,
    OBJECT_NAME(fk.referenced_object_id) AS REFERENCED_TABLE,
    COL_NAME(fc.referenced_object_id, fc.referenced_column_id) AS REFERENCED_COLUMN
FROM sys.foreign_keys AS fk
INNER JOIN sys.foreign_key_columns AS fc ON fk.object_id = fc.constraint_object_id
WHERE OBJECT_NAME(fk.parent_object_id) = 'User_Wallet';

PRINT '';
PRINT '--- Indexes ---';
SELECT
    i.name AS INDEX_NAME,
    i.type_desc,
    i.is_unique,
    COL_NAME(ic.object_id, ic.column_id) AS COLUMN_NAME
FROM sys.indexes i
INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
WHERE OBJECT_NAME(i.object_id) = 'User_Wallet' AND i.name IS NOT NULL
ORDER BY i.name, ic.key_ordinal;

PRINT '';
PRINT '--- Check Constraints ---';
SELECT
    cc.name AS CONSTRAINT_NAME,
    cc.definition
FROM sys.check_constraints cc
WHERE OBJECT_NAME(cc.parent_object_id) = 'User_Wallet';

PRINT '';
PRINT '';

-- ====================================================================
-- Table: UserSignInStats
-- ====================================================================
PRINT '=== TABLE: UserSignInStats ===';
PRINT '';
PRINT '--- Columns ---';
SELECT
    c.COLUMN_NAME,
    c.DATA_TYPE,
    c.CHARACTER_MAXIMUM_LENGTH,
    c.NUMERIC_PRECISION,
    c.NUMERIC_SCALE,
    c.IS_NULLABLE,
    c.COLUMN_DEFAULT,
    COLUMNPROPERTY(OBJECT_ID(c.TABLE_SCHEMA + '.' + c.TABLE_NAME), c.COLUMN_NAME, 'IsIdentity') AS IS_IDENTITY
FROM INFORMATION_SCHEMA.COLUMNS c
WHERE c.TABLE_NAME = 'UserSignInStats'
ORDER BY c.ORDINAL_POSITION;

PRINT '';
PRINT '--- Primary Key ---';
SELECT kcu.COLUMN_NAME
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu ON tc.CONSTRAINT_NAME = kcu.CONSTRAINT_NAME
WHERE tc.TABLE_NAME = 'UserSignInStats' AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY';

PRINT '';
PRINT '--- Foreign Keys ---';
SELECT
    fk.name AS FK_NAME,
    OBJECT_NAME(fk.parent_object_id) AS TABLE_NAME,
    COL_NAME(fc.parent_object_id, fc.parent_column_id) AS COLUMN_NAME,
    OBJECT_NAME(fk.referenced_object_id) AS REFERENCED_TABLE,
    COL_NAME(fc.referenced_object_id, fc.referenced_column_id) AS REFERENCED_COLUMN
FROM sys.foreign_keys AS fk
INNER JOIN sys.foreign_key_columns AS fc ON fk.object_id = fc.constraint_object_id
WHERE OBJECT_NAME(fk.parent_object_id) = 'UserSignInStats';

PRINT '';
PRINT '--- Indexes ---';
SELECT
    i.name AS INDEX_NAME,
    i.type_desc,
    i.is_unique,
    COL_NAME(ic.object_id, ic.column_id) AS COLUMN_NAME
FROM sys.indexes i
INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
WHERE OBJECT_NAME(i.object_id) = 'UserSignInStats' AND i.name IS NOT NULL
ORDER BY i.name, ic.key_ordinal;

PRINT '';
PRINT '--- Check Constraints ---';
SELECT
    cc.name AS CONSTRAINT_NAME,
    cc.definition
FROM sys.check_constraints cc
WHERE OBJECT_NAME(cc.parent_object_id) = 'UserSignInStats';

PRINT '';
PRINT '';

-- ====================================================================
-- Table: WalletHistory
-- ====================================================================
PRINT '=== TABLE: WalletHistory ===';
PRINT '';
PRINT '--- Columns ---';
SELECT
    c.COLUMN_NAME,
    c.DATA_TYPE,
    c.CHARACTER_MAXIMUM_LENGTH,
    c.NUMERIC_PRECISION,
    c.NUMERIC_SCALE,
    c.IS_NULLABLE,
    c.COLUMN_DEFAULT,
    COLUMNPROPERTY(OBJECT_ID(c.TABLE_SCHEMA + '.' + c.TABLE_NAME), c.COLUMN_NAME, 'IsIdentity') AS IS_IDENTITY
FROM INFORMATION_SCHEMA.COLUMNS c
WHERE c.TABLE_NAME = 'WalletHistory'
ORDER BY c.ORDINAL_POSITION;

PRINT '';
PRINT '--- Primary Key ---';
SELECT kcu.COLUMN_NAME
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu ON tc.CONSTRAINT_NAME = kcu.CONSTRAINT_NAME
WHERE tc.TABLE_NAME = 'WalletHistory' AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY';

PRINT '';
PRINT '--- Foreign Keys ---';
SELECT
    fk.name AS FK_NAME,
    OBJECT_NAME(fk.parent_object_id) AS TABLE_NAME,
    COL_NAME(fc.parent_object_id, fc.parent_column_id) AS COLUMN_NAME,
    OBJECT_NAME(fk.referenced_object_id) AS REFERENCED_TABLE,
    COL_NAME(fc.referenced_object_id, fc.referenced_column_id) AS REFERENCED_COLUMN
FROM sys.foreign_keys AS fk
INNER JOIN sys.foreign_key_columns AS fc ON fk.object_id = fc.constraint_object_id
WHERE OBJECT_NAME(fk.parent_object_id) = 'WalletHistory';

PRINT '';
PRINT '--- Indexes ---';
SELECT
    i.name AS INDEX_NAME,
    i.type_desc,
    i.is_unique,
    COL_NAME(ic.object_id, ic.column_id) AS COLUMN_NAME
FROM sys.indexes i
INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
WHERE OBJECT_NAME(i.object_id) = 'WalletHistory' AND i.name IS NOT NULL
ORDER BY i.name, ic.key_ordinal;

PRINT '';
PRINT '--- Check Constraints ---';
SELECT
    cc.name AS CONSTRAINT_NAME,
    cc.definition
FROM sys.check_constraints cc
WHERE OBJECT_NAME(cc.parent_object_id) = 'WalletHistory';

PRINT '';
PRINT '';

-- ====================================================================
-- Table: ManagerData
-- ====================================================================
PRINT '=== TABLE: ManagerData ===';
PRINT '';
PRINT '--- Columns ---';
SELECT
    c.COLUMN_NAME,
    c.DATA_TYPE,
    c.CHARACTER_MAXIMUM_LENGTH,
    c.NUMERIC_PRECISION,
    c.NUMERIC_SCALE,
    c.IS_NULLABLE,
    c.COLUMN_DEFAULT,
    COLUMNPROPERTY(OBJECT_ID(c.TABLE_SCHEMA + '.' + c.TABLE_NAME), c.COLUMN_NAME, 'IsIdentity') AS IS_IDENTITY
FROM INFORMATION_SCHEMA.COLUMNS c
WHERE c.TABLE_NAME = 'ManagerData'
ORDER BY c.ORDINAL_POSITION;

PRINT '';
PRINT '--- Primary Key ---';
SELECT kcu.COLUMN_NAME
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu ON tc.CONSTRAINT_NAME = kcu.CONSTRAINT_NAME
WHERE tc.TABLE_NAME = 'ManagerData' AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY';

PRINT '';
PRINT '--- Foreign Keys ---';
SELECT
    fk.name AS FK_NAME,
    OBJECT_NAME(fk.parent_object_id) AS TABLE_NAME,
    COL_NAME(fc.parent_object_id, fc.parent_column_id) AS COLUMN_NAME,
    OBJECT_NAME(fk.referenced_object_id) AS REFERENCED_TABLE,
    COL_NAME(fc.referenced_object_id, fc.referenced_column_id) AS REFERENCED_COLUMN
FROM sys.foreign_keys AS fk
INNER JOIN sys.foreign_key_columns AS fc ON fk.object_id = fc.constraint_object_id
WHERE OBJECT_NAME(fk.parent_object_id) = 'ManagerData';

PRINT '';
PRINT '--- Indexes ---';
SELECT
    i.name AS INDEX_NAME,
    i.type_desc,
    i.is_unique,
    COL_NAME(ic.object_id, ic.column_id) AS COLUMN_NAME
FROM sys.indexes i
INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
WHERE OBJECT_NAME(i.object_id) = 'ManagerData' AND i.name IS NOT NULL
ORDER BY i.name, ic.key_ordinal;

PRINT '';
PRINT '--- Check Constraints ---';
SELECT
    cc.name AS CONSTRAINT_NAME,
    cc.definition
FROM sys.check_constraints cc
WHERE OBJECT_NAME(cc.parent_object_id) = 'ManagerData';

PRINT '';
PRINT '';

-- ====================================================================
-- Table: ManagerRole
-- ====================================================================
PRINT '=== TABLE: ManagerRole ===';
PRINT '';
PRINT '--- Columns ---';
SELECT
    c.COLUMN_NAME,
    c.DATA_TYPE,
    c.CHARACTER_MAXIMUM_LENGTH,
    c.NUMERIC_PRECISION,
    c.NUMERIC_SCALE,
    c.IS_NULLABLE,
    c.COLUMN_DEFAULT,
    COLUMNPROPERTY(OBJECT_ID(c.TABLE_SCHEMA + '.' + c.TABLE_NAME), c.COLUMN_NAME, 'IsIdentity') AS IS_IDENTITY
FROM INFORMATION_SCHEMA.COLUMNS c
WHERE c.TABLE_NAME = 'ManagerRole'
ORDER BY c.ORDINAL_POSITION;

PRINT '';
PRINT '--- Primary Key ---';
SELECT kcu.COLUMN_NAME
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu ON tc.CONSTRAINT_NAME = kcu.CONSTRAINT_NAME
WHERE tc.TABLE_NAME = 'ManagerRole' AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY';

PRINT '';
PRINT '--- Foreign Keys ---';
SELECT
    fk.name AS FK_NAME,
    OBJECT_NAME(fk.parent_object_id) AS TABLE_NAME,
    COL_NAME(fc.parent_object_id, fc.parent_column_id) AS COLUMN_NAME,
    OBJECT_NAME(fk.referenced_object_id) AS REFERENCED_TABLE,
    COL_NAME(fc.referenced_object_id, fc.referenced_column_id) AS REFERENCED_COLUMN
FROM sys.foreign_keys AS fk
INNER JOIN sys.foreign_key_columns AS fc ON fk.object_id = fc.constraint_object_id
WHERE OBJECT_NAME(fk.parent_object_id) = 'ManagerRole';

PRINT '';
PRINT '--- Indexes ---';
SELECT
    i.name AS INDEX_NAME,
    i.type_desc,
    i.is_unique,
    COL_NAME(ic.object_id, ic.column_id) AS COLUMN_NAME
FROM sys.indexes i
INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
WHERE OBJECT_NAME(i.object_id) = 'ManagerRole' AND i.name IS NOT NULL
ORDER BY i.name, ic.key_ordinal;

PRINT '';
PRINT '--- Check Constraints ---';
SELECT
    cc.name AS CONSTRAINT_NAME,
    cc.definition
FROM sys.check_constraints cc
WHERE OBJECT_NAME(cc.parent_object_id) = 'ManagerRole';

PRINT '';
PRINT '';

-- ====================================================================
-- Table: ManagerRolePermission
-- ====================================================================
PRINT '=== TABLE: ManagerRolePermission ===';
PRINT '';
PRINT '--- Columns ---';
SELECT
    c.COLUMN_NAME,
    c.DATA_TYPE,
    c.CHARACTER_MAXIMUM_LENGTH,
    c.NUMERIC_PRECISION,
    c.NUMERIC_SCALE,
    c.IS_NULLABLE,
    c.COLUMN_DEFAULT,
    COLUMNPROPERTY(OBJECT_ID(c.TABLE_SCHEMA + '.' + c.TABLE_NAME), c.COLUMN_NAME, 'IsIdentity') AS IS_IDENTITY
FROM INFORMATION_SCHEMA.COLUMNS c
WHERE c.TABLE_NAME = 'ManagerRolePermission'
ORDER BY c.ORDINAL_POSITION;

PRINT '';
PRINT '--- Primary Key ---';
SELECT kcu.COLUMN_NAME
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu ON tc.CONSTRAINT_NAME = kcu.CONSTRAINT_NAME
WHERE tc.TABLE_NAME = 'ManagerRolePermission' AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY';

PRINT '';
PRINT '--- Foreign Keys ---';
SELECT
    fk.name AS FK_NAME,
    OBJECT_NAME(fk.parent_object_id) AS TABLE_NAME,
    COL_NAME(fc.parent_object_id, fc.parent_column_id) AS COLUMN_NAME,
    OBJECT_NAME(fk.referenced_object_id) AS REFERENCED_TABLE,
    COL_NAME(fc.referenced_object_id, fc.referenced_column_id) AS REFERENCED_COLUMN
FROM sys.foreign_keys AS fk
INNER JOIN sys.foreign_key_columns AS fc ON fk.object_id = fc.constraint_object_id
WHERE OBJECT_NAME(fk.parent_object_id) = 'ManagerRolePermission';

PRINT '';
PRINT '--- Indexes ---';
SELECT
    i.name AS INDEX_NAME,
    i.type_desc,
    i.is_unique,
    COL_NAME(ic.object_id, ic.column_id) AS COLUMN_NAME
FROM sys.indexes i
INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
WHERE OBJECT_NAME(i.object_id) = 'ManagerRolePermission' AND i.name IS NOT NULL
ORDER BY i.name, ic.key_ordinal;

PRINT '';
PRINT '--- Check Constraints ---';
SELECT
    cc.name AS CONSTRAINT_NAME,
    cc.definition
FROM sys.check_constraints cc
WHERE OBJECT_NAME(cc.parent_object_id) = 'ManagerRolePermission';

PRINT '';
PRINT '';

-- ====================================================================
-- Table: Users
-- ====================================================================
PRINT '=== TABLE: Users ===';
PRINT '';
PRINT '--- Columns ---';
SELECT
    c.COLUMN_NAME,
    c.DATA_TYPE,
    c.CHARACTER_MAXIMUM_LENGTH,
    c.NUMERIC_PRECISION,
    c.NUMERIC_SCALE,
    c.IS_NULLABLE,
    c.COLUMN_DEFAULT,
    COLUMNPROPERTY(OBJECT_ID(c.TABLE_SCHEMA + '.' + c.TABLE_NAME), c.COLUMN_NAME, 'IsIdentity') AS IS_IDENTITY
FROM INFORMATION_SCHEMA.COLUMNS c
WHERE c.TABLE_NAME = 'Users'
ORDER BY c.ORDINAL_POSITION;

PRINT '';
PRINT '--- Primary Key ---';
SELECT kcu.COLUMN_NAME
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu ON tc.CONSTRAINT_NAME = kcu.CONSTRAINT_NAME
WHERE tc.TABLE_NAME = 'Users' AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY';

PRINT '';
PRINT '--- Foreign Keys ---';
SELECT
    fk.name AS FK_NAME,
    OBJECT_NAME(fk.parent_object_id) AS TABLE_NAME,
    COL_NAME(fc.parent_object_id, fc.parent_column_id) AS COLUMN_NAME,
    OBJECT_NAME(fk.referenced_object_id) AS REFERENCED_TABLE,
    COL_NAME(fc.referenced_object_id, fc.referenced_column_id) AS REFERENCED_COLUMN
FROM sys.foreign_keys AS fk
INNER JOIN sys.foreign_key_columns AS fc ON fk.object_id = fc.constraint_object_id
WHERE OBJECT_NAME(fk.parent_object_id) = 'Users';

PRINT '';
PRINT '--- Indexes ---';
SELECT
    i.name AS INDEX_NAME,
    i.type_desc,
    i.is_unique,
    COL_NAME(ic.object_id, ic.column_id) AS COLUMN_NAME
FROM sys.indexes i
INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
WHERE OBJECT_NAME(i.object_id) = 'Users' AND i.name IS NOT NULL
ORDER BY i.name, ic.key_ordinal;

PRINT '';
PRINT '--- Check Constraints ---';
SELECT
    cc.name AS CONSTRAINT_NAME,
    cc.definition
FROM sys.check_constraints cc
WHERE OBJECT_NAME(cc.parent_object_id) = 'Users';

PRINT '';
PRINT '';

PRINT '====================================================================';
PRINT 'Schema extraction complete!';
PRINT '====================================================================';
