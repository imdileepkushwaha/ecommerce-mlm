<%@ Page Title="Inventory Master Hub" Language="C#" MasterPageFile="~/seller/Seller.Master" AutoEventWireup="true"
    CodeFile="Inventory.aspx.cs" Inherits="EcommerceWebsite.SellerInventory" %>

    <asp:Content ID="ContentHead" ContentPlaceHolderID="head" runat="server">
    </asp:Content>

    <asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
        <asp:ScriptManager ID="smInventory" runat="server" EnablePageMethods="true"></asp:ScriptManager>

        <div class="page-action-bar">
            <div class="welcome-title">
                <h1 class="inv-welcome-title-h1"><i class="fas fa-boxes-stacked inv-welcome-title-i"></i>Inventory
                    Operations Master</h1>
                <p>Keep real-time track of catalog items, set triggers for replenishment, and modify size variant
                    reserves instantly.</p>
            </div>
        </div>

        <!-- METRIC STAT DECK -->
        <div class="inv-metric-row">
            <div class="inv-d-card c-total">
                <div class="inv-d-meta">
                    <span class="inv-d-title">Catalog Lines</span>
                    <span class="inv-d-count">
                        <asp:Literal ID="litDistinctProducts" runat="server">0</asp:Literal>
                    </span>
                    <span class="inv-d-desc">Unique product pages</span>
                </div>
                <div class="inv-d-icon"><i class="fas fa-tags"></i></div>
            </div>

            <div class="inv-d-card c-stock">
                <div class="inv-d-meta">
                    <span class="inv-d-title">Total Stock Pool</span>
                    <span class="inv-d-count">
                        <asp:Literal ID="litTotalQuantity" runat="server">0</asp:Literal>
                    </span>
                    <span class="inv-d-desc">Total units across catalog</span>
                </div>
                <div class="inv-d-icon"><i class="fas fa-warehouse"></i></div>
            </div>

            <div class="inv-d-card c-low">
                <div class="inv-d-meta">
                    <span class="inv-d-title">Low Replenishment</span>
                    <span class="inv-d-count">
                        <asp:Literal ID="litLowStockCount" runat="server">0</asp:Literal>
                    </span>
                    <span class="inv-d-desc">Stock below 10 units</span>
                </div>
                <div class="inv-d-icon"><i class="fas fa-triangle-exclamation"></i></div>
            </div>

            <div class="inv-d-card c-out">
                <div class="inv-d-meta">
                    <span class="inv-d-title">Deficit / Sold Out</span>
                    <span class="inv-d-count">
                        <asp:Literal ID="litOutOfStockCount" runat="server">0</asp:Literal>
                    </span>
                    <span class="inv-d-desc">Immediate refill needed</span>
                </div>
                <div class="inv-d-icon"><i class="fas fa-ban"></i></div>
            </div>
        </div>

        <!-- MAIN PRODUCTS INVENTORY GRID WRAPPER -->
        <div class="db-data-card inv-db-card">

            <!-- SEARCH & CONTROL HEADER -->
            <div class="inv-db-header">
                <h3><i class="fas fa-clipboard-list"></i>Warehouse Inventory Overview</h3>

                <!-- Sleek Client-Side Search Module -->
                <div class="inv-search-wrap js-search-wrapper">
                    <i class="fas fa-search"></i>
                    <input type="text" id="txtClientSearch" placeholder="Instant search name, SKU..."
                        oninput="applyClientInventoryFilter()" autocomplete="off" class="inv-search-input" />

                    <span id="btnClientClearSearch" onclick="clearClientSearch()" class="inv-search-clear">
                        <i class="fas fa-circle-xmark"></i>
                    </span>
                </div>
            </div>

            <!-- INTERACTIVE DATA VIEWPORT -->
            <div class="table-wrapper inv-table-wrap">
                <asp:GridView ID="gvInventory" runat="server" AutoGenerateColumns="False" CssClass="clean-data-table"
                    GridLines="None" BorderStyle="None" Width="100%" ShowHeaderWhenEmpty="True" DataKeyNames="Id"
                    AllowPaging="False">
                    <Columns>
                        <asp:TemplateField HeaderText="Product Profile">
                            <ItemTemplate>
                                <div class="product-cell inv-prod-cell">
                                    <img src='<%# GetProductImage(Eval("MainImage")) %>' alt='item'
                                        class="inv-prod-img" />
                                    <div class="inv-prod-meta-stack">
                                        <strong class="js-searchable-name inv-prod-name">
                                            <%# Eval("Name") %>
                                        </strong>
                                        <span class="inv-prod-category">
                                            <%# Eval("Category") %>
                                        </span>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:BoundField DataField="Sku" HeaderText="Main SKU" SortExpression="Sku"
                            HeaderStyle-CssClass="text-center" ItemStyle-CssClass="text-center text-monospace" />

                        <asp:TemplateField HeaderText="Variant Setup" ItemStyle-CssClass="text-center">
                            <ItemTemplate>
                                <span
                                    class='badge-variant <%# Convert.ToInt32(Eval("VariantCount")) > 0 ? "active" : "" %>'>
                                    <i
                                        class='fas <%# Convert.ToInt32(Eval("VariantCount")) > 0 ? "fa-diagram-project" : "fa-circle-minus" %>'></i>
                                    <%# Convert.ToInt32(Eval("VariantCount"))> 0 ? Eval("VariantCount") + " Sizes" :
                                        "Static Unit" %>
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Reserves" ItemStyle-CssClass="text-center">
                            <ItemTemplate>
                                <span class='<%# GetStockPillClass(Eval("Stock")) %>'>
                                    <%# Eval("Stock") %> Pcs
                                </span>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:TemplateField HeaderText="Operations">
                            <ItemStyle CssClass="text-center" Width="160px" />
                            <ItemTemplate>
                                <button type="button" class="btn-action-inv"
                                    onclick='<%# string.Format("loadAndShowDrawer({0}, \"{1}\", \"{2}\", {3})", Eval("Id"), HttpUtility.JavaScriptStringEncode(Eval("Name").ToString()), GetProductImage(Eval("MainImage")), Eval("Stock")) %>'>
                                    <i class="fas fa-sliders"></i> Manage
                                </button>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                    <EmptyDataTemplate>
                        <div class="inv-empty-state">
                            <i class="fas fa-box-open inv-empty-icon"></i>
                            No products found in warehouse.
                        </div>
                    </EmptyDataTemplate>
                </asp:GridView>

                <!-- Dynamic No Matches Visual Fallback (Hidden by default) -->
                <div id="noResultsMatch" class="inv-no-match">
                    <i class="fas fa-magnifying-glass inv-no-match-icon"></i>
                    No inventories matched your local search criteria.
                </div>
            </div>

            <!-- FOOTER PAGINATOR MATCHING VISUALS -->
            <div class="cat-footer" id="pnlClientPaginator">
                <div>
                    Showing all <span id="totalMatchCount">
                        <%= distinctProductCount %>
                    </span> active products
                </div>
                <div class="inv-live-indicator">
                    <span class="inv-live-dot"></span> Live Matrix
                </div>
            </div>
        </div>

        <!-- ====================================================
             DYNAMIC DRAWER SLIDE-OUT UI
             ==================================================== -->
        <div class="inv-drawer-overlay" id="drawerOverlay" onclick="closeDrawer()"></div>

        <div class="inv-drawer" id="rightDrawer">
            <!-- Drawer Header -->
            <div class="inv-dr-header">
                <div class="inv-dr-title">
                    <h3>Product Inventory Reserves</h3>
                    <p>Assign individual shelf reserves per Size variant.</p>
                </div>
                <button type="button" class="inv-dr-close" onclick="closeDrawer()">
                    <i class="fas fa-times"></i>
                </button>
            </div>

            <!-- Drawer Body -->
            <div class="inv-dr-body" id="drawerBody">
                <!-- Product Core Overview -->
                <div class="dr-prod-meta">
                    <img id="drProdImg" src="" alt="prod" />
                    <div class="dr-pm-info">
                        <h4 id="drProdName">Loading Product Name...</h4>
                        <span>Current Global Catalog Level: <strong id="drGlobalStockVal" class="dr-stock-accent">0
                                Pcs</strong></span>
                    </div>
                </div>

                <!-- Variant List Placeholder -->
                <div class="dr-section-wrap">
                    <label class="dr-section-label">
                        Granular Variant Stock (Live Controls)
                    </label>
                    <div id="variantContainer">
                        <!-- Populated dynamically via JavaScript -->
                    </div>
                </div>
            </div>

            <!-- Action Footer -->
            <div class="inv-dr-footer">
                <div id="dr-toast"></div>
                <button type="button" class="btn-dr-cancel" onclick="closeDrawer()">Cancel</button>
                <button type="button" class="btn-dr-save" id="btnSaveReserves" onclick="commitStockChanges()">
                    <i class="fas fa-circle-check"></i> Apply Changes
                </button>
            </div>
        </div>

        <!-- CLIENT SIDE SCRIPT ENGINE -->
        <script type="text/javascript">
            let activeProductId = 0;

            function loadAndShowDrawer(id, name, imageUrl, globalStock) {
                activeProductId = id;

                // 1. Update initial header literals
                document.getElementById('drProdName').innerText = name;
                document.getElementById('drProdImg').src = imageUrl;
                document.getElementById('drGlobalStockVal').innerText = globalStock + " Pcs";

                // 2. Reset container and show spinner
                const container = document.getElementById('variantContainer');
                container.innerHTML = `
                    <div class="loading-container">
                        <div class="spinner"></div>
                        <span>Reading variant ledger matrix...</span>
                    </div>
                `;

                // 3. Fetch real-time variants via ASP.NET PageMethod
                PageMethods.GetProductVariants(id, onFetchSuccess, onFetchError);

                // 4. Animate Drawer In
                document.getElementById('rightDrawer').classList.add('show');
                document.getElementById('drawerOverlay').classList.add('show');
            }

            function onFetchSuccess(response) {
                const container = document.getElementById('variantContainer');
                container.innerHTML = '';

                if (!response || response.length === 0) {
                    // Handles Product without specific size configurations
                    container.innerHTML = `
                        <div class="empty-variants">
                            <h5>🚀 Master Stock Logic Active</h5>
                            <p>This product operates under static catalog counting (No Sizes). To modify its quantity, please adjust the Warehouse Reserves directly in Product Editor.</p>
                        </div>
                        
                        <div class="dr-master-divider">
                            <div class="var-item-row" style="grid-template-columns: 1fr 120px;">
                                <div class="var-meta-left">
                                    <div class="var-name-lbl"><i class="fas fa-boxes"></i> Global Master Inventory</div>
                                    <div class="var-sku-lbl">Adjust cumulative stock across all endpoints</div>
                                </div>
                                <input type="number" class="input-stock-dr js-master-stock-input" 
                                       value="${document.getElementById('drGlobalStockVal').innerText.replace(' Pcs', '')}" min="0"/>
                            </div>
                        </div>
                    `;
                    return;
                }

                // Render size rows with dynamic dynamic bindings
                let html = '<div class="dr-variant-card">';
                response.forEach(v => {
                    const skuTag = v.Sku && v.Sku.trim() !== "" ? v.Sku : "SYSTEM_GEN";
                    html += `
                        <div class="var-item-row">
                            <div class="var-meta-left">
                                <div class="var-name-lbl"><i class="fas fa-ruler-combined"></i> Size: <b>${v.Value}</b></div>
                                <div class="var-sku-lbl">SKU: ${skuTag}</div>
                            </div>
                            <div>
                                <input type="number" class="input-stock-dr js-variant-stock-input" 
                                       data-vid="${v.Id}" value="${v.Stock}" min="0" />
                            </div>
                        </div>
                    `;
                });
                html += '</div>';

                html += `
                    <p style="font-size: 0.7rem; color:#888888; margin-top: 12px; font-weight:600; line-height:1.4;">
                        💡 <strong class="dr-info-strong">Info:</strong> Individual size reserves tabulate up into the Global Total automatically on save.
                    </p>
                `;
                container.innerHTML = html;
            }

            function onFetchError(err) {
                document.getElementById('variantContainer').innerHTML = `
                    <div class="dr-error-container">
                        <i class="fas fa-circle-exclamation" style="font-size:1.5rem; display:block; margin-bottom:10px;"></i>
                        Failed to read ledger info. Reloading recommended.
                    </div>
                `;
            }

            function closeDrawer() {
                document.getElementById('rightDrawer').classList.remove('show');
                document.getElementById('drawerOverlay').classList.remove('show');
                hideDrawerToast();
            }

            function commitStockChanges() {
                const btn = document.getElementById('btnSaveReserves');
                const originalContent = btn.innerHTML;
                btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Applying...';
                btn.disabled = true;

                // Determine if managing specific variants or master stock
                const variantInputs = document.querySelectorAll('.js-variant-stock-input');
                const masterInput = document.querySelector('.js-master-stock-input');

                if (variantInputs.length > 0) {
                    // 1. Build a delimited array of variantId:stock
                    let payload = [];
                    variantInputs.forEach(input => {
                        const vid = input.getAttribute('data-vid');
                        const val = parseInt(input.value) || 0;
                        payload.push(vid + ":" + val);
                    });

                    const dataString = payload.join('|');
                    PageMethods.UpdateVariantStocks(activeProductId, dataString, onSaveSuccess, onSaveError);
                }
                else if (masterInput) {
                    // 2. Simply update global inventory
                    const newGlobalStock = parseInt(masterInput.value) || 0;
                    PageMethods.UpdateGlobalStock(activeProductId, newGlobalStock, onSaveSuccess, onSaveError);
                }

                function onSaveSuccess(res) {
                    btn.innerHTML = originalContent;
                    btn.disabled = false;
                    if (res && res.success) {
                        showDrawerToast("Inventories synced successfully!", "success");

                        // Trigger page refresh in 1s to update backend grid visual states
                        setTimeout(() => {
                            location.reload();
                        }, 1200);
                    } else {
                        showDrawerToast(res.message || "Sync failure.", "error");
                    }
                }

                function onSaveError(err) {
                    btn.innerHTML = originalContent;
                    btn.disabled = false;
                    showDrawerToast("Operational error encountered.", "error");
                }
            }

            function showDrawerToast(msg, type) {
                const toast = document.getElementById('dr-toast');
                toast.className = 'show ' + type;
                toast.innerText = msg;
            }

            function hideDrawerToast() {
                const toast = document.getElementById('dr-toast');
                toast.className = '';
            }

            // ======================================================
            // ULTRA-FAST CLIENT-SIDE LIVE FILTER ENGINE (0ms LATENCY)
            // ======================================================
            function applyClientInventoryFilter() {
                const searchVal = document.getElementById('txtClientSearch').value.toLowerCase().trim();
                const clearBtn = document.getElementById('btnClientClearSearch');

                // Toggle Clear Search visual indicator
                if (clearBtn) {
                    clearBtn.style.display = searchVal !== "" ? "inline-block" : "none";
                }

                const grid = document.getElementById('<%= gvInventory.ClientID %>');
                if (!grid) return;

                // Exclude table header tr:first-child
                const rows = grid.querySelectorAll('tr:not(:first-child)');
                let visibleCount = 0;

                rows.forEach(function (row) {
                    // Combine target properties to test matches (Name, Category, SKU)
                    const rowText = row.innerText.toLowerCase();

                    if (rowText.indexOf(searchVal) > -1) {
                        row.style.display = ""; // Show matched entry
                        visibleCount++;
                    } else {
                        row.style.display = "none"; // Hide unmatched entry
                    }
                });

                // Update instant count badge in footer
                const counter = document.getElementById('totalMatchCount');
                if (counter) {
                    counter.innerText = visibleCount;
                }

                // Fallback display if search yields 0 results
                const fallback = document.getElementById('noResultsMatch');
                if (fallback) {
                    if (visibleCount === 0) {
                        fallback.style.display = "block";
                        grid.style.display = "none";
                    } else {
                        fallback.style.display = "none";
                        grid.style.display = "table";
                    }
                }
            }

            function clearClientSearch() {
                const searchInput = document.getElementById('txtClientSearch');
                if (searchInput) {
                    searchInput.value = "";
                    applyClientInventoryFilter();
                    searchInput.focus();
                }
            }
        </script>
    </asp:Content>