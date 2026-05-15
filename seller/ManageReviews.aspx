<%@ Page Title="Manage Product Reviews" Language="C#" MasterPageFile="~/seller/Seller.Master" AutoEventWireup="true" CodeFile="ManageReviews.aspx.cs" Inherits="EcommerceWebsite.SellerManageReviews" %>

<asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    
    <!-- SCRIPTA MANAGER -->
    <asp:ScriptManager ID="smReviews" runat="server"></asp:ScriptManager>

    <!-- ACTION BAR TOP -->
    <div class="page-action-bar">
        <div class="welcome-title">
            <h1 style="font-size: 1.6rem;"><i class="fas fa-comments" style="color: var(--accent); margin-right: 8px;"></i>Customer Reviews</h1>
            <p>Moderate product ratings, approve constructive feedback, and drive listing engagement.</p>
        </div>
    </div>

    <!-- GLOBAL SYSTEM MESSAGES -->
    <asp:UpdatePanel ID="upnlMsg" runat="server" UpdateMode="Conditional">
        <ContentTemplate>
            <asp:Label ID="lblGlobalMsg" runat="server" Visible="false" style="display:block; padding:16px 24px; border-radius:12px; margin-bottom:25px; font-size:0.9rem; font-weight:600;"></asp:Label>
        </ContentTemplate>
    </asp:UpdatePanel>

    <!-- UPDATABLE WORKSPACE BINDER (METRICS + GRID) -->
    <asp:UpdatePanel ID="upnlWorkspace" runat="server" UpdateMode="Always">
        <ContentTemplate>
            
            <!-- 1. SYSTEM METRICS DECK -->
            <div class="dashboard-stat-row">
                <!-- Card 1: Total Intake -->
                <div class="d-card d-card-1">
                    <div class="d-meta">
                        <span class="d-title">TOTAL RECEIVED</span>
                        <span class="d-count">
                            <asp:Literal ID="litTotalReviews" runat="server">0</asp:Literal>
                        </span>
                        <span class="d-desc">Lifetime customer ratings</span>
                    </div>
                    <div class="d-icon-circle" style="background:#eff6ff; color:#3b82f6;"><i class="fas fa-comments"></i></div>
                </div>

                <!-- Card 2: Pending Action -->
                <div class="d-card d-card-3">
                    <div class="d-meta">
                        <span class="d-title">PENDING ACTION</span>
                        <span class="d-count">
                            <asp:Literal ID="litPendingReviews" runat="server">0</asp:Literal>
                        </span>
                        <span class="d-desc">Requires moderation</span>
                    </div>
                    <div class="d-icon-circle" style="background:#fffbeb; color:#f59e0b;"><i class="fas fa-hourglass-half"></i></div>
                </div>

                <!-- Card 3: Approved Public -->
                <div class="d-card d-card-2">
                    <div class="d-meta">
                        <span class="d-title">APPROVED PUBLIC</span>
                        <span class="d-count">
                            <asp:Literal ID="litApprovedReviews" runat="server">0</asp:Literal>
                        </span>
                        <span class="d-desc">Published feedback</span>
                    </div>
                    <div class="d-icon-circle" style="background:#ecfdf5; color:#10b981;"><i class="fas fa-circle-check"></i></div>
                </div>

                <!-- Card 4: Avg Rating -->
                <div class="d-card d-card-4" style="border-top-color: #8b5cf6;">
                    <div class="d-meta">
                        <span class="d-title">QUALITY SCORE</span>
                        <span class="d-count" style="color:#8b5cf6;">
                            <asp:Literal ID="litAvgRating" runat="server">0.0</asp:Literal><span style="font-size:0.9rem; color:#94a3b8; margin-left:2px;">★</span>
                        </span>
                        <span class="d-desc">Cumulative average</span>
                    </div>
                    <div class="d-icon-circle" style="background:#f5f3ff; color:#8b5cf6;"><i class="fas fa-star"></i></div>
                </div>
            </div>

            <!-- 2. MAIN REVIEWS BOARD -->
            <div class="prod-card">
                <div class="prod-table-wrap">
                    <asp:Repeater ID="rptReviews" runat="server" OnItemCommand="rptReviews_ItemCommand">
                        <HeaderTemplate>
                            <table class="prod-table">
                                <thead>
                                    <tr>
                                        <th>Product Details</th>
                                        <th>Reviewer</th>
                                        <th>Rating & Feedback</th>
                                        <th>Submission Date</th>
                                        <th>Status</th>
                                        <th style="text-align: center;">Moderation</th>
                                    </tr>
                                </thead>
                                <tbody>
                        </HeaderTemplate>
                        <ItemTemplate>
                            <tr>
                                <td>
                                    <div class="p-item-meta" style="max-width:240px;">
                                        <div class="p-thumb-box" style="width:45px; height:45px; flex-shrink:0;">
                                            <%# GetProductImage(Eval("MainImage")) %>
                                        </div>
                                        <div class="p-info-block" style="min-width:0;">
                                            <h4 style="white-space: nowrap; overflow: hidden; text-overflow: ellipsis; font-size:0.85rem;" title='<%# Eval("ProductName") %>'>
                                                <%# Eval("ProductName") %>
                                            </h4>
                                            <span style="font-size:0.75rem; color:#64748b;">ID: <%# Eval("ProductId") %></span>
                                        </div>
                                    </div>
                                </td>
                                <td>
                                    <div style="display:flex; align-items:center; gap:8px;">
                                        <div style="width:28px; height:28px; background:#e2e8f0; border-radius:50%; display:flex; align-items:center; justify-content:center; color:#475569; font-size:0.75rem;">
                                            <i class="fas fa-user"></i>
                                        </div>
                                        <div>
                                            <strong style="color: #1e293b; font-size:0.85rem;"><%# Eval("ReviewerName") %></strong>
                                            <%# Convert.ToBoolean(Eval("IsVerifiedPurchase")) ? "<div style='font-size:10px; color:#059669; font-weight:700;'><i class='fas fa-check-circle'></i> Verified Purchase</div>" : "" %>
                                        </div>
                                    </div>
                                </td>
                                <td>
                                    <div style="margin-bottom: 6px; color: #f59e0b; font-size:0.75rem;">
                                        <%# GetStarsHTML(Eval("Rating")) %>
                                    </div>
                                    <div style="font-size: 0.85rem; color: #334155; max-width: 300px; font-style:italic; line-height:1.4; word-wrap: break-word;">
                                        "<%# Eval("ReviewText") %>"
                                    </div>
                                </td>
                                <td style="font-size:0.8rem; color:#475569;">
                                    <%# Convert.ToDateTime(Eval("ReviewDate")).ToString("dd MMM yyyy · hh:mm tt") %>
                                </td>
                                <td>
                                    <%# GetStatusBadge(Eval("ReviewStatus")) %>
                                </td>
                                <td>
                                    <div class="action-btn-grp" style="justify-content: center; gap: 10px;">
                                        <asp:PlaceHolder ID="phActions" runat="server" Visible='<%# Eval("ReviewStatus").ToString().ToUpper() == "PENDING" %>'>
                                            <asp:LinkButton ID="btnApprove" runat="server" 
                                                CommandName="ApproveReview" 
                                                CommandArgument='<%# Eval("Id") %>'
                                                CssClass="action-ico"
                                                style="background: #ecfdf5; color: #059669; border: 1px solid #a7f3d0;"
                                                ToolTip="Approve Review & Make Public">
                                                <i class="fas fa-check"></i>
                                            </asp:LinkButton>
                                            <asp:LinkButton ID="btnReject" runat="server" 
                                                CommandName="RejectReview" 
                                                CommandArgument='<%# Eval("Id") %>'
                                                CssClass="action-ico"
                                                style="background: #fef2f2; color: #dc2626; border: 1px solid #fecaca;"
                                                ToolTip="Reject & Mask Content">
                                                <i class="fas fa-times"></i>
                                            </asp:LinkButton>
                                        </asp:PlaceHolder>
                                        <asp:PlaceHolder ID="phLocked" runat="server" Visible='<%# Eval("ReviewStatus").ToString().ToUpper() != "PENDING" %>'>
                                            <span style="font-size:0.75rem; color:#94a3b8; font-weight:600;"><i class="fas fa-lock" style="margin-right:3px;"></i> Action Completed</span>
                                        </asp:PlaceHolder>
                                    </div>
                                </td>
                            </tr>
                        </ItemTemplate>
                        <FooterTemplate>
                                </tbody>
                            </table>
                        </FooterTemplate>
                    </asp:Repeater>

                    <!-- EMPTY RUN ENGINE -->
                    <asp:PlaceHolder ID="phEmptyState" runat="server" Visible="false">
                        <div style="text-align:center; padding:60px 20px;">
                            <div style="font-size:3.5rem; color:#cbd5e1; margin-bottom:15px;"><i class="far fa-comments"></i></div>
                            <h4 style="font-weight:800; font-size:1.1rem; color:#0f172a; margin-bottom:6px;">No Reviews Logged</h4>
                            <p style="color:#64748b; font-size:0.9rem; max-width:400px; margin:0 auto 20px;">Your products do not have any pending or processed ratings to display.</p>
                        </div>
                    </asp:PlaceHolder>
                </div>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>

</asp:Content>
