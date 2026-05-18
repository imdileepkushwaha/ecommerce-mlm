<%@ Page Title="Users" Language="C#" MasterPageFile="~/admin/Admin.Master" AutoEventWireup="true" CodeFile="ManageUsers.aspx.cs" Inherits="ecommerce_mlm.admin.ManageUsers" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
    <link rel="stylesheet" href="assets/css/admin-users.css?v=1.2" />
</asp:Content>

<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="mu-page">
        <span class="mu-overline">SHOP</span>
        <h1 class="mu-title">Users</h1>
        <p class="mu-sub">Registered customer accounts and profile details.</p>

        <asp:Panel ID="pnlFlash" runat="server" Visible="false" CssClass="mu-flash">
            <i runat="server" id="icoFlash" class="fas fa-check-circle"></i>
            <asp:Literal ID="litFlash" runat="server" />
        </asp:Panel>

        <!-- KPI cards -->
        <div class="mu-kpi-grid">
            <div class="mu-kpi-card mu-kpi-blue">
                <div class="mu-kpi-body">
                    <label>ALL USERS</label>
                    <strong><asp:Literal ID="litAllUsers" runat="server" Text="0" /></strong>
                    <span>Registered accounts</span>
                </div>
                <div class="mu-kpi-ico"><i class="fas fa-users"></i></div>
            </div>
            <div class="mu-kpi-card mu-kpi-green">
                <div class="mu-kpi-body">
                    <label>PHONE ON FILE</label>
                    <strong><asp:Literal ID="litPhoneOnFile" runat="server" Text="0" /></strong>
                    <span>Contact number saved</span>
                </div>
                <div class="mu-kpi-ico"><i class="fas fa-mobile-alt"></i></div>
            </div>
            <div class="mu-kpi-card mu-kpi-purple">
                <div class="mu-kpi-body">
                    <label>BIRTHDAY SET</label>
                    <strong><asp:Literal ID="litBirthdaySet" runat="server" Text="0" /></strong>
                    <span>Date of birth on profile</span>
                </div>
                <div class="mu-kpi-ico"><i class="fas fa-calendar-alt"></i></div>
            </div>
            <div class="mu-kpi-card mu-kpi-indigo">
                <div class="mu-kpi-body">
                    <label>NEW (30 DAYS)</label>
                    <strong><asp:Literal ID="litNewUsers" runat="server" Text="0" /></strong>
                    <span>Recently joined</span>
                </div>
                <div class="mu-kpi-ico"><i class="fas fa-user-plus"></i></div>
            </div>
        </div>

        <!-- Table -->
        <div class="mu-table-card">
            <div class="mu-table-toolbar">
                <div class="mu-table-toolbar-left">
                    <h3>All Users</h3>
                    <p><asp:Literal ID="litTableHint" runat="server" /></p>
                </div>
                <div class="mu-search-wrap" id="searchGroup">
                    <i class="fas fa-search"></i>
                    <asp:TextBox ID="txtSearch" runat="server" CssClass="mu-search-input" placeholder="Search name, email, phone, ID..." ClientIDMode="Static" />
                    <button type="button" class="mu-search-clear" onclick="clearSearch();" aria-label="Clear search">
                        <i class="fas fa-times"></i>
                    </button>
                </div>
            </div>

            <div class="mu-table-scroll">
                <asp:Repeater ID="rptUsers" runat="server" OnItemCommand="rptUsers_ItemCommand">
                    <HeaderTemplate>
                        <table class="mu-users-table" id="usersTable">
                            <thead>
                                <tr>
                                    <th>ID</th>
                                    <th>Name</th>
                                    <th>Email</th>
                                    <th>Phone</th>
                                    <th>Gender</th>
                                    <th>DOB</th>
                                    <th>Created</th>
                                    <th class="mu-th-actions">Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                    </HeaderTemplate>
                    <ItemTemplate>
                        <tr class='mu-user-row <%# Convert.ToBoolean(Eval("IsActive")) ? "" : "mu-row-suspended" %>'>
                            <td><span class="mu-id">#<%# Eval("Id") %></span></td>
                            <td>
                                <div class="mu-name-cell">
                                    <span class="mu-avatar"><%# GetInitials(Eval("FullName")) %></span>
                                    <a href='UserDetails.aspx?uid=<%# Eval("Id") %>' class="mu-name-link"><%# Eval("FullName") %></a>
                                </div>
                            </td>
                            <td><%# Eval("Email") %></td>
                            <td><%# FormatPhone(Eval("Mobile")) %></td>
                            <td><%# FormatGender(Eval("Gender")) %></td>
                            <td><%# FormatDob(Eval("Dob")) %></td>
                            <td class="mu-created"><%# FormatCreated(Eval("CreatedAt")) %></td>
                            <td>
                                <div class="mu-actions">
                                    <a href='UserDetails.aspx?uid=<%# Eval("Id") %>' class="action-btn-circle action-btn-view" title="View profile">
                                        <svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" viewBox="0 0 24 24"><g fill="none" stroke="currentColor" stroke-width="1.5"><path stroke-linecap="round" d="M9 4.46A9.8 9.8 0 0 1 12 4c4.182 0 7.028 2.5 8.725 4.704C21.575 9.81 22 10.361 22 12c0 1.64-.425 2.191-1.275 3.296C19.028 17.5 16.182 20 12 20s-7.028-2.5-8.725-4.704C2.425 14.192 2 13.639 2 12c0-1.64.425-2.191 1.275-3.296A14.5 14.5 0 0 1 5 6.821"></path><path d="M15 12a3 3 0 1 1-6 0a3 3 0 0 1 6 0Z"></path></g></svg>
                                    </a>
                                    <asp:LinkButton runat="server" CommandName="ToggleStatus" CommandArgument='<%# Eval("Id") %>'
                                        CssClass='<%# Convert.ToBoolean(Eval("IsActive")) ? "action-btn-circle action-btn-block" : "action-btn-circle action-btn-unblock" %>'
                                        ToolTip='<%# Convert.ToBoolean(Eval("IsActive")) ? "Suspend account" : "Reactivate account" %>'
                                        OnClientClick='<%# Convert.ToBoolean(Eval("IsActive")) ? "return confirm(\"Suspend this user? They will not be able to sign in until reactivated.\");" : "return confirm(\"Reactivate this user account?\");" %>'>
                                        <i class='fas <%# Convert.ToBoolean(Eval("IsActive")) ? "fa-user-slash" : "fas fa-user-check" %>'></i>
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

                <asp:Panel ID="pnlEmpty" runat="server" Visible="false" CssClass="mu-empty-state">
                    <div class="mu-empty-ico mu-empty-ico-muted"><i class="fas fa-users-slash"></i></div>
                    <h4 class="mu-empty-title">No users yet</h4>
                    <p class="mu-empty-desc">Registered customers will appear here once they sign up.</p>
                </asp:Panel>

                <div id="jsEmptyState" class="mu-empty-state u-d-none" aria-live="polite">
                    <div class="mu-empty-ico"><i class="fas fa-search"></i></div>
                    <h4 class="mu-empty-title">No matches on this page</h4>
                    <p class="mu-empty-desc">Nothing matches <strong id="jsEmptyQuery"></strong>. Try another name, email, phone, or ID.</p>
                    <button type="button" class="mu-empty-btn" onclick="clearSearch();">
                        <i class="fas fa-times"></i> Clear search
                    </button>
                </div>
            </div>

            <div class="mu-table-foot">
                <div class="mu-table-foot-left">
                    <asp:Literal ID="litShowing" runat="server" Text="Showing 0 of 0" />
                </div>
                <div class="mu-table-foot-right">
                    <div class="mu-per-page">
                        <span>Per page</span>
                        <asp:DropDownList ID="ddlPageSize" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlPageSize_SelectedIndexChanged" ClientIDMode="Static">
                            <asp:ListItem Text="10" Value="10" />
                            <asp:ListItem Text="25" Value="25" Selected="True" />
                            <asp:ListItem Text="50" Value="50" />
                            <asp:ListItem Text="100" Value="100" />
                        </asp:DropDownList>
                    </div>
                    <asp:Literal ID="litPageInfo" runat="server" Text="Page 1 of 1" />
                </div>
            </div>
        </div>
    </div>

    <script type="text/javascript">
        (function () {
            var input = document.getElementById('txtSearch');
            var group = document.getElementById('searchGroup');
            if (!input) return;

            input.addEventListener('input', filterUsersTable);
            if (input.value) filterUsersTable();
        })();

        function filterUsersTable() {
            var input = document.getElementById('txtSearch');
            var group = document.getElementById('searchGroup');
            var table = document.getElementById('usersTable');
            var emptyEl = document.getElementById('jsEmptyState');
            if (!input || !table) return;

            var filter = input.value.toUpperCase();
            if (group) {
                if (filter.length > 0) group.classList.add('has-val');
                else group.classList.remove('has-val');
            }

            var tbody = table.querySelector('tbody');
            if (!tbody) return;

            var rows = tbody.querySelectorAll('.mu-user-row');
            var visible = 0;
            for (var i = 0; i < rows.length; i++) {
                if (rows[i].innerText.toUpperCase().indexOf(filter) > -1) {
                    rows[i].style.display = '';
                    visible++;
                } else {
                    rows[i].style.display = 'none';
                }
            }

            var queryEl = document.getElementById('jsEmptyQuery');
            if (queryEl) queryEl.textContent = input.value ? '"' + input.value + '"' : 'your search';

            if (visible === 0 && rows.length > 0) {
                table.style.display = 'none';
                if (emptyEl) emptyEl.classList.remove('u-d-none');
            } else {
                table.style.display = '';
                if (emptyEl) emptyEl.classList.add('u-d-none');
            }
        }

        function clearSearch() {
            var input = document.getElementById('txtSearch');
            if (input) {
                input.value = '';
                filterUsersTable();
                input.focus();
            }
        }
    </script>
</asp:Content>
