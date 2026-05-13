<%@ Page Title="Catalog Inventory" Language="C#" MasterPageFile="~/admin/Admin.Master" AutoEventWireup="true" CodeFile="ManageProducts.aspx.cs" Inherits="ecommerce_mlm.admin.ManageProducts" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        .prod-img-thumb { width: 50px; height: 50px; object-fit: cover; border-radius: 12px; border: 2px solid #ffffff; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05); }
        .prod-price { font-weight: 800; color: #0f172a; font-size: 1rem; }
        .prod-mrp { text-decoration: line-through; color: #94a3b8; font-size: 0.8rem; margin-left: 5px; }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="u-mb-30 u-d-flex u-j-between u-a-center">

        <div>
            <h1 class="u-txt-lg">Inventory Control</h1>
            <p class="u-txt-subtitle u-mt-5">Govern published merchandise assets across infrastructure.</p>
        </div>
        <div class="u-d-flex u-gap-10">
            <div class="u-search-group" id="searchGroup">
                <input type="text" id="jsSearchInput" placeholder="Search product name, brand..." onkeyup="filterProductsTable()" class="u-search-box" />
                <i class="fas fa-times u-search-clear" onclick="clearSearch()"></i>
            </div>
        </div>
    </div>

    <div class="table-card">
        <div class="table-header">
            <h3 class="u-page-title">Inventory Grid</h3>
            <asp:Label ID="lblCount" runat="server" CssClass="badge u-badge-count">Total: 0</asp:Label>
        </div>
        <div class="table-responsive">
            <asp:Repeater ID="rptProducts" runat="server" OnItemCommand="rptProducts_ItemCommand">
                <HeaderTemplate>
                    <table class="admin-table">
                        <thead>
                            <tr>
                                <th>Product Data</th>
                                <th>Category</th>
                                <th>Financials</th>
                                <th>Volume/Stock</th>
                                <th>Status</th>
                                <th>Operations</th>
                            </tr>
                        </thead>
                        <tbody>
                </HeaderTemplate>
                <ItemTemplate>
                    <tr>
                        <td>
                            <div class="u-d-flex u-a-center u-gap-12">
                                <img src='<%# ResolveUrl(!string.IsNullOrEmpty(Eval("MainImage").ToString()) ? Eval("MainImage").ToString() : "~/assets/images/no-product.png") %>' class="prod-img-thumb" />
                                <div>
                                    <div class="u-bold-700 u-color-dark"><%# Eval("Name") %></div>
                                    <div class="u-txt-gray-sm">Brand: <%# Eval("Brand") %></div>
                                </div>
                            </div>
                        </td>
                        <td>
                            <span class="u-mono-block u-txt-085">
                                <%# Eval("Category") %>
                            </span>
                        </td>
                        <td>
                            <span class="prod-price">₹<%# Convert.ToDecimal(Eval("Price")).ToString("N0") %></span>
                            <span class="prod-mrp">₹<%# Convert.ToDecimal(Eval("Mrp")).ToString("N0") %></span>
                        </td>
                        <td>
                            <span class='badge badge-stock'>
                                <%# Eval("Stock") %> units
                            </span>
                        </td>
                        <td>
                            <span class='badge <%# Convert.ToBoolean(Eval("IsActive")) ? "badge-success" : "badge-danger" %>'>
                                <%# Convert.ToBoolean(Eval("IsActive")) ? "Approved" : "Pending" %>
                            </span>
                        </td>
                        <td>

                            <div class="u-d-flex u-gap-8">
                                <a href='../ProductDetails.aspx?slug=<%# Eval("Slug") %>' target="_blank" class="action-btn-circle action-btn-view" title="View Product">
                                    <i class="fas fa-external-link-alt"></i>
                                </a>
                                
                                <asp:LinkButton ID="btnToggleStatus" runat="server" CommandName="ToggleStatus" CommandArgument='<%# Eval("Id") %>' 
                                    CssClass='<%# Convert.ToBoolean(Eval("IsActive")) ? "action-btn-circle action-btn-block" : "action-btn-circle action-btn-unblock" %>'
                                    ToolTip='<%# Convert.ToBoolean(Eval("IsActive")) ? "Suspend Listing" : "Approve Product" %>'>
                                    <i class='<%# Convert.ToBoolean(Eval("IsActive")) ? "fas fa-ban" : "fas fa-check-circle" %>'></i>
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
            
            <!-- Bulletproof Client-Side Empty State Indicator -->
            <div id="jsEmptyState" class="u-empty-state u-d-none">
                <div style="padding:60px; text-align:center;">
                    <i class="fas fa-box-open u-empty-icon" style="color:#cbd5e1; font-size:4rem;"></i>
                    <h3 class="u-color-dark u-mb-15">No Match Records</h3>
                    <p class="u-txt-subtitle">Re-calibrate search vector to access matching catalog metadata.</p>
                </div>
            </div>

            <asp:Panel ID="pnlEmpty" runat="server" Visible="false" CssClass="u-empty-state">
                <i class="fas fa-boxes u-empty-icon"></i>
                <h4>Zero asset nodes registered within operational grid.</h4>
            </asp:Panel>
        </div>
    </div>

    <script type='text/javascript'>
        function filterProductsTable() {
            const input = document.getElementById('jsSearchInput');
            const group = document.getElementById('searchGroup');
            const filter = input.value.toUpperCase();
            
            if(group) {
                if(filter.length > 0) group.classList.add('has-val');
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
                if(emptyEl) emptyEl.classList.remove('u-d-none');
            } else {
                tableEl.classList.remove('u-d-none');
                if(emptyEl) emptyEl.classList.add('u-d-none');
            }
            
            const countBadge = document.getElementById('<%= lblCount.ClientID %>');
            if (countBadge) {
                countBadge.innerText = 'Refined: ' + visibleCount;
            }
        }

        function clearSearch() {
            const input = document.getElementById('jsSearchInput');
            if(input) {
                input.value = '';
                filterProductsTable();
                input.focus();
            }
        }
    </script>
</asp:Content>
