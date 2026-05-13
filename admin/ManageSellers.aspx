<%@ Page Title="Merchant Directory" Language="C#" MasterPageFile="~/admin/Admin.Master" AutoEventWireup="true" CodeFile="ManageSellers.aspx.cs" Inherits="ecommerce_mlm.admin.ManageSellers" %>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <!-- HEADER SECTION -->
    <div class="u-mb-30 u-d-flex u-j-between u-a-center">
        <div>
            <h1 class="u-txt-lg">Merchant Directory</h1>
            <p class="u-txt-subtitle u-mt-5">Monitor profiles, vet eligibility and manage commercial operations.</p>
        </div>
        <div class="u-d-flex u-gap-10">
            <div class="u-search-group" id="searchGroup">
                <input type="text" id="jsSearchInput" placeholder="Search by name, email or state..." onkeyup="filterSellersTable()" class="u-search-box" />
                <i class="fas fa-times u-search-clear" onclick="clearSearch()"></i>
            </div>
        </div>
    </div>

    <!-- SELLERS TABLE -->
    <div class="table-card">
        <div class="table-header">
            <h3 class="u-page-title">Authorized Vendors</h3>
            <asp:Label ID="lblCount" runat="server" CssClass="badge u-badge-count">Live</asp:Label>
        </div>
        <div class="table-responsive">
            <asp:Repeater ID="rptSellers" runat="server" OnItemCommand="rptSellers_ItemCommand">
                <HeaderTemplate>
                    <table class="admin-table">
                        <thead>
                            <tr>
                                <th>ID / Profile</th>
                                <th>Commercial Reach</th>
                                <th>System Integrity</th>
                                <th>KYC / Verification</th>
                                <th>Operator Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                </HeaderTemplate>
                <ItemTemplate>
                    <tr class='<%# Convert.ToBoolean(Eval("IsActive")) ? "" : "u-bg-mute-subtle" %>'>
                        <td>
                            <div class="u-d-flex u-a-center u-gap-12">
                                <div class="u-avatar-sm">
                                    <%# Eval("FullName").ToString().Substring(0, 1).ToUpper() %>
                                </div>
                                <div>
                                    <div class="u-bold-700 u-color-dark"><%# Eval("FullName") %></div>
                                    <div class="u-txt-gray-sm"><i class="fas fa-store u-mr-5"></i>ID: #<%# Eval("Id") %></div>
                                </div>
                            </div>
                        </td>
                        <td>
                            <div class="u-txt-gray-sm"><i class="fas fa-envelope u-mr-5"></i> <%# Eval("Email") %></div>
                            <div class="u-txt-gray-sm u-mt-5"><i class="fas fa-phone u-mr-5"></i> <%# Eval("Mobile") != DBNull.Value ? Eval("Mobile") : "N/A" %></div>
                        </td>
                        <td>
                            <span class='badge <%# Convert.ToBoolean(Eval("IsActive")) ? "badge-success" : "badge-danger" %>'>
                                <%# Convert.ToBoolean(Eval("IsActive")) ? "OPERATIONAL" : "SUSPENDED" %>
                            </span>
                        </td>
                        <td>
                            <span class='badge <%# Eval("KycStatus") != DBNull.Value && Eval("KycStatus").ToString() == "Approved" ? "badge-info" : "badge-warning" %>'>
                                <%# Eval("KycStatus") != DBNull.Value ? Eval("KycStatus") : "Pending" %>
                            </span>
                        </td>
                        <td>
                            <div class="u-d-flex u-gap-8">
                                <a href='#' class="action-btn-circle action-btn-view" title="Deep Audit">
                                    <i class="fas fa-eye"></i>
                                </a>
                                <asp:LinkButton runat="server" CommandName="ToggleStatus" CommandArgument='<%# Eval("Id") %>'
                                    CssClass='<%# Convert.ToBoolean(Eval("IsActive")) ? "action-btn-circle action-btn-block" : "action-btn-circle action-btn-unblock" %>'
                                    ToolTip='<%# Convert.ToBoolean(Eval("IsActive")) ? "Suspend Account" : "Reinstate Account" %>'
                                    OnClientClick='<%# "return confirm(\"Proceed to transition state for this merchant?\");" %>'>
                                    <i class='fas <%# Convert.ToBoolean(Eval("IsActive")) ? "fa-ban" : "fa-check-circle" %>'></i>
                                </asp:LinkButton>
                            </div>
                        </td>
                    </tr>
                </ItemTemplate>
                <FooterTemplate>
                        </tbody>
                    </table>
                </FooterTemplate>
            </asp:Repeater>

            <!-- EMPTY STATE -->
            <div id="jsEmptyState" class="u-empty-state u-d-none">
                <div style="font-size: 3rem; color: #cbd5e1; margin-bottom:15px;">🕵️‍♂️</div>
                <h4>No match found</h4>
                <p>Try relaxing your instant filter criteria.</p>
            </div>
        </div>
    </div>
    
    <script type='text/javascript'>
        function filterSellersTable() {
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
                filterSellersTable(); 
                input.focus();
            }
        }
    </script>
</asp:Content>
