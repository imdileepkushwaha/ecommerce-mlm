<%@ Page Title="Manage Payouts" Language="C#" MasterPageFile="~/admin/Admin.Master" AutoEventWireup="true"
    CodeFile="ManagePayouts.aspx.cs" Inherits="ecommerce_mlm.admin.ManagePayouts" %>

    <asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
        <style>
            .bank-badge {
                background: #f1f5f9;
                border-radius: 8px;
                padding: 10px 12px;
                font-size: 11.5px;
                border: 1px solid #e2e8f0;
                color: #475569;
                line-height: 1.4;
            }

            .bank-badge span {
                color: #1e293b;
                font-weight: 600;
            }

            .modal-overlay {
                position: fixed;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
                background: rgba(15, 23, 42, 0.6);
                backdrop-filter: blur(4px);
                display: flex;
                align-items: center;
                justify-content: center;
                z-index: 9999;
                opacity: 0;
                visibility: hidden;
                transition: all 0.3s ease;
            }

            .modal-overlay.show {
                opacity: 1;
                visibility: visible;
            }

            .action-modal {
                background: #fff;
                width: 400px;
                max-width: 90%;
                border-radius: 16px;
                padding: 24px;
                box-shadow: 0 20px 25px -5px rgba(0, 0, 0, 0.1), 0 10px 10px -5px rgba(0, 0, 0, 0.04);
                transform: scale(0.9);
                transition: transform 0.3s ease;
            }

            .modal-overlay.show .action-modal {
                transform: scale(1);
            }

            .modal-title {
                font-size: 18px;
                font-weight: 700;
                color: #0f172a;
                margin-bottom: 8px;
            }

            .modal-desc {
                font-size: 13px;
                color: #888888;
                margin-bottom: 20px;
            }

            .tab-btn {
                background: transparent;
                color: #64748b;
                transition: all 0.2s ease;
            }
            .tab-btn:hover {
                color: #0ea5e9;
            }
            .tab-btn.active {
                background: #f1f5f9;
                color: #0ea5e9;
            }
            body.dark-theme .tab-btn.active {
                background: #1e1e24;
                color: #38bdf8;
            }

            .action-matrix-btn {
                display: inline-flex;
                align-items: center;
                justify-content: center;
                width: 32px;
                height: 32px;
                border-radius: 10px;
                border: 1px solid transparent;
                font-size: 13px;
                cursor: pointer;
                transition: all 0.2s cubic-bezier(0.4, 0, 0.2, 1);
                text-decoration: none;
            }

            .action-btn-paid {
                background: #e6fcf5;
                color: #0ca678;
                border-color: #c3fae8;
            }

            .action-btn-paid:hover {
                background: #0ca678;
                color: #ffffff;
                border-color: #0ca678;
                transform: translateY(-2px);
                box-shadow: 0 4px 12px rgba(12, 166, 120, 0.25);
            }

            .action-btn-reject {
                background: #fff5f5;
                color: #e03131;
                border-color: #ffe3e3;
            }

            .action-btn-reject:hover {
                background: #e03131;
                color: #ffffff;
                border-color: #e03131;
                transform: translateY(-2px);
                box-shadow: 0 4px 12px rgba(224, 49, 49, 0.25);
            }

            body.dark-theme .action-btn-paid {
                background: rgba(12, 166, 120, 0.1) !important;
                color: #20c997 !important;
                border-color: rgba(12, 166, 120, 0.2) !important;
            }
            body.dark-theme .action-btn-paid:hover {
                background: #0ca678 !important;
                color: #ffffff !important;
                border-color: #0ca678 !important;
            }

            body.dark-theme .action-btn-reject {
                background: rgba(224, 49, 49, 0.1) !important;
                color: #ff6b6b !important;
                border-color: rgba(224, 49, 49, 0.2) !important;
            }
            body.dark-theme .action-btn-reject:hover {
                background: #e03131 !important;
                color: #ffffff !important;
                border-color: #e03131 !important;
            }

            /* Premium Modal Redesign */
            .action-modal {
                background: #ffffff;
                width: 440px;
                max-width: 95%;
                border-radius: 20px;
                padding: 28px;
                box-shadow: 0 25px 50px -12px rgba(15, 23, 42, 0.15), 0 0 0 1px rgba(15, 23, 42, 0.05);
                transform: scale(0.95);
                transition: all 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
            }

            body.dark-theme .action-modal {
                background: #18181b !important;
                box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.5), 0 0 0 1px rgba(255, 255, 255, 0.05) !important;
            }

            .modal-header-badge {
                width: 56px;
                height: 56px;
                border-radius: 14px;
                display: flex;
                align-items: center;
                justify-content: center;
                font-size: 24px;
                margin-bottom: 20px;
            }

            .badge-emerald {
                background: #ecfdf5;
                color: #10b981;
            }

            body.dark-theme .badge-emerald {
                background: rgba(16, 185, 129, 0.1);
            }

            .badge-rose {
                background: #fff1f2;
                color: #f43f5e;
            }

            body.dark-theme .badge-rose {
                background: rgba(244, 63, 94, 0.1);
            }

            .modal-title {
                font-size: 20px;
                font-weight: 800;
                color: #0f172a;
                margin-bottom: 8px;
                display: flex;
                align-items: center;
                gap: 8px;
            }

            body.dark-theme .modal-title {
                color: #f8fafc;
            }

            .modal-desc {
                font-size: 13.5px;
                color: #64748b;
                line-height: 1.5;
                margin-bottom: 24px;
            }

            body.dark-theme .modal-desc {
                color: #94a3b8;
            }

            .modal-form-label {
                display: block;
                font-size: 12.5px;
                font-weight: 700;
                color: #475569;
                text-transform: uppercase;
                letter-spacing: 0.5px;
                margin-bottom: 8px;
            }

            body.dark-theme .modal-form-label {
                color: #cbd5e1;
            }

            .modal-textbox {
                width: 100%;
                padding: 12px 16px;
                font-size: 14px;
                font-weight: 500;
                color: #0f172a;
                background: #ffffff;
                border: 1.5px solid #e2e8f0;
                border-radius: 12px;
                outline: none;
                transition: all 0.2s ease;
            }

            .modal-textbox:focus {
                border-color: #0ea5e9;
                box-shadow: 0 0 0 4px rgba(14, 165, 233, 0.1);
            }

            body.dark-theme .modal-textbox {
                background: #27272a;
                border-color: rgba(255, 255, 255, 0.08);
                color: #f8fafc;
            }

            body.dark-theme .modal-textbox:focus {
                border-color: #38bdf8;
                box-shadow: 0 0 0 4px rgba(56, 189, 248, 0.1);
            }

            /* Custom Modal Footer Buttons */
            .modal-btn-cancel {
                display: inline-flex;
                align-items: center;
                justify-content: center;
                padding: 12px 20px;
                border-radius: 12px;
                font-size: 13.5px;
                font-weight: 700;
                background: #f8fafc;
                border: 1.5px solid #e2e8f0;
                color: #64748b;
                cursor: pointer;
                transition: all 0.2s ease;
                text-decoration: none;
            }

            .modal-btn-cancel:hover {
                background: #f1f5f9;
                color: #475569;
                border-color: #cbd5e1;
            }

            body.dark-theme .modal-btn-cancel {
                background: #27272a;
                border-color: rgba(255, 255, 255, 0.08);
                color: #cbd5e1;
            }

            body.dark-theme .modal-btn-cancel:hover {
                background: #3f3f46;
                color: #f8fafc;
            }

            .modal-btn-submit-emerald {
                display: inline-flex;
                align-items: center;
                justify-content: center;
                padding: 12px 20px;
                border-radius: 12px;
                font-size: 13.5px;
                font-weight: 700;
                background: #10b981;
                border: 1.5px solid #10b981;
                color: #ffffff;
                cursor: pointer;
                transition: all 0.2s ease;
                box-shadow: 0 4px 12px rgba(16, 185, 129, 0.15);
            }

            .modal-btn-submit-emerald:hover {
                background: #059669;
                border-color: #059669;
                transform: translateY(-1px);
                box-shadow: 0 6px 16px rgba(16, 185, 129, 0.25);
            }

            .modal-btn-submit-rose {
                display: inline-flex;
                align-items: center;
                justify-content: center;
                padding: 12px 20px;
                border-radius: 12px;
                font-size: 13.5px;
                font-weight: 700;
                background: #f43f5e;
                border: 1.5px solid #f43f5e;
                color: #ffffff;
                cursor: pointer;
                transition: all 0.2s ease;
                box-shadow: 0 4px 12px rgba(244, 63, 94, 0.15);
            }

            .modal-btn-submit-rose:hover {
                background: #e11d48;
                border-color: #e11d48;
                transform: translateY(-1px);
                box-shadow: 0 6px 16px rgba(244, 63, 94, 0.25);
            }

            /* Premium Status Pill Badges */
            .badge-status {
                display: inline-flex;
                align-items: center;
                gap: 5px;
                padding: 6px 12px;
                border-radius: 20px;
                font-size: 11px;
                font-weight: 700;
                text-transform: uppercase;
                letter-spacing: 0.5px;
                border: 1px solid transparent;
            }

            .badge-status i {
                font-size: 11.5px;
            }

            .badge-status.badge-warning {
                background: #fffbeb;
                color: #d97706;
                border-color: #fef3c7;
            }

            body.dark-theme .badge-status.badge-warning {
                background: rgba(217, 119, 6, 0.1) !important;
                color: #fbbf24 !important;
                border-color: rgba(217, 119, 6, 0.2) !important;
            }

            .badge-status.badge-success {
                background: #f0fdf4;
                color: #16a34a;
                border-color: #dcfce7;
            }

            body.dark-theme .badge-status.badge-success {
                background: rgba(22, 163, 74, 0.1) !important;
                color: #4ade80 !important;
                border-color: rgba(22, 163, 74, 0.2) !important;
            }

            .badge-status.badge-danger {
                background: #fef2f2;
                color: #dc2626;
                border-color: #fee2e2;
            }

            body.dark-theme .badge-status.badge-danger {
                background: rgba(220, 38, 38, 0.1) !important;
                color: #f87171 !important;
                border-color: rgba(220, 38, 38, 0.2) !important;
            }

            /* Premium Bank Coordinate Cards */
            .bank-badge {
                background: #f8fafc;
                border: 1px solid #e2e8f0;
                border-left: 3.5px solid #0ea5e9;
                border-radius: 12px;
                padding: 12px 14px;
                font-size: 12px;
                color: #64748b;
                line-height: 1.6;
                box-shadow: 0 2px 4px rgba(0, 0, 0, 0.02);
                transition: all 0.2s ease;
                display: block;
                max-width: 260px;
            }

            .bank-badge:hover {
                transform: translateX(2px);
                border-color: #cbd5e1;
                background: #ffffff;
            }

            body.dark-theme .bank-badge {
                background: #18181b !important;
                border-color: rgba(255, 255, 255, 0.06) !important;
                border-left-color: #38bdf8 !important;
                color: #a1a1aa !important;
            }

            body.dark-theme .bank-badge:hover {
                background: #202024 !important;
            }

            .bank-badge span {
                color: #0f172a;
                font-weight: 700;
            }

            body.dark-theme .bank-badge span {
                color: #f4f4f5;
            }

            .bank-badge .bank-meta-label {
                font-size: 10.5px;
                font-weight: 700;
                color: #94a3b8;
                text-transform: uppercase;
                letter-spacing: 0.3px;
                margin-right: 4px;
                display: inline-block;
            }

            body.dark-theme .bank-badge .bank-meta-label {
                color: #71717a;
            }
        </style>
    </asp:Content>

    <asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

        <!-- Persists Selected Payout between UI events -->
        <asp:HiddenField ID="hfSelectedPayoutId" runat="server" ClientIDMode="Static" />
        <asp:HiddenField ID="hfActiveTab" runat="server" Value="MEMBER" ClientIDMode="Static" />

        <div class="u-mb-30 u-d-flex u-j-between u-a-center">
            <div>
                <h1 class="u-txt-lg">Withdrawal Settlements</h1>
                <p class="u-txt-subtitle u-mt-5">Audit payout requests, process bank payouts, and record transactional UTR vectors.</p>
            </div>
        </div>

        <asp:Panel ID="pnlMsg" runat="server" Visible="false"
            style="border-radius: 12px; font-weight:600; padding: 12px 20px;">
            <asp:Label ID="lblMsg" runat="server"></asp:Label>
        </asp:Panel>

        <!-- FILTER & TAB NAVIGATION BLOCK -->
        <div class="table-card u-mb-20" style="padding: 10px 20px; border-radius: 12px; display: flex; align-items: center; justify-content: space-between; flex-wrap: wrap; gap: 15px;">
            <div style="display: flex; gap: 8px;">
                <asp:LinkButton ID="btnTabMember" runat="server" CssClass="tab-btn active" OnClick="btnTabMember_Click" style="padding: 8px 16px; border-radius: 8px; font-weight: 700; font-size: 13.5px; border: none; cursor: pointer; text-decoration: none; display: inline-flex; align-items: center; gap: 6px;">
                    <i class="fas fa-users"></i> Member Payouts
                </asp:LinkButton>
                <asp:LinkButton ID="btnTabSeller" runat="server" CssClass="tab-btn" OnClick="btnTabSeller_Click" style="padding: 8px 16px; border-radius: 8px; font-weight: 700; font-size: 13.5px; border: none; cursor: pointer; text-decoration: none; display: inline-flex; align-items: center; gap: 6px;">
                    <i class="fas fa-store"></i> Seller Payouts
                </asp:LinkButton>
            </div>
            
            <div class="u-d-flex u-a-center u-gap-10">
                <div style="font-weight: 600; color: #475569; font-size: 13px;"><i class="fas fa-filter u-mr-5"></i> Filter by Status:</div>
                <asp:DropDownList ID="ddlStatusFilter" runat="server" AutoPostBack="true"
                    OnSelectedIndexChanged="ddlStatusFilter_SelectedIndexChanged" CssClass="u-input-field"
                    style="width: 160px; margin: 0; padding: 6px 12px; font-size: 12.5px;">
                    <asp:ListItem Value="ALL">All Requests</asp:ListItem>
                    <asp:ListItem Value="PENDING">Pending Audit</asp:ListItem>
                    <asp:ListItem Value="PAID">Successfully Settled</asp:ListItem>
                    <asp:ListItem Value="REJECTED">Rejected Requests</asp:ListItem>
                </asp:DropDownList>
            </div>
        </div>

        <!-- DATA GRID VIEW -->
        <div class="table-card" style="overflow-x: auto;">
            <asp:GridView ID="gvPayouts" runat="server" AutoGenerateColumns="false" CssClass="admin-table"
                GridLines="None" OnRowCommand="gvPayouts_RowCommand">
                <EmptyDataTemplate>
                    <div
                        style="text-align: center; padding: 60px 20px; background: #f8fafc; border-radius: 16px; margin: 15px; display: flex; flex-direction: column; align-items: center; justify-content: center;">
                        <div
                            style="width: 80px; height: 80px; border-radius: 50%; background: #e0f2fe; display: flex; align-items: center; justify-content: center; margin-bottom: 20px; border: 4px solid #f0f9ff; box-shadow: 0 0 0 8px #f8fafc;">
                            <i class="fas fa-receipt" style="font-size: 32px; color: #0ea5e9;"></i>
                        </div>
                        <h3 style="color: #1e293b; font-weight: 800; font-size: 18px; margin-bottom: 8px;">No Settlement
                            Logs Available</h3>
                        <p
                            style="color:#888888; font-size: 13.5px; max-width: 350px; margin: 0 auto 20px; line-height: 1.5;">
                            Your financial ledger is completely clear! Currently, there are no payout requests matching
                            your active filter.
                        </p>
                        <span
                            style="background: #dcfce7; color: #15803d; font-size: 11px; font-weight: 800; padding: 6px 16px; border-radius: 30px; text-transform: uppercase; letter-spacing: 0.5px; border: 1px solid #bbf7d0; display: inline-flex; align-items:center; gap:5px;">
                            <i class="fas fa-check-circle"></i> Ledger Balanced
                        </span>
                    </div>
                </EmptyDataTemplate>
                <Columns>

                    <asp:TemplateField HeaderText="Request ID">
                        <ItemTemplate>
                            <div style="font-weight:700; color:#0f172a;">#PAY-<%# Eval("Id") %>
                            </div>
                            <div style="font-size: 11px; color:#64748b; margin-top:2px;">
                                <%# Eval("CreatedAt", "{0:dd MMM yyyy}" ) %>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Member Information">
                        <ItemTemplate>
                            <div style="font-weight:600; color:#0ea5e9;">
                                <%# Eval("FullName") %>
                            </div>
                            <div style="font-size: 12px; font-weight: 700; color:#475569; margin-top:2px;">👤 <%#
                                    Eval("Username") %>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Financial Breakdown">
                        <ItemTemplate>
                            <div style="font-size:12px; color:#64748b;">Gross: ₹<%# Eval("RequestAmount", "{0:N2}" ) %>
                            </div>
                            <div style="font-size:12px; color:#ef4444; margin-top:2px;">Tax/Fee: ₹<%#
                                    Convert.ToDecimal(Eval("TdsDeduction")) + Convert.ToDecimal(Eval("AdminCharges")) %>
                            </div>
                            <div style="font-size:13.5px; font-weight:700; color:#10b981; margin-top:4px;">Net: ₹<%#
                                    Eval("NetPayable", "{0:N2}" ) %>
                            </div>
                        </ItemTemplate>
                    </asp:TemplateField>

                    <asp:TemplateField HeaderText="Beneficiary Bank Coordinates">
                        <ItemTemplate>
                            <%# Eval("AccountNumber")==DBNull.Value
                                ? "<div style='color:#94a3b8; font-style:italic; font-size:12px;'>No bank registered</div>"
                                : @" <div class='bank-badge'>
                                <div style='margin-bottom: 4px; font-weight: 800; color: #0ea5e9;'><i class='fas fa-university' style='margin-right: 5px;'></i> <span>" + Eval("BankName") + @"</span></div>
                                <div><span class='bank-meta-label'>A/C:</span><span>" + Eval("AccountNumber") + @"</span></div>
                                <div><span class='bank-meta-label'>IFSC:</span><span>" + Eval("IFSCCode") + @"</span></div>
                                <div><span class='bank-meta-label'>Holder:</span><span>" + Eval("AccountHolderName") + @"</span></div>
         </div>
         " %>
        </ItemTemplate>
        </asp:TemplateField>

        <asp:TemplateField HeaderText="Settle State">
            <ItemTemplate>
                <%# Eval("Status").ToString()=="PENDING"
                    ? "<span class='badge-status badge-warning'><i class='fas fa-hourglass-half'></i> PENDING</span>" :
                    Eval("Status").ToString()=="PAID"
                    ? "<span class='badge-status badge-success'><i class='fas fa-check-circle'></i> PAID</span>"
                    : "<span class='badge-status badge-danger'><i class='fas fa-times-circle'></i> REJECTED</span>" %>
                    <%# Eval("TransactionId") !=DBNull.Value && !string.IsNullOrEmpty(Eval("TransactionId").ToString())
                        ? "<div style='font-size:10.5px; font-weight:700; color:#475569; margin-top:5px; border-top:1px dashed #cbd5e1; padding-top:4px;'>UTR: "
                        + Eval("TransactionId") + "</div>" : "" %>
            </ItemTemplate>
        </asp:TemplateField>

        <asp:TemplateField HeaderText="Action Matrix">
            <ItemTemplate>
                <div class="u-d-flex u-gap-5" style="display: <%# Eval(" Status").ToString()=="PENDING" ? "flex"
                    : "none" %>;">
                    <asp:LinkButton ID="lnkPaid" runat="server" CommandName="PaidTrigger"
                        CommandArgument='<%# Eval("Id") %>' CssClass="action-matrix-btn action-btn-paid" ToolTip="Mark Settled/Paid">
                        <i class="fas fa-check"></i>
                    </asp:LinkButton>
                    <asp:LinkButton ID="lnkReject" runat="server" CommandName="RejectTrigger"
                        CommandArgument='<%# Eval("Id") %>' CssClass="action-matrix-btn action-btn-reject" ToolTip="Reject Withdrawal">
                        <i class="fas fa-times"></i>
                    </asp:LinkButton>
                </div>
                <div style="font-size: 12px; color: #94a3b8; font-style: italic; display: <%# Eval(" Status").ToString()
                    !="PENDING" ? "block" : "none" %>;">
                    Processed
                </div>
            </ItemTemplate>
        </asp:TemplateField>

        </Columns>
        </asp:GridView>
        </div>

        <!-- MODAL 1: CONFIRM PAID (TRANSACTION ID) -->
        <div class="modal-overlay" id="modal-paid">
            <div class="action-modal">
                <div class="modal-header-badge badge-emerald">
                    <i class="fas fa-money-bill-wave"></i>
                </div>
                <div class="modal-title">Log Bank Settlement</div>
                <p class="modal-desc">Please input the transactional Reference/UTR Number issued by your banking partner to finalize this settlement ledger.</p>

                <div class="form-grp u-mb-20">
                    <label class="modal-form-label">Bank Reference / UTR Transaction ID</label>
                    <asp:TextBox ID="txtTxnId" runat="server" placeholder="e.g., UTR928374822" CssClass="modal-textbox">
                    </asp:TextBox>
                </div>

                <div class="u-d-flex u-gap-10">
                    <button type="button" class="modal-btn-cancel" onclick="closeActionModal()" style="flex:1;">Cancel</button>
                    <asp:Button ID="btnConfirmPaid" runat="server" Text="Release Payout" CssClass="modal-btn-submit-emerald"
                        OnClick="btnConfirmPaid_Click" style="flex:1.5;" />
                </div>
            </div>
        </div>

        <!-- MODAL 2: CONFIRM REJECTION -->
        <div class="modal-overlay" id="modal-reject">
            <div class="action-modal">
                <div class="modal-header-badge badge-rose">
                    <i class="fas fa-ban"></i>
                </div>
                <div class="modal-title">Deny Payout Request</div>
                <p class="modal-desc">Specify the vector or reason explaining the audit rejection. This explanation is transmitted to the user's core dashboard.</p>

                <div class="form-grp u-mb-20">
                    <label class="modal-form-label">Reason for Audit Rejection</label>
                    <asp:TextBox ID="txtReason" runat="server" TextMode="MultiLine" Rows="3"
                        placeholder="e.g., Invalid IFSC code provided." CssClass="modal-textbox"
                        style="height: auto !important; resize: none;"></asp:TextBox>
                </div>

                <div class="u-d-flex u-gap-10">
                    <button type="button" class="modal-btn-cancel" onclick="closeActionModal()" style="flex:1;">Cancel</button>
                    <asp:Button ID="btnConfirmReject" runat="server" Text="Deny Request" CssClass="modal-btn-submit-rose"
                        OnClick="btnConfirmReject_Click" style="flex:1.5;" />
                </div>
            </div>
        </div>

        <script type="text/javascript">
            function openActionModal(type) {
                closeActionModal(); // close existing first
                if (type === 'paid') {
                    document.getElementById('modal-paid').classList.add('show');
                } else {
                    document.getElementById('modal-reject').classList.add('show');
                }
            }

            function closeActionModal() {
                document.querySelectorAll('.modal-overlay').forEach(function (el) {
                    el.classList.remove('show');
                });
            }
        </script>

    </asp:Content>