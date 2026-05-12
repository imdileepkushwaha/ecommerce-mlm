<%@ Page Title="My Orders" Language="C#" MasterPageFile="~/usersite.Master" AutoEventWireup="true" CodeFile="UserOrders.aspx.cs" Inherits="ecommerce_mlm.UserOrders" %>
<%@ Register Src="~/UserSidebar.ascx" TagPrefix="uc" TagName="UserSidebar" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <section class="dashboard-wrapper">
        <!-- Breadcrumb -->
        <div class="dashboard-breadcrumb">
            <div class="container">
                <div class="dashboard-breadcrumb-inner">
                    <div class="breadcrumb-left">
                        <h3>My Orders</h3>
                    </div>
                    <div class="breadcrumb-right">
                        <a href="index.aspx"><i class="fas fa-home"></i></a>
                        <span> / Orders</span>
                    </div>
                </div>
            </div>
        </div>

        <div class="container dashboard-container dash-spacer">
            <div class="dashboard-layout">
                
                <!-- Sidebar -->
                <uc:UserSidebar runat="server" ID="UserSidebar" />

                <!-- Main Content -->
                <main class="dashboard-main-content">
                    <div class="main-card main-card-padded">
                        <div class="section-title section-title-bordered">
                            <div><i class="fas fa-shopping-basket"></i> Order History</div>
                        </div>

                        <asp:Panel ID="pnlNoOrders" runat="server" Visible="false" CssClass="empty-state-premium">
                            <div class="empty-state-visual">
                                <img src="assets/images/empty-orders.svg" alt="No Orders" />
                            </div>
                            <h3 class="empty-state-heading">Your Cart Deserves a Friend!</h3>
                            <p class="empty-state-sub">You haven't placed any orders yet. Let's fill this empty space with things you love!</p>
                            <a href="ProductList.aspx" class="btn-action-primary">
                                <i class="fas fa-shopping-bag"></i> Discover Products
                            </a>
                        </asp:Panel>

                        <div class="orders-table-container">
                            <asp:Repeater ID="rptOrders" runat="server">
                                <HeaderTemplate>
                                    <table class="orders-table">
                                        <thead>
                                            <tr>
                                                <th>Order ID</th>
                                                <th>Placed On</th>
                                                <th>Items</th>
                                                <th>Total Price</th>
                                                <th>Status</th>
                                                <th class="text-right">Action</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <tr>
                                        <td><span class="order-id">#ORD<%# Eval("Id") %></span></td>
                                        <td><div class="order-date"><%# Eval("CreatedAt", "{0:MMM dd, yyyy}") %><br/><span class="text-muted-sm"><%# Eval("CreatedAt", "{0:hh:mm tt}") %></span></div></td>
                                        <td><%# Eval("ItemCount") %> Item(s)</td>
                                        <td class="text-semibold-dark">₹ <%# String.Format("{0:n2}", Eval("TotalAmount")) %></td>
                                        <td>
                                            <span class='<%# "order-status-badge status-" + Eval("Status").ToString().Trim().ToLower().Replace(" ", "-") %>'>
                                                <i class="fas fa-circle dot-i"></i> <%# Eval("Status") %>
                                            </span>
                                        </td>
                                        <td class="text-right">
                                            <a href='<%# "OrderDetails.aspx?id=" + Eval("Id") %>' class="btn-view-order">
                                                <i class="fas fa-eye"></i> View
                                            </a>
                                        </td>
                                    </tr>
                                </ItemTemplate>
                                <FooterTemplate>
                                        </tbody>
                                    </table>
                                </FooterTemplate>
                            </asp:Repeater>
                        </div>

                    </div>
                </main>
            </div>
        </div>
    </section>
</asp:Content>
