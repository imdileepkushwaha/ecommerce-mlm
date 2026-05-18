<%@ Page Title="Dashboard" Language="C#" MasterPageFile="~/admin/Admin.Master" AutoEventWireup="true" CodeFile="AdminDashboard.aspx.cs" Inherits="ecommerce_mlm.admin.AdminDashboard" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <link rel="stylesheet" href="assets/css/admin-dashboard.css?v=1.4" />
    <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.1/dist/chart.umd.min.js"></script>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <asp:HiddenField ID="hfChartData" runat="server" Value="{}" />

    <!-- Page header -->
    <div class="adm-dash-top">
        <div class="adm-dash-top-left">
            <span class="adm-overline">OVERVIEW</span>
            <h1 class="adm-dash-title">Dashboard</h1>
            <p class="adm-dash-sub">Orders, revenue, and activity across your store.</p>
        </div>
        <div class="adm-dash-top-right">
            <div class="adm-date-pill">
                <i class="far fa-calendar"></i>
                <asp:Literal ID="litDateRange" runat="server" />
            </div>
            <button type="button" class="adm-icon-btn" title="Export (coming soon)"><i class="fas fa-download"></i></button>
            <asp:LinkButton ID="btnRefresh" runat="server" CssClass="adm-icon-btn" OnClick="btnRefresh_Click" title="Refresh">
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M23 4v6h-6"></path><path d="M1 20v-6h6"></path><path d="M3.51 9a9 9 0 0 1 14.85-3.36L23 10M1 14l4.64 4.36A9 9 0 0 0 20.49 15"></path></svg>
            </asp:LinkButton>
        </div>
    </div>

    <!-- Welcome banner -->
    <div class="adm-welcome">
        <div class="adm-welcome-left">
            <h2>Welcome back, <asp:Literal ID="litWelcomeName" runat="server" /></h2>
            <p>Here's what's happening today — jump in where you're needed.</p>
            <div class="adm-welcome-stats">
                <div class="adm-welcome-stat"><strong><asp:Literal ID="litBannerUsers" runat="server" /></strong><span>USERS</span></div>
                <div class="adm-welcome-stat"><strong><asp:Literal ID="litBannerOrders" runat="server" /></strong><span>ORDERS</span></div>
                <div class="adm-welcome-stat"><strong><asp:Literal ID="litBannerProcessing" runat="server" /></strong><span>PROCESSING</span></div>
            </div>
        </div>
        <div class="adm-welcome-actions">
            <a href="ManageUsers.aspx" class="adm-welcome-btn adm-welcome-btn-active">Users</a>
            <a href="ManageOrders.aspx" class="adm-welcome-btn">All orders</a>
            <a href="ManageSellers.aspx" class="adm-welcome-btn">Sellers</a>
        </div>
    </div>

    <!-- KPI + Quick actions row -->
    <div class="adm-metrics-row">
    <div class="adm-metrics-kpi">
    <div class="adm-kpi-grid">
        <div class="adm-kpi-card">
            <div class="adm-kpi-head"><span>Total Orders</span><div class="adm-kpi-ico adm-kpi-ico-blue"><i class="fas fa-file-invoice"></i></div></div>
            <div class="adm-kpi-val"><asp:Literal ID="litTotalOrders" runat="server" /></div>
            <asp:Literal ID="litOrdersTrend" runat="server" />
        </div>
        <div class="adm-kpi-card">
            <div class="adm-kpi-head"><span>Revenue (store)</span><div class="adm-kpi-ico adm-kpi-ico-red"><i class="fas fa-rupee-sign"></i></div></div>
            <div class="adm-kpi-val"><asp:Literal ID="litRevenue" runat="server" /></div>
            <asp:Literal ID="litRevenueTrend" runat="server" />
        </div>
        <div class="adm-kpi-card">
            <div class="adm-kpi-head"><span>Processing Queue</span><div class="adm-kpi-ico adm-kpi-ico-purple"><i class="fas fa-clock"></i></div></div>
            <div class="adm-kpi-val"><asp:Literal ID="litProcessing" runat="server" /></div>
            <span class="adm-stat-hint">Orders awaiting fulfilment</span>
        </div>
        <div class="adm-kpi-card">
            <div class="adm-kpi-head"><span>Total Users</span><div class="adm-kpi-ico adm-kpi-ico-pink"><i class="fas fa-users"></i></div></div>
            <div class="adm-kpi-val"><asp:Literal ID="litTotalUsers" runat="server" /></div>
            <asp:Literal ID="litUsersTrend" runat="server" />
        </div>
        <div class="adm-kpi-card adm-kpi-wide">
            <div class="adm-kpi-head"><span>Active Sellers</span><div class="adm-kpi-ico adm-kpi-ico-cyan"><i class="fas fa-store"></i></div></div>
            <div class="adm-kpi-val"><asp:Literal ID="litActiveSellers" runat="server" /></div>
            <span class="adm-stat-hint">Seller panel accounts</span>
        </div>
    </div>
    </div>

    <aside class="adm-quick-nav">
        <!-- <div class="adm-quick-nav-head">
            <h4>Quick Actions</h4>
            <p>Jump to admin modules</p>
        </div> -->
        <nav class="adm-quick-nav-list">
            <a href="ManagePayouts.aspx" class="adm-quick-link">
                <span class="adm-quick-ico adm-quick-ico-red"><i class="fas fa-rupee-sign"></i></span>
                <span class="adm-quick-text">Admin Earnings</span>
                <i class="fas fa-chevron-right adm-quick-arrow"></i>
            </a>
            <a href="ManageProducts.aspx" class="adm-quick-link">
                <span class="adm-quick-ico adm-quick-ico-blue"><i class="fas fa-box"></i></span>
                <span class="adm-quick-text">Product Approvals</span>
                <i class="fas fa-chevron-right adm-quick-arrow"></i>
            </a>
            <a href="KycAudits.aspx" class="adm-quick-link">
                <span class="adm-quick-ico adm-quick-ico-purple"><i class="fas fa-id-card"></i></span>
                <span class="adm-quick-text">Seller KYC</span>
                <i class="fas fa-chevron-right adm-quick-arrow"></i>
            </a>
            <a href="ManagePayouts.aspx" class="adm-quick-link">
                <span class="adm-quick-ico adm-quick-ico-green"><i class="fas fa-money-bill-wave"></i></span>
                <span class="adm-quick-text">Withdrawals</span>
                <i class="fas fa-chevron-right adm-quick-arrow"></i>
            </a>
            <a href="AccountDeletions.aspx" class="adm-quick-link">
                <span class="adm-quick-ico adm-quick-ico-amber"><i class="fas fa-user-minus"></i></span>
                <span class="adm-quick-text">Deletion Requests</span>
                <i class="fas fa-chevron-right adm-quick-arrow"></i>
            </a>
            <a href="AdminSettings.aspx" class="adm-quick-link">
                <span class="adm-quick-ico adm-quick-ico-gray"><i class="fas fa-cog"></i></span>
                <span class="adm-quick-text">Settings</span>
                <i class="fas fa-chevron-right adm-quick-arrow"></i>
            </a>
        </nav>
    </aside>
    </div>

    <!-- Charts -->
    <div class="adm-charts-row">
        <div class="adm-panel">
            <div class="adm-panel-head">
                <h3>Orders (7 days)</h3>
                <span class="adm-panel-tag">This week</span>
            </div>
            <div class="adm-chart-wrap"><canvas id="chartOrders7"></canvas></div>
            <p class="adm-panel-foot"><asp:Literal ID="litOrders7dSummary" runat="server" /></p>
        </div>
        <div class="adm-panel">
            <div class="adm-panel-head">
                <h3>Revenue (6 months)</h3>
                <span class="adm-panel-tag"><%= DateTime.Now.Year %></span>
            </div>
            <div class="adm-chart-wrap"><canvas id="chartRevenue6"></canvas></div>
            <p class="adm-panel-foot"><asp:Literal ID="litRevenueLifetime" runat="server" /></p>
        </div>
        <div class="adm-panel">
            <div class="adm-panel-head"><h3>Order status mix</h3></div>
            <div class="adm-donut-wrap">
                <canvas id="chartStatus"></canvas>
                <div id="statusLegend" class="adm-status-legend"></div>
            </div>
        </div>
    </div>

    <!-- Activity lists -->
    <div class="adm-lists-row">
        <div class="adm-panel">
            <div class="adm-panel-head">
                <h3>Recent transactions</h3>
                <a href="ManageOrders.aspx" class="adm-link">View all</a>
            </div>
            <asp:PlaceHolder ID="phNoRecentOrders" runat="server" Visible="false">
                <p class="adm-empty">No orders yet.</p>
            </asp:PlaceHolder>
            <asp:Repeater ID="rptRecentOrders" runat="server">
                <ItemTemplate>
                    <div class="adm-list-item">
                        <div class="adm-list-main">
                            <strong><%# GetOrderRef(Eval("Id"), Eval("OrderRef")) %></strong>
                            <span><%# Eval("FullName") %> · <%# FormatOrderDate(Eval("CreatedAt")) %></span>
                        </div>
                        <div class="adm-list-end">
                            <span class='<%# GetStatusPillClass(Eval("Status")) %>'><%# Eval("Status") %></span>
                            <strong><%# FormatAmount(Eval("TotalAmount")) %></strong>
                        </div>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>

        <div class="adm-panel">
            <div class="adm-panel-head">
                <h3>Recently registered</h3>
                <a href="ManageUsers.aspx" class="adm-link">View all</a>
            </div>
            <asp:PlaceHolder ID="phNoRecentUsers" runat="server" Visible="false">
                <p class="adm-empty">No users yet.</p>
            </asp:PlaceHolder>
            <asp:Repeater ID="rptRecentUsers" runat="server">
                <ItemTemplate>
                    <div class="adm-list-item adm-list-user">
                        <div class="adm-user-avatar"><%# GetUserInitials(Eval("FullName")) %></div>
                        <div class="adm-list-main">
                            <strong><%# Eval("FullName") %></strong>
                            <span><%# Eval("Email") %></span>
                        </div>
                        <span class="adm-list-date"><%# FormatUserDate(Eval("CreatedAt")) %></span>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>

        <div class="adm-panel">
            <div class="adm-panel-head">
                <h3>Needs attention</h3>
                <a href="ManageOrders.aspx" class="adm-link">Open queue</a>
            </div>
            <asp:PlaceHolder ID="phNoAttention" runat="server" Visible="false">
                <p class="adm-empty">No orders in processing queue.</p>
            </asp:PlaceHolder>
            <asp:Repeater ID="rptNeedsAttention" runat="server">
                <ItemTemplate>
                    <div class="adm-list-item adm-list-attn">
                        <div class="adm-list-main">
                            <strong><%# GetOrderRef(Eval("Id"), Eval("OrderRef")) %></strong>
                            <span><%# Eval("Status") %> · <%# FormatOrderDate(Eval("CreatedAt")) %></span>
                        </div>
                        <a href='<%# "ManageOrders.aspx" %>' class="adm-review-link">Review</a>
                    </div>
                </ItemTemplate>
            </asp:Repeater>
        </div>
    </div>

    <script type="text/javascript">
        document.addEventListener('DOMContentLoaded', function () {
            var raw = document.getElementById('<%= hfChartData.ClientID %>');
            if (!raw || !raw.value) return;
            var d = {};
            try { d = JSON.parse(raw.value); } catch (e) { return; }

            var gridColor = 'rgba(226, 232, 240, 0.8)';
            var fontFamily = "'Plus Jakarta Sans', sans-serif";

            if (document.getElementById('chartOrders7')) {
                new Chart(document.getElementById('chartOrders7'), {
                    type: 'bar',
                    data: {
                        labels: d.orders7Labels || [],
                        datasets: [{
                            data: d.orders7Data || [],
                            backgroundColor: 'rgba(59, 130, 246, 0.85)',
                            borderRadius: 6,
                            barThickness: 18
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        layout: { padding: { top: 4, right: 8, bottom: 0, left: 4 } },
                        plugins: { legend: { display: false } },
                        scales: {
                            x: { grid: { display: false }, ticks: { font: { family: fontFamily, size: 11 }, padding: 6 } },
                            y: { beginAtZero: true, ticks: { stepSize: 1, font: { family: fontFamily, size: 11 }, padding: 8 }, grid: { color: gridColor } }
                        }
                    }
                });
            }

            if (document.getElementById('chartRevenue6')) {
                new Chart(document.getElementById('chartRevenue6'), {
                    type: 'bar',
                    data: {
                        labels: d.revenueLabels || [],
                        datasets: [{
                            data: d.revenueData || [],
                            backgroundColor: 'rgba(239, 68, 68, 0.8)',
                            borderRadius: 6,
                            barThickness: 22
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        layout: { padding: { top: 4, right: 12, bottom: 0, left: 8 } },
                        plugins: { legend: { display: false } },
                        scales: {
                            x: { grid: { display: false }, ticks: { font: { family: fontFamily, size: 11 }, padding: 6 } },
                            y: {
                                beginAtZero: true,
                                ticks: {
                                    callback: function (v) { return '₹' + v.toLocaleString('en-IN'); },
                                    font: { family: fontFamily, size: 11 },
                                    padding: 8
                                },
                                grid: { color: gridColor }
                            }
                        }
                    }
                });
            }

            if (document.getElementById('chartStatus')) {
                var colors = ['#22c55e', '#3b82f6', '#f59e0b', '#94a3b8'];
                var total = (d.statusData || []).reduce(function (a, b) { return a + b; }, 0) || 1;
                new Chart(document.getElementById('chartStatus'), {
                    type: 'doughnut',
                    data: {
                        labels: d.statusLabels || [],
                        datasets: [{
                            data: d.statusData || [],
                            backgroundColor: colors,
                            borderWidth: 0,
                            cutout: '68%'
                        }]
                    },
                    options: {
                        responsive: true,
                        maintainAspectRatio: false,
                        plugins: { legend: { display: false } }
                    }
                });
                var leg = document.getElementById('statusLegend');
                if (leg && d.statusLabels) {
                    leg.innerHTML = d.statusLabels.map(function (lbl, i) {
                        var cnt = (d.statusCounts || [])[i] || 0;
                        var pct = Math.round((cnt / total) * 100);
                        return '<div class="adm-leg-item"><span class="adm-leg-dot" style="background:' + colors[i] + '"></span>' +
                            lbl + ' <em>' + pct + '% · ' + cnt + '</em></div>';
                    }).join('');
                }
            }
        });
    </script>
</asp:Content>
