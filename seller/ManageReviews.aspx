<%@ Page Title="Manage Product Reviews" Language="C#" MasterPageFile="~/seller/Seller.Master" AutoEventWireup="true"
    CodeFile="ManageReviews.aspx.cs" Inherits="EcommerceWebsite.SellerManageReviews" %>

    <asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

        <!-- SCRIPTA MANAGER -->
        <asp:ScriptManager ID="smReviews" runat="server"></asp:ScriptManager>

        <!-- ACTION BAR TOP -->
        <div class="page-action-bar">
            <div class="welcome-title">
                <h1 style="font-size: 1.6rem;"><i class="fas fa-comments"
                        style="color: var(--accent); margin-right: 8px;"></i>Customer Reviews</h1>
                <p>Moderate product ratings, approve constructive feedback, and drive listing engagement.</p>
            </div>
        </div>

        <!-- GLOBAL SYSTEM MESSAGES -->
        <asp:UpdatePanel ID="upnlMsg" runat="server" UpdateMode="Conditional">
            <ContentTemplate>
                <asp:Label ID="lblGlobalMsg" runat="server" Visible="false"
                    style="display:block; padding:16px 24px; border-radius:12px; margin-bottom:25px; font-size:0.9rem; font-weight:600;">
                </asp:Label>
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
                        <div class="d-icon-circle rv-ico-intake"><i class="fas fa-comments"></i></div>
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
                        <div class="d-icon-circle rv-ico-pending"><i class="fas fa-hourglass-half"></i></div>
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
                        <div class="d-icon-circle rv-ico-approved"><i class="fas fa-circle-check"></i></div>
                    </div>

                    <!-- Card 4: Avg Rating -->
                    <div class="d-card d-card-4 rv-card-score">
                        <div class="d-meta">
                            <span class="d-title">QUALITY SCORE</span>
                            <span class="d-count rv-score-val">
                                <asp:Literal ID="litAvgRating" runat="server">0.0</asp:Literal><span
                                    class="rv-score-star">★</span>
                            </span>
                            <span class="d-desc">Cumulative average</span>
                        </div>
                        <div class="d-icon-circle rv-ico-score"><i class="fas fa-star"></i></div>
                    </div>
                </div>

                <!-- 2. MAIN REVIEWS BOARD -->
                <div class="prod-card">
                    <!-- Custom Header resembling ord-worklist-hdr -->
                    <div class="ord-worklist-hdr">
                        <div class="ord-list-title">
                            <h3>Product Reviews Log</h3>
                            <p>Moderate ratings and approve constructive customer feedback</p>
                        </div>
                        <div class="ord-hdr-filters">
                            <div class="ord-search-box">
                                <i class="fas fa-search"></i>
                                <input type="text" id="txtReviewQuery" onkeyup="performReviewSearch()"
                                    class="ord-input-search" placeholder="Search product, customer, feedback, status..."
                                    autocomplete="off" />
                            </div>
                        </div>
                    </div>
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
                                <tr class="rv-row"
                                    data-filter-node='<%# Eval("ProductName") %> <%# Eval("ReviewerName") %> <%# Eval("ReviewText") %> <%# Eval("Rating") %> <%# Eval("ReviewStatus") %>'>
                                    <td>
                                        <div class="p-item-meta" style="max-width:240px;">
                                            <div class="p-thumb-box" style="width:45px; height:45px; flex-shrink:0;">
                                                <%# GetProductImage(Eval("MainImage")) %>
                                            </div>
                                            <div class="p-info-block" style="min-width:0;">
                                                <h4 style="white-space: nowrap; overflow: hidden; text-overflow: ellipsis; font-size:0.85rem;"
                                                    title='<%# Eval("ProductName") %>'>
                                                    <%# Eval("ProductName") %>
                                                </h4>
                                                <span class="rv-prod-id">ID: <%# Eval("ProductId") %></span>
                                            </div>
                                        </div>
                                    </td>
                                    <td>
                                        <div style="display:flex; align-items:center; gap:8px;">
                                            <div class="rv-reviewer-avatar">
                                                <i class="fas fa-user"></i>
                                            </div>
                                            <div>
                                                <strong class="rv-reviewer-name">
                                                    <%# Eval("ReviewerName") %>
                                                </strong>
                                                <%# Convert.ToBoolean(Eval("IsVerifiedPurchase"))
                                                    ? "<div class='rv-verified-badge'><i class='fas fa-check-circle'></i> Verified Purchase</div>"
                                                    : "" %>
                                            </div>
                                        </div>
                                    </td>
                                    <td>
                                        <div class="rv-stars-row">
                                            <%# GetStarsHTML(Eval("Rating")) %>
                                        </div>
                                        <div class="rv-feedback-text">
                                            "<%# Eval("ReviewText") %>"
                                        </div>
                                    </td>
                                    <td class="rv-date-cell">
                                        <%# Convert.ToDateTime(Eval("ReviewDate")).ToString("dd MMM yyyy · hh:mm tt") %>
                                    </td>
                                    <td>
                                        <%# GetStatusBadge(Eval("ReviewStatus")) %>
                                    </td>
                                    <td>
                                        <div class="action-btn-grp" style="justify-content: center; gap: 10px;">
                                            <asp:PlaceHolder ID="phActions" runat="server"
                                                Visible='<%# Eval("ReviewStatus").ToString().ToUpper() == "PENDING" %>'>
                                                <asp:LinkButton ID="btnApprove" runat="server"
                                                    CommandName="ApproveReview" CommandArgument='<%# Eval("Id") %>'
                                                    CssClass="action-ico rv-btn-approve"
                                                    ToolTip="Approve Review & Make Public">
                                                    <i class="fas fa-check"></i>
                                                </asp:LinkButton>
                                                <asp:LinkButton ID="btnReject" runat="server" CommandName="RejectReview"
                                                    CommandArgument='<%# Eval("Id") %>'
                                                    CssClass="action-ico rv-btn-reject" ToolTip="Reject & Mask Content">
                                                    <i class="fas fa-times"></i>
                                                </asp:LinkButton>
                                            </asp:PlaceHolder>
                                            <asp:PlaceHolder ID="phLocked" runat="server"
                                                Visible='<%# Eval("ReviewStatus").ToString().ToUpper() != "PENDING" %>'>
                                                <span class="rv-locked-lbl"><i class="fas fa-lock"
                                                        style="margin-right:3px;"></i> Action Completed</span>
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

                        <!-- Fallback zero-records alert -->
                        <div id="divReviewFallback" class="ord-fallback-div" style="display:none; padding:40px 20px;">
                            <i class="fas fa-magnifying-glass-minus ord-fallback-i"></i>
                            <h4 class="ord-fallback-h4">No Matching Reviews</h4>
                            <p class="ord-fallback-p">Modify your keywords to filter from the current customer reviews
                                log.</p>
                        </div>

                        <!-- EMPTY RUN ENGINE -->
                        <asp:PlaceHolder ID="phEmptyState" runat="server" Visible="false">
                            <div class="rv-empty-state">
                                <div class="rv-empty-icon"><i class="far fa-comments"></i></div>
                                <h4 class="rv-empty-title">No Reviews Logged</h4>
                                <p class="rv-empty-desc">Your products do not have any pending or processed ratings to
                                    display.</p>
                            </div>
                        </asp:PlaceHolder>
                    </div>
                </div>
            </ContentTemplate>
        </asp:UpdatePanel>

        <!-- Client Side Search Execution Engine -->
        <script type="text/javascript">
            function performReviewSearch() {
                var inp = document.getElementById('txtReviewQuery');
                if (!inp) return;
                var q = inp.value.trim().toLowerCase();

                // Save query to maintain UX state during refreshes
                sessionStorage.setItem('seller_reviews_searchquery', inp.value.trim());

                var tbl = document.querySelector('.prod-table');
                if (!tbl) return;

                var rws = tbl.querySelectorAll('.rv-row');
                var match = 0;

                rws.forEach(function (rw) {
                    var token = rw.getAttribute('data-filter-node').toLowerCase();
                    if (token.indexOf(q) > -1) {
                        rw.style.display = '';
                        match++;
                    } else {
                        rw.style.display = 'none';
                    }
                });

                var fb = document.getElementById('divReviewFallback');
                if (fb) {
                    fb.style.display = (match === 0 && rws.length > 0) ? 'block' : 'none';
                }
            }

            // Restore query on partial update or page reload
            function restoreReviewSearch() {
                var savedQ = sessionStorage.getItem('seller_reviews_searchquery');
                if (savedQ) {
                    var inp = document.getElementById('txtReviewQuery');
                    if (inp) {
                        inp.value = savedQ;
                        performReviewSearch();

                        // Maintain cursor and focus state
                        if (document.activeElement !== inp && savedQ.length > 0) {
                            inp.focus();
                            inp.setSelectionRange(inp.value.length, inp.value.length);
                        }
                    }
                }
            }

            // Bind events for full page load and partial AJAX postbacks
            window.addEventListener('DOMContentLoaded', restoreReviewSearch);

            if (typeof Sys !== 'undefined' && Sys.WebForms && Sys.WebForms.PageRequestManager) {
                Sys.WebForms.PageRequestManager.getInstance().add_endRequest(restoreReviewSearch);
            }
        </script>

    </asp:Content>