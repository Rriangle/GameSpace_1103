# Extract sample data from all tables
$tables = @(
"banned_words","bookmarks","Coupon","CouponType","CS_Agent","CS_Agent_Permission","DM_Conversations","DM_Messages","EVoucher","EVoucherRedeemLog",
"EVoucherToken","EVoucherType","forums","game_metric_daily","game_source_map","games","Group_Block","Group_Chat","Group_Member","Group_Read_States",
"Groups","leaderboard_snapshots","ManagerData","ManagerRole","ManagerRolePermission","MemberSalesProfile","metric_sources","metrics","MiniGame","Mutes",
"Notification_Actions","Notification_Recipients","Notification_Sources","Notifications","Pet","PetBackgroundCostSettings","PetLevelRewardSettings","PetSkinColorCostSettings",
"PlayerMarketOrderInfo","PlayerMarketOrderTradepage","PlayerMarketProductImgs","PlayerMarketProductInfo","PlayerMarketRanking","PlayerMarketTradeMsg","popularity_index_daily",
"post_metric_snapshot","post_sources","posts","reactions","Relation","Relation_Status","RemoteZipcodes","S_GameGenre","S_GameProductDetails","S_GameProductGenre",
"S_MerchType","S_Official_Store_Ranking","S_OtherProductDetails","S_PeriodType","S_Platform","S_ProductCode","S_ProductCodeRule","S_ProductImages","S_ProductInfo",
"S_ProductRatings","S_Supplier","S_SupplierStatus","S_UserFavorites","ShipMethods","SignInRule","SO_CartItems","SO_Carts","SO_Coupons","SO_OrderAddresses",
"SO_OrderInfoes","SO_OrderItems","SO_OrderStatusHistory","SO_PaymentTransactions","SO_PayMethods","SO_RemoteZip","SO_RemoteZipcodes","SO_Shipments","SO_ShipMethods",
"SO_ShipPieceRules","SO_ShippingConfig","SO_ShipWeightRules","SO_StockMovements","Support_Ticket_Assignments","Support_Ticket_Messages","Support_Tickets","SystemSettings",
"thread_posts","threads","User_Introduce","User_Rights","User_Sales_Information","User_Wallet","UserHome","Users","UserSignInStats","UserTokens","WalletHistory"
)

$outputFile = "C:\Users\n2029\Desktop\work-1103\schema\temp_sample_data_all.txt"
"TABLE_NAME|ROW_COUNT|SAMPLE_DATA" | Out-File $outputFile -Encoding UTF8

foreach ($table in $tables) {
    try {
        # Get row count
        $countQuery = "SELECT COUNT(*) FROM [$table]"
        $count = sqlcmd -S "DESKTOP-8HQIS1S\SQLEXPRESS" -d GameSpacedatabase -E -Q $countQuery -h -1 -W | Select-Object -First 1
        $count = $count.Trim()

        # Get top 5 rows
        $sampleQuery = "SET NOCOUNT ON; SELECT TOP 5 * FROM [$table]"
        $sample = sqlcmd -S "DESKTOP-8HQIS1S\SQLEXPRESS" -d GameSpacedatabase -E -Q $sampleQuery -s "|" -W -w 8000

        # Write to file
        "=== $table ($count rows) ===" | Out-File $outputFile -Append -Encoding UTF8
        $sample | Out-File $outputFile -Append -Encoding UTF8

        Write-Host "Extracted: $table ($count rows)"
    }
    catch {
        Write-Host "Error extracting $table : $_"
        "=== $table (ERROR) ===" | Out-File $outputFile -Append -Encoding UTF8
    }
}

Write-Host "Sample data extraction complete!"
