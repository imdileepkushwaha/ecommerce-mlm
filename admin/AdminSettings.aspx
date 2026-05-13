<%@ Page Title="System Configurations" Language="C#" MasterPageFile="~/admin/Admin.Master" AutoEventWireup="true" CodeFile="AdminSettings.aspx.cs" Inherits="ecommerce_mlm.admin.AdminSettings" %>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    
    <!-- Persist Active Tab across server PostBacks -->
    <asp:HiddenField ID="hfActiveTab" runat="server" ClientIDMode="Static" Value="tab-platform" />

    <!-- HEADER SECTION -->
    <div class="u-mb-30 u-d-flex u-j-between u-a-center">
        <div>
            <h1 class="u-txt-lg">Platform Orchestration</h1>
            <p class="u-txt-subtitle u-mt-5">Calibrate operational constants, regulate parameters and govern credentials through vertical gateways.</p>
        </div>
    </div>

    <!-- ALERT AREA -->
    <asp:Panel ID="pnlMsg" runat="server" Visible="false" CssClass="u-mb-20" style="border-radius:15px; padding:15px 20px; font-weight:600;">
        <div class="u-d-flex u-a-center">
            <i class="fas fa-info-circle u-mr-10"></i>
            <asp:Label ID="lblMsg" runat="server"></asp:Label>
        </div>
    </asp:Panel>

    <!-- VERTICAL TAB SYSTEM -->
    <div class="u-v-tab-layout">
        
        <!-- Left Side Vert Nav Anchors -->
        <div class="u-v-tab-nav">
            <button type="button" class="u-v-tab-btn active" onclick="switchTab('tab-platform')" id="btn-tab-platform">
                <i class="fas fa-sliders-h" style="color:#f97316;"></i> System Parameters
            </button>
            <button type="button" class="u-v-tab-btn" onclick="switchTab('tab-mlm')" id="btn-tab-mlm">
                <i class="fas fa-network-wired" style="color:#3b82f6;"></i> MLM Plan Settings
            </button>
            <button type="button" class="u-v-tab-btn" onclick="switchTab('tab-charges')" id="btn-tab-charges">
                <i class="fas fa-receipt" style="color:#a855f7;"></i> Store Charges
            </button>
            <button type="button" class="u-v-tab-btn" onclick="switchTab('tab-pg')" id="btn-tab-pg">
                <i class="fas fa-credit-card" style="color:#f43f5e;"></i> Payment Gateway
            </button>
            <button type="button" class="u-v-tab-btn" onclick="switchTab('tab-smtp')" id="btn-tab-smtp">
                <i class="fas fa-envelope-open-text" style="color:#0ea5e9;"></i> SMTP Mail Settings
            </button>
            <button type="button" class="u-v-tab-btn" onclick="switchTab('tab-sms')" id="btn-tab-sms">
                <i class="fas fa-sms" style="color:#ec4899;"></i> SMS Gateway
            </button>
            <button type="button" class="u-v-tab-btn" onclick="switchTab('tab-wa')" id="btn-tab-wa">
                <i class="fab fa-whatsapp" style="color:#25d366;"></i> WhatsApp API
            </button>
            <button type="button" class="u-v-tab-btn" onclick="switchTab('tab-profile')" id="btn-tab-profile">
                <i class="fas fa-user-cog" style="color:#6366f1;"></i> Identity Profile
            </button>
            <button type="button" class="u-v-tab-btn" onclick="switchTab('tab-security')" id="btn-tab-security">
                <i class="fas fa-key" style="color:#10b981;"></i> Change Password
            </button>
        </div>

        <!-- Right Side Dynamic Views -->
        <div class="u-v-tab-content">

            <!-- PANEL 1: CORE PLATFORM CONFIG -->
            <div class="u-tab-panel active" id="tab-platform">
                <div class="table-card settings-card">
                    <div class="settings-card-header">
                        <h3 class="settings-card-title">Global Environment Variables</h3>
                    </div>
                    <div class="u-form-layout u-d-flex u-direction-col u-gap-15">
                        <div class="form-grp">
                            <label class="settings-label">Site Title Vector</label>
                            <asp:TextBox ID="txtSiteName" runat="server" CssClass="u-input-field"></asp:TextBox>
                        </div>
                        <div class="form-grp">
                            <label class="settings-label">Base Payout Threshold (₹)</label>
                            <asp:TextBox ID="txtMinPayout" runat="server" TextMode="Number" CssClass="u-input-field"></asp:TextBox>
                        </div>
                        <div class="form-grp">
                            <label class="settings-label">Global Support Node (Email)</label>
                            <asp:TextBox ID="txtSupportEmail" runat="server" CssClass="u-input-field"></asp:TextBox>
                        </div>
                        <div class="form-grp">
                            <label class="settings-label">Emergency Mode</label>
                            <asp:DropDownList ID="ddlMaintenance" runat="server" CssClass="u-input-field">
                                <asp:ListItem Value="FALSE">Normal Operational State</asp:ListItem>
                                <asp:ListItem Value="TRUE">Under System Maintenance</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <div class="u-mt-10">
                            <asp:Button ID="btnSavePlatform" runat="server" CssClass="btn-primary u-w-full" Text="Apply Platform Configurations" OnClick="btnSavePlatform_Click" OnClientClick="setTabPersistence('tab-platform')" style="height:42px;"></asp:Button>
                        </div>
                    </div>
                </div>
            </div>

            <!-- PANEL 2: MLM PLAN & PAYOUT SETTINGS -->
            <div class="u-tab-panel" id="tab-mlm">
                <div class="table-card settings-card">
                    <div class="settings-card-header">
                        <h3 class="settings-card-title">MLM Commission & Fiscal Thresholds</h3>
                    </div>
                    <div class="u-form-layout u-d-flex u-direction-col u-gap-15">
                        
                        <!-- SECTION A: COMMISSIONS -->
                        <div style="font-size: 14px; font-weight: 700; color: #3b82f6; text-transform: uppercase; border-bottom: 1px dashed #e2e8f0; padding-bottom: 5px; margin-bottom: 5px;">
                            <i class="fas fa-project-diagram u-mr-5"></i> Commission Structure
                        </div>

                        <div class="form-grp">
                            <label class="settings-label">Direct Referral Bonus (%)</label>
                            <asp:TextBox ID="txtMlmDirect" runat="server" TextMode="Number" CssClass="u-input-field"></asp:TextBox>
                        </div>
                        <div class="form-grp">
                            <label class="settings-label">Level 1 Team Sales (%)</label>
                            <asp:TextBox ID="txtMlmL1" runat="server" TextMode="Number" CssClass="u-input-field"></asp:TextBox>
                        </div>
                        <div class="form-grp">
                            <label class="settings-label">Level 2 Team Sales (%)</label>
                            <asp:TextBox ID="txtMlmL2" runat="server" TextMode="Number" CssClass="u-input-field"></asp:TextBox>
                        </div>
                        <div class="form-grp">
                            <label class="settings-label">Level 3 Team Sales (%)</label>
                            <asp:TextBox ID="txtMlmL3" runat="server" TextMode="Number" CssClass="u-input-field"></asp:TextBox>
                        </div>
                        <div class="form-grp">
                            <label class="settings-label">Activation Limit — Min. Purchase Amount (₹)</label>
                            <asp:TextBox ID="txtMlmMinAct" runat="server" TextMode="Number" CssClass="u-input-field"></asp:TextBox>
                            <small style="color: #64748b; font-size: 12px; display: block; margin-top: 4px;">Minimum order required to unlock wallet commission activations.</small>
                        </div>

                        <!-- SECTION B: DEDUCTIONS -->
                        <div style="font-size: 14px; font-weight: 700; color: #475569; text-transform: uppercase; border-bottom: 1px dashed #e2e8f0; padding-bottom: 5px; margin-top: 10px; margin-bottom: 5px;">
                            <i class="fas fa-file-invoice-dollar u-mr-5"></i> Withholding & Payout Caps
                        </div>

                        <div class="form-grp">
                            <label class="settings-label">TDS Deduction Rate (%)</label>
                            <asp:TextBox ID="txtPayoutTds" runat="server" TextMode="Number" CssClass="u-input-field"></asp:TextBox>
                        </div>
                        <div class="form-grp">
                            <label class="settings-label">Company Processing / Admin Fee (%)</label>
                            <asp:TextBox ID="txtPayoutAdminFee" runat="server" TextMode="Number" CssClass="u-input-field"></asp:TextBox>
                        </div>
                        <div class="form-grp">
                            <label class="settings-label">Minimum Wallet Payout Limit (₹)</label>
                            <asp:TextBox ID="txtPayoutMinLimit" runat="server" TextMode="Number" CssClass="u-input-field"></asp:TextBox>
                        </div>

                        <div class="u-mt-10">
                            <asp:Button ID="btnSaveMlm" runat="server" CssClass="btn-primary u-w-full" Text="Enforce MLM Commission Metrics" OnClick="btnSaveMlm_Click" OnClientClick="setTabPersistence('tab-mlm')" style="height:42px; background:#3b82f6; border-color:#3b82f6;"></asp:Button>
                        </div>
                    </div>
                </div>
            </div>

            <!-- PANEL 3: STORE CHARGES -->
            <div class="u-tab-panel" id="tab-charges">
                <div class="table-card settings-card">
                    <div class="settings-card-header">
                        <h3 class="settings-card-title">Transaction Logic & Freight Logic</h3>
                    </div>
                    <div class="u-form-layout u-d-flex u-direction-col u-gap-15">
                        <div class="form-grp">
                            <label class="settings-label">Platform fee (₹ / order)</label>
                            <asp:TextBox ID="txtPlatformFee" runat="server" TextMode="Number" CssClass="u-input-field"></asp:TextBox>
                        </div>
                        <div class="form-grp">
                            <label class="settings-label">Admin cut on seller sales (%)</label>
                            <asp:TextBox ID="txtAdminCommission" runat="server" TextMode="Number" CssClass="u-input-field"></asp:TextBox>
                        </div>
                        <div class="form-grp">
                            <label class="settings-label">Free shipping — min. cart (₹)</label>
                            <asp:TextBox ID="txtMinFreeShipping" runat="server" TextMode="Number" CssClass="u-input-field"></asp:TextBox>
                        </div>
                        <div class="form-grp">
                            <label class="settings-label">Below minimum — shipping fee (₹)</label>
                            <asp:TextBox ID="txtShippingFee" runat="server" TextMode="Number" CssClass="u-input-field"></asp:TextBox>
                        </div>
                        <div class="u-mt-10">
                            <asp:Button ID="btnSaveCharges" runat="server" CssClass="btn-primary u-w-full" Text="Enforce Transaction Charges" OnClick="btnSaveCharges_Click" OnClientClick="setTabPersistence('tab-charges')" style="height:42px; background:#a855f7; border-color:#a855f7;"></asp:Button>
                        </div>
                    </div>
                </div>
            </div>

            <!-- PANEL 4: PAYMENT GATEWAY -->
            <div class="u-tab-panel" id="tab-pg">
                <div class="table-card settings-card">
                    <div class="settings-card-header">
                        <h3 class="settings-card-title">Financial Procurement (Payment Gateway Settings)</h3>
                    </div>
                    <div class="u-form-layout u-d-flex u-direction-col u-gap-15">
                        <div class="form-grp">
                            <label class="settings-label">Active Payment Operator</label>
                            <asp:DropDownList ID="ddlPgProvider" runat="server" CssClass="u-input-field">
                                <asp:ListItem Value="Razorpay">Razorpay (Recommended)</asp:ListItem>
                                <asp:ListItem Value="PhonePe">PhonePe</asp:ListItem>
                                <asp:ListItem Value="Cashfree">Cashfree Payments</asp:ListItem>
                                <asp:ListItem Value="Paytm">Paytm Business</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <div class="form-grp">
                            <label class="settings-label">Gateway Environment Mode</label>
                            <asp:DropDownList ID="ddlPgEnv" runat="server" CssClass="u-input-field" style="border-color: #f43f5e; background: #fff5f5;">
                                <asp:ListItem Value="TEST">TEST / SANDBOX Mode (Dry Run)</asp:ListItem>
                                <asp:ListItem Value="LIVE">LIVE / PRODUCTION Mode (Real Funds)</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <div class="form-grp">
                            <label class="settings-label">Merchant ID (Optional)</label>
                            <asp:TextBox ID="txtPgMerchantId" runat="server" placeholder="Required for PhonePe/Cashfree" CssClass="u-input-field"></asp:TextBox>
                        </div>
                        <div class="form-grp">
                            <label class="settings-label">API / Public Key (Key ID)</label>
                            <asp:TextBox ID="txtPgKeyId" runat="server" placeholder="e.g., rzp_test_..." CssClass="u-input-field"></asp:TextBox>
                        </div>
                        <div class="form-grp">
                            <label class="settings-label">API Secret / Salt Key (Key Secret)</label>
                            <asp:TextBox ID="txtPgKeySecret" runat="server" TextMode="Password" placeholder="Enter Gateway Secret Pass-Phrase" CssClass="u-input-field"></asp:TextBox>
                        </div>
                        <div class="u-mt-10">
                            <asp:Button ID="btnSavePg" runat="server" CssClass="btn-primary u-w-full" Text="Apply Financial Gateway Logic" OnClick="btnSavePg_Click" OnClientClick="setTabPersistence('tab-pg')" style="height:42px; background:#f43f5e; border-color:#f43f5e;"></asp:Button>
                        </div>
                    </div>
                </div>
            </div>

            <!-- PANEL 5: SMTP SETTINGS -->
            <div class="u-tab-panel" id="tab-smtp">
                <div class="table-card settings-card">
                    <div class="settings-card-header">
                        <h3 class="settings-card-title">Communications Vector (SMTP Matrix)</h3>
                    </div>
                    <div class="u-form-layout u-d-flex u-direction-col u-gap-15">
                        <div class="form-grp">
                            <label class="settings-label">Outgoing SMTP Server</label>
                            <asp:TextBox ID="txtSmtpHost" runat="server" placeholder="e.g., smtp.gmail.com" CssClass="u-input-field"></asp:TextBox>
                        </div>
                        <div class="form-grp">
                            <label class="settings-label">Server Transport Port</label>
                            <asp:TextBox ID="txtSmtpPort" runat="server" TextMode="Number" placeholder="e.g., 587" CssClass="u-input-field"></asp:TextBox>
                        </div>
                        <div class="form-grp">
                            <label class="settings-label">Registered Sender Mail</label>
                            <asp:TextBox ID="txtSmtpFrom" runat="server" placeholder="e.g., sender@yourdomain.com" CssClass="u-input-field"></asp:TextBox>
                        </div>
                        <div class="form-grp">
                            <label class="settings-label">Security Pass-Code / App Password</label>
                            <asp:TextBox ID="txtSmtpPass" runat="server" TextMode="Password" placeholder="••••••••••••••••" CssClass="u-input-field"></asp:TextBox>
                        </div>
                        <div class="form-grp">
                            <label class="settings-label">Secure Sockets (SSL/TLS)</label>
                            <asp:DropDownList ID="ddlSmtpSsl" runat="server" CssClass="u-input-field">
                                <asp:ListItem Value="TRUE">Enabled (Recommended)</asp:ListItem>
                                <asp:ListItem Value="FALSE">Disabled</asp:ListItem>
                            </asp:DropDownList>
                        </div>
                        <div class="u-mt-10">
                            <asp:Button ID="btnSaveSmtp" runat="server" CssClass="btn-primary u-w-full" Text="Lock Mail Server Credentials" OnClick="btnSaveSmtp_Click" OnClientClick="setTabPersistence('tab-smtp')" style="height:42px; background:#0ea5e9; border-color:#0ea5e9;"></asp:Button>
                        </div>
                    </div>
                </div>
            </div>

            <!-- PANEL 6: SMS GATEWAY -->
            <div class="u-tab-panel" id="tab-sms">
                <div class="table-card settings-card">
                    <div class="settings-card-header">
                        <h3 class="settings-card-title">Text Messaging (SMS Gateway Engine)</h3>
                    </div>
                    <div class="u-form-layout u-d-flex u-direction-col u-gap-15">
                        <div class="form-grp">
                            <label class="settings-label">SMS Service Endpoint URL</label>
                            <asp:TextBox ID="txtSmsApiUrl" runat="server" placeholder="e.g., https://api.smsgateway.com/send" CssClass="u-input-field"></asp:TextBox>
                        </div>
                        <div class="form-grp">
                            <label class="settings-label">Gateway Authorization Key / API Key</label>
                            <asp:TextBox ID="txtSmsApiKey" runat="server" TextMode="Password" placeholder="Enter Auth API Key" CssClass="u-input-field"></asp:TextBox>
                        </div>
                        <div class="form-grp">
                            <label class="settings-label">Designated Sender Header / ID</label>
                            <asp:TextBox ID="txtSmsSenderId" runat="server" placeholder="e.g., KRTPHY" MaxLength="6" CssClass="u-input-field"></asp:TextBox>
                        </div>
                        <div class="u-mt-10">
                            <asp:Button ID="btnSaveSms" runat="server" CssClass="btn-primary u-w-full" Text="Bind SMS Gateway Keys" OnClick="btnSaveSms_Click" OnClientClick="setTabPersistence('tab-sms')" style="height:42px; background:#ec4899; border-color:#ec4899;"></asp:Button>
                        </div>
                    </div>
                </div>
            </div>

            <!-- PANEL 7: WHATSAPP CLOUD API -->
            <div class="u-tab-panel" id="tab-wa">
                <div class="table-card settings-card">
                    <div class="settings-card-header">
                        <h3 class="settings-card-title">WhatsApp Business Integration (Cloud API)</h3>
                    </div>
                    <div class="u-form-layout u-d-flex u-direction-col u-gap-15">
                        <div class="form-grp">
                            <label class="settings-label">WhatsApp Graph URL Vector</label>
                            <asp:TextBox ID="txtWaApiUrl" runat="server" placeholder="https://graph.facebook.com/v17.0/" CssClass="u-input-field"></asp:TextBox>
                        </div>
                        <div class="form-grp">
                            <label class="settings-label">Phone Number ID</label>
                            <asp:TextBox ID="txtWaPhoneId" runat="server" placeholder="Enter Meta Phone Number ID" CssClass="u-input-field"></asp:TextBox>
                        </div>
                        <div class="form-grp">
                            <label class="settings-label">WhatsApp Business Account ID</label>
                            <asp:TextBox ID="txtWaBusinessAccountId" runat="server" placeholder="Enter Account ID" CssClass="u-input-field"></asp:TextBox>
                        </div>
                        <div class="form-grp">
                            <label class="settings-label">System User Permanent Access Token</label>
                            <asp:TextBox ID="txtWaAccessToken" runat="server" TextMode="Password" placeholder="EAAB..." CssClass="u-input-field"></asp:TextBox>
                        </div>
                        <div class="u-mt-10">
                            <asp:Button ID="btnSaveWa" runat="server" CssClass="btn-primary u-w-full" Text="Activate WhatsApp Gateway" OnClick="btnSaveWa_Click" OnClientClick="setTabPersistence('tab-wa')" style="height:42px; background:#25d366; border-color:#25d366;"></asp:Button>
                        </div>
                    </div>
                </div>
            </div>

            <!-- PANEL 8: IDENTITY PORTRAIT -->
            <div class="u-tab-panel" id="tab-profile">
                <div class="table-card settings-card">
                    <div class="settings-card-header">
                        <h3 class="settings-card-title">Administrative Identity Assets</h3>
                    </div>
                    <div class="u-d-flex u-direction-col u-gap-15">
                        <div class="form-grp">
                            <label class="settings-label">Designated Alias</label>
                            <asp:TextBox ID="txtAdminName" runat="server" CssClass="u-input-field"></asp:TextBox>
                        </div>
                        <div class="form-grp">
                            <label class="settings-label">Registered Email Axis</label>
                            <asp:TextBox ID="txtAdminEmail" runat="server" CssClass="u-input-field"></asp:TextBox>
                        </div>
                        <div class="u-mt-10">
                            <asp:Button ID="btnSaveProfile" runat="server" CssClass="btn-primary btn-settings-indigo u-w-full" Text="Update Portrait Identity" OnClick="btnSaveProfile_Click" OnClientClick="setTabPersistence('tab-profile')" style="height:42px;"></asp:Button>
                        </div>
                    </div>
                </div>
            </div>

            <!-- PANEL 9: SECURITY MATRIX (Change Password) -->
            <div class="u-tab-panel" id="tab-security">
                <div class="table-card settings-card">
                    <div class="settings-card-header">
                        <h3 class="settings-card-title">Change Security Password</h3>
                    </div>
                    <div class="u-d-flex u-direction-col u-gap-15">
                        <div class="form-grp">
                            <label class="settings-label">Current Password</label>
                            <asp:TextBox ID="txtOldPass" runat="server" TextMode="Password" placeholder="Enter current password" CssClass="u-input-field"></asp:TextBox>
                        </div>
                        <div class="form-grp">
                            <label class="settings-label">New Password</label>
                            <asp:TextBox ID="txtNewPass" runat="server" TextMode="Password" placeholder="Enter new password" CssClass="u-input-field"></asp:TextBox>
                        </div>
                        <div class="form-grp">
                            <label class="settings-label">Confirm New Password</label>
                            <asp:TextBox ID="txtConfirmPass" runat="server" TextMode="Password" placeholder="Confirm new password" CssClass="u-input-field"></asp:TextBox>
                        </div>
                        <div class="u-mt-10">
                            <asp:Button ID="btnUpdatePassword" runat="server" CssClass="btn-primary btn-settings-green u-w-full" Text="Update Access Password" OnClick="btnUpdatePassword_Click" OnClientClick="setTabPersistence('tab-security')" style="height:42px;"></asp:Button>
                        </div>
                    </div>
                </div>
            </div>

        </div>
    </div>

    <!-- TAB PERSISTENCE ENGINE SCRIPTS -->
    <script type="text/javascript">
        function switchTab(tabId) {
            // 1. Hide all panels and inactive all buttons
            document.querySelectorAll('.u-tab-panel').forEach(el => el.classList.remove('active'));
            document.querySelectorAll('.u-v-tab-btn').forEach(el => el.classList.remove('active'));

            // 2. Show target panel and active target button
            const activePanel = document.getElementById(tabId);
            const activeBtn = document.getElementById('btn-' + tabId);
            if (activePanel) activePanel.classList.add('active');
            if (activeBtn) activeBtn.classList.add('active');

            // 3. Store state in persistent hidden field
            document.getElementById('hfActiveTab').value = tabId;
        }

        function setTabPersistence(tabId) {
            document.getElementById('hfActiveTab').value = tabId;
        }

        // Run on initial load to load from stored memory state (post-save/reload)
        document.addEventListener('DOMContentLoaded', function () {
            const storedTab = document.getElementById('hfActiveTab').value;
            if (storedTab) {
                switchTab(storedTab);
            }
        });
    </script>

</asp:Content>
