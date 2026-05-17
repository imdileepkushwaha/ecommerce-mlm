<%@ Page Title="Product Profile Audit" Language="C#" MasterPageFile="~/seller/Seller.Master" AutoEventWireup="true"
    CodeFile="ViewProduct.aspx.cs" Inherits="EcommerceWebsite.SellerViewProduct" %>

    <asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

        <!-- BACK LINK NAVIGATION -->
        <div class="view-back-bar">
            <a href="Products.aspx" class="back-btn-link">
                <i class="fas fa-arrow-left"></i> Back to Catalog Inventory
            </a>
        </div>

        <!-- TOP CONSOLE BAR -->
        <div class="page-action-bar">
            <div class="welcome-title">
                <h1>Product Information Dashboard</h1>
                <p>Comprehensive telemetry and configuration layout for SKU index.</p>
            </div>

            <asp:HyperLink ID="hlEditTop" runat="server" CssClass="add-prod-btn"
                style="background: #fbbf24; color: #1e293b !important; box-shadow: 0 10px 15px -3px rgba(251, 191, 36, 0.25);">
                <i class="fas fa-pen-to-square"></i> Edit Catalog Parameters
            </asp:HyperLink>
        </div>

        <!-- DYNAMIC DATA MATRIX -->
        <div class="prod-showcase-grid">

            <!-- LEFT MODULE: SHUTTER GALLERY -->
            <div class="gallery-panel">
                <div class="hero-viewport" id="divHeroWrap">
                    <asp:Image ID="heroImg" runat="server" ClientIDMode="Static" CssClass="hero-viewport-img"
                        AlternateText="Product Snapshot" Visible="false" />
                    <asp:Literal ID="litHeroPlaceholder" runat="server"><i class='fas fa-image hero-placeholder'></i>
                    </asp:Literal>
                </div>

                <!-- THUMBNAIL REEL GENERATOR -->
                <div class="thumb-reel">
                    <asp:Repeater ID="rptThumbs" runat="server">
                        <ItemTemplate>
                            <div class='thumb-reel-item <%# Container.ItemIndex == 0 ? "active" : "" %>'
                                onclick='switchHero(this, "<%# Container.DataItem %>")'>
                                <img src='<%# Container.DataItem %>' alt="thumb" />
                            </div>
                        </ItemTemplate>
                    </asp:Repeater>
                </div>
            </div>

            <!-- RIGHT MODULE: COMMERCIAL INTELLIGENCE -->
            <div class="details-panel">
                <div class="prod-meta-head">
                    <span class="category-bread">
                        <i class="fas fa-folder-tree u-mr-5"></i>
                        <asp:Literal ID="litCategory" runat="server">General</asp:Literal>
                    </span>
                    <asp:Literal ID="litStatusBadge" runat="server"></asp:Literal>
                </div>

                <h2 class="prod-title-view">
                    <asp:Literal ID="litProductName" runat="server">Unnamed Product</asp:Literal>
                </h2>

                <div class="info-strip">
                    <div class="strip-item">
                        <i class="fas fa-tag"></i> SKU: <strong style="font-family: monospace;">
                            <asp:Literal ID="litSku" runat="server">-</asp:Literal>
                        </strong>
                    </div>
                    <div class="strip-item">
                        <i class="fas fa-copyright"></i> Brand: <asp:Literal ID="litBrand" runat="server">-
                        </asp:Literal>
                    </div>
                    <div class="strip-item">
                        <i class="fas fa-clock"></i> Last Update: <asp:Literal ID="litUpdatedAt" runat="server">Never
                        </asp:Literal>
                    </div>
                </div>

                <!-- PRICING CARD BLOCK -->
                <div class="price-card-view">
                    <div>
                        <div class="price-val-main">
                            ₹<asp:Literal ID="litPrice" runat="server">0.00</asp:Literal>
                        </div>
                        <span
                            style="font-size: 0.75rem; font-weight: 700; color:#888888; text-transform: uppercase;">Selling
                            Price</span>
                    </div>
                    <div>
                        <div class="mrp-val-sub">
                            ₹<asp:Literal ID="litMrp" runat="server">0.00</asp:Literal>
                        </div>
                        <span
                            style="font-size: 0.75rem; font-weight: 700; color:#888888; text-transform: uppercase;">M.R.P.</span>
                    </div>
                    <asp:Literal ID="litDiscountPill" runat="server"></asp:Literal>
                </div>

                <!-- STOCK AND LOGISTICS BANNER -->
                <div class="attrib-grp">
                    <span class="attrib-title">Operational Reserves</span>
                    <div class="reserves-banner-box">
                        <div style="font-size: 1.5rem;">
                            <asp:Literal ID="litStockIcon" runat="server"><i class="fas fa-warehouse"></i></asp:Literal>
                        </div>
                        <div>
                            <strong>
                                <asp:Literal ID="litStockStatus" runat="server">Checking Reserves...</asp:Literal>
                            </strong>
                            <span style="font-size:0.82rem; color:#64748b;">Active quantities indexed in distribution
                                channels.</span>
                        </div>
                    </div>
                </div>

                <!-- ATTRIBUTE SUBSECTION (DYNAMIC VISIBILITY) -->
                <asp:PlaceHolder ID="phColors" runat="server" Visible="false">
                    <div class="attrib-grp">
                        <span class="attrib-title">Available Tints & Colors</span>
                        <div class="attrib-tags">
                            <asp:Repeater ID="rptColors" runat="server">
                                <ItemTemplate>
                                    <span class="attrib-tag-pill"><i class="fas fa-palette"
                                            style="font-size: 0.75rem; margin-right: 6px;"></i>
                                        <%# Container.DataItem %>
                                    </span>
                                </ItemTemplate>
                            </asp:Repeater>
                        </div>
                    </div>
                </asp:PlaceHolder>

                <asp:PlaceHolder ID="phSizes" runat="server" Visible="false">
                    <div class="attrib-grp">
                        <span class="attrib-title">Indexed Dimensions & Sizes</span>
                        <div class="attrib-tags">
                            <asp:Repeater ID="rptSizes" runat="server">
                                <ItemTemplate>
                                    <span class="attrib-tag-pill"><i class="fas fa-ruler"
                                            style="font-size: 0.75rem; margin-right: 6px;"></i>
                                        <%# Container.DataItem %>
                                    </span>
                                </ItemTemplate>
                            </asp:Repeater>
                        </div>
                    </div>
                </asp:PlaceHolder>

            </div>
        </div>

        <!-- SECONDARY DETAILS GRID -->
        <!-- 1. STRUCTURAL SPECIFICATIONS -->
        <div class="full-details-card">
            <h3 class="sec-head-view">
                <i class="fas fa-layer-group" style="color: var(--accent);"></i> Technical Matrix & Specifications
            </h3>
            <div class="spec-grid">
                <div class="spec-box">
                    <span class="spec-lbl">Product Class / Type</span>
                    <span class="spec-val">
                        <asp:Literal ID="litProductType" runat="server">Standard</asp:Literal>
                    </span>
                </div>
                <div class="spec-box">
                    <span class="spec-lbl">Target Consumer Demographics</span>
                    <span class="spec-val">
                        <asp:Literal ID="litGender" runat="server">Unisex</asp:Literal>
                    </span>
                </div>
                <div class="spec-box">
                    <span class="spec-lbl">Physical Net Mass</span>
                    <span class="spec-val">
                        <asp:Literal ID="litWeight" runat="server">N/A</asp:Literal>
                    </span>
                </div>
                <div class="spec-box">
                    <span class="spec-lbl">Volumetric Dimensions</span>
                    <span class="spec-val">
                        <asp:Literal ID="litDimensions" runat="server">N/A</asp:Literal>
                    </span>
                </div>
                <div class="spec-box">
                    <span class="spec-lbl">Shipping Tier Category</span>
                    <span class="spec-val">
                        <asp:Literal ID="litShipping" runat="server">Default Standard</asp:Literal>
                    </span>
                </div>
                <div class="spec-box">
                    <span class="spec-lbl">Creation Sequence Stamp</span>
                    <span class="spec-val">
                        <asp:Literal ID="litCreatedAt" runat="server">-</asp:Literal>
                    </span>
                </div>
            </div>
        </div>

        <!-- 2. CONSUMER DESCRIPTIVE INDEX -->
        <div class="full-details-card">
            <h3 class="sec-head-view">
                <i class="fas fa-align-left" style="color: #10b981;"></i> Consumer Narrative & Description
            </h3>
            <div class="desc-content">
                <asp:Literal ID="litDesc" runat="server">No public narrative indexed for this product record.
                </asp:Literal>
            </div>
        </div>

        <!-- 3. SEARCH ENGINE TELEMETRY -->
        <div class="full-details-card" style="margin-bottom: 50px;">
            <h3 class="sec-head-view">
                <i class="fas fa-search" style="color: #f97316;"></i> SEO & Web Crawler Optimization
            </h3>
            <div class="seo-crawler-box">
                <div style="margin-bottom: 15px;">
                    <span class="attrib-title" style="margin-bottom: 5px;">Meta Title Headline</span>
                    <div class="seo-title-val">
                        <asp:Literal ID="litMetaTitle" runat="server">-</asp:Literal>
                    </div>
                </div>
                <div style="margin-bottom: 15px;">
                    <span class="attrib-title" style="margin-bottom: 5px;">Meta Keyword Catalog</span>
                    <div class="attrib-tags" style="margin-top: 5px;">
                        <asp:Literal ID="litMetaKeywords" runat="server"><span
                                style="color:#94a3b8; font-size:0.85rem; font-style:italic;">No keywords
                                configured.</span></asp:Literal>
                    </div>
                </div>
                <div>
                    <span class="attrib-title" style="margin-bottom: 5px;">Search Engine Excerpt (Snippet)</span>
                    <div class="seo-desc-val">
                        <asp:Literal ID="litMetaDesc" runat="server">No public indexing snippet provided.</asp:Literal>
                    </div>
                </div>
            </div>
        </div>

        <!-- JAVASCRIPT IMAGE SHUTTER CONTROLLER -->
        <script type="text/javascript">
            function switchHero(el, src) {
                const img = document.getElementById('heroImg');
                if (img) {
                    img.src = src;
                    // Toggle Active thumbnail rings
                    document.querySelectorAll('.thumb-reel-item').forEach(item => {
                        item.classList.remove('active');
                    });
                    el.classList.add('active');
                }
            }
        </script>

    </asp:Content>