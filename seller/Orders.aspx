<%@ Page Title="Seller Orders" Language="C#" MasterPageFile="~/seller/Seller.Master" AutoEventWireup="true" CodeFile="Orders.aspx.cs" Inherits="EcommerceWebsite.SellerOrders" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

    <!-- 1. EXECUTIVE ORDERS HEADER REDESIGN -->
    <div class="page-action-bar">
        <div class="welcome-title">
            <h1 style="font-size: 1.6rem;"><i class="fas fa-receipt" style="color: var(--accent); margin-right: 8px;"></i>Orders Management</h1>
            <p>Monitor order fulfillment, manage shipment logistics, and track sales in real-time.</p>
        </div>
        <div class="ord-header-right">
            <a href="#" class="add-prod-btn" style="background: linear-gradient(135deg, #059669, #10b981); text-shadow:none; border:none;">
                <i class="fas fa-wallet"></i> View Earnings
            </a>
        </div>
    </div>

    <!-- 2. TOP METRICS KPI DECK -->
    <div class="ord-metric-row">
        <div class="ord-metric-card ord-card-blue">
            <div class="ord-metric-meta">
                <span class="ord-meta-lbl">ALL ORDERS</span>
                <div class="ord-meta-val">
                    <asp:Literal ID="litAllOrders" runat="server">0</asp:Literal>
                </div>
                <span class="ord-meta-desc">Rows in your list</span>
            </div>
            <div class="ord-metric-icon"><i class="fas fa-folder-open"></i></div>
        </div>
        
        <div class="ord-metric-card ord-card-yellow">
            <div class="ord-metric-meta">
                <span class="ord-meta-lbl">NEEDS CONFIRM</span>
                <div class="ord-meta-val">
                    <asp:Literal ID="litNeedsConfirm" runat="server">0</asp:Literal>
                </div>
                <span class="ord-meta-desc">Processing — action required</span>
            </div>
            <div class="ord-metric-icon"><i class="fas fa-clock"></i></div>
        </div>

        <div class="ord-metric-card ord-card-salmon">
            <div class="ord-metric-meta">
                <span class="ord-meta-lbl">IN TRANSIT</span>
                <div class="ord-meta-val">
                    <asp:Literal ID="litInTransit" runat="server">0</asp:Literal>
                </div>
                <span class="ord-meta-desc">Shipped / out for delivery</span>
            </div>
            <div class="ord-metric-icon"><i class="fas fa-truck"></i></div>
        </div>

        <div class="ord-metric-card ord-card-emerald">
            <div class="ord-metric-meta">
                <span class="ord-meta-lbl">DELIVERED</span>
                <div class="ord-meta-val">
                    <asp:Literal ID="litDelivered" runat="server">0</asp:Literal>
                </div>
                <span class="ord-meta-desc">Completed deliveries</span>
            </div>
            <div class="ord-metric-icon"><i class="fas fa-circle-check"></i></div>
        </div>
    </div>

    <!-- 3. RETURNS KPIs DECK -->
    <span class="ord-section-lbl">RETURNS</span>
    <div class="ord-metric-row">
        <div class="ord-metric-card ord-card-purple">
            <div class="ord-metric-meta">
                <span class="ord-meta-lbl">RETURN REQUESTS</span>
                <div class="ord-meta-val">
                    <asp:Literal ID="litReturnRequests" runat="server">0</asp:Literal>
                </div>
                <span class="ord-meta-desc">Customer returns linked to your products</span>
            </div>
            <div class="ord-metric-icon"><i class="fas fa-rotate-right"></i></div>
        </div>

        <div class="ord-metric-card ord-card-beige">
            <div class="ord-metric-meta">
                <span class="ord-meta-lbl">OPEN RETURNS</span>
                <div class="ord-meta-val">
                    <asp:Literal ID="litOpenReturns" runat="server">0</asp:Literal>
                </div>
                <span class="ord-meta-desc">None active — rejected/refunded closed</span>
            </div>
            <div class="ord-metric-icon"><i class="fas fa-reply" style="transform: scaleX(-1);"></i></div>
        </div>

        <div class="ord-metric-card ord-card-emerald">
            <div class="ord-metric-meta">
                <span class="ord-meta-lbl">RETURN COMPLETED</span>
                <div class="ord-meta-val">
                    <asp:Literal ID="litReturnCompleted" runat="server">0</asp:Literal>
                </div>
                <span class="ord-meta-desc">Refund completed and closed</span>
            </div>
            <div class="ord-metric-icon"><i class="fas fa-circle-check"></i></div>
        </div>

        <div class="ord-metric-card ord-card-red">
            <div class="ord-metric-meta">
                <span class="ord-meta-lbl">SELLER CANCELLED RETURN</span>
                <div class="ord-meta-val">
                    <asp:Literal ID="litCancelledReturn" runat="server">0</asp:Literal>
                </div>
                <span class="ord-meta-desc">Rejected by seller</span>
            </div>
            <div class="ord-metric-icon"><i class="fas fa-circle-stop"></i></div>
        </div>
    </div>

    <!-- 4. MAIN LIST WORKSPACE -->
    <div class="ord-worklist-card">
        <!-- Card Header with Controls -->
        <div class="ord-worklist-hdr">
            <div class="ord-list-title">
                <h3>Order List</h3>
                <p><asp:Literal ID="litHeaderTotal" runat="server">0 orders total.</asp:Literal></p>
            </div>
            
            <div class="ord-hdr-filters">
                <span class="ord-filter-date-lbl">Date</span>
                <asp:DropDownList ID="ddlDateFilter" runat="server" CssClass="ord-select" AutoPostBack="true" OnSelectedIndexChanged="ddlDateFilter_SelectedIndexChanged" style="cursor:pointer;">
                    <asp:ListItem Value="all" Text="All time"></asp:ListItem>
                    <asp:ListItem Value="24h" Text="Last 24 hours"></asp:ListItem>
                    <asp:ListItem Value="7d" Text="Last 7 days"></asp:ListItem>
                    <asp:ListItem Value="30d" Text="Last 30 days"></asp:ListItem>
                </asp:DropDownList>
                
                <div class="ord-search-box">
                    <i class="fas fa-search"></i>
                    <input type="text" id="txtOrderQuery" onkeyup="performInstantFilter()" class="ord-input-search" placeholder="Search ref, customer, email, status, payment..." />
                </div>
                
                <label class="ord-auto-box" for="chkAutoRefresh">
                    <input type="checkbox" id="chkAutoRefresh" style="accent-color:#6366f1; cursor:pointer;" onchange="toggleAutoRefresh()" />
                    <span>Auto (5s)</span>
                </label>
                
                <button type="button" class="ord-refresh-btn" onclick="window.location.reload();">Refresh</button>
            </div>
        </div>

        <!-- Card Body with Interactive Table -->
        <div class="ord-table-wrap">
            <asp:Repeater ID="rptOrders" runat="server">
                <HeaderTemplate>
                    <table class="ord-table" id="dtMainOrders">
                        <thead>
                            <tr>
                                <th>ORDER</th>
                                <th>CUSTOMER</th>
                                <th>CATEGORY</th>
                                <th>STATUS</th>
                                <th>TOTAL</th>
                                <th>PAYMENT TYPE</th>
                                <th>ORDERED AT</th>
                                <th>ACTIONS</th>
                            </tr>
                        </thead>
                        <tbody>
                </HeaderTemplate>
                <ItemTemplate>
                    <tr class="ord-row" data-filter-node='<%# Eval("OrderRef") %> <%# Eval("CustName") %> <%# Eval("CustEmail") %> <%# Eval("Status") %> <%# Eval("PaymentMode") %>'>
                        <td>
                            <div class="ord-cell-ref">
                                <span class="ord-ref-text"><%# Eval("OrderRef") %></span>
                                <span class="ord-id-badge">#<%# Eval("Id") %></span>
                            </div>
                        </td>
                        <td>
                            <div class="ord-cell-cust">
                                <span class="ord-cust-name"><%# Eval("CustName") %></span>
                                <span class="ord-cust-email"><%# Eval("CustEmail") %></span>
                            </div>
                        </td>
                        <td>
                            <span class="ord-pill-cat"><%# Eval("TopCategory") %></span>
                        </td>
                        <td>
                            <%# GetOrderBadgeRedesign(Eval("Status")) %>
                        </td>
                        <td>
                            <span class="ord-total-val">₹<%# Convert.ToDecimal(Eval("SellerTotalAmount")).ToString("N0") %></span>
                        </td>
                        <td>
                            <div class="ord-pay-box">
                                <span class="ord-pay-type"><%# Eval("PaymentMode") %></span>
                                <%# GetPaymentStatusBadge(Eval("Status")) %>
                            </div>
                        </td>
                        <td>
                            <div class="ord-cell-time">
                                <span class="ord-time-abs"><%# Convert.ToDateTime(Eval("CreatedAt")).ToString("MMM dd, yyyy - h:mm tt") %></span>
                                <span class="ord-time-rel"><%# GetRelativeTime(Eval("CreatedAt")) %></span>
                            </div>
                        </td>
                        <td>
                            <div class="ord-action-btns">
                                <asp:LinkButton ID="btnQuickConfirm" runat="server" CssClass="ord-act-btn ord-act-confirm" 
                                    CommandName="ConfirmOrder" CommandArgument='<%# Eval("Id") %>' OnCommand="btnQuickConfirm_Command" 
                                    Visible='<%# IsConfirmButtonVisible(Eval("Status")) %>' title="Confirm Order Delivery Processing">
                                    <i class="fas fa-check"></i>
                                </asp:LinkButton>

                                <asp:HyperLink ID="lnkReturnWorkflow" runat="server" NavigateUrl='<%# "ViewOrder.aspx?id=" + Eval("Id") %>' 
                                    CssClass="ord-act-btn ord-act-revert" style="background:#fdf2f8; border-color:#fbcfe8; color:#db2777;"
                                    Visible='<%# IsReturnButtonVisible(Eval("Status")) %>' title="Inspect Return Lifecycle Workflow">
                                    <i class="fas fa-reply" style="transform: scaleX(-1);"></i>
                                </asp:HyperLink>

                                <a href='ViewOrder.aspx?id=<%# Eval("Id") %>' class="ord-act-btn ord-act-view" title="Inspect Order Details & Full Manifest">
                                    <i class="fas fa-eye"></i>
                                </a>
                            </div>
                        </td>
                    </tr>
                </ItemTemplate>
                <FooterTemplate>
                        </tbody>
                    </table>
                </FooterTemplate>
            </asp:Repeater>

            <!-- Empty / Zero-Records Canvas -->
            <div id="divFilterFallback" style="display:none; text-align:center; padding:50px 20px;">
                <i class="fas fa-magnifying-glass-minus" style="font-size:3rem; color:#cbd5e1; margin-bottom:12px;"></i>
                <h4 style="font-weight:800; color:#475569; margin-bottom:4px;">No Matching Records</h4>
                <p style="font-size:0.82rem; color:#94a3b8;">Modify search keywords to query from current dataset view.</p>
            </div>

            <asp:PlaceHolder ID="phEmptyOrders" runat="server" Visible="false">
                <div style="text-align:center; padding:70px 20px;">
                    <i class="fas fa-inbox" style="font-size:4rem; color:#e2e8f0; margin-bottom:15px;"></i>
                    <h3 style="font-weight:800; color:#1e293b; margin-bottom:6px;">Zero Sales Generated</h3>
                    <p style="font-size:0.88rem; color:#64748b; max-width:400px; margin:0 auto;">Products must be ordered by customers to render sales manifests inside your Executive Workspace.</p>
                </div>
            </asp:PlaceHolder>
        </div>

        <!-- 5. FOOTER PAGINATION BLOCK -->
        <div class="ord-footer">
            <div class="ord-footer-left">
                Showing 1-<asp:Literal ID="litFooterCount" runat="server">0</asp:Literal> of <strong><asp:Literal ID="litFooterCount2" runat="server">0</asp:Literal></strong>
            </div>
            <div class="ord-footer-right">
                <span>Per page</span>
                <select class="ord-select" style="padding: 4px 8px; min-width:60px; margin: 0 10px;">
                    <option>25</option>
                </select>
                <span>Page 1 of 1</span>
            </div>
        </div>
    </div>

    <!-- Client Side Execution Engine -->
    <script type="text/javascript">
        function performInstantFilter() {
            var inp = document.getElementById('txtOrderQuery');
            var q = inp.value.trim().toLowerCase();
            
            // Save query to maintain UX state during 5s refreshes
            sessionStorage.setItem('seller_orders_searchquery', inp.value.trim());
            
            var tbl = document.getElementById('dtMainOrders');
            if (!tbl) return;

            var rws = tbl.querySelectorAll('.ord-row');
            var match = 0;

            rws.forEach(function(rw) {
                var token = rw.getAttribute('data-filter-node').toLowerCase();
                if (token.indexOf(q) > -1) {
                    rw.style.display = '';
                    match++;
                } else {
                    rw.style.display = 'none';
                }
            });

            var fb = document.getElementById('divFilterFallback');
            if (fb) {
                fb.style.display = (match === 0 && rws.length > 0) ? 'block' : 'none';
            }
        }

        // AUTO-REFRESH EXECUTION ENGINE
        var refreshTimer = null;

        function initAutoRefresh() {
            var chk = document.getElementById('chkAutoRefresh');
            if (!chk) return;

            // Default checkbox to checked unless explicitly set to false in localStorage
            var pref = localStorage.getItem('seller_orders_autorefresh');
            chk.checked = (pref !== 'false');

            if (chk.checked) {
                startTimer();
            }

            // Restore user's typed search text to avoid loss of UX focus on reload
            var savedQ = sessionStorage.getItem('seller_orders_searchquery');
            if (savedQ) {
                var inp = document.getElementById('txtOrderQuery');
                if (inp) {
                    inp.value = savedQ;
                    performInstantFilter();
                    // Retain focus and cursor position at the end of query
                    inp.focus();
                    inp.setSelectionRange(inp.value.length, inp.value.length);
                }
            }
        }

        function toggleAutoRefresh() {
            var chk = document.getElementById('chkAutoRefresh');
            localStorage.setItem('seller_orders_autorefresh', chk.checked ? 'true' : 'false');
            
            if (chk.checked) {
                startTimer();
            } else {
                stopTimer();
            }
        }

        function startTimer() {
            stopTimer();
            refreshTimer = setTimeout(function() {
                window.location.reload();
            }, 5000); // 5-second execution loop
        }

        function stopTimer() {
            if (refreshTimer) {
                clearTimeout(refreshTimer);
                refreshTimer = null;
            }
        }

        // Boot system engine on DOM stability
        window.addEventListener('DOMContentLoaded', initAutoRefresh);
    </script>

</asp:Content>
