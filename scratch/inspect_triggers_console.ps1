$connectionString = "Server=.;Database=ecomm_db;Trusted_Connection=True;"
$query1 = "SELECT name, is_disabled FROM sys.triggers WHERE parent_id = OBJECT_ID('Orders');"
$query2 = "SELECT OBJECT_DEFINITION(object_id) as definition FROM sys.triggers WHERE name = 'trg_UpdateStockOnDelivery';"
$query3 = "SELECT OBJECT_DEFINITION(object_id) as definition FROM sys.triggers WHERE name = 'trg_DeductStockOnDelivered';"
$query4 = "SELECT TOP 3 OrderId, ProductId, SelectedSize, SelectedColor, Quantity FROM OrderItems ORDER BY OrderId DESC;"
$query5 = "SELECT TOP 3 Id, Status FROM Orders ORDER BY Id DESC;"

Write-Host "=== ACTIVE TRIGGERS ==="
Invoke-Sqlcmd -ConnectionString $connectionString -Query $query1 | Format-List | Out-String | Write-Host

Write-Host "=== trg_UpdateStockOnDelivery DEFINITION ==="
Invoke-Sqlcmd -ConnectionString $connectionString -Query $query2 | Select-Object -ExpandProperty definition | Write-Host

Write-Host "=== trg_DeductStockOnDelivered DEFINITION ==="
Invoke-Sqlcmd -ConnectionString $connectionString -Query $query3 | Select-Object -ExpandProperty definition | Write-Host

Write-Host "=== RECENT ORDER ITEMS ==="
Invoke-Sqlcmd -ConnectionString $connectionString -Query $query4 | Format-List | Out-String | Write-Host

Write-Host "=== RECENT ORDERS ==="
Invoke-Sqlcmd -ConnectionString $connectionString -Query $query5 | Format-List | Out-String | Write-Host
