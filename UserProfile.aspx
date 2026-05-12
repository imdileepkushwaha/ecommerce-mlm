<%@ Page Title="My Profile" Language="C#" MasterPageFile="~/usersite.Master" AutoEventWireup="true"
    CodeFile="UserProfile.aspx.cs" Inherits="ecommerce_mlm.UserProfile" %>
    <%@ Register Src="~/UserSidebar.ascx" TagPrefix="uc" TagName="UserSidebar" %>

        <asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
            <!-- Global Styles Used From style.css -->
        </asp:Content>

        <asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
            <section class="dashboard-wrapper">
                <!-- Breadcrumb -->
                <div class="dashboard-breadcrumb">
                    <div class="container">
                        <div class="dashboard-breadcrumb-inner">
                            <div class="breadcrumb-left">
                                <h3>My Account</h3>
                            </div>
                            <div class="breadcrumb-right">
                                <a href="index.aspx"><i class="fas fa-home"></i></a>
                                <span> / Profile</span>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="container dashboard-container" style="margin-top: 30px; margin-bottom: 60px;">
                    <div class="dashboard-layout">

                        <!-- Integrated Sidebar Component -->
                        <uc:UserSidebar runat="server" ID="UserSidebar" />

                        <!-- Main Profile Area -->
                        <main class="dashboard-main-content">
                            <asp:Panel ID="pnlStatus" runat="server" Visible="false"></asp:Panel>

                            <div class="profile-container">

                                <!-- LEFT: Quick View & Image Upload -->
                                <div class="profile-card-left">
                                    <div class="profile-img-wrapper">
                                        <asp:Literal ID="litLargeAvatar" runat="server"></asp:Literal>
                                        <label for='<%= fuProfilePic.ClientID %>' class="upload-btn-wrapper"
                                            title="Change Profile Picture">
                                            <i class="fas fa-camera"></i>
                                        </label>
                                    </div>
                                    <asp:FileUpload ID="fuProfilePic" runat="server" style="display:none;"
                                        onchange="formSubmitTrigger();" />
                                    <asp:Button ID="btnTriggerUpload" runat="server" style="display:none;"
                                        OnClick="btnTriggerUpload_Click" />

                                    <div class="profile-meta">
                                        <h3>
                                            <asp:Literal ID="litFullNameHero" runat="server"></asp:Literal>
                                        </h3>
                                        <p><i class="fas fa-at" style="font-size: 0.85rem;"></i>
                                            <asp:Literal ID="litUsernameHero" runat="server"></asp:Literal>
                                        </p>
                                        <div style="display: flex; flex-wrap: wrap; gap: 10px; margin-top: 10px;">
                                            <span class="badge"><i class="fas fa-check-circle"></i> Active Member</span>
                                            <span class="badge" style="background:#eff6ff; color:#1d4ed8; border-color:#dbeafe;"><i class="fas fa-calendar-check"></i> Joined <asp:Literal ID="litJoinedDate" runat="server"></asp:Literal></span>
                                        </div>
                                    </div>
                                </div>

                                <!-- RIGHT: Detailed Edit Form -->
                                <div class="profile-card-right">

                                    <div class="section-title">
                                        <div><i class="fas fa-user-circle"></i> Personal Details</div>
                                        <button type="button" class="btn-edit-toggle" onclick="toggleEditMode()">
                                            <i class="fas fa-edit"></i> <span id="toggleBtnTxt">Edit Profile</span>
                                        </button>
                                    </div>

                                    <!-- READ ONLY VIEW -->
                                    <div id="profileViewSection">
                                        <div class="profile-detail-row">
                                            <div class="icon-box"><i class="fas fa-id-badge"></i></div>
                                            <div class="info-body">
                                                <span class="label">Username</span>
                                                <span class="val"><asp:Literal ID="litReadUsername" runat="server"></asp:Literal></span>
                                            </div>
                                        </div>
                                        <div class="profile-detail-row">
                                            <div class="icon-box"><i class="fas fa-user-friends"></i></div>
                                            <div class="info-body">
                                                <span class="label">Sponsor</span>
                                                <span class="val"><asp:Literal ID="litReadSponsor" runat="server"></asp:Literal></span>
                                            </div>
                                        </div>
                                        <div class="profile-detail-row">
                                            <div class="icon-box"><i class="fas fa-user"></i></div>
                                            <div class="info-body">
                                                <span class="label">Full Name</span>
                                                <span class="val"><asp:Literal ID="litReadFullName" runat="server"></asp:Literal></span>
                                            </div>
                                        </div>
                                        <div class="profile-detail-row">
                                            <div class="icon-box"><i class="fas fa-envelope"></i></div>
                                            <div class="info-body">
                                                <span class="label">Email ID</span>
                                                <span class="val"><asp:Literal ID="litReadEmail" runat="server"></asp:Literal> <asp:Literal ID="litEmailVerifyBadge" runat="server"></asp:Literal></span>
                                            </div>
                                        </div>
                                        <div class="profile-detail-row">
                                            <div class="icon-box"><i class="fas fa-mobile-alt"></i></div>
                                            <div class="info-body">
                                                <span class="label">Mobile</span>
                                                <span class="val"><asp:Literal ID="litReadMobile" runat="server"></asp:Literal> <asp:Literal ID="litMobileVerifyBadge" runat="server"></asp:Literal></span>
                                            </div>
                                        </div>
                                        <div class="profile-detail-row">
                                            <div class="icon-box"><i class="fas fa-calendar-day"></i></div>
                                            <div class="info-body">
                                                <span class="label">DOB</span>
                                                <span class="val"><asp:Literal ID="litReadDob" runat="server">Not Set</asp:Literal></span>
                                            </div>
                                        </div>
                                        <div class="profile-detail-row">
                                            <div class="icon-box"><i class="fas fa-venus-mars"></i></div>
                                            <div class="info-body">
                                                <span class="label">Gender</span>
                                                <span class="val"><asp:Literal ID="litReadGender" runat="server">Not Set</asp:Literal></span>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- EDITABLE FORM -->
                                    <div id="profileEditSection" style="display: none;">
                                        <div class="form-grid">
                                            <!-- Read Only System Fields -->
                                            <div class="form-group">
                                                <label><i class="fas fa-id-card"></i> User Identification /
                                                    Username</label>
                                                <asp:TextBox ID="txtUsername" runat="server" CssClass="form-control"
                                                    Enabled="false"></asp:TextBox>
                                            </div>
                                            <div class="form-group">
                                                <label><i class="fas fa-user-friends"></i> Sponsor ID</label>
                                                <asp:TextBox ID="txtSponsorId" runat="server" CssClass="form-control"
                                                    Enabled="false"></asp:TextBox>
                                            </div>
                                            <div class="form-group">
                                                <label><i class="fas fa-user-tie"></i> Sponsor Name</label>
                                                <asp:TextBox ID="txtSponsorName" runat="server" CssClass="form-control"
                                                    Enabled="false"></asp:TextBox>
                                            </div>

                                            <!-- Editable Fields -->
                                            <div class="form-group">
                                                <label><i class="fas fa-signature"></i> Full Legal Name <span
                                                        style="color:red">*</span></label>
                                                <asp:TextBox ID="txtFullName" runat="server" CssClass="form-control"
                                                    placeholder="Enter full name"></asp:TextBox>
                                            </div>

                                            <div class="form-group">
                                                <label>
                                                    <i class="fas fa-envelope"></i> Email Address <span style="color:red">*</span>
                                                    <asp:LinkButton ID="lnkVerifyEmail" runat="server" CssClass="btn-trigger-verify" OnClick="lnkVerifyEmail_Click">Verify Now</asp:LinkButton>
                                                    <asp:Label ID="lblEmailVerified" runat="server" Visible="false" ForeColor="#10b981" Font-Bold="true" Font-Size="X-Small"><i class="fas fa-check"></i> VERIFIED</asp:Label>
                                                </label>
                                                <asp:TextBox ID="txtEmail" runat="server" CssClass="form-control" TextMode="Email" placeholder="email@domain.com"></asp:TextBox>
                                            </div>

                                            <div class="form-group">
                                                <label>
                                                    <i class="fas fa-mobile-alt"></i> Contact Mobile <span style="color:red">*</span>
                                                    <asp:LinkButton ID="lnkVerifyMobile" runat="server" CssClass="btn-trigger-verify" OnClick="lnkVerifyMobile_Click">Verify Now</asp:LinkButton>
                                                    <asp:Label ID="lblMobileVerified" runat="server" Visible="false" ForeColor="#10b981" Font-Bold="true" Font-Size="X-Small"><i class="fas fa-check"></i> VERIFIED</asp:Label>
                                                </label>
                                                <asp:TextBox ID="txtMobile" runat="server" CssClass="form-control" TextMode="Phone" placeholder="Enter 10-digit mobile"></asp:TextBox>
                                            </div>

                                            <div class="form-group">
                                                <label><i class="fas fa-calendar-alt"></i> Date of Birth</label>
                                                <asp:TextBox ID="txtDob" runat="server" CssClass="form-control"
                                                    placeholder="DD/MM/YYYY"></asp:TextBox>
                                            </div>

                                            <div class="form-group">
                                                <label><i class="fas fa-venus-mars"></i> Gender</label>
                                                <asp:DropDownList ID="ddlGender" runat="server" CssClass="form-control">
                                                    <asp:ListItem Value="">Select Gender</asp:ListItem>
                                                    <asp:ListItem Value="Male">Male</asp:ListItem>
                                                    <asp:ListItem Value="Female">Female</asp:ListItem>
                                                    <asp:ListItem Value="Other">Other</asp:ListItem>
                                                </asp:DropDownList>
                                            </div>
                                        </div>

                                        <div
                                            style="margin-top: 30px; border-top: 1px solid #f3f4f6; padding-top: 20px; display: flex; justify-content: flex-end; gap:15px;">
                                            <button type="button" class="btn-edit-toggle"
                                                style="padding: 12px 25px; border-radius: 8px; margin-top:20px;"
                                                onclick="toggleEditMode()">Cancel</button>
                                            <asp:Button ID="btnUpdateProfile" runat="server" CssClass="btn-save"
                                                Text="Save All Changes" OnClick="btnUpdateProfile_Click" />
                                        </div>
                                        </div>
                                </div>

                                </div>
                            </div>
                        </main>

                    </div>
                </div>
            </section>

            <!-- OTP VERIFICATION MODAL -->
            <div id="otpModalBackdrop" class="verification-modal-backdrop">
                <div class="otp-modal-content">
                    <button type="button" class="close-otp-modal" onclick="toggleOtpModal(false)">&times;</button>
                    <div class="otp-header-icon"><i class="fas fa-shield-alt"></i></div>
                    <h3 class="otp-title">Security Check</h3>
                    <p class="otp-desc">Verification code sent. Please enter it below to continue.</p>
                    
                    <asp:TextBox ID="txtOtpInput" runat="server" CssClass="otp-input-styled" MaxLength="6" placeholder="000000"></asp:TextBox>
                    
                    <asp:Button ID="btnConfirmOtp" runat="server" Text="Verify & Confirm" CssClass="btn-verify-otp" OnClick="btnConfirmOtp_Click" />
                    <p id="otpMsg" style="color:red; font-size:0.85rem; margin-top:10px;"></p>
                </div>
            </div>

            <script type="text/javascript">
                function toggleEditMode() {
                    var view = document.getElementById('profileViewSection');
                    var edit = document.getElementById('profileEditSection');
                    var btnText = document.getElementById('toggleBtnTxt');

                    if (view.style.display === "none") {
                        view.style.display = "block";
                        edit.style.display = "none";
                        btnText.innerText = "Edit Profile";
                    } else {
                        view.style.display = "none";
                        edit.style.display = "block";
                        btnText.innerText = "View Profile";
                    }
                }

                function toggleOtpModal(show) {
                    var modal = document.getElementById('otpModalBackdrop');
                    if (show) {
                        modal.classList.add('show');
                    } else {
                        modal.classList.remove('show');
                    }
                }

                // Auto trigger hidden submit button when user selects a file for instant ajax-like response, although this will postback.
                function formSubmitTrigger() {
                    var fileInput = document.getElementById('<%= fuProfilePic.ClientID %>');
                    if (fileInput.value) {
                        document.getElementById('<%= btnTriggerUpload.ClientID %>').click();
                    }
                }
            </script>
        </asp:Content>