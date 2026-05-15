$connectionString = "Server=.;Database=ecomm_db;Trusted_Connection=True;"
$query = "SELECT TOP 3 * FROM ProductVariants WHERE VariantType = 'Size';"
Write-Host "=== PRODUCT VARIANTS SCHEMA ==="
Invoke-Sqlcmd -ConnectionString $connectionString -Query $query | Format-List | Out-String | Write-Host
