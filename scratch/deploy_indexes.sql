-- SQL Optimization Script: Deploying Indexes for MLM E-Commerce
USE [ecomm_db];
GO

-- 1. Index for Master Page Cart Count (Runs on every page view!)
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_CartItems_SessionId' AND object_id = OBJECT_ID('CartItems'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_CartItems_SessionId ON CartItems(SessionId) INCLUDE (Quantity, IsSavedForLater);
    PRINT 'Created index IX_CartItems_SessionId';
END
ELSE BEGIN PRINT 'Index IX_CartItems_SessionId already exists'; END
GO

-- 2. Index for Master Page Wishlist Count (Runs on every page view!)
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_WishlistItems_SessionId' AND object_id = OBJECT_ID('WishlistItems'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_WishlistItems_SessionId ON WishlistItems(SessionId);
    PRINT 'Created index IX_WishlistItems_SessionId';
END
ELSE BEGIN PRINT 'Index IX_WishlistItems_SessionId already exists'; END
GO

-- 3. Index for Orders by UserId (Dashboard, OrderDetails)
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Orders_UserId' AND object_id = OBJECT_ID('Orders'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Orders_UserId ON Orders(UserId);
    PRINT 'Created index IX_Orders_UserId';
END
ELSE BEGIN PRINT 'Index IX_Orders_UserId already exists'; END
GO

-- 4. Index for OrderItems by OrderId (OrderDetails, Checkout, Invoices)
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_OrderItems_OrderId' AND object_id = OBJECT_ID('OrderItems'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_OrderItems_OrderId ON OrderItems(OrderId);
    PRINT 'Created index IX_OrderItems_OrderId';
END
ELSE BEGIN PRINT 'Index IX_OrderItems_OrderId already exists'; END
GO

-- 5. Index for OrderItems by ProductId
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_OrderItems_ProductId' AND object_id = OBJECT_ID('OrderItems'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_OrderItems_ProductId ON OrderItems(ProductId);
    PRINT 'Created index IX_OrderItems_ProductId';
END
ELSE BEGIN PRINT 'Index IX_OrderItems_ProductId already exists'; END
GO

-- 6. Indexes for Users MLM Sponsor & Parent relations (Genealogy tree searches)
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Users_SponsorId' AND object_id = OBJECT_ID('Users'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Users_SponsorId ON Users(SponsorId);
    PRINT 'Created index IX_Users_SponsorId';
END
ELSE BEGIN PRINT 'Index IX_Users_SponsorId already exists'; END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Users_ParentId' AND object_id = OBJECT_ID('Users'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Users_ParentId ON Users(ParentId);
    PRINT 'Created index IX_Users_ParentId';
END
ELSE BEGIN PRINT 'Index IX_Users_ParentId already exists'; END
GO

-- 7. Index for User Income records by UserId
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_UserIncome_UserId' AND object_id = OBJECT_ID('UserIncome'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_UserIncome_UserId ON UserIncome(UserId);
    PRINT 'Created index IX_UserIncome_UserId';
END
ELSE BEGIN PRINT 'Index IX_UserIncome_UserId already exists'; END
GO

PRINT 'All indexes deployed successfully!';
GO
