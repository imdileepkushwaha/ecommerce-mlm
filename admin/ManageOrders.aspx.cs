using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ecommerce_mlm.admin
{
    public partial class ManageOrders : Page
    {
        string strcon = ConfigurationManager.ConnectionStrings["MlmDb"].ConnectionString;
        int _totalCount;
        int _pageSize = 10;
        int _currentPage = 1;
        int _totalPages = 1;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                int.TryParse(Request.QueryString["page"], out _currentPage);
                if (_currentPage < 1) _currentPage = 1;

                int.TryParse(Request.QueryString["size"], out _pageSize);
                if (_pageSize < 5) _pageSize = 10;
                ddlPageSize.SelectedValue = _pageSize.ToString();

                ShowFlash();
                LoadKpis();
            }

            LoadOrders();
        }

        protected void ddlPageSize_SelectedIndexChanged(object sender, EventArgs e)
        {
            int.TryParse(ddlPageSize.SelectedValue, out _pageSize);
            Response.Redirect(BuildUrl(1));
        }

        private void ShowFlash()
        {
            string msg = Request.QueryString["msg"];
            if (string.IsNullOrEmpty(msg)) return;

            pnlFlash.Visible = true;
            if (msg == "updated")
            {
                pnlFlash.CssClass = "mu-flash mu-flash-success";
                icoFlash.Attributes["class"] = "fas fa-check-circle";
                litFlash.Text = "Order status updated successfully.";
            }
            else if (msg == "error")
            {
                pnlFlash.CssClass = "mu-flash mu-flash-error";
                icoFlash.Attributes["class"] = "fas fa-exclamation-circle";
                litFlash.Text = "Could not update order status. Please try again.";
            }
        }

        private string BuildUrl(int page)
        {
            return "ManageOrders.aspx?page=" + page + "&size=" + GetPageSize();
        }

        private void LoadKpis()
        {
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    litAllOrders.Text = Scalar(con, "SELECT COUNT(*) FROM Orders").ToString("N0");
                    litNeedsConfirm.Text = Scalar(con, @"SELECT COUNT(*) FROM Orders WHERE LOWER(LTRIM(RTRIM(Status))) IN ('pending','processing','placed','confirmed')").ToString("N0");
                    litInTransit.Text = Scalar(con, @"SELECT COUNT(*) FROM Orders WHERE LOWER(LTRIM(RTRIM(Status))) IN ('shipped','dispatched','out for delivery')").ToString("N0");
                    litDelivered.Text = Scalar(con, @"SELECT COUNT(*) FROM Orders WHERE LOWER(LTRIM(RTRIM(Status))) IN ('delivered','completed')").ToString("N0");
                }
            }
            catch
            {
                litAllOrders.Text = litNeedsConfirm.Text = litInTransit.Text = litDelivered.Text = "0";
            }
        }

        private void LoadOrders()
        {
            _pageSize = GetPageSize();
            int.TryParse(Request.QueryString["page"], out _currentPage);
            if (_currentPage < 1) _currentPage = 1;

            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();

                    _totalCount = Scalar(con, "SELECT COUNT(*) FROM Orders");
                    _totalPages = Math.Max(1, (int)Math.Ceiling(_totalCount / (double)_pageSize));
                    if (_currentPage > _totalPages) _currentPage = _totalPages;

                    int offset = (_currentPage - 1) * _pageSize;

                    string sql = @"SELECT O.Id, O.TotalAmount, O.ItemCount, O.Status, O.CreatedAt, O.PaymentMode, O.OrderRef,
                        U.FullName, U.Email,
                        A.FullName AS ShipName, A.StreetAddress, A.City, A.State, A.ZipCode, A.PhoneNumber
                        FROM Orders O
                        INNER JOIN Users U ON O.UserId = U.Id
                        LEFT JOIN Addresses A ON O.AddressId = A.Id
                        ORDER BY O.CreatedAt DESC
                        OFFSET @off ROWS FETCH NEXT @size ROWS ONLY";

                    using (SqlCommand cmd = new SqlCommand(sql, con))
                    {
                        cmd.Parameters.AddWithValue("@off", offset);
                        cmd.Parameters.AddWithValue("@size", _pageSize);

                        DataTable dt = new DataTable();
                        new SqlDataAdapter(cmd).Fill(dt);

                        if (dt.Rows.Count > 0)
                        {
                            rptOrders.DataSource = dt;
                            rptOrders.DataBind();
                            rptOrders.Visible = true;
                            pnlEmpty.Visible = false;
                        }
                        else
                        {
                            rptOrders.Visible = false;
                            pnlEmpty.Visible = true;
                        }
                    }

                    litTableHint.Text = string.Format(
                        "{0} order{1} total · Search filters this page only. On small screens, scroll the table sideways if needed.",
                        _totalCount, _totalCount == 1 ? "" : "s");

                    int from = _totalCount == 0 ? 0 : offset + 1;
                    int to = Math.Min(offset + _pageSize, _totalCount);
                    litShowing.Text = string.Format("Showing {0}–{1} of {2}", from, to, _totalCount);
                    litPageInfo.Text = string.Format("Page {0} of {1}", _currentPage, _totalPages);

                    litPager.Text = BuildPagerHtml();
                }
            }
            catch
            {
                rptOrders.Visible = false;
                pnlEmpty.Visible = true;
                litTableHint.Text = "Unable to load orders.";
                litShowing.Text = "Showing 0 of 0";
                litPageInfo.Text = "Page 1 of 1";
                litPager.Text = "";
            }
        }

        private string BuildPagerHtml()
        {
            if (_totalPages <= 1) return "";

            string prev = _currentPage > 1
                ? "<a href=\"" + BuildUrl(_currentPage - 1) + "\">Previous</a>"
                : "<span class=\"disabled\">Previous</span>";

            string next = _currentPage < _totalPages
                ? "<a href=\"" + BuildUrl(_currentPage + 1) + "\">Next</a>"
                : "<span class=\"disabled\">Next</span>";

            return prev + "<span class=\"current\">" + _currentPage + "</span>" + next;
        }

        private static int Scalar(SqlConnection con, string sql)
        {
            using (SqlCommand cmd = new SqlCommand(sql, con))
                return Convert.ToInt32(cmd.ExecuteScalar());
        }

        private int GetPageSize()
        {
            int size = 10;
            if (ddlPageSize != null)
                int.TryParse(ddlPageSize.SelectedValue, out size);
            return size < 5 ? 10 : size;
        }

        public string GetInitials(object nameObj)
        {
            string name = nameObj != null && nameObj != DBNull.Value ? nameObj.ToString() : "";
            if (string.IsNullOrWhiteSpace(name)) return "??";
            string[] parts = name.Trim().Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
            if (parts.Length >= 2)
                return (parts[0].Substring(0, 1) + parts[1].Substring(0, 1)).ToUpperInvariant();
            return name.Length >= 2 ? name.Substring(0, 2).ToUpperInvariant() : name.Substring(0, 1).ToUpperInvariant();
        }

        public string FormatOrderRef(object refObj, object idObj)
        {
            if (refObj != null && refObj != DBNull.Value && !string.IsNullOrWhiteSpace(refObj.ToString()))
                return Server.HtmlEncode(refObj.ToString().Trim());
            if (idObj != null && idObj != DBNull.Value)
                return Server.HtmlEncode("ORD" + idObj.ToString());
            return "—";
        }

        public string FormatTotal(object amount)
        {
            if (amount == null || amount == DBNull.Value) return "—";
            return "₹" + Convert.ToDecimal(amount).ToString("N0", CultureInfo.InvariantCulture);
        }

        public string FormatStatusBadge(object status)
        {
            if (status == null || status == DBNull.Value) return "<span class=\"mo-status mo-status-default\">Unknown</span>";
            string s = status.ToString().Trim();
            string key = s.ToLowerInvariant().Replace(" ", "-");
            string css = "mo-status-default";
            if (key == "delivered" || key == "completed") css = "mo-status-delivered";
            else if (key == "cancelled" || key == "canceled") css = "mo-status-cancelled";
            else if (key == "pending" || key == "processing" || key == "placed" || key == "confirmed") css = "mo-status-processing";
            else if (key == "shipped" || key == "dispatched" || key == "out-for-delivery") css = "mo-status-shipped";
            return "<span class=\"mo-status " + css + "\">" + Server.HtmlEncode(s) + "</span>";
        }

        public string FormatPayment(object mode)
        {
            if (mode == null || mode == DBNull.Value) return "<span class=\"mo-pay\">COD</span>";
            string m = mode.ToString().Trim();
            if (string.IsNullOrEmpty(m)) return "<span class=\"mo-pay\">COD</span>";
            string css = m.Equals("COD", StringComparison.OrdinalIgnoreCase) ? "mo-pay" : "mo-pay mo-pay-online";
            return "<span class=\"" + css + "\">" + Server.HtmlEncode(m) + "</span>";
        }

        public string FormatShipping(object shipName, object street, object city, object state, object zip)
        {
            string name = shipName != null && shipName != DBNull.Value ? shipName.ToString().Trim() : "";
            string line = street != null && street != DBNull.Value ? street.ToString().Trim() : "";
            string c = city != null && city != DBNull.Value ? city.ToString().Trim() : "";
            string st = state != null && state != DBNull.Value ? state.ToString().Trim() : "";
            string z = zip != null && zip != DBNull.Value ? zip.ToString().Trim() : "";

            if (string.IsNullOrEmpty(name) && string.IsNullOrEmpty(line))
                return "<span class=\"mu-dash\">—</span>";

            var parts = new System.Collections.Generic.List<string>();
            if (!string.IsNullOrEmpty(line)) parts.Add(line);
            if (!string.IsNullOrEmpty(c)) parts.Add(c);
            if (!string.IsNullOrEmpty(st)) parts.Add(st);
            if (!string.IsNullOrEmpty(z)) parts.Add(z);

            string body = Server.HtmlEncode(string.Join(", ", parts));
            if (body.Length > 52) body = body.Substring(0, 49) + "…";

            return "<div class=\"mo-shipping\"><strong>" + Server.HtmlEncode(string.IsNullOrEmpty(name) ? "Customer" : name) + "</strong>" + body + "</div>";
        }

        public string FormatDate(object created)
        {
            if (created == null || created == DBNull.Value) return "<span class=\"mu-dash\">—</span>";
            DateTime dt = Convert.ToDateTime(created);
            return dt.ToString("MMM dd, yyyy", CultureInfo.InvariantCulture) + " · " + dt.ToString("hh:mm tt", CultureInfo.InvariantCulture);
        }
    }
}
