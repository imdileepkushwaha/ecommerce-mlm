<%@ Page Title="Merchant Account Profile" Language="C#" MasterPageFile="~/seller/Seller.Master" AutoEventWireup="true"
    CodeFile="Profile.aspx.cs" Inherits="EcommerceWebsite.SellerProfile" ValidateRequest="false" %>

    <asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    </asp:Content>

    <asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

        <!-- ALERT MESSAGE NOTIFICATIONS -->
        <div style="margin-bottom: 15px;">
            <asp:Label ID="lblMsg" runat="server" Visible="false" CssClass="prof-alert-box">
            </asp:Label>
        </div>

        <!-- EXECUTIVE HEADER DECK -->
        <div class="prof-header-bar">
            <div class="prof-header-title">
                <h2>Profile</h2>
                <p>Yahan <strong>contact & branding</strong> update hoti hai. GST, bank, docs — sab <strong>KYC &
                        Bank</strong> page par.</p>
            </div>
            <div class="prof-actions-cluster">
                <asp:HyperLink ID="lnkViewStore" runat="server" CssClass="prof-btn-outline" Target="_blank">
                    <i class="far fa-eye"></i> View store
                </asp:HyperLink>
                <a href="Kyc.aspx" class="prof-btn-danger">
                    <i class="fas fa-id-card-clip"></i> KYC & Bank
                </a>
            </div>
        </div>

        <!-- SECTION 1: STATUS DECK -->
        <div class="status-deck">
            <!-- Card 1: KYC Status -->
            <div class="status-card sc-purple">
                <div class="sc-content">
                    <span>KYC SUBMITTED</span>
                    <h3>
                        <asp:Literal ID="litKycSub" runat="server">No</asp:Literal>
                    </h3>
                    <p>Updated: <asp:Literal ID="litKycUpdate" runat="server">--</asp:Literal>
                    </p>
                </div>
                <div class="sc-icon-box"><i class="fas fa-shield-halved"></i></div>
            </div>

            <!-- Card 2: Final Approval Status -->
            <div class="status-card sc-green">
                <div class="sc-content">
                    <span>FINAL APPROVAL</span>
                    <h3>
                        <asp:Literal ID="litApproval" runat="server">Pending</asp:Literal>
                    </h3>
                    <p>Reviewed: <asp:Literal ID="litReviewDate" runat="server">--</asp:Literal>
                    </p>
                </div>
                <div class="sc-icon-box"><i class="fas fa-circle-check"></i></div>
            </div>

            <!-- Card 3: Edit Requests -->
            <div class="status-card sc-blue">
                <div class="sc-content">
                    <span>KYC EDIT REQUEST</span>
                    <h3>
                        <asp:Literal ID="litEditReq" runat="server">None</asp:Literal>
                    </h3>
                    <p>Requested: --</p>
                </div>
                <div class="sc-icon-box"><i class="fas fa-pencil-alt"></i></div>
            </div>
        </div>

        <!-- SECTION 2: ACCOUNT & IDENTITY (READ-ONLY SNAPSHOT) -->
        <div class="prof-section">
            <div class="prof-sec-head">
                <div>
                    <h3>Account & Identity</h3>
                    <p>KYC se aayi hui fields read-only yahan dikhti hain. Sirf phone / address / branding neeche wale
                        form se badal sakte ho.</p>
                </div>
            </div>
            <div class="prof-sec-body">
                <div class="data-pills-grid">
                    <div class="data-box">
                        <span class="data-lbl">Full name</span>
                        <span class="data-val">
                            <asp:Literal ID="litFullName" runat="server"></asp:Literal>
                        </span>
                    </div>
                    <div class="data-box">
                        <span class="data-lbl">Email</span>
                        <span class="data-val">
                            <asp:Literal ID="litEmail" runat="server"></asp:Literal>
                            <i class="fas fa-circle-check icon-verify-check" runat="server" id="chkEmailVerify"
                                visible="false"></i>
                        </span>
                    </div>
                    <div class="data-box">
                        <span class="data-lbl">Business name</span>
                        <span class="data-val">
                            <asp:Literal ID="litStoreName" runat="server"></asp:Literal>
                        </span>
                    </div>
                    <div class="data-box">
                        <span class="data-lbl">Phone (on file)</span>
                        <span class="data-val">
                            <asp:Literal ID="litPhoneFile" runat="server"></asp:Literal>
                            <i class="fas fa-circle-check icon-verify-check"></i>
                        </span>
                    </div>

                    <div class="data-box data-pill-full">
                        <span class="data-lbl">Business address (on file)</span>
                        <span class="data-val">
                            <asp:Literal ID="litAddressFile" runat="server"></asp:Literal>
                        </span>
                    </div>

                    <div class="data-box">
                        <span class="data-lbl">Allowed categories</span>
                        <span class="data-val">
                            <asp:Literal ID="litCats" runat="server"></asp:Literal>
                        </span>
                    </div>
                    <div class="data-box">
                        <span class="data-lbl">GST number</span>
                        <span class="data-val">
                            <asp:Literal ID="litGstNum" runat="server">--</asp:Literal>
                        </span>
                    </div>
                    <div class="data-box">
                        <span class="data-lbl">PAN number</span>
                        <span class="data-val">
                            <asp:Literal ID="litPanNum" runat="server">--</asp:Literal>
                        </span>
                    </div>
                    <div class="data-box">
                        <span class="data-lbl">Aadhaar number</span>
                        <span class="data-val">
                            <asp:Literal ID="litAadharNum" runat="server">--</asp:Literal>
                        </span>
                    </div>
                    <div class="data-box">
                        <span class="data-lbl">ID proof</span>
                        <span class="data-val">
                            <asp:Literal ID="litIdProofType" runat="server">Aadhaar</asp:Literal> • <asp:Literal
                                ID="litIdProofNum" runat="server">--</asp:Literal>
                        </span>
                    </div>
                </div>
            </div>
        </div>

        <!-- SECTION 3: STORE BRANDING (PREVIEW SHOWCASE) -->
        <div class="prof-section">
            <div class="prof-sec-head">
                <div>
                    <h3>Store Branding</h3>
                    <p>Logo square, banner wide — buyer storefront par dikhta hain.</p>
                </div>
            </div>
            <div class="prof-sec-body">
                <div class="branding-layout">
                    <div>
                        <span class="form-lbl prof-sub-heading">LOGO</span>
                        <div class="brand-logo-frame">
                            <asp:Image ID="imgPreviewLogo" runat="server"
                                ImageUrl="https://via.placeholder.com/200?text=No+Logo" />
                        </div>
                    </div>
                    <div>
                        <span class="form-lbl prof-sub-heading">BANNER</span>
                        <div class="brand-banner-frame">
                            <asp:Image ID="imgPreviewBanner" runat="server"
                                ImageUrl="https://via.placeholder.com/800x200?text=No+Banner" />
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- SECTION 4: QUICK EDITS (INTERACTIVE MUTATION CONTAINER) -->
        <div class="prof-section">
            <div class="prof-sec-head">
                <div>
                    <h3>Quick Edits</h3>
                    <p>Phone, address, logo, banner. Baaki changes ke liye KYC & Bank kholo.</p>
                </div>
            </div>
            <div class="prof-sec-body">
                <div class="edit-form-grid">
                    <!-- Field 1: Phone Number -->
                    <div class="form-item">
                        <label class="form-lbl">Phone number</label>
                        <asp:TextBox ID="txtPhone" runat="server" CssClass="prof-input" placeholder="9876543210">
                        </asp:TextBox>
                    </div>

                    <!-- Field 2: Store Business Address -->
                    <div class="form-item">
                        <label class="form-lbl">Business address</label>
                        <asp:TextBox ID="txtAddress" runat="server" CssClass="prof-input prof-textarea" TextMode="MultiLine" Rows="1"
                            placeholder="Enter updated address"></asp:TextBox>
                    </div>

                    <!-- Field 3: Logo File Streamer -->
                    <div class="form-item">
                        <label class="form-lbl">Logo file</label>
                        <div class="file-upload-zone">
                            <asp:FileUpload ID="fuLogo" runat="server" CssClass="fu-ctrl" />
                            <span class="fu-sub">JPG / PNG / WebP / GIF • max <strong>5 MB</strong> • square
                                suggested</span>
                        </div>
                    </div>

                    <!-- Field 4: Banner File Streamer -->
                    <div class="form-item">
                        <label class="form-lbl">Banner file</label>
                        <div class="file-upload-zone">
                            <asp:FileUpload ID="fuBanner" runat="server" CssClass="fu-ctrl" />
                            <span class="fu-sub">Wide ratio • max <strong>5 MB</strong></span>
                        </div>
                    </div>
                </div>

                <div class="prof-submit-row">
                    <asp:Button ID="btnSave" runat="server" Text="Save changes" CssClass="prof-btn-danger"
                        OnClick="btnSave_Click" />
                </div>
            </div>
        </div>

        <!-- SECTION 5: BANK & DOCUMENTS (READ-ONLY REPOSITORY) -->
        <div class="prof-section">
            <div class="prof-sec-head">
                <div>
                    <h3>Bank & Documents</h3>
                    <p>Read-only snapshot. Update flow KYC & Bank par.</p>
                </div>
                <div>
                    <a href="Kyc.aspx" class="prof-btn-outline prof-btn-sm">Open KYC</a>
                </div>
            </div>
            <div class="prof-sec-body">
                <div class="data-pills-grid">
                    <div class="data-box">
                        <span class="data-lbl">Bank name</span>
                        <span class="data-val">
                            <asp:Literal ID="litBankName" runat="server">--</asp:Literal>
                        </span>
                    </div>
                    <div class="data-box">
                        <span class="data-lbl">Account holder</span>
                        <span class="data-val">
                            <asp:Literal ID="litBankHolder" runat="server">--</asp:Literal>
                        </span>
                    </div>
                    <div class="data-box">
                        <span class="data-lbl">Account number</span>
                        <span class="data-val">
                            <asp:Literal ID="litBankAccNum" runat="server">--</asp:Literal>
                        </span>
                    </div>
                    <div class="data-box">
                        <span class="data-lbl">IFSC</span>
                        <span class="data-val">
                            <asp:Literal ID="litBankIfsc" runat="server">--</asp:Literal>
                        </span>
                    </div>

                    <div class="data-box data-pill-full">
                        <span class="data-lbl">Registered address</span>
                        <span class="data-val">
                            <asp:Literal ID="litBankAddress" runat="server">--</asp:Literal>
                        </span>
                    </div>

                    <!-- Direct PDF Document Anchors -->
                    <div class="data-box">
                        <span class="data-lbl">GST document</span>
                        <div class="data-val prof-doc-val">
                            <asp:HyperLink ID="lnkGstDoc" runat="server" CssClass="doc-btn-open" Target="_blank"
                                Visible="false">Open</asp:HyperLink>
                            <span class="doc-badge-na" runat="server" id="lblGstNa">Not loaded</span>
                        </div>
                    </div>
                    <div class="data-box">
                        <span class="data-lbl">PAN document</span>
                        <div class="data-val prof-doc-val">
                            <asp:HyperLink ID="lnkPanDoc" runat="server" CssClass="doc-btn-open" Target="_blank"
                                Visible="false">Open</asp:HyperLink>
                            <span class="doc-badge-na" runat="server" id="lblPanNa">Not loaded</span>
                        </div>
                    </div>
                    <div class="data-box">
                        <span class="data-lbl">Aadhaar document</span>
                        <div class="data-val prof-doc-val">
                            <asp:HyperLink ID="lnkAadharDoc" runat="server" CssClass="doc-btn-open" Target="_blank"
                                Visible="false">Open</asp:HyperLink>
                            <span class="doc-badge-na" runat="server" id="lblAadharNa">Not loaded</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>

    </asp:Content>