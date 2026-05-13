<%@ Page Title="Catalog Configuration Console" Language="C#" MasterPageFile="~/seller/Seller.Master"
    AutoEventWireup="true" CodeFile="AddEditProduct.aspx.cs" Inherits="EcommerceWebsite.SellerAddEditProduct" %>

    <asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

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
                            <asp:TextBox ID="txtName" runat="server" CssClass="db-input" placeholder="Product title">
                            </asp:TextBox>
                            <span class="sku-sub-hint" style="display:block; margin-top:5px;">Kam se kam 2 shabd (sirf
                                ek letter ya ek shabd se Next / Submit nahi hoga).</span>
                            <asp:RequiredFieldValidator ID="rfvName" runat="server" ControlToValidate="txtName"
                                Display="Dynamic" ErrorMessage="🚨 Product title is required." SetFocusOnError="true"
                                CssClass="validator-error-text"></asp:RequiredFieldValidator>
                        </div>

                        <div class="db-form-full">
                            <label class="db-label">Description</label>
                            <div style="border: 1.5px solid #e2e8f0; border-radius: 12px; overflow:hidden;">
                                <!-- Toolbar Mock-up similar to image -->
                                <div
                                    style="background: #f8fafc; padding: 8px 15px; border-bottom: 1.5px solid #e2e8f0; display:flex; align-items:center; gap:15px; color:#64748b; font-size:0.85rem;">
                                    <span style="font-weight:700;">Normal <i class="fas fa-caret-down"></i></span>
                                    <span style="width:1px; height:15px; background:#e2e8f0;"></span>
                                    <i class="fas fa-bold" style="cursor:pointer;"></i>
                                    <i class="fas fa-italic" style="cursor:pointer;"></i>
                                    <i class="fas fa-underline" style="cursor:pointer;"></i>
                                    <i class="fas fa-strikethrough" style="cursor:pointer;"></i>
                                    <span style="width:1px; height:15px; background:#e2e8f0;"></span>
                                    <i class="fas fa-list-ul" style="cursor:pointer;"></i>
                                    <i class="fas fa-list-ol" style="cursor:pointer;"></i>
                                    <span style="width:1px; height:15px; background:#e2e8f0;"></span>
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
                                <label class="db-label" style="color: #1e293b; font-weight:700;">Product Image</label>
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
                                <label class="db-label" style="color: #1e293b; font-weight:700;">Product Gallery</label>
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
                                <div style="font-size: 0.78rem; color: #64748b; font-weight:600; margin-top: 8px;">
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
                                <label class="db-label">Product Type Class</label>
                                <asp:DropDownList ID="ddlProductType" runat="server" CssClass="db-select">
                                    <asp:ListItem Value="Simple">Simple Physical Product</asp:ListItem>
                                    <asp:ListItem Value="Variable">Variable Configurable Product</asp:ListItem>
                                    <asp:ListItem Value="Digital">Digital Goods / Virtual</asp:ListItem>
                                </asp:DropDownList>
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

                            <div>
                                <label class="db-label">Dimension Sizes (Comma-separated)</label>
                                <asp:TextBox ID="txtSizes" runat="server" CssClass="db-input"
                                    placeholder="S, M, L, XL, 40, 42"></asp:TextBox>
                            </div>

                            <div class="db-form-full">
                                <label class="db-label">Warehouse Stock Reserves *</label>
                                <asp:TextBox ID="txtStock" runat="server" CssClass="db-input" placeholder="0"
                                    TextMode="Number"></asp:TextBox>
                                <asp:RequiredFieldValidator ID="rfvStock" runat="server" ControlToValidate="txtStock"
                                    Display="Dynamic" ErrorMessage="🚨 Specify warehouse numeric reserves."
                                    CssClass="validator-error-text"></asp:RequiredFieldValidator>
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
                            <div class="db-form-full">
                                <label class="db-label">SERP Discovery Title (Meta Title)</label>
                                <asp:TextBox ID="txtMetaTitle" runat="server" CssClass="db-input"
                                    placeholder="Google crawler headline..."></asp:TextBox>
                            </div>

                            <div class="db-form-full">
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

        </script>


    </asp:Content>