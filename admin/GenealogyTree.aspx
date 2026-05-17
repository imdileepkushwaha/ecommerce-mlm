<%@ Page Title="Genealogy Tree View" Language="C#" MasterPageFile="~/admin/Admin.Master" AutoEventWireup="true"
    CodeFile="GenealogyTree.aspx.cs" Inherits="ecommerce_mlm.admin.GenealogyTree" %>

    <asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
        <style>
            .modal-overlay {
                position: fixed;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
                background: rgba(15, 23, 42, 0.6);
                backdrop-filter: blur(5px);
                display: flex;
                align-items: center;
                justify-content: center;
                z-index: 9999;
                opacity: 0;
                visibility: hidden;
                transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
            }

            .modal-overlay.show {
                opacity: 1;
                visibility: visible;
            }

            .reg-modal {
                background: #fff;
                width: 500px;
                max-width: 90%;
                border-radius: 20px;
                padding: 30px;
                box-shadow: 0 25px 50px -12px rgba(0, 0, 0, 0.25);
                transform: scale(0.95) translateY(15px);
                transition: all 0.3s cubic-bezier(0.34, 1.56, 0.64, 1);
            }

            .modal-overlay.show .reg-modal {
                transform: scale(1) translateY(0);
            }

            .m-hdr {
                display: flex;
                justify-content: space-between;
                align-items: center;
                margin-bottom: 20px;
                padding-bottom: 15px;
                border-bottom: 1.5px solid #f1f5f9;
            }

            .m-title {
                font-size: 18px;
                font-weight: 800;
                color: #0f172a;
                display: flex;
                align-items: center;
                gap: 10px;
            }

            .m-close {
                border: none;
                background: #f1f5f9;
                width: 32px;
                height: 32px;
                border-radius: 50%;
                color: #888888;
                cursor: pointer;
                display: flex;
                align-items: center;
                justify-content: center;
                transition: 0.2s;
            }

            .m-close:hover {
                background: #fee2e2;
                color: #ef4444;
            }

            .grid-inputs {
                display: grid;
                grid-template-columns: 1fr 1fr;
                gap: 15px;
            }
        </style>
    </asp:Content>

    <asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

        <asp:ScriptManager ID="ScriptManager1" runat="server"></asp:ScriptManager>

        <asp:UpdatePanel ID="up1" runat="server">
            <ContentTemplate>

                <div class="u-mb-30 u-d-flex u-j-between u-a-center">
                    <div>
                        <h1 class="u-txt-lg">Network Architecture Viewer</h1>
                        <p class="u-txt-subtitle u-mt-5">Visualize multi-tier downline trees, explore user placements,
                            and perform deep-level genealogy audits.</p>
                    </div>
                </div>

                <!-- ERROR/SUCCESS ALERT PANEL -->
                <asp:Label ID="lblMsg" runat="server" Visible="false" style="border-radius: 12px; font-weight: 600;">
                </asp:Label>

                <!-- MASTER SEARCH BAR & LEGEND PANEL -->
                <div class="table-card u-mb-20"
                    style="padding: 20px; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 20px;">

                    <!-- SEARCH INTERACTION BLOCK -->
                    <div class="u-d-flex u-a-center u-gap-10">
                        <div style="position: relative; width: 260px;">
                            <i class="fas fa-search"
                                style="position: absolute; left: 18px; top: 50%; transform: translateY(-50%); color: #94a3b8; z-index:5;"></i>
                            <asp:TextBox ID="txtSearchUser" runat="server" CssClass="u-input-field"
                                placeholder="Type Username to Search..."
                                style="padding-left: 48px !important; margin: 0; height: 45px !important; font-size: 14px; border-radius: 10px;">
                            </asp:TextBox>
                        </div>
                        <asp:LinkButton ID="btnSearch" runat="server" OnClick="btnSearch_Click" CssClass="btn-primary"
                            style="height: 45px; display: inline-flex; align-items: center; justify-content: center; border-radius: 10px; font-size: 14px; font-weight: 700; gap: 8px; padding: 0 20px; text-decoration:none !important;">
                            <i class="fas fa-sitemap"></i> Load Downlines
                        </asp:LinkButton>
                    </div>

                    <!-- VISUAL STATUS LEGEND MAP -->
                    <div class="u-d-flex u-gap-20"
                        style="background: #f8fafc; border-radius: 10px; padding: 8px 16px; border: 1px solid #e2e8f0;">
                        <div class="u-d-flex u-a-center u-gap-5"
                            style="font-size: 11.5px; font-weight: 700; color: #475569;">
                            <span
                                style="width: 12px; height: 12px; border-radius: 3px; background: #22c55e; border: 1px solid #16a34a; display: inline-block;"></span>
                            ACTIVE NODE
                        </div>
                        <div class="u-d-flex u-a-center u-gap-5"
                            style="font-size: 11.5px; font-weight: 700; color: #475569;">
                            <span
                                style="width: 12px; height: 12px; border-radius: 3px; background: #fee2e2; border: 1px solid #ef4444; display: inline-block;"></span>
                            INACTIVE NODE
                        </div>
                        <div class="u-d-flex u-a-center u-gap-5"
                            style="font-size: 11.5px; font-weight: 700; color: #475569;">
                            <span
                                style="width: 12px; height: 12px; border-radius: 3px; background: #f1f5f9; border: 1px dashed #94a3b8; display: inline-block;"></span>
                            VACANT SLOT
                        </div>
                    </div>

                </div>

                <!-- GENEALOGY CANVAS SECTION -->
                <div class="tree-outer-container" style="position: relative;">
                    <asp:UpdateProgress ID="upg" runat="server" AssociatedUpdatePanelID="up1">
                        <ProgressTemplate>
                            <div
                                style="position: absolute; top:0; left:0; width:100%; height:100%; background:rgba(255,255,255,0.7); z-index:10; display:flex; align-items:center; justify-content:center; font-weight:700; color:#0ea5e9; backdrop-filter:blur(2px);">
                                <i class="fas fa-circle-notch fa-spin u-mr-10"></i> Remapping Hierarchy Graph...
                            </div>
                        </ProgressTemplate>
                    </asp:UpdateProgress>

                    <div class="genealogy-tree">
                        <asp:Literal ID="litTreeOutput" runat="server"></asp:Literal>
                    </div>
                </div>

                <!-- USER ENGAGEMENT SUBTEXT -->
                <div class="u-mt-15 u-mb-30" style="text-align: center; color: #94a3b8; font-size: 12px;">
                    <i class="fas fa-info-circle u-mr-5"></i> Tip: Click <span
                        style="color:#0ea5e9; font-weight:700;"><i class="fas fa-plus-circle"></i> + Add Direct</span>
                    vacant slots to instantly register a member directly under that specific network sponsor node!
                </div>

                <!-- 🏆 MODAL: QUICK DIRECT VISUAL PLACEMENT 🏆 -->
                <div class="modal-overlay" id="modal-quick-reg">
                    <div class="reg-modal">

                        <div class="m-hdr">
                            <div class="m-title"><i class="fas fa-user-plus" style="color:#0ea5e9;"></i> Direct visual
                                Enrollment</div>
                            <button type="button" class="m-close" onclick="closeQuickRegModal()"><i
                                    class="fas fa-times"></i></button>
                        </div>

                        <asp:Panel ID="pnlModalMsg" runat="server" Visible="false"
                            style="border-radius:10px; padding:10px 15px; font-size:12.5px; font-weight:600;">
                        </asp:Panel>
                        <asp:Label ID="lblModalMsg" runat="server" Visible="false"></asp:Label>

                        <p style="font-size:12.5px; color:#64748b; margin-bottom:20px;">
                            You are enrolling a direct member under the selected sponsor. Credentials will be
                            provisioned with full system access instantly.
                        </p>

                        <!-- REGISTRATION FORM GRID -->
                        <asp:HiddenField ID="hfSelectedPosition" runat="server" ClientIDMode="Static" />

                        <div class="form-grp u-mb-15">

                            <label class="settings-label">Pre-Locked Sponsor ID</label>
                            <div style="position:relative;">
                                <i class="fas fa-lock"
                                    style="position:absolute; left:18px; top:50%; transform:translateY(-50%); color:#94a3b8;"></i>
                                <asp:TextBox ID="txtModalSponsor" runat="server" ClientIDMode="Static" ReadOnly="true"
                                    CssClass="u-input-field"
                                    style="padding-left:45px !important; background:#f8fafc; font-weight:700; color:#1e293b; border-color:#cbd5e1; cursor:not-allowed;">
                                </asp:TextBox>
                            </div>
                        </div>

                        <div class="grid-inputs u-mb-15">
                            <div class="form-grp">
                                <label class="settings-label">New Username *</label>
                                <asp:TextBox ID="txtModalUname" runat="server" placeholder="e.g., rohit99"
                                    CssClass="u-input-field" style="margin:0;"></asp:TextBox>
                            </div>
                            <div class="form-grp">
                                <label class="settings-label">Full Legal Name *</label>
                                <asp:TextBox ID="txtModalFullName" runat="server" placeholder="Rohit Sharma"
                                    CssClass="u-input-field" style="margin:0;"></asp:TextBox>
                            </div>
                        </div>

                        <div class="grid-inputs u-mb-15">
                            <div class="form-grp">
                                <label class="settings-label">10-Digit Mobile *</label>
                                <asp:TextBox ID="txtModalMobile" runat="server" placeholder="9876543210"
                                    CssClass="u-input-field" style="margin:0;"></asp:TextBox>
                            </div>
                            <div class="form-grp">
                                <label class="settings-label">Email (Optional)</label>
                                <asp:TextBox ID="txtModalEmail" runat="server" TextMode="Email"
                                    placeholder="rohit@gmail.com" CssClass="u-input-field" style="margin:0;">
                                </asp:TextBox>
                            </div>
                        </div>

                        <div class="form-grp u-mb-25">
                            <label class="settings-label">Login Password *</label>
                            <div style="position:relative;">
                                <i class="fas fa-key"
                                    style="position:absolute; left:18px; top:50%; transform:translateY(-50%); color:#94a3b8;"></i>
                                <asp:TextBox ID="txtModalPass" runat="server" placeholder="••••••••"
                                    CssClass="u-input-field" style="padding-left:45px !important; margin:0;">
                                </asp:TextBox>
                            </div>
                        </div>

                        <!-- ACTION MATRIX -->
                        <div class="u-d-flex u-gap-10">
                            <button type="button" class="btn-outline-primary" onclick="closeQuickRegModal()"
                                style="flex:1; border-radius:10px; font-size:13.5px; height:45px;">Abort</button>
                            <asp:Button ID="btnModalSubmit" runat="server" Text="Commit Enrollment"
                                CssClass="btn-primary" OnClick="btnModalSubmit_Click"
                                style="flex:1.5; border-radius:10px; background:#0ea5e9; border-color:#0ea5e9; font-size:13.5px; height:45px;" />
                        </div>

                    </div>
                </div>

            </ContentTemplate>
        </asp:UpdatePanel>

        <script type="text/javascript">
            // JavaScript to handle opening the registration modal
            function openQuickRegModal(sponsorId, position) {
                if (!sponsorId || sponsorId.trim() === "") {
                    alert("Operational Error: Cannot assign to null sponsor node.");
                    return;
                }
                // Pre-fill locked field
                const spBox = document.getElementById('txtModalSponsor');
                if (spBox) spBox.value = sponsorId;

                // Set target side position to hidden field
                const posBox = document.getElementById('hfSelectedPosition');
                if (posBox) posBox.value = position || 'Left';

                // Open overlays
                const modal = document.getElementById('modal-quick-reg');
                if (modal) modal.classList.add('show');
            }


            function closeQuickRegModal() {
                const modal = document.getElementById('modal-quick-reg');
                if (modal) modal.classList.remove('show');
            }

            // Add standard PageRequestManager hooks for persistence across AJAX update panel updates
            var prm = Sys.WebForms.PageRequestManager.getInstance();
            prm.add_endRequest(function () {
                // Handle re-rendering scenarios if necessary
            });
        </script>

    </asp:Content>