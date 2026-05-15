$connectionString = "Server=.;Database=ecomm_db;Trusted_Connection=True;"
$sql = @"
-- 1. Drop the old conflicting trigger to avoid double deductions
IF OBJECT_ID('trg_UpdateStockOnDelivery', 'TR') IS NOT NULL
BEGIN
    DROP TRIGGER trg_UpdateStockOnDelivery;
    PRINT 'Dropped old trg_UpdateStockOnDelivery trigger.';
END

-- 2. Create/Replace with the Unified Comprehensive Trigger
EXEC('
CREATE OR ALTER TRIGGER trg_DeductStockOnDelivered
ON Orders
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF UPDATE(Status)
    BEGIN
        -- ===============================================================
        -- ACTION A: DEDUCT STOCK (Transition to ''Delivered'')
        -- ===============================================================
        IF EXISTS (
            SELECT 1 FROM inserted i INNER JOIN deleted d ON i.Id = d.Id
            WHERE LOWER(i.Status) = ''delivered'' AND ISNULL(LOWER(d.Status), '''') != ''delivered''
        )
        BEGIN
            -- 1. Global Stock Deduction
            UPDATE SP
            SET SP.Stock = CASE WHEN (SP.Stock - OI.Quantity) < 0 THEN 0 ELSE (SP.Stock - OI.Quantity) END
            FROM SellerProducts SP
            INNER JOIN OrderItems OI ON SP.Id = OI.ProductId
            INNER JOIN inserted i ON OI.OrderId = i.Id
            INNER JOIN deleted d ON i.Id = d.Id
            WHERE LOWER(i.Status) = ''delivered'' AND ISNULL(LOWER(d.Status), '''') != ''delivered'';

            -- 2. Variant Size Stock Deduction
            UPDATE PV
            SET PV.Stock = CASE WHEN (PV.Stock - OI.Quantity) < 0 THEN 0 ELSE (PV.Stock - OI.Quantity) END
            FROM ProductVariants PV
            INNER JOIN OrderItems OI ON PV.ProductId = OI.ProductId AND PV.VariantValue = OI.SelectedSize
            INNER JOIN inserted i ON OI.OrderId = i.Id
            INNER JOIN deleted d ON i.Id = d.Id
            WHERE LOWER(i.Status) = ''delivered'' AND ISNULL(LOWER(d.Status), '''') != ''delivered''
              AND PV.VariantType = ''Size''
              AND OI.SelectedSize IS NOT NULL AND OI.SelectedSize <> '''';
        END

        -- ===============================================================
        -- ACTION B: RESTORE STOCK (Transition AWAY from ''Delivered'')
        -- ===============================================================
        IF EXISTS (
            SELECT 1 FROM inserted i INNER JOIN deleted d ON i.Id = d.Id
            WHERE LOWER(d.Status) = ''delivered'' AND ISNULL(LOWER(i.Status), '''') != ''delivered''
        )
        BEGIN
            -- 1. Global Stock Restoration
            UPDATE SP
            SET SP.Stock = SP.Stock + OI.Quantity
            FROM SellerProducts SP
            INNER JOIN OrderItems OI ON SP.Id = OI.ProductId
            INNER JOIN inserted i ON OI.OrderId = i.Id
            INNER JOIN deleted d ON i.Id = d.Id
            WHERE LOWER(d.Status) = ''delivered'' AND ISNULL(LOWER(i.Status), '''') != ''delivered'';

            -- 2. Variant Size Stock Restoration
            UPDATE PV
            SET PV.Stock = PV.Stock + OI.Quantity
            FROM ProductVariants PV
            INNER JOIN OrderItems OI ON PV.ProductId = OI.ProductId AND PV.VariantValue = OI.SelectedSize
            INNER JOIN inserted i ON OI.OrderId = i.Id
            INNER JOIN deleted d ON i.Id = d.Id
            WHERE LOWER(d.Status) = ''delivered'' AND ISNULL(LOWER(i.Status), '''') != ''delivered''
              AND PV.VariantType = ''Size''
              AND OI.SelectedSize IS NOT NULL AND OI.SelectedSize <> '''';
        END
    END
END
');
PRINT 'Unified trigger trg_DeductStockOnDelivered deployed/upgraded successfully.';
"@

Invoke-Sqlcmd -ConnectionString $connectionString -Query $sql | Out-String | Write-Host
