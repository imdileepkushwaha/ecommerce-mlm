<%@ Page Title="Settings" Language="C#" MasterPageFile="~/usersite.Master" AutoEventWireup="true"
    CodeFile="UserSettings.aspx.cs" Inherits="ecommerce_mlm.UserSettings" %>
    <%@ Register Src="~/UserSidebar.ascx" TagPrefix="uc" TagName="UserSidebar" %>

        <asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
            <style>
                /* Specific overrides for this view */
                .addr-card-footer .btn-mini-action {
                    border: none;
                    cursor: pointer;
                }
            </style>
        </asp:Content>

        <asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
            <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>

            <section class="dashboard-wrapper">
                <div class="dashboard-breadcrumb">
                    <div class="container">
                        <div class="dashboard-breadcrumb-inner">
                            <div class="breadcrumb-left">
                                <h3>Account Settings</h3>
                            </div>
                            <div class="breadcrumb-right">
                                <a href="index.aspx"><i class="fas fa-home"></i></a>
                                <span> / Settings</span>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="container">
                    <div class="dashboard-layout">
                        <uc:UserSidebar runat="server" ID="UserSidebar" />

                        <main class="dashboard-main-content">

                            <!-- UpdatePanel wraps ONLY settings so that actions don't reload full sidebar -->
                            <asp:UpdatePanel ID="upnlSettings" runat="server">
                                <ContentTemplate>

                                    <div class="main-card main-card-padded">
                                        <div class="settings-page-wrap">

                                            <!-- Unified Master Header -->
                                            <div class="section-title section-title-bordered addr-header-wrap">
                                                <div><i class="fas fa-cog"></i> Settings</div>
                                            </div>

                                            <!-- Address Section Encapsulated in Grouped Card -->
                                            <div class="settings-group-card">
                                                <div class="set-grp-header"
                                                    style="justify-content: space-between; width: 100%;">
                                                    <div style="display: flex; align-items: center; gap: 15px;">
                                                        <div class="set-icon-box bg-blue">
                                                            <i class="fas fa-map-marker-alt"></i>
                                                        </div>
                                                        <div class="set-grp-title-grp">
                                                            <h4>Saved Addresses</h4>
                                                            <p>Manage your delivery destinations</p>
                                                        </div>
                                                    </div>
                                                    <asp:LinkButton ID="btnAddAddress" runat="server"
                                                        CssClass="btn-pill-modern btn-orange-grad"
                                                        style="font-size:0.85rem; padding:8px 20px;"
                                                        OnClick="btnAddAddress_Click">
                                                        <i class="fas fa-plus"></i> Add New
                                                    </asp:LinkButton>
                                                </div>

                                                <div style="padding: 0 25px 20px;">
                                                    <!-- Dynamic Repeater for Saved Addresses Grid -->
                                                    <div class="address-grid-layout" style="margin-top: 0;">
                                                        <asp:Repeater ID="rptAddresses" runat="server"
                                                            OnItemCommand="rptAddresses_ItemCommand">
                                                            <ItemTemplate>
                                                                <div class="saved-addr-card"
                                                                    style="box-shadow: 0 2px 10px rgba(0,0,0,0.03);">
                                                                    <div class="addr-card-header"
                                                                        style="margin-bottom: 10px;">
                                                                        <span class="addr-type-tag">
                                                                            <%# Eval("Tag") %>
                                                                        </span>
                                                                        <%# Convert.ToBoolean(Eval("IsDefault"))
                                                                            ? "<span class='addr-default-badge'>Default</span>"
                                                                            : "" %>
                                                                    </div>
                                                                    <div class="addr-card-body"
                                                                        style="margin-bottom:0;">
                                                                        <h5>
                                                                            <%# Eval("FullName") %>
                                                                        </h5>
                                                                        <p class="addr-text-full">
                                                                            <%# Eval("StreetAddress") %>, <%#
                                                                                    Eval("City") %>, <%# Eval("State")
                                                                                        %> - <%# Eval("ZipCode") %>
                                                                        </p>
                                                                        <p class="addr-phone-row">Phone: <%#
                                                                                Eval("PhoneNumber") %>
                                                                        </p>
                                                                    </div>
                                                                    <div class="addr-card-footer"
                                                                        style="padding-top: 0;">
                                                                        <asp:LinkButton runat="server"
                                                                            CommandName="EditAddr"
                                                                            CommandArgument='<%# Eval("Id") %>'
                                                                            CssClass="btn-mini-action mini-btn-blue">
                                                                            Edit</asp:LinkButton>
                                                                        <asp:LinkButton runat="server"
                                                                            CommandName="SetDefault"
                                                                            CommandArgument='<%# Eval("Id") %>'
                                                                            CssClass="btn-mini-action mini-btn-green"
                                                                            Visible='<%# !Convert.ToBoolean(Eval("IsDefault")) %>'>
                                                                            Set default</asp:LinkButton>
                                                                        <asp:LinkButton runat="server"
                                                                            CommandName="DeleteAddr"
                                                                            CommandArgument='<%# Eval("Id") %>'
                                                                            OnClientClick="return confirm('Are you sure you want to delete this address?');"
                                                                            CssClass="btn-mini-action mini-btn-red">
                                                                            Delete</asp:LinkButton>
                                                                    </div>
                                                                </div>
                                                            </ItemTemplate>
                                                        </asp:Repeater>

                                                        <asp:Panel ID="pnlNoAddresses" runat="server" Visible="false"
                                                            CssClass="empty-state-premium"
                                                            style="grid-column: 1/-1; padding: 30px;">
                                                            <p style="color:#64748b;">No addresses saved yet. Click "Add
                                                                New" to store a shipping address.</p>
                                                        </asp:Panel>
                                                    </div>
                                                </div>
                                            </div>

                                            <!-- Bank Account Details -->
                                            <div class="settings-group-card">
                                                <div class="set-grp-header"
                                                    style="justify-content: space-between; width: 100%;">
                                                    <div style="display: flex; align-items: center; gap: 15px;">
                                                        <div class="set-icon-box bg-orange">
                                                            <i class="fas fa-university"></i>
                                                        </div>
                                                        <div class="set-grp-title-grp">
                                                            <h4>Bank Account</h4>
                                                            <p>Where you receive your withdrawal income</p>
                                                        </div>
                                                    </div>
                                                    <asp:LinkButton ID="btnActionBank" runat="server"
                                                        CssClass="btn-pill-modern btn-orange-grad"
                                                        style="font-size:0.85rem; padding:8px 20px;"
                                                        OnClick="btnActionBank_Click">
                                                        <i class="fas fa-plus"></i> Add Account
                                                    </asp:LinkButton>
                                                </div>

                                                <div style="padding: 0 25px 20px;">
                                                    <asp:Panel ID="pnlBankDisplay" runat="server"
                                                        CssClass="bank-details-display" Visible="false">
                                                        <div class="bank-info-box">
                                                            <div class="bank-icon-circle"><i class="fas fa-wallet"></i>
                                                            </div>
                                                            <div>
                                                                <div class="b-bank-name">
                                                                    <asp:Literal ID="lblDispBankName" runat="server">
                                                                    </asp:Literal>
                                                                </div>
                                                                <div class="b-acc-num">
                                                                    <asp:Literal ID="lblDispAccNum" runat="server">
                                                                    </asp:Literal>
                                                                </div>
                                                                <div class="b-holder">A/C Holder: <asp:Literal
                                                                        ID="lblDispAccHolder" runat="server">
                                                                    </asp:Literal>
                                                                </div>
                                                            </div>
                                                        </div>
                                                        <span
                                                            style="font-size:0.75rem; color:#059669; background:#ecfdf5; padding:4px 10px; border-radius:12px; font-weight:700;"><i
                                                                class="fas fa-check-circle"></i> Primary</span>
                                                    </asp:Panel>

                                                    <asp:Panel ID="pnlNoBank" runat="server" CssClass="no-bank-banner">
                                                        <i class="fas fa-info-circle" style="font-size:1.2rem;"></i>
                                                        <span>No bank account connected. Add one to facilitate income
                                                            payouts!</span>
                                                    </asp:Panel>
                                                </div>
                                            </div>

                                            <!-- Security Section -->
                                            <div class="settings-group-card" style="margin-bottom: 0;">
                                                <div class="set-grp-header">
                                                    <div class="set-icon-box bg-blue"><i class="fas fa-lock"></i></div>
                                                    <div class="set-grp-title-grp">
                                                        <h4>Security</h4>
                                                        <p>Manage your password and login settings</p>
                                                    </div>
                                                </div>
                                                <div class="set-item-row">
                                                    <div class="set-item-info">
                                                        <h5>Password</h5>
                                                        <p>Last changed recently. Use a strong, unique password.</p>
                                                    </div>
                                                    <div class="set-actions">
                                                        <asp:LinkButton ID="btnShowChangePassword" runat="server"
                                                            CssClass="btn-pill-modern btn-orange-grad"
                                                            OnClick="btnShowChangePassword_Click"><i
                                                                class="fas fa-key"></i> Change Password</asp:LinkButton>
                                                    </div>
                                                </div>
                                                <div class="set-item-row">
                                                    <div class="set-item-info">
                                                        <h5>Active Sessions</h5>
                                                        <p>You are currently logged in on this device.</p>
                                                    </div>
                                                    <div class="set-actions">
                                                        <asp:LinkButton ID="btnLogout" runat="server"
                                                            CssClass="btn-pill-modern btn-soft-outline"
                                                            OnClick="btnLogout_Click">
                                                            <i class="fas fa-sign-out-alt"></i> Logout
                                                        </asp:LinkButton>
                                                    </div>
                                                </div>
                                            </div>

                                            <!-- Danger Zone -->
                                            <div class="settings-group-card" style="margin-bottom: 0;">
                                                <div class="set-grp-header">
                                                    <div class="set-icon-box bg-red"><i
                                                            class="fas fa-exclamation-triangle"></i></div>
                                                    <div class="set-grp-title-grp">
                                                        <h4>Danger Zone</h4>
                                                        <p>Irreversible account actions</p>
                                                    </div>
                                                </div>
                                                <div class="set-item-row"
                                                    style="flex-direction: column; align-items: flex-start; gap: 15px;">
                                                    <div class="set-item-info">
                                                        <h5>Delete Account</h5>
                                                        <p>Once requested, account is deleted 48 hours after Admin
                                                            approval.</p>
                                                    </div>

                                                    <asp:Panel ID="pnlNoRequest" runat="server" style="width: 100%;">
                                                        <div class="set-actions" style="justify-content: flex-start;">
                                                            <asp:LinkButton ID="btnTriggerDelete" runat="server"
                                                                CssClass="btn-pill-modern btn-red-light"
                                                                OnClick="btnTriggerDelete_Click"><i
                                                                    class="fas fa-trash-alt"></i> Request Account
                                                                Deletion</asp:LinkButton>
                                                        </div>
                                                    </asp:Panel>

                                                    <asp:Panel ID="pnlPendingRequest" runat="server" Visible="false"
                                                        style="width: 100%;">
                                                        <div
                                                            style="background:#fff1f2; border:1px solid #fecdd3; border-radius:12px; padding:15px; width:100%; display:flex; justify-content:space-between; align-items:center;">
                                                            <div>
                                                                <h6
                                                                    style="color:#be123c; font-weight:700; margin:0 0 5px 0; display:flex; align-items:center; gap:8px;">
                                                                    <i class="fas fa-hourglass-half"></i> Deletion
                                                                    Request Pending
                                                                </h6>
                                                                <span style="font-size:0.8rem; color:#9f1239;">Waiting
                                                                    for admin to review your request.</span>
                                                            </div>
                                                            <asp:LinkButton ID="btnCancelReq" runat="server"
                                                                CssClass="btn-pill-modern btn-soft-outline"
                                                                style="border-color:#fda4af; color:#be123c;"
                                                                OnClick="btnCancelReq_Click">Cancel Request
                                                            </asp:LinkButton>
                                                        </div>
                                                    </asp:Panel>
                                                </div>
                                            </div>

                                        </div>
                                    </div>

                                    <!-- CUSTOM ADDRESS POPUP MODAL -->
                                    <asp:Panel ID="pnlAddressModal" runat="server" CssClass="modal-overlay"
                                        Visible="false">
                                        <div class="modal-container">
                                            <div class="modal-header">
                                                <h3>
                                                    <asp:Literal ID="litModalTitle" runat="server">Add New Address
                                                    </asp:Literal>
                                                </h3>
                                                <asp:LinkButton ID="btnCloseModal" runat="server"
                                                    CssClass="btn-close-modal" OnClick="btnCloseModal_Click">
                                                    <i class="fas fa-times"></i>
                                                </asp:LinkButton>
                                            </div>
                                            <div class="modal-body">
                                                <asp:HiddenField ID="hfSelectedAddrId" runat="server" />

                                                <div class="modal-form-row">
                                                    <div class="modal-form-group">
                                                        <label>Full Name</label>
                                                        <asp:TextBox ID="txtFullName" runat="server"
                                                            CssClass="form-control-custom" placeholder="John Doe">
                                                        </asp:TextBox>
                                                    </div>
                                                    <div class="modal-form-group">
                                                        <label>Phone Number</label>
                                                        <asp:TextBox ID="txtPhone" runat="server"
                                                            CssClass="form-control-custom" placeholder="10-digit phone">
                                                        </asp:TextBox>
                                                    </div>
                                                </div>

                                                <div class="modal-form-group">
                                                    <label>Street Address</label>
                                                    <asp:TextBox ID="txtStreet" runat="server"
                                                        CssClass="form-control-custom"
                                                        placeholder="Flat no, Building, Area"></asp:TextBox>
                                                </div>

                                                <div class="modal-form-row">
                                                    <div class="modal-form-group">
                                                        <label>City</label>
                                                        <asp:TextBox ID="txtCity" runat="server"
                                                            CssClass="form-control-custom" placeholder="Enter City">
                                                        </asp:TextBox>
                                                    </div>
                                                    <div class="modal-form-group">
                                                        <label>State</label>
                                                        <asp:TextBox ID="txtState" runat="server"
                                                            CssClass="form-control-custom" placeholder="Enter State">
                                                        </asp:TextBox>
                                                    </div>
                                                </div>

                                                <div class="modal-form-row">
                                                    <div class="modal-form-group">
                                                        <label>Zip Code</label>
                                                        <asp:TextBox ID="txtZip" runat="server"
                                                            CssClass="form-control-custom" placeholder="Zip code">
                                                        </asp:TextBox>
                                                    </div>
                                                    <div class="modal-form-group">
                                                        <label>Address Type (Tag)</label>
                                                        <asp:DropDownList ID="ddlTag" runat="server"
                                                            CssClass="form-control-custom">
                                                            <asp:ListItem Value="HOME">Home</asp:ListItem>
                                                            <asp:ListItem Value="WORK">Work</asp:ListItem>
                                                            <asp:ListItem Value="OTHER">Other</asp:ListItem>
                                                        </asp:DropDownList>
                                                    </div>
                                                </div>

                                                <div class="modal-form-group" style="margin-bottom: 0;">
                                                    <label
                                                        style="display:flex; align-items:center; gap:10px; cursor:pointer;">
                                                        <asp:CheckBox ID="chkIsDefault" runat="server" />
                                                        <span>Set as default delivery address</span>
                                                    </label>
                                                </div>

                                                <div style="margin-top: 10px;">
                                                    <asp:Label ID="lblModalMsg" runat="server" ForeColor="Red"
                                                        Font-Size="Small"></asp:Label>
                                                </div>
                                            </div>
                                            <div class="modal-footer">
                                                <asp:LinkButton ID="btnCancelModal" runat="server"
                                                    CssClass="btn-pill-modern btn-soft-outline"
                                                    OnClick="btnCloseModal_Click">Cancel</asp:LinkButton>
                                                <asp:Button ID="btnSaveAddress" runat="server"
                                                    CssClass="btn-pill-modern btn-orange-grad" style="border:none;"
                                                    Text="Save Address" OnClick="btnSaveAddress_Click" />
                                            </div>
                                        </div>
                                    </asp:Panel>

                                    <!-- CUSTOM PASSWORD MODAL -->
                                    <asp:Panel ID="pnlPasswordModal" runat="server" CssClass="modal-overlay"
                                        Visible="false">
                                        <div class="modal-container">
                                            <div class="modal-header">
                                                <h3>Change Password</h3>
                                                <asp:LinkButton ID="btnClosePassModal" runat="server"
                                                    CssClass="btn-close-modal" OnClick="btnClosePassModal_Click">
                                                    <i class="fas fa-times"></i>
                                                </asp:LinkButton>
                                            </div>
                                            <div class="modal-body">
                                                <div class="modal-form-group">
                                                    <label>Current Password</label>
                                                    <div class="pass-input-wrapper">
                                                        <asp:TextBox ID="txtCurrPass" runat="server"
                                                            CssClass="form-control-custom" TextMode="Password"
                                                            placeholder="••••••••"></asp:TextBox>
                                                        <i class="fas fa-eye toggle-eye-icon"
                                                            onclick="toggleVis(this)"></i>
                                                    </div>
                                                </div>
                                                <div class="modal-form-group">
                                                    <label>New Password</label>
                                                    <div class="pass-input-wrapper">
                                                        <asp:TextBox ID="txtNewPass" runat="server"
                                                            CssClass="form-control-custom" TextMode="Password"
                                                            placeholder="Minimum 6 chars"></asp:TextBox>
                                                        <i class="fas fa-eye toggle-eye-icon"
                                                            onclick="toggleVis(this)"></i>
                                                    </div>
                                                </div>
                                                <div class="modal-form-group" style="margin-bottom: 0;">
                                                    <label>Confirm New Password</label>
                                                    <div class="pass-input-wrapper">
                                                        <asp:TextBox ID="txtConfirmPass" runat="server"
                                                            CssClass="form-control-custom" TextMode="Password"
                                                            placeholder="••••••••"></asp:TextBox>
                                                        <i class="fas fa-eye toggle-eye-icon"
                                                            onclick="toggleVis(this)"></i>
                                                    </div>
                                                </div>
                                                <div style="margin-top: 15px;">
                                                    <asp:Label ID="lblPassMsg" runat="server" ForeColor="Red"
                                                        Font-Bold="true" Font-Size="Small"></asp:Label>
                                                </div>
                                            </div>
                                            <div class="modal-footer">
                                                <asp:LinkButton ID="btnCancelPass" runat="server"
                                                    CssClass="btn-pill-modern btn-soft-outline"
                                                    OnClick="btnClosePassModal_Click">Cancel</asp:LinkButton>
                                                <asp:Button ID="btnSavePassword" runat="server"
                                                    CssClass="btn-pill-modern btn-orange-grad" style="border:none;"
                                                    Text="Update Password" OnClick="btnSavePassword_Click" />
                                            </div>
                                        </div>
                                    </asp:Panel>

                                    <!-- CUSTOM ACCOUNT DELETE CONFIRMATION MODAL -->
                                    <asp:Panel ID="pnlDeleteModal" runat="server" CssClass="modal-overlay"
                                        Visible="false">
                                        <div class="modal-container" style="max-width:420px;">
                                            <div class="modal-header" style="border-bottom-color: #fee2e2;">
                                                <h3 style="color:#dc2626;"><i class="fas fa-exclamation-circle"
                                                        style="margin-right:8px;"></i> Permanent Deletion</h3>
                                                <asp:LinkButton ID="btnCloseDelModal" runat="server"
                                                    CssClass="btn-close-modal" OnClick="btnCloseDelModal_Click">
                                                    <i class="fas fa-times"></i>
                                                </asp:LinkButton>
                                            </div>
                                            <div class="modal-body" style="text-align: center;">
                                                <div style="font-size: 3rem; color: #ef4444; margin-bottom: 15px;"><i
                                                        class="fas fa-user-slash"></i></div>
                                                <h4 style="font-weight:800; color:#1e293b; margin-bottom:10px;">Are you
                                                    absolutely sure?</h4>
                                                <p
                                                    style="font-size:0.88rem; color:#64748b; margin-bottom:20px; line-height:1.5;">
                                                    This action is irreversible. To confirm, please type
                                                    <strong>DELETE</strong> in the box below.
                                                </p>

                                                <div class="modal-form-group">
                                                    <asp:TextBox ID="txtDeleteConfirm" runat="server"
                                                        CssClass="form-control-custom" placeholder="TYPE 'DELETE' HERE"
                                                        style="text-align:center; font-weight:800; text-transform:uppercase; letter-spacing:2px; border-color:#fca5a5;">
                                                    </asp:TextBox>
                                                </div>
                                                <asp:Label ID="lblDelMsg" runat="server" ForeColor="Red"
                                                    Font-Bold="true" Font-Size="Small"></asp:Label>
                                            </div>
                                            <div class="modal-footer" style="background: #fef2f2; border-top: none;">
                                                <asp:LinkButton ID="btnCancelDel" runat="server"
                                                    CssClass="btn-pill-modern btn-soft-outline"
                                                    OnClick="btnCloseDelModal_Click">Keep Account</asp:LinkButton>
                                                <asp:Button ID="btnFinalDelete" runat="server"
                                                    CssClass="btn-pill-modern"
                                                    style="background:#dc2626; color:#fff; border:none;"
                                                    Text="Confirm Deletion" OnClick="btnFinalDelete_Click" />
                                            </div>
                                        </div>
                                    </asp:Panel>

                                    <!-- CUSTOM BANK DETAILS MODAL -->
                                    <asp:Panel ID="pnlBankModal" runat="server" CssClass="modal-overlay"
                                        Visible="false">
                                        <div class="modal-container" style="max-width:500px;">
                                            <div class="modal-header">
                                                <h3><i class="fas fa-university"></i> Manage Bank Account</h3>
                                                <asp:LinkButton ID="btnCloseBank" runat="server"
                                                    CssClass="btn-close-modal" OnClick="btnCloseBankModal_Click">
                                                    <i class="fas fa-times"></i>
                                                </asp:LinkButton>
                                            </div>
                                            <div class="modal-body">

                                                <!-- STEP 1: DATA ENTRY -->
                                                <asp:Panel ID="pnlBankEntryView" runat="server">
                                                    <div class="modal-form-group">
                                                        <label>Account Holder Name <span
                                                                style="color:red;">*</span></label>
                                                        <asp:TextBox ID="txtBankHolderName" runat="server"
                                                            CssClass="form-control-custom"
                                                            placeholder="Name as on passbook"></asp:TextBox>
                                                    </div>
                                                    <div class="modal-form-row">
                                                        <div class="modal-form-group">
                                                            <label>Bank Name <span style="color:red;">*</span></label>
                                                            <asp:TextBox ID="txtBankName" runat="server"
                                                                CssClass="form-control-custom"
                                                                placeholder="SBI, HDFC, etc."></asp:TextBox>
                                                        </div>
                                                        <div class="modal-form-group">
                                                            <label>Account Number <span
                                                                    style="color:red;">*</span></label>
                                                            <asp:TextBox ID="txtAccountNumber" runat="server"
                                                                CssClass="form-control-custom" placeholder="0000000000">
                                                            </asp:TextBox>
                                                        </div>
                                                    </div>
                                                    <div class="modal-form-row">
                                                        <div class="modal-form-group">
                                                            <label>IFSC Code <span style="color:red;">*</span></label>
                                                            <asp:TextBox ID="txtIFSC" runat="server"
                                                                CssClass="form-control-custom"
                                                                placeholder="SBIN0001234"></asp:TextBox>
                                                        </div>
                                                        <div class="modal-form-group">
                                                            <label>Branch Name</label>
                                                            <asp:TextBox ID="txtBranch" runat="server"
                                                                CssClass="form-control-custom" placeholder="Optional">
                                                            </asp:TextBox>
                                                        </div>
                                                    </div>
                                                    <p
                                                        style="font-size: 0.75rem; color: #64748b; margin-top: 10px; display:flex; align-items:center; gap:5px;">
                                                        <i class="fas fa-shield-alt" style="color:#10b981;"></i> Click
                                                        'Send OTP' to authenticate these details.
                                                    </p>
                                                </asp:Panel>

                                                <!-- STEP 2: OTP VERIFICATION -->
                                                <asp:Panel ID="pnlBankOTPView" runat="server" Visible="false"
                                                    style="text-align:center; padding: 10px 0;">
                                                    <div style="font-size: 2rem; color: #f97316; margin-bottom:10px;"><i
                                                            class="fas fa-envelope-open-text"></i></div>
                                                    <h4 style="margin:0 0 5px; color:#1e293b;">Verify OTP</h4>
                                                    <p style="font-size:0.8rem; color:#64748b; margin-bottom:15px;">We
                                                        have emailed a one-time password to your registered address.
                                                        Enter it below:</p>

                                                    <div class="modal-form-group"
                                                        style="max-width:200px; margin:0 auto;">
                                                        <asp:TextBox ID="txtBankOTP" runat="server"
                                                            CssClass="form-control-custom" MaxLength="6"
                                                            placeholder="••••••"
                                                            style="text-align:center; font-size:1.2rem; letter-spacing:5px;">
                                                        </asp:TextBox>
                                                    </div>

                                                    <div style="margin-top:10px;">
                                                        <asp:Label ID="lblBankOTPErr" runat="server" ForeColor="Red"
                                                            Font-Bold="true" Font-Size="Small"></asp:Label>
                                                    </div>
                                                </asp:Panel>

                                            </div>
                                            <div class="modal-footer">
                                                <asp:LinkButton ID="btnCancelBank" runat="server"
                                                    CssClass="btn-pill-modern btn-soft-outline"
                                                    OnClick="btnCloseBankModal_Click">Cancel</asp:LinkButton>

                                                <!-- Dynamic Footers -->
                                                <asp:Button ID="btnSendBankOTP" runat="server"
                                                    CssClass="btn-pill-modern btn-orange-grad" style="border:none;"
                                                    Text="Send OTP & Save" OnClick="btnSendBankOTP_Click" />
                                                <asp:Button ID="btnFinalizeBankUpdate" runat="server"
                                                    CssClass="btn-pill-modern btn-green" style="border:none;"
                                                    Text="Verify & Confirm" OnClick="btnFinalizeBankUpdate_Click"
                                                    Visible="false" />
                                            </div>
                                        </div>
                                    </asp:Panel>

                                    <script type="text/javascript">
                                        // Handle adding dynamic CSS class to reveal popup smoothly through codebehind callback
                                        function showDynamicModal() {
                                            var modal = document.querySelector('.modal-overlay');
                                            if (modal) { modal.classList.add('active'); }
                                        }

                                        function toggleVis(icon) {
                                            // Finds the input field right before the clicked eye icon
                                            var input = icon.previousElementSibling;
                                            if (input.type === "password") {
                                                input.type = "text";
                                                icon.classList.remove("fa-eye");
                                                icon.classList.add("fa-eye-slash");
                                            } else {
                                                input.type = "password";
                                                icon.classList.remove("fa-eye-slash");
                                                icon.classList.add("fa-eye");
                                            }
                                        }
                                    </script>

                                </ContentTemplate>
                            </asp:UpdatePanel>

                        </main>
                    </div>
                </div>
            </section>
        </asp:Content>