<%@ Page Title="KYC Audit Verification" Language="C#" MasterPageFile="~/admin/Admin.Master" AutoEventWireup="true"
    CodeFile="ViewSellerKyc.aspx.cs" Inherits="ecommerce_mlm.admin.ViewSellerKyc" %>

    <asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
        <style>
            /* Document Preview Action Link */
            .btn-doc-preview {
                display: inline-flex;
                align-items: center;
                gap: 6px;
                font-size: 0.75rem !important;
                font-weight: 800;
                background: #eef2ff;
                color: #4f46e5;
                border: 1px solid #c7d2fe;
                padding: 6px 12px;
                border-radius: 6px;
                text-decoration: none;
                transition: all 0.2s;
                cursor: pointer;
            }

            .btn-doc-preview:hover {
                background: #4f46e5;
                color: #fff !important;
                transform: translateY(-1px);
                box-shadow: 0 4px 6px -1px rgba(79, 70, 229, 0.15);
            }

            /* Advanced Lightbox Backdrop */
            .doc-modal-backdrop {
                position: fixed;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
                background: rgba(15, 23, 42, 0.75);
                backdrop-filter: blur(4px);
                display: flex;
                align-items: center;
                justify-content: center;
                opacity: 0;
                pointer-events: none;
                transition: opacity 0.25s cubic-bezier(0.4, 0, 0.2, 1);
                z-index: 9999;
            }

            .doc-modal-backdrop.show {
                opacity: 1;
                pointer-events: auto;
            }

            /* Lightbox Container */
            .doc-modal-content {
                background: #fff;
                width: 90%;
                max-width: 900px;
                border-radius: 16px;
                box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
                display: flex;
                flex-direction: column;
                max-height: 90vh;
                transform: scale(0.95);
                transition: transform 0.25s cubic-bezier(0.34, 1.56, 0.64, 1);
                overflow: hidden;
            }

            .doc-modal-backdrop.show .doc-modal-content {
                transform: scale(1);
            }

            .doc-modal-header {
                padding: 16px 24px;
                border-bottom: 1px solid #f1f5f9;
                display: flex;
                align-items: center;
                justify-content: space-between;
                background: #f8fafc;
            }

            .doc-modal-header h4 {
                font-weight: 800;
                color: #0f172a;
                margin: 0;
                font-size: 1.1rem;
            }

            .doc-modal-close {
                background: none;
                border: none;
                font-size: 1.5rem;
                color: #888888;
                cursor: pointer;
                padding: 4px 8px;
                border-radius: 6px;
                transition: background 0.2s;
            }

            .doc-modal-close:hover {
                background: #cbd5e1;
                color: #0f172a;
            }

            .doc-modal-body {
                padding: 20px;
                overflow-y: auto;
                background: #f1f5f9;
                display: flex;
                justify-content: center;
                align-items: flex-start;
            }

            .zoomable-image {
                max-width: 100%;
                border-radius: 8px;
                cursor: zoom-in;
                transition: width 0.2s;
                box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
            }

            /* Premium Sidebar Download Asset Links */
            .audit-asset-link {
                display: flex;
                align-items: center;
                justify-content: space-between;
                background: #f8fafc;
                color: #1e293b !important;
                border: 1.5px solid #e2e8f0;
                padding: 14px 16px !important;
                border-radius: 12px !important;
                text-decoration: none !important;
                font-weight: 700 !important;
                font-size: 0.85rem !important;
                transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1);
                box-shadow: 0 1px 2px rgba(0, 0, 0, 0.02);
            }

            .audit-asset-link:hover {
                background: #ffffff !important;
                border-color: #6366f1;
                transform: translateY(-2px);
                box-shadow: 0 10px 15px -3px rgba(99, 102, 241, 0.08), 0 4px 6px -2px rgba(99, 102, 241, 0.04);
                color: #4f46e5 !important;
            }

            .audit-asset-link::after {
                content: '\f08e';
                /* Font Awesome external-link icon */
                font-family: "Font Awesome 5 Pro", "Font Awesome 5 Free", "Font Awesome 6 Free";
                font-weight: 900;
                font-size: 0.75rem;
                color: #94a3b8;
                transition: transform 0.25s, color 0.25s;
                margin-left: 8px;
                display: inline-block;
                font-style: normal;
                font-variant: normal;
                text-rendering: auto;
                -webkit-font-smoothing: antialiased;
            }

            .audit-asset-link:hover::after {
                color: #6366f1;
                transform: translate(2px, -2px);
            }

            .audit-asset-link .fa-file-pdf {
                font-size: 1.1rem;
            }

            .audit-asset-link-disabled {
                opacity: 0.65 !important;
                cursor: not-allowed !important;
                pointer-events: none !important;
                background: #f1f5f9 !important;
                color: #94a3b8 !important;
                border-color: #e2e8f0 !important;
                box-shadow: none !important;
                transform: none !important;
            }

            .audit-asset-link-disabled::after {
                display: none !important;
            }
        </style>
    </asp:Content>


    <asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

        <!-- TOP DIRECTORY HEADER -->
        <div class="u-mb-30 u-d-flex u-j-between u-a-center">
            <div>
                <h1 class="u-txt-lg">KYC Portfolio Audit</h1>
                <p class="u-txt-subtitle u-mt-5">Review legal business documents and approve bank clearing settlements.
                </p>
            </div>
            <div>
                <a href="ManageSellers.aspx" class="badge"
                    style="background:#64748b; padding:10px 16px; text-decoration:none; border-radius:8px; font-weight:700; color:#fff;">
                    <i class="fas fa-arrow-left u-mr-5"></i> Back to Directory
                </a>
            </div>
        </div>

        <asp:Label ID="lblStatus" runat="server" Visible="false"></asp:Label>

        <div style="display: grid; grid-template-columns: 2fr 1fr; gap: 25px;">

            <!-- COLUMN 1: PRIMARY INFORMATION BLOCKS -->
            <div>
                <!-- A. Business and Regulatory Profile -->
                <div class="table-card u-mb-25" style="padding: 30px;">
                    <div
                        style="border-bottom:1.5px solid #f1f5f9; padding-bottom:15px; margin-bottom:20px; display:flex; justify-content:space-between; align-items:center;">
                        <h3 style="font-size:1.2rem; font-weight:800; color:#0f172a;">🏢 Business & Tax Details</h3>
                        <span class="badge" id="spnStatus" runat="server">Review Pending</span>
                    </div>

                    <table class="admin-table" style="border:none;">
                        <tr>
                            <td style="font-weight:700; color:#64748b; width:30%; padding:12px 0;">Legal Business Name
                            </td>
                            <td style="font-weight:600; color:#0f172a; padding:12px 0;">
                                <asp:Literal ID="litStoreName" runat="server"></asp:Literal>
                            </td>
                        </tr>
                        <tr>
                            <td style="font-weight:700; color:#64748b; padding:12px 0;">GST Number</td>
                            <td
                                style="font-weight:600; color:#0f172a; padding:12px 0; display:flex; justify-content:space-between; align-items:center;">
                                <asp:Literal ID="litGst" runat="server">Not Available</asp:Literal>
                                <a id="lnkPopGst" runat="server" visible="false" class="btn-doc-preview"
                                    href="javascript:void(0);" onclick="showAuditDoc(this, 'GST Certificate Audit')">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em"
                                        viewBox="0 0 24 24">
                                        <g fill="none" stroke="currentColor" stroke-width="1.5">
                                            <path stroke-linecap="round"
                                                d="M9 4.46A9.8 9.8 0 0 1 12 4c4.182 0 7.028 2.5 8.725 4.704C21.575 9.81 22 10.361 22 12c0 1.64-.425 2.191-1.275 3.296C19.028 17.5 16.182 20 12 20s-7.028-2.5-8.725-4.704C2.425 14.192 2 13.639 2 12c0-1.64.425-2.191 1.275-3.296A14.5 14.5 0 0 1 5 6.821">
                                            </path>
                                            <path d="M15 12a3 3 0 1 1-6 0a3 3 0 0 1 6 0Z"></path>
                                        </g>
                                    </svg> View Certificate
                                </a>
                            </td>
                        </tr>
                        <tr>
                            <td style="font-weight:700; color:#64748b; padding:12px 0;">PAN Number</td>
                            <td
                                style="font-weight:600; color:#0f172a; padding:12px 0; display:flex; justify-content:space-between; align-items:center;">
                                <asp:Literal ID="litPan" runat="server"></asp:Literal>
                                <a id="lnkPopPan" runat="server" visible="false" class="btn-doc-preview"
                                    href="javascript:void(0);" onclick="showAuditDoc(this, 'PAN Card Document Audit')">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em"
                                        viewBox="0 0 24 24">
                                        <g fill="none" stroke="currentColor" stroke-width="1.5">
                                            <path stroke-linecap="round"
                                                d="M9 4.46A9.8 9.8 0 0 1 12 4c4.182 0 7.028 2.5 8.725 4.704C21.575 9.81 22 10.361 22 12c0 1.64-.425 2.191-1.275 3.296C19.028 17.5 16.182 20 12 20s-7.028-2.5-8.725-4.704C2.425 14.192 2 13.639 2 12c0-1.64.425-2.191 1.275-3.296A14.5 14.5 0 0 1 5 6.821">
                                            </path>
                                            <path d="M15 12a3 3 0 1 1-6 0a3 3 0 0 1 6 0Z"></path>
                                        </g>
                                    </svg> View Card
                                </a>
                            </td>
                        </tr>
                        <tr>
                            <td style="font-weight:700; color:#64748b; padding:12px 0;">Aadhaar Number</td>
                            <td
                                style="font-weight:600; color:#0f172a; padding:12px 0; display:flex; justify-content:space-between; align-items:center;">
                                <asp:Literal ID="litAadhar" runat="server"></asp:Literal>
                                <a id="lnkPopAadhar" runat="server" visible="false" class="btn-doc-preview"
                                    href="javascript:void(0);"
                                    onclick="showAuditDoc(this, 'Aadhaar Card Document Audit')">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em"
                                        viewBox="0 0 24 24">
                                        <g fill="none" stroke="currentColor" stroke-width="1.5">
                                            <path stroke-linecap="round"
                                                d="M9 4.46A9.8 9.8 0 0 1 12 4c4.182 0 7.028 2.5 8.725 4.704C21.575 9.81 22 10.361 22 12c0 1.64-.425 2.191-1.275 3.296C19.028 17.5 16.182 20 12 20s-7.028-2.5-8.725-4.704C2.425 14.192 2 13.639 2 12c0-1.64.425-2.191 1.275-3.296A14.5 14.5 0 0 1 5 6.821">
                                            </path>
                                            <path d="M15 12a3 3 0 1 1-6 0a3 3 0 0 1 6 0Z"></path>
                                        </g>
                                    </svg> View Card
                                </a>
                            </td>
                        </tr>
                    </table>
                </div>

                <!-- B. Bank Settlement Profile -->
                <div class="table-card u-mb-25" style="padding: 30px;">
                    <div style="border-bottom:1.5px solid #f1f5f9; padding-bottom:15px; margin-bottom:20px;">
                        <h3 style="font-size:1.2rem; font-weight:800; color:#0f172a;">🏦 Settlement Bank Account</h3>
                    </div>

                    <table class="admin-table" style="border:none;">
                        <tr>
                            <td style="font-weight:700; color:#64748b; width:30%; padding:12px 0;">Beneficiary Bank</td>
                            <td style="font-weight:600; color:#0f172a; padding:12px 0;">
                                <asp:Literal ID="litBankName" runat="server"></asp:Literal>
                            </td>
                        </tr>
                        <tr>
                            <td style="font-weight:700; color:#64748b; padding:12px 0;">Account Holder Name</td>
                            <td style="font-weight:600; color:#0f172a; padding:12px 0;">
                                <asp:Literal ID="litBankHolder" runat="server"></asp:Literal>
                            </td>
                        </tr>
                        <tr>
                            <td style="font-weight:700; color:#64748b; padding:12px 0;">Account Number</td>
                            <td style="font-weight:600; color:#0f172a; padding:12px 0;">
                                <asp:Literal ID="litBankAccNo" runat="server"></asp:Literal>
                            </td>
                        </tr>
                        <tr>
                            <td style="font-weight:700; color:#64748b; padding:12px 0;">Bank IFSC</td>
                            <td style="font-weight:600; color:#0f172a; padding:12px 0;">
                                <asp:Literal ID="litBankIfsc" runat="server"></asp:Literal>
                            </td>
                        </tr>
                    </table>
                </div>

                <!-- C. Operating Footprint Address -->
                <div class="table-card" style="padding: 30px;">
                    <div style="border-bottom:1.5px solid #f1f5f9; padding-bottom:15px; margin-bottom:20px;">
                        <h3 style="font-size:1.2rem; font-weight:800; color:#0f172a;">📍 Operating Footprint Address
                        </h3>
                    </div>
                    <p style="font-weight:600; font-size:1rem; color:#0f172a; line-height:1.6;">
                        <asp:Literal ID="litAddress" runat="server"></asp:Literal>, <br />
                        <asp:Literal ID="litCity" runat="server"></asp:Literal>,
                        <asp:Literal ID="litState" runat="server"></asp:Literal> - <asp:Literal ID="litPincode"
                            runat="server"></asp:Literal>
                    </p>
                </div>
            </div>

            <!-- COLUMN 2: AUDIT CONTROLS & DOCUMENTS -->
            <div>
                <!-- Document Scan Audit Box -->
                <div class="table-card u-mb-25" style="padding: 25px;">
                    <h4 style="font-weight:800; margin-bottom:15px; color:#0f172a;">📄 Uploaded Assets</h4>

                    <div style="display:flex; flex-direction:column; gap:12px;">
                        <!-- PAN Attachment -->
                        <asp:HyperLink ID="hlPan" runat="server" Target="_blank" CssClass="audit-asset-link">
                            <i class="fas fa-file-pdf u-mr-8" style="color:#ef4444;"></i> View PAN Scan
                        </asp:HyperLink>

                        <!-- Aadhaar Attachment -->
                        <asp:HyperLink ID="hlAadhar" runat="server" Target="_blank" CssClass="audit-asset-link">
                            <i class="fas fa-file-pdf u-mr-8" style="color:#0ea5e9;"></i> View Aadhaar Scan
                        </asp:HyperLink>

                        <!-- GST Attachment -->
                        <asp:HyperLink ID="hlGst" runat="server" Target="_blank" CssClass="audit-asset-link">
                            <i class="fas fa-file-pdf u-mr-8" style="color:#22c55e;"></i> View GST Scan
                        </asp:HyperLink>
                    </div>
                </div>

                <!-- Audit Review Verdict Box -->
                <div class="table-card" style="padding: 25px; background: #f8fafc;">
                    <h4 style="font-weight:800; margin-bottom:10px; color:#0f172a;">⚖️ Audit Decision</h4>
                    <p style="font-size:0.8rem; color:#64748b; line-height:1.4; margin-bottom:20px;">Approval will
                        enable active selling operations, inventory creations and payouts clearance.</p>

                    <div style="display:flex; flex-direction:column; gap:12px;">
                        <asp:Button ID="btnApprove" runat="server" CssClass="badge"
                            style="border:none; cursor:pointer; font-weight:800; background:#22c55e; color:#fff; padding:14px;"
                            Text="✓ Approve Verification" OnClick="btnApprove_Click"
                            OnClientClick="return confirm('Conform operational verification for this partner portfolio?');" />
                        <asp:Button ID="btnReject" runat="server" CssClass="badge"
                            style="border:none; cursor:pointer; font-weight:800; background:#ef4444; color:#fff; padding:14px;"
                            Text="✗ Reject Submission" OnClick="btnReject_Click"
                            OnClientClick="return confirm('Reject this KYC portfolio? Merchant will receive modification alerts.');" />
                    </div>
                </div>
            </div>

        </div>

        <!-- === DYNAMIC AUDIT DOCUMENT LIGHTBOX MODAL === -->
        <div id="docModal" class="doc-modal-backdrop" onclick="closeDocModal(event)">
            <div class="doc-modal-content" onclick="event.stopPropagation()">
                <div class="doc-modal-header">
                    <h4 id="docModalTitle">Document Verification View</h4>
                    <button type="button" class="doc-modal-close" onclick="closeDocModalForce()">&times;</button>
                </div>
                <div class="doc-modal-body" id="docModalBody">
                    <!-- Native Embed Dynamic Injection Point -->
                </div>
            </div>
        </div>

        <script type="text/javascript">
            function showAuditDoc(anchor, title) {
                const url = anchor.getAttribute('data-docurl');
                if (!url) return;

                document.getElementById('docModalTitle').innerText = title;
                const body = document.getElementById('docModalBody');

                // Detect extension and render viewport
                const ext = url.split('.').pop().toLowerCase();
                if (ext === 'pdf') {
                    body.innerHTML = `<iframe src="${url}" style="width:100%; height:75vh; border:none; border-radius:8px; background:#fff;"></iframe>`;
                } else {
                    body.innerHTML = `<div style="width:100%; overflow:auto; text-align:center; max-height:75vh;"><img src="${url}" class="zoomable-image" onclick="toggleZoom(this)" title="Click to zoom full scale" /></div>`;
                }

                document.getElementById('docModal').classList.add('show');
            }

            function toggleZoom(img) {
                if (img.style.width === '100%' || img.style.width === '') {
                    img.style.width = 'auto';
                    img.style.maxWidth = 'none';
                    img.style.cursor = 'zoom-out';
                } else {
                    img.style.width = '100%';
                    img.style.maxWidth = '100%';
                    img.style.cursor = 'zoom-in';
                }
            }

            function closeDocModalForce() {
                document.getElementById('docModal').classList.remove('show');
                // Flush frame memory reference on close
                setTimeout(() => {
                    document.getElementById('docModalBody').innerHTML = '';
                }, 250);
            }

            function closeDocModal(e) {
                if (e.target.id === 'docModal') {
                    closeDocModalForce();
                }
            }
        </script>

    </asp:Content>