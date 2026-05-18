<%@ Page Title="Seller details" Language="C#" MasterPageFile="~/admin/Admin.Master" AutoEventWireup="true"
    CodeFile="SellerView.aspx.cs" Inherits="ecommerce_mlm.admin.SellerView" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="ms-page sv-page">
        <div class="ms-page-head">
            <div class="ms-page-head-left">
                <span class="ms-overline">MARKETPLACE</span>
                <h1 class="ms-title">Seller details</h1>
                <p class="ms-sub">Profile, catalog, orders, and account status for this seller.</p>
            </div>
            <div class="ms-page-head-actions">
                <a href="ManageSellers.aspx" class="ms-btn ms-btn-outline">Back to Seller list</a>
                <asp:HyperLink ID="hlKycAudit" runat="server" CssClass="ms-btn ms-btn-primary">KYC audit</asp:HyperLink>
            </div>
        </div>

        <div class="ms-kpi-grid">
            <div class="ms-kpi-card ms-kpi-blue">
                <div class="ms-kpi-body">
                    <label>SELLER</label>
                    <strong class="ms-kpi-text"><asp:Literal ID="litSellerName" runat="server" /></strong>
                    <span><asp:Literal ID="litSellerEmail" runat="server" /></span>
                </div>
                <div class="ms-kpi-ico"><i class="fas fa-user"></i></div>
            </div>
            <div class="ms-kpi-card ms-kpi-green">
                <div class="ms-kpi-body">
                    <label>PRODUCTS</label>
                    <strong><asp:Literal ID="litProductCount" runat="server" Text="0" /></strong>
                    <span><asp:Literal ID="litProductSplit" runat="server" /></span>
                </div>
                <div class="ms-kpi-ico"><i class="fas fa-box"></i></div>
            </div>
            <div class="ms-kpi-card ms-kpi-purple">
                <div class="ms-kpi-body">
                    <label>ORDERS</label>
                    <strong><asp:Literal ID="litOrderCount" runat="server" Text="0" /></strong>
                    <span><asp:Literal ID="litOrderRevenue" runat="server" /></span>
                </div>
                <div class="ms-kpi-ico"><i class="fas fa-shopping-cart"></i></div>
            </div>
            <div class="ms-kpi-card ms-kpi-indigo">
                <div class="ms-kpi-body">
                    <label>ACCOUNT</label>
                    <div class="ms-kpi-status-slot"><asp:Literal ID="litAccountStatus" runat="server" /></div>
                    <span><asp:Literal ID="litAccountCreated" runat="server" /></span>
                </div>
                <div class="ms-kpi-ico"><i class="fas fa-clock"></i></div>
            </div>
        </div>

        <div class="sv-kyc-card">
            <h3 class="sv-kyc-head">KYC &amp; Bank Details</h3>
            <div class="sv-kyc-status-grid">
                <div class="sv-kyc-mini">
                    <span class="sv-kyc-mini-lbl">KYC submission</span>
                    <asp:Literal ID="litKycSubmission" runat="server" />
                </div>
                <div class="sv-kyc-mini">
                    <span class="sv-kyc-mini-lbl">Final approval</span>
                    <asp:Literal ID="litFinalApproval" runat="server" />
                </div>
                <div class="sv-kyc-mini">
                    <span class="sv-kyc-mini-lbl">Last submitted</span>
                    <strong class="sv-kyc-mini-val"><asp:Literal ID="litLastSubmitted" runat="server" /></strong>
                </div>
                <div class="sv-kyc-mini">
                    <span class="sv-kyc-mini-lbl">Last final review</span>
                    <strong class="sv-kyc-mini-val"><asp:Literal ID="litLastFinalReview" runat="server" /></strong>
                </div>
            </div>

            <table class="sv-detail-table">
                <tbody>
                    <tr>
                        <th>BUSINESS DETAILS</th>
                        <td>
                            <div class="sv-detail-block">
                                <div><span class="sv-dt-lbl">Name</span> <asp:Literal ID="litBusinessName" runat="server" /></div>
                                <div><span class="sv-dt-lbl">GST</span> <asp:Literal ID="litGst" runat="server" /></div>
                                <div><span class="sv-dt-lbl">PAN</span> <asp:Literal ID="litPan" runat="server" /></div>
                                <div><span class="sv-dt-lbl">Aadhaar</span> <asp:Literal ID="litAadhaar" runat="server" /></div>
                            </div>
                        </td>
                    </tr>
                    <tr>
                        <th>UPLOADED DOCUMENTS</th>
                        <td>
                            <div class="sv-doc-row">
                                <asp:HyperLink ID="lnkGstDoc" runat="server" CssClass="sv-doc-btn" Visible="false" />
                                <asp:HyperLink ID="lnkPanDoc" runat="server" CssClass="sv-doc-btn" Visible="false" />
                                <asp:HyperLink ID="lnkAadhaarDoc" runat="server" CssClass="sv-doc-btn" Visible="false" />
                            </div>
                        </td>
                    </tr>
                    <tr>
                        <th>BANK DETAILS</th>
                        <td>
                            <div class="sv-detail-block">
                                <div><span class="sv-dt-lbl">Bank</span> <asp:Literal ID="litBankName" runat="server" /></div>
                                <div><span class="sv-dt-lbl">Holder</span> <asp:Literal ID="litBankHolder" runat="server" /></div>
                                <div><span class="sv-dt-lbl">Account</span> <asp:Literal ID="litBankAccount" runat="server" /></div>
                                <div><span class="sv-dt-lbl">IFSC</span> <asp:Literal ID="litBankIfsc" runat="server" /></div>
                            </div>
                        </td>
                    </tr>
                    <tr>
                        <th>ADDRESS &amp; PROOF</th>
                        <td>
                            <div class="sv-detail-block">
                                <div><span class="sv-dt-lbl">Address</span> <asp:Literal ID="litAddress" runat="server" /></div>
                                <div><span class="sv-dt-lbl">ID type</span> <asp:Literal ID="litIdType" runat="server" /></div>
                                <div><span class="sv-dt-lbl">ID number</span> <asp:Literal ID="litIdNumber" runat="server" /></div>
                            </div>
                        </td>
                    </tr>
                </tbody>
            </table>
        </div>

        <div class="ms-table-card sv-table-block">
            <div class="ms-table-toolbar">
                <div class="ms-table-toolbar-left">
                    <h3>Seller Products</h3>
                    <p><asp:Literal ID="litProdHint" runat="server" /></p>
                </div>
                <div class="ms-search-wrap" id="prodSearchGroup">
                    <i class="fas fa-search"></i>
                    <input type="text" id="txtProdSearch" class="ms-search-input" placeholder="Search products..." autocomplete="off" />
                    <button type="button" class="ms-search-clear" onclick="clearSvSearch('txtProdSearch','productsTable','prodEmptyState');" aria-label="Clear search">
                        <i class="fas fa-times"></i>
                    </button>
                </div>
            </div>

            <div class="ms-table-scroll">
                <asp:Repeater ID="rptProducts" runat="server">
                    <HeaderTemplate>
                        <table class="sv-data-table" id="productsTable">
                            <thead>
                                <tr>
                                    <th>PRODUCT</th>
                                    <th>CATEGORY</th>
                                    <th>PRICE</th>
                                    <th>STOCK</th>
                                    <th>STATUS</th>
                                    <th>CREATED</th>
                                </tr>
                            </thead>
                            <tbody>
                    </HeaderTemplate>
                    <ItemTemplate>
                        <tr>
                            <td><%# FormatProductName(Eval("Id"), Eval("Name")) %></td>
                            <td><%# FormatCategory(Eval("Category")) %></td>
                            <td><%# FormatRs(Eval("Price")) %></td>
                            <td><%# Eval("Stock") %></td>
                            <td><%# FormatProductStatus(Eval("IsActive")) %></td>
                            <td class="sv-td-muted"><%# FormatCreatedRow(Eval("CreatedAt")) %></td>
                        </tr>
                    </ItemTemplate>
                    <FooterTemplate></tbody></table></FooterTemplate>
                </asp:Repeater>
            </div>

            <asp:Panel ID="pnlProductsEmpty" runat="server" Visible="false" CssClass="ms-empty-state">
                <div class="ms-empty-ico ms-empty-muted"><i class="fas fa-box-open"></i></div>
                <h4 class="ms-empty-title">No products</h4>
                <p class="ms-empty-desc">This seller has not listed any products yet.</p>
            </asp:Panel>

            <div id="prodEmptyState" class="ms-empty-state u-d-none" aria-live="polite">
                <div class="ms-empty-ico"><i class="fas fa-search"></i></div>
                <h4 class="ms-empty-title">No matches on this page</h4>
                <p class="ms-empty-desc">Nothing matches your product search on this page.</p>
                <button type="button" class="ms-empty-btn" onclick="clearSvSearch('txtProdSearch','productsTable','prodEmptyState');">
                    <i class="fas fa-times"></i> Clear search
                </button>
            </div>

            <div class="ms-table-foot">
                <div class="ms-table-foot-left">
                    <asp:Literal ID="litProdShowing" runat="server" Text="Showing 0 of 0" />
                </div>
                <div class="ms-table-foot-right">
                    <div class="ms-per-page">
                        <span>Per page</span>
                        <asp:DropDownList ID="ddlProdPageSize" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlProdPageSize_SelectedIndexChanged" ClientIDMode="Static">
                            <asp:ListItem Text="10" Value="10" />
                            <asp:ListItem Text="25" Value="25" Selected="True" />
                            <asp:ListItem Text="50" Value="50" />
                            <asp:ListItem Text="100" Value="100" />
                        </asp:DropDownList>
                    </div>
                    <asp:Literal ID="litProdPageInfo" runat="server" Text="Page 1 of 1" />
                    <div class="ms-pager">
                        <asp:Literal ID="litProdPager" runat="server" />
                    </div>
                </div>
            </div>
        </div>

        <div class="ms-table-card sv-table-block">
            <div class="ms-table-toolbar">
                <div class="ms-table-toolbar-left">
                    <h3>Seller Orders</h3>
                    <p><asp:Literal ID="litOrderHint" runat="server" /></p>
                </div>
                <div class="ms-search-wrap" id="orderSearchGroup">
                    <i class="fas fa-search"></i>
                    <input type="text" id="txtOrderSearch" class="ms-search-input" placeholder="Search orders..." autocomplete="off" />
                    <button type="button" class="ms-search-clear" onclick="clearSvSearch('txtOrderSearch','ordersTable','orderEmptyState');" aria-label="Clear search">
                        <i class="fas fa-times"></i>
                    </button>
                </div>
            </div>

            <div class="ms-table-scroll">
                <asp:Repeater ID="rptOrders" runat="server">
                    <HeaderTemplate>
                        <table class="sv-data-table" id="ordersTable">
                            <thead>
                                <tr>
                                    <th>ORDER REF</th>
                                    <th>CUSTOMER</th>
                                    <th>EMAIL</th>
                                    <th>STATUS</th>
                                    <th>TOTAL</th>
                                    <th>ITEMS</th>
                                    <th>PAYMENT</th>
                                    <th>DATE</th>
                                </tr>
                            </thead>
                            <tbody>
                    </HeaderTemplate>
                    <ItemTemplate>
                        <tr>
                            <td><span class="sv-order-ref"><%# FormatOrderRef(Eval("OrderRef"), Eval("Id")) %></span></td>
                            <td><%# Eval("FullName") %></td>
                            <td class="sv-td-muted"><%# Eval("Email") %></td>
                            <td><%# FormatStatusBadge(Eval("Status")) %></td>
                            <td><%# FormatRs(Eval("TotalAmount")) %></td>
                            <td><%# FormatItems(Eval("SellerItems"), Eval("ItemCount")) %></td>
                            <td><%# FormatPayment(Eval("PaymentMode")) %></td>
                            <td class="sv-td-muted"><%# FormatCreatedRow(Eval("CreatedAt")) %></td>
                        </tr>
                    </ItemTemplate>
                    <FooterTemplate></tbody></table></FooterTemplate>
                </asp:Repeater>
            </div>

            <asp:Panel ID="pnlOrdersEmpty" runat="server" Visible="false" CssClass="ms-empty-state">
                <div class="ms-empty-ico ms-empty-muted"><i class="fas fa-receipt"></i></div>
                <h4 class="ms-empty-title">No orders</h4>
                <p class="ms-empty-desc">No store orders include this seller's products yet.</p>
            </asp:Panel>

            <div id="orderEmptyState" class="ms-empty-state u-d-none" aria-live="polite">
                <div class="ms-empty-ico"><i class="fas fa-search"></i></div>
                <h4 class="ms-empty-title">No matches on this page</h4>
                <p class="ms-empty-desc">Nothing matches your order search on this page.</p>
                <button type="button" class="ms-empty-btn" onclick="clearSvSearch('txtOrderSearch','ordersTable','orderEmptyState');">
                    <i class="fas fa-times"></i> Clear search
                </button>
            </div>

            <div class="ms-table-foot">
                <div class="ms-table-foot-left">
                    <asp:Literal ID="litOrderShowing" runat="server" Text="Showing 0 of 0" />
                </div>
                <div class="ms-table-foot-right">
                    <div class="ms-per-page">
                        <span>Per page</span>
                        <asp:DropDownList ID="ddlOrderPageSize" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlOrderPageSize_SelectedIndexChanged" ClientIDMode="Static">
                            <asp:ListItem Text="10" Value="10" />
                            <asp:ListItem Text="25" Value="25" Selected="True" />
                            <asp:ListItem Text="50" Value="50" />
                            <asp:ListItem Text="100" Value="100" />
                        </asp:DropDownList>
                    </div>
                    <asp:Literal ID="litOrderPageInfo" runat="server" Text="Page 1 of 1" />
                    <div class="ms-pager">
                        <asp:Literal ID="litOrderPager" runat="server" />
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script type="text/javascript">
        (function () {
            var prodInput = document.getElementById('txtProdSearch');
            var orderInput = document.getElementById('txtOrderSearch');
            if (prodInput) prodInput.addEventListener('input', function () { filterSvTable('txtProdSearch', 'productsTable', 'prodEmptyState'); });
            if (orderInput) orderInput.addEventListener('input', function () { filterSvTable('txtOrderSearch', 'ordersTable', 'orderEmptyState'); });
        })();

        function filterSvTable(inputId, tableId, emptyId) {
            var input = document.getElementById(inputId);
            var table = document.getElementById(tableId);
            var empty = document.getElementById(emptyId);
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

        function clearSvSearch(inputId, tableId, emptyId) {
            var input = document.getElementById(inputId);
            if (input) input.value = '';
            filterSvTable(inputId, tableId, emptyId);
        }
    </script>
</asp:Content>
