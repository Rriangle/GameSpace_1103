-- ====================================================================
-- SQL Server Schema Extraction Script v2
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
    GETDATE() AS ExtractedAt;

-- ====================================================================
-- 2. ALL TABLES LIST WITH COLUMN COUNTS
-- ====================================================================
PRINT '';
PRINT '=== ALL TABLES ===';
SELECT
    t.TABLE_SCHEMA AS [Schema],
    t.TABLE_NAME AS [Table],
    COUNT(c.COLUMN_NAME) AS ColumnCount
FROM INFORMATION_SCHEMA.TABLES t
LEFT JOIN INFORMATION_SCHEMA.COLUMNS c ON t.TABLE_NAME = c.TABLE_NAME
WHERE t.TABLE_TYPE = 'BASE TABLE'
GROUP BY t.TABLE_SCHEMA, t.TABLE_NAME
ORDER BY t.TABLE_SCHEMA, t.TABLE_NAME;

-- ====================================================================
-- 3. DETAILED COLUMN INFORMATION FOR ALL TABLES
-- ====================================================================
PRINT '';
PRINT '=== COLUMN DETAILS FOR ALL TABLES ===';
SELECT
    c.TABLE_NAME AS [Table],
    c.COLUMN_NAME AS [Column],
    c.DATA_TYPE AS DataType,
    CASE
        WHEN c.CHARACTER_MAXIMUM_LENGTH = -1 THEN 'MAX'
        WHEN c.CHARACTER_MAXIMUM_LENGTH IS NOT NULL THEN CAST(c.CHARACTER_MAXIMUM_LENGTH AS VARCHAR(10))
        WHEN c.NUMERIC_PRECISION IS NOT NULL THEN CAST(c.NUMERIC_PRECISION AS VARCHAR(10)) + ',' + CAST(ISNULL(c.NUMERIC_SCALE, 0) AS VARCHAR(10))
        ELSE ''
    END AS Size,
    c.IS_NULLABLE AS Null,
    ISNULL(c.COLUMN_DEFAULT, '') AS [Default],
    COLUMNPROPERTY(OBJECT_ID(c.TABLE_SCHEMA + '.' + c.TABLE_NAME), c.COLUMN_NAME, 'IsIdentity') AS IsIdent
FROM INFORMATION_SCHEMA.COLUMNS c
WHERE c.TABLE_NAME IN (
    SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE'
)
ORDER BY c.TABLE_NAME, c.ORDINAL_POSITION;

-- ====================================================================
-- 4. PRIMARY KEYS
-- ====================================================================
PRINT '';
PRINT '=== PRIMARY KEYS ===';
SELECT
    tc.TABLE_NAME AS [Table],
    kcu.COLUMN_NAME AS PKColumn
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
INNER JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu
    ON tc.CONSTRAINT_NAME = kcu.CONSTRAINT_NAME
WHERE tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
ORDER BY tc.TABLE_NAME, kcu.ORDINAL_POSITION;

-- ====================================================================
-- 5. FOREIGN KEYS
-- ====================================================================
PRINT '';
PRINT '=== FOREIGN KEYS ===';
SELECT
    OBJECT_NAME(fk.parent_object_id) AS SourceTable,
    COL_NAME(fkc.parent_object_id, fkc.parent_column_id) AS SourceColumn,
    OBJECT_NAME(fk.referenced_object_id) AS TargetTable,
    COL_NAME(fkc.referenced_object_id, fkc.referenced_column_id) AS TargetColumn,
    fk.name AS FKName
FROM sys.foreign_keys fk
INNER JOIN sys.foreign_key_columns fkc ON fk.object_id = fkc.constraint_object_id
ORDER BY OBJECT_NAME(fk.parent_object_id), fkc.constraint_column_id;

-- ====================================================================
-- 6. UNIQUE CONSTRAINTS
-- ====================================================================
PRINT '';
PRINT '=== UNIQUE CONSTRAINTS ===';
SELECT
    tc.TABLE_NAME AS [Table],
    kcu.COLUMN_NAME AS [Column],
    tc.CONSTRAINT_NAME AS ConstraintName
FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
INNER JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu
    ON tc.CONSTRAINT_NAME = kcu.CONSTRAINT_NAME
WHERE tc.CONSTRAINT_TYPE = 'UNIQUE'
ORDER BY tc.TABLE_NAME, kcu.ORDINAL_POSITION;

-- ====================================================================
-- 7. CHECK CONSTRAINTS
-- ====================================================================
PRINT '';
PRINT '=== CHECK CONSTRAINTS ===';
SELECT
    cc.TABLE_NAME AS [Table],
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
    t.name AS [Table],
    i.name AS IndexName,
    i.type_desc AS IndexType,
    c.name AS [Column],
    i.is_unique AS IsUnique
FROM sys.indexes i
INNER JOIN sys.tables t ON i.object_id = t.object_id
INNER JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
INNER JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
WHERE i.name IS NOT NULL
ORDER BY t.name, i.name, ic.key_ordinal;

-- ====================================================================
-- 9. TABLE ROW COUNTS
-- ====================================================================
PRINT '';
PRINT '=== TABLE ROW COUNTS ===';
SELECT
    t.name AS [Table],
    p.rows AS [Rows]
FROM sys.tables t
INNER JOIN sys.partitions p ON t.object_id = p.object_id
WHERE p.index_id IN (0, 1)
ORDER BY t.name;
