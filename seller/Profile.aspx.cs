using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.IO;
using System.Web;
using System.Web.UI.WebControls;

namespace EcommerceWebsite
{
    public partial class SellerProfile : System.Web.UI.Page
    {
        string strcon = ConfigurationManager.ConnectionStrings["MlmDb"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["SellerId"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                lblMsg.Visible = false;
                LoadSellerProfile();
            }
        }

        private void LoadSellerProfile()
        {
            try
            {
                int sellerId = Convert.ToInt32(Session["SellerId"]);

                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    string query = "SELECT * FROM SellerUsers WHERE Id = @id";
                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        cmd.Parameters.AddWithValue("@id", sellerId);
                        using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                        {
                            DataTable dt = new DataTable();
                            da.Fill(dt);

                            if (dt.Rows.Count > 0)
                            {
                                DataRow r = dt.Rows[0];

                                // --- 1. EXECUTIVE METRICS & STATUSES ---
                                bool isKycSub = r["IsKycSubmitted"] != DBNull.Value ? Convert.ToBoolean(r["IsKycSubmitted"]) : false;
                                litKycSub.Text = isKycSub ? "Yes" : "No";
                                
                                string kycStatus = r["KycStatus"] != DBNull.Value ? r["KycStatus"].ToString() : "Pending";
                                litApproval.Text = kycStatus;

                                string editReq = r["EditRequestStatus"] != DBNull.Value ? r["EditRequestStatus"].ToString() : "None";
                                litEditReq.Text = string.IsNullOrEmpty(editReq) ? "None" : editReq;

                                DateTime updatedAt = r["UpdatedAt"] != DBNull.Value ? Convert.ToDateTime(r["UpdatedAt"]) : DateTime.Now;
                                litKycUpdate.Text = updatedAt.ToString("MMM dd, yyyy - hh:mm tt");
                                litReviewDate.Text = updatedAt.ToString("MMM dd, yyyy - hh:mm tt");

                                // View Store Redirect Wireup
                                lnkViewStore.NavigateUrl = "~/SellerStore.aspx?id=" + sellerId;

                                // --- 2. IDENTITY DATA BLOCKS ---
                                litFullName.Text = r["FullName"] != DBNull.Value ? r["FullName"].ToString() : "--";
                                
                                string email = r["Email"] != DBNull.Value ? r["Email"].ToString() : "--";
                                litEmail.Text = email;
                                chkEmailVerify.Visible = r["EmailVerified"] != DBNull.Value ? Convert.ToBoolean(r["EmailVerified"]) : false;

                                string storeName = r["StoreName"] != DBNull.Value ? r["StoreName"].ToString() : "--";
                                litStoreName.Text = storeName;

                                string phoneStr = r["Phone"] != DBNull.Value ? r["Phone"].ToString() : "--";
                                litPhoneFile.Text = phoneStr;
                                txtPhone.Text = phoneStr;

                                string addrStr = r["Address"] != DBNull.Value ? r["Address"].ToString() : "--";
                                litAddressFile.Text = addrStr;
                                txtAddress.Text = addrStr;

                                litCats.Text = r["RequestedCategories"] != DBNull.Value ? r["RequestedCategories"].ToString() : "General";
                                
                                string gst = r["GstNumber"] != DBNull.Value ? r["GstNumber"].ToString() : "--";
                                litGstNum.Text = string.IsNullOrEmpty(gst) ? "--" : gst;
                                
                                string pan = r["PanNumber"] != DBNull.Value ? r["PanNumber"].ToString() : "--";
                                litPanNum.Text = string.IsNullOrEmpty(pan) ? "--" : pan;
                                
                                string aadhar = r["AadharNumber"] != DBNull.Value ? r["AadharNumber"].ToString() : "--";
                                litAadharNum.Text = string.IsNullOrEmpty(aadhar) ? "--" : aadhar;
                                
                                litIdProofNum.Text = string.IsNullOrEmpty(aadhar) ? "--" : aadhar;

                                // --- 3. PREVIEW BRANDING RENDERERS ---
                                string logo = r["LogoPath"] != DBNull.Value ? r["LogoPath"].ToString() : "";
                                if (!string.IsNullOrEmpty(logo))
                                {
                                    imgPreviewLogo.ImageUrl = ResolveUrl(NormalizePath(logo)) + "?v=" + Guid.NewGuid().ToString().Substring(0, 8);
                                }
                                else
                                {
                                    imgPreviewLogo.ImageUrl = "https://via.placeholder.com/200?text=No+Logo";
                                }

                                string banner = r["BannerPath"] != DBNull.Value ? r["BannerPath"].ToString() : "";
                                if (!string.IsNullOrEmpty(banner))
                                {
                                    imgPreviewBanner.ImageUrl = ResolveUrl(NormalizePath(banner)) + "?v=" + Guid.NewGuid().ToString().Substring(0, 8);
                                }
                                else
                                {
                                    imgPreviewBanner.ImageUrl = "https://via.placeholder.com/800x200?text=No+Banner";
                                }

                                // --- 4. BANKING SNAPSHOT ---
                                litBankName.Text = r["BankName"] != DBNull.Value ? r["BankName"].ToString() : "--";
                                litBankHolder.Text = r["BankHolderName"] != DBNull.Value ? r["BankHolderName"].ToString() : "--";
                                litBankAccNum.Text = r["BankAccountNumber"] != DBNull.Value ? r["BankAccountNumber"].ToString() : "--";
                                litBankIfsc.Text = r["BankIFSC"] != DBNull.Value ? r["BankIFSC"].ToString() : "--";
                                
                                string city = r["City"] != DBNull.Value ? r["City"].ToString() : "";
                                string state = r["State"] != DBNull.Value ? r["State"].ToString() : "";
                                string pin = r["Pincode"] != DBNull.Value ? r["Pincode"].ToString() : "";
                                string combinedAddr = addrStr;
                                if (!string.IsNullOrEmpty(city)) combinedAddr += ", " + city;
                                if (!string.IsNullOrEmpty(state)) combinedAddr += ", " + state;
                                if (!string.IsNullOrEmpty(pin)) combinedAddr += " — " + pin;
                                litBankAddress.Text = string.IsNullOrEmpty(combinedAddr.Trim(',',' ')) ? "--" : combinedAddr;

                                // --- 5. DOCUMENT VAULT LINKS ---
                                string gstDoc = r["KycGstDocPath"] != DBNull.Value ? r["KycGstDocPath"].ToString() : "";
                                if (!string.IsNullOrEmpty(gstDoc))
                                {
                                    lnkGstDoc.NavigateUrl = ResolveUrl(NormalizePath(gstDoc));
                                    lnkGstDoc.Visible = true;
                                    lblGstNa.Visible = false;
                                }
                                
                                string panDoc = r["KycPanDocPath"] != DBNull.Value ? r["KycPanDocPath"].ToString() : "";
                                if (!string.IsNullOrEmpty(panDoc))
                                {
                                    lnkPanDoc.NavigateUrl = ResolveUrl(NormalizePath(panDoc));
                                    lnkPanDoc.Visible = true;
                                    lblPanNa.Visible = false;
                                }

                                string aadharDoc = r["KycAadharDocPath"] != DBNull.Value ? r["KycAadharDocPath"].ToString() : "";
                                if (!string.IsNullOrEmpty(aadharDoc))
                                {
                                    lnkAadharDoc.NavigateUrl = ResolveUrl(NormalizePath(aadharDoc));
                                    lnkAadharDoc.Visible = true;
                                    lblAadharNa.Visible = false;
                                }
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ShowAlert("An error occurred while loading your profile: " + ex.Message, false);
            }
        }

        protected void btnSave_Click(object sender, EventArgs e)
        {
            try
            {
                int sellerId = Convert.ToInt32(Session["SellerId"]);
                string newPhone = txtPhone.Text.Trim();
                string newAddr = txtAddress.Text.Trim();

                if (string.IsNullOrEmpty(newPhone))
                {
                    ShowAlert("⚠️ Contact Phone Number is required.", false);
                    return;
                }

                string targetDir = Server.MapPath("~/uploads/store_assets/");
                if (!Directory.Exists(targetDir))
                {
                    Directory.CreateDirectory(targetDir);
                }

                string logoDbPath = null;
                string bannerDbPath = null;

                // Process Logo Stream
                if (fuLogo.HasFile)
                {
                    string ext = Path.GetExtension(fuLogo.FileName).ToLower();
                    if (ext == ".jpg" || ext == ".jpeg" || ext == ".png" || ext == ".webp" || ext == ".gif")
                    {
                        string logoName = "logo_" + sellerId + "_" + Guid.NewGuid().ToString().Substring(0, 6) + ext;
                        string absolutePath = Path.Combine(targetDir, logoName);
                        fuLogo.SaveAs(absolutePath);
                        logoDbPath = "~/uploads/store_assets/" + logoName;
                    }
                    else
                    {
                        ShowAlert("⚠️ Invalid Logo format. Only JPG, PNG, WebP, or GIF permitted.", false);
                        return;
                    }
                }

                // Process Banner Stream
                if (fuBanner.HasFile)
                {
                    string ext = Path.GetExtension(fuBanner.FileName).ToLower();
                    if (ext == ".jpg" || ext == ".jpeg" || ext == ".png" || ext == ".webp" || ext == ".gif")
                    {
                        string bannerName = "banner_" + sellerId + "_" + Guid.NewGuid().ToString().Substring(0, 6) + ext;
                        string absolutePath = Path.Combine(targetDir, bannerName);
                        fuBanner.SaveAs(absolutePath);
                        bannerDbPath = "~/uploads/store_assets/" + bannerName;
                    }
                    else
                    {
                        ShowAlert("⚠️ Invalid Banner format. Only JPG, PNG, WebP, or GIF permitted.", false);
                        return;
                    }
                }

                // Apply Modifications to Database
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    
                    string updateSql = "UPDATE SellerUsers SET Phone = @phone, Address = @addr, UpdatedAt = GETDATE()";
                    if (logoDbPath != null) updateSql += ", LogoPath = @logo";
                    if (bannerDbPath != null) updateSql += ", BannerPath = @banner";
                    updateSql += " WHERE Id = @id";

                    using (SqlCommand cmd = new SqlCommand(updateSql, con))
                    {
                        cmd.Parameters.AddWithValue("@phone", newPhone);
                        cmd.Parameters.AddWithValue("@addr", newAddr);
                        cmd.Parameters.AddWithValue("@id", sellerId);
                        
                        if (logoDbPath != null) cmd.Parameters.AddWithValue("@logo", logoDbPath);
                        if (bannerDbPath != null) cmd.Parameters.AddWithValue("@banner", bannerDbPath);

                        cmd.ExecuteNonQuery();
                    }
                }

                // Reload to showcase instant visual reflect
                LoadSellerProfile();
                ShowAlert("✅ Profile and store branding updated successfully!", true);
            }
            catch (Exception ex)
            {
                ShowAlert("An error occurred during save: " + ex.Message, false);
            }
        }

        private void ShowAlert(string message, bool isSuccess)
        {
            lblMsg.Visible = true;
            lblMsg.Text = message;
            if (isSuccess)
            {
                lblMsg.BackColor = System.Drawing.ColorTranslator.FromHtml("#dcfce7");
                lblMsg.ForeColor = System.Drawing.ColorTranslator.FromHtml("#15803d");
                lblMsg.Style["border"] = "1.5px solid #bbf7d0";
            }
            else
            {
                lblMsg.BackColor = System.Drawing.ColorTranslator.FromHtml("#fee2e2");
                lblMsg.ForeColor = System.Drawing.ColorTranslator.FromHtml("#b91c1c");
                lblMsg.Style["border"] = "1.5px solid #fecaca";
            }
        }

        private string NormalizePath(string path)
        {
            if (string.IsNullOrEmpty(path)) return "";
            if (path.StartsWith("~/")) return path;
            if (path.StartsWith("/")) return "~" + path;
            return "~/" + path;
        }
    }
}
