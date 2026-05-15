$connString = "Server=.;Database=ecomm_db;Trusted_Connection=True;"
$sql = @"
CREATE OR ALTER PROCEDURE sp_Seller_UpdateOrderStatus
    @OrderId INT,
    @Status NVARCHAR(100),
    @PickupNote NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Orders 
    SET Status = @Status, 
        ReturnPickupNote = CASE WHEN @PickupNote IS NOT NULL THEN @PickupNote ELSE ReturnPickupNote END,
        UpdatedAt = GETDATE() 
    WHERE Id = @OrderId;
END
"@

$connection = New-Object System.Data.SqlClient.SqlConnection($connString)
$connection.Open()
$command = New-Object System.Data.SqlClient.SqlCommand($sql, $connection)
$command.ExecuteNonQuery()
$connection.Close()

Write-Host "sp_Seller_UpdateOrderStatus UPDATED Successfully with @PickupNote parameter!"
