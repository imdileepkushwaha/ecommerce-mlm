using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ecommerce_mlm.admin
{
    public partial class AccountDeletions : Page
    {
        private readonly string _strcon = ConfigurationManager.ConnectionStrings["MlmDb"].ConnectionString;

        private int _userPage = 1;
        private int _sellerPage = 1;
        private int _histPage = 1;
        private int _userSize = 10;
        private int _sellerSize = 10;
        private int _histSize = 10;
        private int _userTotal;
        private int _sellerTotal;
        private int _histTotal;
        private int _kpiPendingUsers;
        private int _kpiPendingSellers;
        private int _kpiResolved;

        protected void Page_Load(object sender, EventArgs e)
        {
            int.TryParse(Request.QueryString["upage"], out _userPage);
            int.TryParse(Request.QueryString["spage"], out _sellerPage);
            int.TryParse(Request.QueryString["hpage"], out _histPage);
            if (_userPage < 1) _userPage = 1;
            if (_sellerPage < 1) _sellerPage = 1;
            if (_histPage < 1) _histPage = 1;

            if (!IsPostBack)
            {
                SyncSizeFromQuery("usize", ddlUserPageSize, ref _userSize);
                SyncSizeFromQuery("ssize", ddlSellerPageSize, ref _sellerSize);
                SyncSizeFromQuery("hsize", ddlHistPageSize, ref _histSize);
                ShowFlashIfAny();
            }
            else
            {
                _userSize = GetDropDownSize(ddlUserPageSize, 10);
                _sellerSize = GetDropDownSize(ddlSellerPageSize, 10);
                _histSize = GetDropDownSize(ddlHistPageSize, 10);
            }

            LoadKpis();
            LoadUsers();
            LoadSellers();
            LoadHistory();
        }

        protected void ddlUserPageSize_SelectedIndexChanged(object sender, EventArgs e)
        {
            Response.Redirect(BuildUrl(1, _sellerPage, _histPage, GetDropDownSize(ddlUserPageSize, 10), _sellerSize, _histSize));
        }

        protected void ddlSellerPageSize_SelectedIndexChanged(object sender, EventArgs e)
        {
            Response.Redirect(BuildUrl(_userPage, 1, _histPage, _userSize, GetDropDownSize(ddlSellerPageSize, 10), _histSize));
        }

        protected void ddlHistPageSize_SelectedIndexChanged(object sender, EventArgs e)
        {
            Response.Redirect(BuildUrl(_userPage, _sellerPage, 1, _userSize, _sellerSize, GetDropDownSize(ddlHistPageSize, 10)));
        }

        protected void rptAction_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            string[] args = e.CommandArgument.ToString().Split('|');
            if (args.Length < 2) return;

            string id = args[0];
            string type = args[1];

            try
            {
                using (SqlConnection con = new SqlConnection(_strcon))
                {
                    con.Open();
                    if (e.CommandName == "ApproveRequest")
                    {
                        if (type == "User")
                        {
                            using (SqlCommand cmd = new SqlCommand(
                                "UPDATE AccountDeleteRequests SET Status = 'APPROVED', AdminApprovedDate = GETDATE() WHERE Id = @id AND Status = 'PENDING'", con))
                            {
                                cmd.Parameters.AddWithValue("@id", id);
                                cmd.ExecuteNonQuery();
                            }
                        }
                        else
                        {
                            using (SqlCommand cmd = new SqlCommand(
                                @"UPDATE SellerUsers SET IsActive = 0, DeletionStatus = 'Approved',
                                  DeactivationDate = GETDATE(), UpdatedAt = GETDATE()
                                  WHERE Id = @id AND DeletionStatus = 'Pending'", con))
                            {
                                cmd.Parameters.AddWithValue("@id", id);
                                cmd.ExecuteNonQuery();
                            }
                        }
                        Response.Redirect(BuildUrl(_userPage, _sellerPage, _histPage, _userSize, _sellerSize, _histSize) + "&msg=approved");
                        return;
                    }

                    if (e.CommandName == "RejectRequest")
                    {
                        if (type == "User")
                        {
                            using (SqlCommand cmd = new SqlCommand(
                                "UPDATE AccountDeleteRequests SET Status = 'CANCELLED' WHERE Id = @id AND Status = 'PENDING'", con))
                            {
                                cmd.Parameters.AddWithValue("@id", id);
                                cmd.ExecuteNonQuery();
                            }
                        }
                        else
                        {
                            using (SqlCommand cmd = new SqlCommand(
                                @"UPDATE SellerUsers SET DeletionStatus = 'None', DeactivationDate = NULL, UpdatedAt = GETDATE()
                                  WHERE Id = @id AND DeletionStatus = 'Pending'", con))
                            {
                                cmd.Parameters.AddWithValue("@id", id);
                                cmd.ExecuteNonQuery();
                            }
                        }
                        Response.Redirect(BuildUrl(_userPage, _sellerPage, _histPage, _userSize, _sellerSize, _histSize) + "&msg=rejected");
                    }
                }
            }
            catch
            {
                Response.Redirect(BuildUrl(_userPage, _sellerPage, _histPage, _userSize, _sellerSize, _histSize) + "&msg=error");
            }
        }

        private void ShowFlashIfAny()
        {
            string msg = Request.QueryString["msg"];
            if (string.IsNullOrEmpty(msg)) return;

            pnlFlash.Visible = true;
            if (msg == "approved")
            {
                litFlash.Text = "Deletion request approved.";
                pnlFlash.CssClass = "ms-flash ms-flash-success";
                icoFlash.Attributes["class"] = "fas fa-check-circle";
            }
            else if (msg == "rejected")
            {
                litFlash.Text = "Deletion request rejected and account reinstated.";
                pnlFlash.CssClass = "ms-flash ms-flash-warn";
                icoFlash.Attributes["class"] = "fas fa-undo";
            }
            else
            {
                litFlash.Text = "Action could not be completed. Please try again.";
                pnlFlash.CssClass = "ms-flash ms-flash-error";
                icoFlash.Attributes["class"] = "fas fa-exclamation-circle";
            }
        }

        private void SyncSizeFromQuery(string key, DropDownList ddl, ref int size)
        {
            int q;
            if (int.TryParse(Request.QueryString[key], out q) && q >= 5)
            {
                size = q;
                if (ddl != null)
                {
                    ListItem li = ddl.Items.FindByValue(q.ToString());
                    if (li != null) ddl.SelectedValue = q.ToString();
                }
            }
        }

        private static int GetDropDownSize(DropDownList ddl, int fallback)
        {
            int size = fallback;
            if (ddl != null) int.TryParse(ddl.SelectedValue, out size);
            return size < 5 ? fallback : size;
        }

        private void LoadKpis()
        {
            try
            {
                using (SqlConnection con = new SqlConnection(_strcon))
                {
                    con.Open();
                    _kpiPendingUsers = Scalar(con, "SELECT COUNT(*) FROM AccountDeleteRequests WHERE Status = 'PENDING'");
                    _kpiPendingSellers = Scalar(con, "SELECT COUNT(*) FROM SellerUsers WHERE DeletionStatus = 'Pending'");
                    _kpiResolved = Scalar(con, @"SELECT COUNT(*) FROM (
                        SELECT Id FROM AccountDeleteRequests WHERE Status IN ('APPROVED', 'CANCELLED')
                        UNION ALL
                        SELECT Id FROM SellerUsers WHERE DeletionStatus = 'Approved') x");
                }

                litKpiUsers.Text = _kpiPendingUsers.ToString("N0", CultureInfo.InvariantCulture);
                litKpiSellers.Text = _kpiPendingSellers.ToString("N0", CultureInfo.InvariantCulture);
                litKpiResolved.Text = _kpiResolved.ToString("N0", CultureInfo.InvariantCulture);
            }
            catch
            {
                litKpiUsers.Text = litKpiSellers.Text = litKpiResolved.Text = "0";
            }
        }

        private void LoadUsers()
        {
            const string where = "R.Status = 'PENDING'";
            try
            {
                using (SqlConnection con = new SqlConnection(_strcon))
                {
                    con.Open();
                    _userTotal = Scalar(con, "SELECT COUNT(*) FROM AccountDeleteRequests R INNER JOIN Users U ON R.UserId = U.Id WHERE " + where);
                    BindPagedTable(con,
                        @"SELECT R.Id, R.RequestDate, R.Status, U.FullName, U.Email, U.Mobile
                          FROM AccountDeleteRequests R
                          INNER JOIN Users U ON R.UserId = U.Id
                          WHERE " + where + @"
                          ORDER BY R.RequestDate DESC",
                        ref _userPage, _userSize,
                        rptUsers, pnlUsersEmpty, litUserShowing, litUserPageInfo, litUserPager, litUserHint,
                        "user");
                }
            }
            catch
            {
                FailTable(rptUsers, pnlUsersEmpty, litUserShowing, litUserPageInfo, litUserPager, litUserHint);
            }
        }

        private void LoadSellers()
        {
            const string where = "DeletionStatus = 'Pending'";
            try
            {
                using (SqlConnection con = new SqlConnection(_strcon))
                {
                    con.Open();
                    _sellerTotal = Scalar(con, "SELECT COUNT(*) FROM SellerUsers WHERE " + where);
                    BindPagedTable(con,
                        @"SELECT Id, FullName, Email, StoreName, DeactivationDate, DeletionStatus
                          FROM SellerUsers WHERE " + where + @"
                          ORDER BY DeactivationDate DESC",
                        ref _sellerPage, _sellerSize,
                        rptSellers, pnlSellersEmpty, litSellerShowing, litSellerPageInfo, litSellerPager, litSellerHint,
                        "seller");
                }
            }
            catch
            {
                FailTable(rptSellers, pnlSellersEmpty, litSellerShowing, litSellerPageInfo, litSellerPager, litSellerHint);
            }
        }

        private void LoadHistory()
        {
            string baseSql = @"SELECT EType, FullName, Email, EDate, EStatus FROM (
                SELECT 'User' AS EType, U.FullName, U.Email, R.RequestDate AS EDate, R.Status AS EStatus
                FROM AccountDeleteRequests R
                INNER JOIN Users U ON R.UserId = U.Id
                WHERE R.Status IN ('APPROVED', 'CANCELLED')
                UNION ALL
                SELECT 'Seller' AS EType, FullName, Email, DeactivationDate AS EDate, DeletionStatus AS EStatus
                FROM SellerUsers WHERE DeletionStatus = 'Approved') H";

            try
            {
                using (SqlConnection con = new SqlConnection(_strcon))
                {
                    con.Open();
                    _histTotal = Scalar(con, "SELECT COUNT(*) FROM (" + baseSql + ") Cnt");
                    BindPagedTable(con,
                        baseSql + " ORDER BY EDate DESC",
                        ref _histPage, _histSize,
                        rptHistory, pnlHistEmpty, litHistShowing, litHistPageInfo, litHistPager, litHistHint,
                        "history");
                }
            }
            catch
            {
                FailTable(rptHistory, pnlHistEmpty, litHistShowing, litHistPageInfo, litHistPager, litHistHint);
            }
        }

        private void BindPagedTable(SqlConnection con, string dataSql,
            ref int currentPage, int pageSize,
            Repeater rpt, Panel emptyPanel, Literal litShowing, Literal litPageInfo, Literal litPager, Literal litHint,
            string sectionKey)
        {
            int total = GetTotalForSection(sectionKey);
            int totalPages = Math.Max(1, (int)Math.Ceiling(total / (double)pageSize));
            if (currentPage > totalPages) currentPage = totalPages;
            if (currentPage < 1) currentPage = 1;
            int offset = (currentPage - 1) * pageSize;

            string sql = dataSql;
            if (sql.IndexOf("OFFSET", StringComparison.OrdinalIgnoreCase) < 0)
            {
                sql += " OFFSET @off ROWS FETCH NEXT @size ROWS ONLY";
            }

            DataTable dt = new DataTable();
            using (SqlCommand cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.AddWithValue("@off", offset);
                cmd.Parameters.AddWithValue("@size", pageSize);
                new SqlDataAdapter(cmd).Fill(dt);
            }

            if (dt.Rows.Count > 0)
            {
                rpt.DataSource = dt;
                rpt.DataBind();
                rpt.Visible = true;
                emptyPanel.Visible = false;
            }
            else
            {
                rpt.Visible = false;
                emptyPanel.Visible = true;
            }

            int from = total == 0 ? 0 : offset + 1;
            int to = Math.Min(offset + pageSize, total);
            litShowing.Text = string.Format("Showing {0}–{1} of {2}", from, to, total);
            litPageInfo.Text = string.Format("Page {0} of {1}", currentPage, totalPages);
            litPager.Text = BuildPagerHtml(sectionKey, currentPage, totalPages);
            if (sectionKey == "history")
                litHint.Text = string.Format("{0} resolved · Search filters this page only.", total);
            else
                litHint.Text = string.Format("{0} pending · Search filters this page only.", total);
        }

        private int GetTotalForSection(string key)
        {
            if (key == "user") return _userTotal;
            if (key == "seller") return _sellerTotal;
            return _histTotal;
        }

        private void FailTable(Repeater rpt, Panel emptyPanel, Literal litShowing, Literal litPageInfo, Literal litPager, Literal litHint)
        {
            rpt.Visible = false;
            emptyPanel.Visible = true;
            litShowing.Text = "Showing 0 of 0";
            litPageInfo.Text = "Page 1 of 1";
            litPager.Text = "";
            litHint.Text = "Unable to load data.";
        }

        private string BuildUrl(int userPage, int sellerPage, int histPage, int userSize, int sellerSize, int histSize)
        {
            return string.Format(CultureInfo.InvariantCulture,
                "AccountDeletions.aspx?upage={0}&usize={1}&spage={2}&ssize={3}&hpage={4}&hsize={5}",
                userPage, userSize, sellerPage, sellerSize, histPage, histSize);
        }

        private string BuildPagerHtml(string section, int currentPage, int totalPages)
        {
            if (totalPages <= 1) return "";

            int prev = currentPage - 1;
            int next = currentPage + 1;
            int userP = _userPage;
            int sellerP = _sellerPage;
            int histP = _histPage;

            if (section == "user") userP = prev;
            else if (section == "seller") sellerP = prev;
            else histP = prev;

            string prevUrl = section == "user"
                ? BuildUrl(prev, _sellerPage, _histPage, _userSize, _sellerSize, _histSize)
                : (section == "seller"
                    ? BuildUrl(_userPage, prev, _histPage, _userSize, _sellerSize, _histSize)
                    : BuildUrl(_userPage, _sellerPage, prev, _userSize, _sellerSize, _histSize));

            if (section == "user") userP = next;
            else if (section == "seller") sellerP = next;
            else histP = next;

            string nextUrl = section == "user"
                ? BuildUrl(next, _sellerPage, _histPage, _userSize, _sellerSize, _histSize)
                : (section == "seller"
                    ? BuildUrl(_userPage, next, _histPage, _userSize, _sellerSize, _histSize)
                    : BuildUrl(_userPage, _sellerPage, next, _userSize, _sellerSize, _histSize));

            string prevLink = currentPage > 1
                ? "<a href=\"" + prevUrl + "\">Previous</a>"
                : "<span class=\"disabled\">Previous</span>";
            string nextLink = currentPage < totalPages
                ? "<a href=\"" + nextUrl + "\">Next</a>"
                : "<span class=\"disabled\">Next</span>";

            return prevLink + "<span class=\"current\">" + currentPage + "</span>" + nextLink;
        }

        private static int Scalar(SqlConnection con, string sql)
        {
            using (SqlCommand cmd = new SqlCommand(sql, con))
            {
                object o = cmd.ExecuteScalar();
                return o != null && o != DBNull.Value ? Convert.ToInt32(o) : 0;
            }
        }

        public string FormatDate(object dtObj)
        {
            if (dtObj == null || dtObj == DBNull.Value) return "<span class=\"ms-dash\">—</span>";
            return Convert.ToDateTime(dtObj).ToString("MMM dd, yyyy", CultureInfo.InvariantCulture);
        }

        public string FormatRequestRef(object id, object date)
        {
            string idStr = id != null && id != DBNull.Value ? "#" + id.ToString() : "—";
            string d = FormatDate(date);
            return "<span class=\"ad-ref\">" + Server.HtmlEncode(idStr) + "</span><span class=\"ad-date\">" + d + "</span>";
        }

        public string FormatProfile(object name, object email, object extra)
        {
            string n = name != null && name != DBNull.Value ? name.ToString().Trim() : "—";
            string e = email != null && email != DBNull.Value ? email.ToString().Trim() : "";
            string x = extra != null && extra != DBNull.Value ? extra.ToString().Trim() : "";
            string html = "<span class=\"ad-name\">" + Server.HtmlEncode(n) + "</span>";
            if (!string.IsNullOrEmpty(e))
                html += "<span class=\"ad-email\">" + Server.HtmlEncode(e) + "</span>";
            if (!string.IsNullOrEmpty(x) && x != "0")
                html += "<span class=\"ad-meta\">" + Server.HtmlEncode(x) + "</span>";
            return html;
        }

        public string FormatPendingStatus(object status)
        {
            string s = status != null && status != DBNull.Value ? status.ToString().Trim() : "Pending";
            return "<span class=\"ms-status ms-status-pending\">" + Server.HtmlEncode(s) + "</span>";
        }

        public string FormatHistStatusBadge(object status)
        {
            string s = status != null && status != DBNull.Value ? status.ToString().Trim().ToUpperInvariant() : "";
            if (s == "APPROVED") return "<span class=\"ms-status ms-status-active\">Approved</span>";
            if (s == "CANCELLED") return "<span class=\"ms-status ms-status-inactive\">Cancelled</span>";
            return "<span class=\"ms-status ms-status-deleted\">" + Server.HtmlEncode(s) + "</span>";
        }

        public string FormatTypeBadge(object type)
        {
            string t = type != null && type != DBNull.Value ? type.ToString().Trim() : "";
            if (t.Equals("User", StringComparison.OrdinalIgnoreCase))
                return "<span class=\"ad-type ad-type-user\"><i class=\"fas fa-user\"></i> User</span>";
            return "<span class=\"ad-type ad-type-seller\"><i class=\"fas fa-store\"></i> Seller</span>";
        }

        public string GetHistStatusClass(object status)
        {
            string s = status != null ? status.ToString().ToUpperInvariant() : "";
            if (s == "APPROVED") return "ms-status-active";
            if (s == "CANCELLED") return "ms-status-inactive";
            return "ms-status-deleted";
        }
    }
}
