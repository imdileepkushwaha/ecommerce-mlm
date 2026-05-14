<%@ Page Title="KYC & Banking Compliance" Language="C#" MasterPageFile="~/seller/Seller.Master" AutoEventWireup="true"
    CodeFile="Kyc.aspx.cs" Inherits="EcommerceWebsite.SellerKyc" %>

    <asp:Content ID="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

        <!-- DYNAMIC GLOBAL ALERTS -->
        <asp:Label ID="lblGlobalMsg" runat="server" Visible="false" style="display: block;"></asp:Label>

        <!-- KYC HEADER -->
        <div class="kyc-hero">
            <h1>KYC & Banking Portal</h1>
            <p>Compliance and secure payouts. Please complete your business portfolio verification for commercial
                eligibility.</p>
        </div>

        <!-- TOP TRIPLE STATUS GRID -->
        <div class="kyc-status-grid">
            <!-- 1. KYC Packet Status -->
            <div class='kyc-stat-card <%= Convert.ToBoolean(ViewState["IsKycSubmitted"]) ? "active-blue" : "" %>'>
                <div>
                    <div class="kyc-stat-lbl">KYC PACKET</div>
                    <div class="kyc-stat-val">
                        <asp:Literal ID="litPacketStatus" runat="server">Not Submitted</asp:Literal>
                    </div>
                    <div class="kyc-stat-sub">Updated: <asp:Literal ID="litPacketDate" runat="server">Never
                        </asp:Literal>
                    </div>
                </div>
                <div class="kyc-stat-icon">
                    <i class="fas fa-file-contract"></i>
                </div>
            </div>

            <!-- 2. Approval Audit Status -->
            <div
                class='kyc-stat-card <%= (ViewState["KycStatus"] != null && ViewState["KycStatus"].ToString() == "Approved") ? "active-green" : ((ViewState["KycStatus"] != null && ViewState["KycStatus"].ToString() == "Pending") ? "active-orange" : "") %>'>
                <div>
                    <div class="kyc-stat-lbl">FINAL APPROVAL</div>
                    <div class="kyc-stat-val">
                        <asp:Literal ID="litApprovalStatus" runat="server">Awaiting Submission</asp:Literal>
                    </div>
                    <div class="kyc-stat-sub">Compliance review status</div>
                </div>
                <div class="kyc-stat-icon">
                    <i
                        class='fas <%= (ViewState["KycStatus"] != null && ViewState["KycStatus"].ToString() == "Approved") ? "fa-check-circle" : "fa-clock" %>'></i>
                </div>
            </div>

            <!-- 3. Editable Access Status -->
            <div class="kyc-stat-card">
                <div>
                    <div class="kyc-stat-lbl">PANEL STATE</div>
                    <div class="kyc-stat-val">
                        <asp:Literal ID="litPanelState" runat="server">Active Editor</asp:Literal>
                    </div>
                    <div class="kyc-stat-sub">Configuration state</div>
                </div>
                <div class="kyc-stat-icon">
                    <i class="fas fa-lock-open"></i>
                </div>
            </div>
        </div>

        <!-- BANNER SYSTEM -->
        <asp:Panel ID="pnlLockedBanner" runat="server" CssClass="kyc-banner-locked" Visible="false">
            <i class="fas fa-shield-halved" style="font-size:1.2rem;"></i>
            <div>
                <strong>Audit Lock Active:</strong> Your verification portfolio has been submitted and is currently
                under administrative audit. Modification is locked.
            </div>
        </asp:Panel>

        <asp:Panel ID="pnlApprovedBanner" runat="server" CssClass="kyc-banner-approved" Visible="false">
            <i class="fas fa-circle-check" style="font-size:1.2rem;"></i>
            <div>
                <strong>Verified Merchant:</strong> System verification is complete. Your store operations are fully
                active and settlement ready!
            </div>
        </asp:Panel>

        <!-- REQUEST TO EDIT PORTAL -->
        <asp:Panel ID="pnlRequestEditActions" runat="server" CssClass="kyc-edit-action-box" Visible="false">
            <div class="kyc-edit-action-info">
                <i class="fas fa-user-pen" style="font-size:1.3rem; color:#6366f1;"></i>
                <div>
                    <strong>Need to update KYC or Banking details?</strong>
                    <span>Submit an edit access request to Super Admin. Once approved, you can modify parameters.</span>
                </div>
            </div>
            <asp:Button ID="btnRequestEdit" runat="server" CssClass="kyc-edit-btn" Text="⚡ Request Edit Access"
                OnClick="btnRequestEdit_Click"
                OnClientClick="return confirm('Submit a formal request to edit verified documents?');" />
        </asp:Panel>

        <!-- PENDING EDIT APPROVAL ALERT -->
        <asp:Panel ID="pnlEditRequestPending" runat="server" CssClass="kyc-banner-blue-alert" Visible="false">
            <i class="fas fa-hourglass-half" style="font-size:1.2rem; color:#2563eb;"></i>
            <div>
                <strong>Edit Request Pending:</strong> You have requested access to modify compliance details. Awaiting
                Super Admin authorization.
            </div>
        </asp:Panel>


        <!-- MAIN KYC PAPER CARD -->
        <div class="kyc-paper">
            <div class="kyc-paper-head">
                <h2>Verification & Settlement Profiler</h2>
                <span
                    class='badge kyc-badge-pill <%= Convert.ToBoolean(ViewState["IsKycSubmitted"]) ? "badge-shipped" : "badge-pending" %>'>
                    <asp:Literal ID="litTopBadge" runat="server">Draft Mode</asp:Literal>
                </span>
            </div>

            <!-- === SECTION 1: BUSINESS & TAX PROFILE === -->
            <div class="kyc-section">
                <h3 class="kyc-sec-title">
                    <i class="fas fa-building-columns" style="color: #6366f1;"></i> Business & Tax
                </h3>
                <p class="kyc-sec-sub">Legal company identity, tax registrations and verified proof uploads.</p>

                <!-- Legal Business Name (Standalone Row) -->
                <div class="form-grp">
                    <label>Legal Business Name</label>
                    <asp:TextBox ID="txtStoreName" runat="server" CssClass="reg-input"
                        placeholder="Full brand / legal firm identity"></asp:TextBox>
                </div>

                <!-- GST Profile (Num + Document Row) -->
                <div class="form-row">
                    <div class="form-grp">
                        <label>GST Registration Number (Optional)</label>
                        <asp:TextBox ID="txtGst" runat="server" CssClass="reg-input" placeholder="22AAAAA0000A1Z5">
                        </asp:TextBox>
                    </div>
                    <div class="form-grp">
                        <label>GST Certification Scan (PDF/JPEG)</label>
                        <div class="kyc-upload-box kyc-upload-row" runat="server" id="boxGst">
                            <asp:FileUpload ID="fuGst" runat="server" />
                            <asp:Literal ID="litGstLink" runat="server"></asp:Literal>
                        </div>
                    </div>
                </div>

                <!-- PAN Profile (Num + Document Row) -->
                <div class="form-row">
                    <div class="form-grp">
                        <label>Permanent Account Number (PAN)</label>
                        <asp:TextBox ID="txtPan" runat="server" CssClass="reg-input" placeholder="ABCDE1234F">
                        </asp:TextBox>
                    </div>
                    <div class="form-grp">
                        <label>PAN Card Document Scan (PDF/JPEG)</label>
                        <div class="kyc-upload-box kyc-upload-row" runat="server" id="boxPan">
                            <asp:FileUpload ID="fuPan" runat="server" />
                            <asp:Literal ID="litPanLink" runat="server"></asp:Literal>
                        </div>
                    </div>
                </div>

                <!-- Aadhaar Profile (Num + Document Row) -->
                <div class="form-row">
                    <div class="form-grp">
                        <label>Aadhaar Identification Number</label>
                        <asp:TextBox ID="txtAadhar" runat="server" CssClass="reg-input"
                            placeholder="12-Digit Identification Number"></asp:TextBox>
                    </div>
                    <div class="form-grp">
                        <label>Aadhaar Card Document Scan (PDF/JPEG)</label>
                        <div class="kyc-upload-box kyc-upload-row" runat="server" id="boxAadhar">
                            <asp:FileUpload ID="fuAadhar" runat="server" />
                            <asp:Literal ID="litAadharLink" runat="server"></asp:Literal>
                        </div>
                    </div>
                </div>
            </div>

            <!-- === SECTION 2: BANK ACCOUNT SETTLEMENT === -->
            <div class="kyc-section">
                <h3 class="kyc-sec-title">
                    <i class="fas fa-piggy-bank" style="color: #ec4899;"></i> Settlement Bank Account
                </h3>
                <p class="kyc-sec-sub">Commercial payouts are synced to this clearance pipeline. Ensure alignment with
                    bank ledger.</p>

                <div class="form-row">
                    <div class="form-grp">
                        <label>Beneficiary Bank Name</label>
                        <asp:TextBox ID="txtBankName" runat="server" CssClass="reg-input" placeholder="e.g. HDFC Bank">
                        </asp:TextBox>
                    </div>
                    <div class="form-grp">
                        <label>Registered Account Holder Name</label>
                        <asp:TextBox ID="txtBankHolder" runat="server" CssClass="reg-input"
                            placeholder="Name on passbook"></asp:TextBox>
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-grp">
                        <label>Account Number</label>
                        <asp:TextBox ID="txtBankAccNo" runat="server" CssClass="reg-input" placeholder="Digit string">
                        </asp:TextBox>
                    </div>
                    <div class="form-grp">
                        <label>Indian Financial System Code (IFSC)</label>
                        <asp:TextBox ID="txtBankIfsc" runat="server" CssClass="reg-input"
                            placeholder="e.g. HDFC0001234"></asp:TextBox>
                    </div>
                </div>
            </div>

            <!-- === SECTION 3: MAILING ADDRESS === -->
            <div class="kyc-section">
                <h3 class="kyc-sec-title">
                    <i class="fas fa-map-location-dot" style="color: #10b981;"></i> Registered Address
                </h3>
                <p class="kyc-sec-sub">Primary operating footprint for shipping, return pickings and logistics
                    communication.</p>

                <div class="form-grp">
                    <label>Address Line (Building, Landmark, Street)</label>
                    <asp:TextBox ID="txtAddress" runat="server" CssClass="reg-input"
                        placeholder="Detailed operational address"></asp:TextBox>
                </div>

                <div class="form-row">
                    <div class="form-grp">
                        <label>City</label>
                        <asp:TextBox ID="txtCity" runat="server" CssClass="reg-input" placeholder="Operating City">
                        </asp:TextBox>
                    </div>
                    <div class="form-grp">
                        <label>State / Territory</label>
                        <asp:TextBox ID="txtState" runat="server" CssClass="reg-input" placeholder="State">
                        </asp:TextBox>
                    </div>
                </div>

                <div class="form-row">
                    <div class="form-grp">
                        <label>PIN Area Code</label>
                        <asp:TextBox ID="txtPincode" runat="server" CssClass="reg-input" placeholder="6-Digit Pincode">
                        </asp:TextBox>
                    </div>
                </div>
            </div>

            <!-- SUBMIT PORTFOLIO ACTION -->
            <div class="u-mt-30 kyc-submit-wrap">
                <asp:Button ID="btnSaveKyc" runat="server" CssClass="reg-btn kyc-btn-save"
                    Text="Save & Submit for Review" OnClick="btnSaveKyc_Click"
                    OnClientClick="return confirm('Are you sure you want to lock and submit this portfolio for compliance audit?');" />
            </div>
        </div>

    </asp:Content>