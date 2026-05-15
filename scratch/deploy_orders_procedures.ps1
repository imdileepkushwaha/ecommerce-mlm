$connString = "Server=.;Database=ecomm_db;Trusted_Connection=True;"
$sql = @"
-- 1. SP FOR GETTING SELLER ORDER KPIs
CREATE OR ALTER PROCEDURE sp_Seller_GetOrderMetrics
    @SellerId INT,
    @DateFilter NVARCHAR(10) = 'all'
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @StartDate DATETIME = '1753-01-01';
    IF @DateFilter = '24h' SET @StartDate = DATEADD(hour, -24, GETDATE());
    ELSE IF @DateFilter = '7d' SET @StartDate = DATEADD(day, -7, GETDATE());
    ELSE IF @DateFilter = '30d' SET @StartDate = DATEADD(day, -30, GETDATE());

    SELECT 
        COUNT(DISTINCT o.Id) as TotalOrders,
        COUNT(DISTINCT CASE WHEN o.Status IN ('Pending', 'Placed', 'Processing', 'Confirmed') THEN o.Id END) as NeedsConfirm,
        COUNT(DISTINCT CASE WHEN o.Status IN ('Shipped', 'Dispatched', 'In Transit') THEN o.Id END) as InTransit,
        COUNT(DISTINCT CASE WHEN o.Status = 'Delivered' THEN o.Id END) as Delivered,
        COUNT(DISTINCT CASE WHEN o.Status LIKE '%Return%' THEN o.Id END) as ReturnRequests
    FROM Orders o
    JOIN OrderItems oi ON o.Id = oi.OrderId
    JOIN SellerProducts p ON oi.ProductId = p.Id
    WHERE p.SellerId = @SellerId
      AND o.CreatedAt >= @StartDate;
END
GO

-- 2. SP FOR GETTING SELLER ORDERS LIST WITH PERIOD FILTERING
CREATE OR ALTER PROCEDURE sp_Seller_GetOrdersList
    @SellerId INT,
    @DateFilter NVARCHAR(10) = 'all'
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @StartDate DATETIME = '1753-01-01';
    IF @DateFilter = '24h' SET @StartDate = DATEADD(hour, -24, GETDATE());
    ELSE IF @DateFilter = '7d' SET @StartDate = DATEADD(day, -7, GETDATE());
    ELSE IF @DateFilter = '30d' SET @StartDate = DATEADD(day, -30, GETDATE());

    SELECT DISTINCT 
        o.Id,
        o.OrderRef,
        o.TotalAmount,
        o.Status,
        o.CreatedAt,
        o.PaymentMode,
        o.ReturnReason,
        o.ReturnMessage,
        ISNULL(u.FullName, 'Guest Customer') as CustName,
        ISNULL(u.Email, 'noemail@yopmail.com') as CustEmail,
        (SELECT TOP 1 ISNULL(p3.Category, 'General')
         FROM OrderItems oi3 
         JOIN SellerProducts p3 ON oi3.ProductId = p3.Id 
         WHERE oi3.OrderId = o.Id AND p3.SellerId = @SellerId) as TopCategory,
        (SELECT SUM(oi2.Quantity) 
         FROM OrderItems oi2 
         JOIN SellerProducts p2 ON oi2.ProductId = p2.Id 
         WHERE oi2.OrderId = o.Id AND p2.SellerId = @SellerId) as SellerItemCount,
        (SELECT SUM(oi2.UnitPrice * oi2.Quantity) 
         FROM OrderItems oi2 
         JOIN SellerProducts p2 ON oi2.ProductId = p2.Id 
         WHERE oi2.OrderId = o.Id AND p2.SellerId = @SellerId) as SellerTotalAmount
    FROM Orders o
    LEFT JOIN Users u ON o.UserId = u.Id
    JOIN OrderItems oi ON o.Id = oi.OrderId
    JOIN SellerProducts p ON oi.ProductId = p.Id
    WHERE p.SellerId = @SellerId
      AND o.CreatedAt >= @StartDate
    ORDER BY o.Id DESC;
END
GO

-- 3. SP FOR UPDATING ORDER STATUS
CREATE OR ALTER PROCEDURE sp_Seller_UpdateOrderStatus
    @OrderId INT,
    @Status NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Orders 
    SET Status = @Status, 
        UpdatedAt = GETDATE() 
    WHERE Id = @OrderId;
END
GO

-- 4. SP FOR CUSTOMER REQUESTING RETURN
CREATE OR ALTER PROCEDURE sp_Customer_RequestOrderReturn
    @OrderId INT,
    @Reason NVARCHAR(MAX),
    @Message NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE Orders 
    SET Status = 'Return requested', 
        ReturnReason = @Reason, 
        ReturnMessage = @Message, 
        UpdatedAt = GETDATE() 
    WHERE Id = @OrderId;
END
GO

-- 5. SP FOR SELLER VIEWING SPECIFIC ORDER HEADER DETAILS
CREATE OR ALTER PROCEDURE sp_Seller_GetOrderDetail
    @OrderId INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT o.*, 
           a.FullName as AddrFullName, a.PhoneNumber, a.StreetAddress, a.City, a.State, a.ZipCode, a.Tag,
           u.Email as CustEmail, u.FullName as CustFullName
    FROM Orders o
    LEFT JOIN Addresses a ON o.AddressId = a.Id
    LEFT JOIN Users u ON o.UserId = u.Id
    WHERE o.Id = @OrderId;
END
GO
"@

# Execute blocks separated by GO
$connection = New-Object System.Data.SqlClient.SqlConnection($connString)
$connection.Open()

$blocks = $sql -split "(?mi)^\s*GO\s*$"
foreach ($block in $blocks) {
    if ($block.Trim()) {
        $command = New-Object System.Data.SqlClient.SqlCommand($block, $connection)
        $command.ExecuteNonQuery()
    }
}
$connection.Close()

Write-Host "Optimized Stored Procedures Deployed Successfully!"
