using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ecommerce_mlm.admin
{
    public partial class ManagePayouts : Page
    {
        private readonly string _strcon = ConfigurationManager.ConnectionStrings["MlmDb"].ConnectionString;

        private string _type = "member";
        private string _status = "all";
        private int _page = 1;
        private int _pageSize = 25;
        private int _totalCount;
        private int _kpiPending;
        private int _kpiPaid;
        private int _kpiRejected;
        private decimal _kpiPendingAmount;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["AdminId"] == null)
            {
                Response.Redirect("AdminLogin.aspx");
                return;
            }

            EnsurePayoutSchema();

            _type = NormalizeType(Request.QueryString["type"]);
            _status = NormalizeStatus(Request.QueryString["status"]);
            int.TryParse(Request.QueryString["page"], out _page);
            if (_page < 1) _page = 1;

            if (!IsPostBack)
            {
                SyncPageSizeFromQuery();
                SyncStatusFilter();
                ShowFlashIfAny();
            }
            else
            {
                _pageSize = GetPageSize();
                _status = NormalizeStatus(ddlStatusFilter.SelectedValue);
            }

            BindTypeTabs();
            LoadPayouts();
        }

        protected void ddlPageSize_SelectedIndexChanged(object sender, EventArgs e)
        {
            Response.Redirect(BuildUrl(_type, _status, 1, GetPageSize()));
        }

        protected void ddlStatusFilter_SelectedIndexChanged(object sender, EventArgs e)
        {
            Response.Redirect(BuildUrl(_type, ddlStatusFilter.SelectedValue, 1, _pageSize));
        }

        protected void rptPayouts_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName == "PaidTrigger")
            {
                hfSelectedPayoutId.Value = e.CommandArgument.ToString();
                hfPayoutType.Value = _type;
                txtTxnId.Text = "";
                ScriptManager.RegisterStartupScript(this, GetType(), "PopPaid", "openPayoutModal('paid');", true);
            }
            else if (e.CommandName == "RejectTrigger")
            {
                hfSelectedPayoutId.Value = e.CommandArgument.ToString();
                hfPayoutType.Value = _type;
                txtReason.Text = "";
                ScriptManager.RegisterStartupScript(this, GetType(), "PopReject", "openPayoutModal('reject');", true);
            }
        }

        protected void btnConfirmPaid_Click(object sender, EventArgs e)
        {
            string id = hfSelectedPayoutId.Value;
            string txn = txtTxnId.Text.Trim();
            string type = NormalizeType(hfPayoutType.Value);

            if (string.IsNullOrEmpty(id))
            {
                RedirectWithMsg("error");
                return;
            }
            if (string.IsNullOrEmpty(txn))
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "PopPaidAgain", "openPayoutModal('paid');", true);
                ShowInlineError("Please enter a bank reference / UTR number.");
                return;
            }

            try
            {
                bool isSeller = type == "seller";
                string sql = isSeller
                    ? "UPDATE SellerPayoutRequests SET Status = 'PAID', TransactionId = @txn, PaidDate = GETDATE() WHERE Id = @id AND Status = 'PENDING'"
                    : "UPDATE PayoutRequests SET Status = 'PAID', TransactionId = @txn, PaidDate = GETDATE() WHERE Id = @id AND Status = 'PENDING'";

                ExecUpdate(sql, id, txn, null);
                RedirectWithMsg("paid");
            }
            catch
            {
                RedirectWithMsg("error");
            }
        }

        protected void btnConfirmReject_Click(object sender, EventArgs e)
        {
            string id = hfSelectedPayoutId.Value;
            string reason = txtReason.Text.Trim();
            string type = NormalizeType(hfPayoutType.Value);

            if (string.IsNullOrEmpty(id))
            {
                RedirectWithMsg("error");
                return;
            }
            if (string.IsNullOrEmpty(reason))
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "PopRejectAgain", "openPayoutModal('reject');", true);
                ShowInlineError("Please enter a rejection reason.");
                return;
            }

            try
            {
                bool isSeller = type == "seller";
                string sql = isSeller
                    ? "UPDATE SellerPayoutRequests SET Status = 'REJECTED', AdminRemarks = @reason WHERE Id = @id AND Status = 'PENDING'"
                    : "UPDATE PayoutRequests SET Status = 'REJECTED', AdminRemarks = @reason WHERE Id = @id AND Status = 'PENDING'";

                ExecUpdate(sql, id, null, reason);
                RedirectWithMsg("rejected");
            }
            catch
            {
                RedirectWithMsg("error");
            }
        }

        private void ExecUpdate(string sql, string id, string txn, string reason)
        {
            using (SqlConnection con = new SqlConnection(_strcon))
            {
                con.Open();
                using (SqlCommand cmd = new SqlCommand(sql, con))
                {
                    cmd.Parameters.AddWithValue("@id", id);
                    if (txn != null) cmd.Parameters.AddWithValue("@txn", txn);
                    if (reason != null) cmd.Parameters.AddWithValue("@reason", reason);
                    cmd.ExecuteNonQuery();
                }
            }
        }

        private void RedirectWithMsg(string msg)
        {
            string type = NormalizeType(hfPayoutType.Value);
            if (string.IsNullOrEmpty(type) || type == "member") type = _type;
            Response.Redirect(BuildUrl(type, _status, _page, _pageSize) + "&msg=" + msg);
        }

        private void ShowInlineError(string text)
        {
            pnlFlash.Visible = true;
            pnlFlash.CssClass = "ms-flash ms-flash-error";
            icoFlash.Attributes["class"] = "fas fa-exclamation-circle";
            litFlash.Text = text;
        }

        private void ShowFlashIfAny()
        {
            string msg = Request.QueryString["msg"];
            if (string.IsNullOrEmpty(msg)) return;

            pnlFlash.Visible = true;
            if (msg == "paid")
            {
                litFlash.Text = "Payout marked as paid and settlement recorded.";
                pnlFlash.CssClass = "ms-flash ms-flash-success";
                icoFlash.Attributes["class"] = "fas fa-check-circle";
            }
            else if (msg == "rejected")
            {
                litFlash.Text = "Payout request rejected. The user will see your reason on their dashboard.";
                pnlFlash.CssClass = "ms-flash ms-flash-warn";
                icoFlash.Attributes["class"] = "fas fa-ban";
            }
            else
            {
                litFlash.Text = "Action could not be completed. Please try again.";
                pnlFlash.CssClass = "ms-flash ms-flash-error";
                icoFlash.Attributes["class"] = "fas fa-exclamation-circle";
            }
        }

        private void SyncPageSizeFromQuery()
        {
            int q;
            if (int.TryParse(Request.QueryString["size"], out q) && q >= 5)
            {
                _pageSize = q;
                ListItem li = ddlPageSize.Items.FindByValue(q.ToString());
                if (li != null) ddlPageSize.SelectedValue = q.ToString();
            }
        }

        private void SyncStatusFilter()
        {
            ListItem li = ddlStatusFilter.Items.FindByValue(_status.ToUpperInvariant());
            if (li != null) ddlStatusFilter.SelectedValue = li.Value;
            else if (ddlStatusFilter.Items.FindByValue(_status) != null)
                ddlStatusFilter.SelectedValue = _status;
        }

        private static string NormalizeType(string type)
        {
            if (string.IsNullOrEmpty(type)) return "member";
            type = type.Trim().ToLowerInvariant();
            return type == "seller" ? "seller" : "member";
        }

        private static string NormalizeStatus(string status)
        {
            if (string.IsNullOrEmpty(status)) return "all";
            status = status.Trim().ToUpperInvariant();
            if (status == "PENDING" || status == "PAID" || status == "REJECTED") return status.ToLowerInvariant();
            return "all";
        }

        private void LoadKpis()
        {
            bool isSeller = _type == "seller";
            string table = isSeller ? "SellerPayoutRequests" : "PayoutRequests";

            try
            {
                using (SqlConnection con = new SqlConnection(_strcon))
                {
                    con.Open();
                    _kpiPending = Scalar(con, "SELECT COUNT(*) FROM " + table + " WHERE Status = 'PENDING'");
                    _kpiPaid = Scalar(con, "SELECT COUNT(*) FROM " + table + " WHERE Status = 'PAID'");
                    _kpiRejected = Scalar(con, "SELECT COUNT(*) FROM " + table + " WHERE Status = 'REJECTED'");
                    _kpiPendingAmount = ScalarDecimal(con,
                        "SELECT ISNULL(SUM(" + (isSeller ? "RequestAmount" : "NetPayable") + "), 0) FROM " + table + " WHERE Status = 'PENDING'");
                }

                litKpiPending.Text = _kpiPending.ToString("N0", CultureInfo.InvariantCulture);
                litKpiPaid.Text = _kpiPaid.ToString("N0", CultureInfo.InvariantCulture);
                litKpiRejected.Text = _kpiRejected.ToString("N0", CultureInfo.InvariantCulture);
                litKpiPendingAmt.Text = "₹" + _kpiPendingAmount.ToString("N2", CultureInfo.InvariantCulture);
                litKpiListSub.Text = string.Format(CultureInfo.InvariantCulture, "{0} on this filter", _totalCount > 0 ? _totalCount : 0);
            }
            catch
            {
                litKpiPending.Text = litKpiPaid.Text = litKpiRejected.Text = "0";
                litKpiPendingAmt.Text = "₹0.00";
            }
        }

        private void BindTypeTabs()
        {
            hlTabMember.NavigateUrl = BuildUrl("member", _status, 1, _pageSize);
            hlTabSeller.NavigateUrl = BuildUrl("seller", _status, 1, _pageSize);
            hlTabMember.CssClass = "mp-tab" + (_type == "member" ? " active" : "");
            hlTabSeller.CssClass = "mp-tab" + (_type == "seller" ? " active" : "");

            litTableTitle.Text = _type == "seller" ? "Seller withdrawal requests" : "Member withdrawal requests";
            litTableHint.Text = _type == "seller"
                ? "Settle seller earnings to registered bank accounts."
                : "Settle member MLM income withdrawals with UTR references.";
            litKpiTypeLabel.Text = _type == "seller" ? "SELLER PENDING" : "MEMBER PENDING";
        }

        private void LoadPayouts()
        {
            bool isSeller = _type == "seller";
            string where = "1=1";
            if (_status != "all")
                where += " AND p.Status = @status";

            string dataSql = isSeller ? GetSellerSelectSql(where) : GetMemberSelectSql(where);
            string countSql = isSeller
                ? "SELECT COUNT(*) FROM SellerPayoutRequests p WHERE " + where
                : "SELECT COUNT(*) FROM PayoutRequests p WHERE " + where;

            try
            {
                using (SqlConnection con = new SqlConnection(_strcon))
                {
                    con.Open();
                    _totalCount = Scalar(con, countSql, _status != "all" ? _status.ToUpperInvariant() : null);

                    int totalPages = Math.Max(1, (int)Math.Ceiling(_totalCount / (double)_pageSize));
                    if (_page > totalPages) _page = totalPages;
                    int offset = (_page - 1) * _pageSize;

                    litKpiThisList.Text = _totalCount.ToString("N0", CultureInfo.InvariantCulture);
                    litKpiListSub.Text = string.Format(CultureInfo.InvariantCulture, "{0} matching filter", _totalCount);

                    DataTable dt = new DataTable();
                    using (SqlCommand cmd = new SqlCommand(dataSql + " ORDER BY p.CreatedAt DESC OFFSET @off ROWS FETCH NEXT @size ROWS ONLY", con))
                    {
                        if (_status != "all")
                            cmd.Parameters.AddWithValue("@status", _status.ToUpperInvariant());
                        cmd.Parameters.AddWithValue("@off", offset);
                        cmd.Parameters.AddWithValue("@size", _pageSize);
                        new SqlDataAdapter(cmd).Fill(dt);
                    }

                    if (dt.Rows.Count > 0)
                    {
                        rptPayouts.DataSource = dt;
                        rptPayouts.DataBind();
                        rptPayouts.Visible = true;
                        pnlEmpty.Visible = false;
                    }
                    else
                    {
                        rptPayouts.Visible = false;
                        pnlEmpty.Visible = true;
                        litEmptyTitle.Text = GetEmptyTitle();
                        litEmptyDesc.Text = GetEmptyDesc();
                    }

                    int from = _totalCount == 0 ? 0 : offset + 1;
                    int to = Math.Min(offset + _pageSize, _totalCount);
                    litShowing.Text = string.Format("Showing {0}–{1} of {2}", from, to, _totalCount);
                    litPageInfo.Text = string.Format("Page {0} of {1}", _page, totalPages);
                    litPager.Text = BuildPagerHtml(totalPages);
                }
            }
            catch
            {
                rptPayouts.Visible = false;
                pnlEmpty.Visible = true;
                litEmptyTitle.Text = "Unable to load payouts";
                litEmptyDesc.Text = "Check database connection and try again.";
                litShowing.Text = "Showing 0 of 0";
                litPageInfo.Text = "Page 1 of 1";
                litPager.Text = "";
                litKpiThisList.Text = "0";
            }

            LoadKpis();
        }

        private static string GetMemberSelectSql(string where)
        {
            return @"SELECT 
                p.Id, p.UserId, u.FullName, u.Username,
                p.RequestAmount, p.TdsDeduction, p.AdminCharges, p.NetPayable,
                p.Status, p.TransactionId, p.AdminRemarks, p.PaidDate, p.CreatedAt,
                b.BankName, b.AccountNumber, b.IFSCCode, b.AccountHolderName
                FROM PayoutRequests p
                INNER JOIN Users u ON p.UserId = u.Id
                LEFT JOIN UserBankDetails b ON u.Id = b.UserId
                WHERE " + where;
        }

        private static string GetSellerSelectSql(string where)
        {
            return @"SELECT 
                p.Id, p.SellerId AS UserId, u.FullName, u.StoreName AS Username,
                p.RequestAmount, 0.00 AS TdsDeduction, 0.00 AS AdminCharges, p.RequestAmount AS NetPayable,
                p.Status, p.TransactionId, p.AdminRemarks, p.PaidDate, p.CreatedAt,
                u.BankName, u.BankAccountNumber AS AccountNumber, u.BankIFSC AS IFSCCode, u.BankHolderName AS AccountHolderName
                FROM SellerPayoutRequests p
                INNER JOIN SellerUsers u ON p.SellerId = u.Id
                WHERE " + where;
        }

        private string GetEmptyTitle()
        {
            if (_status == "pending") return "No pending payouts";
            if (_status == "paid") return "No settled payouts";
            if (_status == "rejected") return "No rejected payouts";
            return "No payout requests";
        }

        private string GetEmptyDesc()
        {
            if (_status == "pending") return "Pending withdrawal requests will appear here for audit.";
            if (_status == "paid") return "Successfully settled payouts will show here.";
            if (_status == "rejected") return "Rejected requests will appear here.";
            return "When members or sellers request withdrawals, they will list here.";
        }

        private string BuildUrl(string type, string status, int page, int size)
        {
            return string.Format(CultureInfo.InvariantCulture,
                "ManagePayouts.aspx?type={0}&status={1}&page={2}&size={3}",
                type, status, page, size);
        }

        private string BuildPagerHtml(int totalPages)
        {
            if (totalPages <= 1) return "";

            string prev = _page > 1
                ? "<a href=\"" + BuildUrl(_type, _status, _page - 1, _pageSize) + "\">Previous</a>"
                : "<span class=\"disabled\">Previous</span>";
            string next = _page < totalPages
                ? "<a href=\"" + BuildUrl(_type, _status, _page + 1, _pageSize) + "\">Next</a>"
                : "<span class=\"disabled\">Next</span>";

            return prev + "<span class=\"current\">" + _page + "</span>" + next;
        }

        private static int Scalar(SqlConnection con, string sql, string statusParam = null)
        {
            using (SqlCommand cmd = new SqlCommand(sql, con))
            {
                if (statusParam != null) cmd.Parameters.AddWithValue("@status", statusParam);
                object o = cmd.ExecuteScalar();
                return o != null && o != DBNull.Value ? Convert.ToInt32(o) : 0;
            }
        }

        private static decimal ScalarDecimal(SqlConnection con, string sql)
        {
            using (SqlCommand cmd = new SqlCommand(sql, con))
            {
                object o = cmd.ExecuteScalar();
                return o != null && o != DBNull.Value ? Convert.ToDecimal(o) : 0m;
            }
        }

        private int GetPageSize()
        {
            int size = 25;
            if (ddlPageSize != null) int.TryParse(ddlPageSize.SelectedValue, out size);
            return size < 5 ? 25 : size;
        }

        private void EnsurePayoutSchema()
        {
            try
            {
                using (SqlConnection con = new SqlConnection(_strcon))
                {
                    con.Open();
                    string sql = @"
                        IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'PayoutRequests')
                        BEGIN
                            CREATE TABLE PayoutRequests (
                                Id INT PRIMARY KEY IDENTITY(1,1),
                                UserId INT NOT NULL,
                                RequestAmount DECIMAL(18, 2) NOT NULL,
                                TdsDeduction DECIMAL(18, 2) NOT NULL DEFAULT 0,
                                AdminCharges DECIMAL(18, 2) NOT NULL DEFAULT 0,
                                NetPayable DECIMAL(18, 2) NOT NULL,
                                Status NVARCHAR(50) NOT NULL DEFAULT 'PENDING',
                                TransactionId NVARCHAR(100) NULL,
                                PaidDate DATETIME NULL,
                                AdminRemarks NVARCHAR(MAX) NULL,
                                CreatedAt DATETIME DEFAULT GETDATE()
                            );
                        END";
                    new SqlCommand(sql, con).ExecuteNonQuery();
                }
            }
            catch { }
        }

        public bool ShowPendingActions(object status)
        {
            string s = status != null && status != DBNull.Value ? status.ToString().Trim().ToUpperInvariant() : "";
            return s == "PENDING";
        }

        public string FormatRequestRef(object id, object created)
        {
            string idStr = id != null && id != DBNull.Value ? "#PAY-" + id.ToString() : "—";
            string d = FormatDate(created);
            return "<span class=\"py-ref\">" + Server.HtmlEncode(idStr) + "</span><span class=\"py-date\">" + d + "</span>";
        }

        public string FormatMemberCell(object name, object username)
        {
            string n = SafeStr(name);
            string u = SafeStr(username);
            string html = "<span class=\"py-name\">" + Server.HtmlEncode(string.IsNullOrEmpty(n) ? "—" : n) + "</span>";
            if (!string.IsNullOrEmpty(u))
                html += "<span class=\"py-meta\">" + Server.HtmlEncode(u) + "</span>";
            return html;
        }

        public string FormatAmounts(object gross, object tds, object admin, object net)
        {
            decimal g = ToDec(gross);
            decimal t = ToDec(tds) + ToDec(admin);
            decimal n = ToDec(net);
            return "<span class=\"py-amt-line\">Gross: ₹" + g.ToString("N2", CultureInfo.InvariantCulture) + "</span>"
                + "<span class=\"py-amt-deduct\">Fees: ₹" + t.ToString("N2", CultureInfo.InvariantCulture) + "</span>"
                + "<span class=\"py-amt-net\">Net: ₹" + n.ToString("N2", CultureInfo.InvariantCulture) + "</span>";
        }

        public string FormatBankCell(object bank, object acct, object ifsc, object holder)
        {
            if (acct == null || acct == DBNull.Value || string.IsNullOrWhiteSpace(acct.ToString()))
                return "<span class=\"py-no-bank\">No bank on file</span>";

            string b = SafeStr(bank);
            string a = SafeStr(acct);
            string i = SafeStr(ifsc);
            string h = SafeStr(holder);

            return "<div class=\"py-bank\">"
                + "<span class=\"py-bank-name\"><i class=\"fas fa-university\"></i> " + Server.HtmlEncode(string.IsNullOrEmpty(b) ? "Bank" : b) + "</span>"
                + "<span class=\"py-bank-row\"><span>A/C</span> " + Server.HtmlEncode(a) + "</span>"
                + "<span class=\"py-bank-row\"><span>IFSC</span> " + Server.HtmlEncode(i) + "</span>"
                + "<span class=\"py-bank-row\"><span>Holder</span> " + Server.HtmlEncode(h) + "</span>"
                + "</div>";
        }

        public string FormatStatusCell(object status, object txn)
        {
            string s = status != null && status != DBNull.Value ? status.ToString().Trim().ToUpperInvariant() : "PENDING";
            string badge;
            if (s == "PAID")
                badge = "<span class=\"ms-status ms-status-active\"><i class=\"fas fa-check-circle\"></i> Paid</span>";
            else if (s == "REJECTED")
                badge = "<span class=\"ms-status ms-status-inactive\"><i class=\"fas fa-times-circle\"></i> Rejected</span>";
            else
                badge = "<span class=\"ms-status ms-status-pending\"><i class=\"fas fa-hourglass-half\"></i> Pending</span>";

            string utr = SafeStr(txn);
            if (!string.IsNullOrEmpty(utr))
                badge += "<span class=\"py-utr\">UTR: " + Server.HtmlEncode(utr) + "</span>";
            return badge;
        }

        public string FormatDate(object dtObj)
        {
            if (dtObj == null || dtObj == DBNull.Value) return "<span class=\"ms-dash\">—</span>";
            return Server.HtmlEncode(Convert.ToDateTime(dtObj).ToString("MMM dd, yyyy", CultureInfo.InvariantCulture));
        }

        private static string SafeStr(object o)
        {
            return o != null && o != DBNull.Value ? o.ToString().Trim() : "";
        }

        private static decimal ToDec(object o)
        {
            if (o == null || o == DBNull.Value) return 0m;
            decimal d;
            return decimal.TryParse(o.ToString(), out d) ? d : 0m;
        }
    }
}
