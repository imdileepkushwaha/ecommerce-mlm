<%@ Page Title="Product approvals" Language="C#" MasterPageFile="~/admin/Admin.Master" AutoEventWireup="true"
    CodeFile="ManageProducts.aspx.cs" Inherits="ecommerce_mlm.admin.ManageProducts" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="ms-page mp-page">
        <div class="ms-page-head">
            <div class="ms-page-head-left">
                <span class="ms-overline">CATALOG</span>
                <h1 class="ms-title">Product approvals</h1>
                <p class="ms-sub">Review seller submissions before they appear in the shop catalog.</p>
            </div>
            <div class="ms-page-head-actions">
                <a href="ManageSellers.aspx" class="ms-btn ms-btn-outline">Sellers</a>
            </div>
        </div>

        <asp:Panel ID="pnlFlash" runat="server" Visible="false" CssClass="ms-flash">
            <i runat="server" id="icoFlash" class="fas fa-check-circle"></i>
            <asp:Literal ID="litFlash" runat="server" />
        </asp:Panel>

        <div class="ms-kpi-grid">
            <div class="ms-kpi-card ms-kpi-red">
                <div class="ms-kpi-body">
                    <label>PENDING</label>
                    <strong><asp:Literal ID="litKpiPending" runat="server" Text="0" /></strong>
                    <span>Needs review</span>
                </div>
                <div class="ms-kpi-ico"><i class="fas fa-clock"></i></div>
            </div>
            <div class="ms-kpi-card ms-kpi-red">
                <div class="ms-kpi-body">
                    <label>REJECTED</label>
                    <strong><asp:Literal ID="litKpiRejected" runat="server" Text="0" /></strong>
                    <span>Can be edited &amp; resubmitted</span>
                </div>
                <div class="ms-kpi-ico"><i class="fas fa-times"></i></div>
            </div>
            <div class="ms-kpi-card ms-kpi-green">
                <div class="ms-kpi-body">
                    <label>APPROVED</label>
                    <strong><asp:Literal ID="litKpiApproved" runat="server" Text="0" /></strong>
                    <span>Live in shop catalog</span>
                </div>
                <div class="ms-kpi-ico"><i class="fas fa-check"></i></div>
            </div>
            <div class="ms-kpi-card ms-kpi-purple">
                <div class="ms-kpi-body">
                    <label>THIS LIST</label>
                    <strong><asp:Literal ID="litKpiThisList" runat="server" Text="0" /></strong>
                    <span><asp:Literal ID="litKpiListSub" runat="server" Text="Showing 0 of 0" /></span>
                </div>
                <div class="ms-kpi-ico"><i class="fas fa-list"></i></div>
            </div>
        </div>

        <div class="mp-tabs" role="tablist">
            <asp:HyperLink ID="hlTabPending" runat="server" CssClass="mp-tab">
                <span class="mp-tab-label">Pending</span>
                <span class="mp-tab-count"><asp:Literal ID="litTabPending" runat="server" Text="0" /></span>
            </asp:HyperLink>
            <asp:HyperLink ID="hlTabRejected" runat="server" CssClass="mp-tab">
                <span class="mp-tab-label">Rejected</span>
                <span class="mp-tab-count"><asp:Literal ID="litTabRejected" runat="server" Text="0" /></span>
            </asp:HyperLink>
            <asp:HyperLink ID="hlTabApproved" runat="server" CssClass="mp-tab">
                <span class="mp-tab-label">Recently approved</span>
                <span class="mp-tab-count"><asp:Literal ID="litTabApproved" runat="server" Text="0" /></span>
            </asp:HyperLink>
            <asp:HyperLink ID="hlTabSuspended" runat="server" CssClass="mp-tab">
                <span class="mp-tab-label">Suspended</span>
                <span class="mp-tab-count"><asp:Literal ID="litTabSuspended" runat="server" Text="0" /></span>
            </asp:HyperLink>
        </div>

        <div class="ms-table-card">
            <div class="ms-table-toolbar">
                <div class="ms-table-toolbar-left">
                    <h3><asp:Literal ID="litTableTitle" runat="server" Text="Recently approved" /></h3>
                    <p><asp:Literal ID="litTableHint" runat="server" /></p>
                </div>
                <div class="ms-search-wrap" id="searchGroup">
                    <i class="fas fa-search"></i>
                    <input type="text" id="txtSearch" class="ms-search-input" placeholder="Search name, SKU, seller, category..." autocomplete="off" />
                    <button type="button" class="ms-search-clear" onclick="clearProductSearch();" aria-label="Clear search">
                        <i class="fas fa-times"></i>
                    </button>
                </div>
            </div>

            <div class="ms-table-scroll">
                <asp:Repeater ID="rptProducts" runat="server" OnItemCommand="rptProducts_ItemCommand">
                    <HeaderTemplate>
                        <table class="mp-products-table" id="productsTable">
                            <thead>
                                <tr>
                                    <th>PRODUCT</th>
                                    <th>SELLER</th>
                                    <th>CATEGORY</th>
                                    <th>PRICE</th>
                                    <th>STATUS</th>
                                    <th>ADDED</th>
                                    <th class="ms-th-actions">ACTIONS</th>
                                </tr>
                            </thead>
                            <tbody>
                    </HeaderTemplate>
                    <ItemTemplate>
                        <tr>
                            <td><%# FormatProductCell(Eval("Id"), Eval("Name"), Eval("Slug"), Eval("Sku"), Eval("MainImage")) %></td>
                            <td><%# FormatSellerCell(Eval("SellerId"), Eval("SellerName"), Eval("SellerEmail"), Eval("StoreName")) %></td>
                            <td><%# FormatCategoryPill(Eval("Category")) %></td>
                            <td><%# FormatPriceCell(Eval("Price"), Eval("Mrp")) %></td>
                            <td><%# FormatStatusBadge(Eval("ListingStatus"), Eval("IsActive")) %></td>
                            <td class="mp-td-muted"><%# FormatAdded(Eval("CreatedAt")) %></td>
                            <td>
                                <div class="mp-actions">
                                    <asp:PlaceHolder runat="server" Visible='<%# ShowPendingActions() %>'>
                                        <asp:LinkButton runat="server" CommandName="ApproveProduct" CommandArgument='<%# Eval("Id") %>'
                                            CssClass="mp-btn mp-btn-approve" ToolTip="Approve listing"
                                            OnClientClick="return confirm('Approve this product for the shop catalog?');">
                                            <i class="fas fa-check"></i> 
                                        </asp:LinkButton>
                                        <asp:LinkButton runat="server" CommandName="RejectProduct" CommandArgument='<%# Eval("Id") %>'
                                            CssClass="mp-btn mp-btn-reject" ToolTip="Reject listing"
                                            OnClientClick="return confirm('Reject this product? The seller can edit and resubmit.');">
                                            <i class="fas fa-times"></i> 
                                        </asp:LinkButton>
                                    </asp:PlaceHolder>
                                    <asp:PlaceHolder runat="server" Visible='<%# ShowApprovedActions() %>'>
                                        <asp:LinkButton runat="server" CommandName="SuspendProduct" CommandArgument='<%# Eval("Id") %>'
                                            CssClass="mp-btn mp-btn-suspend" ToolTip="Suspend listing"
                                            OnClientClick="return confirm('Suspend this product? It will be hidden from the shop until reactivated.');">
                                            <i class="fas fa-ban"></i> 
                                        </asp:LinkButton>
                                    </asp:PlaceHolder>
                                    <asp:PlaceHolder runat="server" Visible='<%# ShowSuspendedActions() %>'>
                                        <asp:LinkButton runat="server" CommandName="ReactivateProduct" CommandArgument='<%# Eval("Id") %>'
                                            CssClass="mp-btn mp-btn-approve" ToolTip="Reactivate listing"
                                            OnClientClick="return confirm('Reactivate this product in the shop catalog?');">
                                            <i class="fas fa-check-circle"></i> 
                                        </asp:LinkButton>
                                    </asp:PlaceHolder>
                                    <a href='<%# GetViewUrl(Eval("Slug")) %>' target="_blank" class="mp-btn mp-btn-view" title="View product">
                                        <i class="fas fa-eye"></i>
                                    </a>

                                    
                                </div>
                            </td>
                        </tr>
                    </ItemTemplate>
                    <FooterTemplate></tbody></table></FooterTemplate>
                </asp:Repeater>
            </div>

            <asp:Panel ID="pnlEmpty" runat="server" Visible="false" CssClass="ms-empty-state">
                <div class="ms-empty-ico ms-empty-muted"><i class="fas fa-box-open"></i></div>
                <h4 class="ms-empty-title"><asp:Literal ID="litEmptyTitle" runat="server" Text="No products" /></h4>
                <p class="ms-empty-desc"><asp:Literal ID="litEmptyDesc" runat="server" /></p>
            </asp:Panel>

            <div id="jsEmptyState" class="ms-empty-state u-d-none" aria-live="polite">
                <div class="ms-empty-ico"><i class="fas fa-search"></i></div>
                <h4 class="ms-empty-title">No matches on this page</h4>
                <p class="ms-empty-desc">Nothing matches your search on this page.</p>
                <button type="button" class="ms-empty-btn" onclick="clearProductSearch();">
                    <i class="fas fa-times"></i> Clear search
                </button>
            </div>

            <div class="ms-table-foot">
                <div class="ms-table-foot-left">
                    <asp:Literal ID="litShowing" runat="server" Text="Showing 0 of 0" />
                </div>
                <div class="ms-table-foot-right">
                    <div class="ms-per-page">
                        <span>Per page</span>
                        <asp:DropDownList ID="ddlPageSize" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlPageSize_SelectedIndexChanged" ClientIDMode="Static">
                            <asp:ListItem Text="10" Value="10" />
                            <asp:ListItem Text="25" Value="25" Selected="True" />
                            <asp:ListItem Text="50" Value="50" />
                            <asp:ListItem Text="100" Value="100" />
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

    <script type="text/javascript">
        (function () {
            var input = document.getElementById('txtSearch');
            if (input) input.addEventListener('input', filterProductsTable);
        })();

        function filterProductsTable() {
            var input = document.getElementById('txtSearch');
            var table = document.getElementById('productsTable');
            var empty = document.getElementById('jsEmptyState');
            if (!input || !table) return;
            var q = (input.value || '').toLowerCase().trim();
            var rows = table.querySelectorAll('tbody tr');
            var visible = 0;
            for (var i = 0; i < rows.length; i++) {
                var text = (rows[i].textContent || '').toLowerCase();
                var show = !q || text.indexOf(q) !== -1;
                rows[i].style.display = show ? '' : 'none';
                if (show) visible++;
            }
            if (empty) empty.classList.toggle('u-d-none', visible > 0 || rows.length === 0);
            var wrap = table.closest('.ms-table-scroll');
            if (wrap) wrap.style.display = (visible === 0 && rows.length > 0) ? 'none' : '';
        }

        function clearProductSearch() {
            var input = document.getElementById('txtSearch');
            if (input) input.value = '';
            filterProductsTable();
        }
    </script>
</asp:Content>
