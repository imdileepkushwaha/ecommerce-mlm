<%@ Page Title="Reward Points" Language="C#" MasterPageFile="~/usersite.Master" AutoEventWireup="true" CodeFile="userRewards.aspx.cs" Inherits="ecommerce_mlm.userRewards" %>
<%@ Register Src="~/UserSidebar.ascx" TagPrefix="uc" TagName="UserSidebar" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <section class="dashboard-wrapper">
        <div class="dashboard-breadcrumb">
            <div class="container">
                <div class="dashboard-breadcrumb-inner">
                    <div class="breadcrumb-left"><h3>My Reward Wallet</h3></div>
                    <div class="breadcrumb-right">
                        <a href="index.aspx"><i class="fas fa-home"></i></a>
                        <span> / Rewards</span>
                    </div>
                </div>
            </div>
        </div>

        <div class="container">
            <div class="dashboard-layout">
                <uc:UserSidebar runat="server" ID="UserSidebar" />

                <main class="dashboard-main-content">
                    <div class="main-card main-card-padded" style="background:#f8fafc; border:none; box-shadow:none; padding:0;">

                        <!-- TOP METRICS DASHBOARD -->
                        <div class="rewards-stats-grid">
                            <div class="reward-master-card">
                                <div class="r-card-lbl">Total Redeemable Balance</div>
                                <div class="r-card-val">
                                    <i class="fas fa-coins" style="color:#fbbf24;"></i> 
                                    <asp:Label ID="lblTotalPoints" runat="server">0</asp:Label>
                                </div>
                                <div class="r-card-equiv">Equivalent to ₹ <asp:Label ID="lblCashValue" runat="server">0.00</asp:Label> in Cash</div>
                                <div style="font-size:0.7rem; opacity:0.6; margin-top:15px;">*1000 Points = ₹10</div>
                            </div>
                            
                            <div style="display:flex; flex-direction:column; gap:15px;">
                                <div class="reward-sub-card">
                                    <div class="r-sub-val" style="color:#d97706;">
                                        <asp:Label ID="lblPendingPoints" runat="server">0</asp:Label>
                                    </div>
                                    <div class="r-sub-lbl">Pending Clearance (Return Window)</div>
                                </div>
                                <div class="reward-sub-card">
                                    <div class="r-sub-val" style="color:#059669;">
                                        <asp:Label ID="lblTotalEarned" runat="server">0</asp:Label>
                                    </div>
                                    <div class="r-sub-lbl">Lifetime Lifetime Points Earned</div>
                                </div>
                            </div>
                        </div>

                        <!-- REWARDS TRANSACTION LOG -->
                        <div style="background:#ffffff; border-radius:20px; padding:25px; border:1px solid #eef2f6; box-shadow: 0 4px 20px rgba(0,0,0,0.02);">
                            
                            <div class="section-title section-title-bordered" style="margin-bottom:15px;">
                                <div><i class="fas fa-list-ul"></i> Transaction History</div>
                            </div>

                            <div class="table-responsive">
                                <asp:Repeater ID="rptRewards" runat="server">
                                    <HeaderTemplate>
                                        <table class="rewards-list-table">
                                            <thead>
                                                <tr>
                                                    <th>Reference</th>
                                                    <th>Date</th>
                                                    <th>Points Earned</th>
                                                    <th>Status</th>
                                                    <th>Expires In / Note</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                    </HeaderTemplate>
                                    <ItemTemplate>
                                        <tr class="rewards-row">
                                            <td>
                                                <div style="font-weight:700; color:#1e293b;">Order #<%# Eval("OrderId") %></div>
                                                <div style="font-size:0.75rem; color:#64748b;">Purchase Amount: ₹<%# Eval("OrderAmount") %></div>
                                            </td>
                                            <td style="font-size:0.85rem; color:#475569;">
                                                <%# Convert.ToDateTime(Eval("CreatedAt")).ToString("dd MMM yyyy") %>
                                            </td>
                                            <td>
                                                <span class='<%# GetPointBadgeClass(Eval("Status").ToString()) %>'>
                                                    <i class='<%# Eval("Status").ToString() == "CANCELLED" ? "fas fa-times-circle" : "fas fa-plus-circle" %>'></i>
                                                    <%# Eval("PointsEarned") %> Pts
                                                </span>
                                            </td>
                                            <td>
                                                <%# GetFriendlyStatus(Eval("Status").ToString()) %>
                                            </td>
                                            <td>
                                                <%# GetExpiryHtml(Eval("Status").ToString(), Eval("ExpiryDate")) %>
                                            </td>
                                        </tr>
                                    </ItemTemplate>
                                    <FooterTemplate>
                                            </tbody>
                                        </table>
                                    </FooterTemplate>
                                </asp:Repeater>

                                <asp:Panel ID="pnlNoRewards" runat="server" Visible="false" CssClass="empty-state-premium" style="margin-top: 20px;">
                                    <div class="empty-state-visual">
                                        <img src="assets/images/empty-orders.svg" style="width: 180px;" />
                                    </div>
                                    <h4 class="empty-state-heading">No Rewards Yet</h4>
                                    <p class="empty-state-sub">Shop now to earn cash points on every order. Start filling your wallet!</p>
                                </asp:Panel>
                            </div>
                        </div>

                    </div>
                </main>
            </div>
        </div>
    </section>
</asp:Content>
