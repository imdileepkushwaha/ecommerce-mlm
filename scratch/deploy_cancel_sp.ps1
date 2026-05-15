$connString = "Server=.;Database=ecomm_db;Trusted_Connection=True;"
$sql = @"
CREATE OR ALTER PROCEDURE sp_Customer_RequestOrderCancellation
    @OrderId INT,
    @Reason NVARCHAR(MAX),
    @Message NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Orders 
    SET Status = 'Cancellation requested', 
        ReturnReason = @Reason, 
        ReturnMessage = @Message, 
        UpdatedAt = GETDATE() 
    WHERE Id = @OrderId;
END
"@

$connection = New-Object System.Data.SqlClient.SqlConnection($connString)
$connection.Open()
$command = New-Object System.Data.SqlClient.SqlCommand($sql, $connection)
$command.ExecuteNonQuery()
$connection.Close()

Write-Host "sp_Customer_RequestOrderCancellation Deployed Successfully!"
