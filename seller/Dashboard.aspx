<%@ Page Title="Dashboard - Performance Hub" Language="C#" MasterPageFile="~/seller/Seller.Master" AutoEventWireup="true" CodeFile="Dashboard.aspx.cs" Inherits="EcommerceWebsite.SellerDashboard" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <!-- Page Specific Styles or Scripts can be plugged here -->
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    
    <!-- STANDARD PAGE ACTION HEADER -->
    <div class="page-action-bar" style="margin-bottom: 24px;">
        <div class="welcome-title">
            <h1><i class="fas fa-chart-pie" style="color: var(--accent); margin-right: 8px;"></i>Merchant Dashboard</h1>
            <p>Real-time analytics, sales projections, and inventory catalogs for your commercial storefront.</p>
        </div>
        <div class="action-btn-group">
            <a href="AddEditProduct.aspx" class="add-prod-btn">
                <i class="fas fa-plus-circle" style="margin-right: 6px;"></i> Add Products
            </a>
        </div>
    </div>

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
            <div>
                <div class="stat-lbl">Total Products</div>
                <div class="stat-val"><asp:Literal ID="litTotalProducts" runat="server">0</asp:Literal></div>
                <div class="stat-desc">Registered catalog size</div>
            </div>
            <div class="stat-ico"><i class="fas fa-cube"></i></div>
        </div>

        <div class="stat-card clr-green">
            <div>
                <div class="stat-lbl">Gross Earnings</div>
                <div class="stat-val">₹<asp:Literal ID="litTotalEarnings" runat="server">0.00</asp:Literal></div>
                <div class="stat-desc">Lifetime revenue volume</div>
            </div>
            <div class="stat-ico"><i class="fas fa-indian-rupee-sign"></i></div>
        </div>

        <div class="stat-card clr-orange">
            <div>
                <div class="stat-lbl">Units Dispatched</div>
                <div class="stat-val"><asp:Literal ID="litUnitsSold" runat="server">0</asp:Literal></div>
                <div class="stat-desc">Successful deliveries</div>
            </div>
            <div class="stat-ico"><i class="fas fa-truck-fast"></i></div>
        </div>

        <div class="stat-card">
            <div>
                <div class="stat-lbl">Pending Clearances</div>
                <div class="stat-val"><asp:Literal ID="litPendingOrders" runat="server">0</asp:Literal></div>
                <div class="stat-desc">Awaiting processing</div>
            </div>
            <div class="stat-ico"><i class="fas fa-clock"></i></div>
        </div>
    </section>

    <!-- CORE WORKSPACE GRID (UPGRADED TO CATALOGUE-WRAPPER DESIGN SYSTEM) -->
    <div class="catalogue-wrapper">
        <!-- Flexible Header / Search Toolbar -->
        <div class="cat-toolbar">
            <div class="cat-heading-group">
                <h2>Recent Sale Invoices</h2>
                <span>Live logs and fulfillment registry.</span>
            </div>

            <div class="cat-actions-right">
                <!-- Status filter dropdown -->
                <div class="cat-filter-date">
                    <span>Status</span>
                    <select class="cat-select" id="ddlStatusFilter" onchange="filterWorkspaceOrders()">
                        <option value="all">All statuses</option>
                        <option value="pending">Pending</option>
                        <option value="shipped">Shipped</option>
                        <option value="delivered">Delivered</option>
                        <option value="cancelled">Cancelled</option>
                    </select>
                </div>

                <!-- Instant Search Input -->
                <div class="cat-search-box">
                    <i class="fas fa-search"></i>
                    <input type="text" class="cat-search-input" id="tblSearchInput"
                        placeholder="Search invoice, date, item..." onkeyup="filterWorkspaceOrders()" autocomplete="off" />
                </div>
            </div>
        </div>
        
        <div style="overflow-x: auto; width: 100%;">
            <asp:Repeater ID="rptRecentOrders" runat="server">
                <HeaderTemplate>
                    <table class="cat-table" id="tblWorkspaceOrders">
                        <thead>
                            <tr>
                                <th style="width: 140px;">INVOICE #</th>
                                <th>DATE</th>
                                <th>ITEM / DESCRIPTION</th>
                                <th style="width: 100px;">QTY</th>
                                <th style="width: 130px;">SUM</th>
                                <th style="width: 150px;">STATUS</th>
                            </tr>
                        </thead>
                        <tbody>
                </HeaderTemplate>
                <ItemTemplate>
                    <tr>
                        <!-- Invoice # -->
                        <td style="font-weight:700; color:var(--accent);">#INV-<%# Eval("OrderId") %></td>
                        <!-- Date -->
                        <td style="color:#64748b;"><%# Eval("CreatedAt", "{0:dd MMM yyyy}") %></td>
                        <!-- Product Name -->
                        <td style="font-weight:700; color:#334155;"><%# Eval("ProductName") %></td>
                        <!-- Quantity -->
                        <td><%# Eval("Quantity") %> Units</td>
                        <!-- Sum -->
                        <td style="font-weight:800; color:#0f172a;">₹<%# Convert.ToDecimal(Eval("UnitPrice")) * Convert.ToInt32(Eval("Quantity")) %></td>
                        <!-- Status Badge -->
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

            <!-- Client-Side Filter Empty State -->
            <div id="workspaceEmptyState" class="empty-vector" style="display:none; padding: 40px 20px;">
                <i class="fas fa-search" style="font-size: 3rem; color: #cbd5e1; margin-bottom: 15px;"></i>
                <h4 style="font-weight:700; color:#334155; margin-bottom:5px;">No Matching Records Found</h4>
                <p style="font-size:0.85rem;">Try adjusting your status filter or typing a different search query.</p>
            </div>
        </div>
    </div>

    <!-- Client-Side Live Filters JavaScript -->
    <script type="text/javascript">
        function filterWorkspaceOrders() {
            var searchInput = document.getElementById("tblSearchInput");
            var statusSelect = document.getElementById("ddlStatusFilter");
            
            if (!searchInput || !statusSelect) return;
            
            var query = searchInput.value.toLowerCase().trim();
            var statusFilter = statusSelect.value.toLowerCase().trim();
            
            var table = document.getElementById("tblWorkspaceOrders");
            if (!table) return;
            
            var tbody = table.getElementsByTagName("tbody")[0];
            if (!tbody) return;
            
            var rows = tbody.getElementsByTagName("tr");
            var visibleCount = 0;
            
            for (var i = 0; i < rows.length; i++) {
                var row = rows[i];
                
                var invoiceText = row.cells[0].textContent.toLowerCase();
                var dateText = row.cells[1].textContent.toLowerCase();
                var itemText = row.cells[2].textContent.toLowerCase();
                
                var statusBadge = row.cells[5].querySelector(".badge");
                var statusText = statusBadge ? statusBadge.textContent.toLowerCase().trim() : "";
                
                var matchesSearch = invoiceText.indexOf(query) > -1 || 
                                    dateText.indexOf(query) > -1 || 
                                    itemText.indexOf(query) > -1;
                                    
                var matchesStatus = statusFilter === "all" || statusText === statusFilter;
                
                if (matchesSearch && matchesStatus) {
                    row.style.display = "";
                    visibleCount++;
                } else {
                    row.style.display = "none";
                }
            }
            
            // Toggle empty state placeholder
            var emptyState = document.getElementById("workspaceEmptyState");
            if (emptyState) {
                emptyState.style.display = (visibleCount === 0) ? "block" : "none";
            }
        }
    </script>
</asp:Content>
