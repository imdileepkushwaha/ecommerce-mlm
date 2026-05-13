<%@ Page Title="Orders Management" Language="C#" MasterPageFile="~/admin/Admin.Master" AutoEventWireup="true"
    CodeFile="ManageOrders.aspx.cs" Inherits="ecommerce_mlm.admin.ManageOrders" %>

    <asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    </asp:Content>

    <asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
        <div class="u-mb-30 u-j-between u-a-center">
            <div>
                <h1 class="u-txt-lg">All Orders</h1>
                <p class="u-txt-subtitle u-mt-5">Track, monitor, and progress client fulfillment sequences.</p>
            </div>
            <div class="u-d-flex u-gap-10">
                <div class="u-search-group" id="searchGroup">
                    <input type="text" id="jsSearchInput" placeholder="Search order ID or buyer..."
                        onkeyup="filterOrdersTable()" class="u-search-box" />
                    <i class="fas fa-times u-search-clear" onclick="clearSearch()"></i>
                </div>
            </div>
        </div>

        <div class="table-card">
            <div class="table-header">
                <h3 class="u-page-title">Purchase Orders</h3>
                <asp:Label ID="lblCount" runat="server" CssClass="badge u-badge-count">Total: 0</asp:Label>
            </div>
            <div class="table-responsive">
                <asp:Repeater ID="rptOrders" runat="server" OnItemCommand="rptOrders_ItemCommand">
                    <HeaderTemplate>
                        <table class="admin-table">
                            <thead>
                                <tr>
                                    <th>TXN # / Time</th>
                                    <th>Consumer Profile</th>
                                    <th>Payment Mode</th>
                                    <th>Order Ref</th>
                                    <th>Total</th>
                                    <th>Status</th>
                                    <th>Action</th>
                                </tr>
                            </thead>
                            <tbody>
                    </HeaderTemplate>
                    <ItemTemplate>
                        <tr>
                            <td>
                                <span class="u-order-id">#<%# Eval("Id") %></span>
                                <div class="u-datetime-stack">
                                    <div class="u-d-main">
                                        <i class="far fa-calendar-check"></i> <%# Convert.ToDateTime(Eval("CreatedAt")).ToString("dd MMM, yyyy") %>
                                    </div>
                                    <div class="u-t-sub">
                                        <%# Convert.ToDateTime(Eval("CreatedAt")).ToString("hh:mm tt") %>
                                    </div>
                                </div>
                            </td>
                            <td>
                                <div class="u-bold-700 u-color-dark">
                                    <%# Eval("FullName") %>
                                </div>
                                <div class="u-txt-gray-sm">
                                    <%# Eval("Email") %>
                                </div>
                            </td>
                            <td>
                                <span class="badge badge-payment">
                                    <i class="fas fa-credit-card u-mr-5"></i>
                                    <%# Eval("PaymentMode") !=DBNull.Value ? Eval("PaymentMode") : "Standard" %>
                                </span>
                            </td>
                            <td>
                                <span class="u-txt-085 u-bold-700 u-color-brand">
                                    <%# Eval("OrderRef") !=DBNull.Value ? Eval("OrderRef") : "PENDING" %>
                                </span>
                            </td>
                            <td>
                                <div class="u-bold-800 u-color-dark" style="font-size:1.1rem;">
                                    ₹<%# Convert.ToDecimal(Eval("TotalAmount")).ToString("N0") %>
                                </div>
                                <div class="u-txt-gray-sm">
                                    <%# Eval("ItemCount") %> Unit(s)
                                </div>
                            </td>
                            <td>
                                <span class='badge <%# GetStatusClass(Eval("Status")) %>'>
                                    <%# Eval("Status") %>
                                </span>
                            </td>
                            <td class="u-w-auto">
                                <div class="u-d-flex u-gap-8">
                                    <!-- View Details placeholder -->
                                    <a href="#" class="action-btn-circle action-btn-view" title="Open Order Invoice">
                                        <i class="fas fa-eye"></i>
                                    </a>

                                    <!-- Quick Ship Action, visible if Pending -->
                                    <asp:LinkButton runat="server" CommandName="UpdateStatus"
                                        CommandArgument='<%# Eval("Id") + "|Shipped" %>'
                                        Visible='<%# Eval("Status").ToString().ToLower() == "pending" %>'
                                        CssClass="action-btn-circle action-btn-ship" ToolTip="Promote to Shipped">
                                        <i class="fas fa-truck"></i>
                                    </asp:LinkButton>

                                    <!-- Quick Deliver Action, visible if Shipped -->
                                    <asp:LinkButton runat="server" CommandName="UpdateStatus"
                                        CommandArgument='<%# Eval("Id") + "|Delivered" %>'
                                        Visible='<%# Eval("Status").ToString().ToLower() == "shipped" %>'
                                        CssClass="action-btn-circle action-btn-deliver" ToolTip="Complete as Delivered">
                                        <i class="fas fa-check-double"></i>
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

                <!-- Search Failover Rendering -->
                <div id="jsEmptyState" class="u-empty-state u-d-none">
                    <div style="padding:60px; text-align:center;">
                        <i class="fas fa-search-minus u-empty-icon" style="color:#cbd5e1; font-size:4rem;"></i>
                        <h3 class="u-color-dark u-mb-15">No Transactions Identified</h3>
                        <p class="u-txt-subtitle">Refine structural query parameters to isolate specified commerce
                            records.</p>
                    </div>
                </div>

                <asp:Panel ID="pnlEmpty" runat="server" Visible="false" CssClass="u-empty-state">
                    <i class="fas fa-receipt u-empty-icon"></i>
                    <h4>Zero transactional records logged within cycle window.</h4>
                </asp:Panel>
            </div>
        </div>

        <script type='text/javascript'>
            function filterOrdersTable() {
                const input = document.getElementById('jsSearchInput');
                const group = document.getElementById('searchGroup');
                const filter = input.value.toUpperCase();

                if (group) {
                    if (filter.length > 0) group.classList.add('has-val');
                    else group.classList.remove('has-val');
                }

                const tableEl = document.querySelector('.admin-table');
                const emptyEl = document.getElementById('jsEmptyState');
                const tbody = tableEl ? tableEl.querySelector('tbody') : null;

                if (!tbody || !tableEl) return;

                const rows = tbody.getElementsByTagName('tr');
                let visibleCount = 0;

                for (let i = 0; i < rows.length; i++) {
                    const rowText = rows[i].innerText.toUpperCase();
                    if (rowText.indexOf(filter) > -1) {
                        rows[i].classList.remove('u-d-none');
                        visibleCount++;
                    } else {
                        rows[i].classList.add('u-d-none');
                    }
                }

                if (visibleCount === 0) {
                    tableEl.classList.add('u-d-none');
                    if (emptyEl) emptyEl.classList.remove('u-d-none');
                } else {
                    tableEl.classList.remove('u-d-none');
                    if (emptyEl) emptyEl.classList.add('u-d-none');
                }

                const countBadge = document.getElementById('<%= lblCount.ClientID %>');
                if (countBadge) {
                    countBadge.innerText = 'Filtered: ' + visibleCount;
                }
            }

            function clearSearch() {
                const input = document.getElementById('jsSearchInput');
                if (input) {
                    input.value = '';
                    filterOrdersTable();
                    input.focus();
                }
            }
        </script>
    </asp:Content>