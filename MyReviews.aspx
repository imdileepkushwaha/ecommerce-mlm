<%@ Page Title="My Reviews" Language="C#" MasterPageFile="~/usersite.Master" AutoEventWireup="true" CodeFile="MyReviews.aspx.cs" Inherits="ecommerce_mlm.MyReviews" %>
<%@ Register Src="~/UserSidebar.ascx" TagPrefix="uc" TagName="UserSidebar" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <style>
        /* Overrides for Star selection */
        .star-option { cursor:pointer; font-size: 1.8rem; color: #cbd5e1; transition: color 0.1s; }
        .star-option.selected { color: #fbbf24; }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>

    <section class="dashboard-wrapper">
        <div class="dashboard-breadcrumb">
            <div class="container">
                <div class="dashboard-breadcrumb-inner">
                    <div class="breadcrumb-left"><h3>Product Reviews</h3></div>
                    <div class="breadcrumb-right">
                        <a href="index.aspx"><i class="fas fa-home"></i></a>
                        <span> / Reviews</span>
                    </div>
                </div>
            </div>
        </div>

        <div class="container">
            <div class="dashboard-layout">
                <!-- User Navigation -->
                <uc:UserSidebar runat="server" ID="UserSidebar" />

                <!-- Main Body -->
                <main class="dashboard-main-content">
                    <asp:UpdatePanel ID="upnlReviews" runat="server">
                        <ContentTemplate>
                            <div class="main-card main-card-padded">
                                
                                <div class="section-title section-title-bordered" style="margin-bottom: 25px;">
                                    <div><i class="fas fa-star"></i> Rate Delivered Products</div>
                                </div>

                                <!-- Dynamic Repeater -->
                                <div class="review-card-list">
                                    <asp:Repeater ID="rptDeliveredProducts" runat="server" OnItemCommand="rptDeliveredProducts_ItemCommand">
                                        <ItemTemplate>
                                            <div class="rev-item-row">
                                                <!-- Left Column: Product Detail -->
                                                <img src='<%# ResolveUrl("~/assets/images/products/" + Eval("MainImage")) %>' 
                                                     onerror="this.src='assets/images/no-image.png';" class="rev-prod-thumb" />
                                                
                                                <div class="rev-info-block">
                                                    <div class="rev-prod-name"><%# Eval("ProductName") %></div>
                                                    <div class="rev-status-badge"><i class="fas fa-check-circle"></i> Verified Purchase - Delivered</div>
                                                </div>

                                                <!-- Right Column: Review status block -->
                                                <div class="rev-action-area">
                                                    
                                                    <!-- STATE 1: Already Reviewed (DISPLAY MODE, NO EDIT) -->
                                                    <asp:Panel runat="server" Visible='<%# Convert.ToInt32(Eval("HasReviewed")) == 1 %>' CssClass="existing-rev-box">
                                                        <div class="rev-stars-display">
                                                            <%# ecommerce_mlm.MyReviews.GetStarsHTML(Convert.ToInt32(Eval("Rating"))) %>
                                                        </div>
                                                        <div class="rev-comment-txt">"<%# Eval("ReviewText") %>"</div>
                                                        <div style="font-size:0.75rem; color:#94a3b8; margin-top:8px; font-weight:600;">Reviewed on <%# Convert.ToDateTime(Eval("ReviewDate")).ToString("dd MMM yyyy") %></div>
                                                    </asp:Panel>

                                                    <!-- STATE 2: Not Reviewed (WRITE MODE) -->
                                                    <asp:Panel runat="server" Visible='<%# Convert.ToInt32(Eval("HasReviewed")) == 0 %>'>
                                                        <asp:LinkButton ID="btnWriteRev" runat="server" CommandName="TriggerReview" CommandArgument='<%# Eval("ProductId") + "|" + Eval("ProductName") %>' 
                                                                        CssClass="btn-pill-modern btn-orange-grad" style="font-size:0.85rem; padding: 10px 20px;">
                                                            <i class="fas fa-pen"></i> Write Review
                                                        </asp:LinkButton>
                                                    </asp:Panel>

                                                </div>
                                            </div>
                                        </ItemTemplate>
                                    </asp:Repeater>

                                    <asp:Panel ID="pnlNoProducts" runat="server" Visible="false" CssClass="empty-state-premium">
                                        <div class="empty-state-visual">
                                            <img src="assets/images/empty-orders.svg" alt="No delivered products" />
                                        </div>
                                        <h4 class="empty-state-heading">No Delivered Products Yet</h4>
                                        <p class="empty-state-sub">
                                            You don't have any delivered products awaiting your review right now. 
                                            Shop now and check back once your items arrive!
                                        </p>
                                        <a href="index.aspx" class="btn-pill-modern btn-orange-grad" style="text-decoration:none;"><i class="fas fa-shopping-bag"></i> Start Shopping</a>
                                    </asp:Panel>
                                </div>

                            </div>

                            <!-- SUBMIT REVIEW POPUP MODAL -->
                            <asp:Panel ID="pnlReviewModal" runat="server" CssClass="modal-overlay" Visible="false">
                                <div class="modal-container" style="max-width:450px;">
                                    <div class="modal-header">
                                        <h3>Submit Review</h3>
                                        <asp:LinkButton ID="btnCloseModal" runat="server" CssClass="btn-close-modal" OnClick="btnCloseModal_Click"><i class="fas fa-times"></i></asp:LinkButton>
                                    </div>
                                    <div class="modal-body">
                                        <asp:HiddenField ID="hfRevProdId" runat="server" />
                                        <asp:HiddenField ID="hfRatingValue" runat="server" Value="0" />
                                        
                                        <div style="text-align: center; margin-bottom: 20px;">
                                            <h5 style="color:#1e293b; font-weight:700; margin-bottom:5px;">Rate this Product</h5>
                                            <asp:Label ID="lblModalProdName" runat="server" CssClass="rev-prod-name" Font-Bold="false"></asp:Label>
                                        </div>

                                        <!-- Visual Star Selector -->
                                        <div style="display: flex; justify-content: center; gap: 10px; margin-bottom: 25px;">
                                            <i class="fas fa-star star-option" onclick="setRating(1)"></i>
                                            <i class="fas fa-star star-option" onclick="setRating(2)"></i>
                                            <i class="fas fa-star star-option" onclick="setRating(3)"></i>
                                            <i class="fas fa-star star-option" onclick="setRating(4)"></i>
                                            <i class="fas fa-star star-option" onclick="setRating(5)"></i>
                                        </div>

                                        <div class="modal-form-group">
                                            <label>Share your experience (Comments)</label>
                                            <asp:TextBox ID="txtReviewText" runat="server" TextMode="MultiLine" Rows="4" CssClass="form-control-custom" style="resize:none;" placeholder="What did you like or dislike about this product?"></asp:TextBox>
                                        </div>

                                        <asp:Label ID="lblModalErr" runat="server" ForeColor="Red" Font-Size="Small" Font-Bold="true"></asp:Label>
                                    </div>
                                    <div class="modal-footer">
                                        <asp:LinkButton ID="btnCancel" runat="server" CssClass="btn-pill-modern btn-soft-outline" OnClick="btnCloseModal_Click">Cancel</asp:LinkButton>
                                        <asp:Button ID="btnSubmitReview" runat="server" Text="Post Review" CssClass="btn-pill-modern btn-orange-grad" style="border:none;" OnClick="btnSubmitReview_Click" />
                                    </div>
                                </div>
                            </asp:Panel>

                            <script type="text/javascript">
                                function showModal() {
                                    var mod = document.querySelector('.modal-overlay');
                                    if(mod) mod.classList.add('active');
                                }
                                
                                function setRating(n) {
                                    // Save logic back to server hidden field
                                    document.getElementById('<%= hfRatingValue.ClientID %>').value = n;
                                    
                                    // Visual update
                                    var stars = document.querySelectorAll('.star-option');
                                    stars.forEach(function(star, index) {
                                        if (index < n) {
                                            star.classList.add('selected');
                                        } else {
                                            star.classList.remove('selected');
                                        }
                                    });
                                }
                            </script>

                        </ContentTemplate>
                    </asp:UpdatePanel>
                </main>
            </div>
        </div>
    </section>
</asp:Content>
