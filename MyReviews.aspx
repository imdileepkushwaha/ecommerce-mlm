<%@ Page Title="My Reviews" Language="C#" MasterPageFile="~/usersite.Master" AutoEventWireup="true"
    CodeFile="MyReviews.aspx.cs" Inherits="ecommerce_mlm.MyReviews" %>
    <%@ Register Src="~/UserSidebar.ascx" TagPrefix="uc" TagName="UserSidebar" %>

        <asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">

        </asp:Content>

        <asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
            <asp:ScriptManager ID="ScriptManager1" runat="server" />

            <section class="dashboard-wrapper">
                <div class="container dashboard-container" style="padding-top: 30px;">
                    <div class="dashboard-layout">
                        <!-- Sidebar Section -->
                        <uc:UserSidebar runat="server" ID="UserSidebar" />

                        <!-- Main Area -->
                        <main class="dashboard-main-content">
                            <div class="review-dashboard-content">
                                <h1 class="page-header-title">My Reviews</h1>

                                <asp:UpdatePanel ID="upnlMain" runat="server" UpdateMode="Conditional">
                                    <ContentTemplate>
                                        <asp:Repeater ID="rptProductReviews" runat="server"
                                            OnItemCommand="rptProductReviews_ItemCommand"
                                            OnItemDataBound="rptProductReviews_ItemDataBound">
                                            <ItemTemplate>
                                                <!-- Individual Card representing Product + Review logic -->
                                                <div class="review-item-card">
                                                    <div class="prod-meta-row">
                                                        <div class="prod-info-left">
                                                            <!-- Product Image -->
                                                            <img src='<%# ResolveProductImage(Eval("MainImage")) %>'
                                                                class="prod-img-thumb" alt="Product"
                                                                onerror="this.src='assets/images/no-image.png';" />

                                                            <div class="prod-details-stack">
                                                                <!-- Product Name -->
                                                                <h4 class="prod-title-link">
                                                                    <%# Eval("ProductName") %>
                                                                </h4>
                                                                <!-- Delivered / Order Date -->
                                                                <span class="order-date-text">
                                                                    <i class="far fa-calendar-alt"></i>
                                                                    <%# Convert.ToDateTime(Eval("CreatedAt")).ToString("MMM dd, yyyy") %>
                                                                </span>
                                                            </div>
                                                        </div>

                                                        <!-- Action Badges / Trigger Buttons on Right -->
                                                        <div class="action-badge-right">
                                                            <!-- STATE: No Review Made Yet -->
                                                            <asp:LinkButton ID="btnWriteReviewTrigger" runat="server"
                                                                CommandName="ExpandForm"
                                                                CommandArgument='<%# Eval("ProductId") %>'
                                                                CssClass="btn-write-rev-pill"
                                                                Visible='<%# Convert.ToInt32(Eval("HasReviewed")) == 0 %>'>
                                                                <i class="fas fa-pencil-alt"></i> Write Review
                                                            </asp:LinkButton>

                                                            <!-- STATE: Approved Review -->
                                                            <div class="badge-approved" runat="server"
                                                                visible='<%# Convert.ToInt32(Eval("HasReviewed")) == 1 && Eval("ReviewStatus").ToString().ToUpper() == "APPROVED" %>'>
                                                                <i class="fas fa-check"></i> Approved
                                                            </div>

                                                            <!-- STATE: Pending Review -->
                                                            <div class="badge-pending" runat="server"
                                                                visible='<%# Convert.ToInt32(Eval("HasReviewed")) == 1 && Eval("ReviewStatus").ToString().ToUpper() == "PENDING" %>'>
                                                                <i class="far fa-clock"></i> Under Process
                                                            </div>

                                                            <!-- STATE: Rejected Review -->
                                                            <div class="badge-pending"
                                                                style="background:#fef2f2; border-color:#fecaca; color:#dc2626;"
                                                                runat="server"
                                                                visible='<%# Convert.ToInt32(Eval("HasReviewed")) == 1 && Eval("ReviewStatus").ToString().ToUpper() == "REJECTED" %>'>
                                                                <i class="fas fa-ban"></i> Rejected
                                                            </div>
                                                        </div>
                                                    </div>

                                                    <!-- SECTION A: Output Review Content (If Reviewed Already) -->
                                                    <div class="review-output-block" runat="server"
                                                        visible='<%# Convert.ToInt32(Eval("HasReviewed")) == 1 %>'>
                                                        <div class="rev-rating-display-row">
                                                            <div class="stars-gold">
                                                                <%# GetVisualStars(Eval("Rating")) %>
                                                            </div>
                                                            <span class="rating-badge-mini">
                                                                <%# Eval("Rating") %>/5
                                                            </span>
                                                        </div>
                                                        <p class="review-comment-quote">"<%# Eval("ReviewText") %>"</p>
                                                    </div>

                                                    <!-- SECTION B: Expandable Write Review Panel (Inline) -->
                                                    <asp:Panel ID="pnlInlineWriteReview" runat="server"
                                                        CssClass="write-review-inline-panel" Visible="false">
                                                        <h5 class="inline-panel-title">
                                                            <i class="fas fa-pencil-alt"></i> Share your experience with
                                                            this product
                                                        </h5>

                                                        <div class="inline-form-grid">
                                                            <!-- Star Rating DD -->
                                                            <asp:DropDownList ID="ddlStars" runat="server"
                                                                CssClass="star-select-ddl">
                                                                <asp:ListItem Text="⭐⭐⭐⭐⭐ 5 Stars" Value="5"
                                                                    Selected="True"></asp:ListItem>
                                                                <asp:ListItem Text="⭐⭐⭐⭐ 4 Stars" Value="4">
                                                                </asp:ListItem>
                                                                <asp:ListItem Text="⭐⭐⭐ 3 Stars" Value="3">
                                                                </asp:ListItem>
                                                                <asp:ListItem Text="⭐⭐ 2 Stars" Value="2">
                                                                </asp:ListItem>
                                                                <asp:ListItem Text="⭐ 1 Star" Value="1"></asp:ListItem>
                                                            </asp:DropDownList>

                                                            <!-- Review Text input -->
                                                            <asp:TextBox ID="txtInlineComment" runat="server"
                                                                CssClass="review-textbox-input"
                                                                placeholder="Share what you think about this product..."
                                                                MaxLength="300"></asp:TextBox>

                                                            <!-- Submit Trigger -->
                                                            <asp:Button ID="btnInlineSubmitReview" runat="server"
                                                                Text="Submit" CommandName="SubmitReview"
                                                                CommandArgument='<%# Eval("ProductId") %>'
                                                                CssClass="btn-inline-submit" />
                                                        </div>

                                                        <asp:Label ID="lblInlineError" runat="server"
                                                            CssClass="error-feedback-label" Visible="false"></asp:Label>
                                                    </asp:Panel>
                                                </div>
                                            </ItemTemplate>
                                        </asp:Repeater>

                                        <!-- Empty State Display -->
                                        <asp:Panel ID="pnlEmpty" runat="server" Visible="false"
                                            style="text-align:center; padding:40px; background:#fff; border-radius:16px; border:1px solid #f1f5f9;">
                                            <img src="assets/images/dashboard/notification.svg"
                                                style="width:80px; margin-bottom:16px; opacity:0.4;" alt="Empty" />
                                            <h4 style="font-weight:700; color:#334155; margin-bottom:8px;">No orders
                                                found for review</h4>
                                            <p style="color:#64748b; font-size:14px;">When your orders are delivered,
                                                they will show up here for your valuable feedback.</p>
                                        </asp:Panel>

                                    </ContentTemplate>
                                </asp:UpdatePanel>

                            </div>
                        </main>
                    </div>
                </div>
            </section>
        </asp:Content>