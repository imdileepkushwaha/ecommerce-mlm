<%@ Page Title="Order Details" Language="C#" MasterPageFile="~/admin/Admin.Master" AutoEventWireup="true"
    CodeFile="ViewOrder.aspx.cs" Inherits="ecommerce_mlm.admin.ViewOrder" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <link rel="stylesheet" href="assets/css/admin-users.css?v=1.2" />
    <link rel="stylesheet" href="assets/css/admin-orders.css?v=1.0" />
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="mu-page">
        <a href="ManageOrders.aspx" class="mo-vo-back"><i class="fas fa-arrow-left"></i> Back to orders</a>

        <asp:Panel ID="pnlFlash" runat="server" Visible="false" CssClass="mu-flash">
            <i runat="server" id="icoFlash" class="fas fa-check-circle"></i>
            <asp:Literal ID="litFlash" runat="server" />
        </asp:Panel>

        <asp:Panel ID="pnlContent" runat="server">
            <span class="mu-overline">ORDER</span>
            <h1 class="mu-title"><asp:Literal ID="litPageTitle" runat="server" /></h1>
            <p class="mu-sub"><asp:Literal ID="litPageSub" runat="server" /></p>

            <div class="mo-vo-grid">
                <div class="mo-vo-card">
                    <h4>Order summary</h4>
                    <div class="mo-vo-row"><span>Status</span><span><asp:Literal ID="litStatus" runat="server" /></span></div>
                    <div class="mo-vo-row"><span>Total</span><span><asp:Literal ID="litTotal" runat="server" /></span></div>
                    <div class="mo-vo-row"><span>Items</span><span><asp:Literal ID="litItemCount" runat="server" /></span></div>
                    <div class="mo-vo-row"><span>Payment</span><span><asp:Literal ID="litPayment" runat="server" /></span></div>
                    <div class="mo-vo-row"><span>Placed</span><span><asp:Literal ID="litPlaced" runat="server" /></span></div>
                </div>
                <div class="mo-vo-card">
                    <h4>Customer</h4>
                    <div class="mo-vo-row"><span>Name</span><span><asp:Literal ID="litCustomer" runat="server" /></span></div>
                    <div class="mo-vo-row"><span>Email</span><span><asp:Literal ID="litEmail" runat="server" /></span></div>
                    <div class="mo-vo-row"><span>Shipping</span><span style="max-width:55%;"><asp:Literal ID="litShipping" runat="server" /></span></div>
                </div>
            </div>

            <div class="mo-vo-items">
                <table>
                    <thead>
                        <tr>
                            <th>Product</th>
                            <th>Qty</th>
                            <th>Price</th>
                            <th>Line total</th>
                        </tr>
                    </thead>
                    <tbody>
                        <asp:Repeater ID="rptItems" runat="server">
                            <ItemTemplate>
                                <tr>
                                    <td><%# Eval("ProductName") %></td>
                                    <td><%# Eval("Quantity") %></td>
                                    <td>₹<%# Convert.ToDecimal(Eval("Price")).ToString("N0") %></td>
                                    <td><strong>₹<%# (Convert.ToDecimal(Eval("Price")) * Convert.ToInt32(Eval("Quantity"))).ToString("N0") %></strong></td>
                                </tr>
                            </ItemTemplate>
                        </asp:Repeater>
                    </tbody>
                </table>
            </div>

            <asp:Panel ID="pnlActions" runat="server" CssClass="mo-vo-actions">
                <asp:LinkButton ID="btnShip" runat="server" CssClass="mo-vo-btn mo-vo-btn-primary" OnClick="btnShip_Click"
                    OnClientClick="return confirm('Mark this order as Shipped?');" Visible="false">
                    <i class="fas fa-truck"></i> Mark shipped
                </asp:LinkButton>
                <asp:LinkButton ID="btnDeliver" runat="server" CssClass="mo-vo-btn mo-vo-btn-primary" OnClick="btnDeliver_Click"
                    OnClientClick="return confirm('Mark this order as Delivered?');" Visible="false">
                    <i class="fas fa-check-double"></i> Mark delivered
                </asp:LinkButton>
                <asp:LinkButton ID="btnCancel" runat="server" CssClass="mo-vo-btn" OnClick="btnCancel_Click"
                    OnClientClick="return confirm('Cancel this order?');" Visible="false">
                    <i class="fas fa-ban"></i> Cancel order
                </asp:LinkButton>
            </asp:Panel>
        </asp:Panel>

        <asp:Panel ID="pnlError" runat="server" Visible="false" CssClass="mu-empty-state">
            <div class="mu-empty-ico mu-empty-ico-muted"><i class="fas fa-exclamation-triangle"></i></div>
            <h4 class="mu-empty-title">Order not found</h4>
            <p class="mu-empty-desc">This order may have been removed or the link is invalid.</p>
            <a href="ManageOrders.aspx" class="mu-empty-btn" style="text-decoration:none;"><i class="fas fa-arrow-left"></i> Back to orders</a>
        </asp:Panel>
    </div>
</asp:Content>
