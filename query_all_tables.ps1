# SQL Server Database Query Script for MiniGame Area
# 连接参数
$serverName = "tcp:DESKTOP-8HQIS1S\SQLEXPRESS,1433"
$dbName = "GameSpacedatabase"
$outputDir = "C:\Users\n2029\Desktop"
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$outputFile = "$outputDir\MiniGame_Tables_Query_$timestamp.txt"

# 定义所有需要查询的表
$tables = @(
    @{ Name = "Coupon"; UserField = "User_Id" },
    @{ Name = "CouponType"; UserField = $null },
    @{ Name = "EVoucher"; UserField = "User_Id" },
    @{ Name = "EVoucherType"; UserField = $null },
    @{ Name = "EVoucherRedeemLog"; UserField = "User_Id" },
    @{ Name = "EVoucherToken"; UserField = "User_Id" },
    @{ Name = "MiniGame"; UserField = "User_Id" },
    @{ Name = "Pet"; UserField = "User_Id" },
    @{ Name = "PetBackgroundCostSettings"; UserField = $null },
    @{ Name = "PetLevelRewardSettings"; UserField = $null },
    @{ Name = "PetSkinColorCostSettings"; UserField = $null },
    @{ Name = "SignInRule"; UserField = $null },
    @{ Name = "UserSignInStats"; UserField = "User_Id" },
    @{ Name = "User_Wallet"; UserField = "User_Id" },
    @{ Name = "WalletHistory"; UserField = "User_Id" },
    @{ Name = "SystemSettings"; UserField = $null }
)

# 目标用户ID
$userIds = @(10000001, 10000002)

# 初始化输出文件
$output = @()
$output += "=================================================="
$output += "MiniGame Area Database Tables Query Report"
$output += "Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
$output += "Database: $dbName"
$output += "Server: $serverName"
$output += "Target Users: $($userIds -join ', ')"
$output += "=================================================="
$output += ""

# 函数：获取表结构信息
function Get-TableStructure {
    param([string]$tableName)

    $queries = @"
-- ============== TABLE STRUCTURE FOR $tableName ==============
USE $dbName;
GO

-- 1. 表的所有列信息（包括主键、默认值、标识列等）
SELECT
    ORDINAL_POSITION AS '列号',
    COLUMN_NAME AS '列名',
    DATA_TYPE AS '数据类型',
    CHARACTER_MAXIMUM_LENGTH AS '最大长度',
    IS_NULLABLE AS '允许NULL',
    COLUMN_DEFAULT AS '默认值'
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = '$tableName'
ORDER BY ORDINAL_POSITION;
GO

-- 2. 主键信息
SELECT
    CONSTRAINT_NAME AS '约束名',
    COLUMN_NAME AS '列名',
    ORDINAL_POSITION AS '列顺序'
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_NAME = '$tableName'
  AND CONSTRAINT_NAME IN (SELECT CONSTRAINT_NAME FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE TABLE_NAME = '$tableName' AND CONSTRAINT_TYPE = 'PRIMARY KEY')
ORDER BY ORDINAL_POSITION;
GO

-- 3. 外键约束
SELECT
    CONSTRAINT_NAME AS '外键约束名',
    TABLE_NAME AS '当前表',
    COLUMN_NAME AS '当前列',
    REFERENCED_TABLE_NAME AS '引用表',
    REFERENCED_COLUMN_NAME AS '引用列'
FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS rc
JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu ON rc.CONSTRAINT_NAME = kcu.CONSTRAINT_NAME
WHERE kcu.TABLE_NAME = '$tableName';
GO

-- 4. 唯一键约束
SELECT
    CONSTRAINT_NAME AS '唯一约束名',
    COLUMN_NAME AS '列名'
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_NAME = '$tableName'
  AND CONSTRAINT_NAME IN (
    SELECT CONSTRAINT_NAME FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS
    WHERE TABLE_NAME = '$tableName' AND CONSTRAINT_TYPE = 'UNIQUE'
  );
GO

-- 5. 其他约束（CHECK）
SELECT
    CONSTRAINT_NAME AS '约束名',
    CHECK_CLAUSE AS '检查条件'
FROM INFORMATION_SCHEMA.CHECK_CONSTRAINTS
WHERE TABLE_NAME = '$tableName';
GO

-- 6. 标识列信息
SELECT
    COLUMN_NAME AS '列名',
    SEED_VALUE AS '种子值',
    INCREMENT_VALUE AS '增量'
FROM INFORMATION_SCHEMA.IDENTITY_COLUMNS
WHERE TABLE_NAME = '$tableName';
GO

-- 7. 表的总行数
SELECT COUNT(*) AS '总行数' FROM [$tableName];
GO

"@

    return $queries
}

# 函数：获取特定用户的数据
function Get-UserData {
    param([string]$tableName, [string]$userField, [array]$userIds)

    if ($userField -eq $null) {
        # 如果表没有用户字段，返回前10行示例数据
        $query = @"
-- Data sample from $tableName (first 10 rows)
SELECT TOP 10 * FROM [$tableName] ORDER BY (SELECT NULL);
GO

"@
    } else {
        # 查询特定用户的所有数据
        $userIdList = ($userIds | ForEach-Object { $_ }) -join ','
        $query = @"
-- Data for User IDs: $userIdList
SELECT * FROM [$tableName]
WHERE $userField IN ($userIdList)
ORDER BY $userField;
GO

"@
    }

    return $query
}

# 输出文件路径
Write-Host "开始查询数据库...输出文件: $outputFile" -ForegroundColor Green

# 创建临时SQL脚本
$tempSqlFile = "$env:TEMP\query_$timestamp.sql"
$allQueries = ""

foreach ($table in $tables) {
    Write-Host "准备查询表: $($table.Name)" -ForegroundColor Cyan

    $allQueries += "-- ============================================================================`n"
    $allQueries += "-- TABLE: $($table.Name)`n"
    $allQueries += "-- ============================================================================`n`n"

    # 添加表结构信息
    $allQueries += Get-TableStructure -tableName $table.Name
    $allQueries += "`n"

    # 添加数据查询
    $allQueries += Get-UserData -tableName $table.Name -userField $table.UserField -userIds $userIds
    $allQueries += "`n`n"
}

# 将所有查询写入临时SQL文件
$allQueries | Out-File -FilePath $tempSqlFile -Encoding UTF8

Write-Host "执行SQL查询..." -ForegroundColor Cyan

# 执行sqlcmd并将输出重定向到文件
try {
    sqlcmd -S $serverName -d $dbName -E -i $tempSqlFile -o $outputFile
    Write-Host "查询成功！输出文件: $outputFile" -ForegroundColor Green

    # 显示文件信息
    if (Test-Path $outputFile) {
        $fileInfo = Get-Item $outputFile
        Write-Host "文件大小: $($fileInfo.Length) 字节" -ForegroundColor Green
        Write-Host "文件位置: $($fileInfo.FullName)" -ForegroundColor Green
    }
} catch {
    Write-Host "查询失败: $_" -ForegroundColor Red
}

# 清理临时文件
if (Test-Path $tempSqlFile) {
    Remove-Item $tempSqlFile -Force
}

Write-Host "完成！" -ForegroundColor Green
