using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace ecommerce_mlm.admin
{
    public partial class ViewSellerKyc : System.Web.UI.Page
    {
        string strcon = ConfigurationManager.ConnectionStrings["MlmDb"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Request.QueryString["id"] == null)
            {
                Response.Redirect("ManageSellers.aspx");
                return;
            }

            if (!IsPostBack)
            {
                int sellerId = Convert.ToInt32(Request.QueryString["id"]);
                LoadKycAudit(sellerId);

                if (Request.QueryString["op"] == "app")
                {
                    ShowResult("✅ Success: Merchant actions authorized and synchronized!", false);
                }
                else if (Request.QueryString["op"] == "rej")
                {
                    ShowResult("ℹ️ Notice: Request / Modifications rejected or discarded successfully.", true);
                }
            }
        }

        private void LoadKycAudit(int sid)
        {
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    string sql = "SELECT * FROM SellerUsers WHERE Id = @sid";
                    using (SqlCommand cmd = new SqlCommand(sql, con))
                    {
                        cmd.Parameters.AddWithValue("@sid", sid);
                        SqlDataAdapter da = new SqlDataAdapter(cmd);
                        DataTable dt = new DataTable();
                        da.Fill(dt);

                        if (dt.Rows.Count > 0)
                        {
                            DataRow r = dt.Rows[0];
                            string editRequestStatus = r["EditRequestStatus"] != DBNull.Value ? r["EditRequestStatus"].ToString() : "";

                            // Fetch Draft Data if the user submitted an Edit Re-audit!
                            DataRow rDraft = null;
                            if (editRequestStatus.Equals("DraftSubmitted", StringComparison.OrdinalIgnoreCase))
                            {
                                string draftSql = "SELECT * FROM SellerKycDrafts WHERE SellerId = @sid";
                                using (SqlCommand cmdDraft = new SqlCommand(draftSql, con))
                                {
                                    cmdDraft.Parameters.AddWithValue("@sid", sid);
                                    SqlDataAdapter daDraft = new SqlDataAdapter(cmdDraft);
                                    DataTable dtDraft = new DataTable();
                                    daDraft.Fill(dtDraft);
                                    if (dtDraft.Rows.Count > 0)
                                    {
                                        rDraft = dtDraft.Rows[0];
                                    }
                                }
                            }

                            // 1. Identity Block (Comparison Active)
                            litStoreName.Text = RenderDiff(r["StoreName"], rDraft != null ? rDraft["StoreName"] : DBNull.Value);
                            litGst.Text = RenderDiff(r["GstNumber"], rDraft != null ? rDraft["GstNumber"] : DBNull.Value);
                            litPan.Text = RenderDiff(r["PanNumber"], rDraft != null ? rDraft["PanNumber"] : DBNull.Value);
                            litAadhar.Text = RenderDiff(r["AadharNumber"], rDraft != null ? rDraft["AadharNumber"] : DBNull.Value);

                            // 2. Bank Block (Comparison Active)
                            litBankName.Text = RenderDiff(r["BankName"], rDraft != null ? rDraft["BankName"] : DBNull.Value);
                            litBankHolder.Text = RenderDiff(r["BankHolderName"], rDraft != null ? rDraft["BankHolderName"] : DBNull.Value);
                            litBankAccNo.Text = RenderDiff(r["BankAccountNumber"], rDraft != null ? rDraft["BankAccountNumber"] : DBNull.Value);
                            litBankIfsc.Text = RenderDiff(r["BankIFSC"], rDraft != null ? rDraft["BankIFSC"] : DBNull.Value);

                            // 3. Address Block (Comparison Active)
                            litAddress.Text = RenderDiff(r["Address"], rDraft != null ? rDraft["Address"] : DBNull.Value);
                            litCity.Text = RenderDiff(r["City"], rDraft != null ? rDraft["City"] : DBNull.Value);
                            litState.Text = RenderDiff(r["State"], rDraft != null ? rDraft["State"] : DBNull.Value);
                            litPincode.Text = RenderDiff(r["Pincode"], rDraft != null ? rDraft["Pincode"] : DBNull.Value);

                            // 4. Dynamic Status & Adapt Button Verdict System
                            string status = r["KycStatus"] != DBNull.Value ? r["KycStatus"].ToString() : "Draft";
                            spnStatus.InnerText = "Audit State: " + status;

                            // Adaptive UI based on Compliance Queue Sub-State
                            if (editRequestStatus.Equals("PendingApproval", StringComparison.OrdinalIgnoreCase))
                            {
                                spnStatus.InnerText = "Access Requested: Edit KYC";
                                spnStatus.Attributes["class"] = "badge";
                                spnStatus.Style["background"] = "#3b82f6";
                                spnStatus.Style["color"] = "#fff";

                                btnApprove.Text = "✓ Grant Edit Right";
                                btnApprove.Style["background"] = "#3b82f6";
                                btnApprove.OnClientClick = "return confirm('Authorize this merchant to unlock and edit their KYC documents?');";

                                btnReject.Text = "✗ Deny Request";
                                btnReject.OnClientClick = "return confirm('Refuse edit request and keep the current locked KYC intact?');";
                            }
                            else if (editRequestStatus.Equals("DraftSubmitted", StringComparison.OrdinalIgnoreCase))
                            {
                                spnStatus.InnerText = "Audit State: Re-evaluation";
                                spnStatus.Attributes["class"] = "badge";
                                spnStatus.Style["background"] = "#d97706";
                                spnStatus.Style["color"] = "#fff";

                                btnApprove.Text = "✓ Approve Modifications";
                                btnApprove.Style["background"] = "#22c55e";
                                btnApprove.OnClientClick = "return confirm('Merge these proposed modifications and overwrite the active KYC values?');";

                                btnReject.Text = "✗ Reject & Discard Edits";
                                btnReject.OnClientClick = "return confirm('Discard the pending modifications? Active approved details will remain unchanged.');";
                            }
                            else if (status.Equals("Approved", StringComparison.OrdinalIgnoreCase))
                            {
                                spnStatus.Attributes["class"] = "badge badge-success";
                                btnApprove.Enabled = false;
                                btnApprove.Text = "✓ Already Approved";
                                btnApprove.Style["background"] = "#94a3b8";
                            }
                            else if (status.Equals("Rejected", StringComparison.OrdinalIgnoreCase))
                            {
                                spnStatus.Attributes["class"] = "badge badge-danger";
                            }
                            else if (status.Equals("Pending", StringComparison.OrdinalIgnoreCase))
                            {
                                spnStatus.Attributes["class"] = "badge badge-warning";
                            }
                            else
                            {
                                spnStatus.Attributes["class"] = "badge";
                                spnStatus.Style["background"] = "#64748b";
                                spnStatus.Style["color"] = "#fff";
                            }

                            // 5. Set Download Documents Sidebar & Inline Lightbox Popups (Adaptive Diff)
                            object panActive = r["KycPanDocPath"];
                            object panDraft = rDraft != null ? rDraft["KycPanDocPath"] : DBNull.Value;
                            object aadharActive = r["KycAadharDocPath"];
                            object aadharDraft = rDraft != null ? rDraft["KycAadharDocPath"] : DBNull.Value;
                            object gstActive = r["KycGstDocPath"];
                            object gstDraft = rDraft != null ? rDraft["KycGstDocPath"] : DBNull.Value;

                            SetupDocumentLinkWithDiff(hlPan, panActive, panDraft, "View PAN Scan");
                            SetupDocumentLinkWithDiff(hlAadhar, aadharActive, aadharDraft, "View Aadhaar Scan");
                            SetupDocumentLinkWithDiff(hlGst, gstActive, gstDraft, "View GST Scan");

                            SetupPopupLinkWithDiff(lnkPopPan, panActive, panDraft, "View Card");
                            SetupPopupLinkWithDiff(lnkPopAadhar, aadharActive, aadharDraft, "View Card");
                            SetupPopupLinkWithDiff(lnkPopGst, gstActive, gstDraft, "View Certificate");
                        }
                        else
                        {
                            Response.Redirect("ManageSellers.aspx");
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ShowResult("Read fault: " + ex.Message, true);
            }
        }

        private string RenderDiff(object active, object draft)
        {
            string sActive = active != DBNull.Value ? active.ToString().Trim() : "";
            string sDraft = draft != DBNull.Value ? draft.ToString().Trim() : "";

            // Handle fallback for Standard view where draft is NULL
            if (draft == DBNull.Value)
            {
                return string.IsNullOrEmpty(sActive) ? "Not Specified" : sActive;
            }

            // If both are identical, return standard
            if (sActive.Equals(sDraft, StringComparison.OrdinalIgnoreCase))
            {
                return string.IsNullOrEmpty(sActive) ? "Not Specified" : sActive;
            }
            else
            {
                // Highlight Diff!
                return string.Format(
                    @"<span style='text-decoration: line-through; color: #94a3b8; margin-right: 8px;'>{0}</span>
                      <span class='badge' style='background: #fef3c7; color: #b45309; border: 1px solid #fde68a; font-size: 0.7rem; padding: 2px 6px; border-radius: 4px; margin-right: 8px; font-weight: 700;'><i class='fas fa-pen-to-square'></i> MODIFIED</span>
                      <span style='color: #b45309; font-weight: 800; background: #fffbeb; padding: 2px 4px; border-radius: 4px;'>{1}</span>",
                    string.IsNullOrEmpty(sActive) ? "[Empty]" : sActive,
                    string.IsNullOrEmpty(sDraft) ? "[Cleared]" : sDraft
                );
            }
        }

        private void SetupPopupLinkWithDiff(System.Web.UI.HtmlControls.HtmlAnchor lnk, object activePath, object draftPath, string baseLabel)
        {
            string pathStr = (draftPath != DBNull.Value && !string.IsNullOrEmpty(draftPath.ToString())) 
                             ? draftPath.ToString() 
                             : (activePath != DBNull.Value ? activePath.ToString() : "");

            if (!string.IsNullOrEmpty(pathStr))
            {
                string clean = pathStr.StartsWith("~") ? pathStr.Substring(1) : pathStr;
                if (!clean.StartsWith("/")) clean = "/" + clean;

                lnk.Attributes["data-docurl"] = clean;
                lnk.Visible = true;

                // Visual modification marker if paths differ
                if (draftPath != DBNull.Value && activePath != DBNull.Value && !activePath.ToString().Equals(draftPath.ToString(), StringComparison.OrdinalIgnoreCase))
                {
                    lnk.InnerHtml = string.Format("<i class='fas fa-eye'></i> {0} <span class='badge' style='background:#fef3c7; color:#b45309; border:1px solid #fde68a; padding:1px 4px; font-size:0.6rem; margin-left:4px;'>NEW</span>", baseLabel);
                    lnk.Style["border-color"] = "#fbbf24";
                    lnk.Style["background"] = "#fffbeb";
                }
            }
            else
            {
                lnk.Visible = false;
            }
        }

        private void SetupDocumentLinkWithDiff(HyperLink hl, object activePath, object draftPath, string baseLabel)
        {
            string pathStr = (draftPath != DBNull.Value && !string.IsNullOrEmpty(draftPath.ToString())) 
                             ? draftPath.ToString() 
                             : (activePath != DBNull.Value ? activePath.ToString() : "");

            if (!string.IsNullOrEmpty(pathStr))
            {
                string clean = pathStr.StartsWith("~") ? pathStr.Substring(1) : pathStr;
                if (!clean.StartsWith("/")) clean = "/" + clean;

                hl.NavigateUrl = clean;
                
                // If file is modified, style the sidebar link!
                if (draftPath != DBNull.Value && activePath != DBNull.Value && !activePath.ToString().Equals(draftPath.ToString(), StringComparison.OrdinalIgnoreCase))
                {
                    hl.Text = string.Format("<i class='fas fa-file-pdf u-mr-8' style='color:#fbbf24;'></i> {0} (NEW VERSION)", baseLabel);
                    hl.CssClass = "audit-asset-link";
                    hl.Style["border-color"] = "#fbbf24";
                    hl.Style["background"] = "#fffbeb";
                }
                else
                {
                    hl.Text = string.Format("<i class='fas fa-file-pdf u-mr-8'></i> {0}", baseLabel);
                    hl.CssClass = "audit-asset-link";
                }
                
                hl.Enabled = true;
            }
            else
            {
                hl.NavigateUrl = "";
                hl.Text = "<i class='fas fa-times-circle u-mr-8' style='color:#94a3b8;'></i> No Document Available";
                hl.CssClass = "audit-asset-link audit-asset-link-disabled";
                hl.Attributes.Remove("target");
            }
        }

        protected void btnApprove_Click(object sender, EventArgs e)
        {
            int sid = Convert.ToInt32(Request.QueryString["id"]);
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    // Get the EditRequestStatus from DB
                    string esQuery = "SELECT EditRequestStatus FROM SellerUsers WHERE Id = @sid";
                    string editStatus = "";
                    using (SqlCommand cmd = new SqlCommand(esQuery, con))
                    {
                        cmd.Parameters.AddWithValue("@sid", sid);
                        object val = cmd.ExecuteScalar();
                        editStatus = val != DBNull.Value ? val.ToString() : "";
                    }

                    if (editStatus.Equals("PendingApproval", StringComparison.OrdinalIgnoreCase))
                    {
                        // CASE A: GRANT EDIT RIGHTS
                        string sql = "UPDATE SellerUsers SET EditRequestStatus = 'ApprovedToEdit', UpdatedAt = GETDATE() WHERE Id = @sid";
                        using (SqlCommand cmd = new SqlCommand(sql, con))
                        {
                            cmd.Parameters.AddWithValue("@sid", sid);
                            cmd.ExecuteNonQuery();
                        }
                    }
                    else if (editStatus.Equals("DraftSubmitted", StringComparison.OrdinalIgnoreCase))
                    {
                        // CASE B: TRANSACTIONAL MERGE OF DRAFT DATA INTO LIVE PROFILE!
                        string sqlMerge = @"
                            UPDATE SellerUsers SET 
                                StoreName = COALESCE(d.StoreName, u.StoreName),
                                GstNumber = COALESCE(d.GstNumber, u.GstNumber),
                                PanNumber = COALESCE(d.PanNumber, u.PanNumber),
                                AadharNumber = COALESCE(d.AadharNumber, u.AadharNumber),
                                BankName = COALESCE(d.BankName, u.BankName),
                                BankHolderName = COALESCE(d.BankHolderName, u.BankHolderName),
                                BankAccountNumber = COALESCE(d.BankAccountNumber, u.BankAccountNumber),
                                BankIFSC = COALESCE(d.BankIFSC, u.BankIFSC),
                                Address = COALESCE(d.Address, u.Address),
                                City = COALESCE(d.City, u.City),
                                State = COALESCE(d.State, u.State),
                                Pincode = COALESCE(d.Pincode, u.Pincode),
                                KycPanDocPath = COALESCE(d.KycPanDocPath, u.KycPanDocPath),
                                KycAadharDocPath = COALESCE(d.KycAadharDocPath, u.KycAadharDocPath),
                                KycGstDocPath = COALESCE(d.KycGstDocPath, u.KycGstDocPath),
                                EditRequestStatus = 'None', 
                                KycStatus = 'Approved', 
                                UpdatedAt = GETDATE()
                            FROM SellerUsers u
                            INNER JOIN SellerKycDrafts d ON u.Id = d.SellerId
                            WHERE u.Id = @sid;

                            DELETE FROM SellerKycDrafts WHERE SellerId = @sid;
                        ";
                        using (SqlCommand cmd = new SqlCommand(sqlMerge, con))
                        {
                            cmd.Parameters.AddWithValue("@sid", sid);
                            cmd.ExecuteNonQuery();
                        }
                    }
                    else
                    {
                        // CASE C: STANDARD ONBOARDING KYC VERIFICATION
                        string sql = "UPDATE SellerUsers SET KycStatus = 'Approved', AdminApproved = 1, IsActive = 1, UpdatedAt = GETDATE() WHERE Id = @sid";
                        using (SqlCommand cmd = new SqlCommand(sql, con))
                        {
                            cmd.Parameters.AddWithValue("@sid", sid);
                            cmd.ExecuteNonQuery();
                        }
                    }
                }
                Response.Redirect("ViewSellerKyc.aspx?id=" + sid + "&op=app");
            }
            catch (Exception ex)
            {
                ShowResult("Audit Pipeline Merge Fault: " + ex.Message, true);
            }
        }

        protected void btnReject_Click(object sender, EventArgs e)
        {
            int sid = Convert.ToInt32(Request.QueryString["id"]);
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    string esQuery = "SELECT EditRequestStatus FROM SellerUsers WHERE Id = @sid";
                    string editStatus = "";
                    using (SqlCommand cmd = new SqlCommand(esQuery, con))
                    {
                        cmd.Parameters.AddWithValue("@sid", sid);
                        object val = cmd.ExecuteScalar();
                        editStatus = val != DBNull.Value ? val.ToString() : "";
                    }

                    if (editStatus.Equals("PendingApproval", StringComparison.OrdinalIgnoreCase))
                    {
                        // CASE A: DENY EDIT ACCESS
                        string sql = "UPDATE SellerUsers SET EditRequestStatus = 'None', UpdatedAt = GETDATE() WHERE Id = @sid";
                        using (SqlCommand cmd = new SqlCommand(sql, con))
                        {
                            cmd.Parameters.AddWithValue("@sid", sid);
                            cmd.ExecuteNonQuery();
                        }
                    }
                    else if (editStatus.Equals("DraftSubmitted", StringComparison.OrdinalIgnoreCase))
                    {
                        // CASE B: DISCARD PROPOSED EDITS & RESTORE LOCK
                        string sql = @"
                            DELETE FROM SellerKycDrafts WHERE SellerId = @sid;
                            UPDATE SellerUsers SET EditRequestStatus = 'None', UpdatedAt = GETDATE() WHERE Id = @sid;
                        ";
                        using (SqlCommand cmd = new SqlCommand(sql, con))
                        {
                            cmd.Parameters.AddWithValue("@sid", sid);
                            cmd.ExecuteNonQuery();
                        }
                    }
                    else
                    {
                        // CASE C: STANDARD INITIAL AUDIT REJECTION
                        string sql = "UPDATE SellerUsers SET KycStatus = 'Rejected', IsKycSubmitted = 0, AdminApproved = 0, UpdatedAt = GETDATE() WHERE Id = @sid";
                        using (SqlCommand cmd = new SqlCommand(sql, con))
                        {
                            cmd.Parameters.AddWithValue("@sid", sid);
                            cmd.ExecuteNonQuery();
                        }
                    }
                }
                Response.Redirect("ViewSellerKyc.aspx?id=" + sid + "&op=rej");
            }
            catch (Exception ex)
            {
                ShowResult("Audit Pipeline Dismissal Fault: " + ex.Message, true);
            }
        }

        private void ShowResult(string msg, bool isErr)
        {
            lblStatus.Text = msg;
            lblStatus.CssClass = isErr ? "alert-danger d-block u-mb-20" : "alert-success d-block u-mb-20";
            lblStatus.Visible = true;
        }
    }
}
