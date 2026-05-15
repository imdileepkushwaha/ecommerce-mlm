<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Login.aspx.cs" Inherits="EcommerceWebsite.SellerLogin"
    EnableViewStateMac="false" EnableEventValidation="false" ViewStateEncryptionMode="Never" %>
    <!DOCTYPE html>
    <html lang="en">

    <head runat="server">
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <title>Seller Login</title>
        <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700;800&display=swap" rel="stylesheet" />
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" />
        <link rel="stylesheet" href="assets/css/seller.css" />

    </head>

    <body class="seller-auth-body">
        <form id="form1" runat="server">
            <div class="seller-auth-wrap">
                <div class="seller-auth-grid">
                    <div class="seller-auth-showcase">
                        <h2>Sell smarter on MLM</h2>
                        <p>Empowering sellers with elite tools to manage products, pricing, and orders with unparalleled
                            efficiency.</p>
                        <ul class="seller-points">
                            <li>
                                <svg width="20" height="20" viewBox="0 0 24 24">
                                    <path fill="currentColor"
                                        d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10s10-4.48 10-10S17.52 2 12 2m-2 15l-5-5l1.41-1.41L10 14.17l7.59-7.59L19 8z">
                                    </path>
                                </svg>
                                <span>Advanced Product Catalog Management</span>
                            </li>
                            <li>
                                <svg width="20" height="20" viewBox="0 0 24 24">
                                    <path fill="currentColor"
                                        d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10s10-4.48 10-10S17.52 2 12 2m-2 15l-5-5l1.41-1.41L10 14.17l7.59-7.59L19 8z">
                                    </path>
                                </svg>
                                <span>Verified Review & Trust Moderation</span>
                            </li>
                            <li>
                                <svg width="20" height="20" viewBox="0 0 24 24">
                                    <path fill="currentColor"
                                        d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10s10-4.48 10-10S17.52 2 12 2m-2 15l-5-5l1.41-1.41L10 14.17l7.59-7.59L19 8z">
                                    </path>
                                </svg>
                                <span>Real-time Seller Insights & Growth</span>
                            </li>
                        </ul>
                    </div>
                    <div class="seller-auth-card">
                        <div class="seller-auth-kicker">SELLER PORTAL</div>
                        <h3>Welcome back</h3>
                        <p class="seller-auth-sub">Enter your credentials to access your dashboard.</p>
                        <asp:Label ID="lblMsg" runat="server"
                            CssClass="alert alert-danger d-block py-2 mb-3 rounded-3 small" Visible="false" />

                        <div class="mb-1">
                            <label class="seller-field-label">Email address</label>
                            <div class="seller-input-wrap">
                                <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" TextMode="Email"
                                    placeholder="you@store.com" />
                                <svg width="18" height="18" viewBox="0 0 24 24">
                                    <path fill="currentColor"
                                        d="M22 6c0-1.1-.9-2-2-2H4c-1.1 0-2 .9-2 2v12c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V6m-2 0l-8 5l-8-5h16m0 12H4V8l8 5l8-5v10z">
                                    </path>
                                </svg>
                            </div>
                        </div>

                        <div class="mb-1">
                            <label class="seller-field-label">Password</label>
                            <div class="seller-input-wrap">
                                <asp:TextBox ID="txtPassword" runat="server"
                                    CssClass="form-control password-with-toggle" TextMode="Password"
                                    placeholder="Enter password" />
                                <svg width="18" height="18" viewBox="0 0 24 24">
                                    <path fill="currentColor"
                                        d="M12 17a2 2 0 0 0 2-2a2 2 0 0 0-2-2a2 2 0 0 0-2 2a2 2 0 0 0 2 2m6-9a2 2 0 0 1 2 2v10a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V10a2 2 0 0 1 2-2h1V7a5 5 0 0 1 5-5a5 5 0 0 1 5 5v1h1m-6-4a3 3 0 0 0-3 3v1h6V7a3 3 0 0 0-3-3z">
                                    </path>
                                </svg>
                                <button type="button" class="password-toggle-btn" id="loginPasswordToggle"
                                    aria-label="Show password">
                                    <svg width="18" height="18" viewBox="0 0 24 24" id="eyeIcon">
                                        <path fill="currentColor"
                                            d="M12 9a3 3 0 0 0-3 3a3 3 0 0 0 3 3a3 3 0 0 0 3-3a3 3 0 0 0-3-3m0 8a5 5 0 0 1-5-5a5 5 0 0 1 5-5a5 5 0 0 1 5 5a5 5 0 0 1-5 5m0-12.5C7 4.5 2.73 7.61 1 12c1.73 4.39 6 7.5 11 7.5s9.27-3.11 11-7.5c-1.73-4.39-6-7.5-11-7.5z">
                                        </path>
                                    </svg>
                                </button>
                            </div>
                        </div>
                        
                        <!-- CAPTCHA SECURITY MATRIX -->
                        <div class="mb-1">
                            <label class="seller-field-label">Verify Security Code</label>
                            <div class="captcha-matrix">
                                <div class="captcha-visual-box">
                                    <img id="captchaImg" src="../Captcha.ashx" alt="Captcha Vector" />
                                </div>
                                <button type="button" class="captcha-refresh-btn" onclick="refreshCaptcha()" aria-label="Reload Code" title="Reload verification code">
                                    <svg width="20" height="20" viewBox="0 0 24 24">
                                        <path fill="currentColor" d="M17.65 6.35A7.958 7.958 0 0 0 12 4a8 8 0 1 0 8 8h-2a6 6 0 1 1-6-6c1.66 0 3.14.69 4.22 1.78L13 11h7V4l-2.35 2.35z"/>
                                    </svg>
                                </button>
                                <div class="seller-input-wrap" style="margin-bottom: 0; flex: 1;">
                                    <asp:TextBox ID="txtCaptcha" runat="server" CssClass="form-control" placeholder="Type code..." style="padding-left: 18px;" MaxLength="6" autocomplete="off"></asp:TextBox>
                                </div>
                            </div>
                        </div>

                        <asp:Button ID="btnLogin" runat="server" CssClass="seller-login-btn" Text="Sign In to Dashboard"
                            OnClick="btnLogin_Click" />

                        <div class="seller-links">
                            <a href="Signup.aspx">Create Seller Account</a>
                            <a href="#" id="forgotPasswordTrigger">Forgot password?</a>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Simplified Modal Structure for forgot password -->
            <div id="forgotPasswordModal"
                class='seller-modal-backdrop <%= IsForgotModalOpen ? "show" : string.Empty %>'>
                <div class="seller-modal-card">
                    <div class="seller-modal-head">
                        <h4 class="seller-modal-title">Recover Password</h4>
                        <button type="button" class="seller-modal-close" id="forgotModalClose">
                            <svg width="20" height="20" viewBox="0 0 24 24">
                                <path fill="currentColor"
                                    d="M19 6.41L17.59 5L12 10.59L6.41 5L5 6.41L10.59 12L5 17.59L6.41 19L12 13.41L17.59 19L19 17.59L13.41 12L19 6.41z">
                                </path>
                            </svg>
                        </button>
                    </div>
                    <div class="seller-modal-body">
                        <p class="text-muted small mb-4">Follow the steps to securely reset your store access password.
                        </p>
                        <asp:Label ID="lblResetMsg" runat="server"
                            CssClass="alert alert-danger d-block py-2 mb-3 rounded-3 small" Visible="false" />

                        <div class="mb-3">
                            <label class="seller-field-label">Registered Email</label>
                            <div class="seller-input-wrap">
                                <asp:TextBox ID="txtResetEmail" runat="server" CssClass="form-control" TextMode="Email"
                                    placeholder="you@store.com" />
                                <svg width="18" height="18" viewBox="0 0 24 24">
                                    <path fill="currentColor"
                                        d="M22 6c0-1.1-.9-2-2-2H4c-1.1 0-2 .9-2 2v12c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V6m-2 0l-8 5l-8-5h16m0 12H4V8l8 5l8-5v10z">
                                    </path>
                                </svg>
                            </div>
                            <asp:Button ID="btnSendResetCode" runat="server"
                                CssClass="btn btn-outline-danger w-100 mt-2 rounded-3" Text="Send Verification Code"
                                OnClick="btnSendResetCode_Click" />
                        </div>

                        <div class="mb-3">
                            <label class="seller-field-label">Verification Code</label>
                            <div class="seller-input-wrap">
                                <asp:TextBox ID="txtResetCode" runat="server" CssClass="form-control" MaxLength="6"
                                    placeholder="Enter 6-digit code" />
                                <svg width="18" height="18" viewBox="0 0 24 24">
                                    <path fill="currentColor"
                                        d="M12 1L3 5v6c0 5.55 3.84 10.74 9 12c5.16-1.26 9-6.45 9-12V5l-9-4zm0 10.99h7c-.53 4.12-3.28 7.79-7 8.94V12H5V6.3l7-3.11v8.8z">
                                    </path>
                                </svg>
                            </div>
                            <asp:Button ID="btnVerifyResetCode" runat="server"
                                CssClass="btn btn-outline-success w-100 mt-2 rounded-3" Text="Verify Code"
                                OnClick="btnVerifyResetCode_Click" />
                        </div>

                        <asp:Panel ID="pnlResetPasswordFields" runat="server" Visible="false">
                            <div class="mb-3">
                                <label class="seller-field-label">New Password</label>
                                <div class="seller-input-wrap">
                                    <asp:TextBox ID="txtResetPassword" runat="server" CssClass="form-control"
                                        TextMode="Password" placeholder="Enter new password" />
                                    <svg width="18" height="18" viewBox="0 0 24 24">
                                        <path fill="currentColor"
                                            d="M12 17a2 2 0 0 0 2-2a2 2 0 0 0-2-2a2 2 0 0 0-2 2a2 2 0 0 0 2 2m6-9a2 2 0 0 1 2 2v10a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V10a2 2 0 0 1 2-2h1V7a5 5 0 0 1 5-5a5 5 0 0 1 5 5v1h1m-6-4a3 3 0 0 0-3 3v1h6V7a3 3 0 0 0-3-3z">
                                        </path>
                                    </svg>
                                </div>
                            </div>
                            <div class="mb-4">
                                <label class="seller-field-label">Confirm Password</label>
                                <div class="seller-input-wrap">
                                    <asp:TextBox ID="txtConfirmResetPassword" runat="server" CssClass="form-control"
                                        TextMode="Password" placeholder="Confirm new password" />
                                    <svg width="18" height="18" viewBox="0 0 24 24">
                                        <path fill="currentColor"
                                            d="M12 17a2 2 0 0 0 2-2a2 2 0 0 0-2-2a2 2 0 0 0-2 2a2 2 0 0 0 2 2m6-9a2 2 0 0 1 2 2v10a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2V10a2 2 0 0 1 2-2h1V7a5 5 0 0 1 5-5a5 5 0 0 1 5 5v1h1m-6-4a3 3 0 0 0-3 3v1h6V7a3 3 0 0 0-3-3z">
                                        </path>
                                    </svg>
                                </div>
                            </div>
                            <asp:Button ID="btnResetPassword" runat="server" CssClass="seller-login-btn mt-0"
                                Text="Update Password" OnClick="btnResetPassword_Click" />
                        </asp:Panel>
                    </div>
                </div>
            </div>
        </form>
        <script>
            (function () {
                var trigger = document.getElementById("forgotPasswordTrigger");
                var modal = document.getElementById("forgotPasswordModal");
                var closeBtn = document.getElementById("forgotModalClose");
                function openModal() { if (modal) modal.classList.add("show"); }
                function closeModal() { if (modal) modal.classList.remove("show"); }
                if (trigger) { trigger.addEventListener("click", function (e) { e.preventDefault(); openModal(); }); }
                if (closeBtn) closeBtn.addEventListener("click", closeModal);
                if (modal) { modal.addEventListener("click", function (e) { if (e.target === modal) closeModal(); }); }

                function setupPasswordToggle(inputId, buttonId) {
                    var input = document.getElementById(inputId);
                    var button = document.getElementById(buttonId);
                    if (!input || !button) return;
                    button.addEventListener("click", function () {
                        var show = input.type === "password";
                        input.type = show ? "text" : "password";
                        var svg = button.querySelector('svg');
                        if (show) {
                            svg.innerHTML = '<path fill="currentColor" d="M12 17.5c-3.8 0-7.2-2.1-8.8-5.5c1.6-3.4 5-5.5 8.8-5.5s7.2 2.1 8.8 5.5c-1.6 3.4-5 5.5-8.8 5.5m0-13c-5 0-9.27 3.11-11 7.5c1.73 4.39 6 7.5 11 7.5s9.27-3.11 11-7.5c-1.73-4.39-6-7.5-11-7.5M12 9a3 3 0 0 0-3 3a3 3 0 0 0 3 3a3 3 0 0 0 3-3a3 3 0 0 0-3-3m0 4a1 1 0 0 1-1-1a1 1 0 0 1 1-1a1 1 0 0 1 1 1a1 1 0 0 1-1 1z"></path>';
                        } else {
                            svg.innerHTML = '<path fill="currentColor" d="M12 9a3 3 0 0 0-3 3a3 3 0 0 0 3 3a3 3 0 0 0 3-3a3 3 0 0 0-3-3m0 8a5 5 0 0 1-5-5a5 5 0 0 1 5-5a5 5 0 0 1 5 5a5 5 0 0 1-5 5m0-12.5C7 4.5 2.73 7.61 1 12c1.73 4.39 6 7.5 11 7.5s9.27-3.11 11-7.5c-1.73-4.39-6-7.5-11-7.5z"></path>';
                        }
                    });
                }
                setupPasswordToggle("<%= txtPassword.ClientID %>", "loginPasswordToggle");

                // 2. CAPTCHA LIVE RELOADER
                window.refreshCaptcha = function() {
                    var img = document.getElementById('captchaImg');
                    if (img) {
                        img.src = '../Captcha.ashx?t=' + new Date().getTime(); // Append timestamp anti-cache vector
                    }
                };
            })();
        </script>
    </body>

    </html>