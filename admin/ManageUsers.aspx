<%@ Page Title="Manage System Users" Language="C#" MasterPageFile="~/admin/Admin.Master" AutoEventWireup="true" CodeFile="ManageUsers.aspx.cs" Inherits="ecommerce_mlm.admin.ManageUsers" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="u-mb-30 u-j-between u-a-center">
        <div>
            <h1 class="u-txt-lg">Users Directory</h1>
            <p class="u-txt-subtitle u-mt-5">Audit and manage registered infrastructure consumers.</p>
        </div>
        <div class="u-d-flex u-gap-10">
            <div class="u-search-group" id="searchGroup">
                <input type="text" id="jsSearchInput" placeholder="Search by email or username..." onkeyup="filterUsersTable()" class="u-search-box" />
                <i class="fas fa-times u-search-clear" onclick="clearSearch()"></i>
            </div>
        </div>
    </div>

    <div class="table-card">
        <div class="table-header">
            <h3 class="u-page-title">Member Records</h3>
            <asp:Label ID="lblCount" runat="server" CssClass="badge u-badge-count">Total: 0</asp:Label>
        </div>
        <div class="table-responsive">
            <asp:Repeater ID="rptUsers" runat="server" OnItemCommand="rptUsers_ItemCommand">
                <HeaderTemplate>
                    <table class="admin-table">
                        <thead>
                            <tr>
                                <th>Member Identification</th>
                                <th>Username / ID</th>
                                <th>Contact Coordinate</th>
                                <th>Registration Date</th>
                                <th>Active Status</th>
                                <th>Controls</th>
                            </tr>
                        </thead>
                        <tbody>
                </HeaderTemplate>
                <ItemTemplate>
                    <tr>
                        <td>
                            <div class="user-mini">
                                <div class="u-circle">
                                    <%# GetInitials(Eval("FullName").ToString()) %>
                                </div>
                                <div>
                                    <div class="u-bold-700 u-color-dark"><%# Eval("FullName") %></div>
                                    <div class="u-txt-gray-sm">Ref: <%# Eval("SponsorName") %></div>
                                </div>
                            </div>
                        </td>
                        <td>
                            <span class="u-mono-block">
                                <%# Eval("Username") %>
                            </span>
                        </td>
                        <td>
                            <div class="u-txt-085"><i class="far fa-envelope u-color-gray-500"></i> <%# Eval("Email") %></div>
                            <div class="u-txt-085 u-mt-2"><i class="fas fa-phone u-color-gray-500 u-txt-085"></i> <%# Eval("Mobile") %></div>
                        </td>
                        <td class="u-txt-gray-sm u-txt-085">
                            <%# Convert.ToDateTime(Eval("CreatedAt")).ToString("dd MMM yyyy") %>
                        </td>
                        <td>
                            <span class='badge <%# Convert.ToBoolean(Eval("IsActive")) ? "badge-success" : "badge-danger" %>'>
                                <%# Convert.ToBoolean(Eval("IsActive")) ? "Active" : "Suspended" %>
                            </span>
                        </td>
                        <td class="u-w-full u-nowrap u-w-auto">
                            <div class="u-d-flex u-gap-8">
                                <a href='UserDetails.aspx?uid=<%# Eval("Id") %>' class="action-btn-circle action-btn-view" title="View Profile">
                                    <svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" viewBox="0 0 24 24"><g fill="none" stroke="currentColor" stroke-width="1.5"><path stroke-linecap="round" d="M9 4.46A9.8 9.8 0 0 1 12 4c4.182 0 7.028 2.5 8.725 4.704C21.575 9.81 22 10.361 22 12c0 1.64-.425 2.191-1.275 3.296C19.028 17.5 16.182 20 12 20s-7.028-2.5-8.725-4.704C2.425 14.192 2 13.639 2 12c0-1.64.425-2.191 1.275-3.296A14.5 14.5 0 0 1 5 6.821"></path><path d="M15 12a3 3 0 1 1-6 0a3 3 0 0 1 6 0Z"></path></g></svg>
                                </a>
                                
                                <asp:LinkButton ID="btnToggleStatus" runat="server" CommandName="ToggleStatus" CommandArgument='<%# Eval("Id") %>' 
                                    CssClass='<%# Convert.ToBoolean(Eval("IsActive")) ? "action-btn-circle action-btn-block" : "action-btn-circle action-btn-unblock" %>'
                                    ToolTip='<%# Convert.ToBoolean(Eval("IsActive")) ? "Block User" : "Activate User" %>'>
                                    <i class='<%# Convert.ToBoolean(Eval("IsActive")) ? "fas fa-user-slash" : "fas fa-user-check" %>'></i>
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
            <!-- Bulletproof Client-Side Empty State Indicator -->
            <div id="jsEmptyState" class="u-empty-state u-d-none">
                <div style="padding:60px; text-align:center;">
                    <i class="fas fa-search-minus u-empty-icon" style="color:#cbd5e1; font-size:4rem;"></i>
                    <h3 class="u-color-dark u-mb-15">No Matches Located</h3>
                    <p class="u-txt-subtitle">Adjust your search criteria to locate target node records.</p>
                </div>
            </div>

            <asp:Panel ID="pnlEmpty" runat="server" Visible="false" CssClass="u-empty-state">
                <i class="fas fa-users-slash u-empty-icon"></i>
                <h4>No users stored in primary infrastructure database.</h4>
            </asp:Panel>
        </div>
    </div>
    <script type='text/javascript'>
        function filterUsersTable() {
            const input = document.getElementById('jsSearchInput');
            const group = document.getElementById('searchGroup');
            const filter = input.value.toUpperCase();
            
            // Toggle clear button
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
            
            // Bulletproof Toggle
            if (visibleCount === 0) {
                tableEl.classList.add('u-d-none'); // Hide whole table!
                if(emptyEl) emptyEl.classList.remove('u-d-none'); // Show big empty pnl!
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
                filterUsersTable(); // re-run logic to reset list
                input.focus();
            }
        }
    </script>
</asp:Content>
