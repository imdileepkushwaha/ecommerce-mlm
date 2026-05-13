<%@ Page Title="Dashboard - Performance Hub" Language="C#" MasterPageFile="~/seller/Seller.Master" AutoEventWireup="true" CodeFile="Dashboard.aspx.cs" Inherits="EcommerceWebsite.SellerDashboard" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <!-- Page Specific Styles or Scripts can be plugged here -->
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    
    <asp:Panel ID="pnlKycBlocker" runat="server" CssClass="kyc-banner-locked kyc-banner-dashboard" Visible="false">
        <i class="fas fa-circle-exclamation dash-banner-ico"></i>
        <div>
            <strong class="dash-banner-lbl">🚫 Product Uploads Locked</strong>
            You cannot add products or start selling yet. Please <a href="Kyc.aspx" class="dash-banner-anchor">submit your KYC portfolio</a> and wait for administrator approval to activate operations.
        </div>
    </asp:Panel>

    <!-- METRICS CARD GRID -->
    <section class="metric-grid">
        <div class="stat-card clr-blue">
            <div class="stat-lbl">Total Products</div>
            <div class="stat-val"><asp:Literal ID="litTotalProducts" runat="server">0</asp:Literal></div>
            <div class="stat-ico"><i class="fas fa-cube"></i></div>
        </div>

        <div class="stat-card clr-green">
            <div class="stat-lbl">Gross Earnings</div>
            <div class="stat-val">₹<asp:Literal ID="litTotalEarnings" runat="server">0.00</asp:Literal></div>
            <div class="stat-ico"><i class="fas fa-indian-rupee-sign"></i></div>
        </div>

        <div class="stat-card clr-orange">
            <div class="stat-lbl">Units Dispatched</div>
            <div class="stat-val"><asp:Literal ID="litUnitsSold" runat="server">0</asp:Literal></div>
            <div class="stat-ico"><i class="fas fa-truck-fast"></i></div>
        </div>

        <div class="stat-card">
            <div class="stat-lbl">Pending Clearances</div>
            <div class="stat-val"><asp:Literal ID="litPendingOrders" runat="server">0</asp:Literal></div>
            <div class="stat-ico"><i class="fas fa-clock"></i></div>
        </div>
    </section>

    <!-- CORE WORKSPACE GRID -->
    <div class="workspace-card">
        <div class="card-header">
            <h2>Recent Sale Invoices</h2>
            <span style="font-size:0.85rem; font-weight:700; color:#6366f1; background: #eff6ff; padding: 5px 15px; border-radius:20px; border:1px solid #bfdbfe;">
                Live Logs
            </span>
        </div>
        
        <div style="overflow-x: auto;">
            <asp:Repeater ID="rptRecentOrders" runat="server">
                <HeaderTemplate>
                    <table class="custom-tbl">
                        <thead>
                            <tr>
                                <th>INVOICE #</th>
                                <th>DATE</th>
                                <th>ITEM / DESCRIPTION</th>
                                <th>QTY</th>
                                <th>SUM</th>
                                <th>STATUS</th>
                            </tr>
                        </thead>
                        <tbody>
                </HeaderTemplate>
                <ItemTemplate>
                    <tr>
                        <td style="font-weight:700; color:var(--accent);">#INV-<%# Eval("OrderId") %></td>
                        <td style="color:#64748b;"><%# Eval("CreatedAt", "{0:dd MMM yyyy}") %></td>
                        <td style="font-weight:700; color:#334155;"><%# Eval("ProductName") %></td>
                        <td><%# Eval("Quantity") %> Units</td>
                        <td style="font-weight:800; color:#0f172a;">₹<%# Convert.ToDecimal(Eval("UnitPrice")) * Convert.ToInt32(Eval("Quantity")) %></td>
                        <td>
                            <span class='badge <%# GetStatusClass(Eval("Status")) %>'>
                                <%# Eval("Status") %>
                            </span>
                        </td>
                    </tr>
                </ItemTemplate>
                <FooterTemplate>
                        </tbody>
                    </table>
                </FooterTemplate>
            </asp:Repeater>
            
            <asp:PlaceHolder ID="phEmptyState" runat="server" Visible="false">
                <div class="empty-vector">
                    <i class="fas fa-receipt" style="font-size: 3rem; color: #cbd5e1; margin-bottom: 15px;"></i>
                    <h4 style="font-weight:700; color:#334155; margin-bottom:5px;">No Transactions Detected</h4>
                    <p style="font-size:0.85rem;">As buyers purchase products from your inventory, live logs will populate here.</p>
                </div>
            </asp:PlaceHolder>
        </div>
    </div>

</asp:Content>
