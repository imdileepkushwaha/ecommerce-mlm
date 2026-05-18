using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ecommerce_mlm.admin
{
    public partial class ManageUsers : Page
    {
        string strcon = ConfigurationManager.ConnectionStrings["MlmDb"].ConnectionString;
        int _totalCount;
        int _pageSize = 25;
        int _currentPage = 1;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                string q = Request.QueryString["q"] ?? "";
                if (!string.IsNullOrEmpty(q))
                    txtSearch.Text = q;

                int.TryParse(Request.QueryString["page"], out _currentPage);
                if (_currentPage < 1) _currentPage = 1;

                int.TryParse(Request.QueryString["size"], out _pageSize);
                if (_pageSize < 5) _pageSize = 25;
                ddlPageSize.SelectedValue = _pageSize.ToString();

                ShowFlash();
                LoadKpis();
            }

            LoadUsers();
        }

        protected void ddlPageSize_SelectedIndexChanged(object sender, EventArgs e)
        {
            int.TryParse(ddlPageSize.SelectedValue, out _pageSize);
            _currentPage = 1;
            LoadKpis();
            LoadUsers();
        }

        protected void rptUsers_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            if (e.CommandName != "ToggleStatus") return;

            string userId = e.CommandArgument.ToString();
            bool nowActive = false;

            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    using (SqlCommand chk = new SqlCommand("SELECT IsActive FROM Users WHERE Id = @id", con))
                    {
                        chk.Parameters.AddWithValue("@id", userId);
                        object val = chk.ExecuteScalar();
                        if (val == null || val == DBNull.Value) return;
                        bool current = Convert.ToBoolean(val);
                        nowActive = !current;

                        using (SqlCommand cmd = new SqlCommand("UPDATE Users SET IsActive = @active WHERE Id = @id", con))
                        {
                            cmd.Parameters.AddWithValue("@active", nowActive);
                            cmd.Parameters.AddWithValue("@id", userId);
                            cmd.ExecuteNonQuery();
                        }
                    }
                }
            }
            catch
            {
                Response.Redirect(BuildUrl(_currentPage, Request.QueryString["q"], "error"));
                return;
            }

            int page = 1;
            int.TryParse(Request.QueryString["page"], out page);
            if (page < 1) page = 1;

            string msg = nowActive ? "activated" : "suspended";
            Response.Redirect(BuildUrl(page, Request.QueryString["q"], msg));
        }

        private void ShowFlash()
        {
            string msg = Request.QueryString["msg"];
            if (string.IsNullOrEmpty(msg)) return;

            pnlFlash.Visible = true;
            if (msg == "suspended")
            {
                pnlFlash.CssClass = "mu-flash mu-flash-warn";
                icoFlash.Attributes["class"] = "fas fa-ban";
                litFlash.Text = "User account has been suspended. They cannot sign in until reactivated.";
            }
            else if (msg == "activated")
            {
                pnlFlash.CssClass = "mu-flash mu-flash-success";
                icoFlash.Attributes["class"] = "fas fa-check-circle";
                litFlash.Text = "User account has been reactivated successfully.";
            }
            else if (msg == "error")
            {
                pnlFlash.CssClass = "mu-flash mu-flash-error";
                icoFlash.Attributes["class"] = "fas fa-exclamation-circle";
                litFlash.Text = "Could not update account status. Please try again.";
            }
        }

        private string BuildUrl(int page, string q, string msg)
        {
            string url = "ManageUsers.aspx?page=" + page + "&size=" + GetPageSize();
            if (!string.IsNullOrEmpty(q))
                url += "&q=" + Server.UrlEncode(q);
            if (!string.IsNullOrEmpty(msg))
                url += "&msg=" + Server.UrlEncode(msg);
            return url;
        }

        private void LoadKpis()
        {
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    litAllUsers.Text = Scalar(con, "SELECT COUNT(*) FROM Users").ToString("N0");
                    litPhoneOnFile.Text = Scalar(con, @"SELECT COUNT(*) FROM Users WHERE Mobile IS NOT NULL AND LTRIM(RTRIM(Mobile)) <> '' AND LTRIM(RTRIM(Mobile)) <> '0'").ToString("N0");
                    litBirthdaySet.Text = Scalar(con, "SELECT COUNT(*) FROM Users WHERE Dob IS NOT NULL").ToString("N0");
                    litNewUsers.Text = Scalar(con, "SELECT COUNT(*) FROM Users WHERE CreatedAt >= DATEADD(day, -30, GETDATE())").ToString("N0");
                }
            }
            catch
            {
                litAllUsers.Text = litPhoneOnFile.Text = litBirthdaySet.Text = litNewUsers.Text = "0";
            }
        }

        private void LoadUsers()
        {
            _pageSize = GetPageSize();
            string query = (Request.QueryString["q"] ?? "").Trim();
            string where = "";
            if (!string.IsNullOrEmpty(query))
            {
                where = @" WHERE FullName LIKE @q OR Email LIKE @q OR Username LIKE @q 
                    OR Mobile LIKE @q OR CAST(Id AS VARCHAR(20)) LIKE @q";
            }

            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();

                    string countSql = "SELECT COUNT(*) FROM Users" + where;
                    using (SqlCommand cmdCount = new SqlCommand(countSql, con))
                    {
                        if (!string.IsNullOrEmpty(query))
                            cmdCount.Parameters.AddWithValue("@q", "%" + query + "%");
                        _totalCount = Convert.ToInt32(cmdCount.ExecuteScalar());
                    }

                    int totalPages = Math.Max(1, (int)Math.Ceiling(_totalCount / (double)_pageSize));
                    if (_currentPage > totalPages) _currentPage = totalPages;

                    int offset = (_currentPage - 1) * _pageSize;

                    string sql = @"SELECT Id, FullName, Username, Email, Mobile, Gender, Dob, CreatedAt, IsActive 
                        FROM Users" + where + @" ORDER BY CreatedAt DESC
                        OFFSET @off ROWS FETCH NEXT @size ROWS ONLY";

                    using (SqlCommand cmd = new SqlCommand(sql, con))
                    {
                        if (!string.IsNullOrEmpty(query))
                            cmd.Parameters.AddWithValue("@q", "%" + query + "%");
                        cmd.Parameters.AddWithValue("@off", offset);
                        cmd.Parameters.AddWithValue("@size", _pageSize);

                        DataTable dt = new DataTable();
                        new SqlDataAdapter(cmd).Fill(dt);

                        if (dt.Rows.Count > 0)
                        {
                            rptUsers.DataSource = dt;
                            rptUsers.DataBind();
                            rptUsers.Visible = true;
                            pnlEmpty.Visible = false;
                        }
                        else
                        {
                            rptUsers.Visible = false;
                            pnlEmpty.Visible = true;
                        }
                    }

                    litTableHint.Text = string.Format(
                        "{0} user{1} total · Search filters this page only. On small screens, scroll the table sideways if needed.",
                        _totalCount, _totalCount == 1 ? "" : "s");

                    int from = _totalCount == 0 ? 0 : offset + 1;
                    int to = Math.Min(offset + _pageSize, _totalCount);
                    litShowing.Text = string.Format("Showing {0}–{1} of {2}", from, to, _totalCount);
                    litPageInfo.Text = string.Format("Page {0} of {1}", _currentPage, totalPages);
                }
            }
            catch
            {
                rptUsers.Visible = false;
                pnlEmpty.Visible = true;
                litTableHint.Text = "Unable to load users.";
                litShowing.Text = "Showing 0 of 0";
                litPageInfo.Text = "Page 1 of 1";
            }
        }

        private static int Scalar(SqlConnection con, string sql)
        {
            using (SqlCommand cmd = new SqlCommand(sql, con))
                return Convert.ToInt32(cmd.ExecuteScalar());
        }

        private int GetPageSize()
        {
            int size = 25;
            if (ddlPageSize != null)
                int.TryParse(ddlPageSize.SelectedValue, out size);
            return size < 5 ? 25 : size;
        }

        public string GetInitials(object nameObj)
        {
            string name = nameObj != null && nameObj != DBNull.Value ? nameObj.ToString() : "";
            if (string.IsNullOrWhiteSpace(name)) return "U";
            string[] parts = name.Trim().Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
            if (parts.Length >= 2)
                return (parts[0].Substring(0, 1) + parts[1].Substring(0, 1)).ToUpperInvariant();
            return name.Length >= 2 ? name.Substring(0, 2).ToUpperInvariant() : name.Substring(0, 1).ToUpperInvariant();
        }

        public string FormatPhone(object mobile)
        {
            if (mobile == null || mobile == DBNull.Value) return "<span class=\"mu-dash\">—</span>";
            string m = mobile.ToString().Trim();
            if (string.IsNullOrEmpty(m) || m == "0") return "<span class=\"mu-dash\">—</span>";
            return Server.HtmlEncode(m);
        }

        public string FormatGender(object gender)
        {
            if (gender == null || gender == DBNull.Value) return "<span class=\"mu-dash\">—</span>";
            string g = gender.ToString().Trim();
            if (string.IsNullOrEmpty(g) || g.Equals("Unspecified", StringComparison.OrdinalIgnoreCase))
                return "<span class=\"mu-dash\">—</span>";
            return "<span class=\"mu-pill\">" + Server.HtmlEncode(g.ToLowerInvariant()) + "</span>";
        }

        public string FormatDob(object dob)
        {
            if (dob == null || dob == DBNull.Value) return "<span class=\"mu-dash\">—</span>";
            return Convert.ToDateTime(dob).ToString("MMM dd, yyyy", CultureInfo.InvariantCulture);
        }

        public string FormatCreated(object created)
        {
            if (created == null || created == DBNull.Value) return "<span class=\"mu-dash\">—</span>";
            DateTime dt = Convert.ToDateTime(created);
            return dt.ToString("MMM dd, yyyy", CultureInfo.InvariantCulture) + " - " + dt.ToString("hh:mm tt", CultureInfo.InvariantCulture);
        }
    }
}
