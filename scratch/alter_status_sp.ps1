$connString = "Server=.;Database=ecomm_db;Trusted_Connection=True;"

$alterTable = @"
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Orders]') AND name = 'CouponCode')
    ALTER TABLE [dbo].[Orders] ADD [CouponCode] VARCHAR(50) NULL;
"@

$createSp = Get-Content -Raw -Path (Join-Path $PSScriptRoot "sp_Seller_UpdateOrderStatus.sql")

$connection = New-Object System.Data.SqlClient.SqlConnection($connString)
$connection.Open()

$cmd1 = New-Object System.Data.SqlClient.SqlCommand($alterTable, $connection)
$cmd1.ExecuteNonQuery() | Out-Null

$cmd2 = New-Object System.Data.SqlClient.SqlCommand($createSp, $connection)
$cmd2.ExecuteNonQuery() | Out-Null

$connection.Close()

Write-Host "Orders.CouponCode + sp_Seller_UpdateOrderStatus (coupon restore on cancel) deployed."
