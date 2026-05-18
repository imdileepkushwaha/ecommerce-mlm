CREATE OR ALTER PROCEDURE sp_Seller_GetNotificationSummary
    @SellerId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        ISNULL((SELECT KycStatus FROM SellerUsers WHERE Id = @SellerId), '') AS KycStatus,
        ISNULL((SELECT COUNT(*) FROM SellerProducts WHERE SellerId = @SellerId AND Stock < 10 AND Stock > 0), 0) AS LowStockCount,
        ISNULL((SELECT COUNT(*) FROM SellerProducts WHERE SellerId = @SellerId AND Stock <= 0), 0) AS OutOfStockCount,
        ISNULL((
            SELECT COUNT(DISTINCT oi.OrderId)
            FROM OrderItems oi
            INNER JOIN Orders o ON oi.OrderId = o.Id
            INNER JOIN SellerProducts p ON oi.ProductId = p.Id
            WHERE p.SellerId = @SellerId AND o.Status IN ('Placed', 'Pending', 'Processing')
        ), 0) AS PendingOrdersCount;
END
GO

CREATE OR ALTER PROCEDURE sp_Seller_GetOrderItems
    @OrderId INT,
    @SellerId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT oi.*,
           p.MainImage,
           p.Slug,
           ISNULL(p.Category, 'General') AS Category,
           ISNULL(p.ColorName, '--') AS ColorName,
           ISNULL(p.ColorCode, '') AS ColorCode,
           o.Status AS OrderStatus
    FROM OrderItems oi
    INNER JOIN SellerProducts p ON oi.ProductId = p.Id
    INNER JOIN Orders o ON oi.OrderId = o.Id
    WHERE oi.OrderId = @OrderId AND p.SellerId = @SellerId;
END
GO
