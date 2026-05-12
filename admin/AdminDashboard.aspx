<%@ Page Title="Dashboard" Language="C#" MasterPageFile="~/admin/Admin.Master" AutoEventWireup="true" CodeFile="AdminDashboard.aspx.cs" Inherits="ecommerce_mlm.admin.AdminDashboard" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="u-mb-30">
        <h1 class="u-txt-lg">Welcome Back, System Administrator</h1>
        <p class="u-txt-subtitle u-mt-5">Here's a high-level pulse projection of the infrastructure today.</p>
    </div>

    <!-- Stats Row -->
    <div class="card-stats-grid">
        <div class="stat-card">
            <div class="stat-hdr">
                <span>Total System Users</span>
                <i class="fas fa-users u-stat-ico-p"></i>
            </div>
            <div class="stat-val"><asp:Literal ID="litTotalUsers" runat="server">0</asp:Literal></div>
            <div class="u-stat-inc u-txt-gray-sm u-mt-5">Registered user database active</div>
        </div>

        <div class="stat-card">
            <div class="stat-hdr">
                <span>Gross Revenue Flow</span>
                <i class="fas fa-rupee-sign u-stat-ico-g"></i>
            </div>
            <div class="stat-val"><asp:Literal ID="litRevenue" runat="server">₹0</asp:Literal></div>
            <div class="u-stat-inc u-txt-gray-sm u-mt-5">Cumulative infrastructure sales volume</div>
        </div>

        <div class="stat-card">
            <div class="stat-hdr">
                <span>Active Pending Orders</span>
                <i class="fas fa-shopping-cart u-stat-ico-o"></i>
            </div>
            <div class="stat-val"><asp:Literal ID="litPendingOrders" runat="server">0</asp:Literal></div>
            <div class="u-stat-dec u-txt-gray-sm u-mt-5">Requires processing attention</div>
        </div>

        <div class="stat-card">
            <div class="stat-hdr">
                <span>Total Published Items</span>
                <i class="fas fa-box u-stat-ico-pink"></i>
            </div>
            <div class="stat-val"><asp:Literal ID="litTotalProducts" runat="server">0</asp:Literal></div>
            <div class="u-txt-gray-sm u-mt-5">Active product catalog matrix</div>
        </div>
    </div>

    <!-- Sample Visual Placeholder Area -->
    <div class="u-placeholder-box">
        <i class="fas fa-chart-line u-lg-icon u-mb-15"></i>
        <h3 class="u-color-dark">Operational Metrics Engine</h3>
        <p class="u-txt-09">Visual chart algorithms and real-time log streaming grids will be deployed into this module cluster.</p>
    </div>
</asp:Content>
