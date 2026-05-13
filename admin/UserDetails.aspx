<%@ Page Title="User Deep Profile" Language="C#" MasterPageFile="~/admin/Admin.Master" AutoEventWireup="true" CodeFile="UserDetails.aspx.cs" Inherits="ecommerce_mlm.admin.UserDetails" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="u-mb-30">
        <a href="ManageUsers.aspx" class="u-back-nav">
            <i class="fas fa-arrow-left"></i> Back to Directory
        </a>
    </div>

    <div class="profile-grid">
        <!-- Left Side: Core Profile -->
        <div class="u-profile-shell">
            <div class="u-profile-banner"></div>
            <div class="u-profile-body">
                <div class="u-avatar-ring">
                    <asp:Literal ID="litInitials" runat="server"></asp:Literal>
                </div>
                <h2 class="u-color-dark u-bold-800 u-mb-15 u-font-size-1-4">
                    <asp:Literal ID="litFullName" runat="server"></asp:Literal>
                </h2>
                <p class="u-txt-gray-sm u-mb-15 u-mono-block u-display-inline-block u-bg-transparent u-txt-09">@<asp:Literal ID="litUsername" runat="server"></asp:Literal></p>
                
                <div class="u-mb-25">
                    <asp:Label ID="lblStatusBadge" runat="server" CssClass="badge"></asp:Label>
                </div>

                <div>
                    <div class="u-detail-entry"><span class="u-lbl">Email</span><span class="u-val"><asp:Literal ID="litEmail" runat="server"></asp:Literal></span></div>
                    <div class="u-detail-entry"><span class="u-lbl">Mobile</span><span class="u-val"><asp:Literal ID="litMobile" runat="server"></asp:Literal></span></div>
                    <div class="u-detail-entry"><span class="u-lbl">Joined</span><span class="u-val"><asp:Literal ID="litJoinDate" runat="server"></asp:Literal></span></div>
                    <div class="u-detail-entry"><span class="u-lbl">Sponsor</span><span class="u-val u-sponsor-val"><asp:Literal ID="litSponsor" runat="server"></asp:Literal></span></div>
                    <div class="u-detail-entry"><span class="u-lbl">Gender</span><span class="u-val"><asp:Literal ID="litGender" runat="server"></asp:Literal></span></div>
                </div>
            </div>
        </div>

        <!-- Right Side: Deep Metrics & Secondary Content -->
        <div>
            <!-- Top Summary Row -->
            <div class="u-grid-3col">
                <div class="u-metric-box">
                    <div class="u-metric-ico u-stat-icon-w"><i class="fas fa-wallet"></i></div>
                    <div>
                        <div class="u-lbl u-text-upper">Total Earned</div>
                        <div class="u-bold-800 u-txt-1rem u-mt-3 u-metric-val-font">₹<asp:Literal ID="litTotalIncome" runat="server">0.00</asp:Literal></div>
                    </div>
                </div>
                
                <div class="u-metric-box">
                    <div class="u-metric-ico u-stat-icon-g"><i class="fas fa-users"></i></div>
                    <div>
                        <div class="u-lbl u-text-upper">Direct Team</div>
                        <div class="u-bold-800 u-mt-3 u-metric-val-font"><asp:Literal ID="litTeamCount" runat="server">0</asp:Literal> <span class="u-txt-gray-sm u-txt-09 u-metric-subtext">Members</span></div>
                    </div>
                </div>

                <div class="u-metric-box">
                    <div class="u-metric-ico u-stat-icon-y"><i class="fas fa-award"></i></div>
                    <div>
                        <div class="u-lbl u-text-upper">Reward Total</div>
                        <div class="u-bold-800 u-mt-3 u-metric-val-font"><asp:Literal ID="litRewardPoints" runat="server">0</asp:Literal> <span class="u-txt-gray-sm u-txt-09 u-metric-subtext">Pts</span></div>
                    </div>
                </div>
            </div>

            <!-- Section: Bank Details -->
            <div class="u-sec-hdr"><i class="fas fa-university"></i> Settlement Channels</div>
            <div class="u-data-cont">
                <asp:Repeater ID="rptBank" runat="server">
                    <ItemTemplate>
                        <div class="u-row-item u-j-between u-a-center">
                            <div class="u-d-flex u-gap-18 u-a-center">
                                <div class="u-icon-w">
                                    <i class="fas fa-credit-card"></i>
                                </div>
                                <div>
                                    <div class="u-bold-800 u-color-dark u-txt-1rem"><%# Eval("BankName") %></div>
                                    <div class="u-txt-gray-sm u-mt-2">Acc No: <strong class="u-color-dark"><%# Eval("AccountNumber") %></strong> <span class="u-color-gray-500 u-separator">|</span> IFSC: <%# Eval("IFSCCode") %></div>
                                </div>
                            </div>
                            <div class="u-text-right u-txt-085">
                                <div class="u-bold-700 u-color-dark u-text-upper"><%# Eval("AccountHolderName") %></div>
                                <div class="u-txt-gray-sm u-mt-3"><%# Eval("BranchName") %></div>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
                <asp:Panel ID="pnlNoBank" runat="server" Visible="false" CssClass="u-no-data-alert">
                    <i class="fas fa-info-circle"></i> No active bank records detected.
                </asp:Panel>
            </div>

            <!-- Section: Saved Addresses -->
            <div class="u-sec-hdr"><i class="fas fa-map-marker-alt"></i> Delivery Nodes</div>
            <div class="u-data-cont">
                <asp:Repeater ID="rptAddress" runat="server">
                    <ItemTemplate>
                        <div class="u-row-item u-d-flex u-gap-18 u-align-start">
                            <div class="u-icon-w u-icon-w-home">
                                <i class="fas fa-home"></i>
                            </div>
                            <div>
                                <div class="u-d-flex u-gap-10 u-a-center">
                                    <span class="u-bold-800 u-color-dark u-txt-1rem"><%# Eval("Tag") %></span>
                                    <span class='badge u-badge-primary <%# Convert.ToBoolean(Eval("IsDefault")) ? "u-d-flex" : "u-d-none" %>'>PRIMARY</span>
                                </div>
                                <div class="u-txt-09 u-mt-8 u-text-slate-dark u-line-height-1-6">
                                    <strong class="u-color-dark"><%# Eval("FullName") %></strong> <span class="u-color-gray-500 u-separator">•</span> <%# Eval("PhoneNumber") %><br />
                                    <%# Eval("StreetAddress") %>, <%# Eval("City") %>, <%# Eval("State") %> - <strong><%# Eval("ZipCode") %></strong>
                                </div>
                            </div>
                        </div>
                    </ItemTemplate>
                </asp:Repeater>
                <asp:Panel ID="pnlNoAddr" runat="server" Visible="false" CssClass="u-no-data-alert">
                    <i class="fas fa-info-circle"></i> No delivery locations filed.
                </asp:Panel>
            </div>

        </div>
    </div>
</asp:Content>
