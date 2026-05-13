<%@ Page Title="Account Deletion Protocols" Language="C#" MasterPageFile="~/admin/Admin.Master" AutoEventWireup="true"
    CodeFile="AccountDeletions.aspx.cs" Inherits="ecommerce_mlm.admin.AccountDeletions" %>

    <asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
        <style>
            .u-notice-banner {
                background: #fffbeb;
                border: 1px solid #fef3c7;
                border-left: 4px solid #f59e0b;
                padding: 15px 20px;
                border-radius: 8px;
                display: flex;
                align-items: center;
                gap: 15px;
                color: #92400e;
                margin-bottom: 25px;
            }

            .u-notice-banner i {
                font-size: 1.2rem;
                color: #d97706;
            }
        </style>
    </asp:Content>

    <asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
        <div class="u-mb-30">
            <h1 class="u-txt-lg">Account Termination</h1>
            <p class="u-txt-subtitle u-mt-5">Evaluate and authorize requests for persistent account deletion protocols.
            </p>
        </div>

        <div class="u-notice-banner">
            <i class="fas fa-exclamation-triangle"></i>
            <div>
                <strong>Strict Data Governance Active:</strong>
                Deleting accounts creates permanent systemic voids. Audit records thoroughly prior to authorization.
            </div>
        </div>

        <!-- ==================== USERS TABLE ==================== -->
        <div class="u-mb-20 u-d-flex u-j-between u-a-center">
            <h2 class="u-page-title">
                <i class="fas fa-users u-mr-5"></i> User Terminal Requests
            </h2>
            <span class="badge badge-danger">Active: <asp:Label ID="lblUserCount" runat="server">0</asp:Label></span>
        </div>

        <div class="table-card u-mb-30">
            <div class="table-responsive">
                <asp:Repeater ID="rptUsers" runat="server" OnItemCommand="rptAction_ItemCommand">
                    <HeaderTemplate>
                        <table class="admin-table">
                            <thead>
                                <tr>
                                    <th>Request # / Date</th>
                                    <th>User Profile</th>
                                    <th>Current Status</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                    </HeaderTemplate>
                    <ItemTemplate>
                        <tr>
                            <td>
                                <span class="u-order-id">#<%# Eval("Id") %></span>
                                <div class="u-datetime-stack">
                                    <div class="u-d-main"><i class="far fa-calendar-alt"></i>
                                        <%# Convert.ToDateTime(Eval("RequestDate")).ToString("dd MMM, yyyy") %>
                                    </div>
                                </div>
                            </td>
                            <td>
                                <div class="u-bold-700 u-color-dark">
                                    <%# Eval("FullName") %>
                                </div>
                                <div class="u-txt-gray-sm">
                                    <%# Eval("Email") %>
                                </div>
                            </td>
                            <td>
                                <span class="badge badge-pending">
                                    <%# Eval("Status") %>
                                </span>
                            </td>
                            <td>
                                <div class="u-d-flex u-gap-8">
                                    <!-- Approve/Delete Action -->
                                    <asp:LinkButton runat="server" CommandName="ApproveRequest"
                                        CommandArgument='<%# Eval("Id") + "|User" %>'
                                        CssClass="action-btn-circle action-btn-block"
                                        ToolTip="Authorize Permanent Deletion"
                                        OnClientClick="return confirm('Irrevocable Warning: Authorize permanent account terminal sequence?');">
                                        <i class="fas fa-trash-alt"></i>
                                    </asp:LinkButton>

                                    <!-- Reject/Keep Action -->
                                    <asp:LinkButton runat="server" CommandName="RejectRequest"
                                        CommandArgument='<%# Eval("Id") + "|User" %>'
                                        CssClass="action-btn-circle action-btn-unblock"
                                        ToolTip="Reject Request & Reinstate Account">
                                        <i class="fas fa-undo-alt"></i>
                                    </asp:LinkButton>
                                </div>
                            </td>
                        </tr>
                    </ItemTemplate>
                    <FooterTemplate>
                        </tbody>
                        </table>
                    </FooterTemplate>
                </asp:Repeater>
                <asp:Panel ID="pnlUsersEmpty" runat="server" CssClass="u-empty-state">
                    <i class="fas fa-check-circle u-empty-icon" style="color:#10b981;"></i>
                    <h4>No active consumer termination requests pending review.</h4>
                </asp:Panel>
            </div>
        </div>

        <div style="height:30px;"></div>

        <!-- ==================== SELLERS TABLE ==================== -->
        <div class="u-mb-20 u-d-flex u-j-between u-a-center">
            <h2 class="u-page-title">
                <i class="fas fa-store u-mr-5"></i> Merchant Terminal Requests
            </h2>
            <span class="badge badge-danger">Active: <asp:Label ID="lblSellerCount" runat="server">0</asp:Label></span>
        </div>

        <div class="table-card">
            <div class="table-responsive">
                <asp:Repeater ID="rptSellers" runat="server" OnItemCommand="rptAction_ItemCommand">
                    <HeaderTemplate>
                        <table class="admin-table">
                            <thead>
                                <tr>
                                    <th>Seller # / Date</th>
                                    <th>Business Profile</th>
                                    <th>System State</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                    </HeaderTemplate>
                    <ItemTemplate>
                        <tr>
                            <td>
                                <span class="u-order-id">#<%# Eval("Id") %></span>
                                <div class="u-datetime-stack">
                                    <div class="u-d-main"><i class="far fa-calendar-alt"></i>
                                        <%# Eval("DeactivationDate") !=DBNull.Value ?
                                            Convert.ToDateTime(Eval("DeactivationDate")).ToString("dd MMM, yyyy")
                                            : "N/A" %>
                                    </div>
                                </div>
                            </td>
                            <td>
                                <div class="u-bold-700 u-color-dark">
                                    <%# Eval("FullName") %>
                                </div>
                                <div class="u-txt-gray-sm">
                                    <%# Eval("Email") %>
                                </div>
                            </td>
                            <td>
                                <span class="badge badge-pending">
                                    <%# Eval("DeletionStatus") %>
                                </span>
                            </td>
                            <td>
                                <div class="u-d-flex u-gap-8">
                                    <!-- Approve/Delete Action -->
                                    <asp:LinkButton runat="server" CommandName="ApproveRequest"
                                        CommandArgument='<%# Eval("Id") + "|Seller" %>'
                                        CssClass="action-btn-circle action-btn-block"
                                        ToolTip="Authorize Permanent Deletion"
                                        OnClientClick="return confirm('Irrevocable Warning: Authorize permanent merchant termination sequence?');">
                                        <i class="fas fa-trash-alt"></i>
                                    </asp:LinkButton>

                                    <!-- Reject/Keep Action -->
                                    <asp:LinkButton runat="server" CommandName="RejectRequest"
                                        CommandArgument='<%# Eval("Id") + "|Seller" %>'
                                        CssClass="action-btn-circle action-btn-unblock"
                                        ToolTip="Reject Request & Reinstate Merchant">
                                        <i class="fas fa-undo-alt"></i>
                                    </asp:LinkButton>
                                </div>
                            </td>
                        </tr>
                    </ItemTemplate>
                    <FooterTemplate>
                        </tbody>
                        </table>
                    </FooterTemplate>
                </asp:Repeater>
                <asp:Panel ID="pnlSellersEmpty" runat="server" CssClass="u-empty-state">
                    <i class="fas fa-check-circle u-empty-icon" style="color:#10b981;"></i>
                    <h4>No active merchant termination requests pending review.</h4>
                </asp:Panel>
            </div>
        </div>
        <div style="height:40px;"></div>

        <!-- ==================== RESOLUTION HISTORY ==================== -->
        <div class="u-mb-20 u-d-flex u-a-center">
            <h2 class="u-page-title">
                <i class="fas fa-history u-mr-5" style="color:#94a3b8;"></i> Audit & Resolution History
            </h2>
        </div>

        <div class="table-card" style="opacity: 0.95;">
            <div class="table-responsive">
                <asp:Repeater ID="rptHistory" runat="server">
                    <HeaderTemplate>
                        <table class="admin-table">
                            <thead style="background:#f1f5f9;">
                                <tr>
                                    <th>Type</th>
                                    <th>Profile Reference</th>
                                    <th>Event Triggered</th>
                                    <th>Resolution State</th>
                                </tr>
                            </thead>
                            <tbody>
                    </HeaderTemplate>
                    <ItemTemplate>
                        <tr>
                            <td>
                                <span class='badge <%# Eval("EType").ToString() == "User" ? "badge-info" : "badge-warning" %>'>
                                    <i class='fas <%# Eval("EType").ToString() == "User" ? "fa-user" : "fa-store" %> u-mr-5'></i>
                                    <%# Eval("EType") %>
                                </span>
                            </td>
                            <td>
                                <div class="u-bold-700 u-color-dark"><%# Eval("FullName") %></div>
                                <div class="u-txt-gray-sm"><%# Eval("Email") %></div>
                            </td>
                            <td>
                                <div class="u-datetime-stack">
                                    <div class="u-d-main"><i class="far fa-clock"></i> <%# Convert.ToDateTime(Eval("EDate")).ToString("dd MMM, yyyy") %></div>
                                </div>
                            </td>
                            <td>
                                <span class='badge <%# GetHistStatusClass(Eval("EStatus")) %>'>
                                    <%# Eval("EStatus") %>
                                </span>
                            </td>
                        </tr>
                    </ItemTemplate>
                    <FooterTemplate>
                        </tbody>
                        </table>
                    </FooterTemplate>
                </asp:Repeater>
                <asp:Panel ID="pnlHistEmpty" runat="server" CssClass="u-empty-state">
                    <i class="fas fa-folder-open u-empty-icon" style="color:#cbd5e1;"></i>
                    <h4>Historical archives are currently empty.</h4>
                </asp:Panel>
            </div>
        </div>
    </asp:Content>