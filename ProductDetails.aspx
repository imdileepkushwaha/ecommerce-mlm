<%@ Page Title="Product Details" Language="C#" MasterPageFile="~/usersite.Master" AutoEventWireup="true"
    CodeFile="ProductDetails.aspx.cs" Inherits="ecommerce_mlm.ProductDetails" %>

    <asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
        <style>
            /* Unique styles embedded directly for specificity */
            .oos-large-banner {
                background: #fee2e2;
                color: #ef4444;
                border: 1px solid #fecaca;
                padding: 20px;
                border-radius: 12px;
                font-weight: 800;
                text-align: center;
                font-size: 1.2rem;
                letter-spacing: 1px;
                box-shadow: inset 0 0 10px rgba(239,68,68,0.05);
                display: flex;
                align-items: center;
                justify-content: center;
                gap: 10px;
                width: 100%;
            }
            .pd-color-ball.active {
                outline: 2px solid #000;
                outline-offset: 2px;
                transform: scale(1.1);
                box-shadow: 0 0 8px rgba(0,0,0,0.2);
                display: flex !important;
                align-items: center;
                justify-content: center;
            }
            .pd-color-ball {
                transition: all 0.2s ease;
            }
            .pd-color-anchor {
                text-decoration: none !important;
                display: inline-block;
            }
            .pd-color-ball:hover {
                transform: scale(1.15);
            }
        </style>
    </asp:Content>

    <asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

        <!-- Breadcrumb Container -->
        <div class="dashboard-breadcrumb">
            <div class="container">
                <div class="dashboard-breadcrumb-inner">
                    <div class="breadcrumb-left">
                        <h3>
                            <asp:Literal ID="litBTitle" runat="server">Product</asp:Literal>
                        </h3>


                    </div>

                    <div class="breadcrumb-right">
                        <a href="index.aspx"><i class="fas fa-home"></i></a>
                        <span> / Product</span>

                    </div>


                </div>
            </div>
        </div>

        <section class="pd-container">
            <div class="container">
                <div class="pd-grid">

                    <!-- LEFT: GALLERY SECTION -->
                    <div class="pd-gallery">
                        <div class="pd-thumbs">
                            <div class="pd-thumb-item active js-thumb" data-src='<%= mainImageUrl %>'>
                                <img src="<%= mainImageUrl %>" alt="Thumbnail" />
                            </div>
                            <asp:Repeater ID="rptGallery" runat="server">
                                <ItemTemplate>
                                    <div class="pd-thumb-item js-thumb" data-src='<%# Container.DataItem.ToString() %>'>
                                        <img src='<%# Container.DataItem.ToString() %>' alt="Gallery" />
                                    </div>
                                </ItemTemplate>
                            </asp:Repeater>

                        </div>
                        <div class="pd-main-image">
                            <img src="<%= mainImageUrl %>" id="mainProdImg" alt="Main Image" />
                        </div>
                    </div>

                    <!-- RIGHT: PRODUCT INFO SECTION -->
                    <div class="pd-info">
                        <div class="pd-top-tags">
                            <div class="pd-tag-sale" runat="server" id="divBadge"><i class="fas fa-tags" id="iconBadge" runat="server"></i>
                                <asp:Literal ID="litBadge" runat="server">Sale Available</asp:Literal>
                            </div>
                            <div class="sold-badge"><i class="fas fa-fire"></i>
                                <%= dynamicSoldCount %> SOLD IN LAST 24H
                            </div>
                        </div>
                        <h1 class="pd-title">
                            <asp:Literal ID="litName" runat="server"></asp:Literal>
                        </h1>

                        <div class="pd-meta-short">
                            <span><i class="far fa-user"></i> Sold by: <a href='SellerStore.aspx?id=<%= activeSellerId %>' style="color:#3b82f6; font-weight:700; text-decoration:none;">
                                    <asp:Literal ID="litBrandDisplay" runat="server"></asp:Literal>
                                </a></span>
                            <span>|</span>
                            <span style="color:#f59e0b;"><i class="fas fa-star"></i><i class="fas fa-star"></i><i
                                    class="fas fa-star"></i><i class="fas fa-star"></i><i
                                    class="fas fa-star-half-alt"></i> (4.8)</span>
                            <span>|</span>
                            <span style="font-size:13px;">
                                <asp:Literal ID="litMainRevCount" runat="server">(0 Reviews)</asp:Literal>
                            </span>
                        </div>

                        <!-- DYNAMIC FLASH DEAL WIDGET -->
                        <asp:Panel ID="pnlFlashOffer" runat="server" CssClass="flash-deal-box" Visible="false">
                            <div class="flash-deal-txt">
                                <i class="fas fa-stopwatch fa-spin"></i> <asp:Literal ID="litFlashOfferText" runat="server"></asp:Literal>
                            </div>
                            <div class="flash-timer-wrap">
                                <div class="flash-unit" id="timer-h">00</div> :
                                <div class="flash-unit" id="timer-m">00</div> :
                                <div class="flash-unit" id="timer-s">00</div>
                            </div>
                            <asp:HiddenField ID="hfOfferSeconds" runat="server" Value="0" ClientIDMode="Static" />
                        </asp:Panel>

                        <div class="seller-offers-wrapper">
                            <!-- Dynamic Bank Offer Added from Console -->
                            <asp:Panel ID="pnlBankOffer" runat="server" CssClass="offer-card" Visible="false" style="border-left: 3px solid #2563eb; background: #eff6ff;">
                                <div class="offer-icon-circle" style="background: #2563eb; color: #fff;"><i class="fas fa-university"></i></div>
                                <div class="offer-content">
                                    <h5 style="color: #1e3a8a;">Instant Bank/Card Offer</h5>
                                    <p style="color: #1e40af; font-weight: 600;">
                                        <asp:Literal ID="litBankOfferText" runat="server"></asp:Literal>
                                    </p>
                                </div>
                            </asp:Panel>

                            <div class="offer-card">
                                <div class="offer-icon-circle"><i class="fas fa-percent"></i></div>
                                <div class="offer-content">
                                    <h5>Special Instant Offer</h5>
                                    <p>
                                        <asp:Literal ID="litOffer1" runat="server"></asp:Literal>
                                    </p>
                                </div>
                            </div>
                            <div class="offer-card">
                                <div class="offer-icon-circle"><i class="fas fa-credit-card"></i></div>
                                <div class="offer-content">
                                    <h5>Digital Payments Offer</h5>
                                    <p>
                                        <asp:Literal ID="litOffer2" runat="server"></asp:Literal>
                                    </p>
                                </div>
                            </div>
                        </div>

                        <div class="pd-pricing-row">
                            <div class="pd-price-now">₹ <asp:Literal ID="litPrice" runat="server"></asp:Literal>
                            </div>
                            <div>
                                <span class="pd-price-old">₹ <asp:Literal ID="litMrp" runat="server"></asp:Literal>
                                </span>
                                <asp:Label ID="litDiscountPill" runat="server" CssClass="discount-pill-pd"></asp:Label>
                            </div>
                        </div>

                        <!-- Color Options dynamic -->
                        <!-- Legacy Simple String-based Colors -->
                        <asp:Panel ID="pnlColors" runat="server" CssClass="pd-option-group">
                            <span class="pd-opt-label">Color Selection</span>
                            <div class="pd-opt-list">
                                <asp:Repeater ID="rptColors" runat="server">
                                    <ItemTemplate>
                                        <div class="pd-color-ball"
                                            style='<%# "background-color:" + Container.DataItem.ToString() %>'
                                            title='<%# Container.DataItem.ToString() %>'
                                            onclick="selectOpt(this, 'color')"></div>
                                    </ItemTemplate>
                                </asp:Repeater>
                            </div>
                        </asp:Panel>

                        <!-- Color Variant Group Linking System (Multi-Product Page Switcher) -->
                        <asp:Panel ID="pnlGroupColors" runat="server" CssClass="pd-option-group" Visible="false">
                            <span class="pd-opt-label">Available Colors</span>
                            <div class="pd-opt-list">
                                <asp:Repeater ID="rptGroupColors" runat="server">
                                    <ItemTemplate>
                                        <a href='ProductDetails.aspx?slug=<%# Eval("Slug") %>' class="pd-color-anchor" 
                                           title='<%# Eval("ColorName") %>'>
                                            <div class='<%# "pd-color-ball" + (Eval("Id").ToString() == productId.ToString() ? " active" : "") %>'
                                                 style='<%# "background-color:" + Eval("ColorCode") %>'>
                                                 <%# Eval("Id").ToString() == productId.ToString() ? "<i class=\"fas fa-check\" style=\"color:#fff; font-size:9px; text-shadow: 0 1px 2px rgba(0,0,0,0.5);\"></i>" : "" %>
                                            </div>
                                        </a>
                                    </ItemTemplate>
                                </asp:Repeater>
                            </div>
                        </asp:Panel>

                        <!-- Size Options dynamic -->
                        <asp:Panel ID="pnlSizes" runat="server" CssClass="pd-option-group">
                            <span class="pd-opt-label">Size Choice</span>
                            <div class="pd-opt-list">
                                <asp:Repeater ID="rptSizes" runat="server">
                                    <ItemTemplate>
                                        <div class="pd-size-box" data-stock='<%# Eval("Stock") %>' onclick="selectOpt(this, 'size')">
                                            <%# Eval("Name") %>
                                        </div>
                                    </ItemTemplate>
                                </asp:Repeater>
                            </div>
                        </asp:Panel>

                        <% if (isAvailable) { %>
                        <div class="pd-stock-alert" id="js-stock-alert"><i class="fas fa-fire"></i> Hurry! Only <%= productStock %> units left in stock.</div>
                        <% } else { %>
                        <div class="pd-stock-alert" style="color:#ef4444; background:#fee2e2;"><i class="fas fa-exclamation-triangle"></i> This product is currently suspended or out of stock.</div>
                        <% } %>

                        <!-- Quantity & Action Buttons -->
                        <div class="pd-actions-wrap">
                            <% if (isAvailable) { %>
                                <div class="qty-ctrl">
                                    <button type="button" class="qty-btn" onclick="updateQty(-1)">-</button>
                                    <input type="text" id="txtQty" value="1" class="qty-input" readonly />
                                    <button type="button" class="qty-btn" onclick="updateQty(1)">+</button>
                                </div>

                                <button type="button" class="pd-add-to-cart" onclick="processCartAction(false)">
                                    <i class="fas fa-shopping-bag"></i> Add to Cart — ₹ <span id="js-live-total">
                                        <asp:Literal ID="litActionPrice" runat="server"></asp:Literal>
                                    </span>
                                </button>
                            <% } else { %>
                                <div class="oos-large-banner">
                                    <i class="fas fa-ban"></i> CURRENTLY OUT OF STOCK
                                </div>
                            <% } %>

                            <div class="pd-wish-share">
                                <div class="pd-icon-circle js-wish-heart" title="Wishlist" onclick="addToWishlist()"><i
                                        class="far fa-heart"></i></div>
                                <div class="pd-icon-circle" title="Share" onclick="toggleShareModal(true)"><i
                                        class="fas fa-share-alt"></i></div>
                            </div>
                        </div>

                        <div class="pd-badges-row">
                            <div class="pd-badge-pill pill-blue"><i class="fas fa-shipping-fast"></i> Free Delivery
                            </div>
                            <div class="pd-badge-pill pill-green"><i class="fas fa-history"></i> 10 Days Return</div>
                            <div class="pd-badge-pill pill-orange"><i class="fas fa-shield-alt"></i> Secure Payment
                            </div>
                        </div>
                    </div>
                </div>

                <!-- MIDDLE SECTION: TABS & SPEC CARD -->
                <div class="pd-details-extra">
                    <div class="pd-spec-card">
                        <h4 style="margin-top:0; font-weight:800; font-size:16px; margin-bottom:20px;">Additional
                            Information:</h4>
                        <table class="spec-table">
                            <tr>
                                <td class="spec-key">Brand</td>
                                <td class="spec-val">
                                    <asp:Literal ID="sBrand" runat="server"></asp:Literal>
                                </td>
                            </tr>
                            <tr>
                                <td class="spec-key">Category</td>
                                <td class="spec-val">
                                    <asp:Literal ID="sCat" runat="server"></asp:Literal>
                                </td>
                            </tr>
                            <tr>
                                <td class="spec-key">Gender</td>
                                <td class="spec-val">
                                    <asp:Literal ID="sGen" runat="server"></asp:Literal>
                                </td>
                            </tr>
                            <tr>
                                <td class="spec-key">Product Type</td>
                                <td class="spec-val">
                                    <asp:Literal ID="sPType" runat="server"></asp:Literal>
                                </td>
                            </tr>
                            <tr>
                                <td class="spec-key">Weight</td>
                                <td class="spec-val">
                                    <asp:Literal ID="sWeight" runat="server"></asp:Literal>
                                </td>
                            </tr>
                            <tr>
                                <td class="spec-key">Dimensions</td>
                                <td class="spec-val">
                                    <asp:Literal ID="sDim" runat="server"></asp:Literal>
                                </td>
                            </tr>
                            <tr>
                                <td class="spec-key">SKU Code</td>
                                <td class="spec-val">
                                    <asp:Literal ID="sSku" runat="server"></asp:Literal>
                                </td>
                            </tr>
                        </table>
                    </div>

                    <div class="pd-tabs-wrap">
                        <div class="pd-tab-headers">
                            <div class="tab-head-item active" onclick="switchTab(0)">Description</div>
                            <div class="tab-head-item" onclick="switchTab(1)">Manufacturer</div>
                            <div class="tab-head-item" onclick="switchTab(2)">Reviews <asp:Literal ID="litRevCountTab"
                                    runat="server"></asp:Literal>
                            </div>
                        </div>
                        <div class="tab-content-body">
                            <!-- PANE 0 -->
                            <div class="tab-pane active">
                                <h3 style="margin-top:0; color:#0f172a; font-weight:800;">Detailed Overview</h3>
                                <div style="white-space:pre-line;">
                                    <asp:Literal ID="litFullDesc" runat="server"></asp:Literal>
                                </div>
                            </div>
                            <!-- PANE 1 -->
                            <div class="tab-pane">
                                <h3 style="margin-top:0; color:#0f172a; font-weight:800; margin-bottom: 20px;"><i class="fas fa-industry" style="color:#f97316; margin-right:8px;"></i>Manufacturer & Compliance Data</h3>
                                <div class="mfg-info-container" style="background:#f8fafc; border: 1px solid #e2e8f0; border-radius:12px; padding: 24px; display:grid; gap: 16px;">
                                    
                                    <div style="display:flex; align-items:baseline; gap:12px;">
                                        <div style="font-weight:700; color:#475569; width: 180px; flex-shrink:0;"><i class="fas fa-building" style="font-size: 0.85rem; width:16px; margin-right:6px; color:#64748b;"></i> Manufacturer:</div>
                                        <div style="color:#0f172a; font-weight:600;"><asp:Literal ID="litMfgName" runat="server" Text="Not Specified"></asp:Literal></div>
                                    </div>

                                    <div style="display:flex; align-items:baseline; gap:12px;">
                                        <div style="font-weight:700; color:#475569; width: 180px; flex-shrink:0;"><i class="fas fa-earth-americas" style="font-size: 0.85rem; width:16px; margin-right:6px; color:#64748b;"></i> Country of Origin:</div>
                                        <div style="color:#0f172a; font-weight:600;"><asp:Literal ID="litMfgCountry" runat="server" Text="Not Specified"></asp:Literal></div>
                                    </div>

                                    <div style="display:flex; align-items:baseline; gap:12px;">
                                        <div style="font-weight:700; color:#475569; width: 180px; flex-shrink:0;"><i class="fas fa-location-dot" style="font-size: 0.85rem; width:16px; margin-right:6px; color:#64748b;"></i> Registered Address:</div>
                                        <div style="color:#0f172a; font-weight:600; line-height:1.5;"><asp:Literal ID="litMfgAddress" runat="server" Text="Not Specified"></asp:Literal></div>
                                    </div>

                                </div>
                            </div>
                            <!-- PANE 2 -->
                            <div class="tab-pane">
                                <div class="reviews-summary-bar">
                                    <h3 style="margin:0; color:#0f172a; font-weight:800;">
                                        <asp:Literal ID="litRevCountSummary" runat="server"></asp:Literal>
                                    </h3>
                                    <button type="button" class="btn-open-rev-form" onclick="toggleRevForm()">Write A
                                        Review</button>
                                </div>

                                <!-- Submission Form (Hidden initially) -->
                                <div class="review-form-container" id="revFormContainer">
                                    <h4 style="margin-top:0; margin-bottom:15px;">Write Your Feedback</h4>
                                    <div class="rev-form-row">
                                        <label class="rev-form-lbl">Rating (1 to 5)</label>
                                        <div class="star-rating-picker" id="starPicker">
                                            <i class="far fa-star active" data-val="1" onclick="setRating(1)"></i>
                                            <i class="far fa-star" data-val="2" onclick="setRating(2)"></i>
                                            <i class="far fa-star" data-val="3" onclick="setRating(3)"></i>
                                            <i class="far fa-star" data-val="4" onclick="setRating(4)"></i>
                                            <i class="far fa-star" data-val="5" onclick="setRating(5)"></i>
                                        </div>
                                        <input type="hidden" id="hdnRating" value="1" />
                                    </div>
                                    <div class="rev-form-row">
                                        <label class="rev-form-lbl">Your Name</label>
                                        <input type="text" class="rev-inp" id="txtRevName" placeholder="Enter name" />
                                    </div>
                                    <div class="rev-form-row">
                                        <label class="rev-form-lbl">Message</label>
                                        <textarea class="rev-inp" id="txtRevMsg" rows="3"
                                            placeholder="Tell us about the product"></textarea>
                                    </div>
                                    <button type="button" class="pd-add-to-cart"
                                        style="font-size:14px; padding:10px 20px; width:auto;"
                                        onclick="submitReview()">Post Review</button>
                                </div>

                                <asp:Panel ID="pnlNoReviews" runat="server"
                                    style="padding: 40px 20px; background: #f8fafc; border: 1px dashed #cbd5e1; border-radius:12px; text-align:center; color:#64748b; display:flex; flex-direction:column; align-items:center; gap:10px;">
                                    <div
                                        style="width:50px; height:50px; background:#e2e8f0; border-radius:50%; display:flex; align-items:center; justify-content:center; font-size:20px; color:#475569;">
                                        <i class="far fa-comments"></i>
                                    </div>
                                    <h4 style="margin:0; color:#334155;">No Reviews Yet</h4>
                                    <p style="margin:0; font-size:13px;">Be the first one to share your experience about
                                        this product!</p>
                                </asp:Panel>

                                <div class="review-item-list">
                                    <asp:Repeater ID="rptReviews" runat="server">
                                        <ItemTemplate>
                                            <div class="single-review">
                                                <div class="rev-hdr">
                                                    <div class="rev-user"><i class="fas fa-user-circle"></i>
                                                        <%# Eval("ReviewerName") %>
                                                    </div>
                                                    <div class="rev-stars">
                                                        <%# RenderRevStars(Eval("Rating")) %>
                                                    </div>
                                                </div>
                                                <div class="rev-text">"<%# Eval("ReviewText") %>"</div>
                                                <div class="rev-date">
                                                    <%# Convert.ToDateTime(Eval("ReviewDate")).ToString("dd MMM yyyy")
                                                        %>
                                                </div>
                                            </div>
                                        </ItemTemplate>
                                    </asp:Repeater>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- BOTTOM SECTION: RELATED PRODUCTS -->
                <div class="pd-related-sec">
                    <div class="category-header mb-30">
                        <div class="category-title-area">
                            <h2 class="category-main-title">Related Products</h2>
                        </div>
                    </div>

                    <div class="pl-grid">
                        <asp:Repeater ID="rptRelated" runat="server">
                            <ItemTemplate>
                                <div class="product-card">
                                    <div class="product-card-img">
                                        <img src='<%# ResolveUrl(Eval("MainImage").ToString()) %>'
                                            alt='<%# Eval("Name") %>' />
                                        <div class="product-actions">
                                            <a href='<%# "ProductDetails.aspx?slug=" + Eval("Slug") %>'
                                                class="action-btn"><i class="far fa-eye"></i></a>
                                        </div>
                                    </div>
                                    <div class="product-card-body">
                                        <div class="prod-rating"><i class="fas fa-star"></i><i
                                                class="fas fa-star"></i><i class="fas fa-star"></i><span>(4.5)</span>
                                        </div>
                                        <span class="prod-brand">
                                            <%# Eval("Brand") %>
                                        </span>
                                        <h3><a href='<%# "ProductDetails.aspx?slug=" + Eval("Slug") %>'>
                                                <%# Eval("Name") %>
                                            </a></h3>
                                        <div class="prod-pricing">
                                            <span class="current-price">₹ <%#
                                                    Convert.ToDecimal(Eval("Price")).ToString("N0") %></span>
                                        </div>
                                        <div class="prod-action-row">
                                            <a href='<%# "ProductDetails.aspx?slug=" + Eval("Slug") %>'
                                                class="buy-now-btn">View Details</a>
                                        </div>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </div>

            </div>
        </section>

        <!-- SHARE MODAL -->
        <div class="share-modal-backdrop" id="shareModal">
            <div class="share-modal">
                <div class="share-hdr">
                    <h4>Share this Product</h4>
                    <div class="share-close" onclick="toggleShareModal(false)"><i class="fas fa-times"></i></div>
                </div>
                <div class="share-options-grid">
                    <a href="#" id="linkWa" target="_blank" class="share-opt-item">
                        <div class="share-icon-wrap wa"><i class="fab fa-whatsapp"></i></div>
                        <span>WhatsApp</span>
                    </a>
                    <a href="#" id="linkMail" target="_blank" class="share-opt-item">
                        <div class="share-icon-wrap mail"><i class="far fa-envelope"></i></div>
                        <span>Email</span>
                    </a>
                    <a href="#" id="linkFb" target="_blank" class="share-opt-item">
                        <div class="share-icon-wrap fb"><i class="fab fa-facebook-f"></i></div>
                        <span>Facebook</span>
                    </a>
                </div>
                <div class="share-copy-box">
                    <input type="text" class="share-url-inp" id="txtShareUrl" readonly />
                    <button type="button" class="share-copy-btn" onclick="copyProductLink()">Copy</button>
                </div>
            </div>
        </div>

        <!-- Client Logic for Details Interactives -->
        <script>
            const basePrice = parseFloat('<%= productRawPrice %>');
            let prodId = '<%= productId %>';
            let maxStock = parseInt('<%= productStock %>') || 999;
            let wishlistState = <%= isInWishlist ? "true" : "false" %>; // server-side initial state

            // Apply initial wishlist icon state on page load
            (function initWishIcon() {
                const circle = document.querySelector('.js-wish-heart');
                const icon   = circle ? circle.querySelector('i') : null;
                if (!icon) return;
                if (wishlistState) {
                    icon.className = 'fas fa-heart';
                    circle.style.color = '#ef4444';
                    circle.style.borderColor = '#ef4444';
                } else {
                    icon.className = 'far fa-heart';
                    circle.style.color = '';
                    circle.style.borderColor = '';
                }
            })();

            // 1. Quantity Logic (capped at stock)
            function updateQty(change) {
                const input = document.getElementById('txtQty');
                let cur = parseInt(input.value) || 1;
                cur += change;
                if (cur < 1) cur = 1;
                if (cur > maxStock) {
                    cur = maxStock;
                    if (typeof showToast === 'function')
                        showToast('Only ' + maxStock + ' unit(s) available in stock!', 'warning', 'Stock Limit');
                }
                input.value = cur;
                const tot = cur * basePrice;
                document.getElementById('js-live-total').innerText = tot.toLocaleString();
            }

            // 2. Thumb Switcher
            document.querySelectorAll('.js-thumb').forEach(th => {
                th.addEventListener('click', function () {
                    document.querySelectorAll('.js-thumb').forEach(i => i.classList.remove('active'));
                    this.classList.add('active');
                    document.getElementById('mainProdImg').src = this.getAttribute('data-src');
                });
            });

            // 3. Selection Highlight (Color/Size)
            function selectOpt(el, type) {
                const siblings = el.parentNode.children;
                for (let s of siblings) s.classList.remove('active');
                el.classList.add('active');
                
                if (type === 'size') {
                    const variantStock = el.getAttribute('data-stock');
                    if (variantStock) {
                        maxStock = parseInt(variantStock) || 0;
                        const alertBox = document.getElementById('js-stock-alert');
                        if (alertBox) {
                            alertBox.innerHTML = '<i class="fas fa-fire"></i> Hurry! Only ' + maxStock + ' units of size <b>' + el.innerText.trim() + '</b> left in stock.';
                        }
                        const qtyInput = document.getElementById('txtQty');
                        if (qtyInput && parseInt(qtyInput.value) > maxStock) {
                            qtyInput.value = maxStock > 0 ? maxStock : 1;
                            updateQty(0); // trigger price recalculation
                        }
                    }
                }
            }

            // 4. AJAX Add To Cart
            function processCartAction(isBuyNow) {
                const qty = document.getElementById('txtQty').value;
                
                // Fetch selected size and color
                const activeSize = document.querySelector('.pd-size-box.active');
                const activeColor = document.querySelector('.pd-color-ball.active');
                
                const sizeVal = activeSize ? activeSize.innerText.trim() : '';
                const colorVal = activeColor ? activeColor.getAttribute('title') || '' : '';

                const btn = document.querySelector('.pd-add-to-cart');
                const originalHtml = btn.innerHTML;
                btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Processing...';
                btn.style.pointerEvents = 'none';

                let url = 'AddToCart.ashx?pid=' + prodId + '&qty=' + qty;
                if(sizeVal) url += '&size=' + encodeURIComponent(sizeVal);
                if(colorVal) url += '&color=' + encodeURIComponent(colorVal);

                fetch(url)
                    .then(r => r.json())
                    .then(data => {
                        window.location.href = 'Cart.aspx';
                    }).catch(e => { window.location.href = 'Cart.aspx'; });
            }

            // 5. Tab Switcher
            function switchTab(idx) {
                const headers = document.querySelectorAll('.tab-head-item');
                const panes = document.querySelectorAll('.tab-pane');
                headers.forEach(h => h.classList.remove('active'));
                panes.forEach(p => p.classList.remove('active'));
                headers[idx].classList.add('active');
                panes[idx].classList.add('active');
            }

            // 6. Flash Deal Countdown
            const hfSec = document.getElementById('hfOfferSeconds');
            const timerH = document.getElementById('timer-h');
            if (hfSec && timerH) {
                let timeLimit = parseInt(hfSec.value) || 31500;
                const timerInterval = setInterval(() => {
                    if (timeLimit <= 0) {
                        clearInterval(timerInterval);
                        return;
                    }
                    let h = Math.floor(timeLimit / 3600);
                    let m = Math.floor((timeLimit % 3600) / 60);
                    let s = timeLimit % 60;
                    
                    const th = document.getElementById('timer-h');
                    const tm = document.getElementById('timer-m');
                    const ts = document.getElementById('timer-s');
                    if(th) th.innerText = String(h).padStart(2, '0');
                    if(tm) tm.innerText = String(m).padStart(2, '0');
                    if(ts) ts.innerText = String(s).padStart(2, '0');
                    
                    timeLimit--;
                }, 1000);
            }

            // 7. Wishlist Toggle
            function addToWishlist() {
                const circle = document.querySelector('.js-wish-heart');
                const icon   = circle ? circle.querySelector('i') : null;
                if (!icon) return;

                // Optimistic UI update while request is in flight
                icon.className = 'fas fa-spinner fa-spin';

                fetch('AddToWishlist.ashx?pid=' + prodId + '&action=toggle')
                    .then(r => r.json())
                    .then(d => {
                        if (!d.success) { icon.className = wishlistState ? 'fas fa-heart' : 'far fa-heart'; return; }

                        wishlistState = d.inWishlist;

                        if (wishlistState) {
                            icon.className = 'fas fa-heart';
                            circle.style.color = '#ef4444';
                            circle.style.borderColor = '#ef4444';
                        } else {
                            icon.className = 'far fa-heart';
                            circle.style.color = '';
                            circle.style.borderColor = '';
                        }

                        // Live-update header wishlist badge (no page reload)
                        const badge = document.getElementById('wishlist_count');
                        if (badge) badge.textContent = d.totalCount;

                        const toastType = wishlistState ? 'success' : 'info';
                        showToast(d.message, toastType, 'Wishlist');
                    })
                    .catch(() => {
                        // Restore on network error
                        icon.className = wishlistState ? 'fas fa-heart' : 'far fa-heart';
                    });
            }

            // 8. Share Modal Config
            function toggleShareModal(show) {
                const m = document.getElementById('shareModal');
                if (show) {
                    const currentUrl = window.location.href;
                    const msg = "Check out this amazing product! " + currentUrl;
                    document.getElementById('txtShareUrl').value = currentUrl;
                    document.getElementById('linkWa').href = "https://api.whatsapp.com/send?text=" + encodeURIComponent(msg);
                    document.getElementById('linkMail').href = "mailto:?subject=Amazing Product&body=" + encodeURIComponent(msg);
                    document.getElementById('linkFb').href = "https://www.facebook.com/sharer/sharer.php?u=" + encodeURIComponent(currentUrl);

                    m.style.display = 'flex';
                    setTimeout(() => m.classList.add('show'), 10);
                } else {
                    m.classList.remove('show');
                    setTimeout(() => m.style.display = 'none', 300);
                }
            }
            function copyProductLink() {
                const inp = document.getElementById('txtShareUrl');
                inp.select();
                document.execCommand('copy');
                showToast('Link copied to clipboard!', 'info', 'Copied');
            }

            // 9. Reviews Functions
            function toggleRevForm() {
                const c = document.getElementById('revFormContainer');
                c.style.display = (c.style.display === 'block') ? 'none' : 'block';
            }
            function setRating(r) {
                document.getElementById('hdnRating').value = r;
                const stars = document.querySelectorAll('#starPicker i');
                stars.forEach(s => {
                    const val = parseInt(s.getAttribute('data-val'));
                    if (val <= r) {
                        s.className = "fas fa-star active";
                    } else {
                        s.className = "far fa-star";
                    }
                });
            }
            function submitReview() {
                const name = document.getElementById('txtRevName').value.trim();
                const msg = document.getElementById('txtRevMsg').value.trim();
                const rating = document.getElementById('hdnRating').value;

                if (!name || !msg) { showToast('Please fill your name and message!', 'warning', 'Validation Error'); return; }

                const f = new FormData();
                f.append('pid', prodId);
                f.append('name', name);
                f.append('msg', msg);
                f.append('rating', rating);

                fetch('SubmitReview.ashx', { method: 'POST', body: f })
                    .then(res => res.json())
                    .then(dat => {
                        showToast(dat.message, dat.success ? 'success' : 'error', 'Review System');
                        if (dat.success) window.location.reload();
                    });
            }
        </script>
    </asp:Content>