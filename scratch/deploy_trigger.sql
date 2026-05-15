CREATE OR ALTER TRIGGER trg_DeductStockOnDelivered
ON Orders
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Only proceed if the Status column changed
    IF UPDATE(Status)
    BEGIN
        -- 2. Identify orders that transitioned to 'Delivered' in this batch
        -- (Ensures we only deduct ONCE by checking if the previous status was not Delivered)
        IF EXISTS (
            SELECT 1 
            FROM inserted i
            INNER JOIN deleted d ON i.Id = d.Id
            WHERE i.Status = 'Delivered' AND ISNULL(d.Status, '') != 'Delivered'
        )
        BEGIN
            -- A. Deduct Global Product Stock
            UPDATE SP
            SET SP.Stock = CASE WHEN (SP.Stock - OI.Quantity) < 0 THEN 0 ELSE (SP.Stock - OI.Quantity) END
            FROM SellerProducts SP
            INNER JOIN OrderItems OI ON SP.Id = OI.ProductId
            INNER JOIN inserted i ON OI.OrderId = i.Id
            INNER JOIN deleted d ON i.Id = d.Id
            WHERE i.Status = 'Delivered' AND ISNULL(d.Status, '') != 'Delivered';

            -- B. Deduct Size-wise Variant Stock (if the order item specifies a size)
            UPDATE PV
            SET PV.Stock = CASE WHEN (PV.Stock - OI.Quantity) < 0 THEN 0 ELSE (PV.Stock - OI.Quantity) END
            FROM ProductVariants PV
            INNER JOIN OrderItems OI ON PV.ProductId = OI.ProductId AND PV.VariantValue = OI.SelectedSize
            INNER JOIN inserted i ON OI.OrderId = i.Id
            INNER JOIN deleted d ON i.Id = d.Id
            WHERE i.Status = 'Delivered' AND ISNULL(d.Status, '') != 'Delivered'
              AND PV.VariantType = 'Size'
              AND OI.SelectedSize IS NOT NULL AND OI.SelectedSize <> '';
        END
    END
END
GO
PRINT 'Trigger trg_DeductStockOnDelivered deployed successfully!'
