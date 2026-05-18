<%@ Page Title="Merchant Account Settings" Language="C#" MasterPageFile="~/seller/Seller.Master" AutoEventWireup="true"
    CodeFile="Settings.aspx.cs" Inherits="EcommerceWebsite.SellerSettings" %>

    <asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
        <!-- Shipped to seller.css! -->
    </asp:Content>

    <asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

        <div class="container">

            <!-- ALERT MESSAGE NOTIFICATIONS -->
            <div class="settings-alert-wrapper">
                <asp:Label ID="lblMsg" runat="server" Visible="false" CssClass="prof-alert-box">
                </asp:Label>
            </div>

            <!-- 1. PORTAL HEADER -->
            <div class="page-action-bar">
                <div class="welcome-title">
                    <h1><i class="fas fa-cogs" style="color: var(--accent); margin-right: 8px;"></i>Settings</h1>
                    <p>Seller account, payouts, shipping aur security — sab sections neeche zones me grouped hain.</p>
                </div>
                <div>
                    <a href="Dashboard.aspx" class="add-prod-btn">
                        <i class="fas fa-chart-pie"></i> Dashboard
                    </a>
                </div>
            </div>

            <!-- 2. JUMP TAB BAR -->
            <nav class="jump-nav-bar">
                <span class="jump-label">JUMP</span>
                <a href="#zone1" class="jump-link">Account</a>
                <a href="#zone2" class="jump-link">Finance</a>
                <a href="#zone3" class="jump-link">Fulfilment</a>
                <a href="#zone4" class="jump-link">Security</a>
                <a href="#zone5" class="jump-link">Shortcuts</a>
                <a href="#zone6" class="jump-link">Communications</a>
                <a href="#zone4" class="jump-link jump-link-red">Delete account</a>
            </nav>

            <!-- 3. ZONES GRID -->
            <div class="zones-grid">

                <!-- ZONE 1: Account & Profile -->
                <div class="zone-card zone-card-purple" id="zone1">
                    <div class="zone-header">
                        <span class="zone-tag">ZONE 1 • IDENTITY</span>
                        <h2 class="zone-title">Account & Profile</h2>
                    </div>

                    <a href="Profile.aspx" class="portal-card">
                        <div class="portal-card-left">
                            <div class="portal-icon-box"><i class="fas fa-user-gear"></i></div>
                            <div class="portal-info">
                                <span class="portal-title">Profile & branding</span>
                                <span class="portal-desc">Phone, address, logo, banner</span>
                            </div>
                        </div>
                        <i class="fas fa-arrow-right portal-arrow"></i>
                    </a>

                    <a href="Kyc.aspx" class="portal-card">
                        <div class="portal-card-left">
                            <div class="portal-icon-box"><i class="fas fa-id-card-clip"></i></div>
                            <div class="portal-info">
                                <span class="portal-title">KYC & bank</span>
                                <span class="portal-desc">GST, documents, payout details</span>
                            </div>
                        </div>
                        <i class="fas fa-arrow-right portal-arrow"></i>
                    </a>

                    <asp:HyperLink ID="lnkPublicStore" runat="server" CssClass="portal-card" Target="_blank">
                        <div class="portal-card-left">
                            <div class="portal-icon-box"><i class="fas fa-globe"></i></div>
                            <div class="portal-info">
                                <span class="portal-title">Public store</span>
                                <span class="portal-desc">Buyer-facing storefront (new tab)</span>
                            </div>
                        </div>
                        <i class="fas fa-arrow-up-right-from-square portal-arrow portal-arrow-ext"></i>
                    </asp:HyperLink>


                </div>

                <!-- ZONE 2: Payouts / Financial -->
                <div class="zone-card zone-card-green" id="zone2">
                    <div class="zone-header">
                        <span class="zone-tag">ZONE 2 • PAYOUTS</span>
                        <h2 class="zone-title">Financial</h2>
                    </div>

                    <a href="Kyc.aspx" class="portal-card">
                        <div class="portal-card-left">
                            <div class="portal-icon-box"><i class="fas fa-dollar-sign"></i></div>
                            <div class="portal-info">
                                <span class="portal-title">Financial settings</span>
                                <span class="portal-desc">Bank accounts list & add new</span>
                            </div>
                        </div>
                        <i class="fas fa-arrow-right portal-arrow"></i>
                    </a>
                </div>

                <!-- ZONE 3: Delivery / Fulfilment -->
                <div class="zone-card zone-card-orange" id="zone3">
                    <div class="zone-header">
                        <span class="zone-tag">ZONE 3 • DELIVERY</span>
                        <h2 class="zone-title">Fulfilment</h2>
                    </div>

                    <asp:LinkButton ID="btnShipCard1" runat="server" CssClass="portal-card" OnClick="btnShipCard_Click"
                        CommandArgument="Shipping settings" CausesValidation="false">
                        <div class="portal-card-left">
                            <div class="portal-icon-box"><i class="fas fa-truck"></i></div>
                            <div class="portal-info">
                                <span class="portal-title">Shipping settings</span>
                                <span class="portal-desc">Classes, handling, zones</span>
                            </div>
                        </div>
                        <i class="fas fa-arrow-right portal-arrow"></i>
                    </asp:LinkButton>

                    <asp:LinkButton ID="btnShipCard2" runat="server" CssClass="portal-card" OnClick="btnShipCard_Click"
                        CommandArgument="Delivery options" CausesValidation="false">
                        <div class="portal-card-left">
                            <div class="portal-icon-box"><i class="fas fa-location-dot"></i></div>
                            <div class="portal-info">
                                <span class="portal-title">Delivery options</span>
                                <span class="portal-desc">Buyer delivery choices</span>
                            </div>
                        </div>
                        <i class="fas fa-arrow-right portal-arrow"></i>
                    </asp:LinkButton>

                    <asp:LinkButton ID="btnShipCard3" runat="server" CssClass="portal-card" OnClick="btnShipCard_Click"
                        CommandArgument="Returns & refunds" CausesValidation="false">
                        <div class="portal-card-left">
                            <div class="portal-icon-box"><i class="fas fa-rotate-left"></i></div>
                            <div class="portal-info">
                                <span class="portal-title">Returns & refunds</span>
                                <span class="portal-desc">Policy & windows</span>
                            </div>
                        </div>
                        <i class="fas fa-arrow-right portal-arrow"></i>
                    </asp:LinkButton>
                </div>

                <!-- ZONE 4: Access / Security -->
                <div class="zone-card zone-card-blue" id="zone4">
                    <div class="zone-header">
                        <span class="zone-tag">ZONE 4 • ACCESS</span>
                        <h2 class="zone-title">Security</h2>
                    </div>

                    <asp:LinkButton ID="btnOpenPassModal" runat="server" CssClass="portal-card"
                        OnClick="btnOpenPassModal_Click" CausesValidation="false">
                        <div class="portal-card-left">
                            <div class="portal-icon-box"><i class="fas fa-key"></i></div>
                            <div class="portal-info">
                                <span class="portal-title">Change password</span>
                                <span class="portal-desc">Current password + naya strong password</span>
                            </div>
                        </div>
                        <i class="fas fa-arrow-right portal-arrow"></i>
                    </asp:LinkButton>

                    <asp:LinkButton ID="btnOpenDeleteModal" runat="server" CssClass="portal-card portal-card-danger"
                        OnClick="btnOpenDeleteModal_Click" CausesValidation="false">
                        <div class="portal-card-left">
                            <div class="portal-icon-box"><i class="fas fa-triangle-exclamation"></i></div>
                            <div class="portal-info">
                                <span class="portal-title">Delete account</span>
                                <span class="portal-desc">Admin review ke baad access band</span>
                            </div>
                        </div>
                        <i class="fas fa-arrow-right portal-arrow"></i>
                    </asp:LinkButton>

                    <asp:LinkButton ID="btnOpenNotifyModal" runat="server" CssClass="portal-card"
                        OnClick="btnOpenNotifyModal_Click" CausesValidation="false">
                        <div class="portal-card-left">
                            <div class="portal-icon-box"><i class="fas fa-bell"></i></div>
                            <div class="portal-info">
                                <span class="portal-title">Notification settings</span>
                                <span class="portal-desc">Manage automated alerts & notifications</span>
                            </div>
                        </div>
                        <i class="fas fa-arrow-right portal-arrow"></i>
                    </asp:LinkButton>
                </div>

                <!-- ZONE 5: Shortcuts / Orders & Tools -->
                <div class="zone-card zone-card-indigo" id="zone5">
                    <div class="zone-header">
                        <span class="zone-tag">ZONE 5 • SHORTCUTS</span>
                        <h2 class="zone-title">Orders & Tools</h2>
                    </div>

                    <div class="shortcuts-row">
                        <a href="Orders.aspx" class="portal-card">
                            <div class="portal-card-left">
                                <div class="portal-icon-box"><i class="fas fa-receipt"></i></div>
                                <div class="portal-info">
                                    <span class="portal-title">Orders</span>
                                    <span class="portal-desc">Fulfilment & status</span>
                                </div>
                            </div>
                            <i class="fas fa-arrow-right portal-arrow"></i>
                        </a>

                        <a href="Inventory.aspx" class="portal-card">
                            <div class="portal-card-left">
                                <div class="portal-icon-box"><i class="fas fa-truck-ramp-box"></i></div>
                                <div class="portal-info">
                                    <span class="portal-title">Shipped products</span>
                                    <span class="portal-desc">Line-level shipped list</span>
                                </div>
                            </div>
                            <i class="fas fa-arrow-right portal-arrow"></i>
                        </a>

                        <a href="earnings.aspx" class="portal-card">
                            <div class="portal-card-left">
                                <div class="portal-icon-box"><i class="fas fa-wallet"></i></div>
                                <div class="portal-info">
                                    <span class="portal-title">Earnings & payouts</span>
                                    <span class="portal-desc">Withdraw, transactions</span>
                                </div>
                            </div>
                            <i class="fas fa-arrow-right portal-arrow"></i>
                        </a>
                    </div>
                </div>

                <!-- ZONE 6: Alerts & Integrations (Communications) -->
                <div class="zone-card zone-card-teal" id="zone6">
                    <div class="zone-header">
                        <span class="zone-tag">ZONE 6 • COMMUNICATIONS</span>
                        <h2 class="zone-title">Alerts & Integrations</h2>
                    </div>

                    <a href="CommunicationSettings.aspx?channel=email" class="portal-card">
                        <div class="portal-card-left">
                            <div class="portal-icon-box" style="background: rgba(6, 182, 212, 0.08); color: #06b6d4;"><i
                                    class="fas fa-envelope"></i></div>
                            <div class="portal-info">
                                <span class="portal-title">Email channel setup</span>
                                <span class="portal-desc">SMTP parameters, notification alerts</span>
                            </div>
                        </div>
                        <i class="fas fa-arrow-right portal-arrow"></i>
                    </a>

                    <a href="CommunicationSettings.aspx?channel=whatsapp" class="portal-card">
                        <div class="portal-card-left">
                            <div class="portal-icon-box" style="background: rgba(16, 185, 129, 0.08); color: #10b981;">
                                <i class="fab fa-whatsapp"></i>
                            </div>
                            <div class="portal-info">
                                <span class="portal-title">WhatsApp gateway setup</span>
                                <span class="portal-desc">WhatsApp Business API, verified sandbox</span>
                            </div>
                        </div>
                        <i class="fas fa-arrow-right portal-arrow"></i>
                    </a>

                    <a href="CommunicationSettings.aspx?channel=sms" class="portal-card">
                        <div class="portal-card-left">
                            <div class="portal-icon-box" style="background: rgba(245, 158, 11, 0.08); color: #f59e0b;">
                                <i class="fas fa-comment-sms"></i>
                            </div>
                            <div class="portal-info">
                                <span class="portal-title">SMS dispatch setup</span>
                                <span class="portal-desc">SMS API credentials, phone number notifications</span>
                            </div>
                        </div>
                        <i class="fas fa-arrow-right portal-arrow"></i>
                    </a>
                </div>

            </div>

        </div>

        <!-- ==========================================
       DYNAMIC INTERACTIVE MODALS DECK
       ========================================== -->

        <!-- Modal A: Change Password -->
        <asp:Panel ID="pnlPasswordModal" runat="server" Visible="false" CssClass="modal-overlay">
            <div class="modal-card">
                <div class="modal-header">
                    <h3 class="modal-title">Rotate Security Password</h3>
                    <asp:LinkButton ID="btnClosePass" runat="server" CssClass="modal-close-btn"
                        OnClick="btnCloseModal_Click" CausesValidation="false">
                        <i class="fas fa-xmark"></i>
                    </asp:LinkButton>
                </div>
                <div class="modal-body" style="gap: 16px;">
                    <div class="form-item">
                        <label class="form-lbl">Current Password</label>
                        <div class="password-input-wrapper">
                            <asp:TextBox ID="txtCurrentPassword" runat="server"
                                CssClass="prof-input password-toggle-input" TextMode="Password" placeholder="••••••••">
                            </asp:TextBox>
                            <span class="password-toggle-eye" onclick="togglePasswordVisibility(this)">
                                <i class="fas fa-eye-slash"></i>
                            </span>
                        </div>
                    </div>
                    <div class="form-item">
                        <label class="form-lbl">New Password</label>
                        <div class="password-input-wrapper">
                            <asp:TextBox ID="txtNewPassword" runat="server" CssClass="prof-input password-toggle-input"
                                TextMode="Password" placeholder="••••••••"></asp:TextBox>
                            <span class="password-toggle-eye" onclick="togglePasswordVisibility(this)">
                                <i class="fas fa-eye-slash"></i>
                            </span>
                        </div>
                    </div>
                    <div class="form-item">
                        <label class="form-lbl">Confirm New Password</label>
                        <div class="password-input-wrapper">
                            <asp:TextBox ID="txtConfirmPassword" runat="server"
                                CssClass="prof-input password-toggle-input" TextMode="Password" placeholder="••••••••">
                            </asp:TextBox>
                            <span class="password-toggle-eye" onclick="togglePasswordVisibility(this)">
                                <i class="fas fa-eye-slash"></i>
                            </span>
                        </div>
                    </div>
                    <div class="prof-submit-row settings-submit-row" style="margin-top: 5px;">
                        <asp:Button ID="btnUpdatePassword" runat="server" Text="Update Password"
                            CssClass="prof-btn-danger btn-accent-save" OnClick="btnUpdatePassword_Click"
                            style="width: 100%; border-radius: 10px; font-weight: 800; padding: 12px;" />
                    </div>
                </div>
            </div>
        </asp:Panel>

        <!-- Modal B: Notification Toggles -->
        <asp:Panel ID="pnlNotificationModal" runat="server" Visible="false" CssClass="modal-overlay">
            <div class="modal-card">
                <div class="modal-header">
                    <h3 class="modal-title">Notification Settings</h3>
                    <asp:LinkButton ID="btnCloseNotify" runat="server" CssClass="modal-close-btn"
                        OnClick="btnCloseModal_Click" CausesValidation="false">
                        <i class="fas fa-xmark"></i>
                    </asp:LinkButton>
                </div>
                <div class="modal-body">
                    <div class="chk-list-container">
                        <div class="chk-row">
                            <asp:CheckBox ID="chkNotifyEmail" runat="server" />
                            <div class="chk-label-box">
                                <span class="chk-lbl-title">Email Notifications</span>
                                <span class="chk-lbl-desc">Receive real-time purchase updates, reports & inventory
                                    warnings.</span>
                            </div>
                        </div>
                        <div class="chk-row">
                            <asp:CheckBox ID="chkNotifySms" runat="server" />
                            <div class="chk-label-box">
                                <span class="chk-lbl-title">SMS Notifications</span>
                                <span class="chk-lbl-desc">Receive critical login alerts, password synchronizations &
                                    security dispatches.</span>
                            </div>
                        </div>
                    </div>
                    <div class="prof-submit-row settings-submit-row">
                        <asp:Button ID="btnSavePreferences" runat="server" Text="Save Settings"
                            CssClass="prof-btn-danger btn-accent-save" OnClick="btnSavePreferences_Click" />
                    </div>
                </div>
            </div>
        </asp:Panel>

        <!-- Modal C: Account Deletion danger zone -->
        <asp:Panel ID="pnlDeleteModal" runat="server" Visible="false" CssClass="modal-overlay">
            <div class="modal-card">
                <div class="modal-header" style="border-bottom-color: #fee2e2;">
                    <h3 class="modal-title text-danger"><i class="fas fa-triangle-exclamation"></i> Permanent Account
                        Deactivation</h3>
                    <asp:LinkButton ID="btnCloseDelete" runat="server" CssClass="modal-close-btn"
                        OnClick="btnCloseModal_Click" CausesValidation="false">
                        <i class="fas fa-xmark"></i>
                    </asp:LinkButton>
                </div>
                <div class="modal-body" style="gap: 18px;">

                    <!-- Dedicate Inline Error Message for Delete Modal -->
                    <asp:Label ID="lblDeleteError" runat="server" Visible="false" CssClass="delete-modal-alert">
                    </asp:Label>

                    <!-- PAN A: ACTIVE (DELETION NOT FILED YET) -->
                    <asp:Panel ID="pnlDeleteActive" runat="server" Visible="true">
                        <!-- Hazard Pulsing Warning -->
                        <div class="delete-icon-container">
                            <div class="delete-icon-pulse">
                                <i class="fas fa-circle-exclamation"></i>
                            </div>
                        </div>

                        <div class="danger-note-box">
                            <h4
                                style="margin: 0 0 8px 0; font-size: 0.88rem; font-weight: 800; text-transform: uppercase; color: #991b1b; display: flex; align-items: center; gap: 6px;">
                                <i class="fas fa-triangle-exclamation"></i> Permanent Deactivation Disclosure
                            </h4>
                            <ul class="danger-bullets-list">
                                <li><i class="fas fa-ban"></i> <b>Immediate Freeze:</b> All stock counts & catalog
                                    products will be locked.</li>
                                <li><i class="fas fa-percent"></i> <b>Commissions:</b> Unpaid balances & commissions
                                    will be locked.</li>
                                <li><i class="fas fa-link"></i> <b>Store URL:</b> Your storefront link will be
                                    permanently unregistered.</li>
                            </ul>
                        </div>

                        <div class="form-item" style="margin-top: 5px;">
                            <label class="form-lbl text-dark-red"
                                style="font-weight: 750; font-size: 0.8rem; margin-bottom: 8px; display: block;">
                                Type <strong class="text-auth-auth"
                                    style="text-decoration: underline !important; color: #000; font-weight: 900;">DELETE</strong>
                                to authorize deactivation request:
                            </label>
                            <asp:TextBox ID="txtDeleteConfirm" runat="server" CssClass="prof-input input-danger-border"
                                placeholder="DELETE" style="text-align: center; font-weight: 800; letter-spacing: 1px;">
                            </asp:TextBox>
                        </div>

                        <div class="prof-submit-row settings-submit-row">
                            <asp:Button ID="btnRequestDelete" runat="server" Text="Request Deletion"
                                CssClass="prof-btn-danger" OnClick="btnRequestDelete_Click"
                                style="width: 100%; border-radius: 10px; font-weight: 800; padding: 12px;" />
                        </div>
                    </asp:Panel>

                    <!-- PAN B: PENDING AUDIT STATE (High Fidelity Pipeline) -->
                    <asp:Panel ID="pnlDeletePending" runat="server" Visible="false">
                        <div class="pending-flow-container">
                            <div class="pending-flow-header">
                                <div class="pending-status-pill">
                                    <span class="pulse-indicator-orange"></span> Audit Pending
                                </div>
                                <span class="pending-flow-time">Filed: <asp:Literal ID="litDeleteDate" runat="server">
                                    </asp:Literal></span>
                            </div>

                            <!-- Premium Timeline Pipeline -->
                            <div class="pflow-timeline">
                                <div class="pflow-step completed">
                                    <div class="pflow-dot"><i class="fas fa-file-signature"></i></div>
                                    <span class="pflow-lbl">Request Filed</span>
                                </div>
                                <div class="pflow-line active"></div>
                                <div class="pflow-step active">
                                    <div class="pflow-dot"><i class="fas fa-hourglass-half"></i></div>
                                    <span class="pflow-lbl">Admin Audit</span>
                                </div>
                                <div class="pflow-line"></div>
                                <div class="pflow-step">
                                    <div class="pflow-dot"><i class="fas fa-trash-can"></i></div>
                                    <span class="pflow-lbl">Deactivation</span>
                                </div>
                            </div>

                            <div class="info-note-box"
                                style="margin-top: 10px; font-size: 0.76rem; border-radius: 8px; padding: 10px 14px; border-left: 4px solid #3b82f6; display: flex; align-items: flex-start; gap: 8px;">
                                <i class="fas fa-circle-info"
                                    style="color: #2563eb; margin-top: 2px; flex-shrink:0;"></i>
                                <span>Your products remain active in the system until final admin clearance. You can
                                    cancel this request instantly below to restore normal shop operations.</span>
                            </div>
                        </div>

                        <div class="prof-submit-row settings-submit-row" style="margin-top: 15px;">
                            <asp:Button ID="btnCancelDelete" runat="server" Text="Restore Store & Cancel Deactivation"
                                CssClass="prof-btn-danger btn-green-save" OnClick="btnCancelDelete_Click"
                                style="width: 100%; border-radius: 10px; font-weight: 800; padding: 12px;" />
                        </div>
                    </asp:Panel>

                </div>
            </div>
        </asp:Panel>

        <!-- Modal D: Fulfilment Support Help Info -->
        <asp:Panel ID="pnlFulfilmentModal" runat="server" Visible="false" CssClass="modal-overlay">
            <div class="modal-card">
                <div class="modal-header">
                    <h3 class="modal-title">
                        <asp:Literal ID="litFulfilmentHeader" runat="server">Fulfilment Settings</asp:Literal>
                    </h3>
                    <asp:LinkButton ID="btnCloseFulfilment" runat="server" CssClass="modal-close-btn"
                        OnClick="btnCloseModal_Click" CausesValidation="false">
                        <i class="fas fa-xmark"></i>
                    </asp:LinkButton>
                </div>
                <div class="modal-body">
                    <div class="danger-note-box info-note-box">
                        <strong>Global Shipping Integration Policy:</strong>
                        <br />
                        Store fulfilment parameters, shipping rates, regional delivery boundaries, and buyer return
                        windows are managed at the **global merchant network tier** for standard customer protection.
                        <br /><br />
                        If your store sells custom merchandise requiring distinct dimensions or unique handling, please
                        file a support ticket or contact our merchant helpdesk to establish a custom class override.
                    </div>
                    <div class="prof-submit-row settings-submit-row">
                        <asp:Button ID="btnOkFulfilment" runat="server" Text="Understood"
                            CssClass="prof-btn-danger btn-accent-save" OnClick="btnCloseModal_Click"
                            CausesValidation="false" />
                    </div>
                </div>
            </div>
        </asp:Panel>

        <!-- Client-Side Password Eye Toggle Script -->
        <script type="text/javascript">
            function togglePasswordVisibility(btn) {
                const wrapper = btn.closest('.password-input-wrapper');
                if (!wrapper) return;
                const input = wrapper.querySelector('.password-toggle-input');
                const icon = btn.querySelector('i');
                if (!input || !icon) return;

                if (input.type === 'password') {
                    input.type = 'text';
                    icon.className = 'fas fa-eye';
                } else {
                    input.type = 'password';
                    icon.className = 'fas fa-eye-slash';
                }
            }
        </script>

    </asp:Content>