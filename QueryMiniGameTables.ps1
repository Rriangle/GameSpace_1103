# SQL Server Connection Script for MiniGame Area Tables
# Read-only queries with READ UNCOMMITTED isolation level

# Connection parameters
$serverNames = @(
    "DESKTOP-8HQIS1S\SQLEXPRESS",
    "(local)\SQLEXPRESS01"
)
$database = "GameSpacedatabase"

# Tables to query
$tables = @(
    "dbo.Coupon",
    "dbo.CouponType",
    "dbo.EVoucher",
    "dbo.EVoucherRedeemLog",
    "dbo.EVoucherToken",
    "dbo.EVoucherType",
    "dbo.MiniGame",
    "dbo.Pet",
    "dbo.PetBackgroundCostSettings",
    "dbo.PetLevelRewardSettings",
    "dbo.PetSkinColorCostSettings",
    "dbo.SignInRule",
    "dbo.SystemSettings",
    "dbo.User_Wallet",
    "dbo.UserSignInStats",
    "dbo.WalletHistory",
    "dbo.ManagerData",
    "dbo.ManagerRolePermission",
    "dbo.Users"
)

# Output file
$outputFile = "C:\Users\n2029\Desktop\work-1103\MiniGameTables_Output.txt"
$jsonOutputFile = "C:\Users\n2029\Desktop\work-1103\MiniGameTables_Data.json"

# Initialize output
$results = @{}
$allResults = ""

# Function to try connection
function Test-SQLConnection {
    param($serverName, $database)

    try {
        $connectionString = "Server=$serverName;Database=$database;Integrated Security=True;TrustServerCertificate=True;Connection Timeout=5;"
        $connection = New-Object System.Data.SqlClient.SqlConnection($connectionString)
        $connection.Open()
        $connection.Close()
        return $true
    }
    catch {
        return $false
    }
}

# Function to execute query
function Invoke-SQLQuery {
    param($serverName, $database, $query)

    try {
        $connectionString = "Server=$serverName;Database=$database;Integrated Security=True;TrustServerCertificate=True;Connection Timeout=30;"
        $connection = New-Object System.Data.SqlClient.SqlConnection($connectionString)
        $connection.Open()

        $command = $connection.CreateCommand()
        $command.CommandText = $query
        $command.CommandTimeout = 60

        $adapter = New-Object System.Data.SqlClient.SqlDataAdapter($command)
        $dataset = New-Object System.Data.DataSet
        $adapter.Fill($dataset) | Out-Null

        $connection.Close()

        return $dataset.Tables[0]
    }
    catch {
        Write-Host "Query Error: $_" -ForegroundColor Red
        return $null
    }
}

# Try to connect to SQL Server
$connectedServer = $null
foreach ($server in $serverNames) {
    Write-Host "Trying to connect to: $server..." -ForegroundColor Yellow
    if (Test-SQLConnection -serverName $server -database $database) {
        $connectedServer = $server
        Write-Host "Successfully connected to: $server" -ForegroundColor Green
        break
    }
    else {
        Write-Host "Failed to connect to: $server" -ForegroundColor Red
    }
}

if (-not $connectedServer) {
    Write-Host "ERROR: Could not connect to any SQL Server instance" -ForegroundColor Red
    exit 1
}

$allResults += "=" * 100 + "`n"
$allResults += "SQL Server MiniGame Area Tables - Structure and Seed Data`n"
$allResults += "Connected Server: $connectedServer`n"
$allResults += "Database: $database`n"
$allResults += "Query Time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')`n"
$allResults += "=" * 100 + "`n`n"

# Query each table
foreach ($table in $tables) {
    Write-Host "`nProcessing table: $table" -ForegroundColor Cyan
    $allResults += "`n" + "=" * 100 + "`n"
    $allResults += "TABLE: $table`n"
    $allResults += "=" * 100 + "`n`n"

    # Get table structure
    Write-Host "  - Querying table structure..." -ForegroundColor Gray
    $structureQuery = @"
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SELECT
    c.COLUMN_NAME as [Column Name],
    c.DATA_TYPE as [Data Type],
    CASE WHEN c.CHARACTER_MAXIMUM_LENGTH = -1 THEN 'MAX'
         WHEN c.CHARACTER_MAXIMUM_LENGTH IS NOT NULL THEN CAST(c.CHARACTER_MAXIMUM_LENGTH AS VARCHAR)
         ELSE '' END as [Length],
    c.IS_NULLABLE as [Nullable],
    ISNULL(c.COLUMN_DEFAULT, '') as [Default],
    CASE WHEN pk.COLUMN_NAME IS NOT NULL THEN 'YES' ELSE 'NO' END as [Primary Key]
FROM INFORMATION_SCHEMA.COLUMNS c
LEFT JOIN (
    SELECT ku.COLUMN_NAME
    FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
    JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE ku ON tc.CONSTRAINT_NAME = ku.CONSTRAINT_NAME
    WHERE tc.CONSTRAINT_TYPE = 'PRIMARY KEY' AND ku.TABLE_NAME = '$($table.Split('.')[1])'
) pk ON c.COLUMN_NAME = pk.COLUMN_NAME
WHERE c.TABLE_NAME = '$($table.Split('.')[1])'
ORDER BY c.ORDINAL_POSITION;
"@

    $structure = Invoke-SQLQuery -serverName $connectedServer -database $database -query $structureQuery

    if ($structure) {
        $allResults += "TABLE STRUCTURE:`n"
        $allResults += "-" * 100 + "`n"
        $allResults += $structure | Format-Table -AutoSize | Out-String
        $allResults += "`n"
    }

    # Get data (top 20 rows, or all for SystemSettings with filter)
    Write-Host "  - Querying table data..." -ForegroundColor Gray

    if ($table -eq "dbo.SystemSettings") {
        # Special query for SystemSettings - get all MiniGame related settings
        $dataQuery = @"
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SELECT *
FROM $table
WHERE Category IN ('Game', 'Pet', 'SignIn', 'Wallet')
ORDER BY Category, [Key];
"@
        $allResults += "DATA (All MiniGame Related Settings - Category IN ('Game', 'Pet', 'SignIn', 'Wallet')):`n"
    }
    else {
        # Standard query for other tables
        $dataQuery = @"
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SELECT TOP 20 *
FROM $table;
"@
        $allResults += "DATA (First 20 rows):`n"
    }

    $allResults += "-" * 100 + "`n"

    $data = Invoke-SQLQuery -serverName $connectedServer -database $database -query $dataQuery

    if ($data -and $data.Rows.Count -gt 0) {
        $allResults += "Row Count: $($data.Rows.Count)`n`n"
        $allResults += $data | Format-Table -AutoSize | Out-String

        # Store in results object
        $results[$table] = @{
            Structure = $structure
            Data = $data
            RowCount = $data.Rows.Count
        }
    }
    else {
        $allResults += "No data found in this table.`n"
        $results[$table] = @{
            Structure = $structure
            Data = $null
            RowCount = 0
        }
    }

    $allResults += "`n"
}

# Save text output
$allResults | Out-File -FilePath $outputFile -Encoding UTF8
Write-Host "`nResults saved to: $outputFile" -ForegroundColor Green

# Create JSON summary
$jsonSummary = @{
    Server = $connectedServer
    Database = $database
    QueryTime = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    Tables = @{}
}

foreach ($table in $tables) {
    if ($results.ContainsKey($table)) {
        $tableInfo = @{
            RowCount = $results[$table].RowCount
            Columns = @()
        }

        if ($results[$table].Structure) {
            $results[$table].Structure | ForEach-Object {
                $tableInfo.Columns += @{
                    Name = $_.'Column Name'
                    Type = $_.'Data Type'
                    Length = $_.Length
                    Nullable = $_.Nullable
                    PrimaryKey = $_.'Primary Key'
                }
            }
        }

        $jsonSummary.Tables[$table] = $tableInfo
    }
}

$jsonSummary | ConvertTo-Json -Depth 10 | Out-File -FilePath $jsonOutputFile -Encoding UTF8
Write-Host "JSON summary saved to: $jsonOutputFile" -ForegroundColor Green

Write-Host "`n" + "=" * 100 -ForegroundColor Green
Write-Host "All queries completed successfully!" -ForegroundColor Green
Write-Host "=" * 100 + "`n" -ForegroundColor Green
