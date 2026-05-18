<%@ Page Title="KYC Compliance Audits" Language="C#" MasterPageFile="~/admin/Admin.Master" AutoEventWireup="true" CodeFile="KycAudits.aspx.cs" Inherits="ecommerce_mlm.admin.KycAudits" %>



<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

    <div class="ms-page">

        <div class="ms-page-head">

            <div class="ms-page-head-left">

                <span class="ms-overline">MARKETPLACE</span>

                <h1 class="ms-title">KYC Submission Audits</h1>

                <p class="ms-sub">Review pending legal documents and process onboarding approvals.</p>

            </div>

            <div class="ms-page-head-actions">

                <a href="ManageSellers.aspx" class="ms-btn ms-btn-primary">All Sellers</a>

            </div>

        </div>

        <asp:Panel ID="pnlFlash" runat="server" Visible="false" CssClass="ms-flash" style="margin-bottom:20px;">
            <i runat="server" id="icoFlash" class="fas fa-check-circle"></i>
            <asp:Literal ID="litFlash" runat="server" />
        </asp:Panel>

        <div class="ms-kpi-grid ms-kpi-grid-6">

            <div class="ms-kpi-card ms-kpi-orange">

                <div class="ms-kpi-body">

                    <label>PENDING REGISTRATION</label>

                    <strong><asp:Literal ID="litPendingReg" runat="server" Text="0" /></strong>

                    <span>New signup requests</span>

                </div>

                <div class="ms-kpi-ico"><i class="fas fa-file-alt"></i></div>

            </div>

            <div class="ms-kpi-card ms-kpi-green">

                <div class="ms-kpi-body">

                    <label>REG. APPROVED</label>

                    <strong><asp:Literal ID="litRegApproved" runat="server" Text="0" /></strong>

                    <span>Accounts created</span>

                </div>

                <div class="ms-kpi-ico"><i class="fas fa-check"></i></div>

            </div>

            <div class="ms-kpi-card ms-kpi-red">

                <div class="ms-kpi-body">

                    <label>REG. REJECTED</label>

                    <strong><asp:Literal ID="litRegRejected" runat="server" Text="0" /></strong>

                    <span>Declined applications</span>

                </div>

                <div class="ms-kpi-ico"><i class="fas fa-times"></i></div>

            </div>

            <div class="ms-kpi-card ms-kpi-purple">

                <div class="ms-kpi-body">

                    <label>PENDING FINAL KYC</label>

                    <strong><asp:Literal ID="litPendingFinalKyc" runat="server" Text="0" /></strong>

                    <span>Submitted, not final</span>

                </div>

                <div class="ms-kpi-ico"><i class="fas fa-clock"></i></div>

            </div>

            <div class="ms-kpi-card ms-kpi-teal">

                <div class="ms-kpi-body">

                    <label>FINAL APPROVED</label>

                    <strong><asp:Literal ID="litFinalApproved" runat="server" Text="0" /></strong>

                    <span>Can list products</span>

                </div>

                <div class="ms-kpi-ico"><i class="fas fa-user-check"></i></div>

            </div>

            <div class="ms-kpi-card ms-kpi-indigo">

                <div class="ms-kpi-body">

                    <label>PENDING EDIT</label>

                    <strong><asp:Literal ID="litPendingEdit" runat="server" Text="0" /></strong>

                    <span>Unlock requests</span>

                </div>

                <div class="ms-kpi-ico"><i class="fas fa-pen"></i></div>

            </div>

        </div>



        <div class="ms-table-card">

            <div class="ms-table-toolbar">

                <div class="ms-table-toolbar-left">

                    <h3>All Pending Sellers</h3>

                    <p><asp:Literal ID="litTableHint" runat="server" /></p>

                </div>

                <div class="ms-search-wrap" id="searchGroup">

                    <i class="fas fa-search"></i>

                    <input type="text" id="txtSearch" class="ms-search-input" placeholder="Search name, store, email, ID..." autocomplete="off" />

                    <button type="button" class="ms-search-clear" onclick="clearSearch();" aria-label="Clear search">

                        <i class="fas fa-times"></i>

                    </button>

                </div>

            </div>



            <div class="ms-table-scroll">

                <asp:Repeater ID="rptKyc" runat="server">

                    <HeaderTemplate>

                        <table class="ms-kyc-table" id="kycTable">

                            <thead>

                                <tr>

                                    <th>Merchant</th>

                                    <th>Company</th>

                                    <th>Contact</th>

                                    <th>Queue</th>

                                    <th class="ms-th-actions">Actions</th>

                                </tr>

                            </thead>

                            <tbody>

                    </HeaderTemplate>

                    <ItemTemplate>

                        <tr class="ms-kyc-row">

                            <td>

                                <div class="ms-kyc-merchant">

                                    <span class="ms-avatar"><%# GetInitials(Eval("FullName")) %></span>

                                    <div>

                                        <span class="ms-kyc-name"><%# Eval("FullName") %></span>

                                        <span class="ms-kyc-mid">#<%# Eval("Id") %></span>

                                    </div>

                                </div>

                            </td>

                            <td>

                                <div class="ms-kyc-store"><%# Eval("StoreName") != DBNull.Value ? Eval("StoreName") : "Draft Profile" %></div>

                                <div class="ms-kyc-meta">GST: <%# FormatGst(Eval("GstNumber")) %></div>

                            </td>

                            <td>

                                <div class="ms-kyc-contact-line"><i class="fas fa-envelope"></i> <%# Eval("Email") %></div>

                                <div class="ms-kyc-contact-line"><i class="fas fa-phone"></i> <%# FormatPhone(Eval("Phone")) %></div>

                            </td>

                            <td>

                                <div class="ms-kyc-time"><%# Eval("UpdatedAt", "{0:dd MMM yyyy, hh:mm tt}") %></div>

                                <%# GetQueueBadge(Eval("EmailVerified"), Eval("IsKycSubmitted"), Eval("KycStatus"), Eval("EditRequestStatus")) %>

                            </td>

                            <td>

                                <div class="ms-kyc-actions">

                                    <a href='ViewSellerKyc.aspx?id=<%# Eval("Id") %>' class="action-btn-circle action-btn-view" title="Deep audit">

                                        <svg xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" viewBox="0 0 24 24"><g fill="none" stroke="currentColor" stroke-width="1.5"><path stroke-linecap="round" d="M9 4.46A9.8 9.8 0 0 1 12 4c4.182 0 7.028 2.5 8.725 4.704C21.575 9.81 22 10.361 22 12c0 1.64-.425 2.191-1.275 3.296C19.028 17.5 16.182 20 12 20s-7.028-2.5-8.725-4.704C2.425 14.192 2 13.639 2 12c0-1.64.425-2.191 1.275-3.296A14.5 14.5 0 0 1 5 6.821"></path><path d="M15 12a3 3 0 1 1-6 0a3 3 0 0 1 6 0Z"></path></g></svg>

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



                <asp:PlaceHolder ID="phEmptyState" runat="server" Visible="false">

                    <div class="ms-empty-state">

                        <div class="ms-empty-ico ms-empty-muted"><i class="fas fa-check-double"></i></div>

                        <h4 class="ms-empty-title">All caught up</h4>

                        <p class="ms-empty-desc">No pending merchant KYC verification requests are in the audit queue.</p>

                    </div>

                </asp:PlaceHolder>



                <div id="jsEmptyState" class="ms-empty-state u-d-none" aria-live="polite">

                    <div class="ms-empty-ico"><i class="fas fa-search"></i></div>

                    <h4 class="ms-empty-title">No matches on this page</h4>

                    <p class="ms-empty-desc">Nothing matches <strong id="jsEmptyQuery"></strong>. Try another name, store, or email.</p>

                    <button type="button" class="ms-empty-btn" onclick="clearSearch();">

                        <i class="fas fa-times"></i> Clear search

                    </button>

                </div>

            </div>



            <div class="ms-table-foot">

                <div class="ms-table-foot-left">

                    <asp:Literal ID="litShowing" runat="server" Text="Showing 0 pending" />

                </div>

                <div class="ms-table-foot-right">

                    <asp:Label ID="lblQueueCount" runat="server" CssClass="ms-queue-count">0 in queue</asp:Label>

                </div>

            </div>

        </div>

        <div class="ms-table-card fkyc-table-card">
            <div class="ms-table-toolbar">
                <div class="ms-table-toolbar-left">
                    <h3>Final KYC (Seller Panel)</h3>
                    <p><asp:Literal ID="litFinalKycHint" runat="server" Text="Documents submitted in the seller dashboard — approve before they can sell. • Search filters this list only." /></p>
                </div>
                <div class="ms-search-wrap" id="fkycSearchGroup">
                    <i class="fas fa-search"></i>
                    <input type="text" id="txtFkycSearch" class="ms-search-input" placeholder="Search name, email, GST, bank, city..." autocomplete="off" />
                    <button type="button" class="ms-search-clear" onclick="clearFkycSearch();" aria-label="Clear search">
                        <i class="fas fa-times"></i>
                    </button>
                </div>
            </div>

            <div class="ms-table-scroll">
                <asp:Repeater ID="rptFinalKyc" runat="server" OnItemCommand="rptFinalKyc_ItemCommand">
                    <HeaderTemplate>
                        <table class="fkyc-table" id="fkycTable">
                            <thead>
                                <tr>
                                    <th>Seller</th>
                                    <th>Business + proof</th>
                                    <th>Bank + address</th>
                                    <th>Final status</th>
                                    <th class="ms-th-actions">Action</th>
                                </tr>
                            </thead>
                            <tbody>
                    </HeaderTemplate>
                    <ItemTemplate>
                        <tr class="fkyc-row">
                            <td>
                                <div class="fkyc-seller">
                                    <span class="ms-avatar"><%# GetInitials(Eval("FullName")) %></span>
                                    <div>
                                        <span class="fkyc-seller-name"><%# Eval("FullName") %></span>
                                        <span class="fkyc-seller-email"><%# Eval("Email") %></span>
                                        <a href='SellerView.aspx?id=<%# Eval("Id") %>' class="fkyc-profile-link">Seller profile &rarr;</a>
                                    </div>
                                </div>
                            </td>
                            <td class="fkyc-stack"><%# FormatBusinessProof(Eval("StoreName"), Eval("GstNumber"), Eval("PanNumber"), Eval("AadharNumber"), Eval("KycGstDocPath"), Eval("KycPanDocPath"), Eval("KycAadharDocPath")) %></td>
                            <td class="fkyc-stack"><%# FormatBankAddress(Eval("BankName"), Eval("BankHolderName"), Eval("BankAccountNumber"), Eval("BankIFSC"), Eval("Address"), Eval("City"), Eval("State"), Eval("Pincode")) %></td>
                            <td class="fkyc-stack"><%# FormatFinalStatus(Eval("KycStatus"), Eval("EditRequestStatus"), Eval("UpdatedAt"), Eval("CreatedAt")) %></td>
                            <td>
                                <div class="fkyc-actions">
                                    <asp:Panel runat="server" Visible='<%# ShowFinalKycActions(Eval("KycStatus"), Eval("EditRequestStatus")) %>'>
                                        <asp:LinkButton runat="server" CommandName="ApproveFinal" CommandArgument='<%# Eval("Id") %>'
                                            CssClass="fkyc-btn fkyc-btn-approve" ToolTip="Approve final KYC"
                                            OnClientClick="return confirm('Approve final KYC? This seller can list products after approval.');">
                                            Approve
                                        </asp:LinkButton>
                                        <asp:LinkButton runat="server" CommandName="RejectFinal" CommandArgument='<%# Eval("Id") %>'
                                            CssClass="fkyc-btn fkyc-btn-reject" ToolTip="Reject final KYC"
                                            OnClientClick="return confirm('Reject this KYC submission? The seller must resubmit documents.');">
                                            Reject
                                        </asp:LinkButton>
                                    </asp:Panel>
                                    <asp:Panel runat="server" Visible='<%# !ShowFinalKycActions(Eval("KycStatus"), Eval("EditRequestStatus")) %>'>
                                        <span class="fkyc-act-dash">&mdash;</span>
                                    </asp:Panel>
                                </div>
                            </td>
                        </tr>
                    </ItemTemplate>
                    <FooterTemplate>
                            </tbody>
                        </table>
                    </FooterTemplate>
                </asp:Repeater>

                <asp:PlaceHolder ID="phFinalKycEmpty" runat="server" Visible="false">
                    <div class="ms-empty-state">
                        <div class="ms-empty-ico ms-empty-muted"><i class="fas fa-folder-open"></i></div>
                        <h4 class="ms-empty-title">No final KYC submissions</h4>
                        <p class="ms-empty-desc">Submitted seller documents will appear here for review.</p>
                    </div>
                </asp:PlaceHolder>

                <div id="jsFkycEmptyState" class="ms-empty-state u-d-none" aria-live="polite">
                    <div class="ms-empty-ico"><i class="fas fa-search"></i></div>
                    <h4 class="ms-empty-title">No matches on this page</h4>
                    <p class="ms-empty-desc">Nothing matches <strong id="jsFkycEmptyQuery"></strong>.</p>
                    <button type="button" class="ms-empty-btn" onclick="clearFkycSearch();"><i class="fas fa-times"></i> Clear search</button>
                </div>
            </div>

            <div class="ms-table-foot">
                <div class="ms-table-foot-left">
                    <asp:Literal ID="litFkycShowing" runat="server" Text="Showing 0 of 0" />
                </div>
                <div class="ms-table-foot-right">
                    <div class="ms-per-page">
                        <span>Per page</span>
                        <asp:DropDownList ID="ddlFkycPageSize" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlFkycPageSize_SelectedIndexChanged" ClientIDMode="Static">
                            <asp:ListItem Text="10" Value="10" />
                            <asp:ListItem Text="25" Value="25" Selected="True" />
                            <asp:ListItem Text="50" Value="50" />
                            <asp:ListItem Text="100" Value="100" />
                        </asp:DropDownList>
                    </div>
                    <asp:Literal ID="litFkycPageInfo" runat="server" Text="Page 1 of 1" />
                    <div class="ms-pager">
                        <asp:Literal ID="litFkycPager" runat="server" />
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script type="text/javascript">

        (function () {

            var input = document.getElementById('txtSearch');

            if (input) input.addEventListener('input', filterKycTable);

        })();



        function filterKycTable() {

            var input = document.getElementById('txtSearch');

            var group = document.getElementById('searchGroup');

            var table = document.getElementById('kycTable');

            var emptyEl = document.getElementById('jsEmptyState');

            if (!input || !table) return;



            var filter = input.value.toUpperCase();

            if (group) {

                if (filter.length > 0) group.classList.add('has-val');

                else group.classList.remove('has-val');

            }



            var tbody = table.querySelector('tbody');

            if (!tbody) return;



            var rows = tbody.querySelectorAll('.ms-kyc-row');

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



            var foot = document.getElementById('<%= litShowing.ClientID %>');

            if (foot && rows.length > 0) {

                foot.innerText = 'Showing ' + visible + ' of ' + rows.length + ' in queue';

            }

        }



        function clearSearch() {

            var input = document.getElementById('txtSearch');

            if (input) {

                input.value = '';

                filterKycTable();

                input.focus();

            }

        }

        (function () {
            var fkInput = document.getElementById('txtFkycSearch');
            if (fkInput) fkInput.addEventListener('input', filterFkycTable);
        })();

        function filterFkycTable() {
            var input = document.getElementById('txtFkycSearch');
            var group = document.getElementById('fkycSearchGroup');
            var table = document.getElementById('fkycTable');
            var emptyEl = document.getElementById('jsFkycEmptyState');
            if (!input || !table) return;

            var filter = input.value.toUpperCase();
            if (group) {
                if (filter.length > 0) group.classList.add('has-val');
                else group.classList.remove('has-val');
            }

            var tbody = table.querySelector('tbody');
            if (!tbody) return;

            var rows = tbody.querySelectorAll('.fkyc-row');
            var visible = 0;
            for (var i = 0; i < rows.length; i++) {
                if (rows[i].innerText.toUpperCase().indexOf(filter) > -1) {
                    rows[i].style.display = '';
                    visible++;
                } else {
                    rows[i].style.display = 'none';
                }
            }

            var queryEl = document.getElementById('jsFkycEmptyQuery');
            if (queryEl) queryEl.textContent = input.value ? '"' + input.value + '"' : 'your search';

            if (visible === 0 && rows.length > 0) {
                table.style.display = 'none';
                if (emptyEl) emptyEl.classList.remove('u-d-none');
            } else {
                table.style.display = '';
                if (emptyEl) emptyEl.classList.add('u-d-none');
            }
        }

        function clearFkycSearch() {
            var input = document.getElementById('txtFkycSearch');
            if (input) {
                input.value = '';
                filterFkycTable();
                input.focus();
            }
        }

    </script>

</asp:Content>

