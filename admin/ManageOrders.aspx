<%@ Page Title="Orders" Language="C#" MasterPageFile="~/admin/Admin.Master" AutoEventWireup="true"
    CodeFile="ManageOrders.aspx.cs" Inherits="ecommerce_mlm.admin.ManageOrders" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <link rel="stylesheet" href="assets/css/admin-users.css?v=1.2" />
    <link rel="stylesheet" href="assets/css/admin-orders.css?v=1.1" />
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="mu-page">
        <span class="mu-overline">SHOP</span>
        <h1 class="mu-title">Orders</h1>
        <p class="mu-sub">Purchase orders across the store — newest first.</p>

        <asp:Panel ID="pnlFlash" runat="server" Visible="false" CssClass="mu-flash">
            <i runat="server" id="icoFlash" class="fas fa-check-circle"></i>
            <asp:Literal ID="litFlash" runat="server" />
        </asp:Panel>

        <div class="mu-kpi-grid">
            <div class="mu-kpi-card mu-kpi-blue">
                <div class="mu-kpi-body">
                    <label>ALL ORDERS</label>
                    <strong><asp:Literal ID="litAllOrders" runat="server" Text="0" /></strong>
                    <span>Store-wide total</span>
                </div>
                <div class="mu-kpi-ico"><i class="fas fa-receipt"></i></div>
            </div>
            <div class="mu-kpi-card mu-kpi-green">
                <div class="mu-kpi-body">
                    <label>NEEDS CONFIRM</label>
                    <strong><asp:Literal ID="litNeedsConfirm" runat="server" Text="0" /></strong>
                    <span>Processing — action required</span>
                </div>
                <div class="mu-kpi-ico"><i class="fas fa-clock"></i></div>
            </div>
            <div class="mu-kpi-card mu-kpi-purple">
                <div class="mu-kpi-body">
                    <label>IN TRANSIT</label>
                    <strong><asp:Literal ID="litInTransit" runat="server" Text="0" /></strong>
                    <span>Shipped / out for delivery</span>
                </div>
                <div class="mu-kpi-ico"><i class="fas fa-truck"></i></div>
            </div>
            <div class="mu-kpi-card mu-kpi-indigo">
                <div class="mu-kpi-body">
                    <label>DELIVERED</label>
                    <strong><asp:Literal ID="litDelivered" runat="server" Text="0" /></strong>
                    <span>Completed deliveries</span>
                </div>
                <div class="mu-kpi-ico"><i class="fas fa-check-circle"></i></div>
            </div>
        </div>

        <div class="mu-table-card">
            <div class="mu-table-toolbar">
                <div class="mu-table-toolbar-left">
                    <h3>Purchase Orders</h3>
                    <p><asp:Literal ID="litTableHint" runat="server" /></p>
                </div>
                <div class="mu-search-wrap" id="searchGroup">
                    <i class="fas fa-search"></i>
                    <input type="text" id="txtSearch" class="mu-search-input" placeholder="Search ref, customer, email, status, total..." autocomplete="off" />
                    <button type="button" class="mu-search-clear" onclick="clearSearch();" aria-label="Clear search">
                        <i class="fas fa-times"></i>
                    </button>
                </div>
            </div>

            <div class="mu-table-scroll">
                <asp:Repeater ID="rptOrders" runat="server">
                    <HeaderTemplate>
                        <table class="mo-orders-table" id="ordersTable">
                            <thead>
                                <tr>
                                    <th>Order Ref</th>
                                    <th>Customer</th>
                                    <th>Status</th>
                                    <th>Total</th>
                                    <th>Payment</th>
                                    <th>Shipping</th>
                                    <th>Date</th>
                                    <th class="mu-th-actions">Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                    </HeaderTemplate>
                    <ItemTemplate>
                        <tr class="mo-order-row">
                            <td><span class="mo-order-ref"><%# FormatOrderRef(Eval("OrderRef"), Eval("Id")) %></span></td>
                            <td>
                                <div class="mu-name-cell mo-customer-cell">
                                    <span class="mu-avatar"><%# GetInitials(Eval("FullName")) %></span>
                                    <div class="mo-customer-meta">
                                        <span class="mo-customer-name"><%# Eval("FullName") %></span>
                                        <span class="mo-customer-email"><%# Eval("Email") %></span>
                                    </div>
                                </div>
                            </td>
                            <td><%# FormatStatusBadge(Eval("Status")) %></td>
                            <td class="mo-total"><%# FormatTotal(Eval("TotalAmount")) %></td>
                            <td><%# FormatPayment(Eval("PaymentMode")) %></td>
                            <td><%# FormatShipping(Eval("ShipName"), Eval("StreetAddress"), Eval("City"), Eval("State"), Eval("ZipCode")) %></td>
                            <td class="mo-date"><%# FormatDate(Eval("CreatedAt")) %></td>
                            <td>
                                <div class="mu-actions">
                                    <a href='ViewOrder.aspx?id=<%# Eval("Id") %>' class="action-btn-circle action-btn-view" title="View order details">
                                        <svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" viewBox="0 0 24 24"><g fill="none" stroke="currentColor" stroke-width="1.5"><path stroke-linecap="round" d="M9 4.46A9.8 9.8 0 0 1 12 4c4.182 0 7.028 2.5 8.725 4.704C21.575 9.81 22 10.361 22 12c0 1.64-.425 2.191-1.275 3.296C19.028 17.5 16.182 20 12 20s-7.028-2.5-8.725-4.704C2.425 14.192 2 13.639 2 12c0-1.64.425-2.191 1.275-3.296A14.5 14.5 0 0 1 5 6.821"></path><path d="M15 12a3 3 0 1 1-6 0a3 3 0 0 1 6 0Z"></path></g></svg>
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

                <asp:Panel ID="pnlEmpty" runat="server" Visible="false" CssClass="mu-empty-state">
                    <div class="mu-empty-ico mu-empty-ico-muted"><i class="fas fa-receipt"></i></div>
                    <h4 class="mu-empty-title">No orders yet</h4>
                    <p class="mu-empty-desc">Customer purchases will appear here once checkout is complete.</p>
                </asp:Panel>

                <div id="jsEmptyState" class="mu-empty-state u-d-none" aria-live="polite">
                    <div class="mu-empty-ico"><i class="fas fa-search"></i></div>
                    <h4 class="mu-empty-title">No matches on this page</h4>
                    <p class="mu-empty-desc">Nothing matches <strong id="jsEmptyQuery"></strong>. Try another ref, customer, email, or status.</p>
                    <button type="button" class="mu-empty-btn" onclick="clearSearch();">
                        <i class="fas fa-times"></i> Clear search
                    </button>
                </div>
            </div>

            <div class="mu-table-foot">
                <div class="mu-table-foot-left">
                    <asp:Literal ID="litShowing" runat="server" Text="Showing 0 of 0" />
                </div>
                <div class="mu-table-foot-right">
                    <div class="mu-per-page">
                        <span>Per page</span>
                        <asp:DropDownList ID="ddlPageSize" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlPageSize_SelectedIndexChanged" ClientIDMode="Static">
                            <asp:ListItem Text="10" Value="10" Selected="True" />
                            <asp:ListItem Text="25" Value="25" />
                            <asp:ListItem Text="50" Value="50" />
                            <asp:ListItem Text="100" Value="100" />
                        </asp:DropDownList>
                    </div>
                    <asp:Literal ID="litPageInfo" runat="server" Text="Page 1 of 1" />
                    <div class="mo-pager">
                        <asp:Literal ID="litPager" runat="server" />
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script type="text/javascript">
        (function () {
            var input = document.getElementById('txtSearch');
            if (!input) return;
            input.addEventListener('input', filterOrdersTable);
        })();

        function filterOrdersTable() {
            var input = document.getElementById('txtSearch');
            var group = document.getElementById('searchGroup');
            var table = document.getElementById('ordersTable');
            var emptyEl = document.getElementById('jsEmptyState');
            if (!input || !table) return;

            var filter = input.value.toUpperCase();
            if (group) {
                if (filter.length > 0) group.classList.add('has-val');
                else group.classList.remove('has-val');
            }

            var tbody = table.querySelector('tbody');
            if (!tbody) return;

            var rows = tbody.querySelectorAll('.mo-order-row');
            var visible = 0;
            for (var i = 0; i < rows.length; i++) {
                if (rows[i].innerText.toUpperCase().indexOf(filter) > -1) {
                    rows[i].style.display = '';
                    visible++;
                } else {
                    rows[i].style.display = 'none';
                }
            }

            var queryEl = document.getElementById('jsEmptyQuery');
            if (queryEl) queryEl.textContent = input.value ? '"' + input.value + '"' : 'your search';

            if (visible === 0 && rows.length > 0) {
                table.style.display = 'none';
                if (emptyEl) emptyEl.classList.remove('u-d-none');
            } else {
                table.style.display = '';
                if (emptyEl) emptyEl.classList.add('u-d-none');
            }
        }

        function clearSearch() {
            var input = document.getElementById('txtSearch');
            if (input) {
                input.value = '';
                filterOrdersTable();
                input.focus();
            }
        }
    </script>
</asp:Content>
