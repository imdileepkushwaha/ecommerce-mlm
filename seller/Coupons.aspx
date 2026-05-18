<%@ Page Title="Manage Promo Coupons" Language="C#" MasterPageFile="~/seller/Seller.Master" AutoEventWireup="true"
    CodeFile="Coupons.aspx.cs" Inherits="EcommerceWebsite.SellerCoupons" %>

    <asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

        <!-- SCRIPTS MANAGER -->
        <asp:ScriptManager ID="smCoupons" runat="server"></asp:ScriptManager>

        <!-- ACTION BAR TOP -->
        <div class="page-action-bar">
            <div class="welcome-title">
                <h1><i class="fas fa-ticket-alt" style="color: var(--accent); margin-right: 8px;"></i>Store Coupons</h1>
                <p>Generate, monitor, and manage discount codes to incentivize catalog orders and brand growth.</p>
            </div>
            <div>
                <asp:LinkButton ID="btnCreateCoupon" runat="server" CssClass="add-prod-btn" OnClick="btnCreateCoupon_Click" CausesValidation="false"
                    OnClientClick="sessionStorage.removeItem('seller_coupons_searchquery');">
                    <i class="fas fa-plus"></i> New Coupon
                </asp:LinkButton>
            </div>
        </div>

        <!-- GLOBAL SYSTEM ALERTS -->
        <asp:UpdatePanel ID="upnlMsg" runat="server" UpdateMode="Conditional">
            <ContentTemplate>
                <asp:Label ID="lblGlobalMsg" runat="server" Visible="false"
                    style="display:block; padding:16px 24px; border-radius:12px; margin-bottom:25px; font-size:0.9rem; font-weight:600;">
                </asp:Label>
            </ContentTemplate>
        </asp:UpdatePanel>

        <!-- MAIN PANEL WITH GRID AND FILTERS -->
        <asp:UpdatePanel ID="upnlWorkspace" runat="server" UpdateMode="Always">
            <ContentTemplate>

                <!-- 1. SUMMARY STATS BOARD -->
                <div class="dashboard-stat-row">
                    <!-- Card 1: Total Coupons -->
                    <div class="d-card d-card-1">
                        <div class="d-meta">
                            <span class="d-title">TOTAL CREATED</span>
                            <span class="d-count">
                                <asp:Literal ID="litTotalCoupons" runat="server">0</asp:Literal>
                            </span>
                            <span class="d-desc">Lifetime coupon codes</span>
                        </div>
                        <div class="d-icon-circle rv-ico-intake"><i class="fas fa-tags"></i></div>
                    </div>

                    <!-- Card 2: Active Promos -->
                    <div class="d-card d-card-2">
                        <div class="d-meta">
                            <span class="d-title">ACTIVE PROMOS</span>
                            <span class="d-count" style="color: #10b981;">
                                <asp:Literal ID="litActiveCoupons" runat="server">0</asp:Literal>
                            </span>
                            <span class="d-desc">Redeemable by shoppers</span>
                        </div>
                        <div class="d-icon-circle rv-ico-approved"><i class="fas fa-circle-check"></i></div>
                    </div>

                    <!-- Card 3: Coupon redemptions -->
                    <div class="d-card d-card-3">
                        <div class="d-meta">
                            <span class="d-title">TOTAL REDEMPTIONS</span>
                            <span class="d-count" style="color: #3b82f6;">
                                <asp:Literal ID="litTotalRedeemed" runat="server">0</asp:Literal>
                            </span>
                            <span class="d-desc">Customer redemptions</span>
                        </div>
                        <div class="d-icon-circle rv-ico-score" style="background:#eff6ff; color:#3b82f6;"><i class="fas fa-shopping-bag"></i></div>
                    </div>
                </div>

                <!-- 2. COUPONS DATA LOG -->
                <div class="prod-card">
                    <!-- Header with quick filter search -->
                    <div class="ord-worklist-hdr">
                        <div class="ord-list-title">
                            <h3>Active Promotional Codes</h3>
                            <p>Manage discounts, validate limits, and monitor customer redemptions</p>
                        </div>
                        <div class="ord-hdr-filters">
                            <div class="ord-search-box">
                                <i class="fas fa-search"></i>
                                <input type="text" id="txtCouponQuery" onkeyup="performCouponSearch()"
                                    class="ord-input-search" placeholder="Search code, discount, type, status..."
                                    autocomplete="off" />
                            </div>
                        </div>
                    </div>

                    <div class="prod-table-wrap">
                        <asp:Repeater ID="rptCoupons" runat="server" OnItemCommand="rptCoupons_ItemCommand">
                            <HeaderTemplate>
                                <table class="prod-table">
                                    <thead>
                                        <tr>
                                            <th>Coupon Code</th>
                                            <th>Type & Discount</th>
                                            <th>Minimum Spend</th>
                                            <th>Usage Stats</th>
                                            <th>Validity Period</th>
                                            <th>Status</th>
                                            <th style="text-align: center;">Actions</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                            </HeaderTemplate>
                            <ItemTemplate>
                                <tr class="cp-row"
                                    data-filter-node='<%# Eval("CouponCode") %> <%# Eval("DiscountType") %> <%# Eval("IsActive") %>'>
                                    <td>
                                        <div style="display:flex; align-items:center; gap:8px;">
                                            <div style="background: rgba(139, 92, 246, 0.08); color: #8b5cf6; padding: 6px 12px; border-radius: 8px; font-weight: 800; font-family: monospace; font-size: 0.95rem; letter-spacing: 0.5px; border: 1px dashed rgba(139, 92, 246, 0.3);">
                                                <%# Eval("CouponCode") %>
                                            </div>
                                        </div>
                                    </td>
                                    <td>
                                        <strong style="color: #334155; font-weight: 700;">
                                            <%# Eval("DiscountType").ToString() == "Percentage" 
                                                ? Eval("DiscountValue") + "% Off" 
                                                : "₹" + Eval("DiscountValue") + " Off" %>
                                        </strong>
                                        <span style="display:block; font-size:0.7rem; color:#888888;">
                                            <%# Eval("DiscountType") %> discount
                                        </span>
                                    </td>
                                    <td>
                                        <span style="font-weight:600; color:#475569;">
                                            ₹<%# Eval("MinOrderAmount") %>
                                        </span>
                                    </td>
                                    <td>
                                        <div style="width: 100px;">
                                            <div style="display:flex; justify-content:space-between; font-size:0.7rem; color:#64748b; margin-bottom:3px;">
                                                <span>Redeemed</span>
                                                <strong><%# Eval("UsedCount") %>/<%# Eval("UsageLimit") %></strong>
                                            </div>
                                            <div style="width:100%; height:6px; background:#e2e8f0; border-radius:3px; overflow:hidden;">
                                                <div style='height:100%; background:#8b5cf6; width: <%# GetUsagePercent(Eval("UsedCount"), Eval("UsageLimit")) %>%;'></div>
                                            </div>
                                        </div>
                                    </td>
                                    <td>
                                        <div style="font-size:0.78rem; color:#334155;">
                                            <i class="far fa-calendar-check" style="color:#10b981; margin-right:4px;"></i>
                                            <%# FormatCouponDate(Eval("StartDate")) %>
                                        </div>
                                        <div style="font-size:0.75rem; color:#ef4444; margin-top:2px;">
                                            <i class="far fa-calendar-times" style="margin-right:4px;"></i>
                                            <%# FormatCouponDate(Eval("EndDate")) %>
                                        </div>
                                    </td>
                                    <td>
                                        <%# GetStatusBadge(Eval("IsActive"), Eval("EndDate")) %>
                                    </td>
                                    <td>
                                        <div class="action-btn-grp" style="justify-content: center; gap: 8px;">
                                            <asp:LinkButton ID="btnEdit" runat="server" CommandName="EditCoupon"
                                                CommandArgument='<%# Eval("Id") %>' CssClass="action-ico rv-btn-approve" ToolTip="Edit Coupon Parameters"
                                                style="color: #3b82f6; background: rgba(59, 130, 246, 0.08);">
                                                <i class="fas fa-edit"></i>
                                            </asp:LinkButton>
                                            
                                            <asp:LinkButton ID="btnToggle" runat="server" CommandName="ToggleCoupon"
                                                CommandArgument='<%# Eval("Id") %>' CssClass="action-ico" ToolTip="Toggle Status"
                                                OnClientClick="sessionStorage.removeItem('seller_coupons_searchquery');"
                                                style='<%# IsCouponActive(Eval("IsActive")) ? "color:#f59e0b; background:rgba(245,158,11,0.08);" : "color:#10b981; background:rgba(16,185,129,0.08);" %>'>
                                                <i class='<%# IsCouponActive(Eval("IsActive")) ? "fas fa-eye-slash" : "fas fa-eye" %>'></i>
                                            </asp:LinkButton>

                                            <asp:LinkButton ID="btnDelete" runat="server" CommandName="DeleteCoupon"
                                                CommandArgument='<%# Eval("Id") %>' CssClass="action-ico rv-btn-reject" ToolTip="Permanently Delete"
                                                OnClientClick="sessionStorage.removeItem('seller_coupons_searchquery'); return confirm('⚠️ Are you sure you want to permanently delete this coupon? This action cannot be undone.');">
                                                <i class="fas fa-trash-alt"></i>
                                            </asp:LinkButton>
                                        </div>
                                    </td>
                                </tr>
                            </ItemTemplate>
                            <FooterTemplate>
                                </tbody>
                                </table>
                            </FooterTemplate>
                        </asp:Repeater>

                        <!-- Fallback zero-records alert -->
                        <div id="divCouponFallback" class="ord-fallback-div" style="display:none; padding:40px 20px;">
                            <i class="fas fa-ticket-alt ord-fallback-i" style="color: #cbd5e1;"></i>
                            <h4 class="ord-fallback-h4">No Matching Coupons</h4>
                            <p class="ord-fallback-p">No coupons matches your search parameters in the catalog log.</p>
                        </div>

                        <!-- EMPTY RUN STATE -->
                        <asp:PlaceHolder ID="phEmptyState" runat="server" Visible="false">
                            <div class="coupon-empty-container">
                                <div class="coupon-empty-icon-wrapper">
                                    <i class="fas fa-ticket-alt"></i>
                                </div>
                                <h4 class="coupon-empty-title">No Active Coupons Found</h4>
                                <p class="coupon-empty-desc">You haven't generated any discount codes yet. Create promotional coupons to reward loyal shoppers and drive massive sales volumes.</p>
                                <div>
                                    <asp:LinkButton ID="btnEmptyCreate" runat="server" CssClass="coupon-empty-btn" OnClick="btnCreateCoupon_Click" CausesValidation="false">
                                        <i class="fas fa-plus"></i> Create Store Coupon
                                    </asp:LinkButton>
                                </div>
                            </div>
                        </asp:PlaceHolder>
                    </div>
                </div>

            </ContentTemplate>
        </asp:UpdatePanel>

        <!-- =======================================================================
        DYNAMIC MODALS DECK (CREATE / EDIT SYSTEM FORM PANEL)
        ======================================================================== -->
        <asp:UpdatePanel ID="upnlModal" runat="server" UpdateMode="Conditional">
            <ContentTemplate>
                <asp:Panel ID="pnlCouponModal" runat="server" Visible="false" CssClass="modal-overlay">
                    <div class="coupon-modal-card">
                        <div class="coupon-modal-header">
                            <h3 class="coupon-modal-title">
                                <i class="fas fa-ticket-alt"></i>
                                <asp:Literal ID="litModalTitle" runat="server">Create Store Coupon</asp:Literal>
                            </h3>
                            <asp:LinkButton ID="btnCloseModal" runat="server" CssClass="coupon-modal-close-btn"
                                OnClick="btnCloseModal_Click" CausesValidation="false">
                                <i class="fas fa-xmark"></i>
                            </asp:LinkButton>
                        </div>
                        
                        <!-- Inline Validation Message inside modal -->
                        <asp:Label ID="lblModalError" runat="server" Visible="false"
                            style="display:block; padding:12px 16px; background:#fef2f2; border-left:4px solid #ef4444; color:#991b1b; font-size:0.8rem; font-weight:700; border-radius:10px; margin: 15px 15px 0 15px;">
                        </asp:Label>

                        <div class="coupon-modal-body">
                            <!-- Coupon Code -->
                            <div class="coupon-form-group">
                                <label class="coupon-form-label"><i class="fas fa-barcode"></i> Coupon Code <span style="color:#ef4444; margin-left:2px;">*</span></label>
                                <asp:TextBox ID="txtCouponCode" runat="server" CssClass="coupon-form-input" 
                                    placeholder="e.g. SAVE20" MaxLength="50" style="text-transform:uppercase; font-weight:800; font-family:monospace; letter-spacing:1px;"></asp:TextBox>
                                <span class="coupon-input-desc">
                                    Coupons are unique marketplace-wide. Duplicate codes registered by other sellers are blocked.
                                </span>
                            </div>

                            <!-- Discount Grid (Type & Value) -->
                            <div class="coupon-grid-2">
                                <div class="coupon-form-group">
                                    <label class="coupon-form-label"><i class="fas fa-calculator"></i> Discount Type</label>
                                    <asp:DropDownList ID="ddlDiscountType" runat="server" CssClass="coupon-form-input" style="font-family: inherit; font-weight: 700;">
                                        <asp:ListItem Value="Percentage">Percentage (%)</asp:ListItem>
                                        <asp:ListItem Value="FixedAmount">Fixed Amount (₹)</asp:ListItem>
                                    </asp:DropDownList>
                                </div>
                                <div class="coupon-form-group">
                                    <label class="coupon-form-label"><i class="fas fa-tags"></i> Discount Value <span style="color:#ef4444; margin-left:2px;">*</span></label>
                                    <asp:TextBox ID="txtDiscountValue" runat="server" CssClass="coupon-form-input" placeholder="e.g. 15.00"></asp:TextBox>
                                </div>
                            </div>

                            <!-- Order thresholds (Min spend & Max cap) -->
                            <div class="coupon-grid-2">
                                <div class="coupon-form-group">
                                    <label class="coupon-form-label"><i class="fas fa-bag-shopping"></i> Minimum Purchase</label>
                                    <asp:TextBox ID="txtMinOrderAmount" runat="server" CssClass="coupon-form-input" placeholder="e.g. 499.00"></asp:TextBox>
                                </div>
                                <div class="coupon-form-group">
                                    <label class="coupon-form-label"><i class="fas fa-shield"></i> Max Discount Cap</label>
                                    <asp:TextBox ID="txtMaxDiscountAmount" runat="server" CssClass="coupon-form-input" placeholder="e.g. 150.00 (Optional)"></asp:TextBox>
                                </div>
                            </div>

                            <!-- Validity Period (Start & End Dates) -->
                            <div class="coupon-grid-2">
                                <div class="coupon-form-group">
                                    <label class="coupon-form-label"><i class="fas fa-calendar-days"></i> Launch Date <span style="color:#ef4444; margin-left:2px;">*</span></label>
                                    <asp:TextBox ID="txtStartDate" runat="server" CssClass="coupon-form-input" TextMode="Date" style="font-family: inherit;"></asp:TextBox>
                                </div>
                                <div class="coupon-form-group">
                                    <label class="coupon-form-label"><i class="fas fa-calendar-xmark"></i> Expiry Date <span style="color:#ef4444; margin-left:2px;">*</span></label>
                                    <asp:TextBox ID="txtEndDate" runat="server" CssClass="coupon-form-input" TextMode="Date" style="font-family: inherit;"></asp:TextBox>
                                </div>
                            </div>

                            <!-- Usage count limit & status -->
                            <div class="coupon-grid-2" style="align-items: center;">
                                <div class="coupon-form-group">
                                    <label class="coupon-form-label"><i class="fas fa-users-line"></i> Redemption Limit</label>
                                    <asp:TextBox ID="txtUsageLimit" runat="server" CssClass="coupon-form-input" placeholder="e.g. 100" TextMode="Number"></asp:TextBox>
                                </div>
                                <div class="coupon-form-group" style="padding-top: 20px;">
                                    <div class="coupon-checkbox-wrapper" onclick="if (event.target.tagName !== 'INPUT') { document.getElementById('<%= chkIsActive.ClientID %>').click(); }">
                                        <asp:CheckBox ID="chkIsActive" runat="server" Checked="true" style="transform: scale(1.2); cursor:pointer;" />
                                        <span style="font-size:0.82rem; font-weight:800; color:inherit; user-select:none; cursor:pointer;">Set Active Status</span>
                                    </div>
                                </div>
                            </div>

                            <asp:HiddenField ID="hfCouponId" runat="server" />

                            <!-- Submit Buttons -->
                            <div>
                                <asp:Button ID="btnSaveCoupon" runat="server" Text="Publish Promo Code"
                                    CssClass="coupon-submit-btn" OnClick="btnSaveCoupon_Click" />
                            </div>
                        </div>
                    </div>
                </asp:Panel>
            </ContentTemplate>
        </asp:UpdatePanel>

        <!-- Client Side Search Execution Engine -->
        <script type="text/javascript">
            function performCouponSearch() {
                var inp = document.getElementById('txtCouponQuery');
                if (!inp) return;
                var q = inp.value.trim().toLowerCase();

                // Save search query state in session
                sessionStorage.setItem('seller_coupons_searchquery', inp.value.trim());

                var tbl = document.querySelector('.prod-table');
                if (!tbl) return;

                var rws = tbl.querySelectorAll('.cp-row');
                var match = 0;

                rws.forEach(function (rw) {
                    var token = rw.getAttribute('data-filter-node').toLowerCase();
                    if (token.indexOf(q) > -1) {
                        rw.style.display = '';
                        match++;
                    } else {
                        rw.style.display = 'none';
                    }
                });

                var fb = document.getElementById('divCouponFallback');
                if (fb) {
                    fb.style.display = (match === 0 && rws.length > 0) ? 'block' : 'none';
                }
            }

            function restoreCouponSearch() {
                var savedQ = sessionStorage.getItem('seller_coupons_searchquery');
                if (savedQ) {
                    var inp = document.getElementById('txtCouponQuery');
                    if (inp) {
                        inp.value = savedQ;
                        performCouponSearch();

                        if (document.activeElement !== inp && savedQ.length > 0) {
                            inp.focus();
                            inp.setSelectionRange(inp.value.length, inp.value.length);
                        }
                    }
                }
            }

            window.addEventListener('DOMContentLoaded', restoreCouponSearch);

            if (typeof Sys !== 'undefined' && Sys.WebForms && Sys.WebForms.PageRequestManager) {
                Sys.WebForms.PageRequestManager.getInstance().add_endRequest(restoreCouponSearch);
            }
        </script>

    </asp:Content>
