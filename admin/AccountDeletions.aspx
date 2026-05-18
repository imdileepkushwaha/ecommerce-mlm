<%@ Page Title="Account deletions" Language="C#" MasterPageFile="~/admin/Admin.Master" AutoEventWireup="true"
    CodeFile="AccountDeletions.aspx.cs" Inherits="ecommerce_mlm.admin.AccountDeletions" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="ms-page ad-page">
        <div class="ms-page-head">
            <div class="ms-page-head-left">
                <span class="ms-overline">COMPLIANCE</span>
                <h1 class="ms-title">Account deletions</h1>
                <p class="ms-sub">Review and authorize user and seller account termination requests.</p>
            </div>
        </div>

        <div class="ad-notice">
            <i class="fas fa-exclamation-triangle"></i>
            <div>
                <strong>Permanent action.</strong>
                Approving deletion disables the account. Audit each request before authorizing.
            </div>
        </div>

        <asp:Panel ID="pnlFlash" runat="server" Visible="false" CssClass="ms-flash">
            <i runat="server" id="icoFlash" class="fas fa-check-circle"></i>
            <asp:Literal ID="litFlash" runat="server" />
        </asp:Panel>

        <div class="ms-kpi-grid ms-kpi-grid-3">
            <div class="ms-kpi-card ms-kpi-orange">
                <div class="ms-kpi-body">
                    <label>PENDING USERS</label>
                    <strong><asp:Literal ID="litKpiUsers" runat="server" Text="0" /></strong>
                    <span>Awaiting review</span>
                </div>
                <div class="ms-kpi-ico"><i class="fas fa-user"></i></div>
            </div>
            <div class="ms-kpi-card ms-kpi-red">
                <div class="ms-kpi-body">
                    <label>PENDING SELLERS</label>
                    <strong><asp:Literal ID="litKpiSellers" runat="server" Text="0" /></strong>
                    <span>Merchant requests</span>
                </div>
                <div class="ms-kpi-ico"><i class="fas fa-store"></i></div>
            </div>
            <div class="ms-kpi-card ms-kpi-indigo">
                <div class="ms-kpi-body">
                    <label>RESOLVED</label>
                    <strong><asp:Literal ID="litKpiResolved" runat="server" Text="0" /></strong>
                    <span>Approved or cancelled</span>
                </div>
                <div class="ms-kpi-ico"><i class="fas fa-history"></i></div>
            </div>
        </div>

        <!-- User requests -->
        <div class="ms-table-card ad-table-card">
            <div class="ms-table-toolbar">
                <div class="ms-table-toolbar-left">
                    <h3>User deletion requests</h3>
                    <p><asp:Literal ID="litUserHint" runat="server" /></p>
                </div>
                <div class="ms-search-wrap" id="userSearchGroup">
                    <i class="fas fa-search"></i>
                    <input type="text" id="txtUserSearch" class="ms-search-input" placeholder="Search name, email, request ID..." autocomplete="off" />
                    <button type="button" class="ms-search-clear" onclick="clearAdSearch('txtUserSearch','usersTable','userEmptyState');" aria-label="Clear search">
                        <i class="fas fa-times"></i>
                    </button>
                </div>
            </div>

            <div class="ms-table-scroll">
                <asp:Repeater ID="rptUsers" runat="server" OnItemCommand="rptAction_ItemCommand">
                    <HeaderTemplate>
                        <table class="ad-table" id="usersTable">
                            <thead>
                                <tr>
                                    <th>REQUEST</th>
                                    <th>USER</th>
                                    <th>STATUS</th>
                                    <th class="ms-th-actions">ACTIONS</th>
                                </tr>
                            </thead>
                            <tbody>
                    </HeaderTemplate>
                    <ItemTemplate>
                        <tr>
                            <td><%# FormatRequestRef(Eval("Id"), Eval("RequestDate")) %></td>
                            <td><%# FormatProfile(Eval("FullName"), Eval("Email"), Eval("Mobile")) %></td>
                            <td><%# FormatPendingStatus(Eval("Status")) %></td>
                            <td>
                                <div class="ad-actions">
                                    <asp:LinkButton runat="server" CommandName="ApproveRequest" CommandArgument='<%# Eval("Id") + "|User" %>'
                                        CssClass="action-btn-circle action-btn-block" ToolTip="Approve deletion"
                                        OnClientClick="return confirm('Permanently approve this user deletion request?');">
                                        <i class="fas fa-trash-alt"></i>
                                    </asp:LinkButton>
                                    <asp:LinkButton runat="server" CommandName="RejectRequest" CommandArgument='<%# Eval("Id") + "|User" %>'
                                        CssClass="action-btn-circle action-btn-unblock" ToolTip="Reject and keep account"
                                        OnClientClick="return confirm('Reject this deletion request and keep the account active?');">
                                        <i class="fas fa-undo-alt"></i>
                                    </asp:LinkButton>
                                </div>
                            </td>
                        </tr>
                    </ItemTemplate>
                    <FooterTemplate></tbody></table></FooterTemplate>
                </asp:Repeater>
            </div>

            <asp:Panel ID="pnlUsersEmpty" runat="server" Visible="false" CssClass="ms-empty-state">
                <div class="ms-empty-ico ms-empty-muted"><i class="fas fa-check-circle"></i></div>
                <h4 class="ms-empty-title">No pending user requests</h4>
                <p class="ms-empty-desc">Consumer deletion requests will appear here.</p>
            </asp:Panel>

            <div id="userEmptyState" class="ms-empty-state u-d-none" aria-live="polite">
                <div class="ms-empty-ico"><i class="fas fa-search"></i></div>
                <h4 class="ms-empty-title">No matches on this page</h4>
                <p class="ms-empty-desc">Nothing matches your search on this page.</p>
                <button type="button" class="ms-empty-btn" onclick="clearAdSearch('txtUserSearch','usersTable','userEmptyState');">
                    <i class="fas fa-times"></i> Clear search
                </button>
            </div>

            <div class="ms-table-foot">
                <div class="ms-table-foot-left">
                    <asp:Literal ID="litUserShowing" runat="server" Text="Showing 0 of 0" />
                </div>
                <div class="ms-table-foot-right">
                    <div class="ms-per-page">
                        <span>Per page</span>
                        <asp:DropDownList ID="ddlUserPageSize" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlUserPageSize_SelectedIndexChanged" ClientIDMode="Static">
                            <asp:ListItem Text="10" Value="10" Selected="True" />
                            <asp:ListItem Text="25" Value="25" />
                            <asp:ListItem Text="50" Value="50" />
                        </asp:DropDownList>
                    </div>
                    <asp:Literal ID="litUserPageInfo" runat="server" Text="Page 1 of 1" />
                    <div class="ms-pager">
                        <asp:Literal ID="litUserPager" runat="server" />
                    </div>
                </div>
            </div>
        </div>

        <!-- Seller requests -->
        <div class="ms-table-card ad-table-card">
            <div class="ms-table-toolbar">
                <div class="ms-table-toolbar-left">
                    <h3>Seller deletion requests</h3>
                    <p><asp:Literal ID="litSellerHint" runat="server" /></p>
                </div>
                <div class="ms-search-wrap" id="sellerSearchGroup">
                    <i class="fas fa-search"></i>
                    <input type="text" id="txtSellerSearch" class="ms-search-input" placeholder="Search name, email, store..." autocomplete="off" />
                    <button type="button" class="ms-search-clear" onclick="clearAdSearch('txtSellerSearch','sellersTable','sellerEmptyState');" aria-label="Clear search">
                        <i class="fas fa-times"></i>
                    </button>
                </div>
            </div>

            <div class="ms-table-scroll">
                <asp:Repeater ID="rptSellers" runat="server" OnItemCommand="rptAction_ItemCommand">
                    <HeaderTemplate>
                        <table class="ad-table" id="sellersTable">
                            <thead>
                                <tr>
                                    <th>REQUEST</th>
                                    <th>SELLER</th>
                                    <th>STATUS</th>
                                    <th class="ms-th-actions">ACTIONS</th>
                                </tr>
                            </thead>
                            <tbody>
                    </HeaderTemplate>
                    <ItemTemplate>
                        <tr>
                            <td><%# FormatRequestRef(Eval("Id"), Eval("DeactivationDate")) %></td>
                            <td><%# FormatProfile(Eval("FullName"), Eval("Email"), Eval("StoreName")) %></td>
                            <td><%# FormatPendingStatus(Eval("DeletionStatus")) %></td>
                            <td>
                                <div class="ad-actions">
                                    <asp:LinkButton runat="server" CommandName="ApproveRequest" CommandArgument='<%# Eval("Id") + "|Seller" %>'
                                        CssClass="action-btn-circle action-btn-block" ToolTip="Approve deletion"
                                        OnClientClick="return confirm('Permanently approve this seller deletion request?');">
                                        <i class="fas fa-trash-alt"></i>
                                    </asp:LinkButton>
                                    <asp:LinkButton runat="server" CommandName="RejectRequest" CommandArgument='<%# Eval("Id") + "|Seller" %>'
                                        CssClass="action-btn-circle action-btn-unblock" ToolTip="Reject and reinstate"
                                        OnClientClick="return confirm('Reject this deletion request and reinstate the seller?');">
                                        <i class="fas fa-undo-alt"></i>
                                    </asp:LinkButton>
                                    <a href='SellerView.aspx?id=<%# Eval("Id") %>' class="action-btn-circle action-btn-view" title="View seller">
                                        <i class="fas fa-eye"></i>
                                    </a>
                                </div>
                            </td>
                        </tr>
                    </ItemTemplate>
                    <FooterTemplate></tbody></table></FooterTemplate>
                </asp:Repeater>
            </div>

            <asp:Panel ID="pnlSellersEmpty" runat="server" Visible="false" CssClass="ms-empty-state">
                <div class="ms-empty-ico ms-empty-muted"><i class="fas fa-check-circle"></i></div>
                <h4 class="ms-empty-title">No pending seller requests</h4>
                <p class="ms-empty-desc">Merchant deletion requests will appear here.</p>
            </asp:Panel>

            <div id="sellerEmptyState" class="ms-empty-state u-d-none" aria-live="polite">
                <div class="ms-empty-ico"><i class="fas fa-search"></i></div>
                <h4 class="ms-empty-title">No matches on this page</h4>
                <p class="ms-empty-desc">Nothing matches your search on this page.</p>
                <button type="button" class="ms-empty-btn" onclick="clearAdSearch('txtSellerSearch','sellersTable','sellerEmptyState');">
                    <i class="fas fa-times"></i> Clear search
                </button>
            </div>

            <div class="ms-table-foot">
                <div class="ms-table-foot-left">
                    <asp:Literal ID="litSellerShowing" runat="server" Text="Showing 0 of 0" />
                </div>
                <div class="ms-table-foot-right">
                    <div class="ms-per-page">
                        <span>Per page</span>
                        <asp:DropDownList ID="ddlSellerPageSize" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlSellerPageSize_SelectedIndexChanged" ClientIDMode="Static">
                            <asp:ListItem Text="10" Value="10" Selected="True" />
                            <asp:ListItem Text="25" Value="25" />
                            <asp:ListItem Text="50" Value="50" />
                        </asp:DropDownList>
                    </div>
                    <asp:Literal ID="litSellerPageInfo" runat="server" Text="Page 1 of 1" />
                    <div class="ms-pager">
                        <asp:Literal ID="litSellerPager" runat="server" />
                    </div>
                </div>
            </div>
        </div>

        <!-- History -->
        <div class="ms-table-card ad-table-card ad-table-card-muted">
            <div class="ms-table-toolbar">
                <div class="ms-table-toolbar-left">
                    <h3>Resolution history</h3>
                    <p><asp:Literal ID="litHistHint" runat="server" /></p>
                </div>
                <div class="ms-search-wrap" id="histSearchGroup">
                    <i class="fas fa-search"></i>
                    <input type="text" id="txtHistSearch" class="ms-search-input" placeholder="Search name, email, type, status..." autocomplete="off" />
                    <button type="button" class="ms-search-clear" onclick="clearAdSearch('txtHistSearch','historyTable','histEmptyState');" aria-label="Clear search">
                        <i class="fas fa-times"></i>
                    </button>
                </div>
            </div>

            <div class="ms-table-scroll">
                <asp:Repeater ID="rptHistory" runat="server">
                    <HeaderTemplate>
                        <table class="ad-table" id="historyTable">
                            <thead>
                                <tr>
                                    <th>TYPE</th>
                                    <th>PROFILE</th>
                                    <th>DATE</th>
                                    <th>RESOLUTION</th>
                                </tr>
                            </thead>
                            <tbody>
                    </HeaderTemplate>
                    <ItemTemplate>
                        <tr>
                            <td><%# FormatTypeBadge(Eval("EType")) %></td>
                            <td><%# FormatProfile(Eval("FullName"), Eval("Email"), "") %></td>
                            <td class="ad-td-muted"><%# FormatDate(Eval("EDate")) %></td>
                            <td><%# FormatHistStatusBadge(Eval("EStatus")) %></td>
                        </tr>
                    </ItemTemplate>
                    <FooterTemplate></tbody></table></FooterTemplate>
                </asp:Repeater>
            </div>

            <asp:Panel ID="pnlHistEmpty" runat="server" Visible="false" CssClass="ms-empty-state">
                <div class="ms-empty-ico ms-empty-muted"><i class="fas fa-folder-open"></i></div>
                <h4 class="ms-empty-title">No history yet</h4>
                <p class="ms-empty-desc">Resolved requests will appear here.</p>
            </asp:Panel>

            <div id="histEmptyState" class="ms-empty-state u-d-none" aria-live="polite">
                <div class="ms-empty-ico"><i class="fas fa-search"></i></div>
                <h4 class="ms-empty-title">No matches on this page</h4>
                <p class="ms-empty-desc">Nothing matches your search on this page.</p>
                <button type="button" class="ms-empty-btn" onclick="clearAdSearch('txtHistSearch','historyTable','histEmptyState');">
                    <i class="fas fa-times"></i> Clear search
                </button>
            </div>

            <div class="ms-table-foot">
                <div class="ms-table-foot-left">
                    <asp:Literal ID="litHistShowing" runat="server" Text="Showing 0 of 0" />
                </div>
                <div class="ms-table-foot-right">
                    <div class="ms-per-page">
                        <span>Per page</span>
                        <asp:DropDownList ID="ddlHistPageSize" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlHistPageSize_SelectedIndexChanged" ClientIDMode="Static">
                            <asp:ListItem Text="10" Value="10" Selected="True" />
                            <asp:ListItem Text="25" Value="25" />
                            <asp:ListItem Text="50" Value="50" />
                        </asp:DropDownList>
                    </div>
                    <asp:Literal ID="litHistPageInfo" runat="server" Text="Page 1 of 1" />
                    <div class="ms-pager">
                        <asp:Literal ID="litHistPager" runat="server" />
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script type="text/javascript">
        (function () {
            bindAdSearch('txtUserSearch', 'usersTable', 'userEmptyState');
            bindAdSearch('txtSellerSearch', 'sellersTable', 'sellerEmptyState');
            bindAdSearch('txtHistSearch', 'historyTable', 'histEmptyState');
        })();

        function bindAdSearch(inputId, tableId, emptyId) {
            var input = document.getElementById(inputId);
            if (!input) return;
            input.addEventListener('input', function () {
                filterAdTable(inputId, tableId, emptyId);
            });
        }

        function filterAdTable(inputId, tableId, emptyId) {
            var input = document.getElementById(inputId);
            var table = document.getElementById(tableId);
            var empty = document.getElementById(emptyId);
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

        function clearAdSearch(inputId, tableId, emptyId) {
            var input = document.getElementById(inputId);
            if (input) input.value = '';
            filterAdTable(inputId, tableId, emptyId);
        }
    </script>
</asp:Content>
