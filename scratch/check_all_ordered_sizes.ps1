$connectionString = "Server=.;Database=ecomm_db;Trusted_Connection=True;"
$query = "SELECT OrderId, ProductId, SelectedSize, Quantity FROM OrderItems WHERE SelectedSize IS NOT NULL AND SelectedSize <> '';"
Write-Host "=== ORDERS WITH POPULATED SIZES ==="
Invoke-Sqlcmd -ConnectionString $connectionString -Query $query | Format-List | Out-String | Write-Host
