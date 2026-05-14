<%@ Page Title="Seller Storefront" Language="C#" MasterPageFile="~/usersite.Master" AutoEventWireup="true"
    CodeFile="SellerStore.aspx.cs" Inherits="ecommerce_mlm.SellerStore" %>

    <asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
        <!-- All specific styles shifted to ~/assets/css/style.css for optimal caching -->
    </asp:Content>

    <asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
        
        <!-- Top Dynamic Hero & Profile Backdrop Layer -->
        <div class="ss-hero-wrapper" id="divHeroCover" runat="server">
            <div class="ss-hero-overlay"></div>
            <div class="container ss-hero-container">
                <!-- Float Glassmorphism Profile Details -->
                <div class="ss-glass-profile">
                    <div class="ss-avatar-ring">
                        <asp:Image ID="imgStoreLogo" runat="server" Visible="false" />
                        <asp:Panel ID="pnlInitialsAvatar" runat="server" CssClass="ss-initials-avatar" Visible="false">
                            <asp:Literal ID="litInitials" runat="server"></asp:Literal>
                        </asp:Panel>
                    </div>
                    
                    <div class="ss-info-stack">
                        <div class="ss-verify-pill"><i class="fas fa-check-circle"></i> VERIFIED SELLER</div>
                        <h1><asp:Literal ID="litStoreTitle" runat="server"></asp:Literal></h1>
                        <div class="ss-location-meta">
                            <i class="fas fa-location-dot ss-loc-icon"></i> 
                            <asp:Literal ID="litHeaderLocation" runat="server"></asp:Literal> 
                            • Member since <asp:Literal ID="litMemberSince" runat="server"></asp:Literal>
                        </div>
                        <div class="ss-stats-flex">
                            <div class="ss-stat-box">
                                <span class="ss-stat-val"><asp:Literal ID="litStatProductCount" runat="server"></asp:Literal></span>
                                <span class="ss-stat-lbl">Products</span>
                            </div>
                            <div class="ss-stat-box">
                                <span class="ss-stat-val">4.8 <i class="fas fa-star" style="font-size: 1rem; color:#fbbf24;"></i></span>
                                <span class="ss-stat-lbl">124 Reviews</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <div class="container">
            <!-- Info Dense Identity Widget Grid -->
            <div class="ss-widgets-grid">
                <!-- Widget 1: About The Merchant -->
                <div class="ss-widget-card">
                    <div class="ss-widget-title">
                        <i class="fas fa-shop ss-shop-icon"></i> About the Store
                    </div>
                    <p class="ss-widget-desc">
                        <asp:Literal ID="litAboutStore" runat="server"></asp:Literal>
                    </p>
                </div>

                <!-- Widget 2: Product Specialities / Categories -->
                <div class="ss-widget-card">
                    <div class="ss-widget-title">
                        <i class="fas fa-boxes-stacked ss-spec-icon"></i> Specialities
                    </div>
                    <div class="ss-tag-cloud">
                        <asp:Repeater ID="rptSpecialities" runat="server">
                            <ItemTemplate>
                                <span class="ss-tag-pill"><%# Container.DataItem.ToString() %></span>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </div>

                <!-- Widget 3: Direct Contact / Origin Mapping -->
                <div class="ss-widget-card">
                    <div class="ss-widget-title">
                        <i class="fas fa-circle-info ss-info-icon"></i> Store Information
                    </div>
                    <ul class="ss-meta-list">
                        <li class="ss-meta-item">
                            <div class="ss-meta-icon"><i class="fas fa-envelope"></i></div>
                            <div class="ss-meta-val">
                                <strong>Email Address</strong>
                                <asp:Literal ID="litMetaEmail" runat="server"></asp:Literal>
                            </div>
                        </li>
                        <li class="ss-meta-item">
                            <div class="ss-meta-icon"><i class="fas fa-map-location"></i></div>
                            <div class="ss-meta-val">
                                <strong>Origin Address</strong>
                                <asp:Literal ID="litMetaAddress" runat="server"></asp:Literal>
                            </div>
                        </li>
                        <li class="ss-meta-item">
                            <div class="ss-meta-icon"><i class="fas fa-thumbtack"></i></div>
                            <div class="ss-meta-val">
                                <strong>PIN Code</strong>
                                <asp:Literal ID="litMetaPin" runat="server"></asp:Literal>
                            </div>
                        </li>
                    </ul>
                </div>
            </div>

            <!-- Product Showcase Section -->
            <div class="ss-section-hdr">
                <h2>Products from <asp:Literal ID="litSectionTitle" runat="server"></asp:Literal></h2>
            </div>

            <div class="pl-grid">
                <asp:Repeater ID="rptCatalog" runat="server">
                    <ItemTemplate>
                        <div class="product-card">
                            <div class="product-card-img">
                                <!-- Badge Logic Integration -->
                                <div class='<%# Eval("Badge").ToString() == "Hot" ? "tag-hot" : (Eval("Badge").ToString() == "Sale" ? "tag-sale" : "") %>' 
                                     style='<%# string.IsNullOrEmpty(Eval("Badge").ToString()) || Eval("Badge").ToString() == "None" ? "display:none;" : "" %>'>
                                    <%# Eval("BadgeText") %>
                                </div>

                                <img src='<%# ResolveUrl(Eval("MainImage").ToString()) %>' alt='<%# Eval("Name") %>' />
                                
                                <div class="product-actions">
                                    <a href='<%# "ProductDetails.aspx?slug=" + Eval("Slug") %>' class="action-btn"><i class="far fa-eye"></i></a>
                                </div>
                            </div>
                            <div class="product-card-body">
                                <div class="prod-rating">
                                    <i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star"></i><i class="fas fa-star-half-alt"></i>
                                    <span>(4.7)</span>
                                </div>
                                <span class="prod-brand"><%# Eval("Brand") %></span>
                                <h3>
                                    <a href='<%# "ProductDetails.aspx?slug=" + Eval("Slug") %>'><%# Eval("Name") %></a>
                                </h3>
                                <div class="prod-pricing">
                                    <span class="current-price">₹ <%# Convert.ToDecimal(Eval("Price")).ToString("N0") %></span>
                                    <span class="old-price">₹ <%# Convert.ToDecimal(Eval("Mrp")).ToString("N0") %></span>
                                </div>
                                <div class="prod-action-row">
                                    <a href='<%# "ProductDetails.aspx?slug=" + Eval("Slug") %>' class="buy-now-btn">View Details</a>
                                </div>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>

                <asp:Panel ID="pnlEmptyCatalog" runat="server" CssClass="ss-empty-slate" Visible="false">
                    <i class="fas fa-basket-shopping"></i>
                    <h3>Catalog is Empty</h3>
                    <p>This seller hasn't published any active products to showcase just yet.</p>
                </asp:Panel>
            </div>
        </div>

    </asp:Content>
