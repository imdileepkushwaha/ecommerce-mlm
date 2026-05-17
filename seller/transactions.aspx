<%@ Page Title="Transaction Ledger" Language="C#" MasterPageFile="~/seller/Seller.Master" AutoEventWireup="true"
    CodeFile="transactions.aspx.cs" Inherits="EcommerceWebsite.SellerTransactions" %>

    <asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

        <!-- SCRIPTA MANAGER FOR AJAX ACTIONS -->
        <asp:ScriptManager ID="smTransactions" runat="server"></asp:ScriptManager>

        <!-- MAIN UPDATABLE VIEWPORT -->
        <asp:UpdatePanel ID="upnlTransactions" runat="server" UpdateMode="Conditional">
            <ContentTemplate>

                <!-- TOP BAR ROW -->
                <div class="page-action-bar earn-header">
                    <div class="welcome-title earn-welcome-title">
                        <h1><i class="fas fa-list-ul"></i> Transaction Ledger</h1>
                        <p>Comprehensive audit history of credited earnings, fee deductions, and withdrawal payouts.</p>
                    </div>
                    <div class="action-btn-grp earn-action-btn-grp">
                        <a href="earnings.aspx" class="btn-action earn-nav-btn"><i class="fas fa-wallet"></i> Earnings</a>
                        <a href="Withdrawal.aspx" class="btn-action earn-nav-btn"><i class="fas fa-hand-holding-dollar"></i> Withdrawal</a>
                    </div>
                </div>

                <!-- DYNAMIC GLOBAL ALERT SYSTEM -->
                <asp:Label ID="lblMsg" runat="server" Visible="false" CssClass="earn-global-alert"></asp:Label>

                <!-- FINANCIAL STATISTICS GRID -->
                <div class="dashboard-stat-row earn-stat-row" style="grid-template-columns: repeat(auto-fit, minmax(320px, 1fr));">
                    <!-- Card 1: Total Credits (Income) -->
                    <div class="d-card d-card-3">
                        <div class="d-meta">
                            <span class="d-title">TOTAL CREDITED</span>
                            <span class="d-count" style="color: #10b981;">+₹<asp:Literal ID="litTotalCredited" runat="server">0</asp:Literal></span>
                            <span class="d-desc">Income from delivered products</span>
                        </div>
                        <div class="d-icon-circle rv-ico-approved"><i class="fas fa-arrow-down-left"></i></div>
                    </div>

                    <!-- Card 2: Total Debits (Payouts) -->
                    <div class="d-card d-card-1">
                        <div class="d-meta">
                            <span class="d-title">TOTAL SETTLED</span>
                            <span class="d-count" style="color: #ef4444;">-₹<asp:Literal ID="litTotalSettled" runat="server">0</asp:Literal></span>
                            <span class="d-desc">Debited/approved payouts</span>
                        </div>
                        <div class="d-icon-circle rv-ico-pending" style="background: rgba(239, 68, 68, 0.08); color: #ef4444;"><i class="fas fa-arrow-up-right"></i></div>
                    </div>

                    <!-- Card 3: Net Ledger Balance -->
                    <div class="d-card d-card-2">
                        <div class="d-meta">
                            <span class="d-title">NET LEDGER VALUE</span>
                            <span class="d-count">₹<asp:Literal ID="litNetValue" runat="server">0</asp:Literal></span>
                            <span class="d-desc">Total credited minus paid out</span>
                        </div>
                        <div class="d-icon-circle rv-ico-intake"><i class="fas fa-scale-balanced"></i></div>
                    </div>
                </div>

                <!-- TRANSACTIONS CONTAINER -->
                <div class="prod-card earn-panel" style="margin-top: 25px;">
                    <div class="earn-table-header-box">
                        <div class="earn-header-flex">
                            <div class="earn-title-group">
                                <h3>Account Ledger <span class="earn-table-badge earn-badge-red">
                                        <asp:Literal ID="litTransactionsBadgeCount" runat="server">0</asp:Literal> records
                                    </span></h3>
                                <p>View real-time chronological entries of credits (income) and debits (withdrawals).</p>
                            </div>
                            
                            <!-- Search & Dynamic Filters bar -->
                            <div class="earn-hdr-actions-right">
                                <!-- Type filter select -->
                                <select id="ddlFilterType" class="earn-filter-select" onchange="performLedgerSearch()">
                                    <option value="">All Types</option>
                                    <option value="CREDIT">Credits</option>
                                    <option value="DEBIT">Debits</option>
                                </select>
                                
                                <!-- Status filter select -->
                                <select id="ddlFilterStatus" class="earn-filter-select" onchange="performLedgerSearch()">
                                    <option value="">All Statuses</option>
                                    <option value="SUCCESS">Success</option>
                                    <option value="PENDING">Pending</option>
                                    <option value="FAILED">Failed</option>
                                </select>

                                <div class="earn-search-wrap">
                                    <i class="fas fa-search search-icon"></i>
                                    <asp:TextBox ID="txtSearchLedger" runat="server" CssClass="earn-search-input"
                                        Placeholder="Search reference, description..." onkeyup="performLedgerSearch()"
                                        autocomplete="off"></asp:TextBox>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="prod-table-wrap">
                        <asp:Repeater ID="rptTransactions" runat="server">
                            <HeaderTemplate>
                                <table class="prod-table earn-table" id="dtLedger">
                                    <thead>
                                        <tr>
                                            <th>DATE / TIME</th>
                                            <th>REFERENCE</th>
                                            <th>DESCRIPTION</th>
                                            <th>TYPE</th>
                                            <th>AMOUNT</th>
                                            <th>STATUS</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                            </HeaderTemplate>
                            <ItemTemplate>
                                <tr class="earn-ledger-row"
                                    data-filter-node='<%# Convert.ToDateTime(Eval("TxnDate")).ToString("MMM dd, yyyy · hh:mm tt") %> <%# Eval("ReferenceNumber") %> <%# Eval("Description") %> <%# Eval("TxnType") %> <%# Eval("Status") %>'>
                                    <td>
                                        <%# Convert.ToDateTime(Eval("TxnDate")).ToString("MMM dd, yyyy · hh:mm tt") %>
                                    </td>
                                    <td>
                                        <strong class="earn-bold-text"><%# Eval("ReferenceNumber") %></strong>
                                    </td>
                                    <td>
                                        <span class="earn-text-secondary"><%# Eval("Description") %></span>
                                    </td>
                                    <td>
                                        <%# Eval("TxnType").ToString() == "CREDIT" 
                                            ? "<span class='earn-table-badge badge-delivered' style='padding:4px 8px;'><i class='fas fa-arrow-down-left' style='margin-right:4px;'></i>CREDIT</span>"
                                            : "<span class='earn-table-badge badge-cancelled' style='padding:4px 8px;'><i class='fas fa-arrow-up-right' style='margin-right:4px;'></i>DEBIT</span>"
                                        %>
                                    </td>
                                    <td>
                                        <strong class='<%# Eval("TxnType").ToString() == "CREDIT" ? "earn-success-amount" : "earn-bold-text" %>' 
                                                style='<%# Eval("TxnType").ToString() == "CREDIT" ? "" : "color: #ef4444;" %>'>
                                            <%# Eval("TxnType").ToString() == "CREDIT" ? "+" : "-" %>₹<%# Convert.ToDecimal(Eval("Amount")).ToString("N2") %>
                                        </strong>
                                    </td>
                                    <td>
                                        <%# GetLedgerStatusBadge(Eval("Status")) %>
                                    </td>
                                </tr>
                            </ItemTemplate>
                            <FooterTemplate>
                                </tbody>
                                </table>
                            </FooterTemplate>
                        </asp:Repeater>

                        <!-- Fallback zero-records alert -->
                        <div id="divLedgerFallback" class="ord-fallback-div" style="display:none; padding:40px 20px;">
                            <i class="fas fa-magnifying-glass-minus ord-fallback-i"></i>
                            <h4 class="ord-fallback-h4">No Ledger Entries Found</h4>
                            <p class="ord-fallback-p">No transactions match your current search query or dynamic filters.</p>
                        </div>

                        <!-- Empty transaction state placeholder -->
                        <asp:PlaceHolder ID="phEmptyLedger" runat="server" Visible="true">
                            <div class="earn-empty-box">
                                <div class="earn-empty-icon"><i class="fas fa-scale-balanced"></i></div>
                                <h4>Ledger Khali Hai</h4>
                                <p>Jab aap products sell karenge ya payout receive karenge, ledger entries yahan dikhein gi.</p>
                            </div>
                        </asp:PlaceHolder>
                    </div>

                    <!-- DELIVERED STYLE PAGINATION FOOTER -->
                    <div class="earn-pagination-footer">
                        <div class="earn-pagination-text">
                            Showing <strong class="earn-pagination-text-strong">
                                <asp:Literal ID="litLedgerPaginationRange" runat="server">0-0</asp:Literal>
                            </strong> of <strong class="earn-pagination-text-strong">
                                <asp:Literal ID="litLedgerPaginationTotal" runat="server">0</asp:Literal>
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

            </ContentTemplate>
        </asp:UpdatePanel>

        <!-- Dynamic Real-Time Client Filtration & Pagination Update System -->
        <script type="text/javascript">
            function performLedgerSearch() {
                var inp = document.getElementById('<%= txtSearchLedger.ClientID %>');
                if (!inp) return;
                var q = inp.value.trim().toLowerCase();

                var filterType = document.getElementById('ddlFilterType').value.toUpperCase();
                var filterStatus = document.getElementById('ddlFilterStatus').value.toUpperCase();

                var tbl = document.getElementById('dtLedger');
                if (!tbl) return;

                var rws = tbl.querySelectorAll('.earn-ledger-row');
                var match = 0;

                rws.forEach(function (rw) {
                    var token = rw.getAttribute('data-filter-node').toUpperCase();
                    
                    var textMatch = q === "" || token.indexOf(q.toUpperCase()) > -1;
                    var typeMatch = filterType === "" || token.indexOf(" " + filterType + " ") > -1;
                    var statusMatch = filterStatus === "" || token.endsWith(" " + filterStatus) || token.indexOf(" " + filterStatus + " ") > -1;

                    if (textMatch && typeMatch && statusMatch) {
                        rw.style.display = '';
                        match++;
                    } else {
                        rw.style.display = 'none';
                    }
                });

                var fb = document.getElementById('divLedgerFallback');
                if (fb) {
                    fb.style.display = (match === 0 && rws.length > 0) ? 'block' : 'none';
                }

                // Update dynamic pagination telemetry
                var rangeLit = document.getElementById('<%= litLedgerPaginationRange.ClientID %>');
                var totalLit = document.getElementById('<%= litLedgerPaginationTotal.ClientID %>');
                if (rangeLit) {
                    rangeLit.textContent = match > 0 ? '1-' + match : '0-0';
                }
                if (totalLit) {
                    totalLit.textContent = match;
                }
            }

            // Restore search queries on asynchronous updates
            function restoreLedgerSearch() {
                var inp = document.getElementById('<%= txtSearchLedger.ClientID %>');
                if (inp) {
                    performLedgerSearch();
                }
            }

            window.addEventListener('DOMContentLoaded', restoreLedgerSearch);
            if (typeof Sys !== 'undefined' && Sys.WebForms && Sys.WebForms.PageRequestManager) {
                Sys.WebForms.PageRequestManager.getInstance().add_endRequest(restoreLedgerSearch);
            }
        </script>

    </asp:Content>
