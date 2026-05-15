CREATE   PROCEDURE sp_Seller_UpdateOrderStatus
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
