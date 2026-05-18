using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ecommerce_mlm.admin
{
    public partial class ManageProducts : Page
    {
        private readonly string _strcon = ConfigurationManager.ConnectionStrings["MlmDb"].ConnectionString;
        private string _tab = "approved";
        private int _page = 1;
        private int _pageSize = 25;
        private int _totalCount;
        private int _kpiPending;
        private int _kpiRejected;
        private int _kpiApproved;
        private int _kpiSuspended;

        protected void Page_Load(object sender, EventArgs e)
        {
            _tab = NormalizeTab(Request.QueryString["tab"]);
            int.TryParse(Request.QueryString["page"], out _page);
            if (_page < 1) _page = 1;

            if (!IsPostBack)
            {
                SyncPageSizeFromQuery();
                ShowFlashIfAny();
            }
            else
            {
                _pageSize = GetPageSize();
            }

            LoadKpis();
            BindTabs();
            LoadProducts();
        }

        protected void ddlPageSize_SelectedIndexChanged(object sender, EventArgs e)
        {
            Response.Redirect(BuildUrl(_tab, 1, GetPageSize()));
        }

        protected void rptProducts_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            string pid = e.CommandArgument != null ? e.CommandArgument.ToString() : "";
            if (string.IsNullOrEmpty(pid)) return;

            try
            {
                if (e.CommandName == "ApproveProduct")
                {
                    ExecUpdate("UPDATE SellerProducts SET ListingStatus = 'Approved', IsActive = 1, UpdatedAt = GETDATE() WHERE Id = @pid", pid);
                    Response.Redirect(BuildUrl("approved", 1, _pageSize) + "&msg=approved");
                    return;
                }
                if (e.CommandName == "RejectProduct")
                {
                    ExecUpdate("UPDATE SellerProducts SET ListingStatus = 'Rejected', IsActive = 0, UpdatedAt = GETDATE() WHERE Id = @pid", pid);
                    Response.Redirect(BuildUrl("rejected", 1, _pageSize) + "&msg=rejected");
                    return;
                }
                if (e.CommandName == "SuspendProduct")
                {
                    ExecUpdate(@"UPDATE SellerProducts SET IsActive = 0, UpdatedAt = GETDATE()
                        WHERE Id = @pid AND LOWER(LTRIM(RTRIM(ISNULL(ListingStatus, '')))) IN ('approved', 'active')", pid);
                    Response.Redirect(BuildUrl("suspended", 1, _pageSize) + "&msg=suspended");
                    return;
                }
                if (e.CommandName == "ReactivateProduct")
                {
                    ExecUpdate(@"UPDATE SellerProducts SET IsActive = 1, UpdatedAt = GETDATE()
                        WHERE Id = @pid AND LOWER(LTRIM(RTRIM(ISNULL(ListingStatus, '')))) IN ('approved', 'active')", pid);
                    Response.Redirect(BuildUrl("approved", 1, _pageSize) + "&msg=reactivated");
                    return;
                }
            }
            catch
            {
                Response.Redirect(BuildUrl(_tab, _page, _pageSize) + "&msg=error");
            }
        }

        private void ExecUpdate(string sql, string pid)
        {
            using (SqlConnection con = new SqlConnection(_strcon))
            {
                con.Open();
                using (SqlCommand cmd = new SqlCommand(sql, con))
                {
                    cmd.Parameters.AddWithValue("@pid", pid);
                    cmd.ExecuteNonQuery();
                }
            }
        }

        private void ShowFlashIfAny()
        {
            string msg = Request.QueryString["msg"];
            if (string.IsNullOrEmpty(msg)) return;

            pnlFlash.Visible = true;
            if (msg == "approved")
            {
                litFlash.Text = "Product approved and is live in the catalog.";
                pnlFlash.CssClass = "ms-flash ms-flash-success";
                icoFlash.Attributes["class"] = "fas fa-check-circle";
            }
            else if (msg == "rejected")
            {
                litFlash.Text = "Product rejected. The seller can edit and resubmit.";
                pnlFlash.CssClass = "ms-flash ms-flash-error";
                icoFlash.Attributes["class"] = "fas fa-times-circle";
            }
            else if (msg == "suspended")
            {
                litFlash.Text = "Product suspended and hidden from the shop catalog.";
                pnlFlash.CssClass = "ms-flash ms-flash-warn";
                icoFlash.Attributes["class"] = "fas fa-ban";
            }
            else if (msg == "reactivated")
            {
                litFlash.Text = "Product reactivated and is live in the catalog again.";
                pnlFlash.CssClass = "ms-flash ms-flash-success";
                icoFlash.Attributes["class"] = "fas fa-check-circle";
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

        private static string NormalizeTab(string tab)
        {
            if (string.IsNullOrEmpty(tab)) return "approved";
            tab = tab.Trim().ToLowerInvariant();
            if (tab == "pending" || tab == "rejected" || tab == "approved" || tab == "suspended") return tab;
            return "approved";
        }

        private static string ApprovedStatusSql(string tableAlias)
        {
            string col = string.IsNullOrEmpty(tableAlias) ? "ListingStatus" : tableAlias + ".ListingStatus";
            return "LOWER(LTRIM(RTRIM(ISNULL(" + col + ", '')))) IN ('approved', 'active')";
        }

        private void LoadKpis()
        {
            try
            {
                using (SqlConnection con = new SqlConnection(_strcon))
                {
                    con.Open();
                    _kpiPending = Scalar(con, @"SELECT COUNT(*) FROM SellerProducts
                        WHERE ISNULL(ListingStatus, 'Pending') = 'Pending'
                           OR LTRIM(RTRIM(ISNULL(ListingStatus, ''))) = ''");
                    _kpiRejected = Scalar(con, @"SELECT COUNT(*) FROM SellerProducts
                        WHERE LOWER(LTRIM(RTRIM(ISNULL(ListingStatus, '')))) = 'rejected'");
                    _kpiApproved = Scalar(con, @"SELECT COUNT(*) FROM SellerProducts
                        WHERE " + ApprovedStatusSql("") + " AND IsActive = 1");
                    _kpiSuspended = Scalar(con, @"SELECT COUNT(*) FROM SellerProducts
                        WHERE " + ApprovedStatusSql("") + " AND IsActive = 0");
                }

                litKpiPending.Text = _kpiPending.ToString("N0", CultureInfo.InvariantCulture);
                litKpiRejected.Text = _kpiRejected.ToString("N0", CultureInfo.InvariantCulture);
                litKpiApproved.Text = _kpiApproved.ToString("N0", CultureInfo.InvariantCulture);
            }
            catch
            {
                litKpiPending.Text = litKpiRejected.Text = litKpiApproved.Text = "0";
                _kpiSuspended = 0;
            }
        }

        private void BindTabs()
        {
            litTabPending.Text = _kpiPending.ToString(CultureInfo.InvariantCulture);
            litTabRejected.Text = _kpiRejected.ToString(CultureInfo.InvariantCulture);
            litTabApproved.Text = _kpiApproved.ToString(CultureInfo.InvariantCulture);
            litTabSuspended.Text = _kpiSuspended.ToString(CultureInfo.InvariantCulture);

            hlTabPending.NavigateUrl = BuildUrl("pending", 1, _pageSize);
            hlTabRejected.NavigateUrl = BuildUrl("rejected", 1, _pageSize);
            hlTabApproved.NavigateUrl = BuildUrl("approved", 1, _pageSize);
            hlTabSuspended.NavigateUrl = BuildUrl("suspended", 1, _pageSize);

            hlTabPending.CssClass = "mp-tab" + (_tab == "pending" ? " active" : "");
            hlTabRejected.CssClass = "mp-tab" + (_tab == "rejected" ? " active" : "");
            hlTabApproved.CssClass = "mp-tab" + (_tab == "approved" ? " active" : "");
            hlTabSuspended.CssClass = "mp-tab" + (_tab == "suspended" ? " active" : "");

            if (_tab == "pending")
            {
                litTableTitle.Text = "Pending submissions";
                litTableHint.Text = "Review new seller listings — approve or reject before they go live.";
            }
            else if (_tab == "rejected")
            {
                litTableTitle.Text = "Rejected listings";
                litTableHint.Text = "Rejected products can be edited and resubmitted by the seller.";
            }
            else if (_tab == "suspended")
            {
                litTableTitle.Text = "Suspended listings";
                litTableHint.Text = "Approved products hidden from the shop — reactivate to publish again.";
            }
            else
            {
                litTableTitle.Text = "Recently approved";
                litTableHint.Text = "Live in catalog — suspend to hide without rejecting.";
            }
        }

        private void LoadProducts()
        {
            string where = GetTabWhereClause();
            string orderBy = _tab == "pending"
                ? "p.CreatedAt ASC"
                : "ISNULL(p.UpdatedAt, p.CreatedAt) DESC";

            try
            {
                using (SqlConnection con = new SqlConnection(_strcon))
                {
                    con.Open();
                    string countSql = "SELECT COUNT(*) FROM SellerProducts p WHERE " + where;
                    _totalCount = Scalar(con, countSql);

                    int totalPages = Math.Max(1, (int)Math.Ceiling(_totalCount / (double)_pageSize));
                    if (_page > totalPages) _page = totalPages;
                    int offset = (_page - 1) * _pageSize;

                    litKpiThisList.Text = _totalCount.ToString("N0", CultureInfo.InvariantCulture);

                    string sql = @"SELECT p.Id, p.Name, p.Sku, p.Slug, p.Category, p.Price, p.Mrp, p.Stock, p.MainImage,
                        p.IsActive, p.CreatedAt, p.UpdatedAt, p.ListingStatus,
                        s.Id AS SellerId, s.FullName AS SellerName, s.Email AS SellerEmail, s.StoreName
                        FROM SellerProducts p
                        LEFT JOIN SellerUsers s ON p.SellerId = s.Id
                        WHERE " + where + @"
                        ORDER BY " + orderBy + @"
                        OFFSET @off ROWS FETCH NEXT @size ROWS ONLY";

                    DataTable dt = new DataTable();
                    using (SqlCommand cmd = new SqlCommand(sql, con))
                    {
                        cmd.Parameters.AddWithValue("@off", offset);
                        cmd.Parameters.AddWithValue("@size", _pageSize);
                        new SqlDataAdapter(cmd).Fill(dt);
                    }

                    if (dt.Rows.Count > 0)
                    {
                        rptProducts.DataSource = dt;
                        rptProducts.DataBind();
                        rptProducts.Visible = true;
                        pnlEmpty.Visible = false;
                    }
                    else
                    {
                        rptProducts.Visible = false;
                        pnlEmpty.Visible = true;
                        litEmptyTitle.Text = GetEmptyTitle();
                        litEmptyDesc.Text = GetEmptyDesc();
                    }

                    int from = _totalCount == 0 ? 0 : offset + 1;
                    int to = Math.Min(offset + _pageSize, _totalCount);
                    litShowing.Text = string.Format("Showing {0}–{1} of {2}", from, to, _totalCount);
                    litKpiListSub.Text = string.Format("Showing {0}–{1} of {2}", from, to, _totalCount);
                    litPageInfo.Text = string.Format("Page {0} of {1}", _page, totalPages);
                    litPager.Text = BuildPagerHtml(totalPages);
                }
            }
            catch
            {
                rptProducts.Visible = false;
                pnlEmpty.Visible = true;
                litShowing.Text = "Showing 0 of 0";
                litKpiListSub.Text = "Unable to load list";
                litPageInfo.Text = "Page 1 of 1";
                litPager.Text = "";
                litKpiThisList.Text = "0";
            }
        }

        private string GetTabWhereClause()
        {
            if (_tab == "pending")
            {
                return @"(ISNULL(p.ListingStatus, 'Pending') = 'Pending'
                    OR LTRIM(RTRIM(ISNULL(p.ListingStatus, ''))) = '')";
            }
            if (_tab == "rejected")
            {
                return "LOWER(LTRIM(RTRIM(ISNULL(p.ListingStatus, '')))) = 'rejected'";
            }
            if (_tab == "suspended")
            {
                return ApprovedStatusSql("p") + " AND p.IsActive = 0";
            }
            return ApprovedStatusSql("p") + " AND p.IsActive = 1";
        }

        private string GetEmptyTitle()
        {
            if (_tab == "pending") return "No pending products";
            if (_tab == "rejected") return "No rejected products";
            if (_tab == "suspended") return "No suspended products";
            return "No approved products";
        }

        private string GetEmptyDesc()
        {
            if (_tab == "pending") return "New seller submissions will appear here for review.";
            if (_tab == "rejected") return "Rejected listings will show here.";
            if (_tab == "suspended") return "Suspended listings will appear here when you suspend approved products.";
            return "Approved catalog items will appear here.";
        }

        private string BuildUrl(string tab, int page, int size)
        {
            return string.Format(CultureInfo.InvariantCulture,
                "ManageProducts.aspx?tab={0}&page={1}&size={2}", tab, page, size);
        }

        private string BuildPagerHtml(int totalPages)
        {
            if (totalPages <= 1) return "";

            string prev = _page > 1
                ? "<a href=\"" + BuildUrl(_tab, _page - 1, _pageSize) + "\">Previous</a>"
                : "<span class=\"disabled\">Previous</span>";
            string next = _page < totalPages
                ? "<a href=\"" + BuildUrl(_tab, _page + 1, _pageSize) + "\">Next</a>"
                : "<span class=\"disabled\">Next</span>";

            return prev + "<span class=\"current\">" + _page + "</span>" + next;
        }

        private static int Scalar(SqlConnection con, string sql)
        {
            using (SqlCommand cmd = new SqlCommand(sql, con))
            {
                object o = cmd.ExecuteScalar();
                return o != null && o != DBNull.Value ? Convert.ToInt32(o) : 0;
            }
        }

        private int GetPageSize()
        {
            int size = 25;
            if (ddlPageSize != null) int.TryParse(ddlPageSize.SelectedValue, out size);
            return size < 5 ? 25 : size;
        }

        public bool ShowPendingActions()
        {
            return _tab == "pending";
        }

        public bool ShowApprovedActions()
        {
            return _tab == "approved";
        }

        public bool ShowSuspendedActions()
        {
            return _tab == "suspended";
        }

        public string FormatProductCell(object id, object name, object slug, object sku, object img)
        {
            string n = SafeStr(name);
            if (string.IsNullOrEmpty(n)) n = "Untitled product";

            string idPart = id != null && id != DBNull.Value ? "#" + id.ToString() : "";
            string slugPart = TruncateSlug(SafeStr(slug));
            string metaLine = idPart;
            if (!string.IsNullOrEmpty(slugPart))
                metaLine += (metaLine.Length > 0 ? " · " : "") + slugPart;

            string skuLine = "SKU " + (string.IsNullOrEmpty(SafeStr(sku)) ? "—" : SafeStr(sku));
            string imgUrl = ResolveImageUrl(img);

            return "<div class=\"mp-prod-cell\">" +
                "<img src=\"" + Server.HtmlEncode(imgUrl) + "\" alt=\"\" class=\"mp-prod-thumb\" />" +
                "<div class=\"mp-prod-meta\">" +
                "<span class=\"mp-prod-name\">" + Server.HtmlEncode(n) + "</span>" +
                "<span class=\"mp-prod-sub\">" + Server.HtmlEncode(metaLine) + "</span>" +
                "<span class=\"mp-prod-sku\">" + Server.HtmlEncode(skuLine) + "</span>" +
                "</div></div>";
        }

        public string FormatSellerCell(object sellerId, object fullName, object email, object storeName)
        {
            string name = SafeStr(fullName);
            if (string.IsNullOrEmpty(name)) name = "Unknown seller";
            string em = SafeStr(email);
            string store = SafeStr(storeName);

            string sid = sellerId != null && sellerId != DBNull.Value ? sellerId.ToString() : "";
            string profileLink = string.IsNullOrEmpty(sid)
                ? ""
                : "<a href=\"SellerView.aspx?id=" + Server.HtmlEncode(sid) + "\" class=\"mp-seller-link\">Seller profile &rarr;</a>";

            return "<div class=\"mp-seller-cell\">" +
                "<span class=\"mp-seller-name\">" + Server.HtmlEncode(name) + "</span>" +
                (string.IsNullOrEmpty(em) ? "" : "<span class=\"mp-seller-email\">" + Server.HtmlEncode(em) + "</span>") +
                (string.IsNullOrEmpty(store) ? "" : "<span class=\"mp-seller-store\">" + Server.HtmlEncode(store) + "</span>") +
                profileLink +
                "</div>";
        }

        public string FormatCategoryPill(object cat)
        {
            string c = SafeStr(cat);
            if (string.IsNullOrEmpty(c)) return "<span class=\"ms-dash\">—</span>";
            return "<span class=\"mp-cat-pill\">" + Server.HtmlEncode(c.ToLowerInvariant()) + "</span>";
        }

        public string FormatPriceCell(object price, object mrp)
        {
            decimal p = price != null && price != DBNull.Value ? Convert.ToDecimal(price) : 0m;
            decimal m = mrp != null && mrp != DBNull.Value ? Convert.ToDecimal(mrp) : 0m;
            string html = "<span class=\"mp-price\">₹" + p.ToString("N0", CultureInfo.InvariantCulture) + "</span>";
            if (m > 0)
                html += "<span class=\"mp-mrp\">MRP ₹" + m.ToString("N0", CultureInfo.InvariantCulture) + "</span>";
            return html;
        }

        public string FormatStatusBadge(object dbStatus, object dbIsActive)
        {
            string status = dbStatus != null && dbStatus != DBNull.Value ? dbStatus.ToString().Trim() : "Pending";
            bool isActive = dbIsActive != null && dbIsActive != DBNull.Value && Convert.ToBoolean(dbIsActive);

            if (status.Equals("Pending", StringComparison.OrdinalIgnoreCase) || string.IsNullOrEmpty(status))
                return "<span class=\"mp-status mp-status-pending\">Pending</span>";
            if (status.Equals("Rejected", StringComparison.OrdinalIgnoreCase))
                return "<span class=\"mp-status mp-status-rejected\">Rejected</span>";
            if (status.Equals("Approved", StringComparison.OrdinalIgnoreCase) || status.Equals("Active", StringComparison.OrdinalIgnoreCase))
            {
                if (isActive)
                    return "<span class=\"mp-status mp-status-approved\">Approved</span>";
                return "<span class=\"mp-status mp-status-suspended\">Suspended</span>";
            }
            return "<span class=\"mp-status mp-status-muted\">" + Server.HtmlEncode(status) + "</span>";
        }

        public string FormatAdded(object created)
        {
            if (created == null || created == DBNull.Value) return "<span class=\"ms-dash\">—</span>";
            DateTime dt = Convert.ToDateTime(created);
            return dt.ToString("MMM dd, yyyy · h:mm tt", CultureInfo.InvariantCulture);
        }

        public string GetViewUrl(object slug)
        {
            string s = SafeStr(slug);
            if (string.IsNullOrEmpty(s)) return "#";
            return ResolveUrl("~/ProductDetails.aspx?slug=" + Server.UrlEncode(s));
        }

        private string ResolveImageUrl(object img)
        {
            string path = SafeStr(img);
            if (string.IsNullOrEmpty(path)) return ResolveUrl("~/assets/images/no-product.png");
            if (path.StartsWith("http", StringComparison.OrdinalIgnoreCase)) return path;
            if (path.StartsWith("~")) return ResolveUrl(path);
            if (path.StartsWith("/")) return ResolveUrl("~" + path);
            return ResolveUrl("~/" + path.TrimStart('/'));
        }

        private static string SafeStr(object o)
        {
            return o != null && o != DBNull.Value ? o.ToString().Trim() : "";
        }

        private static string TruncateSlug(string slug)
        {
            if (string.IsNullOrEmpty(slug)) return "";
            if (slug.Length <= 28) return slug;
            return slug.Substring(0, 25) + "...";
        }
    }
}
