<%@ Page Title="My Income" Language="C#" MasterPageFile="~/usersite.Master" AutoEventWireup="true" CodeFile="userIncome.aspx.cs" Inherits="ecommerce_mlm.userIncome" %>
<%@ Register Src="~/UserSidebar.ascx" TagPrefix="uc" TagName="UserSidebar" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <section class="dashboard-wrapper">
        <div class="dashboard-breadcrumb">
            <div class="container">
                <div class="dashboard-breadcrumb-inner">
                    <div class="breadcrumb-left"><h3>Earnings & Income</h3></div>
                    <div class="breadcrumb-right">
                        <a href="index.aspx"><i class="fas fa-home"></i></a>
                        <span> / Income</span>
                    </div>
                </div>
            </div>
        </div>

        <div class="container">
            <div class="dashboard-layout">
                <uc:UserSidebar runat="server" ID="UserSidebar" />

                <main class="dashboard-main-content">
                    
                    <!-- MASTER BANNER (COMPACT SPLIT) -->
                    <div class="income-summary-banner">
                        <div>
                            <div class="inc-lbl">Total Wallet Income</div>
                            <div style="font-size:0.75rem; opacity:0.85; display:flex; align-items:center; gap:6px; margin-top:4px;">
                                <i class="fas fa-info-circle"></i> Cumulative Lifetime Earnings
                            </div>
                        </div>
                        <div class="inc-val">₹ <asp:Label ID="lblTotalEarnings" runat="server">0.00</asp:Label></div>
                    </div>

                    <!-- STAT CARDS ROW -->
                    <div class="inc-stats-row">
                        <div class="inc-stat-card">
                            <div class="inc-icon-box box-orange"><i class="fas fa-hourglass-half"></i></div>
                            <div>
                                <div class="inc-meta-val">₹ <asp:Label ID="lblPendingAmt" runat="server">0.00</asp:Label></div>
                                <div class="inc-meta-lbl">Pending Verification</div>
                            </div>
                        </div>
                        <div class="inc-stat-card">
                            <div class="inc-icon-box box-green"><i class="fas fa-check-circle"></i></div>
                            <div>
                                <div class="inc-meta-val">₹ <asp:Label ID="lblApprovedAmt" runat="server">0.00</asp:Label></div>
                                <div class="inc-meta-lbl">Available to Withdraw</div>
                            </div>
                        </div>
                        <div class="inc-stat-card">
                            <div class="inc-icon-box box-blue"><i class="fas fa-money-bill-wave"></i></div>
                            <div>
                                <div class="inc-meta-val">₹ <asp:Label ID="lblPaidAmt" runat="server">0.00</asp:Label></div>
                                <div class="inc-meta-lbl">Already Payouts</div>
                            </div>
                        </div>
                    </div>

                    <!-- DETAILED LOGS -->
                    <div class="main-card main-card-padded">
                        <div class="section-title section-title-bordered" style="margin-bottom:20px;">
                            <div><i class="fas fa-exchange-alt"></i> Statement History</div>
                        </div>

                        <div class="table-responsive">
                            <asp:Repeater ID="rptIncome" runat="server">
                                <HeaderTemplate>
                                    <table class="table-custom-compact">
                                        <thead>
                                            <tr>
                                                <th>Date</th>
                                                <th>Refereed From</th>
                                                <th>Reference</th>
                                                <th>Commission</th>
                                                <th>Amount</th>
                                                <th>Status</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                </HeaderTemplate>
                                <ItemTemplate>
                                    <tr>
                                        <td style="color:#64748b; font-weight:600;"><%# Convert.ToDateTime(Eval("CreatedAt")).ToString("dd MMM yyyy") %></td>
                                        <td>
                                            <div style="font-weight:700; color:#1e293b;"><%# Eval("RefName") %></div>
                                            <div style="font-size:0.75rem; color:#94a3b8;">ID: <%# Eval("RefUser") %></div>
                                        </td>
                                        <td>
                                            <span style="color:#475569;">Order #<%# Eval("OrderId") %></span>
                                        </td>
                                        <td>
                                            <span style="background:#f1f5f9; padding:3px 8px; border-radius:4px; font-weight:700;"><%# Eval("CommissionPct") %>%</span>
                                        </td>
                                        <td style="color:#059669; font-weight:800; font-size:1rem;">
                                            ₹<%# Eval("IncomeAmount") %>
                                        </td>
                                        <td>
                                            <span class='<%# GetStatusClass(Eval("Status").ToString()) %>'>
                                                <%# Eval("Status") %>
                                            </span>
                                        </td>
                                    </tr>
                                </ItemTemplate>
                                <FooterTemplate>
                                        </tbody>
                                    </table>
                                </FooterTemplate>
                            </asp:Repeater>

                            <!-- EMPTY STATE IF NO TRANSACTIONS -->
                            <asp:Panel ID="pnlNoIncome" runat="server" Visible="false" CssClass="empty-state-premium">
                                <div class="empty-state-visual">
                                    <img src="assets/images/empty-income.svg" alt="No Income Earned" />
                                </div>
                                <h4 class="empty-state-heading">Your Income Wallet is Empty</h4>
                                <p class="empty-state-sub">Invite friends and family to join using your sponsor link and start earning lifetime rewards instantly!</p>
                            </asp:Panel>
                        </div>
                    </div>

                </main>
            </div>
        </div>
    </section>
</asp:Content>
