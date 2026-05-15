$connectionString = "Server=.;Database=ecomm_db;Trusted_Connection=True;"
$query = "SELECT TOP 5 CartItemId, ProductId, SelectedSize, SelectedColor, Quantity FROM CartItems ORDER BY CartItemId DESC;"
Write-Host "=== RECENT CART ITEMS ==="
Invoke-Sqlcmd -ConnectionString $connectionString -Query $query | Format-List | Out-String | Write-Host
