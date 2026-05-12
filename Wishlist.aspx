<%@ Page Title="My Wishlist" Language="C#" MasterPageFile="~/usersite.Master" AutoEventWireup="true" CodeFile="Wishlist.aspx.cs" Inherits="ecommerce_mlm.Wishlist" %>
<%@ Register Src="~/UserSidebar.ascx" TagPrefix="uc" TagName="UserSidebar" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <!-- Global Styles Handled in style.css -->
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <section class="dashboard-wrapper">
        <!-- Breadcrumb Top Bar -->
        <div class="dashboard-breadcrumb">
            <div class="container">
                <div class="dashboard-breadcrumb-inner">
                    <div class="breadcrumb-left">
                        <h3>My Wishlist</h3>
                    </div>
                    <div class="breadcrumb-right">
                        <a href="index.aspx"><i class="fas fa-home"></i></a>
                        <span> / Wishlist</span>
                    </div>
                </div>
            </div>
        </div>

        <div class="container dashboard-container" style="margin-top: 30px; margin-bottom: 60px;">
            <div class="dashboard-layout">
                
                <!-- Sidebar Start -->
                <uc:UserSidebar runat="server" ID="UserSidebar" />
                <!-- Sidebar End -->

                <!-- Main Content Area Start -->
                <main class="dashboard-main-content">
                    <div class="main-card" style="padding: 25px;">
                        <div class="wishlist-header">
                            <h2><i class="fas fa-heart"></i> My Wishlist (<asp:Literal ID="litWishCount" runat="server">0</asp:Literal>)</h2>
                        </div>

                        <!-- Item List -->
                        <asp:Repeater ID="rptWishlist" runat="server">
                            <HeaderTemplate>
                                <div class="wishlist-grid">
                            </HeaderTemplate>
                            <ItemTemplate>
                                <div class="wish-card">
                                    <a href='javascript:void(0);' class="btn-wish-remove js-wishlist-remove" data-pid='<%# Eval("ProductId") %>' title="Remove from wishlist">
                                        <i class="fas fa-times"></i>
                                    </a>
                                    <a href='<%# "ProductDetails.aspx?id=" + Eval("ProductId") %>' class="wish-img-link">
                                        <img src='<%# ResolveUrl(Eval("MainImage") != DBNull.Value && !string.IsNullOrEmpty(Eval("MainImage").ToString()) ? Eval("MainImage").ToString() : "https://via.placeholder.com/300x350?text=No+Image") %>' onerror="this.onerror=null; this.src='https://via.placeholder.com/300x350?text=No+Image';" alt="product" />
                                    </a>
                                    <div class="wish-details">
                                        <div class="wish-cat"><%# Eval("CategoryName") %></div>
                                        <a href='<%# "ProductDetails.aspx?id=" + Eval("ProductId") %>' class="wish-title">
                                            <%# Eval("Name") %>
                                        </a>
                                        <div class="wish-pricing">
                                            <span class="wish-price">₹ <%# String.Format("{0:n0}", Eval("Price")) %></span>
                                            <%# Convert.ToDecimal(Eval("Mrp")) > Convert.ToDecimal(Eval("Price")) ? "<span class='wish-mrp'>₹ " + String.Format("{0:n0}", Eval("Mrp")) + "</span>" : "" %>
                                        </div>
                                        <div class="wish-actions">
                                            <a href="javascript:void(0);" class="btn-add-bag js-wish-to-cart" data-pid='<%# Eval("ProductId") %>'>
                                                <i class="fas fa-shopping-bag"></i> Add to Bag
                                            </a>
                                        </div>
                                    </div>
                                </div>
                            </ItemTemplate>
                            <FooterTemplate>
                                </div>
                            </FooterTemplate>
                        </asp:Repeater>

                        <asp:Panel ID="pnlEmpty" runat="server" Visible="false" CssClass="empty-wishlist" style="box-shadow:none; padding:40px 10px;">
                            <div style="margin-bottom: 20px;">
                                <svg width="120" height="120" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
                                    <rect width="24" height="24" fill="none"/>
                                    <circle cx="12" cy="12" r="10" fill="#FEF2F2"/>
                                    <path d="M12 18.5C11.8 18.5 11.6 18.45 11.43 18.36C9.25 17.27 3 13.43 3 8.5C3 5.74 5.24 3.5 8 3.5C9.33 3.5 10.6 4.02 11.54 4.96C11.79 5.21 12.21 5.21 12.46 4.96C13.4 4.02 14.67 3.5 16 3.5C18.76 3.5 21 5.74 21 8.5C21 13.43 14.75 17.27 12.57 18.36C12.4 18.45 12.2 18.5 12 18.5ZM8 5C6.07 5 4.5 6.57 4.5 8.5C4.5 11.96 9.36 15.36 12 16.71C14.64 15.36 19.5 11.96 19.5 8.5C19.5 6.57 17.93 5 16 5C14.98 5 14.02 5.44 13.38 6.21L12 7.85L10.62 6.21C9.98 5.44 9.02 5 8 5Z" fill="#EF4444"/>
                                    <path opacity="0.4" d="M16 7C16.83 7 17.5 7.67 17.5 8.5C17.5 9.33 16.83 10 16 10C15.17 10 14.5 9.33 14.5 8.5C14.5 7.67 15.17 7 16 7Z" fill="#EF4444"/>
                                </svg>
                            </div>
                            <h4>Your wishlist is empty</h4>
                            <p>Explore our collection and add your favorites!</p>
                            <a href="index.aspx" class="btn-shop-now">Shop Now</a>
                        </asp:Panel>

                    </div>
                </main>
                <!-- Main Content Area End -->
            </div>
        </div>
    </section>
    
    <script>
        // Immediate forceful bypass for preloader hung states
        (function() {
            var forceLoader = document.getElementById('preloader');
            if (forceLoader) { forceLoader.style.display = 'none'; }
        })();
    </script>
    <script>
        document.addEventListener('DOMContentLoaded', function() {
            // Remove from wishlist handler
            document.body.addEventListener('click', function(e) {
                const remBtn = e.target.closest('.js-wishlist-remove');
                if (remBtn) {
                    e.preventDefault();
                    const pid = remBtn.getAttribute('data-pid');
                    
                    fetch('AddToWishlist.ashx?action=remove&pid=' + pid)
                        .then(r => r.json())
                        .then(d => {
                            if (d.success) {
                                // Instant fade out
                                const card = remBtn.closest('.wish-card');
                                card.style.opacity = '0';
                                card.style.transform = 'scale(0.9)';
                                setTimeout(() => {
                                     window.location.reload(); // Refresh updated view
                                }, 300);
                            } else {
                                showToast(d.message || 'Operation failed', 'error');
                            }
                        });
                }
                
                // Add to bag from wishlist handler
                const bagBtn = e.target.closest('.js-wish-to-cart');
                if (bagBtn) {
                    e.preventDefault();
                    const pid = bagBtn.getAttribute('data-pid');
                    bagBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Working...';
                    
                    fetch('AddToCart.ashx?pid=' + pid)
                        .then(r => r.json())
                        .then(d => {
                            if (d.success) {
                                showToast('Successfully moved to cart!', 'success');
                                bagBtn.innerHTML = '<i class="fas fa-check"></i> Added';
                                bagBtn.style.background = '#10b981';
                                // Optionally auto update header if present
                                const hCart = document.getElementById('cart_count');
                                if (hCart) hCart.innerText = d.totalCount;
                            } else {
                                bagBtn.innerHTML = '<i class="fas fa-shopping-bag"></i> Try Again';
                                showToast(d.message || 'Failed adding to bag', 'error');
                            }
                        });
                }
            });
        });
    </script>
</asp:Content>
