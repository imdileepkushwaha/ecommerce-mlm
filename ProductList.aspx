<%@ Page Title="Explore All Products" Language="C#" MasterPageFile="~/usersite.Master" AutoEventWireup="true"
    CodeFile="ProductList.aspx.cs" Inherits="ecommerce_mlm.ProductList" %>

    <asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
        <style>
            /* Product List Layout overrides */
            .pl-wrapper {
                display: grid;
                grid-template-columns: 280px 1fr;
                gap: 30px;
            }

            @media(max-width: 992px) {
                .pl-wrapper {
                    grid-template-columns: 1fr;
                }

                .filter-sidebar {
                    display: none;
                }

                /* could be toggled */
            }

            /* Sidebar Filters */
            .filter-sidebar {
                background: #fff;
                border: 1px solid #e2e8f0;
                border-radius: 16px;
                padding: 25px;
                position: sticky;
                top: 100px;
                height: fit-content;
            }

            .filter-group {
                margin-bottom: 30px;
            }

            .filter-title {
                font-size: 16px;
                font-weight: 700;
                color: #0f172a;
                margin-bottom: 15px;
                padding-bottom: 10px;
                border-bottom: 2px solid #f1f5f9;
                display: flex;
                justify-content: space-between;
                align-items: center;
            }

            .filter-list {
                list-style: none;
                padding: 0;
                margin: 0;
            }

            .filter-item {
                display: flex;
                align-items: center;
                gap: 10px;
                margin-bottom: 10px;
                font-size: 14px;
                color: #475569;
                cursor: pointer;
                transition: 0.2s;
            }

            .filter-item:hover {
                color: #f97316;
            }

            .filter-item input[type="checkbox"] {
                accent-color: #f97316;
                width: 16px;
                height: 16px;
                cursor: pointer;
            }

            /* Sorting Top Bar */
            .pl-top-bar {
                background: #fff;
                border: 1px solid #e2e8f0;
                border-radius: 12px;
                padding: 15px 20px;
                display: flex;
                justify-content: space-between;
                align-items: center;
                margin-bottom: 25px;
            }

            .results-count {
                font-weight: 600;
                color: #64748b;
                font-size: 14px;
            }

            .sort-dropdown {
                padding: 8px 15px;
                border-radius: 8px;
                border: 1px solid #cbd5e1;
                font-size: 14px;
                color: #334155;
                outline: none;
            }

            .pl-grid {
                display: grid;
                grid-template-columns: repeat(auto-fill, minmax(240px, 1fr));
                gap: 25px;
            }

            /* Custom Card Adjustment for Grid fit */
            .pl-grid .product-card {
                margin: 0;
            }

            .empty-pl-msg {
                text-align: center;
                padding: 60px 20px;
                color: #64748b;
            }

            .oos-banner {
                background: #fee2e2;
                color: #ef4444;
                font-weight: 800;
                text-align: center;
                width: 100%;
                padding: 10px;
                border-radius: 8px;
                font-size: 13px;
                letter-spacing: 0.5px;
                border: 1px dashed #fca5a5;
            }

            .oos-overlay {
                position: absolute;
                top: 0;
                left: 0;
                right: 0;
                bottom: 0;
                background: rgba(255, 255, 255, 0.6);
                z-index: 2;
                pointer-events: none;
            }
        </style>
    </asp:Content>

    <asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

        <!-- BREADCRUMB -->
        <div class="dashboard-breadcrumb">
            <div class="container">
                <div class="dashboard-breadcrumb-inner">
                    <div class="breadcrumb-left">
                        <h3>Explore Our Collection</h3>
                    </div>
                    <div class="breadcrumb-right">
                        <a href="index.aspx"><i class="fas fa-home"></i></a>
                        <span> / Products</span>
                    </div>
                </div>
            </div>
        </div>

        <div class="container py-5">
            <div class="pl-wrapper">

                <!-- LEFT FILTERS SIDEBAR -->
                <aside class="filter-sidebar">
                    <h4 style="margin-top:0; font-weight:800; margin-bottom:25px; color:#1e293b;">Filters</h4>

                    <!-- Category Filter -->
                    <div class="filter-group">
                        <div class="filter-title">Category <i class="fas fa-chevron-down"
                                style="font-size:12px; opacity:0.5;"></i></div>
                        <ul class="filter-list">
                            <li class="filter-item"><input type="checkbox" id="c1" /><label for="c1">Men's
                                    Fashion</label></li>
                            <li class="filter-item"><input type="checkbox" id="c2" /><label for="c2">Women's
                                    Clothing</label></li>
                            <li class="filter-item"><input type="checkbox" id="c3" /><label for="c3">Kids
                                    Collection</label></li>
                            <li class="filter-item"><input type="checkbox" id="c4" /><label for="c4">Footwear</label>
                            </li>
                            <li class="filter-item"><input type="checkbox" id="c5" /><label for="c5">Accessories</label>
                            </li>
                        </ul>
                    </div>

                    <!-- Brand Filter -->
                    <div class="filter-group">
                        <div class="filter-title">Popular Brands</div>
                        <ul class="filter-list">
                            <li class="filter-item"><input type="checkbox" id="b1" /><label for="b1">Nike</label></li>
                            <li class="filter-item"><input type="checkbox" id="b2" /><label for="b2">Adidas</label></li>
                            <li class="filter-item"><input type="checkbox" id="b3" /><label for="b3">Zara</label></li>
                            <li class="filter-item"><input type="checkbox" id="b4" /><label for="b4">Puma</label></li>
                        </ul>
                    </div>

                    <!-- Price Range -->
                    <div class="filter-group">
                        <div class="filter-title">Price Range</div>
                        <ul class="filter-list">
                            <li class="filter-item"><input type="checkbox" id="p1" /><label for="p1">Under ₹ 500</label>
                            </li>
                            <li class="filter-item"><input type="checkbox" id="p2" /><label for="p2">₹ 500 -
                                    ₹ 1,000</label></li>
                            <li class="filter-item"><input type="checkbox" id="p3" /><label for="p3">₹ 1,000 -
                                    ₹ 5,000</label></li>
                            <li class="filter-item"><input type="checkbox" id="p4" /><label for="p4">Over ₹
                                    5,000</label>
                            </li>
                        </ul>
                    </div>

                    <button type="button" class="btn btn-dark w-100 mt-3" style="border-radius:10px;">Apply
                        Filters</button>
                </aside>

                <!-- RIGHT PRODUCTS VIEW -->
                <main class="products-view">

                    <!-- Top Sorting Bar -->
                    <div class="pl-top-bar">
                        <div class="results-count">
                            Showing <asp:Literal ID="litTotalCount" runat="server">0</asp:Literal> items
                        </div>
                        <div class="d-flex align-items-center gap-3">
                            <span style="font-size:14px; color:#64748b;">Sort By:</span>
                            <select class="sort-dropdown" id="ddlSort" onchange="sortProducts(this)">
                                <option value="latest">Newest Arrivals</option>
                                <option value="low_high">Price: Low to High</option>
                                <option value="high_low">Price: High to Low</option>
                            </select>
                        </div>
                    </div>

                    <!-- THE GRID -->
                    <div class="pl-grid">
                        <asp:Repeater ID="rptProducts" runat="server">
                            <ItemTemplate>
                                <div class="product-card">
                                    <div class="product-card-img">
                                        <%# !IsProductAvailable(Eval("IsActive"), Eval("Stock"), Eval("SellerActive"))
                                            ? "<div class='oos-overlay'></div>" : "" %>
                                            <span class="discount-tag">
                                                <%# GetDiscountPercentage(Eval("Price"), Eval("Mrp")) %>
                                            </span>
                                            <img src='<%# ResolveUrl(Eval("MainImage") != DBNull.Value && Eval("MainImage").ToString() != "" ? Eval("MainImage").ToString() : "https://via.placeholder.com/300?text=No+Image") %>'
                                                alt='<%# Eval("Name") %>' />

                                            <div class="product-actions">
                                                <a href="javascript:void(0);" class="action-btn btn-wishlist"
                                                    title="Add to Wishlist" data-pid='<%# Eval("Id") %>'><i
                                                        class="far fa-heart"></i></a>
                                                <a href='<%# "ProductDetails.aspx?slug=" + Eval("Slug") %>'
                                                    class="action-btn" title="Quick View"><i class="far fa-eye"></i></a>
                                            </div>
                                    </div>
                                    <div class="product-card-body">
                                        <div class="prod-rating">
                                            <i class="fas fa-star"></i><i class="fas fa-star"></i><i
                                                class="fas fa-star"></i><i class="fas fa-star"></i><i
                                                class="fas fa-star-half-alt"></i>
                                            <span>(4.2)</span>
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
                                            <span class="old-price">₹ <%# Convert.ToDecimal(Eval("Mrp")).ToString("N0")
                                                    %></span>
                                        </div>
                                        <div class="prod-action-row">
                                            <%# IsProductAvailable(Eval("IsActive"), Eval("Stock"),
                                                Eval("SellerActive")) ? @"<a href='javascript:void(0);'
                                                class='add-cart-btn js-add-to-cart' data-pid='" + Eval("Id") + @"'
                                                title='Add to Cart'><i class='fas fa-shopping-basket'></i></a>
                                                <a href='javascript:void(0);' class='buy-now-btn js-buy-now'
                                                    data-pid='" + Eval("Id") + @"'>Buy Now</a>" :
                                                @"<div class='oos-banner'><i class='fas fa-exclamation-circle'></i> OUT
                                                    OF STOCK</div>"
                                                %>
                                        </div>
                                    </div>
                                </div>
                            </ItemTemplate>
                        </asp:Repeater>
                    </div>

                    <asp:Panel ID="pnlNoData" runat="server" CssClass="empty-pl-msg" Visible="false">
                        <img src="https://cdn-icons-png.flaticon.com/512/7486/7486744.png"
                            style="width:80px; opacity:0.4; margin-bottom:20px;" />
                        <h4>No products found</h4>
                        <p>Try relaxing your filter criteria to explore more items.</p>
                    </asp:Panel>

                </main>

            </div>
        </div>

        <script>
            // 1. HANDLE SORTING DROPDOWN
            window.sortProducts = function (sel) {
                const url = new URL(window.location.href);
                url.searchParams.set('sort', sel.value);
                window.location.href = url.href;
            };

            document.addEventListener('DOMContentLoaded', function () {
                // Persist selected sort value from URL param
                const currentSort = new URLSearchParams(window.location.search).get('sort') || 'latest';
                const ddl = document.getElementById('ddlSort');
                if (ddl) ddl.value = currentSort;

                document.body.addEventListener('click', function (e) {
                    let btn = e.target.closest('.js-add-to-cart');
                    if (btn) {
                        e.preventDefault();
                        let pid = btn.getAttribute('data-pid');

                        btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Adding...';
                        btn.style.pointerEvents = 'none';

                        fetch('AddToCart.ashx?pid=' + pid + '&qty=1')
                            .then(r => r.json())
                            .then(data => {
                                if (data.success) {
                                    showToast('Successfully added to cart!', 'success');
                                    setTimeout(() => window.location.reload(), 1000); // slightly delay to show toast
                                } else {
                                    showToast(data.message || 'Error adding to cart.', 'error');
                                    btn.innerHTML = '<i class="fas fa-shopping-basket"></i> Add to Cart';
                                    btn.style.pointerEvents = 'auto';
                                }
                            })
                            .catch(() => {
                                showToast('Network error occurred.', 'error');
                                btn.innerHTML = '<i class="fas fa-shopping-basket"></i> Add to Cart';
                                btn.style.pointerEvents = 'auto';
                            });
                    }
                });
            });
        </script>

    </asp:Content>