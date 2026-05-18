using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ecommerce_mlm.admin
{
    public partial class ManageSellers : Page
    {
        string strcon = ConfigurationManager.ConnectionStrings["MlmDb"].ConnectionString;
        int _totalCount;
        int _pageSize = 25;
        int _currentPage = 1;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                int.TryParse(Request.QueryString["page"], out _currentPage);
                if (_currentPage < 1) _currentPage = 1;

                int.TryParse(Request.QueryString["size"], out _pageSize);
                if (_pageSize < 5) _pageSize = 25;
                ddlPageSize.SelectedValue = _pageSize.ToString();

                ShowFlash();
                LoadKpis();
            }

            LoadSellers();
        }

        protected void ddlPageSize_SelectedIndexChanged(object sender, EventArgs e)
        {
            Response.Redirect(BuildUrl(1));
        }

        protected void rptSellers_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            string sellerId = e.CommandArgument.ToString();

            if (e.CommandName == "ToggleStatus")
            {
                try
                {
                    using (SqlConnection con = new SqlConnection(strcon))
                    {
                        con.Open();
                        using (SqlCommand chk = new SqlCommand("SELECT IsActive FROM SellerUsers WHERE Id = @id", con))
                        {
                            chk.Parameters.AddWithValue("@id", sellerId);
                            object val = chk.ExecuteScalar();
                            if (val == null || val == DBNull.Value) return;
                            bool current = Convert.ToBoolean(val);

                            using (SqlCommand cmd = new SqlCommand("UPDATE SellerUsers SET IsActive = @active, UpdatedAt = GETDATE() WHERE Id = @id", con))
                            {
                                cmd.Parameters.AddWithValue("@active", !current);
                                cmd.Parameters.AddWithValue("@id", sellerId);
                                cmd.ExecuteNonQuery();
                            }
                        }
                    }
                }
                catch { }

                Response.Redirect(BuildUrl(GetCurrentPage(), "toggled"));
                return;
            }

        }

        protected void btnConfirmDeleteSeller_Click(object sender, EventArgs e)
        {
            string sellerId = hfDeleteSellerId.Value;
            if (string.IsNullOrWhiteSpace(sellerId)) return;
            if (!CanDeleteSeller(sellerId)) return;

            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    using (SqlCommand cmd = new SqlCommand(@"UPDATE SellerUsers SET IsActive = 0, DeletionStatus = 'Approved', DeactivationDate = GETDATE(), UpdatedAt = GETDATE() WHERE Id = @id", con))
                    {
                        cmd.Parameters.AddWithValue("@id", sellerId);
                        cmd.ExecuteNonQuery();
                    }
                }
            }
            catch { }

            Response.Redirect(BuildUrl(GetCurrentPage(), "deleted"));
        }

        public string AttrEnc(object value)
        {
            if (value == null || value == DBNull.Value) return "";
            return HttpUtility.HtmlAttributeEncode(value.ToString());
        }

        private void ShowFlash()
        {
            string msg = Request.QueryString["msg"];
            if (string.IsNullOrEmpty(msg)) return;

            pnlFlash.Visible = true;
            if (msg == "toggled")
            {
                pnlFlash.CssClass = "ms-flash ms-flash-success";
                icoFlash.Attributes["class"] = "fas fa-check-circle";
                litFlash.Text = "Seller access updated successfully.";
            }
            else if (msg == "deleted")
            {
                pnlFlash.CssClass = "ms-flash ms-flash-warn";
                icoFlash.Attributes["class"] = "fas fa-trash-alt";
                litFlash.Text = "Seller account has been marked as deleted.";
            }
            else if (msg == "error")
            {
                pnlFlash.CssClass = "ms-flash ms-flash-error";
                icoFlash.Attributes["class"] = "fas fa-exclamation-circle";
                litFlash.Text = "Action could not be completed. Please try again.";
            }
        }

        private string BuildUrl(int page, string msg = null)
        {
            string url = "ManageSellers.aspx?page=" + page + "&size=" + GetPageSize();
            if (!string.IsNullOrEmpty(msg))
                url += "&msg=" + Server.UrlEncode(msg);
            return url;
        }

        private int GetCurrentPage()
        {
            int page = 1;
            int.TryParse(Request.QueryString["page"], out page);
            return page < 1 ? 1 : page;
        }

        private void LoadKpis()
        {
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    litActive.Text = Scalar(con, @"SELECT COUNT(*) FROM SellerUsers WHERE IsActive = 1 AND ISNULL(DeletionStatus, 'None') IN ('None', '')").ToString("N0");
                    litNewToday.Text = Scalar(con, "SELECT COUNT(*) FROM SellerUsers WHERE CAST(CreatedAt AS DATE) = CAST(GETDATE() AS DATE)").ToString("N0");
                    litInactive.Text = Scalar(con, @"SELECT COUNT(*) FROM SellerUsers WHERE IsActive = 0 AND ISNULL(DeletionStatus, 'None') IN ('None', '')").ToString("N0");
                    litPendingKyc.Text = Scalar(con, @"SELECT COUNT(*) FROM SellerUsers WHERE KycStatus = 'Pending' OR EditRequestStatus IN ('PendingApproval', 'DraftSubmitted')").ToString("N0");
                    litKycDate.Text = DateTime.Now.ToString("MMM dd, yyyy", CultureInfo.InvariantCulture);
                }
            }
            catch
            {
                litActive.Text = litNewToday.Text = litInactive.Text = litPendingKyc.Text = "0";
            }
        }

        private void LoadSellers()
        {
            _pageSize = GetPageSize();
            int.TryParse(Request.QueryString["page"], out _currentPage);
            if (_currentPage < 1) _currentPage = 1;

            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();

                    _totalCount = Scalar(con, "SELECT COUNT(*) FROM SellerUsers");
                    int totalPages = Math.Max(1, (int)Math.Ceiling(_totalCount / (double)_pageSize));
                    if (_currentPage > totalPages) _currentPage = totalPages;

                    int offset = (_currentPage - 1) * _pageSize;

                    string sql = @"
                        SELECT s.Id, s.FullName, s.Email, s.Phone, s.RequestedCategories, s.IsActive,
                               s.KycStatus, s.DeletionStatus, s.CreatedAt, s.StoreName,
                               s.Address, s.City, s.State, s.Pincode, s.LogoPath, s.BannerPath,
                               ISNULL(st.TotalStock, 0) AS TotalStock,
                               ISNULL(st.TotalSells, 0) AS TotalSells,
                               ISNULL(st.TotalClients, 0) AS TotalClients,
                               ISNULL(st.TotalRevenue, 0) AS TotalRevenue,
                               ISNULL(st.AvgRating, 0) AS AvgRating,
                               ISNULL(st.ReviewCount, 0) AS ReviewCount
                        FROM SellerUsers s
                        OUTER APPLY (
                            SELECT
                                (SELECT ISNULL(SUM(p.Stock), 0) FROM SellerProducts p WHERE p.SellerId = s.Id) AS TotalStock,
                                (SELECT ISNULL(SUM(oi.Quantity), 0) FROM OrderItems oi INNER JOIN SellerProducts p ON oi.ProductId = p.Id WHERE p.SellerId = s.Id) AS TotalSells,
                                (SELECT COUNT(DISTINCT o.UserId) FROM Orders o INNER JOIN OrderItems oi ON o.Id = oi.OrderId INNER JOIN SellerProducts p ON oi.ProductId = p.Id WHERE p.SellerId = s.Id) AS TotalClients,
                                (SELECT ISNULL(SUM(oi.Quantity * oi.UnitPrice), 0) FROM OrderItems oi INNER JOIN SellerProducts p ON oi.ProductId = p.Id WHERE p.SellerId = s.Id) AS TotalRevenue,
                                (SELECT AVG(CAST(pr.Rating AS DECIMAL(5,2))) FROM ProductReviews pr INNER JOIN SellerProducts p ON pr.ProductId = p.Id WHERE p.SellerId = s.Id AND pr.IsApproved = 1) AS AvgRating,
                                (SELECT COUNT(*) FROM ProductReviews pr INNER JOIN SellerProducts p ON pr.ProductId = p.Id WHERE p.SellerId = s.Id AND pr.IsApproved = 1) AS ReviewCount
                        ) st
                        ORDER BY s.CreatedAt DESC
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
                        rptSellers.DataSource = dt;
                        rptSellers.DataBind();
                        rptSellersGrid.DataSource = dt;
                        rptSellersGrid.DataBind();
                        rptSellers.Visible = true;
                        rptSellersGrid.Visible = true;
                        pnlEmpty.Visible = false;
                    }
                    else
                    {
                        rptSellers.Visible = false;
                        rptSellersGrid.Visible = false;
                        pnlEmpty.Visible = true;
                    }

                    litTableHint.Text = string.Format(
                        "{0} seller account{1} · Search filters this page only.",
                        _totalCount, _totalCount == 1 ? "" : "s");

                    int from = _totalCount == 0 ? 0 : offset + 1;
                    int to = Math.Min(offset + _pageSize, _totalCount);
                    litShowing.Text = string.Format("Showing {0}–{1} of {2}", from, to, _totalCount);
                    litPageInfo.Text = string.Format("Page {0} of {1}", _currentPage, totalPages);
                    litPager.Text = BuildPagerHtml(totalPages);
                }
            }
            catch
            {
                rptSellers.Visible = false;
                rptSellersGrid.Visible = false;
                pnlEmpty.Visible = true;
                litTableHint.Text = "Unable to load sellers.";
                litShowing.Text = "Showing 0 of 0";
                litPageInfo.Text = "Page 1 of 1";
                litPager.Text = "";
            }
        }

        private string BuildPagerHtml(int totalPages)
        {
            if (totalPages <= 1) return "";

            string prev = _currentPage > 1
                ? "<a href=\"" + BuildUrl(_currentPage - 1) + "\">Previous</a>"
                : "<span class=\"disabled\">Previous</span>";

            string next = _currentPage < totalPages
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
            int size = 25;
            if (ddlPageSize != null)
                int.TryParse(ddlPageSize.SelectedValue, out size);
            return size < 5 ? 25 : size;
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

        public string FormatPhone(object phone)
        {
            if (phone == null || phone == DBNull.Value) return "<span class=\"ms-dash\">—</span>";
            string p = phone.ToString().Trim();
            if (string.IsNullOrEmpty(p) || p == "0") return "<span class=\"ms-dash\">—</span>";
            return Server.HtmlEncode(p);
        }

        public string FormatContact(object email, object phone)
        {
            string emailLine = FormatContactLine(email, "fa-envelope", false);
            string phoneLine = FormatContactLine(phone, "fa-phone", true);
            return "<div class=\"ms-contact-cell\">" + emailLine + phoneLine + "</div>";
        }

        private string FormatContactLine(object value, string iconClass, bool isPhone)
        {
            string text = value != null && value != DBNull.Value ? value.ToString().Trim() : "";
            if (isPhone && (string.IsNullOrEmpty(text) || text == "0"))
                return "<span class=\"ms-contact-line\"><i class=\"fas " + iconClass + "\"></i><span class=\"ms-dash\">—</span></span>";

            if (string.IsNullOrEmpty(text))
                return "<span class=\"ms-contact-line\"><i class=\"fas " + iconClass + "\"></i><span class=\"ms-dash\">—</span></span>";

            return "<span class=\"ms-contact-line\"><i class=\"fas " + iconClass + "\"></i>" + Server.HtmlEncode(text) + "</span>";
        }

        public string FormatCategories(object cats)
        {
            if (cats == null || cats == DBNull.Value) return "<span class=\"ms-dash\">—</span>";
            string c = cats.ToString().Trim();
            if (string.IsNullOrEmpty(c)) return "<span class=\"ms-dash\">—</span>";
            return "<span class=\"ms-cats\">" + Server.HtmlEncode(c.ToLowerInvariant()) + "</span>";
        }

        public string FormatMetric(object value)
        {
            int n = value != null && value != DBNull.Value ? Convert.ToInt32(value) : 0;
            return "<span class=\"ms-metric\">" + n + "</span>";
        }

        public string FormatMetrics(object stock, object sells, object clients)
        {
            return FormatMetric(stock) + " / " + FormatMetric(sells) + " / " + FormatMetric(clients);
        }

        public string FormatRevenue(object revenue)
        {
            if (revenue == null || revenue == DBNull.Value) return "Rs 0";
            decimal r = Convert.ToDecimal(revenue);
            if (r >= 100000) return "Rs " + (r / 100000m).ToString("0.#", CultureInfo.InvariantCulture) + "L";
            if (r >= 1000) return "Rs " + (r / 1000m).ToString("0.#", CultureInfo.InvariantCulture) + "k";
            return "Rs " + r.ToString("N0", CultureInfo.InvariantCulture);
        }

        public string FormatStatusBadge(object isActive, object deletionStatus)
        {
            string del = deletionStatus != null && deletionStatus != DBNull.Value ? deletionStatus.ToString().Trim() : "None";
            if (del.Equals("Approved", StringComparison.OrdinalIgnoreCase) || del.Equals("Pending", StringComparison.OrdinalIgnoreCase))
                return "<span class=\"ms-status ms-status-deleted\">Deleted</span>";

            bool active = isActive != null && isActive != DBNull.Value && Convert.ToBoolean(isActive);
            if (active)
                return "<span class=\"ms-status ms-status-active\">Active</span>";

            return "<span class=\"ms-status ms-status-inactive\">Inactive</span>";
        }

        public string FormatCreated(object created)
        {
            if (created == null || created == DBNull.Value) return "<span class=\"ms-dash\">—</span>";
            DateTime dt = Convert.ToDateTime(created);
            return dt.ToString("MMM dd, yyyy", CultureInfo.InvariantCulture);
        }

        public string GetToggleClass(object isActive, object deletionStatus)
        {
            string del = deletionStatus != null && deletionStatus != DBNull.Value ? deletionStatus.ToString().Trim() : "None";
            if (del.Equals("Approved", StringComparison.OrdinalIgnoreCase) || del.Equals("Pending", StringComparison.OrdinalIgnoreCase))
                return "ms-toggle off locked";

            bool active = isActive != null && isActive != DBNull.Value && Convert.ToBoolean(isActive);
            return active ? "ms-toggle on" : "ms-toggle off";
        }

        public string GetAccessLabel(object isActive, object deletionStatus)
        {
            string del = deletionStatus != null && deletionStatus != DBNull.Value ? deletionStatus.ToString().Trim() : "None";
            if (del.Equals("Approved", StringComparison.OrdinalIgnoreCase) || del.Equals("Pending", StringComparison.OrdinalIgnoreCase))
                return "Disabled";

            bool active = isActive != null && isActive != DBNull.Value && Convert.ToBoolean(isActive);
            return active ? "Active" : "Disabled";
        }

        public bool CanToggleAccess(object isActive, object deletionStatus)
        {
            string del = deletionStatus != null && deletionStatus != DBNull.Value ? deletionStatus.ToString().Trim() : "None";
            return !del.Equals("Approved", StringComparison.OrdinalIgnoreCase) && !del.Equals("Pending", StringComparison.OrdinalIgnoreCase);
        }

        public bool ShowDeleteButton(object id, object fullName, object storeName, object deletionStatus)
        {
            if (!CanDeleteSeller(id != null ? id.ToString() : "0")) return false;
            string del = deletionStatus != null && deletionStatus != DBNull.Value ? deletionStatus.ToString().Trim() : "None";
            return !del.Equals("Approved", StringComparison.OrdinalIgnoreCase);
        }

        private bool CanDeleteSeller(string sellerId)
        {
            int id;
            if (!int.TryParse(sellerId, out id) || id <= 1) return false;

            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    using (SqlCommand cmd = new SqlCommand("SELECT FullName, StoreName FROM SellerUsers WHERE Id = @id", con))
                    {
                        cmd.Parameters.AddWithValue("@id", id);
                        using (SqlDataReader dr = cmd.ExecuteReader())
                        {
                            if (!dr.Read()) return false;
                            string name = dr["FullName"] != DBNull.Value ? dr["FullName"].ToString() : "";
                            string store = dr["StoreName"] != DBNull.Value ? dr["StoreName"].ToString() : "";
                            if (name.IndexOf("default", StringComparison.OrdinalIgnoreCase) >= 0 ||
                                store.IndexOf("default", StringComparison.OrdinalIgnoreCase) >= 0)
                                return false;
                        }
                    }
                }
            }
            catch { return false; }

            return true;
        }

        public string GetRowClass(object isActive, object deletionStatus)
        {
            string del = deletionStatus != null && deletionStatus != DBNull.Value ? deletionStatus.ToString().Trim() : "None";
            if (del.Equals("Approved", StringComparison.OrdinalIgnoreCase)) return "ms-seller-row ms-row-deleted";
            bool active = isActive != null && isActive != DBNull.Value && Convert.ToBoolean(isActive);
            return active ? "ms-seller-row" : "ms-seller-row ms-row-muted";
        }

        public string GetGridCardClass(object isActive, object deletionStatus)
        {
            string del = deletionStatus != null && deletionStatus != DBNull.Value ? deletionStatus.ToString().Trim() : "None";
            if (del.Equals("Approved", StringComparison.OrdinalIgnoreCase) || del.Equals("Pending", StringComparison.OrdinalIgnoreCase))
                return "ms-grid-card is-deleted";
            bool active = isActive != null && isActive != DBNull.Value && Convert.ToBoolean(isActive);
            return active ? "ms-grid-card" : "ms-grid-card is-disabled";
        }

        public string GetHeroClass(object bannerPath, object id)
        {
            string bannerUrl;
            if (TryGetBannerUrl(bannerPath, out bannerUrl)) return "ms-gc-hero has-banner";
            int n = 0;
            if (id != null && id != DBNull.Value) int.TryParse(id.ToString(), out n);
            return "ms-gc-hero ms-gc-hero--" + ((n % 6) + 1);
        }

        public string FormatHeroBackground(object bannerPath)
        {
            string url;
            if (!TryGetBannerUrl(bannerPath, out url)) return "";
            return "<img class=\"ms-gc-hero-img\" src=\"" + HttpUtility.HtmlAttributeEncode(url) + "\" alt=\"\" loading=\"lazy\" />";
        }

        private bool TryGetBannerUrl(object bannerPath, out string url)
        {
            url = "";
            if (bannerPath == null || bannerPath == DBNull.Value) return false;
            string raw = bannerPath.ToString().Trim();
            if (string.IsNullOrEmpty(raw)) return false;

            url = ResolveUrl(NormalizeMediaPath(raw));
            return !string.IsNullOrEmpty(url);
        }

        public string FormatGridHeroBadge(object isActive, object deletionStatus)
        {
            string del = deletionStatus != null && deletionStatus != DBNull.Value ? deletionStatus.ToString().Trim() : "None";
            if (del.Equals("Approved", StringComparison.OrdinalIgnoreCase) || del.Equals("Pending", StringComparison.OrdinalIgnoreCase))
                return "<span class=\"ms-gc-badge ms-gc-badge-deleted\">DELETED</span>";
            bool active = isActive != null && isActive != DBNull.Value && Convert.ToBoolean(isActive);
            if (active)
                return "<span class=\"ms-gc-badge ms-gc-badge-active\">ACTIVE</span>";
            return "<span class=\"ms-gc-badge ms-gc-badge-off\">INACTIVE</span>";
        }

        public string FormatGridAvatar(object logoPath, object fullName)
        {
            string logo = logoPath != null && logoPath != DBNull.Value ? logoPath.ToString().Trim() : "";
            if (!string.IsNullOrEmpty(logo))
                return "<img src=\"" + ResolveUrl(NormalizeMediaPath(logo)) + "\" alt=\"\" class=\"ms-gc-avatar-img\" />";
            return "<span class=\"ms-gc-avatar-init\">" + GetInitials(fullName) + "</span>";
        }

        public string FormatCategoryTags(object cats)
        {
            if (cats == null || cats == DBNull.Value) return "";
            string raw = cats.ToString().Trim();
            if (string.IsNullOrEmpty(raw)) return "";
            string[] parts = raw.Split(new[] { ',', ';' }, StringSplitOptions.RemoveEmptyEntries);
            var sb = new System.Text.StringBuilder();
            int n = 0;
            foreach (string p in parts)
            {
                if (n >= 4) break;
                string t = p.Trim();
                if (string.IsNullOrEmpty(t)) continue;
                sb.Append("<span class=\"ms-gc-tag\">").Append(Server.HtmlEncode(CultureInfo.InvariantCulture.TextInfo.ToTitleCase(t.ToLowerInvariant()))).Append("</span>");
                n++;
            }
            return sb.ToString();
        }

        public string FormatGridRating(object avg, object count)
        {
            int c = count != null && count != DBNull.Value ? Convert.ToInt32(count) : 0;
            if (c <= 0)
                return "<div class=\"ms-gc-rating ms-gc-rating-empty\"><i class=\"fas fa-star\"></i><span>No reviews</span><em>—</em></div>";
            decimal a = avg != null && avg != DBNull.Value ? Convert.ToDecimal(avg) : 0m;
            return "<div class=\"ms-gc-rating\"><i class=\"fas fa-star\"></i><strong>" + a.ToString("0.0", CultureInfo.InvariantCulture) + "</strong><span>(" + c + " review" + (c == 1 ? "" : "s") + ")</span></div>";
        }

        public string FormatGridAddress(object address, object city, object state, object zip)
        {
            var parts = new System.Collections.Generic.List<string>();
            if (address != null && address != DBNull.Value && !string.IsNullOrWhiteSpace(address.ToString()))
                parts.Add(address.ToString().Trim());
            if (city != null && city != DBNull.Value && !string.IsNullOrWhiteSpace(city.ToString()))
                parts.Add(city.ToString().Trim());
            if (state != null && state != DBNull.Value && !string.IsNullOrWhiteSpace(state.ToString()))
                parts.Add(state.ToString().Trim());
            if (zip != null && zip != DBNull.Value && !string.IsNullOrWhiteSpace(zip.ToString()))
                parts.Add(zip.ToString().Trim());
            if (parts.Count == 0) return "Address not set";
            return Server.HtmlEncode(string.Join(", ", parts));
        }

        public string FormatGridPhone(object phone)
        {
            if (phone == null || phone == DBNull.Value) return "Phone not set";
            string p = phone.ToString().Trim();
            if (string.IsNullOrEmpty(p) || p == "0") return "Phone not set";
            return Server.HtmlEncode(p);
        }

        public string GetPrimaryCategory(object cats)
        {
            if (cats == null || cats == DBNull.Value) return "General";
            string raw = cats.ToString().Trim();
            if (string.IsNullOrEmpty(raw)) return "General";
            string first = raw.Split(new[] { ',', ';' }, StringSplitOptions.RemoveEmptyEntries)[0].Trim();
            return string.IsNullOrEmpty(first) ? "General" : CultureInfo.InvariantCulture.TextInfo.ToTitleCase(first.ToLowerInvariant());
        }

        public int GetProgressPercent(object revenue, object sells)
        {
            decimal r = revenue != null && revenue != DBNull.Value ? Convert.ToDecimal(revenue) : 0m;
            int s = sells != null && sells != DBNull.Value ? Convert.ToInt32(sells) : 0;
            if (r <= 0 && s <= 0) return 8;
            decimal score = (r / 500m) + (s * 2m);
            int pct = (int)Math.Min(100m, Math.Max(12m, score));
            return pct;
        }

        public bool ShowGridDisabledPill(object isActive, object deletionStatus)
        {
            if (!CanToggleAccess(isActive, deletionStatus)) return true;
            return isActive == null || isActive == DBNull.Value || !Convert.ToBoolean(isActive);
        }

        public bool ShowGridPowerButton(object isActive, object deletionStatus)
        {
            if (!CanToggleAccess(isActive, deletionStatus)) return false;
            return isActive != null && isActive != DBNull.Value && Convert.ToBoolean(isActive);
        }

        private static string NormalizeMediaPath(string path)
        {
            if (string.IsNullOrWhiteSpace(path)) return "";
            path = path.Trim().Replace("\\", "/");
            if (path.StartsWith("~/")) return path;
            if (path.StartsWith("/")) return "~" + path;
            return "~/" + path.TrimStart('/');
        }
    }
}
