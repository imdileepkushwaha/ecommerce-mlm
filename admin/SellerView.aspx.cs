using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ecommerce_mlm.admin
{
    public partial class SellerView : Page
    {
        private readonly string _strcon = ConfigurationManager.ConnectionStrings["MlmDb"].ConnectionString;
        private int _sellerId;
        private int _prodPage = 1;
        private int _prodSize = 25;
        private int _prodTotal;
        private int _orderPage = 1;
        private int _orderSize = 25;
        private int _orderTotal;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!int.TryParse(Request.QueryString["id"], out _sellerId) || _sellerId < 1)
            {
                Response.Redirect("ManageSellers.aspx");
                return;
            }

            int.TryParse(Request.QueryString["ppage"], out _prodPage);
            int.TryParse(Request.QueryString["opage"], out _orderPage);
            if (_prodPage < 1) _prodPage = 1;
            if (_orderPage < 1) _orderPage = 1;

            if (!IsPostBack)
            {
                SyncPageSizeFromQuery("psize", ddlProdPageSize, ref _prodSize);
                SyncPageSizeFromQuery("osize", ddlOrderPageSize, ref _orderSize);
            }
            else
            {
                _prodSize = GetDropDownSize(ddlProdPageSize, 25);
                _orderSize = GetDropDownSize(ddlOrderPageSize, 25);
            }

            LoadSellerProfile();
            LoadProducts();
            LoadOrders();
        }

        protected void ddlProdPageSize_SelectedIndexChanged(object sender, EventArgs e)
        {
            Response.Redirect(BuildUrl(1, _orderPage, GetDropDownSize(ddlProdPageSize, 25), _orderSize));
        }

        protected void ddlOrderPageSize_SelectedIndexChanged(object sender, EventArgs e)
        {
            Response.Redirect(BuildUrl(_prodPage, 1, _prodSize, GetDropDownSize(ddlOrderPageSize, 25)));
        }

        private void SyncPageSizeFromQuery(string key, DropDownList ddl, ref int size)
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

        private void LoadSellerProfile()
        {
            try
            {
                using (SqlConnection con = new SqlConnection(_strcon))
                {
                    con.Open();
                    string sql = @"SELECT s.*,
                        ISNULL((SELECT COUNT(*) FROM SellerProducts p WHERE p.SellerId = s.Id), 0) AS ProductTotal,
                        ISNULL((SELECT COUNT(*) FROM SellerProducts p WHERE p.SellerId = s.Id AND p.IsActive = 1), 0) AS ProductActive,
                        ISNULL((SELECT COUNT(*) FROM SellerProducts p WHERE p.SellerId = s.Id AND p.IsActive = 0), 0) AS ProductInactive,
                        ISNULL((SELECT COUNT(DISTINCT o.Id) FROM Orders o
                            INNER JOIN OrderItems oi ON o.Id = oi.OrderId
                            INNER JOIN SellerProducts p ON oi.ProductId = p.Id
                            WHERE p.SellerId = s.Id), 0) AS OrderTotal,
                        ISNULL((SELECT SUM(oi.Quantity * oi.UnitPrice) FROM OrderItems oi
                            INNER JOIN SellerProducts p ON oi.ProductId = p.Id
                            WHERE p.SellerId = s.Id), 0) AS SellerRevenue
                        FROM SellerUsers s WHERE s.Id = @id";

                    using (SqlCommand cmd = new SqlCommand(sql, con))
                    {
                        cmd.Parameters.AddWithValue("@id", _sellerId);
                        DataTable dt = new DataTable();
                        new SqlDataAdapter(cmd).Fill(dt);
                        if (dt.Rows.Count == 0)
                        {
                            Response.Redirect("ManageSellers.aspx");
                            return;
                        }

                        DataRow r = dt.Rows[0];
                        string fullName = SafeStr(r["FullName"]);
                        string email = SafeStr(r["Email"]);
                        string storeName = SafeStr(r["StoreName"]);
                        litSellerName.Text = Server.HtmlEncode(string.IsNullOrEmpty(fullName) ? "Seller #" + _sellerId : fullName);
                        litSellerEmail.Text = Server.HtmlEncode(string.IsNullOrEmpty(email) ? "—" : email);

                        int prodTotal = Convert.ToInt32(r["ProductTotal"]);
                        int prodActive = Convert.ToInt32(r["ProductActive"]);
                        int prodInactive = Convert.ToInt32(r["ProductInactive"]);
                        litProductCount.Text = prodTotal.ToString("N0", CultureInfo.InvariantCulture);
                        litProductSplit.Text = string.Format("Active: {0} · Inactive: {1}",
                            prodActive.ToString("N0", CultureInfo.InvariantCulture),
                            prodInactive.ToString("N0", CultureInfo.InvariantCulture));

                        int orderTotal = Convert.ToInt32(r["OrderTotal"]);
                        litOrderCount.Text = orderTotal.ToString("N0", CultureInfo.InvariantCulture);
                        decimal revenue = r["SellerRevenue"] != DBNull.Value ? Convert.ToDecimal(r["SellerRevenue"]) : 0m;
                        litOrderRevenue.Text = "Revenue: " + FormatRs(revenue);

                        litAccountStatus.Text = FormatAccountStatusHtml(r["IsActive"], r["DeletionStatus"]);
                        if (r["CreatedAt"] != DBNull.Value)
                        {
                            DateTime created = Convert.ToDateTime(r["CreatedAt"]);
                            litAccountCreated.Text = "Created: " + created.ToString("MMM dd, yyyy h:mm tt", CultureInfo.InvariantCulture);
                        }
                        else
                            litAccountCreated.Text = "Created: —";

                        bool isKycSubmitted = r["IsKycSubmitted"] != DBNull.Value && Convert.ToBoolean(r["IsKycSubmitted"]);
                        string kycStatus = SafeStr(r["KycStatus"]);
                        if (string.IsNullOrEmpty(kycStatus)) kycStatus = "Draft";

                        litKycSubmission.Text = isKycSubmitted
                            ? "<span class=\"sv-pill sv-pill-green\">Submitted</span>"
                            : "<span class=\"sv-pill sv-pill-muted\">Not submitted</span>";

                        litFinalApproval.Text = FormatKycStatusPill(kycStatus);

                        DateTime updatedAt = r["UpdatedAt"] != DBNull.Value ? Convert.ToDateTime(r["UpdatedAt"]) : DateTime.MinValue;
                        litLastSubmitted.Text = isKycSubmitted && updatedAt != DateTime.MinValue
                            ? updatedAt.ToString("yyyy-MM-dd HH:mm:ss", CultureInfo.InvariantCulture)
                            : "—";
                        litLastFinalReview.Text = (kycStatus.Equals("Approved", StringComparison.OrdinalIgnoreCase)
                            || kycStatus.Equals("Rejected", StringComparison.OrdinalIgnoreCase)) && updatedAt != DateTime.MinValue
                            ? updatedAt.ToString("yyyy-MM-dd HH:mm:ss", CultureInfo.InvariantCulture)
                            : "—";

                        litBusinessName.Text = Server.HtmlEncode(string.IsNullOrEmpty(storeName) ? "—" : storeName);
                        litGst.Text = Server.HtmlEncode(ValOrDash(r["GstNumber"]));
                        litPan.Text = Server.HtmlEncode(ValOrDash(r["PanNumber"]));
                        litAadhaar.Text = Server.HtmlEncode(ValOrDash(r["AadharNumber"]));

                        litBankName.Text = Server.HtmlEncode(ValOrDash(r["BankName"]));
                        litBankHolder.Text = Server.HtmlEncode(ValOrDash(r["BankHolderName"]));
                        litBankAccount.Text = Server.HtmlEncode(ValOrDash(r["BankAccountNumber"]));
                        litBankIfsc.Text = Server.HtmlEncode(ValOrDash(r["BankIFSC"]));

                        string addr = BuildAddress(r);
                        litAddress.Text = Server.HtmlEncode(string.IsNullOrEmpty(addr) ? "—" : addr);
                        string pan = ValOrDash(r["PanNumber"]);
                        litIdType.Text = !string.IsNullOrEmpty(pan) && pan != "—" ? "PAN" : "Aadhaar";
                        litIdNumber.Text = Server.HtmlEncode(!string.IsNullOrEmpty(pan) && pan != "—" ? pan : ValOrDash(r["AadharNumber"]));

                        SetupDocLink(lnkGstDoc, r["KycGstDocPath"], "Open GST Doc");
                        SetupDocLink(lnkPanDoc, r["KycPanDocPath"], "Open PAN Doc");
                        SetupDocLink(lnkAadhaarDoc, r["KycAadharDocPath"], "Open Aadhaar Doc");

                        hlKycAudit.NavigateUrl = "ViewSellerKyc.aspx?id=" + _sellerId;
                    }
                }
            }
            catch
            {
                litSellerName.Text = "Unable to load seller";
            }
        }

        private void LoadProducts()
        {
            try
            {
                using (SqlConnection con = new SqlConnection(_strcon))
                {
                    con.Open();
                    string countSql = "SELECT COUNT(*) FROM SellerProducts WHERE SellerId = @sid";
                    _prodTotal = ScalarInt(con, countSql, _sellerId);

                    int totalPages = Math.Max(1, (int)Math.Ceiling(_prodTotal / (double)_prodSize));
                    if (_prodPage > totalPages) _prodPage = totalPages;
                    int offset = (_prodPage - 1) * _prodSize;

                    string sql = @"SELECT Id, Name, Category, Price, Stock, IsActive, CreatedAt
                        FROM SellerProducts WHERE SellerId = @sid
                        ORDER BY CreatedAt DESC
                        OFFSET @off ROWS FETCH NEXT @size ROWS ONLY";

                    DataTable dt = new DataTable();
                    using (SqlCommand cmd = new SqlCommand(sql, con))
                    {
                        cmd.Parameters.AddWithValue("@sid", _sellerId);
                        cmd.Parameters.AddWithValue("@off", offset);
                        cmd.Parameters.AddWithValue("@size", _prodSize);
                        new SqlDataAdapter(cmd).Fill(dt);
                    }

                    if (dt.Rows.Count > 0)
                    {
                        rptProducts.DataSource = dt;
                        rptProducts.DataBind();
                        rptProducts.Visible = true;
                        pnlProductsEmpty.Visible = false;
                    }
                    else
                    {
                        rptProducts.Visible = false;
                        pnlProductsEmpty.Visible = true;
                    }

                    litProdHint.Text = string.Format(
                        "{0} total in catalog · Type to filter this page only. Pagination is independent of orders below.",
                        _prodTotal);
                    int from = _prodTotal == 0 ? 0 : offset + 1;
                    int to = Math.Min(offset + _prodSize, _prodTotal);
                    litProdShowing.Text = string.Format("Showing {0}–{1} of {2}", from, to, _prodTotal);
                    litProdPageInfo.Text = string.Format("Page {0} of {1}", _prodPage, totalPages);
                    litProdPager.Text = BuildPagerHtml(_prodPage, totalPages, true);
                }
            }
            catch
            {
                rptProducts.Visible = false;
                pnlProductsEmpty.Visible = true;
                litProdHint.Text = "Unable to load products.";
                litProdShowing.Text = "Showing 0 of 0";
                litProdPageInfo.Text = "Page 1 of 1";
                litProdPager.Text = "";
            }
        }

        private void LoadOrders()
        {
            try
            {
                using (SqlConnection con = new SqlConnection(_strcon))
                {
                    con.Open();
                    string countSql = @"SELECT COUNT(DISTINCT o.Id) FROM Orders o
                        INNER JOIN OrderItems oi ON o.Id = oi.OrderId
                        INNER JOIN SellerProducts p ON oi.ProductId = p.Id
                        WHERE p.SellerId = @sid";
                    _orderTotal = ScalarInt(con, countSql, _sellerId);

                    int totalPages = Math.Max(1, (int)Math.Ceiling(_orderTotal / (double)_orderSize));
                    if (_orderPage > totalPages) _orderPage = totalPages;
                    int offset = (_orderPage - 1) * _orderSize;

                    string sql = @"SELECT o.Id, o.OrderRef, o.Status, o.TotalAmount, o.ItemCount, o.CreatedAt, o.PaymentMode,
                        u.FullName, u.Email,
                        (SELECT ISNULL(SUM(oi.Quantity), 0) FROM OrderItems oi
                            INNER JOIN SellerProducts p ON oi.ProductId = p.Id
                            WHERE oi.OrderId = o.Id AND p.SellerId = @sid) AS SellerItems
                        FROM Orders o
                        INNER JOIN Users u ON o.UserId = u.Id
                        WHERE EXISTS (
                            SELECT 1 FROM OrderItems oi
                            INNER JOIN SellerProducts p ON oi.ProductId = p.Id
                            WHERE oi.OrderId = o.Id AND p.SellerId = @sid)
                        ORDER BY o.CreatedAt DESC
                        OFFSET @off ROWS FETCH NEXT @size ROWS ONLY";

                    DataTable dt = new DataTable();
                    using (SqlCommand cmd = new SqlCommand(sql, con))
                    {
                        cmd.Parameters.AddWithValue("@sid", _sellerId);
                        cmd.Parameters.AddWithValue("@off", offset);
                        cmd.Parameters.AddWithValue("@size", _orderSize);
                        new SqlDataAdapter(cmd).Fill(dt);
                    }

                    if (dt.Rows.Count > 0)
                    {
                        rptOrders.DataSource = dt;
                        rptOrders.DataBind();
                        rptOrders.Visible = true;
                        pnlOrdersEmpty.Visible = false;
                    }
                    else
                    {
                        rptOrders.Visible = false;
                        pnlOrdersEmpty.Visible = true;
                    }

                    litOrderHint.Text = string.Format(
                        "{0} total orders · Type to filter this page only. Pagination is independent of products above.",
                        _orderTotal);
                    int from = _orderTotal == 0 ? 0 : offset + 1;
                    int to = Math.Min(offset + _orderSize, _orderTotal);
                    litOrderShowing.Text = string.Format("Showing {0}–{1} of {2}", from, to, _orderTotal);
                    litOrderPageInfo.Text = string.Format("Page {0} of {1}", _orderPage, totalPages);
                    litOrderPager.Text = BuildPagerHtml(_orderPage, totalPages, false);
                }
            }
            catch
            {
                rptOrders.Visible = false;
                pnlOrdersEmpty.Visible = true;
                litOrderHint.Text = "Unable to load orders.";
                litOrderShowing.Text = "Showing 0 of 0";
                litOrderPageInfo.Text = "Page 1 of 1";
                litOrderPager.Text = "";
            }
        }

        private string BuildUrl(int prodPage, int orderPage, int prodSize, int orderSize)
        {
            return string.Format(CultureInfo.InvariantCulture,
                "SellerView.aspx?id={0}&ppage={1}&psize={2}&opage={3}&osize={4}",
                _sellerId, prodPage, prodSize, orderPage, orderSize);
        }

        private string BuildPagerHtml(int currentPage, int totalPages, bool forProducts)
        {
            if (totalPages <= 1) return "";

            int prevPage = currentPage - 1;
            int nextPage = currentPage + 1;
            string prevUrl;
            string nextUrl;

            if (forProducts)
            {
                prevUrl = BuildUrl(prevPage, _orderPage, _prodSize, _orderSize);
                nextUrl = BuildUrl(nextPage, _orderPage, _prodSize, _orderSize);
            }
            else
            {
                prevUrl = BuildUrl(_prodPage, prevPage, _prodSize, _orderSize);
                nextUrl = BuildUrl(_prodPage, nextPage, _prodSize, _orderSize);
            }

            string prev = currentPage > 1
                ? "<a href=\"" + prevUrl + "\">Previous</a>"
                : "<span class=\"disabled\">Previous</span>";
            string next = currentPage < totalPages
                ? "<a href=\"" + nextUrl + "\">Next</a>"
                : "<span class=\"disabled\">Next</span>";

            return prev + "<span class=\"current\">" + currentPage + "</span>" + next;
        }

        private static int ScalarInt(SqlConnection con, string sql, int sellerId)
        {
            using (SqlCommand cmd = new SqlCommand(sql, con))
            {
                cmd.Parameters.AddWithValue("@sid", sellerId);
                object o = cmd.ExecuteScalar();
                return o != null && o != DBNull.Value ? Convert.ToInt32(o) : 0;
            }
        }

        private void SetupDocLink(HyperLink hl, object pathObj, string label)
        {
            string path = pathObj != null && pathObj != DBNull.Value ? pathObj.ToString().Trim() : "";
            if (string.IsNullOrEmpty(path))
            {
                hl.Visible = false;
                return;
            }
            string clean = path.StartsWith("~") ? path.Substring(1) : path;
            if (!clean.StartsWith("/")) clean = "/" + clean;
            hl.NavigateUrl = clean;
            hl.Text = label;
            hl.Target = "_blank";
            hl.Visible = true;
        }

        private static string SafeStr(object o)
        {
            return o != null && o != DBNull.Value ? o.ToString().Trim() : "";
        }

        private static string ValOrDash(object o)
        {
            string s = SafeStr(o);
            return string.IsNullOrEmpty(s) ? "—" : s;
        }

        private static string BuildAddress(DataRow r)
        {
            string line = ValOrDash(r["Address"]);
            if (line == "—") line = "";
            string city = SafeStr(r["City"]);
            string state = SafeStr(r["State"]);
            string pin = SafeStr(r["Pincode"]);
            string tail = "";
            if (!string.IsNullOrEmpty(city)) tail += city;
            if (!string.IsNullOrEmpty(state)) tail += (tail.Length > 0 ? ", " : "") + state;
            if (!string.IsNullOrEmpty(pin)) tail += (tail.Length > 0 ? " - " : "") + pin;
            if (!string.IsNullOrEmpty(tail))
                line = (string.IsNullOrEmpty(line) ? "" : line + ", ") + tail;
            return line;
        }

        private string FormatAccountStatusHtml(object isActive, object deletionStatus)
        {
            string del = SafeStr(deletionStatus);
            if (string.IsNullOrEmpty(del)) del = "None";
            if (del.Equals("Approved", StringComparison.OrdinalIgnoreCase) || del.Equals("Pending", StringComparison.OrdinalIgnoreCase))
                return "<span class=\"ms-status ms-status-deleted\">Deleted</span>";
            bool active = isActive != null && isActive != DBNull.Value && Convert.ToBoolean(isActive);
            if (active)
                return "<span class=\"ms-status ms-status-active\">Active</span>";
            return "<span class=\"ms-status ms-status-inactive\">Inactive</span>";
        }

        private string FormatKycStatusPill(string status)
        {
            string s = string.IsNullOrEmpty(status) ? "Draft" : status;
            if (s.Equals("Approved", StringComparison.OrdinalIgnoreCase))
                return "<span class=\"sv-pill sv-pill-green\">Approved</span>";
            if (s.Equals("Rejected", StringComparison.OrdinalIgnoreCase))
                return "<span class=\"sv-pill sv-pill-red\">Rejected</span>";
            if (s.Equals("Pending", StringComparison.OrdinalIgnoreCase))
                return "<span class=\"sv-pill sv-pill-amber\">Pending</span>";
            return "<span class=\"sv-pill sv-pill-muted\">" + Server.HtmlEncode(s) + "</span>";
        }

        public string FormatRs(object amount)
        {
            if (amount == null || amount == DBNull.Value) return "Rs 0";
            decimal d = Convert.ToDecimal(amount);
            return "Rs " + d.ToString("N0", CultureInfo.InvariantCulture);
        }

        public string FormatProductStatus(object isActive)
        {
            bool active = isActive != null && isActive != DBNull.Value && Convert.ToBoolean(isActive);
            if (active)
                return "<span class=\"sv-pill sv-pill-green\">Active</span>";
            return "<span class=\"sv-pill sv-pill-muted\">Inactive</span>";
        }

        public string FormatProductName(object id, object name)
        {
            string n = SafeStr(name);
            if (string.IsNullOrEmpty(n)) n = "Untitled product";
            string idStr = id != null && id != DBNull.Value ? "#" + id.ToString() : "";
            return "<div class=\"sv-prod-name\">" + Server.HtmlEncode(n) + "<br /><span class=\"sv-prod-id\">" + Server.HtmlEncode(idStr) + "</span></div>";
        }

        public string FormatCategory(object cat)
        {
            string c = SafeStr(cat);
            if (string.IsNullOrEmpty(c)) return "<span class=\"ms-dash\">—</span>";
            return Server.HtmlEncode(c.ToLowerInvariant());
        }

        public string FormatCreatedRow(object created)
        {
            if (created == null || created == DBNull.Value) return "<span class=\"ms-dash\">—</span>";
            return Convert.ToDateTime(created).ToString("yyyy-MM-dd HH:mm:ss", CultureInfo.InvariantCulture);
        }

        public string FormatOrderRef(object refObj, object idObj)
        {
            if (refObj != null && refObj != DBNull.Value && !string.IsNullOrWhiteSpace(refObj.ToString()))
                return Server.HtmlEncode(refObj.ToString().Trim());
            if (idObj != null && idObj != DBNull.Value)
                return Server.HtmlEncode("ORD" + idObj.ToString());
            return "—";
        }

        public string FormatStatusBadge(object status)
        {
            if (status == null || status == DBNull.Value) return "<span class=\"sv-pill sv-pill-muted\">Unknown</span>";
            string s = status.ToString().Trim();
            string key = s.ToLowerInvariant();
            string css = "sv-pill-muted";
            if (key == "delivered" || key == "completed") css = "sv-pill-green";
            else if (key == "cancelled" || key == "canceled") css = "sv-pill-red";
            else if (key == "pending" || key == "processing" || key == "placed" || key == "confirmed") css = "sv-pill-amber";
            else if (key == "shipped" || key == "dispatched") css = "sv-pill-blue";
            return "<span class=\"sv-pill " + css + "\">" + Server.HtmlEncode(s) + "</span>";
        }

        public string FormatPayment(object mode)
        {
            if (mode == null || mode == DBNull.Value) return "COD";
            string m = mode.ToString().Trim();
            return string.IsNullOrEmpty(m) ? "COD" : Server.HtmlEncode(m);
        }

        public string FormatItems(object sellerItems, object orderItems)
        {
            int n = sellerItems != null && sellerItems != DBNull.Value ? Convert.ToInt32(sellerItems) : 0;
            if (n > 0) return n.ToString(CultureInfo.InvariantCulture);
            if (orderItems != null && orderItems != DBNull.Value)
                return Convert.ToInt32(orderItems).ToString(CultureInfo.InvariantCulture);
            return "0";
        }
    }
}
