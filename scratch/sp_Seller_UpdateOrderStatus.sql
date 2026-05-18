CREATE OR ALTER PROCEDURE sp_Seller_UpdateOrderStatus
    @OrderId INT,
    @Status NVARCHAR(100),
    @PickupNote NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @PrevStatus NVARCHAR(100);
    DECLARE @CouponCode NVARCHAR(50);
    DECLARE @DiscountAmount DECIMAL(18, 2);

    SELECT @PrevStatus = Status,
           @CouponCode = NULLIF(LTRIM(RTRIM(CouponCode)), ''),
           @DiscountAmount = ISNULL(DiscountAmount, 0)
    FROM Orders
    WHERE Id = @OrderId;

    IF @PrevStatus IS NULL
        RETURN;

    UPDATE Orders
    SET Status = @Status,
        ReturnPickupNote = CASE WHEN @PickupNote IS NOT NULL THEN @PickupNote ELSE ReturnPickupNote END,
        UpdatedAt = GETDATE()
    WHERE Id = @OrderId;

    -- Release coupon usage when order is fully cancelled (seller-approved)
    IF @Status = 'Cancelled'
       AND ISNULL(@PrevStatus, '') <> 'Cancelled'
       AND @CouponCode IS NOT NULL
       AND @DiscountAmount > 0
    BEGIN
        UPDATE Coupons
        SET UsedCount = CASE WHEN UsedCount > 0 THEN UsedCount - 1 ELSE 0 END
        WHERE CouponCode = @CouponCode;
    END
END
