<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Register.aspx.cs" Inherits="ecommerce_mlm.Register" %>

    <!DOCTYPE html>
    <html xmlns="http://www.w3.org/1999/xhtml">

    <head runat="server">
        <title>Sign Up - Kartify</title>
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <link href="assets/css/auth.css" rel="stylesheet" />
        <link rel="stylesheet" href="assets/fonts/fontawesome/css/all.min.css" />
    </head>

    <body>
        <form id="form1" runat="server">
            <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>

            <asp:UpdatePanel ID="updRoot" runat="server">
                <ContentTemplate>
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
                                <h1>Join Us Today.</h1>
                                <p>Start your journey with Kartify. Create a free account and unlock incredible discounts and
                                    networking opportunities.</p>
                            </div>
                        </div>

                        <!-- Right Form Section -->
                        <div class="auth-form-container">
                            <div class="auth-header">
                                <h2>Create Account</h2>
                                <p>Please fill in the details below to register.</p>
                            </div>
                            <div class="auth-form-inner max-w-600">

                                <asp:Label ID="lblMessage" runat="server" CssClass="success-msg" Visible="false"></asp:Label>
                                <asp:Label ID="lblError" runat="server" CssClass="error-msg" Visible="false"></asp:Label>

                                <!-- Section 1: Referral Detail -->
                                <asp:UpdatePanel ID="updPnlSponsor" runat="server">
                                    <ContentTemplate>
                                        <div class="form-row">
                                            <div class="form-group">
                                                <label class="form-label">Sponsor ID</label>
                                                <div class="status-icon-wrapper">
                                                    <asp:TextBox ID="txtSponsorId" runat="server" CssClass="form-input"
                                                        placeholder="e.g. admin" AutoPostBack="true"
                                                        OnTextChanged="txtSponsorId_TextChanged"></asp:TextBox>
                                                    <asp:Literal ID="litSponsorStatus" runat="server"></asp:Literal>
                                                </div>
                                            </div>
                                            <div class="form-group">
                                                <label class="form-label">Sponsor Name</label>
                                                <asp:TextBox ID="txtSponsorName" runat="server"
                                                    CssClass="form-input input-readonly" placeholder="Sponsor Name"
                                                    ReadOnly="true"></asp:TextBox>
                                            </div>
                                        </div>
                                        <div class="mt-neg-15 mb-15">
                                            <asp:Label ID="lblSponsorError" runat="server"
                                                CssClass="error-msg lbl-inline-error-compact" Visible="false">
                                            </asp:Label>
                                        </div>
                                        <div class="form-group mt-15 mb-0">
                                            <label class="form-label">Placement Node Position</label>
                                            <asp:RadioButtonList ID="rblPosition" runat="server" RepeatDirection="Horizontal" CssClass="modern-radio-list">
                                                <asp:ListItem Text="Left Side Node" Value="Left" Selected="True"></asp:ListItem>
                                                <asp:ListItem Text="Right Side Node" Value="Right"></asp:ListItem>
                                            </asp:RadioButtonList>
                                        </div>
                                    </ContentTemplate>
                                </asp:UpdatePanel>


                                <!-- Section 2: Personal Detail -->
                                <div class="form-group">
                                    <label class="form-label">Full Name</label>
                                    <asp:TextBox ID="txtFullName" runat="server" CssClass="form-input"
                                        placeholder="Enter full name"></asp:TextBox>
                                </div>

                                <div class="form-row">
                                    <div class="form-group">
                                        <label class="form-label">Date of Birth</label>
                                        <asp:TextBox ID="txtDob" runat="server" CssClass="form-input" TextMode="Date">
                                        </asp:TextBox>
                                    </div>
                                    <div class="form-group">
                                        <label class="form-label">Gender</label>
                                        <asp:DropDownList ID="ddlGender" runat="server" CssClass="form-input">
                                            <asp:ListItem Text="Select Gender" Value="" />
                                            <asp:ListItem Text="Male" Value="Male" />
                                            <asp:ListItem Text="Female" Value="Female" />
                                            <asp:ListItem Text="Other" Value="Other" />
                                        </asp:DropDownList>
                                    </div>
                                </div>

                                <!-- Section 3: Account Detail -->

                                <div class="form-group">
                                    <label class="form-label">Email Address</label>
                                    <asp:TextBox ID="txtEmail" runat="server" CssClass="form-input" TextMode="Email"
                                        placeholder="yourname@example.com"></asp:TextBox>
                                </div>

                                <div class="form-row">
                                    <div class="form-group">
                                        <label class="form-label">Choose Username</label>
                                        <asp:TextBox ID="txtUsername" runat="server" CssClass="form-input"
                                            placeholder="Pick a username"></asp:TextBox>
                                    </div>
                                    <div class="form-group">
                                        <label class="form-label">Mobile Number</label>
                                        <asp:TextBox ID="txtMobile" runat="server" CssClass="form-input"
                                            placeholder="10 digit number"></asp:TextBox>
                                    </div>
                                </div>

                                <div class="form-row">
                                    <div class="form-group">
                                        <label class="form-label">Password</label>
                                        <div class="password-field-wrapper">
                                            <asp:TextBox ID="txtPassword" runat="server" CssClass="form-input"
                                                TextMode="Password" placeholder="••••••••"></asp:TextBox>
                                            <i class="fas fa-eye-slash toggle-password"
                                                onclick="togglePass(this, '<%= txtPassword.ClientID %>')"></i>
                                        </div>
                                    </div>
                                    <div class="form-group">
                                        <label class="form-label">Confirm Password</label>
                                        <div class="password-field-wrapper">
                                            <asp:TextBox ID="txtConfirmPassword" runat="server" CssClass="form-input"
                                                TextMode="Password" placeholder="••••••••"></asp:TextBox>
                                            <i class="fas fa-eye-slash toggle-password"
                                                onclick="togglePass(this, '<%= txtConfirmPassword.ClientID %>')"></i>
                                        </div>
                                    </div>
                                </div>

                                <div class="form-group flex-center-gap mb-20">
                                    <asp:CheckBox ID="chkTerms" runat="server" />
                                    <label for="<%= chkTerms.ClientID %>" class="checkbox-label">
                                        I accept the <a href="#" class="link-accent">Terms &amp; Conditions</a>
                                    </label>
                                </div>

                                <asp:Button ID="btnRegister" runat="server" Text="Create Free Account" CssClass="auth-btn"
                                    OnClick="btnRegister_Click" />

                                <div class="auth-footer mb-40">
                                    <p>Already have an account? <a href="Login.aspx">Sign In Here</a></p>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Registration OTP Verification Popup -->
                    <div class="modal-overlay" id="regVerifyModal">
                        <div class="modal-content text-center">
                            <div class="modal-icon"><i class="fa fa-envelope-open-text"></i></div>
                            
                            <asp:Label ID="lblModalMsg" runat="server" CssClass="error-msg lbl-inline-error" Visible="false"></asp:Label>
                            
                            <asp:MultiView ID="mvVerify" runat="server" ActiveViewIndex="0">
                                <!-- Step 1: Enter Verification Code -->
                                <asp:View ID="vwCodeEntry" runat="server">
                                    <div class="modal-header">
                                        <h3>Verify Your Email</h3>
                                        <p>To complete registration, please enter the 6-digit security code dispatched to your inbox.</p>
                                    </div>
                                    <div class="form-group text-left">
                                        <label class="form-label">Security Code</label>
                                        <asp:TextBox ID="txtRegCode" runat="server" CssClass="form-input otp-input" placeholder="XXXXXX" MaxLength="6"></asp:TextBox>
                                    </div>
                                    <asp:Button ID="btnVerifyReg" runat="server" Text="Verify & Complete" CssClass="auth-btn" OnClick="btnVerifyReg_Click" />
                                    
                                    <div class="text-center" style="margin-top: 15px;">
                                        <span id="resendTimerReg" style="color: #64748b; font-size: 0.85rem;">Resend available in <b id="timeLeftReg">02:00</b></span>
                                        <asp:LinkButton ID="lnkResendReg" runat="server" CssClass="forgot-link" Text="Resend Code" OnClick="lnkResendReg_Click" style="display: none; font-weight: 600;"></asp:LinkButton>
                                    </div>

                                    <a href="javascript:void(0)" class="forgot-link d-block mt-15" onclick="toggleRegModal(false)">Modify Info</a>
                                </asp:View>

                                <!-- Step 2: Finished Successfully -->
                                <asp:View ID="vwRegSuccess" runat="server">
                                    <div class="modal-header">
                                        <div class="icon-success-large"><i class="fa fa-check-circle"></i></div>
                                        <h3>Congratulations!</h3>
                                        <p>Your email is validated and your account is ready to use.</p>
                                    </div>
                                    <a href="Login.aspx" class="auth-btn text-center d-block" style="text-decoration: none; color: #fff;">Sign In Now</a>
                                </asp:View>
                            </asp:MultiView>
                        </div>
                    </div>
                </ContentTemplate>
            </asp:UpdatePanel>
        </form>

        <script type="text/javascript">
            function togglePass(icon, controlId) {
                const input = document.getElementById(controlId);
                if (input.type === "password") {
                    input.type = "text";
                    icon.classList.remove("fa-eye-slash");
                    icon.classList.add("fa-eye");
                } else {
                    input.type = "password";
                    icon.classList.remove("fa-eye");
                    icon.classList.add("fa-eye-slash");
                }
            }

            function toggleRegModal(show) {
                const modal = document.getElementById('regVerifyModal');
                if (!modal) return;
                if (show) {
                    modal.classList.add('active');
                } else {
                    modal.classList.remove('active');
                }
            }

            let resendTimerReg;
            function startRegResendCountdown(spanId, linkId, valId, time) {
                const span = document.getElementById(spanId);
                const link = document.getElementById(linkId);
                const valDisplay = document.getElementById(valId);
                
                if(!span || !link || !valDisplay) return;
                
                span.style.display = 'inline';
                link.style.display = 'none';
                valDisplay.style.color = '#22c55e'; // Normal Green initially
                
                let left = time;
                clearInterval(resendTimerReg);
                
                resendTimerReg = setInterval(function() {
                    let m = parseInt(left / 60, 10);
                    let s = parseInt(left % 60, 10);
                    m = m < 10 ? "0" + m : m;
                    s = s < 10 ? "0" + s : s;
                    valDisplay.textContent = m + ":" + s;

                    if (left <= 20) {
                        valDisplay.style.color = 'red';
                    } else {
                        valDisplay.style.color = '#22c55e'; // Stays Green ordinarily
                    }
                    
                    if(--left < 0) {
                        clearInterval(resendTimerReg);
                        span.style.display = 'none';
                        link.style.display = 'inline-block';
                    }
                }, 1000);
            }
        </script>
    </body>

    </html>