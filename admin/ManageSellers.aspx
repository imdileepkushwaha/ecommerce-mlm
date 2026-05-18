<%@ Page Title="Sellers" Language="C#" MasterPageFile="~/admin/Admin.Master" AutoEventWireup="true"
    CodeFile="ManageSellers.aspx.cs" Inherits="ecommerce_mlm.admin.ManageSellers" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="ms-page">
        <div class="ms-page-head">
            <div class="ms-page-head-left">
                <span class="ms-overline">MARKETPLACE</span>
                <h1 class="ms-title">Sellers</h1>
                <p class="ms-sub">Registered seller accounts, catalog activity, and moderation actions.</p>
            </div>
            <div class="ms-page-head-actions">
                <a href="ManageProducts.aspx" class="ms-btn ms-btn-outline">Product approvals</a>
                <a href="KycAudits.aspx" class="ms-btn ms-btn-primary">Review KYC</a>
            </div>
        </div>

        <asp:Panel ID="pnlFlash" runat="server" Visible="false" CssClass="ms-flash">
            <i runat="server" id="icoFlash" class="fas fa-check-circle"></i>
            <asp:Literal ID="litFlash" runat="server" />
        </asp:Panel>

        <div class="ms-kpi-grid">
            <div class="ms-kpi-card ms-kpi-green">
                <div class="ms-kpi-body">
                    <label>ACTIVE</label>
                    <strong><asp:Literal ID="litActive" runat="server" Text="0" /></strong>
                    <span>Can list products</span>
                </div>
                <div class="ms-kpi-ico"><i class="fas fa-users"></i></div>
            </div>
            <div class="ms-kpi-card ms-kpi-blue">
                <div class="ms-kpi-body">
                    <label>NEW TODAY</label>
                    <strong><asp:Literal ID="litNewToday" runat="server" Text="0" /></strong>
                    <span>Joined today (<asp:Literal ID="litKycDate" runat="server" />)</span>
                </div>
                <div class="ms-kpi-ico"><i class="fas fa-user-plus"></i></div>
            </div>
            <div class="ms-kpi-card ms-kpi-red">
                <div class="ms-kpi-body">
                    <label>INACTIVE</label>
                    <strong><asp:Literal ID="litInactive" runat="server" Text="0" /></strong>
                    <span>Flagged off</span>
                </div>
                <div class="ms-kpi-ico"><i class="fas fa-user-slash"></i></div>
            </div>
            <div class="ms-kpi-card ms-kpi-orange">
                <div class="ms-kpi-body">
                    <label>PENDING KYC</label>
                    <strong><asp:Literal ID="litPendingKyc" runat="server" Text="0" /></strong>
                    <span>Awaiting registration review</span>
                </div>
                <div class="ms-kpi-ico"><i class="fas fa-file-alt"></i></div>
            </div>
        </div>

        <div class="ms-table-card">
            <div class="ms-table-toolbar">
                <div class="ms-table-toolbar-left">
                    <h3>All Sellers</h3>
                    <p><asp:Literal ID="litTableHint" runat="server" /></p>
                </div>
                <div class="ms-toolbar-right">
                    <div class="ms-search-wrap" id="searchGroup">
                        <i class="fas fa-search"></i>
                        <input type="text" id="txtSearch" class="ms-search-input" placeholder="Search name, email, ID, categories..." autocomplete="off" />
                        <button type="button" class="ms-search-clear" onclick="clearSearch();" aria-label="Clear search">
                            <i class="fas fa-times"></i>
                        </button>
                    </div>
                    <div class="ms-view-toggle" role="group" aria-label="View mode">
                        <button type="button" class="ms-view-btn active" id="btnViewList" onclick="setSellerView('list');" title="List view">
                            <i class="fas fa-list"></i>
                        </button>
                        <button type="button" class="ms-view-btn" id="btnViewGrid" onclick="setSellerView('grid');" title="Grid view">
                            <i class="fas fa-th-large"></i>
                        </button>
                    </div>
                </div>
            </div>

            <div class="ms-table-scroll" id="sellerListView">
                <asp:Repeater ID="rptSellers" runat="server" OnItemCommand="rptSellers_ItemCommand">
                    <HeaderTemplate>
                        <table class="ms-sellers-table" id="sellersTable">
                            <thead>
                                <tr>
                                    <!-- <th>ID</th> -->
                                    <th>Seller</th>
                                    <th>Contact</th>
                                    <th>Categories</th>
                                    <th>Stock </th>
                                    <th>Sells</th>
                                    <th>Clients</th>
                                    <th>Revenue</th>
                                    <th>Status</th>
                                    <th>Created</th>
                                    <th class="ms-th-actions">Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                    </HeaderTemplate>
                    <ItemTemplate>
                        <tr class='<%# GetRowClass(Eval("IsActive"), Eval("DeletionStatus")) %>'>
                            <!-- <td><span class="ms-seller-id">#<%# Eval("Id") %></span></td> -->
                            <td>
                                <div class="ms-seller-cell">
                                    <span class="ms-avatar"><%# GetInitials(Eval("FullName")) %></span>
                                    <span class="ms-seller-name"><%# Eval("FullName") %></span>
                                </div>
                            </td>
                           
                            <td><%# FormatContact(Eval("Email"), Eval("Phone")) %></td>
                            <td><%# FormatCategories(Eval("RequestedCategories")) %></td>
                            <td><%# FormatMetric(Eval("TotalStock")) %></td>
                            <td><%# FormatMetric(Eval("TotalSells")) %></td>
                            <td><%# FormatMetric(Eval("TotalClients")) %></td>
                            <td class="ms-revenue"><%# FormatRevenue(Eval("TotalRevenue")) %></td>
                            <td><%# FormatStatusBadge(Eval("IsActive"), Eval("DeletionStatus")) %></td>
                            
                            <td class="ms-created"><%# FormatCreated(Eval("CreatedAt")) %></td>
                            <td>
                                <div class="ms-actions">
                                    <a href='SellerView.aspx?id=<%# Eval("Id") %>' class="action-btn-circle action-btn-view" title="View seller profile">
                                        <svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" viewBox="0 0 24 24"><g fill="none" stroke="currentColor" stroke-width="1.5"><path stroke-linecap="round" d="M9 4.46A9.8 9.8 0 0 1 12 4c4.182 0 7.028 2.5 8.725 4.704C21.575 9.81 22 10.361 22 12c0 1.64-.425 2.191-1.275 3.296C19.028 17.5 16.182 20 12 20s-7.028-2.5-8.725-4.704C2.425 14.192 2 13.639 2 12c0-1.64.425-2.191 1.275-3.296A14.5 14.5 0 0 1 5 6.821"></path><path d="M15 12a3 3 0 1 1-6 0a3 3 0 0 1 6 0Z"></path></g></svg>
                                    </a>
                                    <asp:LinkButton runat="server" Visible='<%# ShowDeleteButton(Eval("Id"), Eval("FullName"), Eval("StoreName"), Eval("DeletionStatus")) %>'
                                        CssClass="action-btn-circle action-btn-delete js-ms-delete"
                                        data-seller-id='<%# Eval("Id") %>'
                                        data-seller-name='<%# AttrEnc(Eval("FullName")) %>'
                                        data-store-name='<%# AttrEnc(Eval("StoreName")) %>'
                                        ToolTip="Delete seller account"
                                        OnClientClick="return msOpenDeleteModal(this);">
                                        <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" aria-hidden="true" focusable="false"><path fill="none" stroke="currentColor" stroke-linecap="round" stroke-width="1.5" d="M20.5 6h-17m5.67-2a3.001 3.001 0 0 1 5.66 0m3.544 11.4c-.177 2.654-.266 3.981-1.131 4.79s-2.195.81-4.856.81h-.774c-2.66 0-3.99 0-4.856-.81c-.865-.809-.953-2.136-1.13-4.79l-.46-6.9m13.666 0l-.2 3"></path></svg>
                                    </asp:LinkButton>

                                    <div class="ms-access-cell">
                                        <asp:Panel runat="server" Visible='<%# CanToggleAccess(Eval("IsActive"), Eval("DeletionStatus")) %>'>
                                            <asp:LinkButton runat="server" CommandName="ToggleStatus" CommandArgument='<%# Eval("Id") %>'
                                                CssClass='<%# Convert.ToBoolean(Eval("IsActive")) ? "action-btn-circle action-btn-block" : "action-btn-circle action-btn-unblock" %>'
                                                ToolTip='<%# Convert.ToBoolean(Eval("IsActive")) ? "Suspend account" : "Reinstate account" %>'
                                                OnClientClick='<%# Convert.ToBoolean(Eval("IsActive")) ? "return confirm(\"Suspend this seller? They will not be able to sign in or list products.\");" : "return confirm(\"Reactivate this seller account?\");" %>'>
                                                <i class='fas <%# Convert.ToBoolean(Eval("IsActive")) ? "fa-user-slash" : "fa-user-check" %>'></i>
                                            </asp:LinkButton>
                                        </asp:Panel>
                                        <asp:Panel runat="server" Visible='<%# !CanToggleAccess(Eval("IsActive"), Eval("DeletionStatus")) %>'>
                                            <span class="action-btn-circle is-locked" title="Access locked"><i class="fas fa-ban"></i></span>
                                        </asp:Panel>
                                    </div>

                                </div>
                                
                            </td>
                        </tr>
                    </ItemTemplate>
                    <FooterTemplate>
                            </tbody>
                        </table>
                    </FooterTemplate>
                </asp:Repeater>
            </div>

            <div class="ms-grid-wrap u-d-none" id="sellerGridView">
                <asp:Repeater ID="rptSellersGrid" runat="server" OnItemCommand="rptSellers_ItemCommand">
                    <HeaderTemplate><div class="ms-sellers-grid"></HeaderTemplate>
                    <ItemTemplate>
                        <div class='<%# GetGridCardClass(Eval("IsActive"), Eval("DeletionStatus")) %>'>
                            <div class='<%# GetHeroClass(Eval("BannerPath"), Eval("Id")) %>'>
                                <%# FormatHeroBackground(Eval("BannerPath")) %>
                                <%# FormatGridHeroBadge(Eval("IsActive"), Eval("DeletionStatus")) %>
                            </div>
                            <div class="ms-gc-avatar-wrap">
                                <%# FormatGridAvatar(Eval("LogoPath"), Eval("FullName")) %>
                            </div>
                            <div class="ms-gc-body">
                                <h3 class="ms-gc-name"><%# Eval("FullName") %></h3>
                                <div class="ms-gc-tags"><%# FormatCategoryTags(Eval("RequestedCategories")) %></div>
                                <p class="ms-gc-email-top"><%# Eval("Email") %></p>
                                <%# FormatGridRating(Eval("AvgRating"), Eval("ReviewCount")) %>
                                <div class="ms-gc-contact">
                                    <div class="ms-gc-contact-row">
                                        <i class="fas fa-map-marker-alt"></i>
                                        <span><%# FormatGridAddress(Eval("Address"), Eval("City"), Eval("State"), Eval("Pincode")) %></span>
                                    </div>
                                    <div class="ms-gc-contact-row">
                                        <i class="fas fa-envelope"></i>
                                        <span><%# Eval("Email") %></span>
                                    </div>
                                    <div class="ms-gc-contact-row">
                                        <i class="fas fa-phone"></i>
                                        <span><%# FormatGridPhone(Eval("Phone")) %></span>
                                    </div>
                                </div>
                                <div class="ms-gc-perf">
                                    <div class="ms-gc-perf-head">
                                        <span><%# GetPrimaryCategory(Eval("RequestedCategories")) %></span>
                                        <span class="ms-gc-rev-up"><%# FormatRevenue(Eval("TotalRevenue")) %> <i class="fas fa-arrow-up"></i></span>
                                    </div>
                                    <div class="ms-gc-bar"><span style='width:<%# GetProgressPercent(Eval("TotalRevenue"), Eval("TotalSells")) %>%'></span></div>
                                    <div class="ms-gc-stats-row">
                                        <div><strong><%# Eval("TotalStock") %></strong><span>Item Stock</span></div>
                                        <div><strong><%# Eval("TotalSells") %></strong><span>Sells</span></div>
                                        <div><strong><%# Eval("TotalClients") %></strong><span>Happy Client</span></div>
                                    </div>
                                </div>
                                <div class="ms-gc-actions">
                                    <a href='SellerView.aspx?id=<%# Eval("Id") %>' class="ms-gc-btn ms-gc-btn-view">View Profile</a>
                                    <a href='ViewSellerKyc.aspx?id=<%# Eval("Id") %>' class="ms-gc-btn ms-gc-btn-kyc">KYC</a>
                                    <asp:Panel runat="server" Visible='<%# ShowGridDisabledPill(Eval("IsActive"), Eval("DeletionStatus")) %>' CssClass="ms-gc-access-wrap">
                                        <asp:LinkButton runat="server" Visible='<%# CanToggleAccess(Eval("IsActive"), Eval("DeletionStatus")) %>'
                                            CommandName="ToggleStatus" CommandArgument='<%# Eval("Id") %>'
                                            CssClass="ms-gc-disabled-pill"
                                            OnClientClick="return confirm('Re-enable this seller account?');">
                                            <i class="fas fa-ban"></i> DISABLED
                                        </asp:LinkButton>
                                        <span runat="server" Visible='<%# !CanToggleAccess(Eval("IsActive"), Eval("DeletionStatus")) %>' class="ms-gc-disabled-pill is-locked">
                                            <i class="fas fa-ban"></i> DISABLED
                                        </span>
                                    </asp:Panel>
                                    <asp:LinkButton runat="server" Visible='<%# ShowGridPowerButton(Eval("IsActive"), Eval("DeletionStatus")) %>'
                                        CommandName="ToggleStatus" CommandArgument='<%# Eval("Id") %>'
                                        CssClass="ms-gc-btn-icon ms-gc-btn-power"
                                        ToolTip="Disable seller access"
                                        OnClientClick="return confirm('Disable this seller? They will not be able to sign in or list products.');">
                                        <i class="fas fa-power-off"></i>
                                    </asp:LinkButton>
                                    <asp:LinkButton runat="server" Visible='<%# ShowDeleteButton(Eval("Id"), Eval("FullName"), Eval("StoreName"), Eval("DeletionStatus")) %>'
                                        CssClass="ms-gc-btn-icon ms-gc-btn-del js-ms-delete"
                                        data-seller-id='<%# Eval("Id") %>'
                                        data-seller-name='<%# AttrEnc(Eval("FullName")) %>'
                                        data-store-name='<%# AttrEnc(Eval("StoreName")) %>'
                                        ToolTip="Delete seller"
                                        OnClientClick="return msOpenDeleteModal(this);">
                                        <i class="fas fa-trash-alt"></i>
                                    </asp:LinkButton>
                                </div>
                            </div>
                        </div>
                    </ItemTemplate>
                    <FooterTemplate></div></FooterTemplate>
                </asp:Repeater>
            </div>

            <asp:Panel ID="pnlEmpty" runat="server" Visible="false" CssClass="ms-empty-state">
                <div class="ms-empty-ico ms-empty-muted"><i class="fas fa-store-slash"></i></div>
                <h4 class="ms-empty-title">No sellers yet</h4>
                <p class="ms-empty-desc">Seller registrations will appear here once they sign up.</p>
            </asp:Panel>

            <div id="jsEmptyState" class="ms-empty-state u-d-none" aria-live="polite">
                <div class="ms-empty-ico"><i class="fas fa-search"></i></div>
                <h4 class="ms-empty-title">No matches on this page</h4>
                <p class="ms-empty-desc">Nothing matches <strong id="jsEmptyQuery"></strong>. Try another name, email, or category.</p>
                <button type="button" class="ms-empty-btn" onclick="clearSearch();">
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

    <asp:HiddenField ID="hfDeleteSellerId" runat="server" Value="" />
    <asp:Button ID="btnConfirmDeleteSeller" runat="server" OnClick="btnConfirmDeleteSeller_Click" CssClass="u-d-none" UseSubmitBehavior="true" />

    <div id="msDeleteModal" class="ms-modal" aria-hidden="true" role="dialog" aria-labelledby="msDeleteModalTitle">
        <div class="ms-modal-backdrop" onclick="msCloseDeleteModal()"></div>
        <div class="ms-modal-dialog">
            <div class="ms-modal-header">
                <div class="ms-modal-icon-danger" aria-hidden="true"><i class="fas fa-trash-alt"></i></div>
                <div class="ms-modal-head-text">
                    <h3 id="msDeleteModalTitle">Delete seller account?</h3>
                    <p class="ms-modal-sub">This action cannot be undone from the seller panel.</p>
                </div>
                <button type="button" class="ms-modal-close" onclick="msCloseDeleteModal()" aria-label="Close">&times;</button>
            </div>
            <div class="ms-modal-body">
                <p class="ms-modal-lead">You are about to permanently remove <strong id="msDeleteSellerName"></strong><span id="msDeleteStoreWrap" class="u-d-none"> (<span id="msDeleteStoreName"></span>)</span> from the marketplace.</p>
                <ul class="ms-modal-list">
                    <li>Seller will be marked as <strong>deleted</strong> and deactivated.</li>
                    <li>They will not be able to sign in or list new products.</li>
                    <li>Existing order history will remain for records.</li>
                </ul>
            </div>
            <div class="ms-modal-footer">
                <button type="button" class="ms-btn ms-btn-outline" onclick="msCloseDeleteModal()">Cancel</button>
                <button type="button" class="ms-btn ms-btn-danger" onclick="msConfirmDeleteSeller()">Yes, delete seller</button>
            </div>
        </div>
    </div>

    <script type="text/javascript">
        var msDeletePendingId = '';

        function msOpenDeleteModal(btn) {
            if (!btn) return false;
            var name = btn.getAttribute('data-seller-name') || 'this seller';
            var store = btn.getAttribute('data-store-name') || '';
            msDeletePendingId = btn.getAttribute('data-seller-id') || '';
            var nameEl = document.getElementById('msDeleteSellerName');
            var storeWrap = document.getElementById('msDeleteStoreWrap');
            var storeEl = document.getElementById('msDeleteStoreName');
            if (nameEl) nameEl.textContent = name;
            if (store && store.trim() && storeWrap && storeEl) {
                storeEl.textContent = store;
                storeWrap.classList.remove('u-d-none');
            } else if (storeWrap) {
                storeWrap.classList.add('u-d-none');
            }
            var modal = document.getElementById('msDeleteModal');
            if (modal) {
                modal.classList.add('is-open');
                modal.setAttribute('aria-hidden', 'false');
            }
            return false;
        }

        function msCloseDeleteModal() {
            var modal = document.getElementById('msDeleteModal');
            if (modal) {
                modal.classList.remove('is-open');
                modal.setAttribute('aria-hidden', 'true');
            }
            msDeletePendingId = '';
        }

        function msConfirmDeleteSeller() {
            if (!msDeletePendingId) return;
            var hf = document.getElementById('<%= hfDeleteSellerId.ClientID %>');
            var submitBtn = document.getElementById('<%= btnConfirmDeleteSeller.ClientID %>');
            if (hf) hf.value = msDeletePendingId;
            if (submitBtn) submitBtn.click();
        }

        (function () {
            var input = document.getElementById('txtSearch');
            if (input) input.addEventListener('input', filterSellers);
            var saved = localStorage.getItem('adminSellersView');
            if (saved === 'grid') setSellerView('grid');
        })();

        function setSellerView(mode) {
            var list = document.getElementById('sellerListView');
            var grid = document.getElementById('sellerGridView');
            var btnList = document.getElementById('btnViewList');
            var btnGrid = document.getElementById('btnViewGrid');
            if (!list || !grid) return;

            if (mode === 'grid') {
                list.classList.add('u-d-none');
                grid.classList.remove('u-d-none');
                if (btnGrid) btnGrid.classList.add('active');
                if (btnList) btnList.classList.remove('active');
                localStorage.setItem('adminSellersView', 'grid');
            } else {
                grid.classList.add('u-d-none');
                list.classList.remove('u-d-none');
                if (btnList) btnList.classList.add('active');
                if (btnGrid) btnGrid.classList.remove('active');
                localStorage.setItem('adminSellersView', 'list');
            }
            filterSellers();
        }

        function filterSellers() {
            var input = document.getElementById('txtSearch');
            var group = document.getElementById('searchGroup');
            var emptyEl = document.getElementById('jsEmptyState');
            var listWrap = document.getElementById('sellerListView');
            var gridWrap = document.getElementById('sellerGridView');
            if (!input) return;

            var filter = input.value.toUpperCase();
            if (group) {
                if (filter.length > 0) group.classList.add('has-val');
                else group.classList.remove('has-val');
            }

            var rows = document.querySelectorAll('.ms-seller-row');
            var cards = document.querySelectorAll('.ms-grid-card');
            var visible = 0;
            var isGrid = gridWrap && !gridWrap.classList.contains('u-d-none');

            for (var i = 0; i < rows.length; i++) {
                var show = rows[i].innerText.toUpperCase().indexOf(filter) > -1;
                rows[i].style.display = show ? '' : 'none';
            }
            for (var j = 0; j < cards.length; j++) {
                var showCard = cards[j].innerText.toUpperCase().indexOf(filter) > -1;
                cards[j].style.display = showCard ? '' : 'none';
                if (isGrid && showCard) visible++;
            }
            if (!isGrid) {
                for (var k = 0; k < rows.length; k++) {
                    if (rows[k].style.display !== 'none') visible++;
                }
            }

            var queryEl = document.getElementById('jsEmptyQuery');
            if (queryEl) queryEl.textContent = input.value ? '"' + input.value + '"' : 'your search';

            var table = document.getElementById('sellersTable');
            var total = isGrid ? cards.length : rows.length;

            if (visible === 0 && total > 0) {
                if (table) table.style.display = 'none';
                if (listWrap && !isGrid) listWrap.style.display = 'none';
                if (gridWrap && isGrid) gridWrap.style.display = 'none';
                if (emptyEl) emptyEl.classList.remove('u-d-none');
            } else {
                if (table) table.style.display = '';
                if (listWrap && !isGrid) listWrap.style.display = '';
                if (gridWrap && isGrid) gridWrap.style.display = '';
                if (emptyEl) emptyEl.classList.add('u-d-none');
            }
        }

        function clearSearch() {
            var input = document.getElementById('txtSearch');
            if (input) {
                input.value = '';
                filterSellers();
                input.focus();
            }
        }
    </script>
</asp:Content>
