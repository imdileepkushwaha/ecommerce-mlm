<%@ Page Title="Catalog Configuration Console" Language="C#" MasterPageFile="~/seller/Seller.Master"
    AutoEventWireup="true" CodeFile="AddEditProduct.aspx.cs" Inherits="EcommerceWebsite.SellerAddEditProduct"
    ValidateRequest="false" %>

    <asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
        <style>
            .size-check-grid {
                display: flex;
                flex-wrap: wrap;
                gap: 10px;
            }

            .size-pill {
                display: flex;
                align-items: center;
                gap: 8px;
                background: #fff;
                border: 1.5px solid #cbd5e1;
                padding: 10px 18px;
                border-radius: 10px;
                font-size: 0.85rem;
                font-weight: 800;
                cursor: pointer;
                user-select: none;
                transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
                box-shadow: 0 1px 2px rgba(0, 0, 0, 0.05);
            }

            .size-pill:hover {
                border-color: #94a3b8;
                background: #f8fafc;
            }

            .size-pill:has(input:checked) {
                background: #eff6ff;
                border-color: #2563eb;
                color: #1d4ed8;
                box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.15);
            }

            .size-pill input {
                cursor: pointer;
                accent-color: #2563eb;
                width: 16px;
                height: 16px;
            }
        </style>

        <!-- PAGE HEADER CONSOLE -->
        <div class="page-action-bar" style="margin-bottom: 30px;">
            <div class="welcome-title">
                <h1>
                    <asp:Literal ID="litPageTitle" runat="server">Add Product Console</asp:Literal>
                </h1>
                <p>Configure your storefront listing across multi-step telemetry layers.</p>
            </div>

            <!-- RETURN ANCHOR FLOATED TO RIGHT -->
            <a href="Products.aspx" class="back-btn-link"
                style="font-size: 0.92rem; border: 1.5px solid var(--border-c); padding: 10px 20px; border-radius: 12px; background: #fff; box-shadow: 0 4px 6px -1px rgba(0,0,0,0.05);">
                <i class="fas fa-arrow-left"></i> Return to Catalog
            </a>
        </div>

        <!-- GLOBAL ALERTS -->
        <asp:Label ID="lblMsg" runat="server" Visible="false"
            style="display:block; padding:18px 25px; border-radius:16px; margin-bottom:25px; font-size:0.92rem; font-weight:650;">
        </asp:Label>

        <!-- ==========================================
         MAIN DUAL COLUMN VERTICAL TAB LAYOUT
         ========================================== -->
        <div class="vt-layout">

            <!-- 1. LEFT STEPPER NAVIGATION MODULE -->
            <aside class="vt-nav">
                <span class="vt-nav-lbl">Product Form</span>

                <!-- Tab 0: Add Product Details -->
                <div class="vt-tab-link vt-active-red active" id="lnkTab0" onclick="showTab(0)">
                    <div class="vt-tab-ico">
                        <i class="fas fa-circle-plus"></i>
                    </div>
                    <div class="vt-tab-meta">
                        <strong>Add Product Details</strong>
                        <span>Add Product name & details</span>
                    </div>
                </div>

                <!-- Tab 1: Product Gallery -->
                <div class="vt-tab-link" id="lnkTab1" onclick="showTab(1)">
                    <div class="vt-tab-ico">
                        <i class="fas fa-images"></i>
                    </div>
                    <div class="vt-tab-meta">
                        <strong>Product gallery</strong>
                        <span>thumbnail & Add Gallery</span>
                    </div>
                </div>

                <!-- Tab 2: Product Categories -->
                <div class="vt-tab-link" id="lnkTab2" onclick="showTab(2)">
                    <div class="vt-tab-ico">
                        <i class="fas fa-layer-group"></i>
                    </div>
                    <div class="vt-tab-meta">
                        <strong>Product Categories</strong>
                        <span>category & listing status</span>
                    </div>
                </div>

                <!-- Tab 3: Selling Prices -->
                <div class="vt-tab-link" id="lnkTab3" onclick="showTab(3)">
                    <div class="vt-tab-ico">
                        <i class="fas fa-tags"></i>
                    </div>
                    <div class="vt-tab-meta">
                        <strong>Selling prices</strong>
                        <span>basic price & discount</span>
                    </div>
                </div>

                <!-- Tab 4: Advance -->
                <div class="vt-tab-link" id="lnkTab4" onclick="showTab(4)">
                    <div class="vt-tab-ico">
                        <i class="fas fa-wrench"></i>
                    </div>
                    <div class="vt-tab-meta">
                        <strong>Advance</strong>
                        <span>Meta details & Inventory</span>
                    </div>
                </div>

                <!-- Tab 5: Shipping -->
                <div class="vt-tab-link" id="lnkTab5" onclick="showTab(5)">
                    <div class="vt-tab-ico">
                        <i class="fas fa-location-dot"></i>
                    </div>
                    <div class="vt-tab-meta">
                        <strong>Shipping</strong>
                        <span>weight & dimensions</span>
                    </div>
                </div>
            </aside>

            <!-- 2. RIGHT VIEWPORT CONTENT PANELS -->
            <div class="vt-viewport">

                <!-- ==========================================
                 PANEL 0: ADD PRODUCT DETAILS & SKU BLOCK
                 ========================================== -->
                <div class="vt-panel active" id="panel0">
                    <!-- SKU TOGGLE BLOCK (AS PER IMAGE) -->
                    <div class="sku-opt-card">
                        <span class="sku-lbl-top">SKU (Stock Keeping Unit)</span>
                        <div class="sku-selector-grp">
                            <label class="sku-radio-box">
                                <asp:RadioButton ID="rdoSkuAuto" runat="server" GroupName="SkuGroup" Checked="true"
                                    onclick="toggleSkuMode(true);" ClientIDMode="Static" />
                                Auto-generate on save
                            </label>
                            <label class="sku-radio-box sku-manual">
                                <asp:RadioButton ID="rdoSkuManual" runat="server" GroupName="SkuGroup"
                                    onclick="toggleSkuMode(false);" ClientIDMode="Static" />
                                Manual Input
                            </label>
                        </div>
                        <div id="divSkuHint" class="sku-sub-hint">
                            Khali chhodoge to save par system SKU banayega (category + product name se).
                        </div>

                        <!-- Manual SKU Input Panel (Toggled by JS) -->
                        <div id="divManualSkuInput" style="margin-top: 15px; display:none;">
                            <label class="db-label" style="font-size: 0.75rem;">Define Custom SKU *</label>
                            <asp:TextBox ID="txtSku" runat="server" CssClass="db-input"
                                placeholder="e.g., PROD-SHIRT-001" ClientIDMode="Static"></asp:TextBox>
                        </div>
                    </div>

                    <!-- Product Identity -->
                    <div class="db-form-card" style="margin-bottom:0;">
                        <div class="db-form-head">
                            <i class="fas fa-circle-plus" style="color:#ef4444;"></i>
                            <h3>Core Product Details</h3>
                        </div>

                        <div class="db-form-full" style="margin-bottom: 20px;">
                            <label class="db-label">Product Title *</label>
                            <asp:TextBox ID="txtName" runat="server" CssClass="db-input" placeholder="Product title"
                                ClientIDMode="Static">
                            </asp:TextBox>
                            <span class="sku-sub-hint" style="display:block; margin-top:5px;">Kam se kam 2 shabd (sirf
                                ek letter ya ek shabd se Next / Submit nahi hoga).</span>
                            <asp:RequiredFieldValidator ID="rfvName" runat="server" ControlToValidate="txtName"
                                Display="Dynamic" ErrorMessage="🚨 Product title is required." SetFocusOnError="true"
                                CssClass="validator-error-text"></asp:RequiredFieldValidator>
                        </div>

                        <div class="db-form-full slug-container-banner">
                            <label class="db-label">Product Permalink / Slug <i class="fas fa-lock"
                                    style="margin-left: 5px; font-size: 0.78rem; color: #94a3b8;"></i></label>
                            <asp:TextBox ID="txtSlug" runat="server" CssClass="db-input slug-input-read"
                                placeholder="auto-generated-slug-path" ReadOnly="true" ClientIDMode="Static">
                            </asp:TextBox>
                            <span class="sku-sub-hint" style="display:block; margin-top:6px; color:#888888;"><i
                                    class="fas fa-circle-info" style="margin-right:4px;"></i> Automatically synchronized
                                from title. Cannot be manually overridden.</span>
                        </div>

                        <div class="db-form-full">
                            <label class="db-label">Description</label>
                            <div class="mock-editor-container">
                                <!-- Toolbar Mock-up similar to image -->
                                <div class="mock-editor-toolbar">
                                    <span style="font-weight:700;">Normal <i class="fas fa-caret-down"></i></span>
                                    <span class="mock-editor-divider"></span>
                                    <i class="fas fa-bold" style="cursor:pointer;"></i>
                                    <i class="fas fa-italic" style="cursor:pointer;"></i>
                                    <i class="fas fa-underline" style="cursor:pointer;"></i>
                                    <i class="fas fa-strikethrough" style="cursor:pointer;"></i>
                                    <span class="mock-editor-divider"></span>
                                    <i class="fas fa-list-ul" style="cursor:pointer;"></i>
                                    <i class="fas fa-list-ol" style="cursor:pointer;"></i>
                                    <span class="mock-editor-divider"></span>
                                    <i class="fas fa-link" style="cursor:pointer;"></i>
                                    <i class="fas fa-image" style="cursor:pointer;"></i>
                                </div>
                                <asp:TextBox ID="txtDesc" runat="server" CssClass="db-textarea" TextMode="MultiLine"
                                    placeholder="Enter your messages..."
                                    style="border:none; border-radius:0; height: 180px;"></asp:TextBox>
                            </div>
                            <span class="sku-sub-hint" style="display:block; margin-top:5px;">Improve product visibility
                                by adding a compelling description. Kam se kam 2 shabd zaroori hain.</span>
                            <asp:RequiredFieldValidator ID="rfvDesc" runat="server" ControlToValidate="txtDesc"
                                Display="Dynamic" ErrorMessage="🚨 Public product narrative cannot be blank."
                                CssClass="validator-error-text"></asp:RequiredFieldValidator>
                        </div>
                    </div>
                </div>

                <!-- ==========================================
                 PANEL 1: PRODUCT GALLERY (MEDIA)
                 ========================================== -->
                <div class="vt-panel" id="panel1">
                    <!-- REMOVAL VECTOR STATE STORE -->
                    <asp:HiddenField ID="hfRemovedGalleryUrls" runat="server" ClientIDMode="Static" Value="" />

                    <div class="db-form-card">
                        <div class="db-form-head">
                            <i class="fas fa-images"></i>
                            <h3>Product Pallery</h3>
                        </div>

                        <!-- STAGE 1: PARALLEL FILE ATTACHMENT PORTS -->
                        <div class="pg-drop-row">

                            <!-- Left Column: Solo Product Image -->
                            <div style="flex: 1;">
                                <label class="db-label">Product Image</label>
                                <div class="pg-drop-box" onclick="document.getElementById('fuMain').click();">
                                    <i class="fas fa-cloud-arrow-up" id="iconMain"></i>
                                    <strong>Drag your image here, or browser</strong>
                                    <span>SVG, PNG, JPG or GIF</span>

                                    <span id="spnMainName"
                                        style="margin-top: 12px; font-size: 0.75rem; background: #eff6ff; color: var(--accent); padding: 4px 10px; border-radius: 20px; font-weight: 800; display:none; border: 1px solid #bfdbfe;"></span>

                                    <!-- Hidden Real ASP FileUpload -->
                                    <asp:FileUpload ID="fuMain" runat="server" style="display:none;"
                                        ClientIDMode="Static"
                                        onchange="if(this.files[0]){ document.getElementById('spnMainName').innerText = '📌 Staged: ' + this.files[0].name; document.getElementById('spnMainName').style.display='inline-block'; document.getElementById('iconMain').style.color='var(--accent)'; }" />
                                </div>
                            </div>

                            <!-- Right Column: Bulk Gallery Pipeline -->
                            <div style="flex: 1;">
                                <label class="db-label">Product Gallery</label>
                                <div class="pg-drop-box" onclick="document.getElementById('fuGallery').click();">
                                    <i class="fas fa-images" id="iconGal"></i>
                                    <strong>Drag files here</strong>
                                    <span>Add Product Gallery Images (max 6 per color)</span>

                                    <span id="spnGalSummary"
                                        style="margin-top: 12px; font-size: 0.75rem; background: #eff6ff; color: var(--accent); padding: 4px 10px; border-radius: 20px; font-weight: 800; display:none; border: 1px solid #bfdbfe;"></span>

                                    <asp:FileUpload ID="fuGallery" runat="server" AllowMultiple="true"
                                        style="display:none;" ClientIDMode="Static"
                                        onchange="var f=this.files; var n=[]; for(var i=0; i<f.length; i++){ n.push(f[i].name); } document.getElementById('spnGalSummary').innerText = '🔥 ' + f.length + ' Image(s) Queued'; document.getElementById('spnGalSummary').style.display='inline-block'; document.getElementById('iconGal').style.color='var(--accent)';" />
                                </div>
                                <div style="font-size: 0.78rem; color:#888888; font-weight:600; margin-top: 8px;">
                                    Har selected color ke liye max 6 images. Main product image alag hai.
                                </div>
                            </div>
                        </div>

                        <!-- DIVISION LINE -->
                        <hr style="border: 0; border-top: 1.5px solid #f1f5f9; margin: 30px 0;" />

                        <!-- STAGE 2: ACTIVE GALLERY MODIFICATION REGION -->
                        <asp:Panel ID="pnlGalleryExisting" runat="server" Visible="false">
                            <div
                                style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px; gap: 20px;">
                                <div style="font-size: 0.82rem; font-weight: 600; color: #475569; line-height: 1.5;">
                                    Abhi ki photos — remove tick karke galat image hata sakte ho. Nayi upload sirf tab
                                    replace karegi jab files select karo.
                                </div>
                                <button type="button" class="vt-btn-next"
                                    style="padding: 8px 20px; border-radius: 30px; font-size: 0.8rem; color: #1e293b; border-color: #cbd5e1; white-space: nowrap;"
                                    onclick="clearGallerySelections();">
                                    Clear selection
                                </button>
                            </div>

                            <!-- GRID COMPONENT WRAPPER -->
                            <div class="ex-gal-grid">
                                <asp:Literal ID="litGalleryExistingThumbs" runat="server"></asp:Literal>
                            </div>
                        </asp:Panel>

                    </div>
                </div>


                <!-- ==========================================
                 PANEL 2: CATEGORIES AND CLASSIFICATION
                 ========================================== -->
                <div class="vt-panel" id="panel2">
                    <div class="db-form-card">
                        <div class="db-form-head">
                            <i class="fas fa-layer-group"></i>
                            <h3>Product Categories & Status</h3>
                        </div>

                        <div class="db-form-grid">
                            <div>
                                <label class="db-label">Listing Classification Category *</label>
                                <asp:TextBox ID="txtCategory" runat="server" CssClass="db-input"
                                    placeholder="e.g., Apparel / Accessories"></asp:TextBox>
                                <asp:RequiredFieldValidator ID="rfvCat" runat="server" ControlToValidate="txtCategory"
                                    Display="Dynamic" ErrorMessage="🚨 Classification category required."
                                    CssClass="validator-error-text"></asp:RequiredFieldValidator>
                            </div>

                            <div>
                                <label class="db-label">Brand Identity Label</label>
                                <asp:TextBox ID="txtBrand" runat="server" CssClass="db-input"
                                    placeholder="e.g., BrandName / Local"></asp:TextBox>
                            </div>

                            <div>
                                <label class="db-label">Catalog Product Type *</label>
                                <asp:DropDownList ID="ddlProductType" runat="server" CssClass="db-select"
                                    ClientIDMode="Static" onchange="handleTypeChange();">
                                    <asp:ListItem Value="Shirt">👔 Shirt / T-Shirt</asp:ListItem>
                                    <asp:ListItem Value="Jeans">👖 Jeans / Denim</asp:ListItem>
                                    <asp:ListItem Value="Shoes">👟 Shoes / Footwear</asp:ListItem>
                                    <asp:ListItem Value="Watch">⌚ Watches / Smartwear</asp:ListItem>
                                    <asp:ListItem Value="Bag">🎒 Bags & Backpacks</asp:ListItem>
                                    <asp:ListItem Value="Accessories">🕶️ Accessories / Jewellery</asp:ListItem>
                                    <asp:ListItem Value="Other">🛍️ Other / Custom</asp:ListItem>
                                </asp:DropDownList>
                            </div>

                            <!-- DYNAMIC SIZE SELECTOR MODULE -->
                            <div class="db-form-full size-config-card">
                                <label class="db-label">Available Size Configurator</label>
                                <p style="font-size:0.76rem; color:#64748b; margin-bottom:15px; font-weight:600;">
                                    Product type badalne par standard size options boxes apne aap dikhenge. Please ticks
                                    karein.</p>

                                <!-- Jeans Sizes -->
                                <div id="grpJeansSizes" class="size-check-grid" style="display:none;">
                                    <label class="size-pill"><input type="checkbox" value="28"
                                            onchange="syncSizes();" /> 28</label>
                                    <label class="size-pill"><input type="checkbox" value="30"
                                            onchange="syncSizes();" /> 30</label>
                                    <label class="size-pill"><input type="checkbox" value="32"
                                            onchange="syncSizes();" /> 32</label>
                                    <label class="size-pill"><input type="checkbox" value="34"
                                            onchange="syncSizes();" /> 34</label>
                                    <label class="size-pill"><input type="checkbox" value="36"
                                            onchange="syncSizes();" /> 36</label>
                                    <label class="size-pill"><input type="checkbox" value="38"
                                            onchange="syncSizes();" /> 38</label>
                                    <label class="size-pill"><input type="checkbox" value="40"
                                            onchange="syncSizes();" /> 40</label>
                                </div>

                                <!-- Shirt/T-Shirt Sizes -->
                                <div id="grpShirtSizes" class="size-check-grid" style="display:none;">
                                    <label class="size-pill"><input type="checkbox" value="XS"
                                            onchange="syncSizes();" /> XS</label>
                                    <label class="size-pill"><input type="checkbox" value="S" onchange="syncSizes();" />
                                        S</label>
                                    <label class="size-pill"><input type="checkbox" value="M" onchange="syncSizes();" />
                                        M</label>
                                    <label class="size-pill"><input type="checkbox" value="L" onchange="syncSizes();" />
                                        L</label>
                                    <label class="size-pill"><input type="checkbox" value="XL"
                                            onchange="syncSizes();" /> XL</label>
                                    <label class="size-pill"><input type="checkbox" value="XXL"
                                            onchange="syncSizes();" /> XXL</label>
                                    <label class="size-pill"><input type="checkbox" value="3XL"
                                            onchange="syncSizes();" /> 3XL</label>
                                </div>

                                <!-- Shoes Sizes -->
                                <div id="grpShoesSizes" class="size-check-grid" style="display:none;">
                                    <label class="size-pill"><input type="checkbox" value="6" onchange="syncSizes();" />
                                        6</label>
                                    <label class="size-pill"><input type="checkbox" value="7" onchange="syncSizes();" />
                                        7</label>
                                    <label class="size-pill"><input type="checkbox" value="8" onchange="syncSizes();" />
                                        8</label>
                                    <label class="size-pill"><input type="checkbox" value="9" onchange="syncSizes();" />
                                        9</label>
                                    <label class="size-pill"><input type="checkbox" value="10"
                                            onchange="syncSizes();" /> 10</label>
                                    <label class="size-pill"><input type="checkbox" value="11"
                                            onchange="syncSizes();" /> 11</label>
                                </div>

                                <!-- Watches Sizes -->
                                <div id="grpWatchSizes" class="size-check-grid" style="display:none;">
                                    <label class="size-pill"><input type="checkbox" value="Free Size"
                                            onchange="syncSizes();" /> Free Size</label>
                                    <label class="size-pill"><input type="checkbox" value="38mm"
                                            onchange="syncSizes();" /> 38mm</label>
                                    <label class="size-pill"><input type="checkbox" value="40mm"
                                            onchange="syncSizes();" /> 40mm</label>
                                    <label class="size-pill"><input type="checkbox" value="42mm"
                                            onchange="syncSizes();" /> 42mm</label>
                                    <label class="size-pill"><input type="checkbox" value="44mm"
                                            onchange="syncSizes();" /> 44mm</label>
                                    <label class="size-pill"><input type="checkbox" value="45mm"
                                            onchange="syncSizes();" /> 45mm</label>
                                    <label class="size-pill"><input type="checkbox" value="Standard"
                                            onchange="syncSizes();" /> Standard</label>
                                </div>

                                <!-- Bags Sizes -->
                                <div id="grpBagSizes" class="size-check-grid" style="display:none;">
                                    <label class="size-pill"><input type="checkbox" value="Small"
                                            onchange="syncSizes();" /> Small</label>
                                    <label class="size-pill"><input type="checkbox" value="Medium"
                                            onchange="syncSizes();" /> Medium</label>
                                    <label class="size-pill"><input type="checkbox" value="Large"
                                            onchange="syncSizes();" /> Large</label>
                                    <label class="size-pill"><input type="checkbox" value="Free Size"
                                            onchange="syncSizes();" /> Free Size</label>
                                    <label class="size-pill"><input type="checkbox" value="15L"
                                            onchange="syncSizes();" /> 15L</label>
                                    <label class="size-pill"><input type="checkbox" value="25L"
                                            onchange="syncSizes();" /> 25L</label>
                                    <label class="size-pill"><input type="checkbox" value="35L"
                                            onchange="syncSizes();" /> 35L</label>
                                </div>

                                <!-- Accessories Sizes -->
                                <div id="grpAccessoriesSizes" class="size-check-grid" style="display:none;">
                                    <label class="size-pill"><input type="checkbox" value="Free Size"
                                            onchange="syncSizes();" /> Free Size</label>
                                    <label class="size-pill"><input type="checkbox" value="One Size"
                                            onchange="syncSizes();" /> One Size</label>
                                    <label class="size-pill"><input type="checkbox" value="Small"
                                            onchange="syncSizes();" /> S</label>
                                    <label class="size-pill"><input type="checkbox" value="Medium"
                                            onchange="syncSizes();" /> M</label>
                                    <label class="size-pill"><input type="checkbox" value="Large"
                                            onchange="syncSizes();" /> L</label>
                                    <label class="size-pill"><input type="checkbox" value="Standard"
                                            onchange="syncSizes();" /> Standard</label>
                                </div>

                                <!-- Final Value Input Storage (Loaded / Auto-Synced) -->
                                <div style="margin-top:15px; border-top: 1px dashed #cbd5e1; padding-top:15px;">
                                    <label class="db-label" style="font-size: 0.76rem; color:#475569;">Final Sizes
                                        Collection (Comma-separated or Custom Values)</label>
                                    <asp:TextBox ID="txtSizes" runat="server" CssClass="db-input"
                                        placeholder="e.g., S, M, L or Custom values..." ClientIDMode="Static"
                                        oninput="syncChecksFromText();"></asp:TextBox>
                                </div>
                            </div>

                            <div>
                                <label class="db-label">Target Consumer Cohort</label>
                                <asp:DropDownList ID="ddlGender" runat="server" CssClass="db-select">
                                    <asp:ListItem Value="Unisex">Universal / Unisex</asp:ListItem>
                                    <asp:ListItem Value="Male">Male / Mens</asp:ListItem>
                                    <asp:ListItem Value="Female">Female / Womens</asp:ListItem>
                                    <asp:ListItem Value="Kids">Infants / Kids</asp:ListItem>
                                </asp:DropDownList>
                            </div>

                            <!-- DYNAMIC BADGES CONFIG -->
                            <div>
                                <label class="db-label">Product Badge Icon / Type</label>
                                <asp:DropDownList ID="ddlBadge" runat="server" CssClass="db-select">
                                    <asp:ListItem Value="None">No Badge</asp:ListItem>
                                    <asp:ListItem Value="New">🆕 New Arrival</asp:ListItem>
                                    <asp:ListItem Value="Hot">🔥 Hot Seller</asp:ListItem>
                                    <asp:ListItem Value="Sale">💸 On Sale</asp:ListItem>
                                    <asp:ListItem Value="Best">⭐ Best Rated</asp:ListItem>
                                    <asp:ListItem Value="Custom">🎯 Custom Text</asp:ListItem>
                                </asp:DropDownList>
                            </div>

                            <div>
                                <label class="db-label">Badge Display Text</label>
                                <asp:TextBox ID="txtBadgeText" runat="server" CssClass="db-input"
                                    placeholder="e.g., 50% OFF, Trending Now"></asp:TextBox>
                            </div>

                            <div class="db-form-full">
                                <div class="db-switch-row" style="border-color: #e2e8f0;">
                                    <div class="db-switch-meta">
                                        <strong>Listing Visibility Over storefront</strong>
                                        <span>Instantly toggle catalog indexing on retail consumer paths.</span>
                                    </div>
                                    <asp:CheckBox ID="chkActive" runat="server" Checked="true" />
                                </div>
                            </div>
                        </div>

                        <!-- Color Variant Grouping Section -->
                        <div
                            style="margin-top: 25px; padding-top: 25px; border-top: 1.5px solid rgba(243, 243, 243, 0.05) !important;">
                            <h4
                                style="margin: 0 0 10px 0;  font-size: 0.95rem; font-weight: 800; display: flex; align-items: center; gap: 10px;">
                                <i class="fas fa-link" style="color: #ef4444;"></i> Color Variant Group Linking
                            </h4>
                            <p
                                style="font-size: 0.78rem; color:#888888; margin-bottom: 20px; font-weight: 600; line-height: 1.4;">
                                Link distinct color-variant products by specifying the **same Group Identification Key**
                                (e.g. `classic-tee-group`).
                            </p>
                            <div class="db-form-grid">
                                <div>
                                    <label class="db-label">Color Group Identification Key</label>
                                    <asp:TextBox ID="txtColorGroupKey" runat="server" CssClass="db-input"
                                        placeholder="e.g., premium-cotton-shirt-2026"></asp:TextBox>
                                </div>
                                <div>
                                    <label class="db-label">This Product's Color Label</label>
                                    <asp:TextBox ID="txtColorName" runat="server" CssClass="db-input"
                                        placeholder="e.g., Mustard Yellow"></asp:TextBox>
                                </div>
                                <div class="db-form-full" style="display: flex; gap: 15px; align-items: flex-end;">
                                    <div style="flex: 1;">
                                        <label class="db-label">Swatch Visual Color (Hex Code)</label>
                                        <asp:TextBox ID="txtColorCode" runat="server" CssClass="db-input"
                                            placeholder="#FFCC00" ClientIDMode="Static"></asp:TextBox>
                                    </div>
                                    <div style="width: 65px;">
                                        <label class="db-label">Picker</label>
                                        <input type="color" id="htmlColorPicker" class="db-input"
                                            style="height: 45px; padding: 2px; cursor: pointer; border: 1.5px solid #cbd5e1;"
                                            onchange="document.getElementById('txtColorCode').value = this.value.toUpperCase();" />
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- ==========================================
                 PANEL 3: SELLING PRICES & CEILINGS
                 ========================================== -->
                <div class="vt-panel" id="panel3">
                    <div class="db-form-card">
                        <div class="db-form-head">
                            <i class="fas fa-tags"></i>
                            <h3>Commercial Pricing Matrix</h3>
                        </div>

                        <div class="db-form-grid">
                            <div>
                                <label class="db-label">Selling Net Price (₹) *</label>
                                <asp:TextBox ID="txtPrice" runat="server" CssClass="db-input" placeholder="0.00">
                                </asp:TextBox>
                                <asp:RequiredFieldValidator ID="rfvPrice" runat="server" ControlToValidate="txtPrice"
                                    Display="Dynamic" ErrorMessage="🚨 Pricing target missing."
                                    CssClass="validator-error-text"></asp:RequiredFieldValidator>
                            </div>

                            <div>
                                <label class="db-label">Maximum Retail Price (M.R.P.) (₹) *</label>
                                <asp:TextBox ID="txtMrp" runat="server" CssClass="db-input" placeholder="0.00">
                                </asp:TextBox>
                                <asp:RequiredFieldValidator ID="rfvMrp" runat="server" ControlToValidate="txtMrp"
                                    Display="Dynamic" ErrorMessage="🚨 MRP ceiling missing."
                                    CssClass="validator-error-text"></asp:RequiredFieldValidator>
                            </div>
                        </div>
                    </div>

                    <!-- Card 3B: Dynamic Offer Strip Configurations (Attachment Mockup Replica) -->
                    <div class="db-form-card" style="margin-top: 25px;">
                        <div class="db-form-head"
                            style="margin-bottom: 25px; border-left: 4.5px solid #dc2626; padding-left: 18px; display: block;">
                            <h3 class="offer-strip-title">Offer strip</h3>
                            <span
                                style="font-size: 0.82rem; color:#888888; font-weight: 550; display: block; margin-top: 4px; letter-spacing: -0.1px;">Flash
                                line, countdown timer display, aur bank copy — optional.</span>
                        </div>

                        <div class="db-form-grid">
                            <div>
                                <label class="db-label" style="font-weight: 750; font-size: 0.82rem;">Flash offer
                                    text</label>
                                <asp:TextBox ID="txtFlashOfferText" runat="server" CssClass="db-input"
                                    placeholder="e.g., Flash deal ends in"></asp:TextBox>
                            </div>
                            <div>
                                <label class="db-label" style="font-weight: 750; font-size: 0.82rem;">Countdown
                                    (HH:MM:SS)</label>
                                <asp:TextBox ID="txtOfferCountdown" runat="server" CssClass="db-input"
                                    placeholder="48:00:00"></asp:TextBox>
                            </div>
                            <div class="db-form-full">
                                <label class="db-label" style="font-weight: 750; font-size: 0.82rem;">Card / bank offer
                                    text</label>
                                <asp:TextBox ID="txtBankOfferText" runat="server" CssClass="db-input"
                                    placeholder="Extra 10% off with HDFC card"></asp:TextBox>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- ==========================================
                 PANEL 4: ADVANCE (ATTRIBUTES & SEO)
                 ========================================== -->
                <div class="vt-panel" id="panel4">
                    <!-- Card 4A: Extra attributes -->
                    <div class="db-form-card" style="margin-bottom: 25px;">
                        <div class="db-form-head">
                            <i class="fas fa-palette"></i>
                            <h3>Parametric Options & Inventory Reserves</h3>
                        </div>
                        <div class="db-form-grid">
                            <div>
                                <label class="db-label">Color Configurations (Comma-separated)</label>
                                <asp:TextBox ID="txtColors" runat="server" CssClass="db-input"
                                    placeholder="Red, Navy Blue, Charcoal"></asp:TextBox>
                            </div>

                            <!-- Sizes input moved to Categories tab for dynamic context -->

                            <div id="divGlobalStock">
                                <label class="db-label">Warehouse Stock Reserves *</label>
                                <asp:TextBox ID="txtStock" runat="server" CssClass="db-input" placeholder="0"
                                    TextMode="Number" ClientIDMode="Static"></asp:TextBox>
                                <asp:RequiredFieldValidator ID="rfvStock" runat="server" ControlToValidate="txtStock"
                                    Display="Dynamic" ErrorMessage="🚨 Specify warehouse numeric reserves."
                                    CssClass="validator-error-text"></asp:RequiredFieldValidator>
                            </div>

                            <!-- Dynamic Size-wise Variant Stock Allocation Matrix -->
                            <div id="divVariantMatrix" class="db-form-full" style="display: none; margin-top: 10px;">
                                <div class="variant-matrix-header">
                                    <label class="db-label">
                                        <i class="fas fa-boxes" style="color: #3b82f6; margin-right: 5px;"></i>
                                        Size-wise Stock Allocation Matrix
                                    </label>
                                    <span class="matrix-total-badge" id="spnTotalSumDisplay">Total Sum: 0</span>
                                </div>

                                <div class="matrix-table-wrap">
                                    <table class="matrix-table">
                                        <thead>
                                            <tr class="matrix-table-head-row">
                                                <th style="padding: 10px;">Size Option</th>
                                                <th style="padding: 10px;">SKU Suffix (Optional)</th>
                                                <th style="padding: 10px; width: 110px;">Allocated Stock *</th>
                                                <th style="padding: 10px; width: 130px;">Extra Price Offset (₹)</th>
                                            </tr>
                                        </thead>
                                        <tbody id="variantMatrixBody">
                                            <!-- JavaScript Dynamically populates row cells -->
                                        </tbody>
                                    </table>
                                </div>
                                <p style="font-size: 0.7rem; color:#888888; margin-top: 6px; font-weight: 600;">
                                    💡 <strong>Tip:</strong> Stock values daalne par total apne aap upar calculate ho
                                    jayega. Extra Price ko zero rakh sakte hain agar same rate hai.
                                </p>
                                <asp:HiddenField ID="hfVariantData" runat="server" ClientIDMode="Static" />
                            </div>
                        </div>
                    </div>

                    <!-- Card 4M: Manufacturer Compliance Profiles -->
                    <div class="db-form-card">
                        <div class="db-form-head">
                            <i class="fas fa-industry"></i>
                            <h3>Manufacturer & Compliance Profiles</h3>
                        </div>
                        <div class="db-form-grid">
                            <div>
                                <label class="db-label">Manufacturer Name</label>
                                <asp:TextBox ID="txtMfgName" runat="server" CssClass="db-input"
                                    placeholder="e.g., ABC Industries Pvt Ltd"></asp:TextBox>
                            </div>

                            <div>
                                <label class="db-label">Country of Origin</label>
                                <asp:TextBox ID="txtMfgCountry" runat="server" CssClass="db-input"
                                    placeholder="e.g., India, Italy, Japan"></asp:TextBox>
                            </div>

                            <div class="db-form-full">
                                <label class="db-label">Full Address of the Manufacturer</label>
                                <asp:TextBox ID="txtMfgAddress" runat="server" CssClass="db-input" TextMode="MultiLine"
                                    Rows="2" placeholder="Complete factory layout / operational unit address...">
                                </asp:TextBox>
                            </div>
                        </div>
                    </div>

                    <!-- Card 4B: Search Discovery -->
                    <div class="db-form-card">
                        <div class="db-form-head">
                            <i class="fas fa-chart-line"></i>
                            <h3>Advanced Search Engine Optimization (SEO)</h3>
                        </div>
                        <div class="db-form-grid">
                            <div>
                                <label class="db-label">SERP Discovery Title (Meta Title)</label>
                                <asp:TextBox ID="txtMetaTitle" runat="server" CssClass="db-input"
                                    placeholder="Google crawler headline..."></asp:TextBox>
                            </div>

                            <div>
                                <label class="db-label">SERP Keyword Stream (Comma-separated)</label>
                                <asp:TextBox ID="txtMetaKeywords" runat="server" CssClass="db-input"
                                    placeholder="tags, tags, tags"></asp:TextBox>
                            </div>

                            <div class="db-form-full">
                                <label class="db-label">SERP Excerpt Snippet (Meta Description)</label>
                                <asp:TextBox ID="txtMetaDesc" runat="server" CssClass="db-textarea" TextMode="MultiLine"
                                    placeholder="Short descriptive snippet..."></asp:TextBox>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- ==========================================
                 PANEL 5: SHIPPING & PHYSICAL LOGISTICS
                 ========================================== -->
                <div class="vt-panel" id="panel5">
                    <div class="db-form-card">
                        <div class="db-form-head">
                            <i class="fas fa-location-dot"></i>
                            <h3>Logistics & Weight Matrix</h3>
                        </div>

                        <div class="db-form-grid">
                            <div>
                                <label class="db-label">Net Mass / Physical Weight</label>
                                <asp:TextBox ID="txtWeight" runat="server" CssClass="db-input"
                                    placeholder="e.g. 500g, 2.5kg"></asp:TextBox>
                            </div>

                            <div>
                                <label class="db-label">Volumetric Dimensions</label>
                                <asp:TextBox ID="txtDimensions" runat="server" CssClass="db-input"
                                    placeholder="L x W x H (cm)"></asp:TextBox>
                            </div>

                            <div class="db-form-full">
                                <label class="db-label">Carrier Shipping Class Tag</label>
                                <asp:TextBox ID="txtShipping" runat="server" CssClass="db-input"
                                    placeholder="Standard_Global_Express"></asp:TextBox>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- ==========================================
                 INTEGRATED FOOTER CONTROL BAR
                 ========================================== -->
                <footer class="vt-footer">
                    <!-- Left Control: Back button -->
                    <button type="button" class="vt-btn-next" id="btnPrev" onclick="prevStep()" style="display:none;">
                        <i class="fas fa-arrow-left"></i> Back Step
                    </button>
                    <div id="divSpacer" style="flex-grow:1;"></div>

                    <!-- Right Control: Next Button (Swapped for submit at last step) -->
                    <button type="button" class="vt-btn-next vt-btn-next-primary" id="btnNextStep" onclick="nextStep()">
                        Next Progression <i class="fas fa-arrow-right"></i>
                    </button>

                    <!-- Final Submission Unit -->
                    <div id="divSubmit" style="display:none;">
                        <asp:Button ID="btnSave" runat="server" CssClass="btn-save-catalog"
                            Text="🚀 Consolidate & Publish Catalog" OnClick="btnSave_Click"
                            OnClientClick="return validateStepZero();" style="margin:0;" />
                    </div>

                </footer>

            </div>
        </div>

        <!-- ==========================================
         INTERACTION & LAYOUT ANIMATION CONTROLLER
         ========================================== -->
        <script type="text/javascript">
            var currentTab = 0;
            var totalTabs = 6;

            // Slug auto-generator utility
            function generateSlug(text) {
                return text.toString().toLowerCase().trim()
                    .replace(/\s+/g, '-')           // Replace spaces with -
                    .replace(/[^\w\-]+/g, '')       // Remove all non-word chars
                    .replace(/\-\-+/g, '-')         // Replace multiple - with single -
                    .replace(/^-+/, '')             // Trim - from start of text
                    .replace(/-+$/, '');            // Trim - from end of text
            }

            document.addEventListener("DOMContentLoaded", function () {
                const nameField = document.getElementById('txtName');
                const slugField = document.getElementById('txtSlug');

                if (nameField && slugField) {
                    nameField.addEventListener('input', function () {
                        // Auto slugify ONLY on non-empty strings
                        if (this.value.trim() !== "") {
                            slugField.value = generateSlug(this.value);
                        } else {
                            slugField.value = "";
                        }
                    });
                }
            });

            function showTab(idx) {
                // 1. Cycle all content panels
                for (let i = 0; i < totalTabs; i++) {
                    let panel = document.getElementById('panel' + i);
                    let lnk = document.getElementById('lnkTab' + i);
                    if (i === idx) {
                        panel.classList.add('active');
                        lnk.classList.add('active');
                    } else {
                        panel.classList.remove('active');
                        lnk.classList.remove('active');
                    }
                }

                currentTab = idx;

                // 2. Handle Control Bar Toggle states
                const btnPrev = document.getElementById('btnPrev');
                const btnNext = document.getElementById('btnNextStep');
                const divSubmit = document.getElementById('divSubmit');

                if (idx === 0) {
                    btnPrev.style.display = 'none';
                } else {
                    btnPrev.style.display = 'inline-flex';
                }

                if (idx === (totalTabs - 1)) {
                    btnNext.style.display = 'none';
                    divSubmit.style.display = 'inline-flex';
                } else {
                    btnNext.style.display = 'inline-flex';
                    divSubmit.style.display = 'none';
                }

                // Smooth Scroll Up on mobile
                if (window.innerWidth <= 992) {
                    document.querySelector('.vt-layout').scrollIntoView({ behavior: 'smooth' });
                    
                    // Auto-scroll the active tab horizontally to center it in the mobile stepper menu
                    const activeLnk = document.getElementById('lnkTab' + idx);
                    if (activeLnk) {
                        activeLnk.scrollIntoView({ behavior: 'smooth', block: 'nearest', inline: 'center' });
                    }
                }
            }

            // Deep Content Integrity Check for Step 0
            function validateStepZero() {
                const nameBox = document.getElementById('<%= txtName.ClientID %>');
                const descBox = document.getElementById('<%= txtDesc.ClientID %>');

                const nameVal = nameBox.value.trim();
                const descVal = descBox.value.trim();

                // Split and filter out empty string blocks
                const nameWords = nameVal.split(/\s+/).filter(w => w.length > 0);
                const descWords = descVal.split(/\s+/).filter(w => w.length > 0);

                if (nameWords.length < 2) {
                    alert("🚨 Attention: Product Title me kam se kam 2 shabd likhna aniwarya hai (No single-word/character titles allowed)!");
                    nameBox.focus();
                    // Trigger ASP.NET visual error display immediately
                    if (typeof (Page_ClientValidate) === 'function') Page_ClientValidate();
                    return false;
                }

                if (descWords.length < 2) {
                    alert("🚨 Attention: Description narrative me kam se kam 2 shabd hone zaroori hain!");
                    descBox.focus();
                    if (typeof (Page_ClientValidate) === 'function') Page_ClientValidate();
                    return false;
                }

                return true;
            }

            function nextStep() {
                // Block progression if current active tab is Step 0 and content is shallow
                if (currentTab === 0) {
                    if (!validateStepZero()) return;
                }

                // AUTOMATED STATE MERGER: MARK PREVIOUS STEP AS COMPLETED BEFORE JUMPING FORWARD
                document.getElementById('lnkTab' + currentTab).classList.add('completed');

                if (currentTab < (totalTabs - 1)) {
                    showTab(currentTab + 1);
                }
            }


            function prevStep() {
                if (currentTab > 0) {
                    showTab(currentTab - 1);
                }
            }

            // SKU Switch Engine
            function toggleSkuMode(isAuto) {
                const inp = document.getElementById('divManualSkuInput');
                const hint = document.getElementById('divSkuHint');

                if (isAuto) {
                    inp.style.display = 'none';
                    hint.innerText = "Khali chhodoge to save par system SKU banayega (category + product name se).";
                } else {
                    inp.style.display = 'block';
                    hint.innerText = "Enter your manual SKU sequence strictly below.";
                }
            }

            // Run on initialization to match backend pre-load state
            window.addEventListener('DOMContentLoaded', () => {
                const rdoManual = document.getElementById('rdoSkuManual');
                if (rdoManual && rdoManual.checked) {
                    toggleSkuMode(false);
                } else {
                    toggleSkuMode(true);
                }

                // Sync the Native Color Picker with Text Field
                const txtCol = document.getElementById('txtColorCode');
                const pkrCol = document.getElementById('htmlColorPicker');
                if (txtCol && pkrCol) {
                    if (txtCol.value) {
                        pkrCol.value = txtCol.value;
                    }
                    txtCol.addEventListener('input', () => {
                        if (/^#[0-9A-F]{6}$/i.test(txtCol.value)) {
                            pkrCol.value = txtCol.value;
                        }
                    });
                }

                // Trigger handleTypeChange immediately to match backend preloaded values
                handleTypeChange();

                // Bind local Tab Link interceptors to prevent jumping forward without valid Step 0
                const tabLinks = document.querySelectorAll('.vt-tab-link');
                tabLinks.forEach((lnk, index) => {
                    lnk.removeAttribute('onclick');
                    lnk.addEventListener('click', () => {
                        if (currentTab === 0 && index > 0) {
                            if (!validateStepZero()) return;
                        }

                        // IF NAVIGATING FORWARD -> AUTOMATICALLY MARK LEAVING STEP AS COMPLETED!
                        if (index > currentTab) {
                            document.getElementById('lnkTab' + currentTab).classList.add('completed');
                        }

                        showTab(index);
                    });
                });

            });

            // Multi-Image Asset Orchestration
            function trackRemoval(dbPath, checkbox) {
                const hf = document.getElementById('hfRemovedGalleryUrls');
                let removedList = hf.value ? hf.value.split('|') : [];

                if (checkbox.checked) {
                    if (removedList.indexOf(dbPath) === -1) {
                        removedList.push(dbPath);
                    }
                } else {
                    removedList = removedList.filter(item => item !== dbPath);
                }

                hf.value = removedList.join('|');
            }

            function clearGallerySelections() {
                // 1. Untick all active deletion checks
                const checks = document.querySelectorAll('.ex-gal-remove-lbl input[type="checkbox"]');
                checks.forEach(c => c.checked = false);
                document.getElementById('hfRemovedGalleryUrls').value = '';

                // 2. Purge all inputs and clear labels
                document.getElementById('fuMain').value = '';
                document.getElementById('fuGallery').value = '';

                document.getElementById('spnMainName').innerText = '';
                document.getElementById('spnMainName').style.display = 'none';
                document.getElementById('iconMain').style.color = '#94a3b8';

                document.getElementById('spnGalSummary').innerText = '';
                document.getElementById('spnGalSummary').style.display = 'none';
                document.getElementById('iconGal').style.color = '#94a3b8';
            }

            // Dynamic Sizes Orchestrator (New Catalog Feature)
            function handleTypeChange() {
                const ddl = document.getElementById('ddlProductType');
                if (!ddl) return;
                const val = ddl.value;

                // Hide all grids and reset their ticks to prevent 'ghost checkboxes' from leaking
                const allGrids = document.querySelectorAll('.size-check-grid');
                allGrids.forEach(grid => {
                    grid.style.display = 'none';
                    grid.querySelectorAll('input[type="checkbox"]').forEach(c => c.checked = false);
                });

                // Resolve and display target active grid
                let targetGridId = '';
                if (val === 'Jeans') targetGridId = 'grpJeansSizes';
                else if (val === 'Shirt') targetGridId = 'grpShirtSizes';
                else if (val === 'Shoes') targetGridId = 'grpShoesSizes';
                else if (val === 'Watch') targetGridId = 'grpWatchSizes';
                else if (val === 'Bag') targetGridId = 'grpBagSizes';
                else if (val === 'Accessories') targetGridId = 'grpAccessoriesSizes';

                if (targetGridId) {
                    const activeGrid = document.getElementById(targetGridId);
                    if (activeGrid) activeGrid.style.display = 'flex';
                }

                // Populate ticks only in newly activated grid from raw txtSizes value
                syncChecksFromText();
            }

            function syncSizes() {
                const txt = document.getElementById('txtSizes');
                if (!txt) return;

                // 1. Isolate operation STRICTLY to the active visible grid!
                const container = document.querySelector('.size-config-card');
                if (!container) return;
                const activeGrid = Array.from(container.querySelectorAll('.size-check-grid')).find(g => g.style.display === 'flex');
                if (!activeGrid) return;

                // 2. Mutual Exclusion Logic within Active Context Only
                const event = window.event;
                if (event && event.target && event.target.type === 'checkbox' && event.target.checked) {
                    const clickedBox = event.target;
                    const boxVal = clickedBox.value.toUpperCase();
                    const isExclusive = ['FREE SIZE', 'ONE SIZE', 'STANDARD'].includes(boxVal);

                    const checkboxes = activeGrid.querySelectorAll('input[type="checkbox"]');
                    checkboxes.forEach(c => {
                        if (c === clickedBox) return;
                        const otherVal = c.value.toUpperCase();
                        const otherIsExclusive = ['FREE SIZE', 'ONE SIZE', 'STANDARD'].includes(otherVal);

                        if (isExclusive) {
                            c.checked = false;
                        } else if (!isExclusive && otherIsExclusive) {
                            c.checked = false;
                        }
                    });
                }

                // 3. Rebuild CSV String ONLY reading the isolated active grid
                const checkboxes = activeGrid.querySelectorAll('input[type="checkbox"]:checked');
                const values = Array.from(checkboxes).map(c => c.value.trim());

                txt.value = values.join(', ');
                renderVariantMatrix();
            }

            function syncChecksFromText() {
                const txt = document.getElementById('txtSizes');
                if (!txt) return;

                const rawText = txt.value || '';
                const currentValues = rawText.split(',').map(s => s.trim().toUpperCase());

                const container = document.querySelector('.size-config-card');
                if (!container) return;

                // Isolate ticks activation strictly to the currently active visible grid!
                const activeGrid = Array.from(container.querySelectorAll('.size-check-grid')).find(g => g.style.display === 'flex');
                if (!activeGrid) return;

                const checkboxes = activeGrid.querySelectorAll('input[type="checkbox"]');
                checkboxes.forEach(c => {
                    if (currentValues.includes(c.value.toUpperCase())) {
                        c.checked = true;
                    } else {
                        c.checked = false;
                    }
                });
                renderVariantMatrix();
            }

            // ====================================================
            // ADVANCED: Dynamic Size Variant Matrix Syncing Engine
            // ====================================================
            function renderVariantMatrix() {
                const txtSizes = document.getElementById('txtSizes');
                const divMatrix = document.getElementById('divVariantMatrix');
                const divStock = document.getElementById('divGlobalStock');
                const matrixBody = document.getElementById('variantMatrixBody');
                const txtTotalStock = document.getElementById('txtStock');

                if (!txtSizes || !divMatrix || !matrixBody) return;

                const rawText = txtSizes.value || '';
                const sizes = rawText.split(',')
                    .map(s => s.trim())
                    .filter(s => s.length > 0);

                // If no sizes selected, hide matrix & enable manual stock input
                if (sizes.length === 0) {
                    divMatrix.style.display = 'none';
                    if (divStock) divStock.style.display = 'block';
                    if (txtTotalStock) {
                        txtTotalStock.readOnly = false;
                        txtTotalStock.style.background = '';
                        txtTotalStock.style.cursor = '';
                    }
                    return;
                }

                // Show the Matrix grid and set total stock text box as read-only!
                divMatrix.style.display = 'block';
                if (txtTotalStock) {
                    txtTotalStock.readOnly = true;
                    txtTotalStock.style.background = '#f8fafc';
                    txtTotalStock.style.cursor = 'not-allowed';
                }

                // Parse existing configurations to retain values during multi-click sessions
                const existingData = parseVariantData();

                matrixBody.innerHTML = '';
                sizes.forEach(size => {
                    const sizeUpper = size.toUpperCase();
                    const data = existingData[sizeUpper] || { sku: '', stock: '0', price: '0.00' };

                    const tr = document.createElement('tr');
                    tr.style.borderBottom = '1px solid #e2e8f0';

                    tr.innerHTML = `
                        <td style="padding: 10px; font-weight: 700; color: #0f172a;">${size}</td>
                        <td style="padding: 8px;">
                            <input type="text" class="db-input js-mat-sku" value="${data.sku}" placeholder="e.g., -${size}" 
                                style="padding: 6px 10px; font-size:0.75rem; width: 100%; max-width: 130px; height: 36px;" 
                                data-size="${size}" oninput="serializeVariantData();" />
                        </td>
                        <td style="padding: 8px;">
                            <input type="number" class="db-input js-mat-stock" value="${data.stock}" min="0"
                                style="padding: 6px 10px; font-size:0.75rem; width: 100px; height: 36px; text-align:center; font-weight:700;" 
                                data-size="${size}" oninput="calculateTotalStockSum(); serializeVariantData();" />
                        </td>
                        <td style="padding: 8px;">
                            <input type="number" class="db-input js-mat-price" value="${data.price}" step="0.01" min="0"
                                style="padding: 6px 10px; font-size:0.75rem; width: 120px; height: 36px; text-align:center;" 
                                data-size="${size}" oninput="serializeVariantData();" />
                        </td>
                    `;
                    matrixBody.appendChild(tr);
                });

                // Run final sum recalculation & lock string state
                calculateTotalStockSum();
                serializeVariantData();
            }

            function serializeVariantData() {
                const matrixBody = document.getElementById('variantMatrixBody');
                const hf = document.getElementById('hfVariantData');
                if (!matrixBody || !hf) return;

                const rows = matrixBody.querySelectorAll('tr');
                let serializedParts = [];

                rows.forEach(tr => {
                    if (tr.cells.length < 1) return;
                    const sizeTd = tr.cells[0].innerText.trim();
                    const skuInput = tr.querySelector('.js-mat-sku');
                    const stockInput = tr.querySelector('.js-mat-stock');
                    const priceInput = tr.querySelector('.js-mat-price');

                    if (skuInput && stockInput && priceInput) {
                        const sku = skuInput.value.trim() || '';
                        const stock = stockInput.value.trim() || '0';
                        const price = priceInput.value.trim() || '0.00';
                        serializedParts.push(`${sizeTd}:${stock}:${sku}:${price}`);
                    }
                });

                hf.value = serializedParts.join('|');
            }

            function parseVariantData() {
                const hf = document.getElementById('hfVariantData');
                const dataMap = {};
                if (!hf || !hf.value) return dataMap;

                const parts = hf.value.split('|');
                parts.forEach(p => {
                    const segments = p.split(':');
                    if (segments.length >= 4) {
                        const size = segments[0].trim().toUpperCase();
                        dataMap[size] = {
                            stock: segments[1].trim(),
                            sku: segments[2].trim(),
                            price: segments[3].trim()
                        };
                    }
                });
                return dataMap;
            }

            function calculateTotalStockSum() {
                const matrixBody = document.getElementById('variantMatrixBody');
                const txtTotalStock = document.getElementById('txtStock');
                const spnTotal = document.getElementById('spnTotalSumDisplay');
                if (!matrixBody || !txtTotalStock) return;

                const stockInputs = matrixBody.querySelectorAll('.js-mat-stock');
                let total = 0;
                stockInputs.forEach(inp => {
                    const val = parseInt(inp.value) || 0;
                    total += val;
                });

                txtTotalStock.value = total;
                if (spnTotal) {
                    spnTotal.innerText = 'Total Sum: ' + total;
                }
            }

        </script>


    </asp:Content>