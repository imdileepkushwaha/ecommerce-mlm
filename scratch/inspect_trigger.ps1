$connectionString = "Server=.;Database=ecomm_db;Trusted_Connection=True;"
$query = @"
SELECT name, is_disabled, OBJECT_DEFINITION(object_id) as definition
FROM sys.triggers 
WHERE parent_id = OBJECT_ID('Orders');

-- Check if recent order items have sizes populated
SELECT TOP 10 OrderId, ProductId, SelectedSize, SelectedColor, Quantity 
FROM OrderItems 
ORDER BY OrderId DESC;

-- Check sample order statuses
SELECT TOP 10 Id, Status 
FROM Orders 
ORDER BY Id DESC;
"@

Invoke-Sqlcmd -ConnectionString $connectionString -Query $query | Format-Table -AutoSize
