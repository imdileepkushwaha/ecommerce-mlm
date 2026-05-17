<%@ Page Title="Merchant Earnings" Language="C#" MasterPageFile="~/seller/Seller.Master" AutoEventWireup="true"
    CodeFile="earnings.aspx.cs" Inherits="EcommerceWebsite.SellerEarnings" %>

    <asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

        <!-- SCRIPTA MANAGER -->
        <asp:ScriptManager ID="smEarnings" runat="server"></asp:ScriptManager>

        <!-- MAIN UPDATABLE VIEWPORT -->
        <asp:UpdatePanel ID="upnlEarnings" runat="server" UpdateMode="Conditional">
            <ContentTemplate>

                <!-- TOP BAR ROW -->
                <div class="page-action-bar earn-header">
                    <div class="welcome-title earn-welcome-title">
                        <h1><i class="fas fa-wallet"></i>Earnings</h1>
                        <p>Monitor credited balances, track withdrawable funds, and request payout settlements
                            instantly.</p>
                    </div>
                    <div class="action-btn-grp earn-action-btn-grp">
                        <a href="transactions.aspx" class="btn-action earn-nav-btn"><i class="fas fa-list-ul"></i>
                            Transactions</a>
                        <asp:LinkButton ID="btnOpenWithdraw" runat="server" CssClass="btn-action earn-w-btn"
                            OnClick="btnOpenWithdraw_Click"><i class="fas fa-hand-holding-dollar"></i> Withdraw
                        </asp:LinkButton>
                    </div>
                </div>

                <!-- DYNAMIC GLOBAL ALERT SYSTEM -->
                <asp:Label ID="lblMsg" runat="server" Visible="false" CssClass="earn-global-alert"></asp:Label>

                <!-- 1. DYNAMIC METRICS SIX-CARD ROW -->
                <div class="dashboard-stat-row earn-stat-row">
                    <!-- Card 1: Delivered Credited -->
                    <div class="d-card d-card-3">
                        <div class="d-meta">
                            <span class="d-title">DELIVERED (CREDITED)</span>
                            <span class="d-count">₹<asp:Literal ID="litDeliveredCredited" runat="server">0</asp:Literal>
                            </span>
                            <span class="d-desc">Line items jab order delivered ho</span>
                        </div>
                        <div class="d-icon-circle rv-ico-approved"><i class="fas fa-dollar-sign"></i></div>
                    </div>

                    <!-- Card 2: Seller Profit -->
                    <div class="d-card d-card-3">
                        <div class="d-meta">
                            <span class="d-title">SELLER PROFIT</span>
                            <span class="d-count">₹<asp:Literal ID="litSellerProfit" runat="server">0</asp:Literal>
                            </span>
                            <span class="d-desc">Paid out + current withdrawable</span>
                        </div>
                        <div class="d-icon-circle rv-ico-approved"><i class="fas fa-chart-line"></i></div>
                    </div>

                    <!-- Card 3: Withdrawable -->
                    <div class="d-card d-card-2">
                        <div class="d-meta">
                            <span class="d-title">WITHDRAWABLE</span>
                            <span class="d-count">₹<asp:Literal ID="litWithdrawable" runat="server">0</asp:Literal>
                            </span>
                            <span class="d-desc">Abhi payout request kar sakte ho</span>
                        </div>
                        <div class="d-icon-circle rv-ico-intake"><i class="fas fa-arrows-up-down"></i></div>
                    </div>

                    <!-- Card 4: Pending Withdraw -->
                    <div class="d-card d-card-1">
                        <div class="d-meta">
                            <span class="d-title">PENDING WITHDRAW</span>
                            <span class="d-count">₹<asp:Literal ID="litPendingWithdraw" runat="server">0</asp:Literal>
                            </span>
                            <span class="d-desc">Admin review — balance se hold</span>
                        </div>
                        <div class="d-icon-circle rv-ico-pending"><i class="fas fa-clock"></i></div>
                    </div>

                    <!-- Card 5: Paid Out -->
                    <div class="d-card d-card-3">
                        <div class="d-meta">
                            <span class="d-title">PAID OUT</span>
                            <span class="d-count">₹<asp:Literal ID="litPaidOut" runat="server">0</asp:Literal></span>
                            <span class="d-desc">Approved / paid withdrawals</span>
                        </div>
                        <div class="d-icon-circle rv-ico-approved"><i class="fas fa-check-double"></i></div>
                    </div>

                    <!-- Card 6: Pipeline -->
                    <div class="d-card d-card-4">
                        <div class="d-meta">
                            <span class="d-title">PIPELINE</span>
                            <span class="d-count">₹<asp:Literal ID="litPipeline" runat="server">0</asp:Literal></span>
                            <span class="d-desc">Processing + shipped (estimate)</span>
                        </div>
                        <div class="d-icon-circle rv-ico-score"><i class="fas fa-chart-bar"></i></div>
                    </div>
                </div>

                <!-- 2. DELIVERED ORDERS PANEL -->
                <div class="prod-card earn-panel">
                    <div class="earn-table-header-box">
                        <div class="earn-header-flex">
                            <div class="earn-title-group">
                                <h3>Delivered Orders <span class="earn-table-badge badge-delivered">
                                        <asp:Literal ID="litDeliveredBadgeCount" runat="server">0</asp:Literal> orders
                                    </span></h3>
                                <p>Aapke products wale line items ka total jab order <strong>delivered</strong> ho chuka
                                    ho. Poori history ke liye Transactions dekho.</p>
                            </div>
                            <div class="earn-search-wrap">
                                <i class="fas fa-search search-icon"></i>
                                <asp:TextBox ID="txtSearchOrders" runat="server" CssClass="earn-search-input"
                                    Placeholder="Search ref, order id, amount, date..." onkeyup="performOrderSearch()"
                                    autocomplete="off"></asp:TextBox>
                            </div>
                        </div>
                    </div>

                    <div class="prod-table-wrap">
                        <asp:Repeater ID="rptDeliveredOrders" runat="server">
                            <HeaderTemplate>
                                <table class="prod-table earn-table" id="dtDeliveredOrders">
                                    <thead>
                                        <tr>
                                            <th>DELIVERED</th>
                                            <th>ORDER</th>
                                            <th class="earn-center-align">QTY</th>
                                            <th>EARNINGS</th>
                                            <th class="earn-center-align">ACTION</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                            </HeaderTemplate>
                            <ItemTemplate>
                                <tr class="earn-order-row"
                                    data-filter-node='<%# Convert.ToDateTime(Eval("CreatedAt")).ToString("MMM dd, yyyy · hh:mm tt") %> <%# Eval("OrderRef") %> <%# Eval("Id") %> <%# Eval("SellerItemCount") %> <%# Convert.ToDecimal(Eval("SellerTotalAmount")).ToString("N0") %>'>
                                    <td>
                                        <%# Convert.ToDateTime(Eval("CreatedAt")).ToString("MMM dd, yyyy · hh:mm tt") %>
                                    </td>
                                    <td>
                                        <strong class="earn-bold-text">
                                            <%# Eval("OrderRef") %>
                                        </strong>
                                        <span class="earn-ref-id">#<%# Eval("Id") %></span>
                                    </td>
                                    <td class="earn-center-cell">
                                        <%# Eval("SellerItemCount") %>
                                    </td>
                                    <td><strong class="earn-success-amount">+₹<%#
                                                Convert.ToDecimal(Eval("SellerTotalAmount")).ToString("N0") %></strong>
                                    </td>
                                    <td class="earn-center-align">
                                        <a href='ViewOrder.aspx?id=<%# Eval("Id") %>' class="action-ico earn-btn-eye"
                                            title="View Details"><svg xmlns="http://www.w3.org/2000/svg" width="1.1em"
                                                height="1.1em" viewBox="0 0 24 24">
                                                <g fill="none" stroke="currentColor" stroke-width="1.5">
                                                    <path stroke-linecap="round"
                                                        d="M9 4.46A9.8 9.8 0 0 1 12 4c4.182 0 7.028 2.5 8.725 4.704C21.575 9.81 22 10.361 22 12c0 1.64-.425 2.191-1.275 3.296C19.028 17.5 16.182 20 12 20s-7.028-2.5-8.725-4.704C2.425 14.192 2 13.639 2 12c0-1.64.425-2.191 1.275-3.296A14.5 14.5 0 0 1 5 6.821">
                                                    </path>
                                                    <path d="M15 12a3 3 0 1 1-6 0a3 3 0 0 1 6 0Z"></path>
                                                </g>
                                            </svg></a>
                                    </td>
                                </tr>
                            </ItemTemplate>
                            <FooterTemplate>
                                </tbody>
                                </table>
                            </FooterTemplate>
                        </asp:Repeater>

                        <!-- Fallback zero-records alert for orders -->
                        <div id="divOrderFallback" class="ord-fallback-div" style="display:none; padding:40px 20px;">
                            <i class="fas fa-magnifying-glass-minus ord-fallback-i"></i>
                            <h4 class="ord-fallback-h4">No Matching Orders</h4>
                            <p class="ord-fallback-p">Modify search keywords to query from current dataset view.</p>
                        </div>

                        <!-- Empty orders placeholder -->
                        <asp:PlaceHolder ID="phEmptyOrders" runat="server" Visible="false">
                            <div class="earn-empty-placeholder">
                                <div class="icon"><i class="fas fa-box-open"></i></div>
                                <h4>No Delivered Orders Found</h4>
                                <p>Delivered orders will display here once customers receive their items.</p>
                            </div>
                        </asp:PlaceHolder>
                    </div>

                    <!-- Footer Pagination Information -->
                    <div class="earn-pagination-footer">
                        <div class="earn-pagination-text">
                            Showing <strong class="earn-pagination-text-strong">
                                <asp:Literal ID="litPaginationRange" runat="server">1-6</asp:Literal>
                            </strong> of <strong class="earn-pagination-text-strong">
                                <asp:Literal ID="litPaginationTotal" runat="server">6</asp:Literal>
                            </strong>
                        </div>
                        <div class="earn-pagination-actions">
                            <span class="earn-pagination-select-span">Per page
                                <select class="earn-pagination-select">
                                    <option value="25" selected>25</option>
                                </select>
                            </span>
                            <span class="earn-pagination-text">Page 1 of 1</span>
                        </div>
                    </div>
                </div>

                <!-- 3. WITHDRAW REQUESTS PANEL -->
                <div class="prod-card earn-panel earn-panel-withdraw">
                    <div class="earn-table-header-box">
                        <div class="earn-header-flex">
                            <div class="earn-title-group">
                                <h3>Withdraw Requests <span class="earn-table-badge earn-badge-red">
                                        <asp:Literal ID="litWithdrawRequestsBadge" runat="server">0</asp:Literal> total
                                    </span></h3>
                                <p>OTP flow aur nayi request ke liye Withdraw requests page kholo.</p>
                            </div>
                            <div class="earn-hdr-actions-right">
                                <div class="earn-search-wrap">
                                    <i class="fas fa-search search-icon"></i>
                                    <asp:TextBox ID="txtSearchWithdraws" runat="server" CssClass="earn-search-input"
                                        Placeholder="Search WR, amount, method, status..."
                                        onkeyup="performWithdrawSearch()" autocomplete="off"></asp:TextBox>
                                </div>
                                <!-- <asp:LinkButton ID="btnOpenWithdraw2" runat="server" CssClass="btn-action earn-w-btn-sec" OnClick="btnOpenWithdraw_Click"><i class="fas fa-money-bill-transfer"></i> Withdraw</asp:LinkButton> -->
                            </div>
                        </div>
                    </div>

                    <div class="prod-table-wrap">
                        <asp:Repeater ID="rptWithdrawRequests" runat="server">
                            <HeaderTemplate>
                                <table class="prod-table earn-table" id="dtWithdrawRequests">
                                    <thead>
                                        <tr>
                                            <th>REQUESTED</th>
                                            <th>REFERENCE</th>
                                            <th>AMOUNT</th>
                                            <th>METHOD</th>
                                            <th>STATUS</th>
                                            <th>REMARKS / REASON</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                            </HeaderTemplate>
                            <ItemTemplate>
                                <tr class="earn-withdraw-row"
                                    data-filter-node='<%# Convert.ToDateTime(Eval("CreatedAt")).ToString("MMM dd, yyyy · hh:mm tt") %> <%# Eval("ReferenceNumber") %> <%# Convert.ToDecimal(Eval("RequestAmount")).ToString("N0") %> <%# Eval("PaymentMethod") %> <%# Eval("Status") %>'>
                                    <td>
                                        <%# Convert.ToDateTime(Eval("CreatedAt")).ToString("MMM dd, yyyy · hh:mm tt") %>
                                    </td>
                                    <td><strong class="earn-bold-text">
                                            <%# Eval("ReferenceNumber") %>
                                        </strong></td>
                                    <td><strong class="earn-bold-text">₹<%#
                                                Convert.ToDecimal(Eval("RequestAmount")).ToString("N0") %></strong></td>
                                    <td class="earn-text-muted">
                                        <%# Eval("PaymentMethod") %>
                                    </td>
                                    <td>
                                        <%# GetWithdrawStatusBadge(Eval("Status")) %>
                                    </td>
                                    <td>
                                        <%# Eval("Status").ToString()=="REJECTED" && Eval("AdminRemarks") !=DBNull.Value
                                            && !string.IsNullOrEmpty(Eval("AdminRemarks").ToString())
                                            ? "<div class='withdraw-reject-reason' style='margin:0;'><i class='fas fa-info-circle'></i> "
                                            + Eval("AdminRemarks") + "</div>" : "<span class='earn-text-muted'>—</span>"
                                            %>
                                    </td>
                                </tr>
                            </ItemTemplate>
                            <FooterTemplate>
                                </tbody>
                                </table>
                            </FooterTemplate>
                        </asp:Repeater>

                        <!-- Fallback zero-records alert for withdrawals -->
                        <div id="divWithdrawFallback" class="ord-fallback-div" style="display:none; padding:40px 20px;">
                            <i class="fas fa-magnifying-glass-minus ord-fallback-i"></i>
                            <h4 class="ord-fallback-h4">No Matching Withdrawals</h4>
                            <p class="ord-fallback-p">Modify search keywords to query from current dataset view.</p>
                        </div>

                        <!-- Empty withdrawal placeholder -->
                        <asp:PlaceHolder ID="phEmptyWithdraws" runat="server" Visible="true">
                            <div class="earn-empty-box">
                                <div class="earn-empty-icon"><i class="fas fa-arrow-up-from-bracket"></i></div>
                                <h4>Abhi withdraw request nahi</h4>
                                <p>Balance hone par <strong>Withdraw</strong> se OTP ke sath request bhejein.</p>
                            </div>
                        </asp:PlaceHolder>
                    </div>

                    <!-- Footer Pagination Information for Withdraw Requests -->
                    <div class="earn-pagination-footer">
                        <div class="earn-pagination-text">
                            Showing <strong class="earn-pagination-text-strong">
                                <asp:Literal ID="litWithdrawPaginationRange" runat="server">0-0</asp:Literal>
                            </strong> of <strong class="earn-pagination-text-strong">
                                <asp:Literal ID="litWithdrawPaginationTotal" runat="server">0</asp:Literal>
                            </strong>
                        </div>
                        <div class="earn-pagination-actions">
                            <span class="earn-pagination-select-span">Per page
                                <select class="earn-pagination-select">
                                    <option value="25" selected>25</option>
                                </select>
                            </span>
                            <span class="earn-pagination-text">Page 1 of 1</span>
                        </div>
                    </div>
                </div>

                <!-- ==========================================
                 OTP WITHDRAWAL DIALOG MODAL (POPUP)
                 ========================================== -->
                <asp:Panel ID="pnlWithdrawModal" runat="server" Visible="false" CssClass="earn-modal-overlay">
                    <div class="earn-modal-body">
                        <!-- Modal Header -->
                        <div class="earn-modal-header">
                            <h3><i class="fas fa-money-bill-wave"></i> Request Payout</h3>
                            <asp:LinkButton ID="btnCloseModal" runat="server" CssClass="earn-modal-close"
                                OnClick="btnCloseModal_Click" CausesValidation="false"><i class="fas fa-times"></i>
                            </asp:LinkButton>
                        </div>

                        <!-- SCREEN 1: AMOUNT ENTRY -->
                        <asp:PlaceHolder ID="phModalScreenAmount" runat="server" Visible="true">
                            <div class="earn-modal-content">
                                <div class="earn-balance-badge">
                                    <div class="lbl">Withdrawable Balance</div>
                                    <div class="val">₹<asp:Literal ID="litModalWithdrawable" runat="server">0
                                        </asp:Literal>
                                    </div>
                                    <p>Minimum limit ₹200. Request will be processed directly into your registered bank
                                        account.</p>
                                </div>

                                <!-- Input Box -->
                                <div class="form-grp-dr earn-modal-form-grp">
                                    <label>Withdraw Amount</label>
                                    <div class="earn-amount-input-wrapper">
                                        <asp:TextBox ID="txtWithdrawAmount" runat="server"
                                            CssClass="input-stock-dr earn-modal-input" Placeholder="0.00"></asp:TextBox>
                                        <span class="earn-currency-prefix">₹</span>
                                    </div>
                                    <asp:RequiredFieldValidator ID="rfvAmount" runat="server"
                                        ControlToValidate="txtWithdrawAmount" Display="Dynamic"
                                        ErrorMessage="Amount is required" ForeColor="#ef4444" CssClass="validator">
                                    </asp:RequiredFieldValidator>
                                    <asp:CompareValidator ID="cvAmount" runat="server"
                                        ControlToValidate="txtWithdrawAmount" Operator="DataTypeCheck" Type="Double"
                                        Display="Dynamic" ErrorMessage="Please enter a valid amount" ForeColor="#ef4444"
                                        CssClass="validator"></asp:CompareValidator>
                                </div>

                                <!-- Bank Information Details Preview -->
                                <div class="earn-modal-bank-info">
                                    <div class="lbl"><i class="fas fa-shield-halved"></i> Verified Settlement Account
                                    </div>
                                    <div class="grid">
                                        <div class="grid-item">
                                            <span>Bank Name</span>
                                            <strong>
                                                <asp:Literal ID="litModalBankName" runat="server">HDFC Bank
                                                </asp:Literal>
                                            </strong>
                                        </div>
                                        <div class="grid-item">
                                            <span>Holder Name</span>
                                            <strong>
                                                <asp:Literal ID="litModalHolderName" runat="server">Rahul Seller
                                                </asp:Literal>
                                            </strong>
                                        </div>
                                        <div class="grid-item grid-item-full">
                                            <span>Account Number</span>
                                            <strong style="font-family: monospace; letter-spacing: 0.5px;">
                                                <asp:Literal ID="litModalAccNumber" runat="server">123456789987654321
                                                </asp:Literal>
                                            </strong>
                                        </div>
                                    </div>
                                </div>
                            </div>

                            <!-- Footer Actions -->
                            <div class="earn-modal-footer">
                                <asp:LinkButton ID="btnCancelWithdraw" runat="server"
                                    CssClass="btn-action earn-btn-cancel" OnClick="btnCloseModal_Click"
                                    CausesValidation="false">Cancel</asp:LinkButton>
                                <asp:LinkButton ID="btnNextToOtp" runat="server" CssClass="btn-action earn-btn-submit"
                                    OnClick="btnNextToOtp_Click">Next <i class="fas fa-arrow-right"></i>
                                </asp:LinkButton>
                            </div>
                        </asp:PlaceHolder>

                        <!-- SCREEN 2: OTP VERIFICATION -->
                        <asp:PlaceHolder ID="phModalScreenOtp" runat="server" Visible="false">
                            <div class="earn-modal-content">
                                <div class="earn-center-align">
                                    <div class="earn-modal-otp-icon"><i class="fas fa-shield-halved"></i></div>
                                    <h4 class="earn-modal-otp-title">Verify Authorization</h4>
                                    <p class="earn-modal-otp-desc">OTP has been dispatched to your registered merchant
                                        account to authenticate payout of <strong>₹<asp:Literal ID="litOtpTargetAmount"
                                                runat="server">0</asp:Literal></strong>.</p>
                                </div>

                                <!-- Mock OTP Helper for developer comfort -->
                                <div class="earn-modal-demo-banner">
                                    <i class="fas fa-circle-info"></i> [DEMO AUTHORIZATION] Verification code is:
                                    <strong>
                                        <asp:Literal ID="litMockOtpCode" runat="server">884411</asp:Literal>
                                    </strong>
                                </div>

                                <div class="form-grp-dr earn-modal-otp-input-grp">
                                    <asp:TextBox ID="txtOtpInput" runat="server"
                                        CssClass="input-stock-dr earn-modal-input" Placeholder="Enter 6-digit OTP code"
                                        MaxLength="6"></asp:TextBox>
                                </div>
                            </div>

                            <!-- Footer Actions -->
                            <div class="earn-modal-footer">
                                <asp:LinkButton ID="btnBackToAmount" runat="server"
                                    CssClass="btn-action earn-btn-cancel" OnClick="btnBackToAmount_Click"
                                    CausesValidation="false"><i class="fas fa-arrow-left"></i> Back</asp:LinkButton>
                                <asp:LinkButton ID="btnAuthorizePayout" runat="server"
                                    CssClass="btn-action earn-btn-submit" OnClick="btnAuthorizePayout_Click">Authorize
                                    Payout <i class="fas fa-shield"></i></asp:LinkButton>
                            </div>
                        </asp:PlaceHolder>

                        <!-- SCREEN 3: SUCCESS BLOCK -->
                        <asp:PlaceHolder ID="phModalScreenSuccess" runat="server" Visible="false">
                            <div class="earn-modal-content-success">
                                <div class="earn-modal-success-icon"><i class="fas fa-circle-check"></i></div>
                                <h3>Withdrawal Authorized!</h3>
                                <p>Your request for <strong>₹<asp:Literal ID="litSuccessAmount" runat="server">0
                                        </asp:Literal></strong> has been successfully placed under pending settlement.
                                </p>

                                <div class="earn-modal-summary-box">
                                    <div class="summary-row">
                                        <span><i class="fas fa-hashtag"></i> Reference ID</span>
                                        <strong>
                                            <asp:Literal ID="litSuccessRefId" runat="server">WR000001</asp:Literal>
                                        </strong>
                                    </div>
                                    <div class="summary-row">
                                        <span><i class="fas fa-university"></i> Payout Method</span>
                                        <strong>Bank Transfer</strong>
                                    </div>
                                    <div class="summary-row summary-row-last">
                                        <span><i class="fas fa-business-time"></i> Est. Duration</span>
                                        <strong>1-2 Business Days</strong>
                                    </div>
                                </div>
                            </div>

                            <!-- Footer Actions -->
                            <div class="earn-modal-footer-center">
                                <asp:LinkButton ID="btnFinishSuccess" runat="server"
                                    CssClass="btn-action earn-btn-submit" OnClick="btnCloseModal_Click"
                                    CausesValidation="false">Close Panel</asp:LinkButton>
                            </div>
                        </asp:PlaceHolder>
                    </div>
                </asp:Panel>

            </ContentTemplate>
        </asp:UpdatePanel>

        <!-- Client Side Real-Time Filter Execution Engine -->
        <script type="text/javascript">
            function performOrderSearch() {
                var inp = document.getElementById('<%= txtSearchOrders.ClientID %>');
                if (!inp) return;
                var q = inp.value.trim().toLowerCase();

                var tbl = document.getElementById('dtDeliveredOrders');
                if (!tbl) return;

                var rws = tbl.querySelectorAll('.earn-order-row');
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

                var fb = document.getElementById('divOrderFallback');
                if (fb) {
                    fb.style.display = (match === 0 && rws.length > 0) ? 'block' : 'none';
                }
            }

            function performWithdrawSearch() {
                var inp = document.getElementById('<%= txtSearchWithdraws.ClientID %>');
                if (!inp) return;
                var q = inp.value.trim().toLowerCase();

                var tbl = document.getElementById('dtWithdrawRequests');
                if (!tbl) return;

                var rws = tbl.querySelectorAll('.earn-withdraw-row');
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

                var fb = document.getElementById('divWithdrawFallback');
                if (fb) {
                    fb.style.display = (match === 0 && rws.length > 0) ? 'block' : 'none';
                }

                // Update pagination footer dynamically
                var rangeLit = document.getElementById('<%= litWithdrawPaginationRange.ClientID %>');
                var totalLit = document.getElementById('<%= litWithdrawPaginationTotal.ClientID %>');
                if (rangeLit) {
                    rangeLit.textContent = match > 0 ? '1-' + match : '0-0';
                }
                if (totalLit) {
                    totalLit.textContent = match;
                }
            }

            // Restore Search Queries after Asynchronous Postbacks (UpdatePanel)
            function restoreEarningsSearch() {
                // Restore Order Search
                var inpOrders = document.getElementById('<%= txtSearchOrders.ClientID %>');
                if (inpOrders) {
                    performOrderSearch();
                }

                // Restore Withdraw Search
                var inpWithdraws = document.getElementById('<%= txtSearchWithdraws.ClientID %>');
                if (inpWithdraws) {
                    performWithdrawSearch();
                }
            }

            // Bind events for DOM load and ASP.NET AJAX partial updates
            window.addEventListener('DOMContentLoaded', restoreEarningsSearch);

            if (typeof Sys !== 'undefined' && Sys.WebForms && Sys.WebForms.PageRequestManager) {
                Sys.WebForms.PageRequestManager.getInstance().add_endRequest(restoreEarningsSearch);
            }
        </script>

    </asp:Content>