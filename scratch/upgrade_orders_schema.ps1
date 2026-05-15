$connString = "Server=.;Database=ecomm_db;Trusted_Connection=True;"
$sql = @"
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Orders' AND COLUMN_NAME='ReturnReason')
BEGIN
    ALTER TABLE Orders ADD ReturnReason nvarchar(MAX) NULL;
END

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Orders' AND COLUMN_NAME='ReturnMessage')
BEGIN
    ALTER TABLE Orders ADD ReturnMessage nvarchar(MAX) NULL;
END

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME='Orders' AND COLUMN_NAME='ReturnPickupNote')
BEGIN
    ALTER TABLE Orders ADD ReturnPickupNote nvarchar(MAX) NULL;
END
"@

$connection = New-Object System.Data.SqlClient.SqlConnection($connString)
$command = New-Object System.Data.SqlClient.SqlCommand($sql, $connection)
$connection.Open()
$command.ExecuteNonQuery()
$connection.Close()
Write-Host "Database Schema Upgraded Successfully with Return Columns!"
