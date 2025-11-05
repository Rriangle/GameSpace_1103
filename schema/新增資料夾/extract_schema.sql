-- ====================================================================
-- SQL Server Schema Extraction Script
-- Database: GameSpacedatabase
-- Purpose: Extract complete schema information for AI consumption
-- ====================================================================

SET NOCOUNT ON;

-- ====================================================================
-- 1. DATABASE OVERVIEW
-- ====================================================================
PRINT '=== DATABASE OVERVIEW ===';
SELECT
    DB_NAME() AS DatabaseName,
    @@VERSION AS SQLServerVersion,
    GETDATE() AS ExtractedAt;

-- ====================================================================
-- 2. ALL TABLES LIST
-- ====================================================================
PRINT '';
PRINT '=== ALL TABLES ===';
SELECT
    TABLE_SCHEMA AS [Schema],
    TABLE_NAME AS [Table],
    (SELECT COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS c WHERE c.TABLE_NAME = t.TABLE_NAME) AS ColumnCount
FROM INFORMATION_SCHEMA.TABLES t
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_SCHEMA, TABLE_NAME;

-- ====================================================================
-- 3. DETAILED COLUMN INFORMATION FOR ALL TABLES
-- ====================================================================
PRINT '';
PRINT '=== COLUMN DETAILS FOR ALL TABLES ===';
SELECT
    t.TABLE_NAME AS TableName,
    c.COLUMN_NAME AS ColumnName,
    c.DATA_TYPE AS DataType,
    CASE
        WHEN c.CHARACTER_MAXIMUM_LENGTH = -1 THEN 'MAX'
        WHEN c.CHARACTER_MAXIMUM_LENGTH IS NOT NULL THEN CAST(c.CHARACTER_MAXIMUM_LENGTH AS VARCHAR(10))
        WHEN c.NUMERIC_PRECISION IS NOT NULL THEN CAST(c.NUMERIC_PRECISION AS VARCHAR(10)) + ',' + CAST(c.NUMERIC_SCALE AS VARCHAR(10))
        ELSE ''
    END AS [Length/Precision],
    c.IS_NULLABLE AS Nullable,
    c.COLUMN_DEFAULT AS [Default],
    CASE WHEN ic.COLUMN_NAME IS NOT NULL THEN 'YES' ELSE 'NO' END AS IsIdentity,
    c.ORDINAL_POSITION AS OrdinalPosition
FROM INFORMATION_SCHEMA.TABLES t
INNER JOIN INFORMATION_SCHEMA.COLUMNS c ON t.TABLE_NAME = c.TABLE_NAME
LEFT JOIN sys.identity_columns ic ON ic.object_id = OBJECT_ID(t.TABLE_SCHEMA + '.' + t.TABLE_NAME)
    AND ic.name = c.COLUMN_NAME
WHERE t.TABLE_TYPE = 'BASE TABLE'
ORDER BY t.TABLE_NAME, c.ORDINAL_POSITION;

-- ====================================================================
-- 4. PRIMARY KEYS
-- ====================================================================
PRINT '';
PRINT '=== PRIMARY KEYS ===';
SELECT
    tc.TABLE_NAME AS TableName,
    tc.CONSTRAINT_NAME AS PKName,
    STRING_AGG(CAST(kcu.COLUMN_NAME AS NVARCHAR(MAX)), ', ') WITHIN GROUP (ORDER BY kcu.ORDINAL_POSITION) AS PKColumns
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
INNER JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu
    ON tc.CONSTRAINT_NAME = kcu.CONSTRAINT_NAME
    AND tc.TABLE_NAME = kcu.TABLE_NAME
WHERE tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
GROUP BY tc.TABLE_NAME, tc.CONSTRAINT_NAME
ORDER BY tc.TABLE_NAME;

-- ====================================================================
-- 5. FOREIGN KEYS
-- ====================================================================
PRINT '';
PRINT '=== FOREIGN KEYS ===';
SELECT
    fk.name AS FKName,
    OBJECT_NAME(fk.parent_object_id) AS SourceTable,
    STRING_AGG(CAST(COL_NAME(fkc.parent_object_id, fkc.parent_column_id) AS NVARCHAR(MAX)), ', ') AS SourceColumns,
    OBJECT_NAME(fk.referenced_object_id) AS TargetTable,
    STRING_AGG(CAST(COL_NAME(fkc.referenced_object_id, fkc.referenced_column_id) AS NVARCHAR(MAX)), ', ') AS TargetColumns,
    CASE fk.delete_referential_action
        WHEN 0 THEN 'NO ACTION'
        WHEN 1 THEN 'CASCADE'
        WHEN 2 THEN 'SET NULL'
        WHEN 3 THEN 'SET DEFAULT'
    END AS OnDelete,
    CASE fk.update_referential_action
        WHEN 0 THEN 'NO ACTION'
        WHEN 1 THEN 'CASCADE'
        WHEN 2 THEN 'SET NULL'
        WHEN 3 THEN 'SET DEFAULT'
    END AS OnUpdate
FROM sys.foreign_keys fk
INNER JOIN sys.foreign_key_columns fkc ON fk.object_id = fkc.constraint_object_id
GROUP BY fk.name, fk.parent_object_id, fk.referenced_object_id, fk.delete_referential_action, fk.update_referential_action
ORDER BY OBJECT_NAME(fk.parent_object_id);

-- ====================================================================
-- 6. UNIQUE CONSTRAINTS
-- ====================================================================
PRINT '';
PRINT '=== UNIQUE CONSTRAINTS ===';
SELECT
    tc.TABLE_NAME AS TableName,
    tc.CONSTRAINT_NAME AS ConstraintName,
    STRING_AGG(CAST(kcu.COLUMN_NAME AS NVARCHAR(MAX)), ', ') WITHIN GROUP (ORDER BY kcu.ORDINAL_POSITION) AS Columns
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
INNER JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu
    ON tc.CONSTRAINT_NAME = kcu.CONSTRAINT_NAME
    AND tc.TABLE_NAME = kcu.TABLE_NAME
WHERE tc.CONSTRAINT_TYPE = 'UNIQUE'
GROUP BY tc.TABLE_NAME, tc.CONSTRAINT_NAME
ORDER BY tc.TABLE_NAME;

-- ====================================================================
-- 7. CHECK CONSTRAINTS
-- ====================================================================
PRINT '';
PRINT '=== CHECK CONSTRAINTS ===';
SELECT
    cc.TABLE_NAME AS TableName,
    cc.CONSTRAINT_NAME AS ConstraintName,
    cc.CHECK_CLAUSE AS CheckClause
FROM INFORMATION_SCHEMA.CHECK_CONSTRAINTS cc
ORDER BY cc.TABLE_NAME, cc.CONSTRAINT_NAME;

-- ====================================================================
-- 8. INDEXES
-- ====================================================================
PRINT '';
PRINT '=== INDEXES ===';
SELECT
    OBJECT_NAME(i.object_id) AS TableName,
    i.name AS IndexName,
    i.type_desc AS IndexType,
    i.is_unique AS IsUnique,
    i.is_primary_key AS IsPrimaryKey,
    STRING_AGG(CAST(c.name AS NVARCHAR(MAX)), ', ') WITHIN GROUP (ORDER BY ic.key_ordinal) AS Columns
FROM sys.indexes i
INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
INNER JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
WHERE i.object_id IN (SELECT object_id FROM sys.tables WHERE type = 'U')
    AND i.name IS NOT NULL
GROUP BY OBJECT_NAME(i.object_id), i.name, i.type_desc, i.is_unique, i.is_primary_key
ORDER BY OBJECT_NAME(i.object_id), i.name;

-- ====================================================================
-- 9. TABLE ROW COUNTS
-- ====================================================================
PRINT '';
PRINT '=== TABLE ROW COUNTS ===';
SELECT
    t.name AS TableName,
    SUM(p.rows) AS RowCount
FROM sys.tables t
INNER JOIN sys.partitions p ON t.object_id = p.object_id
WHERE p.index_id IN (0, 1)
GROUP BY t.name
ORDER BY t.name;
