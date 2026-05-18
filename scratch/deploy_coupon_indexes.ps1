$connString = "Server=.;Database=ecomm_db;Trusted_Connection=True;"

$indexSeller = @"
IF OBJECT_ID(N'[dbo].[Coupons]', N'U') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Coupons_SellerId' AND object_id = OBJECT_ID(N'[dbo].[Coupons]'))
    CREATE NONCLUSTERED INDEX [IX_Coupons_SellerId] ON [dbo].[Coupons]([SellerId])
    INCLUDE ([IsActive], [UsedCount], [CreatedAt], [CouponCode], [DiscountType], [DiscountValue], [EndDate], [UsageLimit]);
"@

$indexCode = @"
IF OBJECT_ID(N'[dbo].[Coupons]', N'U') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Coupons_CouponCode' AND object_id = OBJECT_ID(N'[dbo].[Coupons]'))
    CREATE NONCLUSTERED INDEX [IX_Coupons_CouponCode] ON [dbo].[Coupons]([CouponCode]);
"@

$connection = New-Object System.Data.SqlClient.SqlConnection($connString)
$connection.Open()

foreach ($sql in @($indexSeller, $indexCode)) {
    $cmd = New-Object System.Data.SqlClient.SqlCommand($sql, $connection)
    $cmd.CommandTimeout = 300
    $cmd.ExecuteNonQuery() | Out-Null
}

$connection.Close()
Write-Host "Coupon indexes deployed."
