<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Login.aspx.cs" Inherits="ecommerce_mlm.Login" %>

    <!DOCTYPE html>
    <html xmlns="http://www.w3.org/1999/xhtml">

    <head runat="server">
        <title>Login - Kartify</title>
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <link href="assets/css/auth.css" rel="stylesheet" />
        <link rel="stylesheet" href="assets/fonts/fontawesome/css/all.min.css" />
    </head>

    <body>
        <form id="form1" runat="server">
            <asp:ScriptManager ID="smPopup" runat="server"></asp:ScriptManager>
            <div class="auth-wrapper">
                <!-- Left Banner Section -->
                <div class="auth-banner">
                    <a href="index.aspx" class="back-home-floating">
                        <i class="fas fa-arrow-left"></i> Back to Home
                    </a>
                    <div class="logo-auth">
                        <img src="assets/images/logo.svg" alt="Kartify Logo" />
                    </div>
                    <div class="banner-content">
                        <h1>Welcome Back.</h1>
                        <p>Login to explore the best deals, track your orders, and manage your account seamlessly.</p>
                    </div>
                </div>

                <!-- Right Form Section -->
                <div class="auth-form-container">
                    <div class="auth-header">
                        <h2>Login to Kartify</h2>
                        <p>Please enter your credentials to continue.</p>
                    </div>
                    <div class="auth-form-inner">

                        <asp:Label ID="lblError" runat="server" CssClass="error-msg" Visible="false"></asp:Label>
                        <asp:Label ID="lblSuccess" runat="server" CssClass="success-msg" Visible="false"></asp:Label>

                        <div class="form-group">
                            <label class="form-label" for="txtUsername">Username</label>
                            <asp:TextBox ID="txtUsername" runat="server" CssClass="form-input"
                                placeholder="e.g. john_doe"></asp:TextBox>
                        </div>

                        <div class="form-group">
                            <label class="form-label" for="txtPassword">Password</label>
                            <div class="password-field-wrapper">
                                <asp:TextBox ID="txtPassword" runat="server" CssClass="form-input" TextMode="Password"
                                    placeholder="••••••••"></asp:TextBox>
                                <i class="fa fa-eye-slash toggle-password" id="eyeToggle"></i>
                            </div>
                        </div>

                        <div class="forgot-link-container">
                            <a href="javascript:void(0)" class="forgot-link" onclick="toggleModal(true)">Forgot
                                Password?</a>
                        </div>

                        <div class="form-group">
                            <label class="form-label">Verify Captcha</label>
                            <div class="captcha-container">
                                <img id="captchaImg" src="Captcha.ashx" alt="Captcha" class="captcha-img" />
                                <button type="button" class="btn-refresh" onclick="refreshCaptcha()">
                                    <i class="fas fa-sync-alt"></i>
                                </button>
                                <asp:TextBox ID="txtCaptcha" runat="server" CssClass="form-input"
                                    placeholder="Enter code" style="width: 120px;"></asp:TextBox>
                            </div>
                        </div>

                        <asp:Button ID="btnLogin" runat="server" Text="Sign In" CssClass="auth-btn"
                            OnClick="btnLogin_Click" />

                        <div class="auth-footer">
                            <p>Don't have an account? <a href="Register.aspx">Create Account</a></p>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Forgot Password Popup -->
            <div class="modal-overlay" id="forgotModal">
                <div class="modal-content" style="text-align: center;">
                    <span class="modal-close" onclick="toggleModal(false)">&times;</span>

                    <asp:UpdatePanel ID="updModal" runat="server">
                        <ContentTemplate>
                            <div class="modal-icon">
                                <i class="fa fa-key"></i>
                            </div>

                            <asp:Label ID="lblModalMsg" runat="server" CssClass="error-msg" Visible="false"
                                style="font-size: 0.8rem; padding: 8px; margin-bottom: 15px;"></asp:Label>

                            <asp:MultiView ID="mvForgot" runat="server" ActiveViewIndex="0">
                                <!-- STEP 1: Enter Username/Email -->
                                <asp:View ID="vwStep1" runat="server">
                                    <div class="modal-header">
                                        <h3>Forgot Password?</h3>
                                        <p>Enter your registered Email or Username and we'll send you a reset code.</p>
                                    </div>
                                    <div class="form-group" style="text-align: left;">
                                        <label class="form-label">Email or Username</label>
                                        <asp:TextBox ID="txtResetIdentity" runat="server" CssClass="form-input"
                                            placeholder="Email or Username"></asp:TextBox>
                                    </div>
                                    <asp:Button ID="btnSendCode" runat="server" Text="Send Reset Code"
                                        CssClass="auth-btn" OnClick="btnSendCode_Click" />
                                </asp:View>

                                <!-- STEP 2: Verify OTP Code -->
                                <asp:View ID="vwStep2" runat="server">
                                    <div class="modal-header">
                                        <h3>Verify Code</h3>
                                        <p>A 6-digit security code has been dispatched to your email. Enter it below.
                                        </p>
                                    </div>
                                    <div class="form-group" style="text-align: left;">
                                        <label class="form-label">6-Digit Code</label>
                                        <asp:TextBox ID="txtResetCode" runat="server" CssClass="form-input"
                                            placeholder="Enter 6-digit code" MaxLength="6"
                                            style="text-align:center; font-size: 1rem; letter-spacing: 5px; font-weight: bold;">
                                        </asp:TextBox>
                                    </div>
                                    <asp:Button ID="btnVerifyCode" runat="server" Text="Verify Code" CssClass="auth-btn"
                                        OnClick="btnVerifyCode_Click" />

                                    <div class="text-center" style="margin-top: 15px;">
                                        <span id="resendTimer" style="color: #64748b; font-size: 0.85rem;">Resend
                                            available in <b id="timeLeft">02:00</b></span>
                                        <asp:LinkButton ID="lnkResendCode" runat="server" CssClass="forgot-link"
                                            Text="Resend Security Code" OnClick="lnkResendCode_Click"
                                            style="display: none; font-weight: 600;"></asp:LinkButton>
                                    </div>

                                    <a href="javascript:void(0)" class="forgot-link"
                                        style="display:block; margin-top:15px;"
                                        onclick="window.location.reload();">Cancel</a>
                                </asp:View>

                                <!-- STEP 3: Create New Password -->
                                <asp:View ID="vwStep3" runat="server">
                                    <div class="modal-header">
                                        <h3>New Password</h3>
                                        <p>Your code was verified successfully. Please establish a safe new password.
                                        </p>
                                    </div>
                                    <div class="form-group" style="text-align: left;">
                                        <label class="form-label">New Password</label>
                                        <asp:TextBox ID="txtNewPassword" runat="server" CssClass="form-input"
                                            TextMode="Password" placeholder="Enter new password"></asp:TextBox>
                                    </div>
                                    <div class="form-group" style="text-align: left;">
                                        <label class="form-label">Confirm Password</label>
                                        <asp:TextBox ID="txtConfirmNewPassword" runat="server" CssClass="form-input"
                                            TextMode="Password" placeholder="Confirm password"></asp:TextBox>
                                    </div>
                                    <asp:Button ID="btnFinalReset" runat="server" Text="Update Password"
                                        CssClass="auth-btn" OnClick="btnFinalReset_Click" />
                                </asp:View>

                                <!-- STEP 4: Final Success Message -->
                                <asp:View ID="vwStep4" runat="server">
                                    <div class="modal-header">
                                        <div style="color: #15803d; font-size: 3rem; margin-bottom: 10px;"><i
                                                class="fa fa-check-circle"></i></div>
                                        <h3>Done!</h3>
                                        <p>Your password has been successfully reset. You can now log in with your
                                            updated credentials.</p>
                                    </div>
                                    <asp:Button ID="btnDone" runat="server" Text="Proceed to Login" CssClass="auth-btn"
                                        OnClientClick="toggleModal(false); return false;" />
                                </asp:View>
                            </asp:MultiView>

                            <a href="javascript:void(0)" class="forgot-link"
                                style="display:block; margin-top: 20px; text-align:center;"
                                onclick="toggleModal(false)">Back to Login</a>
                        </ContentTemplate>
                    </asp:UpdatePanel>
                </div>
            </div>
        </form>

        <script type="text/javascript">
            // 1. Refresh Captcha functionality
            function refreshCaptcha() {
                const img = document.getElementById('captchaImg');
                img.src = 'Captcha.ashx?t=' + new Date().getTime(); // Prevent caching
            }

            // 2. Toggle Password Visibility
            const eyeToggle = document.getElementById('eyeToggle');
            const txtPass = document.getElementById('<%= txtPassword.ClientID %>');

            if (eyeToggle && txtPass) {
                eyeToggle.addEventListener('click', function () {
                    const type = txtPass.getAttribute('type') === 'password' ? 'text' : 'password';
                    txtPass.setAttribute('type', type);

                    // toggle class
                    this.classList.toggle('fa-eye');
                    this.classList.toggle('fa-eye-slash');
                });
            }

            // 3. Modal Popup visibility
            function toggleModal(show) {
                const modal = document.getElementById('forgotModal');
                if (show) {
                    modal.classList.add('active');
                } else {
                    modal.classList.remove('active');
                }
            }

            let resendInterval;
            function startResendCountdown(spanId, linkId, valId, time) {
                const span = document.getElementById(spanId);
                const link = document.getElementById(linkId);
                const timeDisplay = document.getElementById(valId);

                if (!span || !link || !timeDisplay) return;

                span.style.display = 'inline';
                link.style.display = 'none';
                timeDisplay.style.color = '#009a3d'; // Set Initial Normal Green

                let left = time;
                clearInterval(resendInterval);

                resendInterval = setInterval(function () {
                    let min = parseInt(left / 60, 10);
                    let sec = parseInt(left % 60, 10);
                    min = min < 10 ? "0" + min : min;
                    sec = sec < 10 ? "0" + sec : sec;
                    timeDisplay.textContent = min + ":" + sec;

                    if (left <= 20) {
                        timeDisplay.style.color = 'red';
                    } else {
                        timeDisplay.style.color = '#009a3d'; // Keep Green during normal time
                    }

                    if (--left < 0) {
                        clearInterval(resendInterval);
                        span.style.display = 'none';
                        link.style.display = 'inline-block';
                    }
                }, 1000);
            }
        </script>
    </body>

    </html>