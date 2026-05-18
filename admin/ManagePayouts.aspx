<%@ Page Title="Withdrawal settlements" Language="C#" MasterPageFile="~/admin/Admin.Master" AutoEventWireup="true"
    CodeFile="ManagePayouts.aspx.cs" Inherits="ecommerce_mlm.admin.ManagePayouts" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

    <asp:ScriptManager ID="ScriptManager1" runat="server" />

    <asp:HiddenField ID="hfSelectedPayoutId" runat="server" ClientIDMode="Static" />
    <asp:HiddenField ID="hfPayoutType" runat="server" Value="member" ClientIDMode="Static" />

    <div class="ms-page py-page">
        <div class="ms-page-head">
            <div class="ms-page-head-left">
                <span class="ms-overline">FINANCE</span>
                <h1 class="ms-title">Withdrawal settlements</h1>
                <p class="ms-sub">Audit payout requests, process bank transfers, and record UTR references.</p>
            </div>
        </div>

        <asp:Panel ID="pnlFlash" runat="server" Visible="false" CssClass="ms-flash">
            <i runat="server" id="icoFlash" class="fas fa-check-circle"></i>
            <asp:Literal ID="litFlash" runat="server" />
        </asp:Panel>

        <div class="ms-kpi-grid">
            <div class="ms-kpi-card ms-kpi-orange">
                <div class="ms-kpi-body">
                    <label><asp:Literal ID="litKpiTypeLabel" runat="server" Text="PENDING" /></label>
                    <strong><asp:Literal ID="litKpiPending" runat="server" Text="0" /></strong>
                    <span>Awaiting settlement</span>
                </div>
                <div class="ms-kpi-ico"><i class="fas fa-hourglass-half"></i></div>
            </div>
            <div class="ms-kpi-card ms-kpi-green">
                <div class="ms-kpi-body">
                    <label>SETTLED</label>
                    <strong><asp:Literal ID="litKpiPaid" runat="server" Text="0" /></strong>
                    <span>Marked paid</span>
                </div>
                <div class="ms-kpi-ico"><i class="fas fa-check-circle"></i></div>
            </div>
            <div class="ms-kpi-card ms-kpi-red">
                <div class="ms-kpi-body">
                    <label>REJECTED</label>
                    <strong><asp:Literal ID="litKpiRejected" runat="server" Text="0" /></strong>
                    <span>Denied requests</span>
                </div>
                <div class="ms-kpi-ico"><i class="fas fa-ban"></i></div>
            </div>
            <div class="ms-kpi-card ms-kpi-indigo">
                <div class="ms-kpi-body">
                    <label>PENDING VALUE</label>
                    <strong><asp:Literal ID="litKpiPendingAmt" runat="server" Text="₹0.00" /></strong>
                    <span><asp:Literal ID="litKpiListSub" runat="server" Text="0 matching filter" /></span>
                </div>
                <div class="ms-kpi-ico"><i class="fas fa-rupee-sign"></i></div>
            </div>
        </div>

        <div class="mp-tabs" role="tablist">
            <asp:HyperLink ID="hlTabMember" runat="server" CssClass="mp-tab">
                <span class="mp-tab-label">Member payouts</span>
            </asp:HyperLink>
            <asp:HyperLink ID="hlTabSeller" runat="server" CssClass="mp-tab">
                <span class="mp-tab-label">Seller payouts</span>
            </asp:HyperLink>
        </div>

        <div class="ms-table-card py-table-card">
            <div class="ms-table-toolbar">
                <div class="ms-table-toolbar-left">
                    <h3><asp:Literal ID="litTableTitle" runat="server" Text="Member withdrawal requests" /></h3>
                    <p><asp:Literal ID="litTableHint" runat="server" /></p>
                </div>
                <div class="ms-toolbar-right py-toolbar-right">
                    <div class="py-filter-wrap">
                        <label for="ddlStatusFilter" class="py-filter-label"><i class="fas fa-filter"></i> Status</label>
                        <asp:DropDownList ID="ddlStatusFilter" runat="server" AutoPostBack="true"
                            OnSelectedIndexChanged="ddlStatusFilter_SelectedIndexChanged" CssClass="py-filter-select" ClientIDMode="Static">
                            <asp:ListItem Value="ALL" Text="All requests" Selected="True" />
                            <asp:ListItem Value="PENDING" Text="Pending audit" />
                            <asp:ListItem Value="PAID" Text="Settled" />
                            <asp:ListItem Value="REJECTED" Text="Rejected" />
                        </asp:DropDownList>
                    </div>
                    <div class="ms-search-wrap" id="searchGroup">
                        <i class="fas fa-search"></i>
                        <input type="text" id="txtSearch" class="ms-search-input" placeholder="Search ID, name, UTR, bank..." autocomplete="off" />
                        <button type="button" class="ms-search-clear" onclick="clearPayoutSearch();" aria-label="Clear search">
                            <i class="fas fa-times"></i>
                        </button>
                    </div>
                </div>
            </div>

            <div class="ms-table-scroll">
                <asp:Repeater ID="rptPayouts" runat="server" OnItemCommand="rptPayouts_ItemCommand">
                    <HeaderTemplate>
                        <table class="py-table" id="payoutsTable">
                            <thead>
                                <tr>
                                    <th>REQUEST</th>
                                    <th>ACCOUNT</th>
                                    <th>AMOUNTS</th>
                                    <th>BANK</th>
                                    <th>STATUS</th>
                                    <th class="ms-th-actions">ACTIONS</th>
                                </tr>
                            </thead>
                            <tbody>
                    </HeaderTemplate>
                    <ItemTemplate>
                        <tr>
                            <td><%# FormatRequestRef(Eval("Id"), Eval("CreatedAt")) %></td>
                            <td><%# FormatMemberCell(Eval("FullName"), Eval("Username")) %></td>
                            <td><%# FormatAmounts(Eval("RequestAmount"), Eval("TdsDeduction"), Eval("AdminCharges"), Eval("NetPayable")) %></td>
                            <td><%# FormatBankCell(Eval("BankName"), Eval("AccountNumber"), Eval("IFSCCode"), Eval("AccountHolderName")) %></td>
                            <td><%# FormatStatusCell(Eval("Status"), Eval("TransactionId")) %></td>
                            <td>
                                <div class="py-actions">
                                    <asp:Panel runat="server" Visible='<%# ShowPendingActions(Eval("Status")) %>' CssClass="py-actions-pending">
                                        <asp:LinkButton runat="server" CommandName="PaidTrigger" CommandArgument='<%# Eval("Id") %>'
                                            CssClass="action-btn-circle action-btn-unblock" ToolTip="Mark paid">
                                            <i class="fas fa-check"></i>
                                        </asp:LinkButton>
                                        <asp:LinkButton runat="server" CommandName="RejectTrigger" CommandArgument='<%# Eval("Id") %>'
                                            CssClass="action-btn-circle action-btn-block" ToolTip="Reject request">
                                            <i class="fas fa-times"></i>
                                        </asp:LinkButton>
                                    </asp:Panel>
                                    <asp:Panel runat="server" Visible='<%# !ShowPendingActions(Eval("Status")) %>'>
                                        <span class="py-processed">Processed</span>
                                    </asp:Panel>
                                </div>
                            </td>
                        </tr>
                    </ItemTemplate>
                    <FooterTemplate></tbody></table></FooterTemplate>
                </asp:Repeater>
            </div>

            <asp:Panel ID="pnlEmpty" runat="server" Visible="false" CssClass="ms-empty-state">
                <div class="ms-empty-ico ms-empty-muted"><i class="fas fa-receipt"></i></div>
                <h4 class="ms-empty-title"><asp:Literal ID="litEmptyTitle" runat="server" Text="No payout requests" /></h4>
                <p class="ms-empty-desc"><asp:Literal ID="litEmptyDesc" runat="server" /></p>
            </asp:Panel>

            <div id="searchEmptyState" class="ms-empty-state u-d-none" aria-live="polite">
                <div class="ms-empty-ico"><i class="fas fa-search"></i></div>
                <h4 class="ms-empty-title">No matches on this page</h4>
                <p class="ms-empty-desc">Nothing matches your search on this page.</p>
                <button type="button" class="ms-empty-btn" onclick="clearPayoutSearch();">
                    <i class="fas fa-times"></i> Clear search
                </button>
            </div>

            <div class="ms-table-foot">
                <div class="ms-table-foot-left">
                    <asp:Literal ID="litShowing" runat="server" Text="Showing 0 of 0" />
                    <span class="py-foot-extra">· <asp:Literal ID="litKpiThisList" runat="server" Text="0" /> in list</span>
                </div>
                <div class="ms-table-foot-right">
                    <div class="ms-per-page">
                        <span>Per page</span>
                        <asp:DropDownList ID="ddlPageSize" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlPageSize_SelectedIndexChanged" ClientIDMode="Static">
                            <asp:ListItem Text="10" Value="10" />
                            <asp:ListItem Text="25" Value="25" Selected="True" />
                            <asp:ListItem Text="50" Value="50" />
                        </asp:DropDownList>
                    </div>
                    <asp:Literal ID="litPageInfo" runat="server" Text="Page 1 of 1" />
                    <div class="ms-pager">
                        <asp:Literal ID="litPager" runat="server" />
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="ms-modal" id="modal-paid" aria-hidden="true">
        <div class="ms-modal-backdrop" onclick="closePayoutModal();"></div>
        <div class="ms-modal-dialog">
            <div class="ms-modal-header">
                <div class="ms-modal-icon-success" aria-hidden="true"><i class="fas fa-money-bill-wave"></i></div>
                <div class="ms-modal-head-text">
                    <h3>Log bank settlement</h3>
                    <p class="ms-modal-sub">Enter the UTR / reference from your bank transfer.</p>
                </div>
                <button type="button" class="ms-modal-close" onclick="closePayoutModal();" aria-label="Close">&times;</button>
            </div>
            <div class="ms-modal-body">
                <label class="py-modal-label" for="txtTxnId">Bank reference / UTR</label>
                <asp:TextBox ID="txtTxnId" runat="server" CssClass="py-modal-input" placeholder="e.g. UTR928374822" ClientIDMode="Static" />
            </div>
            <div class="ms-modal-footer">
                <button type="button" class="ms-btn ms-btn-outline" onclick="closePayoutModal();">Cancel</button>
                <asp:Button ID="btnConfirmPaid" runat="server" Text="Release payout" CssClass="ms-btn ms-btn-primary"
                    OnClick="btnConfirmPaid_Click" />
            </div>
        </div>
    </div>

    <div class="ms-modal" id="modal-reject" aria-hidden="true">
        <div class="ms-modal-backdrop" onclick="closePayoutModal();"></div>
        <div class="ms-modal-dialog">
            <div class="ms-modal-header">
                <div class="ms-modal-icon-danger" aria-hidden="true"><i class="fas fa-ban"></i></div>
                <div class="ms-modal-head-text">
                    <h3>Reject payout request</h3>
                    <p class="ms-modal-sub">This reason is shown on the member or seller dashboard.</p>
                </div>
                <button type="button" class="ms-modal-close" onclick="closePayoutModal();" aria-label="Close">&times;</button>
            </div>
            <div class="ms-modal-body">
                <label class="py-modal-label" for="txtReason">Reason for rejection</label>
                <asp:TextBox ID="txtReason" runat="server" TextMode="MultiLine" Rows="3" CssClass="py-modal-input py-modal-textarea"
                    placeholder="e.g. Invalid IFSC code provided." ClientIDMode="Static" />
            </div>
            <div class="ms-modal-footer">
                <button type="button" class="ms-btn ms-btn-outline" onclick="closePayoutModal();">Cancel</button>
                <asp:Button ID="btnConfirmReject" runat="server" Text="Deny request" CssClass="ms-btn ms-btn-danger"
                    OnClick="btnConfirmReject_Click" />
            </div>
        </div>
    </div>

    <script type="text/javascript">
        (function () {
            var input = document.getElementById('txtSearch');
            if (input) input.addEventListener('input', filterPayoutTable);
        })();

        function openPayoutModal(type) {
            closePayoutModal();
            var el = document.getElementById(type === 'paid' ? 'modal-paid' : 'modal-reject');
            if (el) {
                el.classList.add('is-open');
                el.setAttribute('aria-hidden', 'false');
            }
        }

        function closePayoutModal() {
            document.querySelectorAll('.ms-modal').forEach(function (el) {
                el.classList.remove('is-open');
                el.setAttribute('aria-hidden', 'true');
            });
        }

        function filterPayoutTable() {
            var input = document.getElementById('txtSearch');
            var table = document.getElementById('payoutsTable');
            var empty = document.getElementById('searchEmptyState');
            if (!input || !table) return;
            var q = (input.value || '').toLowerCase().trim();
            var rows = table.querySelectorAll('tbody tr');
            var visible = 0;
            for (var i = 0; i < rows.length; i++) {
                var show = !q || (rows[i].textContent || '').toLowerCase().indexOf(q) !== -1;
                rows[i].style.display = show ? '' : 'none';
                if (show) visible++;
            }
            if (empty) empty.classList.toggle('u-d-none', visible > 0 || rows.length === 0);
            var wrap = table.closest('.ms-table-scroll');
            if (wrap) wrap.style.display = (visible === 0 && rows.length > 0) ? 'none' : '';
        }

        function clearPayoutSearch() {
            var input = document.getElementById('txtSearch');
            if (input) input.value = '';
            filterPayoutTable();
        }
    </script>
</asp:Content>
