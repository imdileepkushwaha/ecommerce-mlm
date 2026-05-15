$def = Invoke-Sqlcmd -ConnectionString 'Server=.;Database=ecomm_db;Trusted_Connection=True;' -Query "SELECT definition FROM sys.sql_modules WHERE object_id = OBJECT_ID('sp_Seller_UpdateOrderStatus')"
$def.definition | Out-File -FilePath 'c:\Data\Work\MLM\ecommerce-mlm\scratch\sp_Seller_UpdateOrderStatus.sql' -Encoding ascii
Write-Output "Finished writing sp def."
