<%@ Page Title="Catalogue Management" Language="C#" MasterPageFile="~/seller/Seller.Master" AutoEventWireup="true"
    CodeFile="Products.aspx.cs" Inherits="EcommerceWebsite.SellerProducts" %>

    <asp:Content ID="ContentHead" ContentPlaceHolderID="head" runat="server">

    </asp:Content>

    <asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

        <!-- ASYNC ENGINE REFRESH -->
        <asp:ScriptManager ID="smProducts" runat="server"></asp:ScriptManager>

        <!-- ACTION BAR TOP -->
        <div class="page-action-bar">
            <div class="welcome-title">
                <h1 style="font-size: 1.6rem;"><i class="fas fa-boxes"
                        style="color: var(--accent); margin-right: 8px;"></i>Product Catalog</h1>
                <p>Monitor active listings, track local inventory reserves, and synchronize pricing structures.</p>
            </div>

            <a href="AddEditProduct.aspx" class="add-prod-btn">
                <i class="fas fa-plus-circle"></i> Add New Product
            </a>

        </div>
        <!-- 1. DASHBOARD STATISTICAL METRICS GRID -->
        <div class="dashboard-stat-row">
            <!-- STAT CARD 1: TOTAL LISTINGS -->
            <div class="d-card d-card-1">
                <div class="d-meta">
                    <span class="d-title">TOTAL LISTINGS</span>
                    <span class="d-count">
                        <%= totalListings %>
                    </span>
                    <span class="d-desc">All products in your account</span>
                </div>
                <div class="d-icon-circle"><i class="fas fa-sliders-h"></i></div>
            </div>

            <!-- STAT CARD 2: LIVE ON STORE -->
            <div class="d-card d-card-2">
                <div class="d-meta">
                    <span class="d-title">LIVE ON STORE</span>
                    <span class="d-count">
                        <%= liveListings %>
                    </span>
                    <span class="d-desc">Approved + active</span>
                </div>
                <div class="d-icon-circle"><i class="fas fa-eye"></i></div>
            </div>

            <!-- STAT CARD 3: PENDING REVIEW -->
            <div class="d-card d-card-3">
                <div class="d-meta">
                    <span class="d-title">PENDING REVIEW</span>
                    <span class="d-count">
                        <%= pendingListings %>
                    </span>
                    <span class="d-desc">Awaiting admin approval</span>
                </div>
                <div class="d-icon-circle"><i class="far fa-clock"></i></div>
            </div>

            <!-- STAT CARD 4: LOW STOCK ALERT -->
            <div class="d-card d-card-4">
                <div class="d-meta">
                    <span class="d-title">LOW STOCK</span>
                    <span class="d-count">
                        <%= lowStockListings %>
                    </span>
                    <span class="d-desc">Fewer than 5 units (incl. out of stock)</span>
                </div>
                <div class="d-icon-circle"><i class="fas fa-archive"></i></div>
            </div>
        </div>




        <!-- GLOBAL SYSTEM MESSAGES -->
        <asp:UpdatePanel ID="upnlMsg" runat="server" UpdateMode="Conditional">
            <ContentTemplate>
                <asp:Label ID="lblGlobalMsg" runat="server" Visible="false"
                    style="display:block; padding:16px 24px; border-radius:12px; margin-bottom:25px; font-size:0.9rem; font-weight:600;">
                </asp:Label>
            </ContentTemplate>
        </asp:UpdatePanel>

        <!-- 2. CATALOGUE REPOSITORY INTERFACE -->
        <div class="catalogue-wrapper">

            <!-- Flexible Header / Search Toolbar -->
            <div class="cat-toolbar">
                <div class="cat-heading-group">
                    <h2>Catalogue</h2>
                    <span>
                        <%= totalListings %> products · <%= liveListings %> visible to buyers.
                    </span>
                </div>

                <div class="cat-actions-right">
                    <div class="cat-filter-date">
                        <span>Date</span>
                        <select class="cat-select" id="ddlDateFilter" onchange="applyFilters()">
                            <option value="all">All time</option>
                            <option value="24h">Last 24 hours</option>
                            <option value="7d">Last 7 days</option>
                            <option value="30d">Last 30 days</option>
                        </select>
                    </div>

                    <div class="cat-search-box">
                        <i class="fas fa-search"></i>
                        <input type="text" class="cat-search-input"
                            placeholder="Search name, SKU, slug, category, brand..." onkeyup="applyFilters()" />
                    </div>


                </div>
            </div>

            <!-- Interactive Data-Loading Core Grid -->
            <asp:UpdatePanel ID="upnlGrid" runat="server">
                <ContentTemplate>
                    <div style="overflow-x: auto; width: 100%;">
                        <asp:Repeater ID="rptProducts" runat="server" OnItemCommand="rptProducts_ItemCommand">
                            <HeaderTemplate>
                                <table class="cat-table" id="tblCatalogProducts">
                                    <thead>
                                        <tr>
                                            <th style="width: 60px;">ID</th>
                                            <th>PRODUCT</th>
                                            <th>SKU</th>
                                            <th>CATEGORY</th>
                                            <th>PRICE</th>
                                            <th style="width: 80px;">STOCK</th>
                                            <th>LISTING</th>
                                            <th>STATUS</th>
                                            <th style="width: 130px;">ACTIONS</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                            </HeaderTemplate>
                            <ItemTemplate>
                                <tr
                                    data-created='<%# Eval("CreatedAt") != DBNull.Value ? Convert.ToDateTime(Eval("CreatedAt")).ToString("yyyy-MM-ddTHH:mm:ss") : "" %>'>
                                    <!-- Column 1: ID Badge -->
                                    <td>
                                        <span class="id-badge">
                                            <%# Eval("Id") %>
                                        </span>
                                    </td>

                                    <!-- Column 2: High Fidelity Product Block -->
                                    <td>
                                        <div class="prod-meta-flex">
                                            <div class="p-image-box">
                                                <%# GetProductImage(Eval("ThumbnailUrl"), Eval("MainImage")) %>
                                            </div>
                                            <div class="p-text-stack">
                                                <h4>
                                                    <%# Eval("Name") %>
                                                </h4>
                                                <span class="p-slug-small" title='<%# Eval("Slug") %>'>
                                                    <%# Eval("Slug") %>
                                                </span>
                                            </div>
                                        </div>
                                    </td>

                                    <!-- Column 3: Monospace SKU -->
                                    <td>
                                        <span class="cat-sku-code">
                                            <%# Eval("Sku") %>
                                        </span>
                                    </td>

                                    <!-- Column 4: Red/Pink Category Badge -->
                                    <td>
                                        <span class="p-badge-category">
                                            <%# Eval("Category") %>
                                        </span>
                                    </td>

                                    <!-- Column 5: Cur Price + MRP Strikethrough -->
                                    <td>
                                        <div class="p-price-stack">
                                            <span class="p-cur-price">₹<%#
                                                    Convert.ToDecimal(Eval("Price")).ToString("N0") %></span>
                                            <span class="p-mrp-strike">MRP ₹<%#
                                                    Convert.ToDecimal(Eval("Mrp")).ToString("N0") %></span>
                                        </div>
                                    </td>

                                    <!-- Column 6: Square Grey Box Stock -->
                                    <td>
                                        <span class="p-stock-box">
                                            <%# Eval("Stock") %>
                                        </span>
                                    </td>

                                    <!-- Column 7: Approved/Pending Status Badge -->
                                    <td>
                                        <%# GetListingStatusBadge(Eval("ListingStatus")) %>
                                    </td>

                                    <!-- Column 8: iOS Smooth Switch Toggle -->
                                    <td>
                                        <asp:LinkButton ID="lnkToggleActive" runat="server" CommandName="ToggleActive"
                                            CommandArgument='<%# Eval("Id") %>'
                                            CssClass='<%# Convert.ToBoolean(Eval("IsActive")) ? "ios-switch active" : "ios-switch" %>'
                                            ToolTip="Tap to instantly toggle visibility to buyers"></asp:LinkButton>
                                    </td>

                                    <!-- Column 9: Visual Icon Buttons Block -->
                                    <td>
                                        <div class="act-btn-wrap">
                                            <a href='ViewProduct.aspx?id=<%# Eval("Id") %>' class="act-btn act-btn-view"
                                                title="Preview Store View">
                                                <svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em"
                                                    viewBox="0 0 24 24">
                                                    <g fill="none" stroke="currentColor" stroke-width="1.5">
                                                        <path stroke-linecap="round"
                                                            d="M9 4.46A9.8 9.8 0 0 1 12 4c4.182 0 7.028 2.5 8.725 4.704C21.575 9.81 22 10.361 22 12c0 1.64-.425 2.191-1.275 3.296C19.028 17.5 16.182 20 12 20s-7.028-2.5-8.725-4.704C2.425 14.192 2 13.639 2 12c0-1.64.425-2.191 1.275-3.296A14.5 14.5 0 0 1 5 6.821">
                                                        </path>
                                                        <path d="M15 12a3 3 0 1 1-6 0a3 3 0 0 1 6 0Z"></path>
                                                    </g>
                                                </svg>
                                            </a>
                                            <a href='AddEditProduct.aspx?id=<%# Eval("Id") %>'
                                                class="act-btn act-btn-edit" title="Modify Item Parameters">
                                                <svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em"
                                                    viewBox="0 0 24 24">
                                                    <path fill="none" stroke="currentColor" stroke-linecap="round"
                                                        stroke-width="1.5"
                                                        d="M4 22h4m12 0h-8m1.888-18.337l.742-.742a3.146 3.146 0 1 1 4.449 4.45l-.742.74m-4.449-4.448s.093 1.576 1.483 2.966s2.966 1.483 2.966 1.483m-4.449-4.45L7.071 10.48c-.462.462-.693.692-.891.947a5.2 5.2 0 0 0-.599.969c-.139.291-.242.601-.449 1.22l-.875 2.626m14.08-8.13L14.93 11.52m-3.41 3.41c-.462.462-.692.692-.947.891q-.451.352-.969.599c-.291.139-.601.242-1.22.448l-2.626.876m0 0l-.641.213a.848.848 0 0 1-1.073-1.073l.213-.641m1.501 1.5l-1.5-1.5">
                                                    </path>
                                                </svg>
                                            </a>
                                            <asp:LinkButton ID="lnkDelete" runat="server" CommandName="DeleteProduct"
                                                CommandArgument='<%# Eval("Id") %>' CssClass="act-btn act-btn-delete"
                                                OnClientClick="return confirm('WARNING: Complete deletion? This deletes the repository data permanently.');"
                                                ToolTip="Purge Product">
                                                <svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em"
                                                    viewBox="0 0 24 24">
                                                    <path fill="none" stroke="currentColor" stroke-linecap="round"
                                                        stroke-width="1.5"
                                                        d="M20.5 6h-17m5.67-2a3.001 3.001 0 0 1 5.66 0m3.544 11.4c-.177 2.654-.266 3.981-1.131 4.79s-2.195.81-4.856.81h-.774c-2.66 0-3.99 0-4.856-.81c-.865-.809-.953-2.136-1.13-4.79l-.46-6.9m13.666 0l-.2 3">
                                                    </path>
                                                </svg>
                                            </asp:LinkButton>
                                        </div>
                                    </td>
                                </tr>
                            </ItemTemplate>
                            <FooterTemplate>
                                <!-- Client-Side Dynamic "No Records" Warning Node -->
                                <tr id="rowNoRecords" style="display:none;">
                                    <td colspan="9" style="text-align: center; padding: 60px 24px; background: #fff;">
                                        <div style="font-size: 2.8rem; color: #cbd5e1; margin-bottom: 14px;">
                                            <i class="fas fa-search-minus"></i>
                                        </div>
                                        <h4
                                            style="font-weight: 800; color: #475569; margin-bottom: 6px; font-size: 1.05rem;">
                                            No Matching Records</h4>
                                        <p
                                            style="color: #94a3b8; font-size: 0.85rem; max-width: 340px; margin: 0 auto;">
                                            We couldn't find any products matching your search query. Refine your terms
                                            or check for typos.</p>
                                    </td>
                                </tr>
                                </tbody>
                                </table>
                            </FooterTemplate>
                        </asp:Repeater>
                    </div>

                    <!-- UI Dynamic Paginator Matching Layout -->
                    <div class="cat-footer">
                        <div>
                            Showing 1-<%= totalListings %> of <%= totalListings %>
                        </div>
                        <div style="display: flex; align-items: center; gap: 12px;">
                            <span>Per page</span>
                            <select class="cat-select" style="padding: 5px 10px; font-size: 0.75rem;">
                                <option>25</option>
                                <option>50</option>
                                <option>100</option>
                            </select>
                            <span>Page 1 of 1</span>
                        </div>
                    </div>

                    <!-- Empty Registry Fail-Safe -->
                    <asp:PlaceHolder ID="phEmptyState" runat="server" Visible="false">
                        <div style="text-align: center; padding: 70px 24px; background: #fff;">
                            <div style="font-size: 3.5rem; color: #cbd5e1; margin-bottom: 15px;">
                                <i class="fas fa-boxes"></i>
                            </div>
                            <h4 style="font-weight: 800; color: #1e293b; margin-bottom: 8px;">No Products In Catalog
                            </h4>
                            <p style="color: #64748b; font-size: 0.9rem; max-width: 400px; margin: 0 auto 24px;">Begin
                                building your merchant shelf. Index items to open your store to buyers.</p>
                            <a href="AddEditProduct.aspx" class="act-btn act-btn-edit"
                                style="width:auto; margin:0 auto; padding: 0 20px; border-radius: 10px; font-weight: 700; height: 38px;">
                                <i class="fas fa-plus" style="margin-right: 8px;"></i> Launch First Product
                            </a>
                        </div>
                    </asp:PlaceHolder>

                </ContentTemplate>
            </asp:UpdatePanel>

        </div>

        <!-- Client-Side Unified Instant Filter (Search + Date Selection) -->
        <script>
            function applyFilters() {
                var searchVal = document.querySelector(".cat-search-input").value.toLowerCase().trim();
                var dateFilter = document.getElementById("ddlDateFilter").value;

                var rows = document.querySelectorAll("#tblCatalogProducts tbody tr:not(#rowNoRecords)");
                var visibleCount = 0;
                var now = new Date();

                rows.forEach(function (row) {
                    // 1. Text Query matching
                    var rowContent = row.innerText.toLowerCase();
                    var matchesSearch = rowContent.indexOf(searchVal) > -1;

                    // 2. Date Period matching
                    var matchesDate = true;
                    var createdStr = row.getAttribute("data-created");

                    if (createdStr && dateFilter !== "all") {
                        var createdDate = new Date(createdStr);
                        var diffMs = now - createdDate;

                        if (dateFilter === "24h") {
                            matchesDate = (diffMs <= 24 * 60 * 60 * 1000);
                        } else if (dateFilter === "7d") {
                            matchesDate = (diffMs <= 7 * 24 * 60 * 60 * 1000);
                        } else if (dateFilter === "30d") {
                            matchesDate = (diffMs <= 30 * 24 * 60 * 60 * 1000);
                        }
                    }

                    // Unified AND condition toggler
                    if (matchesSearch && matchesDate) {
                        row.style.display = "";
                        visibleCount++;
                    } else {
                        row.style.display = "none";
                    }
                });

                // Toggle warning fallback UI state
                var emptyRow = document.getElementById("rowNoRecords");
                if (emptyRow) {
                    emptyRow.style.display = (visibleCount === 0) ? "" : "none";
                }
            }
        </script>

    </asp:Content>