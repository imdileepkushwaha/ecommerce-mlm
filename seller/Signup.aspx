<%@ Page Language="C#" AutoEventWireup="true" CodeFile="Signup.aspx.cs" Inherits="EcommerceWebsite.SellerSignup" %>

    <!DOCTYPE html>
    <html lang="en">

    <head runat="server">
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <title>Partner Registration - Onboarding</title>

        <!-- FONTS & ICONS -->
        <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700;800&display=swap" rel="stylesheet" />
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" />

        <!-- GLOBAL CSS -->
        <link href="assets/css/seller.css?v=1.1" rel="stylesheet" />
    </head>

    <body>
        <form id="form1" runat="server">
            <div class="reg-page-wrap">
                <div class="reg-card">

                    <!-- HEADER SUBTITLE -->
                    <div class="reg-headline">
                        <h1>Seller Registration</h1>
                        <p>Yeh basic onboarding request hai. Approval ke baad seller login active hoga, fir aap bank
                            details aur business address/proof panel me add kar sakte hain.</p>
                    </div>

                    <!-- GLOBAL ALERTS -->
                    <asp:Label ID="lblMsg" runat="server" CssClass="alert-danger d-block" Visible="false"></asp:Label>

                    <!-- === SECTION 1: ACCOUNT DETAILS === -->
                    <h3 class="reg-section-header">Account details</h3>

                    <div class="form-row">
                        <div class="form-grp">
                            <label>Full name</label>
                            <asp:TextBox ID="txtFullName" runat="server" CssClass="reg-input" placeholder="Seller name"
                                required="required"></asp:TextBox>
                        </div>

                        <div class="form-grp">
                            <label>Email</label>
                            <asp:TextBox ID="txtEmail" runat="server" CssClass="reg-input" TextMode="Email"
                                placeholder="seller@example.com" required="required"></asp:TextBox>
                        </div>
                    </div>

                    <div class="form-row">
                        <div class="form-grp">
                            <label>Phone</label>
                            <asp:TextBox ID="txtPhone" runat="server" CssClass="reg-input" placeholder="+91 9876543210"
                                required="required"></asp:TextBox>
                        </div>

                        <div class="form-grp u-relative">
                            <label>Set password</label>
                            <asp:TextBox ID="txtPassword" runat="server" CssClass="reg-input" TextMode="Password"
                                placeholder="Minimum 8 chars" required="required"></asp:TextBox>
                            <button type="button" id="btnTogglePassword" class="eye-toggle-btn" onclick="togglePass()">
                                <i class="fas fa-eye" id="eyeIcon"></i>
                            </button>
                        </div>
                    </div>

                    <!-- === SECTION 2: BUSINESS DETAILS === -->
                    <h3 class="reg-section-header">Business details</h3>

                    <div class="form-row">
                        <div class="form-grp">
                            <label>Business name</label>
                            <asp:TextBox ID="txtStoreName" runat="server" CssClass="reg-input"
                                placeholder="Your brand / company name" required="required"></asp:TextBox>
                        </div>

                        <div class="form-grp">
                            <label>GST number (optional)</label>
                            <asp:TextBox ID="txtGst" runat="server" CssClass="reg-input" placeholder="22AAAAA0000A1Z5">
                            </asp:TextBox>
                        </div>
                    </div>

                    <!-- Requested Categories Visual Grid -->
                    <div class="form-grp">
                        <label class="lbl-tight">Requested categories</label>

                        <div class="cat-grid">
                            <!-- 1. Fashion -->
                            <label for="<%= chkFashion.ClientID %>" class="cat-card" id="lblFashion">
                                <input type="checkbox" id="chkFashion" runat="server" class="cat-check"
                                    onclick="toggleCardSelect(this, 'lblFashion')" />
                                <div class="cat-details">
                                    <div class="cat-title">👕 Fashion</div>
                                    <div class="cat-desc">Clothing, footwear, accessories</div>
                                </div>
                            </label>

                            <!-- 2. Electronics -->
                            <label for="<%= chkElectronics.ClientID %>" class="cat-card" id="lblElectronics">
                                <input type="checkbox" id="chkElectronics" runat="server" class="cat-check"
                                    onclick="toggleCardSelect(this, 'lblElectronics')" />
                                <div class="cat-details">
                                    <div class="cat-title">🎧 Electronics</div>
                                    <div class="cat-desc">Mobiles, gadgets, appliances</div>
                                </div>
                            </label>

                            <!-- 3. Beauty -->
                            <label for="<%= chkBeauty.ClientID %>" class="cat-card" id="lblBeauty">
                                <input type="checkbox" id="chkBeauty" runat="server" class="cat-check"
                                    onclick="toggleCardSelect(this, 'lblBeauty')" />
                                <div class="cat-details">
                                    <div class="cat-title">💄 Beauty</div>
                                    <div class="cat-desc">Skincare, makeup, wellness</div>
                                </div>
                            </label>

                            <!-- 4. Home -->
                            <label for="<%= chkHome.ClientID %>" class="cat-card" id="lblHome">
                                <input type="checkbox" id="chkHome" runat="server" class="cat-check"
                                    onclick="toggleCardSelect(this, 'lblHome')" />
                                <div class="cat-details">
                                    <div class="cat-title">🏠 Home</div>
                                    <div class="cat-desc">Decor, kitchen, living</div>
                                </div>
                            </label>
                        </div>
                    </div>

                    <div class="form-grp">
                        <label>Additional note (optional)</label>
                        <asp:TextBox ID="txtNote" runat="server" CssClass="reg-input compact-area" TextMode="MultiLine" Rows="3"
                            placeholder="Store type, expected products, etc.">
                        </asp:TextBox>
                    </div>

                    <!-- ACTION SUBMISSION -->
                    <asp:Button ID="btnSubmit" runat="server" CssClass="reg-btn" Text="Send verification code"
                        OnClick="btnSubmit_Click" />

                    <div class="reg-footer">
                        <a href="Login.aspx">Back to seller login</a>
                    </div>

                </div>
            </div>

            <!-- === VERIFICATION OVERLAY MODAL === -->
            <div id="otpModal" class='seller-modal-backdrop <%= IsVerificationModalOpen ? "show" : "" %>'>
                <div class="seller-modal-card modal-txt-center">
                    <div class="seller-modal-head">
                        <h4 class="seller-modal-title">Verify Your Account</h4>
                        <asp:LinkButton ID="btnCloseModal" runat="server" CssClass="seller-modal-close"
                            OnClick="btnCloseModal_Click" CausesValidation="false">
                            <i class="fas fa-times u-fs-12"></i>
                        </asp:LinkButton>
                    </div>

                    <div class="seller-modal-body">
                        <i class="fas fa-shield-halved modal-badge-shield"></i>

                        <p class="modal-p-sub">
                            We have generated a 6-digit verification code. Please enter it below to secure your merchant
                            registration.
                        </p>

                        <div>
                            <asp:Label ID="lblModalMsg" runat="server" CssClass="alert-success d-block mb-3 u-fs-08"
                                Visible="false"></asp:Label>
                        </div>

                        <div class="form-grp">
                            <asp:TextBox ID="txtOtpCode" runat="server" CssClass="reg-input otp-display-input"
                                MaxLength="6" placeholder="000000" autocomplete="off"></asp:TextBox>
                        </div>

                        <asp:Button ID="btnVerifyOtp" runat="server" CssClass="reg-btn mt-0 reg-btn-dark"
                            Text="Confirm & Register Account" OnClick="btnVerifyOtp_Click" />
                    </div>
                </div>
            </div>
        </form>

        <script>
            function togglePass() {
                var input = document.getElementById('<%= txtPassword.ClientID %>');
                var icon = document.getElementById('eyeIcon');
                if (input.type === "password") {
                    input.type = "text";
                    icon.className = "fas fa-eye-slash";
                } else {
                    input.type = "password";
                    icon.className = "fas fa-eye";
                }
            }

            function toggleCardSelect(checkbox, cardId) {
                var card = document.getElementById(cardId);
                if (checkbox.checked) {
                    card.classList.add('cat-card-selected');
                } else {
                    card.classList.remove('cat-card-selected');
                }
            }

            // Set initial select states on page load if boxes pre-checked
            document.addEventListener("DOMContentLoaded", function () {
                var cards = [
                    { chk: document.getElementById('<%= chkFashion.ClientID %>'), lbl: 'lblFashion' },
                    { chk: document.getElementById('<%= chkElectronics.ClientID %>'), lbl: 'lblElectronics' },
                    { chk: document.getElementById('<%= chkBeauty.ClientID %>'), lbl: 'lblBeauty' },
                    { chk: document.getElementById('<%= chkHome.ClientID %>'), lbl: 'lblHome' }
                ];
                cards.forEach(function (c) {
                    if (c.chk && c.chk.checked) {
                        document.getElementById(c.lbl).classList.add('cat-card-selected');
                    }
                });
            });
        </script>
    </body>

    </html>