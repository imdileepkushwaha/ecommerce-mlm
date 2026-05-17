<%@ Page Title="Alerts & Integrations Setup" Language="C#" MasterPageFile="~/seller/Seller.Master"
    AutoEventWireup="true" CodeFile="CommunicationSettings.aspx.cs"
    Inherits="EcommerceWebsite.SellerCommunicationSettings" %>

    <asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">

    </asp:Content>

    <asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

        <asp:ScriptManager ID="smComm" runat="server"></asp:ScriptManager>

        <!-- MAIN UPDATABLE GATEWAY CONFIG CONTAINER -->
        <asp:UpdatePanel ID="upnlComm" runat="server" UpdateMode="Conditional">
            <ContentTemplate>

                <!-- 1. PORTAL HEADER -->
                <div class="page-action-bar earn-header">
                    <div class="welcome-title earn-welcome-title">
                        <h1><i class="fas fa-satellite-dish"></i> Alerts & Integrations</h1>
                        <p>Verify SMS credentials, configure SMTP mail endpoints, and hook up WhatsApp Business sandbox
                            gateways.</p>
                    </div>
                    <div class="action-btn-grp earn-action-btn-grp">
                        <a href="Settings.aspx#zone6" class="btn-action earn-nav-btn"><i class="fas fa-arrow-left"></i>
                            Back to Settings</a>
                    </div>
                </div>

                <!-- DYNAMIC AJAX NOTIFICATION ALERTS -->
                <asp:Label ID="lblMsg" runat="server" Visible="false" CssClass="earn-global-alert"
                    style="margin-bottom: 20px;"></asp:Label>

                <!-- 2. CHANNEL SELECTOR TAB BAR -->
                <div class="comm-tab-bar">
                    <asp:LinkButton ID="tabEmail" runat="server" CssClass="comm-tab-btn" OnClick="tabChannel_Click"
                        CommandArgument="email">
                        <i class="fas fa-envelope"></i> Email SMTP
                    </asp:LinkButton>
                    <asp:LinkButton ID="tabWhatsapp" runat="server" CssClass="comm-tab-btn" OnClick="tabChannel_Click"
                        CommandArgument="whatsapp">
                        <i class="fab fa-whatsapp"></i> WhatsApp Business
                    </asp:LinkButton>
                    <asp:LinkButton ID="tabSms" runat="server" CssClass="comm-tab-btn" OnClick="tabChannel_Click"
                        CommandArgument="sms">
                        <i class="fas fa-comment-sms"></i> Mobile SMS Gateway
                    </asp:LinkButton>
                </div>

                <!-- 3. CONFIGURATION FORMS BOX -->
                <div class="prod-card earn-panel" style="padding: 30px;">

                    <!-- SECTION A: EMAIL PARAMETERS FOR SMTP -->
                    <asp:PlaceHolder ID="phEmailChannel" runat="server" Visible="true">
                        <div class="earn-title-group" style="margin-bottom: 25px;">
                            <h3>Email SMTP Gateway Configuration</h3>
                            <p>Enter server details to dispatch transactional receipts, customer invoices, and stock
                                warnings.</p>
                        </div>

                        <div class="comm-form-grid">
                            <div class="comm-form-grp">
                                <label class="form-lbl">SMTP Server Host</label>
                                <asp:TextBox ID="txtSmtpHost" runat="server" CssClass="prof-input"
                                    placeholder="smtp.gmail.com"></asp:TextBox>
                            </div>
                            <div class="comm-form-grp">
                                <label class="form-lbl">SMTP Server Port</label>
                                <asp:TextBox ID="txtSmtpPort" runat="server" CssClass="prof-input" placeholder="587">
                                </asp:TextBox>
                            </div>
                            <div class="comm-form-grp">
                                <label class="form-lbl">Sender Mail ID / Username</label>
                                <asp:TextBox ID="txtSmtpUser" runat="server" CssClass="prof-input"
                                    placeholder="notifications@yourdomain.com"></asp:TextBox>
                            </div>
                            <div class="comm-form-grp">
                                <label class="form-lbl">Mail Password</label>
                                <div class="password-input-wrapper" style="position: relative;">
                                    <asp:TextBox ID="txtSmtpPass" runat="server"
                                        CssClass="prof-input password-toggle-input" TextMode="Password"
                                        placeholder="••••••••"></asp:TextBox>
                                    <span class="password-toggle-eye" onclick="toggleLocalPassword(this)"
                                        style="position: absolute; right: 14px; top: 50%; transform: translateY(-50%); cursor: pointer; color: #94a3b8;">
                                        <i class="fas fa-eye-slash"></i>
                                    </span>
                                </div>
                            </div>
                            <div class="comm-form-grp" style="justify-content: center; padding-top: 15px;">
                                <label class="form-lbl"
                                    style="display: flex; align-items: center; gap: 8px; cursor: pointer;">
                                    <asp:CheckBox ID="chkSmtpSsl" runat="server" Checked="true" /> Enable TLS/SSL
                                    Authorization
                                </label>
                            </div>
                            <div class="comm-form-grp comm-form-grp-full">
                                <label class="form-lbl">Mail Footer Signature</label>
                                <asp:TextBox ID="txtEmailSignature" runat="server" CssClass="prof-input"
                                    TextMode="MultiLine" Rows="3" placeholder="Regards, Team Shop Portal"></asp:TextBox>
                            </div>
                        </div>

                        <div class="prof-submit-row settings-submit-row"
                            style="border-top: 1px solid var(--border-c); padding-top: 20px; margin-top: 15px;">
                            <asp:Button ID="btnSaveEmail" runat="server" Text="Save SMTP Configuration"
                                CssClass="prof-btn-danger btn-accent-save" OnClick="btnSaveEmail_Click"
                                style="font-weight: 800; border-radius: 8px;" />
                        </div>

                        <!-- LIVE SMTP BROADCAST TESTING DECK -->
                        <div class="comm-gateway-card">
                            <div class="comm-gateway-title"><i class="fas fa-flask"></i> Live SMTP Mail Dispatcher Test
                            </div>
                            <p class="comm-lbl-desc" style="margin-bottom: 15px;">Simulate SMTP pathway verification
                                instantly. Sends a dummy welcome dispatch to confirm routing values.</p>
                            <div class="comm-form-grid"
                                style="grid-template-columns: 1fr auto; align-items: center; gap: 15px;">
                                <asp:TextBox ID="txtTestEmail" runat="server" CssClass="prof-input"
                                    placeholder="recipient@example.com"></asp:TextBox>
                                <asp:Button ID="btnTestEmail" runat="server" Text="Verify SMTP Connection"
                                    CssClass="earn-btn-submit" OnClick="btnTestEmail_Click"
                                    style="height: 38px; border-radius: 8px; font-weight:700;" />
                            </div>
                        </div>
                    </asp:PlaceHolder>

                    <!-- SECTION B: WHATSAPP BUSINESS GATEWAY CONFIG -->
                    <asp:PlaceHolder ID="phWhatsappChannel" runat="server" Visible="false">
                        <div class="earn-title-group" style="margin-bottom: 25px;">
                            <h3>WhatsApp Cloud Business API Configuration</h3>
                            <p>Link your Meta WhatsApp Business API credential key sets to alert customers directly via
                                WA.</p>
                        </div>

                        <div class="comm-form-grid">
                            <div class="comm-form-grp comm-form-grp-full">
                                <label class="form-lbl">API Graph Endpoint URL</label>
                                <asp:TextBox ID="txtWaEndpoint" runat="server" CssClass="prof-input"
                                    placeholder="https://graph.facebook.com/v19.0/phone-number-id/messages">
                                </asp:TextBox>
                            </div>
                            <div class="comm-form-grp">
                                <label class="form-lbl">Temporary / Permanent Bearer Token</label>
                                <div class="password-input-wrapper" style="position: relative;">
                                    <asp:TextBox ID="txtWaToken" runat="server"
                                        CssClass="prof-input password-toggle-input" TextMode="Password"
                                        placeholder="EAAGxxxxxxxxxxxxxxx"></asp:TextBox>
                                    <span class="password-toggle-eye" onclick="toggleLocalPassword(this)"
                                        style="position: absolute; right: 14px; top: 50%; transform: translateY(-50%); cursor: pointer; color: #94a3b8;">
                                        <i class="fas fa-eye-slash"></i>
                                    </span>
                                </div>
                            </div>
                            <div class="comm-form-grp">
                                <label class="form-lbl">Verified Sender WhatsApp Number</label>
                                <asp:TextBox ID="txtWaNumber" runat="server" CssClass="prof-input"
                                    placeholder="+919876543210"></asp:TextBox>
                            </div>
                            <div class="comm-form-grp" style="justify-content: center; padding-top: 15px;">
                                <label class="form-lbl"
                                    style="display: flex; align-items: center; gap: 8px; cursor: pointer;">
                                    <asp:CheckBox ID="chkWaSandbox" runat="server" Checked="true" /> Enable API Sandbox
                                    Mode
                                </label>
                            </div>
                        </div>

                        <div class="prof-submit-row settings-submit-row"
                            style="border-top: 1px solid var(--border-c); padding-top: 20px; margin-top: 15px;">
                            <asp:Button ID="btnSaveWa" runat="server" Text="Save WhatsApp Configuration"
                                CssClass="prof-btn-danger btn-accent-save" OnClick="btnSaveWa_Click"
                                style="font-weight: 800; border-radius: 8px;" />
                        </div>

                        <!-- WHATSAPP API GATEWAY TEST -->
                        <div class="comm-gateway-card"
                            style="background: rgba(16, 185, 129, 0.04); border-color: rgba(16, 185, 129, 0.25);">
                            <div class="comm-gateway-title" style="color: #10b981;"><i class="fab fa-whatsapp"></i> Live
                                Sandbox WA Dispatcher Test</div>
                            <p class="comm-lbl-desc" style="margin-bottom: 15px;">Sends a pre-formatted mock template
                                alert to the developer or merchant recipient handset to confirm hook integrity.</p>
                            <div class="comm-form-grid"
                                style="grid-template-columns: 1fr auto; align-items: center; gap: 15px;">
                                <asp:TextBox ID="txtTestWaPhone" runat="server" CssClass="prof-input"
                                    placeholder="+91 99999 88888"></asp:TextBox>
                                <asp:Button ID="btnTestWa" runat="server" Text="Trigger WhatsApp Sandbox Test"
                                    CssClass="earn-btn-submit" OnClick="btnTestWa_Click"
                                    style="height: 38px; border-radius: 8px; font-weight:700; background: linear-gradient(135deg, #10b981, #059669) !important; box-shadow: 0 4px 10px rgba(16,185,129,0.15) !important;" />
                            </div>
                        </div>
                    </asp:PlaceHolder>

                    <!-- SECTION C: MOBILE SMS GATEWAY CONFIG -->
                    <asp:PlaceHolder ID="phSmsChannel" runat="server" Visible="false">
                        <div class="earn-title-group" style="margin-bottom: 25px;">
                            <h3>Mobile SMS Gateway Configuration</h3>
                            <p>Configure SMS account integration parameters to dispatch security alerts and urgent order
                                notifications.</p>
                        </div>

                        <div class="comm-form-grid">
                            <div class="comm-form-grp">
                                <label class="form-lbl">SMS Account SID / API User</label>
                                <asp:TextBox ID="txtSmsSid" runat="server" CssClass="prof-input"
                                    placeholder="API-USER-ID"></asp:TextBox>
                            </div>
                            <div class="comm-form-grp">
                                <label class="form-lbl">SMS Auth Token / Secret Key</label>
                                <div class="password-input-wrapper" style="position: relative;">
                                    <asp:TextBox ID="txtSmsToken" runat="server"
                                        CssClass="prof-input password-toggle-input" TextMode="Password"
                                        placeholder="••••••••"></asp:TextBox>
                                    <span class="password-toggle-eye" onclick="toggleLocalPassword(this)"
                                        style="position: absolute; right: 14px; top: 50%; transform: translateY(-50%); cursor: pointer; color: #94a3b8;">
                                        <i class="fas fa-eye-slash"></i>
                                    </span>
                                </div>
                            </div>
                            <div class="comm-form-grp">
                                <label class="form-lbl">SMS Sender Number / Sender ID</label>
                                <asp:TextBox ID="txtSmsSender" runat="server" CssClass="prof-input"
                                    placeholder="SENDER-ID"></asp:TextBox>
                            </div>
                        </div>

                        <div class="prof-submit-row settings-submit-row"
                            style="border-top: 1px solid var(--border-c); padding-top: 20px; margin-top: 15px;">
                            <asp:Button ID="btnSaveSms" runat="server" Text="Save SMS Configuration"
                                CssClass="prof-btn-danger btn-accent-save" OnClick="btnSaveSms_Click"
                                style="font-weight: 800; border-radius: 8px;" />
                        </div>

                        <!-- LIVE BROADCAST TEST -->
                        <div class="comm-gateway-card"
                            style="background: rgba(245, 158, 11, 0.03); border-color: rgba(245, 158, 11, 0.2);">
                            <div class="comm-gateway-title" style="color: #f59e0b;"><i class="fas fa-comment-sms"></i>
                                Live Mobile SMS Dispatcher Test</div>
                            <p class="comm-lbl-desc" style="margin-bottom: 15px;">Simulate live carrier cellular message
                                broadcasts. Sends a mock alert verification string directly to a test handset.</p>
                            <div class="comm-form-grid"
                                style="grid-template-columns: 1fr auto; align-items: center; gap: 15px;">
                                <asp:TextBox ID="txtTestSmsPhone" runat="server" CssClass="prof-input"
                                    placeholder="+91 99999 88888"></asp:TextBox>
                                <asp:Button ID="btnTestSms" runat="server" Text="Trigger Mobile SMS Test"
                                    CssClass="earn-btn-submit" OnClick="btnTestSms_Click"
                                    style="height: 38px; border-radius: 8px; font-weight:700; background: linear-gradient(135deg, #f59e0b, #d97706) !important; box-shadow: 0 4px 10px rgba(245,158,11,0.15) !important;" />
                            </div>
                        </div>
                    </asp:PlaceHolder>

                </div>

            </ContentTemplate>
        </asp:UpdatePanel>

        <!-- Dynamic password toggler -->
        <script type="text/javascript">
            function toggleLocalPassword(btn) {
                var wrapper = btn.closest('.password-input-wrapper');
                if (!wrapper) return;
                var input = wrapper.querySelector('.password-toggle-input');
                var icon = btn.querySelector('i');
                if (!input || !icon) return;

                if (input.type === 'password') {
                    input.type = 'text';
                    icon.className = 'fas fa-eye';
                } else {
                    input.type = 'password';
                    icon.className = 'fas fa-eye-slash';
                }
            }

            // Auto-scroll active communication tab into horizontal center on mobile viewports
            function scrollActiveTabIntoView() {
                var activeTab = document.querySelector(".comm-tab-btn.active");
                if (activeTab) {
                    activeTab.scrollIntoView({ behavior: 'smooth', block: 'nearest', inline: 'center' });
                }
            }

            // Run on initial page load
            document.addEventListener("DOMContentLoaded", function () {
                setTimeout(scrollActiveTabIntoView, 150);
            });

            // Run after every partial AJAX UpdatePanel refresh
            if (typeof Sys !== 'undefined' && Sys.WebForms && Sys.WebForms.PageRequestManager) {
                Sys.WebForms.PageRequestManager.getInstance().add_endRequest(function () {
                    setTimeout(scrollActiveTabIntoView, 100);
                });
            }
        </script>

    </asp:Content>