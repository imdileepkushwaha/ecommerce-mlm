<%@ Page Title="Your Shopping Cart" Language="C#" MasterPageFile="~/usersite.Master" AutoEventWireup="true"
    CodeFile="Cart.aspx.cs" Inherits="ecommerce_mlm.Cart" %>

    <asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
        <style>
            /* Cart Specific Overrides/Extensions go into style.css but keeping layout structure references here if needed */
        </style>
    </asp:Content>

    <asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
        <div class="cart-page-wrapper">

            <!-- Breadcrumb Top Bar -->
            <div class="dashboard-breadcrumb">
                <div class="container">
                    <div class="dashboard-breadcrumb-inner">
                        <div class="breadcrumb-left">
                            <h3>Your Shopping Cart <span class="cart-breadcrumb-badge">
                                    <asp:Literal ID="litCartCountBreadcrumb" runat="server" Text="0"></asp:Literal>
                                    Items
                                </span></h3>
                        </div>
                        <div class="breadcrumb-right">
                            <a href="index.aspx"><i class="fas fa-home"></i></a>
                            <span> / Your Shopping Cart</span>
                        </div>
                    </div>

                </div>

                <!-- SAVED FOR LATER SECTION -->


            </div>
            <div class="container py-5">
                <div class="cart-grid">

                    <!-- LEFT SECTION: CART ITEMS -->
                    <div class="cart-items-section">

                        <!-- Select All Bar -->
                        <div class="cart-header-bar">
                            <div class="select-all-group">
                                <input type="checkbox" id="chkSelectAll" class="custom-checkbox" checked="checked" />
                                <label for="chkSelectAll" class="label-bold">Select All (<asp:Literal
                                        ID="litCartCountTop" runat="server" Text="0"></asp:Literal>)</label>
                            </div>
                            <div class="header-bar-actions">
                                <a href="javascript:void(0);" class="action-link" id="btnSaveAll"><i
                                        class="far fa-bookmark"></i> Save All</a>
                                <a href="javascript:void(0);" class="action-link text-danger" id="btnRemoveAll"><i
                                        class="far fa-trash-alt"></i> Remove All</a>
                            </div>
                        </div>

                        <!-- Items List -->
                        <div class="cart-items-list">
                            <asp:Repeater ID="rptCart" runat="server" OnItemDataBound="rptCart_ItemDataBound">
                                <ItemTemplate>
                                    <div class="cart-item-card" data-cid='<%# Eval("CartItemId") %>'>
                                        <div class="item-main-info">
                                            <div class="item-checkbox-wrapper">
                                                <input type="checkbox" class="custom-checkbox item-chk"
                                                    checked="checked" />
                                            </div>
                                            <div class="item-img-wrapper">
                                                <img src='<%# ResolveUrl(Eval("MainImage") != DBNull.Value ? Eval("MainImage").ToString() : "https://via.placeholder.com/120") %>'
                                                    alt='<%# Eval("Name") %>' />
                                            </div>
                                            <div class="item-details-wrapper">
                                                <div class="item-brand text-uppercase">
                                                    <%# Eval("Brand") ?? "GENERIC" %>
                                                </div>
                                                <h3 class="item-name">
                                                    <%# Eval("Name") %>
                                                </h3>

                                                <div class="item-meta-row">
                                                    <span class="meta-pill"><i class="far fa-dot-circle"
                                                            style="font-size:10px; margin-right:5px;"></i> Size: <%#
                                                            Eval("SelectedSize") ?? "N/A" %></span>
                                                    <span class="meta-pill"><i class="fas fa-palette"
                                                            style="font-size:10px; margin-right:5px;"></i> Color: <%#
                                                            Eval("SelectedColor") ?? "Default" %></span>
                                                </div>

                                                <div class="item-qty-row" data-cid='<%# Eval("CartItemId") %>'
                                                    data-unitprice='<%# Eval("Price") %>'>
                                                    <button type="button" class="qty-btn btn-qty-minus">-</button>
                                                    <input type="text" class="qty-input item-qty-val"
                                                        value='<%# Eval("Quantity") %>' readonly />
                                                    <button type="button" class="qty-btn btn-qty-plus">+</button>
                                                </div>

                                                <div class="item-price-row">
                                                    <span class="curr-price item-line-total"
                                                        data-val='<%# Eval("Price") %>'>₹ <%#
                                                            (Convert.ToDecimal(Eval("Price")) *
                                                            Convert.ToInt32(Eval("Quantity"))).ToString("N0") %></span>
                                                    <span class="old-price">₹ <%# Eval("Mrp") %></span>
                                                    <span class="discount-percent-badge">
                                                        <%# GetDiscountPercentage(Eval("Price"), Eval("Mrp")) %> OFF
                                                    </span>
                                                </div>
                                            </div>
                                            <div class="item-close-btn">
                                                <a href="javascript:void(0);" class="close-cross btn-item-remove"
                                                    data-cid='<%# Eval("CartItemId") %>'><i
                                                        class="fas fa-times"></i></a>
                                            </div>
                                        </div>
                                        <!-- Expected Delivery Footer inside item row -->
                                        <div class="item-footer-delivery">
                                            <div class="delivery-info">
                                                <i class="fas fa-truck"></i>
                                                Expected delivery: <span class="delivery-highlight">Standard Delivery by
                                                    15 May - 19 May</span>
                                            </div>
                                            <div class="item-footer-actions">
                                                <a href="javascript:void(0);" class="foot-link btn-save-later"
                                                    data-cid='<%# Eval("CartItemId") %>'><i class="far fa-bookmark"></i>
                                                    Save for
                                                    Later</a>
                                                <div class="link-separator"></div>
                                                <a href="javascript:void(0);"
                                                    class="foot-link text-danger btn-item-remove"
                                                    data-cid='<%# Eval("CartItemId") %>'><i
                                                        class="far fa-trash-alt"></i> Remove</a>
                                            </div>
                                        </div>
                                    </div>
                                </ItemTemplate>
                            </asp:Repeater>

                            <asp:Panel ID="pnlEmptyCart" runat="server" Visible="false" CssClass="empty-cart-msg">
                                <img src="https://cdn-icons-png.flaticon.com/512/11329/11329060.png"
                                    style="width:80px; margin-bottom:15px; opacity:0.5;" />
                                <h4>Your cart is empty</h4>
                                <p>Look like you haven't added anything yet.</p>
                                <a href="index.aspx" class="btn-view-all mt-3">Go Shopping</a>
                            </asp:Panel>
                        </div>

                    </div>

                    <!-- RIGHT SECTION: ORDER SUMMARY -->
                    <div class="cart-summary-section">
                        <div class="summary-sticky-card">

                            <h3 class="summary-title">Order Summary</h3>

                            <!-- Apply Coupon Block -->
                            <div class="coupon-block">
                                <div class="coupon-label"><i class="fas fa-tag" style="color:#f59e0b;"></i> Apply Coupon
                                </div>
                                <div class="coupon-input-group">
                                    <input type="text" placeholder="Enter code" class="form-control coupon-input" />
                                    <button type="button" class="btn btn-dark btn-coupon-apply">Apply</button>
                                </div>
                                <div class="applied-coupon-tags">
                                    <span class="coupon-tag">SAVE10</span>
                                </div>
                            </div>

                            <!-- Free Delivery Dynamic Banner -->
                            <div class="co-speed-free" id="divFreePromoBanner">
                                <!-- <div class="icon-wrap"><i class="fas fa-shipping-fast"></i></div> -->
                                <div class="text-wrap">
                                    <!-- <div class="title">FREE Standard Delivery</div> -->
                                    <div class="desc" id="js-promo-desc">🎉 FREE delivery on orders above ₹1,000!</div>
                                </div>
                            </div>


                            <!-- Delivery Speed Selection -->
                            <div class="delivery-speed-block mt-4">
                                <div class="section-mini-label"><i class="fas fa-shipping-fast"></i> Delivery Speed
                                </div>

                                <div class="speed-option js-speed-option selected" data-fee="25">
                                    <div class="speed-name">Standard (3-5 days)</div>
                                    <div class="speed-cost">₹ 25</div>
                                </div>
                                <div class="speed-option js-speed-option" data-fee="89">
                                    <div class="speed-name">Express (1-2 days)</div>
                                    <div class="speed-cost">₹ 89</div>
                                </div>
                                <div class="speed-option js-speed-option" data-fee="149">
                                    <div class="speed-name">Same Day</div>
                                    <div class="speed-cost">₹ 149</div>
                                </div>
                            </div>

                            <!-- Billing Table -->
                            <div class="billing-breakdown mt-4">
                                <div class="billing-row">
                                    <span>Subtotal (<span id="js-count-span">
                                            <asp:Literal ID="litItemsCountBottom" runat="server">0</asp:Literal>
                                        </span>
                                        items)</span>
                                    <span class="bill-val">₹ <span id="js-subtotal-val">
                                            <asp:Literal ID="litSubtotal" runat="server">0</asp:Literal>
                                        </span></span>
                                </div>
                                <div class="billing-row">
                                    <span>Delivery Charges</span>
                                    <span class="bill-val" id="js-delivery-val">
                                        <asp:Literal ID="litShippingVisual" runat="server">₹ 25</asp:Literal>
                                    </span>
                                </div>
                                <div class="billing-row">
                                    <span>Platform Fee</span>
                                    <span class="bill-val">₹ <span id="js-platform-val">5</span></span>
                                </div>
                            </div>
                            <hr class="billing-separator" />
                            <div class="billing-row total-row">
                                <strong>Total Amount</strong>
                                <strong class="total-val">₹ <span id="js-final-total">
                                        <asp:Literal ID="litTotalAmount" runat="server">0</asp:Literal>
                                    </span></strong>
                            </div>
                            <!-- Checkout Button -->
                            <asp:Button ID="btnCheckout" runat="server" CssClass="btn btn-orange-checkout w-100 mt-4"
                                Text="Proceed to Checkout" />


                            <div class="trust-badge text-center mt-3">
                                <i class="fas fa-lock"></i> Secured by 256-bit SSL encryption
                            </div>

                        </div>
                    </div>

                </div>
                <asp:Panel ID="pnlSavedForLaterSection" runat="server" CssClass="mt-5 pt-4 border-top" Visible="true">
                    <div class="d-flex justify-content-between align-items-center mb-4">
                        <h3 class="section-title mb-0" style="font-size: 22px; font-weight: 800; color: #0f172a;">
                            Saved for Later (<asp:Literal ID="litSavedCount" runat="server">0</asp:Literal> items)
                        </h3>
                    </div>

                    <div class="saved-later-grid"
                        style="display:grid; grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); gap:20px;">
                        <asp:Repeater ID="rptSavedForLater" runat="server">
                            <ItemTemplate>
                                <div class="saved-card"
                                    style="background:#fff; border: 1px solid #e2e8f0; border-radius:16px; padding:15px; display:flex; gap:15px; position:relative; box-shadow: 0 4px 15px rgba(0,0,0,0.03); transition: all 0.3s ease;">
                                    <div class="saved-img"
                                        style="width:85px; height:95px; border-radius:12px; overflow:hidden; flex-shrink:0;">
                                        <img src='<%# ResolveUrl(Eval("MainImage") != DBNull.Value ? Eval("MainImage").ToString() : "https://via.placeholder.com/80") %>'
                                            style="width:100%; height:100%; object-fit:cover;" />
                                    </div>
                                    <div class="saved-details"
                                        style="flex-grow:1; display:flex; flex-direction:column; justify-content: space-between;">
                                        <div>
                                            <h4
                                                style="font-size:14px; font-weight:700; margin-bottom:4px; color:#1e293b; line-height:1.3;">
                                                <%# Eval("Name") %>
                                            </h4>
                                            <div style="font-weight:800; color:#f97316; font-size:16px;">₹ <%#
                                                    Eval("Price") %>
                                            </div>
                                        </div>
                                        <div style="margin-top:8px;">
                                            <a href="javascript:void(0);" class="btn-move-to-cart"
                                                data-cid='<%# Eval("CartItemId") %>'
                                                style="display:inline-block; background:#0f172a; color:#fff; font-size:12px; text-decoration:none; padding: 7px 15px; border-radius: 8px; font-weight: 600; transition: background 0.2s;">Move
                                                to Cart</a>
                                        </div>
                                    </div>
                                    <a href="javascript:void(0);" class="btn-item-remove"
                                        data-cid='<%# Eval("CartItemId") %>'
                                        style="position:absolute; top:12px; right:12px; color:#94a3b8; font-size:14px;"><i
                                            class="fas fa-times"></i></a>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>
                </asp:Panel>
            </div>
        </div>

    </asp:Content>