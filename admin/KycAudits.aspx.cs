using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Text;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ecommerce_mlm.admin
{
    public partial class KycAudits : Page
    {
        string strcon = ConfigurationManager.ConnectionStrings["MlmDb"].ConnectionString;
        int _fkPage = 1;
        int _fkSize = 25;
        int _fkTotal;

        private const string SellerBaseFilter =
            " ISNULL(DeletionStatus, 'None') NOT IN ('Approved') AND Id > 1" +
            " AND ISNULL(FullName, '') NOT LIKE '%default%' AND ISNULL(StoreName, '') NOT LIKE '%default%'";

        private const string PendingSellerFilter =
            @"(
                (ISNULL(EmailVerified, 0) = 0 AND ISNULL(IsKycSubmitted, 0) = 0 AND ISNULL(KycStatus, 'Draft') NOT IN ('Approved'))
                OR (ISNULL(EmailVerified, 0) = 1 AND ISNULL(IsKycSubmitted, 0) = 0 AND ISNULL(KycStatus, 'Draft') IN ('Draft', '') AND ISNULL(AdminApproved, 0) = 0)
                OR (KycStatus = 'Pending' AND ISNULL(IsKycSubmitted, 0) = 1)
                OR (EditRequestStatus IN ('PendingApproval', 'DraftSubmitted'))
                OR (KycStatus = 'Rejected')
            )";

        private const string FinalKycFilter =
            @"ISNULL(IsKycSubmitted, 0) = 1
              AND ISNULL(KycStatus, '') IN ('Pending', 'Approved', 'Rejected')
              AND ISNULL(EditRequestStatus, 'None') NOT IN ('PendingApproval', 'DraftSubmitted')";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                ShowFlash();
                int.TryParse(Request.QueryString["fksize"], out _fkSize);
                if (_fkSize < 5) _fkSize = 25;
                if (ddlFkycPageSize != null) ddlFkycPageSize.SelectedValue = _fkSize.ToString();

                DataTable pending = LoadPendingKyc();
                LoadKpis(pending);
            }
            else
            {
                int.TryParse(Request.QueryString["fksize"], out _fkSize);
                if (_fkSize < 5) _fkSize = 25;
            }

            LoadFinalKyc();
        }

        protected void ddlFkycPageSize_SelectedIndexChanged(object sender, EventArgs e)
        {
            int size = 25;
            int.TryParse(ddlFkycPageSize.SelectedValue, out size);
            if (size < 5) size = 25;
            Response.Redirect("KycAudits.aspx?fkpage=1&fksize=" + size);
        }

        protected void rptFinalKyc_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            string id = e.CommandArgument.ToString();
            if (e.CommandName == "ApproveFinal")
            {
                ApproveFinalKyc(id);
                Response.Redirect(BuildFkUrl(GetFkPage(), "fk_approved"));
            }
            else if (e.CommandName == "RejectFinal")
            {
                RejectFinalKyc(id);
                Response.Redirect(BuildFkUrl(GetFkPage(), "fk_rejected"));
            }
        }

        private void ApproveFinalKyc(string sellerId)
        {
            using (SqlConnection con = new SqlConnection(strcon))
            {
                con.Open();
                using (SqlCommand cmd = new SqlCommand(
                    "UPDATE SellerUsers SET KycStatus = 'Approved', AdminApproved = 1, IsActive = 1, UpdatedAt = GETDATE() WHERE Id = @id AND KycStatus = 'Pending'", con))
                {
                    cmd.Parameters.AddWithValue("@id", sellerId);
                    cmd.ExecuteNonQuery();
                }
            }
        }

        private void RejectFinalKyc(string sellerId)
        {
            using (SqlConnection con = new SqlConnection(strcon))
            {
                con.Open();
                using (SqlCommand cmd = new SqlCommand(
                    "UPDATE SellerUsers SET KycStatus = 'Rejected', IsKycSubmitted = 0, AdminApproved = 0, IsActive = 0, UpdatedAt = GETDATE() WHERE Id = @id", con))
                {
                    cmd.Parameters.AddWithValue("@id", sellerId);
                    cmd.ExecuteNonQuery();
                }
            }
        }

        private void ShowFlash()
        {
            string msg = Request.QueryString["msg"];
            if (string.IsNullOrEmpty(msg)) return;

            pnlFlash.Visible = true;
            if (msg == "fk_approved")
            {
                pnlFlash.CssClass = "ms-flash ms-flash-success";
                icoFlash.Attributes["class"] = "fas fa-check-circle";
                litFlash.Text = "Final KYC approved. Seller can now list products.";
            }
            else if (msg == "fk_rejected")
            {
                pnlFlash.CssClass = "ms-flash ms-flash-warn";
                icoFlash.Attributes["class"] = "fas fa-exclamation-circle";
                litFlash.Text = "Final KYC rejected. Seller must resubmit documents.";
            }
        }

        private string BuildFkUrl(int page, string msg)
        {
            string url = "KycAudits.aspx?fkpage=" + page + "&fksize=" + GetFkSize();
            if (!string.IsNullOrEmpty(msg)) url += "&msg=" + Server.UrlEncode(msg);
            return url;
        }

        private int GetFkPage()
        {
            int page = 1;
            int.TryParse(Request.QueryString["fkpage"], out page);
            return page < 1 ? 1 : page;
        }

        private int GetFkSize()
        {
            int size = 25;
            int.TryParse(Request.QueryString["fksize"], out size);
            return size < 5 ? 25 : size;
        }

        private void LoadKpis(DataTable pendingRows)
        {
            int pendingReg = 0;
            int regApproved = 0;
            int regRejected = 0;
            int pendingFinalKyc = 0;
            int pendingEdit = 0;

            if (pendingRows != null)
            {
                foreach (DataRow row in pendingRows.Rows)
                {
                    string category = GetQueueCategory(
                        row["EmailVerified"], row["IsKycSubmitted"], row["KycStatus"], row["EditRequestStatus"]);

                    if (category == "pending_reg") pendingReg++;
                    else if (category == "awaiting_kyc") regApproved++;
                    else if (category == "rejected") regRejected++;
                    else if (category == "final_kyc") pendingFinalKyc++;
                    else if (category == "edit_access" || category == "reaudit") pendingEdit++;
                }
            }

            litPendingReg.Text = pendingReg.ToString("N0");
            litRegApproved.Text = regApproved.ToString("N0");
            litRegRejected.Text = regRejected.ToString("N0");
            litPendingFinalKyc.Text = pendingFinalKyc.ToString("N0");
            litPendingEdit.Text = pendingEdit.ToString("N0");

            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    litFinalApproved.Text = Scalar(con,
                        "SELECT COUNT(*) FROM SellerUsers WHERE KycStatus = 'Approved' AND " + SellerBaseFilter).ToString("N0");
                }
            }
            catch
            {
                litFinalApproved.Text = "0";
            }
        }

        private static string GetQueueCategory(object emailVerified, object isKycSubmitted, object kycStatus, object editRequestStatus)
        {
            string ks = kycStatus != DBNull.Value ? kycStatus.ToString().Trim() : "";
            string es = editRequestStatus != DBNull.Value ? editRequestStatus.ToString().Trim() : "None";
            bool verified = emailVerified != null && emailVerified != DBNull.Value && Convert.ToBoolean(emailVerified);
            bool submitted = isKycSubmitted != null && isKycSubmitted != DBNull.Value && Convert.ToBoolean(isKycSubmitted);

            if (es.Equals("PendingApproval", StringComparison.OrdinalIgnoreCase)) return "edit_access";
            if (es.Equals("DraftSubmitted", StringComparison.OrdinalIgnoreCase)) return "reaudit";
            if (ks.Equals("Pending", StringComparison.OrdinalIgnoreCase)) return "final_kyc";
            if (ks.Equals("Rejected", StringComparison.OrdinalIgnoreCase)) return "rejected";
            if (!verified) return "pending_reg";
            if (!submitted) return "awaiting_kyc";

            return "other";
        }

        private static int Scalar(SqlConnection con, string sql)
        {
            using (SqlCommand cmd = new SqlCommand(sql, con))
            {
                object o = cmd.ExecuteScalar();
                if (o == null || o == DBNull.Value) return 0;
                return Convert.ToInt32(o);
            }
        }

        private DataTable LoadPendingKyc()
        {
            DataTable dt = new DataTable();
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    string query = @"SELECT * FROM SellerUsers
                        WHERE " + PendingSellerFilter + " AND " + SellerBaseFilter + @"
                        ORDER BY
                            CASE
                                WHEN EditRequestStatus = 'DraftSubmitted' THEN 1
                                WHEN KycStatus = 'Pending' THEN 2
                                WHEN EditRequestStatus = 'PendingApproval' THEN 3
                                WHEN ISNULL(EmailVerified, 0) = 0 THEN 4
                                WHEN ISNULL(IsKycSubmitted, 0) = 0 THEN 5
                                WHEN KycStatus = 'Rejected' THEN 6
                                ELSE 7
                            END,
                            UpdatedAt ASC";

                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        new SqlDataAdapter(cmd).Fill(dt);
                    }
                }

                int count = dt.Rows.Count;
                litTableHint.Text = "All pending registrations, KYC reviews, edit requests, and rejected applications.";

                if (count > 0)
                {
                    rptKyc.DataSource = dt;
                    rptKyc.DataBind();
                    phEmptyState.Visible = false;
                }
                else
                {
                    rptKyc.DataSource = null;
                    rptKyc.DataBind();
                    phEmptyState.Visible = true;
                }

                litShowing.Text = count == 0
                    ? "Showing 0 pending"
                    : "Showing " + count + " of " + count + " in queue";
                lblQueueCount.Text = count + " in queue";
            }
            catch (Exception ex)
            {
                litShowing.Text = "Unable to load queue";
                lblQueueCount.Text = ex.Message;
            }

            return dt;
        }

        private void LoadFinalKyc()
        {
            _fkPage = GetFkPage();
            _fkSize = GetFkSize();

            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    _fkTotal = Scalar(con,
                        "SELECT COUNT(*) FROM SellerUsers WHERE " + FinalKycFilter + " AND " + SellerBaseFilter);

                    int totalPages = Math.Max(1, (int)Math.Ceiling(_fkTotal / (double)_fkSize));
                    if (_fkPage > totalPages) _fkPage = totalPages;

                    int offset = (_fkPage - 1) * _fkSize;
                    int fromRow = _fkTotal == 0 ? 0 : offset + 1;
                    int toRow = Math.Min(offset + _fkSize, _fkTotal);

                    string sql = @"SELECT * FROM SellerUsers
                        WHERE " + FinalKycFilter + " AND " + SellerBaseFilter + @"
                        ORDER BY
                            CASE WHEN KycStatus = 'Pending' THEN 0 WHEN KycStatus = 'Rejected' THEN 1 ELSE 2 END,
                            UpdatedAt DESC
                        OFFSET @off ROWS FETCH NEXT @size ROWS ONLY";

                    DataTable dt = new DataTable();
                    using (SqlCommand cmd = new SqlCommand(sql, con))
                    {
                        cmd.Parameters.AddWithValue("@off", offset);
                        cmd.Parameters.AddWithValue("@size", _fkSize);
                        new SqlDataAdapter(cmd).Fill(dt);
                    }

                    if (dt.Rows.Count > 0)
                    {
                        rptFinalKyc.DataSource = dt;
                        rptFinalKyc.DataBind();
                        phFinalKycEmpty.Visible = false;
                    }
                    else
                    {
                        rptFinalKyc.DataSource = null;
                        rptFinalKyc.DataBind();
                        phFinalKycEmpty.Visible = true;
                    }

                    litFkycShowing.Text = _fkTotal == 0
                        ? "Showing 0 of 0"
                        : "Showing " + fromRow + "-" + toRow + " of " + _fkTotal;
                    litFkycPageInfo.Text = "Page " + _fkPage + " of " + totalPages;
                    litFkycPager.Text = BuildFkPager(_fkPage, totalPages);
                }
            }
            catch (Exception ex)
            {
                litFkycShowing.Text = "Unable to load final KYC list";
                litFkycPageInfo.Text = ex.Message;
            }
        }

        private string BuildFkPager(int page, int totalPages)
        {
            if (totalPages <= 1) return "";

            var sb = new StringBuilder();
            string prev = page > 1 ? BuildFkUrl(page - 1, null) : null;
            string next = page < totalPages ? BuildFkUrl(page + 1, null) : null;

            sb.Append(prev != null
                ? "<a href=\"" + prev + "\" class=\"ms-page-btn\"><i class=\"fas fa-chevron-left\"></i></a>"
                : "<span class=\"ms-page-btn disabled\"><i class=\"fas fa-chevron-left\"></i></span>");

            int start = Math.Max(1, page - 2);
            int end = Math.Min(totalPages, page + 2);
            for (int i = start; i <= end; i++)
            {
                if (i == page)
                    sb.Append("<span class=\"ms-page-btn current\">").Append(i).Append("</span>");
                else
                    sb.Append("<a href=\"").Append(BuildFkUrl(i, null)).Append("\" class=\"ms-page-btn\">").Append(i).Append("</a>");
            }

            sb.Append(next != null
                ? "<a href=\"" + next + "\" class=\"ms-page-btn\"><i class=\"fas fa-chevron-right\"></i></a>"
                : "<span class=\"ms-page-btn disabled\"><i class=\"fas fa-chevron-right\"></i></span>");

            return sb.ToString();
        }

        public bool ShowFinalKycActions(object kycStatus, object editRequestStatus)
        {
            string ks = kycStatus != null && kycStatus != DBNull.Value ? kycStatus.ToString().Trim() : "";
            string es = editRequestStatus != null && editRequestStatus != DBNull.Value ? editRequestStatus.ToString().Trim() : "None";
            if (!es.Equals("None", StringComparison.OrdinalIgnoreCase)) return false;
            return ks.Equals("Pending", StringComparison.OrdinalIgnoreCase);
        }

        public string FormatBusinessProof(object storeName, object gst, object pan, object aadhar,
            object gstDoc, object panDoc, object aadharDoc)
        {
            string store = storeName != null && storeName != DBNull.Value ? storeName.ToString().Trim() : "";
            if (string.IsNullOrEmpty(store)) store = "Draft Profile";

            var sb = new StringBuilder();
            sb.Append("<div class=\"fkyc-line\"><span class=\"fkyc-k\">Business</span> · ").Append(HttpUtility.HtmlEncode(store)).Append("</div>");
            sb.Append(FormatProofDocLine("GST", gst, gstDoc));
            sb.Append(FormatProofDocLine("PAN", pan, panDoc));
            sb.Append(FormatProofDocLine("Aadhaar", aadhar, aadharDoc));
            return sb.ToString();
        }

        public string FormatBankAddress(object bankName, object holder, object accNo, object ifsc,
            object address, object city, object state, object pincode)
        {
            var sb = new StringBuilder();
            sb.Append(FormatLabelLine("Bank", bankName));
            sb.Append(FormatLabelLine("Holder", holder));
            sb.Append(FormatLabelLine("A/C", accNo));
            sb.Append(FormatLabelLine("IFSC", ifsc));

            string addr = BuildAddress(address, city, state, pincode);
            sb.Append("<div class=\"fkyc-line\"><span class=\"fkyc-k\">Address</span> ").Append(HttpUtility.HtmlEncode(addr)).Append("</div>");
            return sb.ToString();
        }

        public string FormatFinalStatus(object kycStatus, object editRequestStatus, object updatedAt, object createdAt)
        {
            string ks = kycStatus != null && kycStatus != DBNull.Value ? kycStatus.ToString().Trim() : "";
            string es = editRequestStatus != null && editRequestStatus != DBNull.Value ? editRequestStatus.ToString().Trim() : "None";

            var sb = new StringBuilder();
            sb.Append("<div class=\"fkyc-status-wrap\">").Append(FormatFinalStatusBadge(ks)).Append("</div>");

            DateTime submitted = GetSubmittedDate(updatedAt, createdAt, ks);
            sb.Append("<div class=\"fkyc-meta-line\">Submitted · ").Append(FormatDateTime(submitted)).Append("</div>");

            if (ks.Equals("Approved", StringComparison.OrdinalIgnoreCase) || ks.Equals("Rejected", StringComparison.OrdinalIgnoreCase))
            {
                sb.Append("<div class=\"fkyc-meta-line\">Reviewed · ").Append(FormatDateTime(GetDate(updatedAt))).Append("</div>");
                sb.Append("<div class=\"fkyc-meta-line\">By · Super Admin</div>");
            }
            else
            {
                sb.Append("<div class=\"fkyc-meta-line\">Reviewed · —</div>");
                sb.Append("<div class=\"fkyc-meta-line\">By · —</div>");
            }

            sb.Append("<div class=\"fkyc-meta-line\">Edit · ").Append(HttpUtility.HtmlEncode(es)).Append("</div>");
            return sb.ToString().Replace("<div class=", "<div class=").Replace("</div>", "</div>");
        }

        private string FormatFinalStatusBadge(string kycStatus)
        {
            if (kycStatus.Equals("Approved", StringComparison.OrdinalIgnoreCase))
                return "<span class=\"fkyc-status fkyc-status-approved\">Final Approved</span>";
            if (kycStatus.Equals("Rejected", StringComparison.OrdinalIgnoreCase))
                return "<span class=\"fkyc-status fkyc-status-rejected\">Final Rejected</span>";
            return "<span class=\"fkyc-status fkyc-status-pending\">Pending Review</span>";
        }

        private string FormatProofDocLine(string label, object number, object docPath)
        {
            string num = FormatValue(number);
            string doc = FormatDocViewLink(docPath);
            return "<div class=\"fkyc-line\"><span class=\"fkyc-k\">" + label + "</span> · " + num + "</div>" +
                   "<div class=\"fkyc-line fkyc-doc-line\"><span class=\"fkyc-k\">" + label + " doc</span> · " + doc + "</div>";
        }

        private string FormatLabelLine(string label, object value)
        {
            return "<div class=\"fkyc-line\"><span class=\"fkyc-k\">" + label + "</span> · " + FormatValue(value) + "</div>";
        }

        private string FormatValue(object value)
        {
            if (value == null || value == DBNull.Value) return "—";
            string s = value.ToString().Trim();
            return string.IsNullOrEmpty(s) ? "—" : HttpUtility.HtmlEncode(s);
        }

        private string FormatDocViewLink(object path)
        {
            string p = path != null && path != DBNull.Value ? path.ToString().Trim() : "";
            if (string.IsNullOrEmpty(p))
                return "<span class=\"fkyc-doc-missing\">—</span>";

            string url = ResolveUrl(NormalizeMediaPath(p));
            return "<a href=\"" + HttpUtility.HtmlAttributeEncode(url) + "\" target=\"_blank\" rel=\"noopener\" class=\"fkyc-doc-link\">View</a>";
        }

        private static string NormalizeMediaPath(string path)
        {
            if (string.IsNullOrWhiteSpace(path)) return "";
            path = path.Trim().Replace("\\", "/");
            if (path.StartsWith("~/")) return path;
            if (path.StartsWith("/")) return "~" + path;
            return "~/" + path.TrimStart('/');
        }

        private static string BuildAddress(object address, object city, object state, object pincode)
        {
            string a = address != DBNull.Value ? address.ToString().Trim() : "";
            string c = city != DBNull.Value ? city.ToString().Trim() : "";
            string st = state != DBNull.Value ? state.ToString().Trim() : "";
            string p = pincode != DBNull.Value ? pincode.ToString().Trim() : "";

            var parts = new System.Collections.Generic.List<string>();
            if (!string.IsNullOrEmpty(a)) parts.Add(a);
            string cs = (c + " " + st).Trim();
            if (!string.IsNullOrEmpty(cs)) parts.Add(cs);
            if (!string.IsNullOrEmpty(p)) parts.Add("— " + p);

            if (parts.Count == 0) return "—";
            return string.Join(", ", parts.ToArray());
        }

        private static DateTime GetSubmittedDate(object updatedAt, object createdAt, string kycStatus)
        {
            if (kycStatus.Equals("Pending", StringComparison.OrdinalIgnoreCase))
                return GetDate(updatedAt);
            return GetDate(createdAt);
        }

        private static DateTime GetDate(object value)
        {
            if (value == null || value == DBNull.Value) return DateTime.MinValue;
            DateTime d;
            if (DateTime.TryParse(value.ToString(), out d)) return d;
            return DateTime.MinValue;
        }

        private static string FormatDateTime(DateTime dt)
        {
            if (dt == DateTime.MinValue) return "—";
            return dt.ToString("dd MMM yyyy · hh:mm tt", CultureInfo.InvariantCulture);
        }

        public string GetInitials(object fullName)
        {
            if (fullName == null || fullName == DBNull.Value) return "??";
            string name = fullName.ToString().Trim();
            if (string.IsNullOrEmpty(name)) return "??";
            string[] parts = name.Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
            if (parts.Length >= 2)
                return (parts[0].Substring(0, 1) + parts[1].Substring(0, 1)).ToUpper();
            return name.Substring(0, Math.Min(2, name.Length)).ToUpper();
        }

        public string FormatGst(object gst)
        {
            if (gst == null || gst == DBNull.Value) return "None";
            string g = gst.ToString().Trim();
            return string.IsNullOrEmpty(g) ? "None" : g;
        }

        public string FormatPhone(object phone)
        {
            if (phone == null || phone == DBNull.Value) return "—";
            string p = phone.ToString().Trim();
            if (string.IsNullOrEmpty(p) || p == "0") return "—";
            return p;
        }

        protected string GetQueueBadge(object emailVerified, object isKycSubmitted, object kycStatus, object editRequestStatus)
        {
            switch (GetQueueCategory(emailVerified, isKycSubmitted, kycStatus, editRequestStatus))
            {
                case "edit_access":
                    return "<span class=\"ms-queue-badge ms-queue-badge-blue\"><i class=\"fas fa-lock-open\"></i> Edit access req</span>";
                case "reaudit":
                    return "<span class=\"ms-queue-badge ms-queue-badge-amber\"><i class=\"fas fa-pen-to-square\"></i> Re-audit pending</span>";
                case "final_kyc":
                    return "<span class=\"ms-queue-badge ms-queue-badge-red\"><i class=\"fas fa-clock\"></i> Final KYC review</span>";
                case "rejected":
                    return "<span class=\"ms-queue-badge ms-queue-badge-gray\"><i class=\"fas fa-times-circle\"></i> Reg. rejected</span>";
                case "pending_reg":
                    return "<span class=\"ms-queue-badge ms-queue-badge-orange\"><i class=\"fas fa-envelope\"></i> Pending registration</span>";
                case "awaiting_kyc":
                    return "<span class=\"ms-queue-badge ms-queue-badge-green\"><i class=\"fas fa-file-alt\"></i> Awaiting KYC submit</span>";
                default:
                    return "<span class=\"ms-queue-badge ms-queue-badge-gray\">Pending</span>";
            }
        }
    }
}
