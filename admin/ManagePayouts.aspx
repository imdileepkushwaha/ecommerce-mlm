<%@ Page Title="Manage Payouts" Language="C#" MasterPageFile="~/admin/Admin.Master" AutoEventWireup="true" CodeFile="ManagePayouts.aspx.cs" Inherits="ecommerce_mlm.admin.ManagePayouts" %>

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
            top: 0; left: 0; width: 100%; height: 100%;
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
            color: #64748b;
            margin-bottom: 20px;
        }
    </style>
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    
    <!-- Persists Selected Payout between UI events -->
    <asp:HiddenField ID="hfSelectedPayoutId" runat="server" ClientIDMode="Static" />

    <div class="u-mb-30 u-d-flex u-j-between u-a-center">
        <div>
            <h1 class="u-txt-lg">Withdrawal Settlements</h1>
            <p class="u-txt-subtitle u-mt-5">Audit member withdrawal requests, process bank payouts, and record transactional UTR vectors.</p>
        </div>
    </div>

    <asp:Panel ID="pnlMsg" runat="server" Visible="false" style="border-radius: 12px; font-weight:600; padding: 12px 20px;">
        <asp:Label ID="lblMsg" runat="server"></asp:Label>
    </asp:Panel>

    <!-- FILTER BLOCK -->
    <div class="table-card u-mb-20" style="padding: 15px 20px;">
        <div class="u-d-flex u-a-center u-gap-15">
            <div style="font-weight: 600; color: #475569; font-size: 14px;"><i class="fas fa-filter u-mr-5"></i> Filter by Status:</div>
            <asp:DropDownList ID="ddlStatusFilter" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlStatusFilter_SelectedIndexChanged" CssClass="u-input-field" style="width: 180px; margin: 0;">
                <asp:ListItem Value="ALL">All Requests</asp:ListItem>
                <asp:ListItem Value="PENDING">Pending Audit</asp:ListItem>
                <asp:ListItem Value="PAID">Successfully Settled</asp:ListItem>
                <asp:ListItem Value="REJECTED">Rejected Requests</asp:ListItem>
            </asp:DropDownList>
        </div>
    </div>

    <!-- DATA GRID VIEW -->
    <div class="table-card" style="overflow-x: auto;">
        <asp:GridView ID="gvPayouts" runat="server" AutoGenerateColumns="false" CssClass="admin-table" GridLines="None" 
            OnRowCommand="gvPayouts_RowCommand">
            <EmptyDataTemplate>
                <div style="text-align: center; padding: 60px 20px; background: #f8fafc; border-radius: 16px; margin: 15px; display: flex; flex-direction: column; align-items: center; justify-content: center;">
                    <div style="width: 80px; height: 80px; border-radius: 50%; background: #e0f2fe; display: flex; align-items: center; justify-content: center; margin-bottom: 20px; border: 4px solid #f0f9ff; box-shadow: 0 0 0 8px #f8fafc;">
                        <i class="fas fa-receipt" style="font-size: 32px; color: #0ea5e9;"></i>
                    </div>
                    <h3 style="color: #1e293b; font-weight: 800; font-size: 18px; margin-bottom: 8px;">No Settlement Logs Available</h3>
                    <p style="color: #64748b; font-size: 13.5px; max-width: 350px; margin: 0 auto 20px; line-height: 1.5;">
                        Your financial ledger is completely clear! Currently, there are no payout requests matching your active filter.
                    </p>
                    <span style="background: #dcfce7; color: #15803d; font-size: 11px; font-weight: 800; padding: 6px 16px; border-radius: 30px; text-transform: uppercase; letter-spacing: 0.5px; border: 1px solid #bbf7d0; display: inline-flex; align-items:center; gap:5px;">
                        <i class="fas fa-check-circle"></i> Ledger Balanced
                    </span>
                </div>
            </EmptyDataTemplate>
            <Columns>
                
                <asp:TemplateField HeaderText="Request ID">
                    <ItemTemplate>
                        <div style="font-weight:700; color:#0f172a;">#PAY-<%# Eval("Id") %></div>
                        <div style="font-size: 11px; color:#64748b; margin-top:2px;"><%# Eval("CreatedAt", "{0:dd MMM yyyy}") %></div>
                    </ItemTemplate>
                </asp:TemplateField>

                <asp:TemplateField HeaderText="Member Information">
                    <ItemTemplate>
                        <div style="font-weight:600; color:#0ea5e9;"><%# Eval("FullName") %></div>
                        <div style="font-size: 12px; font-weight: 700; color:#475569; margin-top:2px;">👤 <%# Eval("Username") %></div>
                    </ItemTemplate>
                </asp:TemplateField>

                <asp:TemplateField HeaderText="Financial Breakdown">
                    <ItemTemplate>
                        <div style="font-size:12px; color:#64748b;">Gross: ₹<%# Eval("RequestAmount", "{0:N2}") %></div>
                        <div style="font-size:12px; color:#ef4444; margin-top:2px;">Tax/Fee: ₹<%# Convert.ToDecimal(Eval("TdsDeduction")) + Convert.ToDecimal(Eval("AdminCharges")) %></div>
                        <div style="font-size:13.5px; font-weight:700; color:#10b981; margin-top:4px;">Net: ₹<%# Eval("NetPayable", "{0:N2}") %></div>
                    </ItemTemplate>
                </asp:TemplateField>

                <asp:TemplateField HeaderText="Beneficiary Bank Coordinates">
                    <ItemTemplate>
                        <%# Eval("AccountNumber") == DBNull.Value ? "<div style='color:#94a3b8; font-style:italic; font-size:12px;'>No bank registered</div>" : @"
                            <div class='bank-badge'>
                                🏢 <span>" + Eval("BankName") + @"</span><br/>
                                💳 A/C: <span>" + Eval("AccountNumber") + @"</span><br/>
                                🔑 IFSC: <span>" + Eval("IFSCCode") + @"</span><br/>
                                👤 Holder: <span>" + Eval("AccountHolderName") + @"</span>
                            </div>
                        " %>
                    </ItemTemplate>
                </asp:TemplateField>

                <asp:TemplateField HeaderText="Settle State">
                    <ItemTemplate>
                        <%# 
                            Eval("Status").ToString() == "PENDING" ? "<span class='badge-status badge-warning'><i class='fas fa-hourglass-half'></i> PENDING</span>" :
                            Eval("Status").ToString() == "PAID" ? "<span class='badge-status badge-success'><i class='fas fa-check-circle'></i> PAID</span>" :
                            "<span class='badge-status badge-danger'><i class='fas fa-times-circle'></i> REJECTED</span>"
                        %>
                        <%# Eval("TransactionId") != DBNull.Value && !string.IsNullOrEmpty(Eval("TransactionId").ToString()) ? "<div style='font-size:10.5px; font-weight:700; color:#475569; margin-top:5px; border-top:1px dashed #cbd5e1; padding-top:4px;'>UTR: " + Eval("TransactionId") + "</div>" : "" %>
                    </ItemTemplate>
                </asp:TemplateField>

                <asp:TemplateField HeaderText="Action Matrix">
                    <ItemTemplate>
                        <div class="u-d-flex u-gap-5" style="display: <%# Eval("Status").ToString() == "PENDING" ? "flex" : "none" %>;">
                            <asp:LinkButton ID="lnkPaid" runat="server" CommandName="PaidTrigger" CommandArgument='<%# Eval("Id") %>' CssClass="btn-action" style="background:#e6fcf5; color:#0ca678; border-radius:8px;" ToolTip="Mark Settled/Paid">
                                <i class="fas fa-check"></i>
                            </asp:LinkButton>
                            <asp:LinkButton ID="lnkReject" runat="server" CommandName="RejectTrigger" CommandArgument='<%# Eval("Id") %>' CssClass="btn-action" style="background:#fff5f5; color:#e03131; border-radius:8px;" ToolTip="Reject Withdrawal">
                                <i class="fas fa-times"></i>
                            </asp:LinkButton>
                        </div>
                        <div style="font-size: 12px; color: #94a3b8; font-style: italic; display: <%# Eval("Status").ToString() != "PENDING" ? "block" : "none" %>;">
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
            <div class="modal-title"><i class="fas fa-money-bill-check" style="color: #10b981;"></i> Log Bank Settlement</div>
            <p class="modal-desc">Please input the transactional Reference/UTR Number issued by your banking partner to finalize this settlement ledger.</p>
            
            <div class="form-grp u-mb-20">
                <label class="settings-label">Bank Reference / UTR Transaction ID</label>
                <asp:TextBox ID="txtTxnId" runat="server" placeholder="e.g., UTR928374822" CssClass="u-input-field"></asp:TextBox>
            </div>

            <div class="u-d-flex u-gap-10">
                <button type="button" class="btn-outline-primary" onclick="closeActionModal()" style="flex:1; border-radius:10px; font-size:13px;">Cancel</button>
                <asp:Button ID="btnConfirmPaid" runat="server" Text="Release Settlement" CssClass="btn-primary" OnClick="btnConfirmPaid_Click" style="flex:1.5; border-radius:10px; background:#10b981; border-color:#10b981; font-size:13px;" />
            </div>
        </div>
    </div>

    <!-- MODAL 2: CONFIRM REJECTION -->
    <div class="modal-overlay" id="modal-reject">
        <div class="action-modal">
            <div class="modal-title"><i class="fas fa-ban" style="color: #f43f5e;"></i> Deny Payout Request</div>
            <p class="modal-desc">Specify the vector/reason explaining the rejection. This explanation is transmitted to the user's core panel.</p>
            
            <div class="form-grp u-mb-20">
                <label class="settings-label">Reason for Audit Rejection</label>
                <asp:TextBox ID="txtReason" runat="server" TextMode="MultiLine" Rows="3" placeholder="e.g., Invalid IFSC code provided." CssClass="u-input-field" style="height: auto !important;"></asp:TextBox>
            </div>

            <div class="u-d-flex u-gap-10">
                <button type="button" class="btn-outline-primary" onclick="closeActionModal()" style="flex:1; border-radius:10px; font-size:13px;">Cancel</button>
                <asp:Button ID="btnConfirmReject" runat="server" Text="Reject Request" CssClass="btn-primary" OnClick="btnConfirmReject_Click" style="flex:1.5; border-radius:10px; background:#f43f5e; border-color:#f43f5e; font-size:13px;" />
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
            document.querySelectorAll('.modal-overlay').forEach(function(el) {
                el.classList.remove('show');
            });
        }
    </script>

</asp:Content>
