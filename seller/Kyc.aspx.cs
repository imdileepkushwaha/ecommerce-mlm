using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace EcommerceWebsite
{
    public partial class SellerKyc : System.Web.UI.Page
    {
        string strcon = ConfigurationManager.ConnectionStrings["MlmDb"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["SellerId"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            int sellerId = Convert.ToInt32(Session["SellerId"]);

            if (!IsPostBack)
            {
                lblGlobalMsg.Visible = false;
                
                // Preset ViewState to prevent null errors in markup evaluation
                ViewState["IsKycSubmitted"] = false;
                ViewState["KycStatus"] = "Draft";

                LoadKycData(sellerId);

                if (Request.QueryString["status"] == "success")
                {
                    ShowMsg("🎉 KYC Portfolio locked and submitted for review!", false);
                }
                else if (Request.QueryString["status"] == "req_success")
                {
                    ShowMsg("⚡ Formal KYC Edit Request submitted to Super Admin successfully!", false);
                }

            }
        }

        private void LoadKycData(int sid)
        {
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    string query = "SELECT * FROM SellerUsers WHERE Id = @sid";
                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        cmd.Parameters.AddWithValue("@sid", sid);
                        SqlDataAdapter da = new SqlDataAdapter(cmd);
                        DataTable dt = new DataTable();
                        da.Fill(dt);

                        if (dt.Rows.Count > 0)
                        {
                            DataRow row = dt.Rows[0];

                            // A. Load Data Textbox Values
                            txtStoreName.Text = row["StoreName"] != DBNull.Value ? row["StoreName"].ToString() : "";
                            txtGst.Text = row["GstNumber"] != DBNull.Value ? row["GstNumber"].ToString() : "";
                            txtPan.Text = row["PanNumber"] != DBNull.Value ? row["PanNumber"].ToString() : "";
                            txtAadhar.Text = row["AadharNumber"] != DBNull.Value ? row["AadharNumber"].ToString() : "";

                            txtBankName.Text = row["BankName"] != DBNull.Value ? row["BankName"].ToString() : "";
                            txtBankHolder.Text = row["BankHolderName"] != DBNull.Value ? row["BankHolderName"].ToString() : "";
                            txtBankAccNo.Text = row["BankAccountNumber"] != DBNull.Value ? row["BankAccountNumber"].ToString() : "";
                            txtBankIfsc.Text = row["BankIFSC"] != DBNull.Value ? row["BankIFSC"].ToString() : "";

                            txtAddress.Text = row["Address"] != DBNull.Value ? row["Address"].ToString() : "";
                            txtCity.Text = row["City"] != DBNull.Value ? row["City"].ToString() : "";
                            txtState.Text = row["State"] != DBNull.Value ? row["State"].ToString() : "";
                            txtPincode.Text = row["Pincode"] != DBNull.Value ? row["Pincode"].ToString() : "";

                            // B. Load Dynamic Indicators
                            bool isSubmitted = row["IsKycSubmitted"] != DBNull.Value ? Convert.ToBoolean(row["IsKycSubmitted"]) : false;
                            string kycStatus = row["KycStatus"] != DBNull.Value ? row["KycStatus"].ToString() : "Draft";
                            string updatedAt = row["UpdatedAt"] != DBNull.Value ? Convert.ToDateTime(row["UpdatedAt"]).ToString("MMM dd, yyyy hh:mm tt") : "Never";
                            string editStatus = row["EditRequestStatus"] != DBNull.Value ? row["EditRequestStatus"].ToString() : "";

                            // Track in viewstate to dynamically style the ASPX markup grid
                            ViewState["IsKycSubmitted"] = isSubmitted;
                            ViewState["KycStatus"] = string.IsNullOrEmpty(kycStatus) ? "Draft" : kycStatus;
                            ViewState["EditStatus"] = editStatus;

                            litPacketStatus.Text = isSubmitted ? "Submitted" : "Not Submitted";
                            litPacketDate.Text = updatedAt;
                            litApprovalStatus.Text = string.IsNullOrEmpty(kycStatus) ? "Awaiting Review" : kycStatus;
                            litTopBadge.Text = isSubmitted ? "Verification Locked" : "Draft Mode";

                            // C. Handle Document Attachment Previews
                            SetupFilePreview(row["KycPanDocPath"], boxPan, litPanLink);
                            SetupFilePreview(row["KycAadharDocPath"], boxAadhar, litAadharLink);
                            SetupFilePreview(row["KycGstDocPath"], boxGst, litGstLink);

                            // D. Enforce Audit Review Lock System
                            bool isEditable = false;
                            if (editStatus.Equals("ApprovedToEdit", StringComparison.OrdinalIgnoreCase))
                            {
                                isEditable = true;
                            }

                            if (isSubmitted && !isEditable)
                            {
                                LockFormControls();
                                pnlLockedBanner.Visible = true;
                                litPanelState.Text = "Audit Locked";
                                btnSaveKyc.Visible = false;
                            }
                            else if (isEditable)
                            {
                                litPanelState.Text = "Edit Mode Active";
                                litTopBadge.Text = "Modification Draft";
                            }

                            // E. Enforce Final Approved Banner & Edit Request Toggles
                            if (kycStatus.Equals("Approved", StringComparison.OrdinalIgnoreCase))
                            {
                                pnlApprovedBanner.Visible = true;
                                pnlLockedBanner.Visible = false; // Supercede with Green Approval ribbon

                                // Handle Sub-states for Approved Merchants wanting an Edit
                                if (string.IsNullOrEmpty(editStatus) || editStatus.Equals("None", StringComparison.OrdinalIgnoreCase))
                                {
                                    pnlRequestEditActions.Visible = true;
                                }
                                else if (editStatus.Equals("PendingApproval", StringComparison.OrdinalIgnoreCase))
                                {
                                    pnlEditRequestPending.Visible = true;
                                    LockFormControls(); // Lock them again explicitly
                                    btnSaveKyc.Visible = false;
                                }
                                else if (editStatus.Equals("DraftSubmitted", StringComparison.OrdinalIgnoreCase))
                                {
                                    pnlLockedBanner.Visible = true;
                                    litPanelState.Text = "Re-audit Pending";
                                    LockFormControls();
                                    btnSaveKyc.Visible = false;
                                }
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ShowMsg("Internal Engine Failure loading profile: " + ex.Message, true);
            }
        }

        private void SetupFilePreview(object pathVal, System.Web.UI.HtmlControls.HtmlGenericControl divBox, Literal lit)
        {
            if (pathVal != DBNull.Value && !string.IsNullOrEmpty(pathVal.ToString()))
            {
                string relPath = pathVal.ToString();
                // Normalize relative path for anchor tag
                string cleanPath = relPath.StartsWith("~") ? relPath.Substring(1) : relPath;
                if (!cleanPath.StartsWith("/")) cleanPath = "/" + cleanPath;

                divBox.Attributes["class"] = "kyc-upload-box has-file";
                lit.Text = string.Format("<a href='{0}' target='_blank' class='kyc-file-link'><i class='fas fa-paperclip'></i> View current attachment</a>", cleanPath);
            }
        }

        private void LockFormControls()
        {
            // Disable all inputs and append stylistic visual lock CSS
            TextBox[] textboxes = { txtStoreName, txtGst, txtPan, txtAadhar, txtBankName, txtBankHolder, txtBankAccNo, txtBankIfsc, txtAddress, txtCity, txtState, txtPincode };
            foreach (TextBox t in textboxes)
            {
                t.Enabled = false;
                t.CssClass = "reg-input kyc-input-disabled";
            }

            // Hide file inputs completely under active lock
            fuPan.Visible = false;
            fuAadhar.Visible = false;
            fuGst.Visible = false;
        }

        protected void btnRequestEdit_Click(object sender, EventArgs e)
        {
            if (Session["SellerId"] == null) return;
            int sid = Convert.ToInt32(Session["SellerId"]);

            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    string sql = "UPDATE SellerUsers SET EditRequestStatus = 'PendingApproval', UpdatedAt = GETDATE() WHERE Id = @sid";
                    using (SqlCommand cmd = new SqlCommand(sql, con))
                    {
                        cmd.Parameters.AddWithValue("@sid", sid);
                        cmd.ExecuteNonQuery();
                    }
                }
                Response.Redirect("Kyc.aspx?status=req_success");
            }
            catch (Exception ex)
            {
                ShowMsg("Failed to submit edit request: " + ex.Message, true);
            }
        }

        protected void btnSaveKyc_Click(object sender, EventArgs e)
        {
            if (Session["SellerId"] == null) return;
            int sid = Convert.ToInt32(Session["SellerId"]);

            // Perform visual validation checks
            if (string.IsNullOrEmpty(txtStoreName.Text) || string.IsNullOrEmpty(txtPan.Text) || string.IsNullOrEmpty(txtAadhar.Text) ||
                string.IsNullOrEmpty(txtBankName.Text) || string.IsNullOrEmpty(txtBankHolder.Text) || string.IsNullOrEmpty(txtBankAccNo.Text) ||
                string.IsNullOrEmpty(txtAddress.Text) || string.IsNullOrEmpty(txtCity.Text) || string.IsNullOrEmpty(txtState.Text))
            {
                ShowMsg("⚠️ Please complete all required mandatory compliance fields.", true);
                return;
            }

            try
            {
                // 1. Handle Document Archival Pipeline
                string uploadsFolder = Server.MapPath("~/uploads/kyc/");
                if (!Directory.Exists(uploadsFolder))
                {
                    Directory.CreateDirectory(uploadsFolder);
                }

                string dbPanPath = GetCurrentPath(sid, "KycPanDocPath");
                string dbAadharPath = GetCurrentPath(sid, "KycAadharDocPath");
                string dbGstPath = GetCurrentPath(sid, "KycGstDocPath");

                // Handle and save fresh uploaded files
                if (fuPan.HasFile) dbPanPath = SaveFileToDisk(fuPan, "pan_" + sid, uploadsFolder);
                if (fuAadhar.HasFile) dbAadharPath = SaveFileToDisk(fuAadhar, "aadhar_" + sid, uploadsFolder);
                if (fuGst.HasFile) dbGstPath = SaveFileToDisk(fuGst, "gst_" + sid, uploadsFolder);

                bool isEditFlow = (ViewState["EditStatus"] != null && ViewState["EditStatus"].ToString() == "ApprovedToEdit");

                // 2. Commit System Persistence Matrix
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    string sql = "";
                    if (isEditFlow)
                    {
                        // 2A. UPSERT INTO SellerKycDrafts + UPDATE EditRequestStatus in SellerUsers
                        sql = @"
                        IF EXISTS(SELECT 1 FROM SellerKycDrafts WHERE SellerId = @sid)
                        BEGIN
                            UPDATE SellerKycDrafts SET 
                                StoreName = @StoreName, GstNumber = @Gst, PanNumber = @Pan, AadharNumber = @Aadhar,
                                BankName = @Bank, BankHolderName = @BankHolder, BankAccountNumber = @BankAcc, BankIFSC = @BankIfsc,
                                Address = @Address, City = @City, State = @State, Pincode = @Pin,
                                KycPanDocPath = @PanPath, KycAadharDocPath = @AadharPath, KycGstDocPath = @GstPath,
                                SubmittedAt = GETDATE(), Status = 'PendingReview'
                            WHERE SellerId = @sid;
                        END
                        ELSE
                        BEGIN
                            INSERT INTO SellerKycDrafts 
                            (SellerId, StoreName, GstNumber, PanNumber, AadharNumber, BankName, BankHolderName, BankAccountNumber, BankIFSC, Address, City, State, Pincode, KycPanDocPath, KycAadharDocPath, KycGstDocPath, SubmittedAt, Status)
                            VALUES 
                            (@sid, @StoreName, @Gst, @Pan, @Aadhar, @Bank, @BankHolder, @BankAcc, @BankIfsc, @Address, @City, @State, @Pin, @PanPath, @AadharPath, @GstPath, GETDATE(), 'PendingReview');
                        END;

                        UPDATE SellerUsers SET EditRequestStatus = 'DraftSubmitted', UpdatedAt = GETDATE() WHERE Id = @sid;
                        ";
                    }
                    else
                    {
                        // 2B. Native First Time Submission
                        sql = @"UPDATE SellerUsers SET 
                            StoreName = @StoreName, GstNumber = @Gst, PanNumber = @Pan, AadharNumber = @Aadhar,
                            BankName = @Bank, BankHolderName = @BankHolder, BankAccountNumber = @BankAcc, BankIFSC = @BankIfsc,
                            Address = @Address, City = @City, State = @State, Pincode = @Pin,
                            KycPanDocPath = @PanPath, KycAadharDocPath = @AadharPath, KycGstDocPath = @GstPath,
                            IsKycSubmitted = 1, KycStatus = 'Pending', UpdatedAt = GETDATE()
                            WHERE Id = @sid";
                    }

                    using (SqlCommand cmd = new SqlCommand(sql, con))
                    {
                        cmd.Parameters.AddWithValue("@StoreName", txtStoreName.Text.Trim());
                        cmd.Parameters.AddWithValue("@Gst", txtGst.Text.Trim());
                        cmd.Parameters.AddWithValue("@Pan", txtPan.Text.Trim());
                        cmd.Parameters.AddWithValue("@Aadhar", txtAadhar.Text.Trim());
                        
                        cmd.Parameters.AddWithValue("@Bank", txtBankName.Text.Trim());
                        cmd.Parameters.AddWithValue("@BankHolder", txtBankHolder.Text.Trim());
                        cmd.Parameters.AddWithValue("@BankAcc", txtBankAccNo.Text.Trim());
                        cmd.Parameters.AddWithValue("@BankIfsc", txtBankIfsc.Text.Trim());

                        cmd.Parameters.AddWithValue("@Address", txtAddress.Text.Trim());
                        cmd.Parameters.AddWithValue("@City", txtCity.Text.Trim());
                        cmd.Parameters.AddWithValue("@State", txtState.Text.Trim());
                        cmd.Parameters.AddWithValue("@Pin", txtPincode.Text.Trim());

                        cmd.Parameters.AddWithValue("@PanPath", dbPanPath ?? (object)DBNull.Value);
                        cmd.Parameters.AddWithValue("@AadharPath", dbAadharPath ?? (object)DBNull.Value);
                        cmd.Parameters.AddWithValue("@GstPath", dbGstPath ?? (object)DBNull.Value);

                        cmd.Parameters.AddWithValue("@sid", sid);
                        
                        cmd.ExecuteNonQuery();
                    }
                }

                // PRG Redirection
                Response.Redirect("Kyc.aspx?status=success");
            }
            catch (Exception ex)
            {
                ShowMsg("Persistence pipeline fault: " + ex.Message, true);
            }
        }

        private string SaveFileToDisk(FileUpload fu, string prefix, string folder)
        {
            try
            {
                string ext = Path.GetExtension(fu.FileName).ToLower();
                string newName = prefix + "_" + DateTime.Now.Ticks + ext;
                string fullDiskPath = Path.Combine(folder, newName);
                fu.SaveAs(fullDiskPath);
                return "uploads/kyc/" + newName; // Relative SQL pointer
            }
            catch
            {
                return null;
            }
        }

        private string GetCurrentPath(int sid, string colName)
        {
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    string sql = string.Format("SELECT {0} FROM SellerUsers WHERE Id = @sid", colName);
                    using (SqlCommand cmd = new SqlCommand(sql, con))
                    {
                        cmd.Parameters.AddWithValue("@sid", sid);
                        object val = cmd.ExecuteScalar();
                        return val != DBNull.Value ? val.ToString() : null;
                    }
                }
            }
            catch { return null; }
        }

        private void ShowMsg(string msg, bool isErr)
        {
            lblGlobalMsg.Text = msg;
            lblGlobalMsg.CssClass = isErr ? "alert-danger d-block" : "alert-success d-block";
            lblGlobalMsg.Visible = true;
        }
    }
}
