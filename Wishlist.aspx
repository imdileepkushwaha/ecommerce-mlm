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

                        <asp:Panel ID="pnlEmpty" runat="server" Visible="false" CssClass="empty-state-premium">
                            <div class="empty-state-visual">
                                <img src="assets/images/empty-wishlist.svg" alt="Wishlist Empty" />
                            </div>
                            <h4 class="empty-state-heading">Your wishlist is empty</h4>
                            <p class="empty-state-sub">Explore our collection and add your absolute favorites!</p>
                            <a href="index.aspx" class="btn-pill-modern btn-orange-grad" style="text-decoration:none;"><i class="fas fa-shopping-bag"></i> Shop Now</a>
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
                    if (bagBtn.classList.contains('working')) return; // Block concurrent clicks
                    
                    bagBtn.classList.add('working');
                    bagBtn.style.pointerEvents = 'none'; // Immediate visual lockout
                    
                    const pid = bagBtn.getAttribute('data-pid');
                    bagBtn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Working...';
                    
                    fetch('AddToCart.ashx?pid=' + pid)
                        .then(r => r.json())
                        .then(d => {
                            if (d.success) {
                                // Chain Wishlist Removal API so the item is deleted from Wishlist database automatically!
                                fetch('AddToWishlist.ashx?action=remove&pid=' + pid)
                                    .then(wr => wr.json())
                                    .then(w => {
                                        showToast('Successfully moved to cart!', 'success');
                                        bagBtn.innerHTML = '<i class="fas fa-check"></i> Moved to Bag';
                                        bagBtn.style.background = '#10b981';
                                        
                                        const hCart = document.getElementById('cart_count');
                                        if (hCart) hCart.innerText = d.totalCount;
                                        
                                        // Animate removal from screen
                                        const card = bagBtn.closest('.wish-card');
                                        if (card) {
                                            card.style.transition = 'all 0.4s cubic-bezier(0.4, 0, 0.2, 1)';
                                            card.style.opacity = '0';
                                            card.style.transform = 'scale(0.85) translateY(20px)';
                                        }
                                        setTimeout(() => {
                                             window.location.reload(); // Clean sync reload
                                        }, 450);
                                    });
                            } else {
                                bagBtn.classList.remove('working');
                                bagBtn.style.pointerEvents = 'auto';
                                bagBtn.innerHTML = '<i class="fas fa-shopping-bag"></i> Try Again';
                                showToast(d.message || 'Failed adding to bag', 'error');
                            }
                        }).catch(err => {
                            bagBtn.classList.remove('working');
                            bagBtn.style.pointerEvents = 'auto';
                            bagBtn.innerHTML = '<i class="fas fa-shopping-bag"></i> Try Again';
                            console.error(err);
                        });
                }
            });
        });
    </script>
</asp:Content>
