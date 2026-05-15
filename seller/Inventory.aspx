<%@ Page Title="Inventory Master Hub" Language="C#" MasterPageFile="~/seller/Seller.Master" AutoEventWireup="true"
    CodeFile="Inventory.aspx.cs" Inherits="EcommerceWebsite.SellerInventory" %>

    <asp:Content ID="ContentHead" ContentPlaceHolderID="head" runat="server">
        <style type="text/css">
            /* Inventory specific custom styling to preserve system standard look */
            .inv-metric-row {
                display: grid;
                grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
                gap: 18px;
                margin-bottom: 30px;
            }

            .inv-d-card {
                background: #fff;
                border-radius: 12px;
                padding: 20px;
                display: flex;
                justify-content: space-between;
                align-items: center;
                box-shadow: 0 4px 15px rgba(0, 0, 0, 0.03);
                border-top: 4px solid transparent;
                transition: transform 0.2s ease, box-shadow 0.2s ease;
            }
            .inv-d-card:hover {
                transform: translateY(-2px);
                box-shadow: 0 6px 20px rgba(0, 0, 0, 0.06);
            }

            .inv-d-card.c-total { border-top-color: #3b82f6; }
            .inv-d-card.c-stock { border-top-color: #10b981; }
            .inv-d-card.c-low { border-top-color: #f59e0b; }
            .inv-d-card.c-out { border-top-color: #ef4444; }

            .inv-d-meta { display: flex; flex-direction: column; gap: 4px; }
            .inv-d-title { font-size: 0.7rem; font-weight: 800; color: #64748b; text-transform: uppercase; letter-spacing: 0.5px; }
            .inv-d-count { font-size: 1.5rem; font-weight: 800; color: #1e293b; }
            .inv-d-desc { font-size: 0.7rem; color: #94a3b8; font-weight: 600; }

            .inv-d-icon {
                width: 45px; height: 45px; border-radius: 10px;
                display: flex; align-items: center; justify-content: center;
                font-size: 1.2rem;
            }
            .c-total .inv-d-icon { background: #eff6ff; color: #3b82f6; }
            .c-stock .inv-d-icon { background: #ecfdf5; color: #10b981; }
            .c-low .inv-d-icon { background: #fffbeb; color: #f59e0b; }
            .c-out .inv-d-icon { background: #fef2f2; color: #ef4444; }

            /* Listing grid additions */
            .badge-variant {
                display: inline-flex; align-items: center; gap: 6px;
                background: #f1f5f9; color: #475569; padding: 4px 10px;
                border-radius: 30px; font-size: 0.7rem; font-weight: 750;
            }
            .badge-variant.active {
                background: #f5f3ff; color: #7c3aed;
            }

            .stock-pill {
                display: inline-block; padding: 4px 12px; border-radius: 20px;
                font-size: 0.74rem; font-weight: 800; text-align: center; min-width: 60px;
            }
            .stock-pill.good { background: #ecfdf5; color: #059669; }
            .stock-pill.low { background: #fffbeb; color: #d97706; }
            .stock-pill.out { background: #fef2f2; color: #dc2626; }

            .btn-action-inv {
                background: #fff; border: 1.5px solid #e2e8f0; color: #334155;
                padding: 7px 14px; border-radius: 8px; font-size: 0.74rem; font-weight: 750;
                cursor: pointer; display: inline-flex; align-items: center; gap: 8px;
                transition: all 0.2s;
            }
            .btn-action-inv:hover {
                border-color: #7c3aed; color: #7c3aed; background: #f5f3ff;
            }

            .text-monospace {
                font-family: monospace;
                font-size: 0.78rem;
                font-weight: 700;
                color: #475569;
            }

            /* ==========================================
               SLIDE-OUT RIGHT DRAWER
               ========================================== */
            .inv-drawer-overlay {
                position: fixed; top: 0; left: 0; width: 100%; height: 100%;
                background: rgba(15, 23, 42, 0.4); backdrop-filter: blur(2px);
                z-index: 1000; opacity: 0; pointer-events: none;
                transition: opacity 0.3s ease;
            }
            .inv-drawer-overlay.show { opacity: 1; pointer-events: auto; }

            .inv-drawer {
                position: fixed; top: 0; right: -460px; width: 100%; max-width: 450px; height: 100%;
                background: #fff; box-shadow: -5px 0 30px rgba(0, 0, 0, 0.1);
                z-index: 1001; display: flex; flex-direction: column;
                transition: right 0.3s cubic-bezier(0.16, 1, 0.3, 1);
            }
            .inv-drawer.show { right: 0; }

            .inv-dr-header {
                padding: 25px; border-bottom: 1.5px solid #f1f5f9;
                display: flex; justify-content: space-between; align-items: center;
            }
            .inv-dr-title h3 { margin: 0; font-size: 1.1rem; font-weight: 800; color: #0f172a; }
            .inv-dr-title p { margin: 4px 0 0 0; font-size: 0.75rem; color: #64748b; font-weight: 600; }

            .inv-dr-close {
                border: none; background: #f1f5f9; width: 32px; height: 32px;
                border-radius: 50%; display: flex; align-items: center; justify-content: center;
                color: #64748b; cursor: pointer; transition: all 0.2s;
            }
            .inv-dr-close:hover { background: #ef4444; color: #fff; }

            .inv-dr-body {
                flex-grow: 1; overflow-y: auto; padding: 25px;
            }

            .inv-dr-footer {
                padding: 20px 25px; border-top: 1.5px solid #f1f5f9;
                background: #f8fafc; display: flex; gap: 12px; justify-content: flex-end;
            }

            .btn-dr-cancel {
                padding: 10px 18px; border: 1.5px solid #cbd5e1; background: #fff;
                color: #475569; border-radius: 8px; font-weight: 700; font-size: 0.82rem; cursor: pointer;
            }
            .btn-dr-save {
                padding: 10px 22px; border: none; background: #7c3aed;
                color: #fff; border-radius: 8px; font-weight: 700; font-size: 0.82rem; cursor: pointer;
                box-shadow: 0 4px 12px rgba(124, 58, 237, 0.3); display: inline-flex; align-items: center; gap: 8px;
            }
            .btn-dr-save:hover { background: #6d28d9; }

            /* Variant List UI inside Drawer */
            .dr-prod-meta {
                display: flex; gap: 15px; align-items: center;
                padding: 12px; border-radius: 12px; background: #f8fafc;
                border: 1.5px solid #e2e8f0; margin-bottom: 25px;
            }
            .dr-prod-meta img {
                width: 50px; height: 50px; border-radius: 8px; object-fit: cover; border: 1px solid #cbd5e1;
            }
            .dr-pm-info h4 { margin: 0; font-size: 0.88rem; font-weight: 750; color: #1e293b; }
            .dr-pm-info span { font-size: 0.72rem; color: #64748b; font-weight: 600; }

            .var-item-row {
                display: grid; grid-template-columns: 1fr 110px; gap: 15px; align-items: center;
                padding: 15px 0; border-bottom: 1px dashed #e2e8f0;
            }
            .var-item-row:last-child { border-bottom: none; }

            .var-meta-left { display: flex; flex-direction: column; gap: 3px; }
            .var-name-lbl { font-weight: 800; font-size: 0.85rem; color: #0f172a; display: flex; align-items: center; gap: 8px; }
            .var-sku-lbl { font-size: 0.72rem; color: #64748b; font-family: monospace; }

            .input-stock-dr {
                width: 100%; height: 38px; border: 1.5px solid #cbd5e1; border-radius: 8px;
                text-align: center; font-weight: 800; font-size: 0.85rem; color: #0f172a;
                outline: none; transition: border-color 0.2s;
            }
            .input-stock-dr:focus { border-color: #7c3aed; box-shadow: 0 0 0 3px rgba(124, 58, 237, 0.15); }

            .loading-container {
                display: flex; flex-direction: column; align-items: center; justify-content: center;
                padding: 60px 0; color: #64748b; font-size: 0.85rem; font-weight: 650; gap: 12px;
            }
            .spinner {
                width: 32px; height: 32px; border: 3.5px solid #e2e8f0; border-top-color: #7c3aed;
                border-radius: 50%; animation: spinDrawer 0.8s linear infinite;
            }
            @keyframes spinDrawer {
                to { transform: rotate(360deg); }
            }

            .empty-variants {
                text-align: center; padding: 40px 20px; background: #fffbeb;
                border: 1.5px dashed #fcd34d; border-radius: 12px; color: #b45309;
            }
            .empty-variants h5 { margin: 0 0 6px 0; font-size: 0.85rem; font-weight: 800; }
            .empty-variants p { margin: 0; font-size: 0.72rem; font-weight: 600; line-height: 1.4; }

            /* Toast Notifications inside Drawer */
            #dr-toast {
                position: absolute; bottom: 85px; left: 25px; right: 25px;
                padding: 12px; border-radius: 8px; font-size: 0.78rem; font-weight: 750;
                display: flex; align-items: center; gap: 8px; opacity: 0; transform: translateY(10px);
                transition: all 0.3s ease; pointer-events: none; z-index: 100;
            }
            #dr-toast.show { opacity: 1; transform: translateY(0); }
            #dr-toast.success { background: #ecfdf5; color: #065f46; border: 1px solid #a7f3d0; }
            #dr-toast.error { background: #fef2f2; color: #991b1b; border: 1px solid #fecaca; }
        </style>
    </asp:Content>

    <asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
        <asp:ScriptManager ID="smInventory" runat="server" EnablePageMethods="true"></asp:ScriptManager>

        <div class="page-action-bar">
            <div class="welcome-title">
                <h1 style="font-size: 1.6rem;"><i class="fas fa-boxes-stacked" style="color: #7c3aed; margin-right: 8px;"></i>Inventory Operations Master</h1>
                <p>Keep real-time track of catalog items, set triggers for replenishment, and modify size variant reserves instantly.</p>
            </div>
        </div>

        <!-- METRIC STAT DECK -->
        <div class="inv-metric-row">
            <div class="inv-d-card c-total">
                <div class="inv-d-meta">
                    <span class="inv-d-title">Catalog Lines</span>
                    <span class="inv-d-count"><asp:Literal ID="litDistinctProducts" runat="server">0</asp:Literal></span>
                    <span class="inv-d-desc">Unique product pages</span>
                </div>
                <div class="inv-d-icon"><i class="fas fa-tags"></i></div>
            </div>

            <div class="inv-d-card c-stock">
                <div class="inv-d-meta">
                    <span class="inv-d-title">Total Stock Pool</span>
                    <span class="inv-d-count"><asp:Literal ID="litTotalQuantity" runat="server">0</asp:Literal></span>
                    <span class="inv-d-desc">Total units across catalog</span>
                </div>
                <div class="inv-d-icon"><i class="fas fa-warehouse"></i></div>
            </div>

            <div class="inv-d-card c-low">
                <div class="inv-d-meta">
                    <span class="inv-d-title">Low Replenishment</span>
                    <span class="inv-d-count"><asp:Literal ID="litLowStockCount" runat="server">0</asp:Literal></span>
                    <span class="inv-d-desc">Stock below 10 units</span>
                </div>
                <div class="inv-d-icon"><i class="fas fa-triangle-exclamation"></i></div>
            </div>

            <div class="inv-d-card c-out">
                <div class="inv-d-meta">
                    <span class="inv-d-title">Deficit / Sold Out</span>
                    <span class="inv-d-count"><asp:Literal ID="litOutOfStockCount" runat="server">0</asp:Literal></span>
                    <span class="inv-d-desc">Immediate refill needed</span>
                </div>
                <div class="inv-d-icon"><i class="fas fa-ban"></i></div>
            </div>
        </div>

        <!-- MAIN PRODUCTS INVENTORY GRID WRAPPER -->
        <div class="db-data-card" style="border-radius: 15px; box-shadow: 0 4px 20px rgba(0,0,0,0.04); border: 1.5px solid #f1f5f9; overflow: hidden;">
            
            <!-- SEARCH & CONTROL HEADER -->
            <div style="padding: 20px 25px; border-bottom: 1.5px solid #f1f5f9; background:#fff; display:flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 15px;">
                <h3 style="margin:0; font-size: 1.05rem; font-weight: 800; color: #1e293b;"><i class="fas fa-clipboard-list" style="color: #64748b; margin-right: 8px;"></i>Warehouse Inventory Overview</h3>
                
                <!-- Sleek Client-Side Search Module -->
                <div style="display: flex; align-items: center; gap: 10px; background: #f8fafc; border: 1.5px solid #e2e8f0; border-radius: 30px; padding: 2px 6px 2px 16px; width: 100%; max-width: 320px; transition: all 0.2s ease;" class="js-search-wrapper">
                    <i class="fas fa-search" style="color: #94a3b8; font-size: 0.85rem;"></i>
                    <input type="text" id="txtClientSearch" placeholder="Instant search name, SKU..." 
                           oninput="applyClientInventoryFilter()" autocomplete="off"
                           style="border: none; background: transparent; outline: none; padding: 8px 0; font-size: 0.82rem; font-weight: 650; color: #1e293b; flex: 1;" />
                    
                    <span id="btnClientClearSearch" onclick="clearClientSearch()" style="display: none; color: #94a3b8; font-size: 0.9rem; padding: 5px 8px; cursor: pointer;">
                        <i class="fas fa-circle-xmark"></i>
                    </span>
                </div>
            </div>

            <!-- INTERACTIVE DATA VIEWPORT -->
            <div class="table-wrapper" style="background:#fff; overflow-x: auto;">
                <asp:GridView ID="gvInventory" runat="server" AutoGenerateColumns="False" CssClass="clean-data-table"
                    GridLines="None" BorderStyle="None" Width="100%" ShowHeaderWhenEmpty="True" DataKeyNames="Id"
                    AllowPaging="False">
                    <Columns>
                        <asp:TemplateField HeaderText="Product Profile">
                            <ItemTemplate>
                                <div class="product-cell" style="display: flex; align-items: center; gap: 12px; padding: 8px 0;">
                                    <img src='<%# GetProductImage(Eval("MainImage")) %>' alt='item' 
                                         style="width: 42px; height: 42px; border-radius: 8px; object-fit: cover; border: 1.5px solid #f1f5f9;" />
                                    <div style="display: flex; flex-direction: column; gap: 2px;">
                                        <strong style="font-size: 0.84rem; color: #1e293b;" class="js-searchable-name"><%# Eval("Name") %></strong>
                                        <span style="font-size: 0.7rem; color: #94a3b8; font-weight: 600;"><%# Eval("Category") %></span>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:TemplateField>

                        <asp:BoundField DataField="Sku" HeaderText="Main SKU" SortExpression="Sku" 
                            HeaderStyle-CssClass="text-center" ItemStyle-CssClass="text-center text-monospace" />

                        <asp:TemplateField HeaderText="Variant Setup" ItemStyle-CssClass="text-center">
                            <ItemTemplate>
                                <span class='badge-variant <%# Convert.ToInt32(Eval("VariantCount")) > 0 ? "active" : "" %>'>
                                    <i class='fas <%# Convert.ToInt32(Eval("VariantCount")) > 0 ? "fa-diagram-project" : "fa-circle-minus" %>'></i>
                                    <%# Convert.ToInt32(Eval("VariantCount")) > 0 ? Eval("VariantCount") + " Sizes" : "Static Unit" %>
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
                        <div style="padding: 50px; text-align: center; color: #64748b; font-weight: 700; font-size: 0.85rem;">
                            <i class="fas fa-box-open" style="font-size: 2rem; color: #cbd5e1; margin-bottom: 15px; display: block;"></i>
                            No products found in warehouse.
                        </div>
                    </EmptyDataTemplate>
                </asp:GridView>

                <!-- Dynamic No Matches Visual Fallback (Hidden by default) -->
                <div id="noResultsMatch" style="display:none; padding: 50px; text-align: center; color: #64748b; font-weight: 700; font-size: 0.85rem; background: #fff;">
                    <i class="fas fa-magnifying-glass" style="font-size: 2.2rem; color: #cbd5e1; margin-bottom: 15px; display: block;"></i>
                    No inventories matched your local search criteria.
                </div>
            </div>

            <!-- FOOTER PAGINATOR MATCHING VISUALS -->
            <div class="cat-footer" id="pnlClientPaginator">
                <div>
                    Showing all <span id="totalMatchCount"><%= distinctProductCount %></span> active products
                </div>
                <div style="font-weight: 700; color:#1e293b; display:flex; align-items:center; gap:8px;">
                    <span style="width: 8px; height: 8px; border-radius:50%; background: #10b981; display:inline-block; animation: pulse 1.5s infinite;"></span> Live Matrix
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
                        <span>Current Global Catalog Level: <strong id="drGlobalStockVal" style="color: #10b981;">0 Pcs</strong></span>
                    </div>
                </div>

                <!-- Variant List Placeholder -->
                <div style="margin-bottom: 15px;">
                    <label style="font-size: 0.74rem; font-weight: 800; color: #64748b; text-transform: uppercase; display: block; letter-spacing: 0.5px; margin-bottom: 12px;">
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
                        
                        <div style="margin-top:25px; border-top: 1.5px solid #f1f5f9; padding-top: 20px;">
                            <div class="var-item-row" style="grid-template-columns: 1fr 120px;">
                                <div class="var-meta-left">
                                    <div class="var-name-lbl"><i class="fas fa-boxes" style="color:#64748b;"></i> Global Master Inventory</div>
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
                let html = '<div style="background:#fff; border:1.5px solid #e2e8f0; border-radius: 12px; padding: 5px 18px;">';
                response.forEach(v => {
                    const skuTag = v.Sku && v.Sku.trim() !== "" ? v.Sku : "SYSTEM_GEN";
                    html += `
                        <div class="var-item-row">
                            <div class="var-meta-left">
                                <div class="var-name-lbl"><i class="fas fa-ruler-combined" style="color:#8b5cf6;"></i> Size: <b>${v.Value}</b></div>
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
                    <p style="font-size: 0.7rem; color: #64748b; margin-top: 12px; font-weight:600; line-height:1.4;">
                        💡 <strong style="color:#1e293b;">Info:</strong> Individual size reserves tabulate up into the Global Total automatically on save.
                    </p>
                `;
                container.innerHTML = html;
            }

            function onFetchError(err) {
                document.getElementById('variantContainer').innerHTML = `
                    <div style="text-align:center; padding: 30px 0; color: #ef4444; font-weight:700; font-size:0.82rem;">
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
