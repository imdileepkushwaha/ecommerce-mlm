<%@ Page Title="KYC Compliance Audits" Language="C#" MasterPageFile="~/admin/Admin.Master" AutoEventWireup="true" CodeFile="KycAudits.aspx.cs" Inherits="ecommerce_mlm.admin.KycAudits" %>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <!-- HEADER SECTION -->
    <div class="u-mb-30 u-d-flex u-j-between u-a-center">
        <div>
            <h1 class="u-txt-lg">KYC Submission Audits</h1>
            <p class="u-txt-subtitle u-mt-5">Review pending legal documents and process onboarding approvals.</p>
        </div>
        <div class="u-d-flex u-gap-10">
            <div class="u-search-group" id="searchGroup">
                <input type="text" id="jsSearchInput" placeholder="Filter pending audits..." onkeyup="filterKycTable()" class="u-search-box" />
                <i class="fas fa-times u-search-clear" onclick="clearSearch()"></i>
            </div>
        </div>
    </div>

    <!-- KYC TABLE -->
    <div class="table-card">
        <div class="table-header">
            <h3 class="u-page-title">Awaiting Compliance Verification</h3>
            <asp:Label ID="lblCount" runat="server" CssClass="badge u-badge-count">0 Pending</asp:Label>
        </div>
        <div class="table-responsive">
            <asp:Repeater ID="rptKyc" runat="server">
                <HeaderTemplate>
                    <table class="admin-table">
                        <thead>
                            <tr>
                                <th>Merchant Profile</th>
                                <th>Company Identity</th>
                                <th>Contact Core</th>
                                <th>Queue Timestamp</th>
                                <th>Audit Console</th>
                            </tr>
                        </thead>
                        <tbody>
                </HeaderTemplate>
                <ItemTemplate>
                    <tr>
                        <td>
                            <div class="u-d-flex u-a-center u-gap-12">
                                <div class="u-avatar-sm" style="background:#eef2ff; color:#6366f1; border: 1px solid #c7d2fe; font-weight:800;">
                                    <%# Eval("FullName").ToString().Substring(0, 1).ToUpper() %>
                                </div>
                                <div>
                                    <div class="u-bold-700 u-color-dark"><%# Eval("FullName") %></div>
                                    <div class="u-txt-gray-sm"><i class="fas fa-fingerprint u-mr-5"></i>MID: #<%# Eval("Id") %></div>
                                </div>
                            </div>
                        </td>
                        <td>
                            <div class="u-bold-600 u-color-dark"><%# Eval("StoreName") != DBNull.Value ? Eval("StoreName") : "Draft Profile" %></div>
                            <div class="u-txt-gray-sm u-mt-5"><i class="fas fa-file-invoice u-mr-5"></i>GST: <%# (Eval("GstNumber") != DBNull.Value && !string.IsNullOrEmpty(Eval("GstNumber").ToString())) ? Eval("GstNumber") : "None" %></div>
                        </td>
                        <td>
                            <div class="u-txt-gray-sm"><i class="fas fa-envelope u-mr-5"></i> <%# Eval("Email") %></div>
                            <div class="u-txt-gray-sm u-mt-5"><i class="fas fa-phone u-mr-5"></i> <%# Eval("Phone") %></div>
                        </td>
                        <td>
                            <div class="u-txt-gray-sm"><i class="fas fa-clock u-mr-5"></i> <%# Eval("UpdatedAt", "{0:dd MMM yyyy hh:mm tt}") %></div>
                            <%# GetQueueBadge(Eval("KycStatus"), Eval("EditRequestStatus")) %>

                        </td>
                        <td>
                            <div class="u-d-flex u-gap-8">
                                <a href='ViewSellerKyc.aspx?id=<%# Eval("Id") %>' class="badge" style="background:#6366f1; color:#fff; text-decoration:none; font-weight:700; padding: 8px 16px; border-radius:6px; display:inline-flex; align-items:center; gap: 6px;">
                                    <i class="fas fa-magnifying-glass-chart"></i> Deep Audit
                                </a>
                            </div>
                        </td>
                    </tr>
                </ItemTemplate>
                <FooterTemplate>
                        </tbody>
                    </table>
                </FooterTemplate>
            </asp:Repeater>

            <!-- EMPTY STATE FOR PENDING RUN QUEUE -->
            <asp:PlaceHolder ID="phEmptyState" runat="server" Visible="false">
                <div class="u-empty-state" style="padding: 50px 20px;">
                    <div style="font-size: 3.5rem; color: #cbd5e1; margin-bottom:20px;">🎉</div>
                    <h4 style="font-weight:800; color:#0f172a; margin-bottom:5px;">All Caught Up!</h4>
                    <p style="color:#64748b; font-size:0.9rem;">No pending merchant KYC verification requests are currently in the audit queue.</p>
                </div>
            </asp:PlaceHolder>

            <!-- EMPTY SEARCH MATCH -->
            <div id="jsEmptyState" class="u-empty-state u-d-none" style="padding: 50px 20px;">
                <div style="font-size: 3rem; color: #cbd5e1; margin-bottom:15px;">🕵️‍♂️</div>
                <h4>No matching requests</h4>
                <p>Try relaxing your instant search terms.</p>
            </div>
        </div>
    </div>
    
    <script type='text/javascript'>
        function filterKycTable() {
            const input = document.getElementById('jsSearchInput');
            const group = document.getElementById('searchGroup');
            const filter = input.value.toUpperCase();
            
            if(group) {
                if(filter.length > 0) group.classList.add('has-val');
                else group.classList.remove('has-val');
            }
            
            const tableEl = document.querySelector('.admin-table');
            const emptyEl = document.getElementById('jsEmptyState');
            const tbody = tableEl ? tableEl.querySelector('tbody') : null;
            
            if (!tbody || !tableEl) return;
            
            const rows = tbody.getElementsByTagName('tr');
            let visibleCount = 0;
            
            for (let i = 0; i < rows.length; i++) {
                const rowText = rows[i].innerText.toUpperCase();
                if (rowText.indexOf(filter) > -1) {
                    rows[i].classList.remove('u-d-none');
                    visibleCount++;
                } else {
                    rows[i].classList.add('u-d-none');
                }
            }
            
            if (visibleCount === 0) {
                tableEl.classList.add('u-d-none'); 
                if(emptyEl) emptyEl.classList.remove('u-d-none');
            } else {
                tableEl.classList.remove('u-d-none');
                if(emptyEl) emptyEl.classList.add('u-d-none');
            }
            
            const countBadge = document.getElementById('<%= lblCount.ClientID %>');
            if (countBadge) {
                countBadge.innerText = 'Filtered: ' + visibleCount;
            }
        }

        function clearSearch() {
            const input = document.getElementById('jsSearchInput');
            if(input) {
                input.value = '';
                filterKycTable(); 
                input.focus();
            }
        }
    </script>
</asp:Content>
