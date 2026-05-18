CREATE OR ALTER PROCEDURE sp_Seller_GetCouponsDashboard
    @SellerId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        COUNT(*) AS Total,
        SUM(CASE WHEN IsActive = 1 THEN 1 ELSE 0 END) AS Active,
        SUM(ISNULL(UsedCount, 0)) AS TotalUsed
    FROM Coupons
    WHERE SellerId = @SellerId;

    SELECT Id, SellerId, CouponCode, DiscountType, DiscountValue, MinOrderAmount,
           MaxDiscountAmount, StartDate, EndDate, UsageLimit, UsedCount, IsActive, CreatedAt
    FROM Coupons
    WHERE SellerId = @SellerId
    ORDER BY CreatedAt DESC;
END
GO

CREATE OR ALTER PROCEDURE sp_Seller_GetCouponById
    @CouponId INT,
    @SellerId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT Id, SellerId, CouponCode, DiscountType, DiscountValue, MinOrderAmount,
           MaxDiscountAmount, StartDate, EndDate, UsageLimit, UsedCount, IsActive, CreatedAt
    FROM Coupons
    WHERE Id = @CouponId AND SellerId = @SellerId;
END
GO

CREATE OR ALTER PROCEDURE sp_Seller_IsCouponCodeTaken
    @CouponCode VARCHAR(50),
    @ExcludeId INT = 0
AS
BEGIN
    SET NOCOUNT ON;

    SELECT COUNT(*)
    FROM Coupons
    WHERE CouponCode = @CouponCode AND Id <> @ExcludeId;
END
GO

CREATE OR ALTER PROCEDURE sp_Seller_SaveCoupon
    @CouponId INT = 0,
    @SellerId INT,
    @CouponCode VARCHAR(50),
    @DiscountType VARCHAR(20),
    @DiscountValue DECIMAL(18, 2),
    @MinOrderAmount DECIMAL(18, 2),
    @MaxDiscountAmount DECIMAL(18, 2) = NULL,
    @StartDate DATETIME,
    @EndDate DATETIME,
    @UsageLimit INT,
    @IsActive BIT
AS
BEGIN
    SET NOCOUNT ON;

    IF @CouponId = 0
    BEGIN
        INSERT INTO Coupons (SellerId, CouponCode, DiscountType, DiscountValue, MinOrderAmount,
            MaxDiscountAmount, StartDate, EndDate, UsageLimit, IsActive)
        VALUES (@SellerId, @CouponCode, @DiscountType, @DiscountValue, @MinOrderAmount,
            @MaxDiscountAmount, @StartDate, @EndDate, @UsageLimit, @IsActive);

        SELECT SCOPE_IDENTITY() AS NewId;
    END
    ELSE
    BEGIN
        UPDATE Coupons
        SET CouponCode = @CouponCode,
            DiscountType = @DiscountType,
            DiscountValue = @DiscountValue,
            MinOrderAmount = @MinOrderAmount,
            MaxDiscountAmount = @MaxDiscountAmount,
            StartDate = @StartDate,
            EndDate = @EndDate,
            UsageLimit = @UsageLimit,
            IsActive = @IsActive
        WHERE Id = @CouponId AND SellerId = @SellerId;

        SELECT @CouponId AS NewId;
    END
END
GO

CREATE OR ALTER PROCEDURE sp_Seller_ToggleCoupon
    @CouponId INT,
    @SellerId INT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Coupons
    SET IsActive = CASE WHEN IsActive = 1 THEN 0 ELSE 1 END
    WHERE Id = @CouponId AND SellerId = @SellerId;
END
GO

CREATE OR ALTER PROCEDURE sp_Seller_DeleteCoupon
    @CouponId INT,
    @SellerId INT
AS
BEGIN
    SET NOCOUNT ON;

    DELETE FROM Coupons WHERE Id = @CouponId AND SellerId = @SellerId;
END
GO
