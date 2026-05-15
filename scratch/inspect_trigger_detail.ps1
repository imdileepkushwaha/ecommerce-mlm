$connectionString = "Server=.;Database=ecomm_db;Trusted_Connection=True;"
$query = @"
SELECT name, OBJECT_DEFINITION(object_id) as definition
FROM sys.triggers 
WHERE parent_id = OBJECT_ID('Orders');

SELECT TOP 5 OrderId, ProductId, SelectedSize, SelectedColor, Quantity 
FROM OrderItems 
ORDER BY OrderId DESC;

SELECT TOP 5 Id, Status 
FROM Orders 
ORDER BY Id DESC;
"@

$result = Invoke-Sqlcmd -ConnectionString $connectionString -Query $query
$result | Out-File -FilePath "c:\Data\Work\MLM\ecommerce-mlm\scratch\trigger_diagnostics.txt"
