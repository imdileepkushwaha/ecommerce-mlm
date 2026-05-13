using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Net;
using System.Net.Mail;
using System.Security.Cryptography;
using System.Text;
using System.Web;
using System.Web.UI;
using ecommerce_mlm;

namespace EcommerceWebsite
{
    public partial class SellerSignup : System.Web.UI.Page
    {
        string strcon = ConfigurationManager.ConnectionStrings["MlmDb"].ConnectionString;
        public bool IsVerificationModalOpen { get; set; }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                IsVerificationModalOpen = false;
                lblMsg.Visible = false;
                lblModalMsg.Visible = false;
            }
        }

        protected void btnSubmit_Click(object sender, EventArgs e)
        {
            lblMsg.Visible = false;
            
            // 1. Gather dynamic inputs
            string fullName = txtFullName.Text.Trim();
            string email = txtEmail.Text.Trim();
            string phone = txtPhone.Text.Trim();
            string password = txtPassword.Text;
            string storeName = txtStoreName.Text.Trim();
            string gst = txtGst.Text.Trim();
            string note = txtNote.Text.Trim();

            // Compile Categories CSV list
            List<string> cats = new List<string>();
            if (chkFashion.Checked) cats.Add("Fashion");
            if (chkElectronics.Checked) cats.Add("Electronics");
            if (chkBeauty.Checked) cats.Add("Beauty");
            if (chkHome.Checked) cats.Add("Home");
            string categoriesCsv = string.Join(", ", cats);

            // Basic Sanitization check
            if (string.IsNullOrEmpty(fullName) || string.IsNullOrEmpty(email) || string.IsNullOrEmpty(password) || string.IsNullOrEmpty(storeName))
            {
                ShowError("Please fill in all required input fields.");
                return;
            }

            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();

                    // A. Identity Check: Exclude duplicate email registries
                    string checkQuery = "SELECT COUNT(*) FROM SellerUsers WHERE Email = @email";
                    using (SqlCommand checkCmd = new SqlCommand(checkQuery, con))
                    {
                        checkCmd.Parameters.AddWithValue("@email", email);
                        int dupes = Convert.ToInt32(checkCmd.ExecuteScalar());
                        if (dupes > 0)
                        {
                            ShowError("A partner portfolio is already registered under this email address.");
                            return;
                        }
                    }

                    // B. Code Generation
                    Random rand = new Random();
                    string registrationCode = rand.Next(100000, 999999).ToString();

                    // C. Hash Encryption
                    string passwordHash = ComputeSha256Hash(password);

                    // D. Permanent SQL Payload Placement
                    string insertQuery = @"INSERT INTO SellerUsers 
                        (FullName, Email, Phone, PasswordHash, StoreName, GstNumber, RequestedCategories, AdditionalNote, 
                         IsActive, EmailVerified, AdminApproved, RegistrationCode, CreatedAt) 
                        VALUES 
                        (@FullName, @Email, @Phone, @PasswordHash, @StoreName, @Gst, @Cats, @Note, 
                         0, 0, 0, @RegCode, GETDATE())";

                    using (SqlCommand cmd = new SqlCommand(insertQuery, con))
                    {
                        cmd.Parameters.AddWithValue("@FullName", fullName);
                        cmd.Parameters.AddWithValue("@Email", email);
                        cmd.Parameters.AddWithValue("@Phone", phone);
                        cmd.Parameters.AddWithValue("@PasswordHash", passwordHash);
                        cmd.Parameters.AddWithValue("@StoreName", storeName);
                        cmd.Parameters.AddWithValue("@Gst", gst);
                        cmd.Parameters.AddWithValue("@Cats", categoriesCsv);
                        cmd.Parameters.AddWithValue("@Note", note);
                        cmd.Parameters.AddWithValue("@RegCode", registrationCode);

                        cmd.ExecuteNonQuery();
                    }

                    // Save target state inside trackers
                    Session["PendingSignupEmail"] = email;

                    // E. Code Dispatch
                    bool sent = SendRegistrationEmail(email, fullName, registrationCode);
                    
                    // F. Trigger Modal Viewport
                    IsVerificationModalOpen = true;
                    lblModalMsg.Visible = true;
                    if (sent)
                    {
                        lblModalMsg.Text = "Verification dispatched! Check your email box.";
                        lblModalMsg.CssClass = "alert-success d-block mb-3";
                    }
                    else
                    {
                        // Dev Mode Fallback Simulation Notice
                        lblModalMsg.Text = "🔔 Dev Mode Code: " + registrationCode + " (Mail skipped locally)";
                        lblModalMsg.CssClass = "alert-success d-block mb-3";
                    }
                }
            }
            catch (Exception ex)
            {
                ShowError("Registration Subsystem Fault: " + ex.Message);
            }
        }

        protected void btnVerifyOtp_Click(object sender, EventArgs e)
        {
            string email = Session["PendingSignupEmail"] != null ? Session["PendingSignupEmail"].ToString() : "";
            string code = txtOtpCode.Text.Trim();

            if (string.IsNullOrEmpty(email))
            {
                ShowError("Onboarding session terminated. Start again.");
                IsVerificationModalOpen = false;
                return;
            }

            if (string.IsNullOrEmpty(code))
            {
                IsVerificationModalOpen = true;
                ShowModalMessage("Please type the 6-digit registration code.", true);
                return;
            }

            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();

                    // Check matching record
                    string checkQuery = "SELECT COUNT(*) FROM SellerUsers WHERE Email = @email AND RegistrationCode = @code";
                    using (SqlCommand cmd = new SqlCommand(checkQuery, con))
                    {
                        cmd.Parameters.AddWithValue("@email", email);
                        cmd.Parameters.AddWithValue("@code", code);

                        int count = Convert.ToInt32(cmd.ExecuteScalar());
                        if (count > 0)
                        {
                            // Match! Update statuses and clear out the temporary code
                            string updateQuery = "UPDATE SellerUsers SET EmailVerified = 1, RegistrationCode = NULL WHERE Email = @email";
                            using (SqlCommand updCmd = new SqlCommand(updateQuery, con))
                            {
                                updCmd.Parameters.AddWithValue("@email", email);
                                updCmd.ExecuteNonQuery();
                            }

                            // Safe disposal
                            Session.Remove("PendingSignupEmail");

                            // Successful exit loop redirect
                            Response.Redirect("Login.aspx?registered=1");
                        }
                        else
                        {
                            IsVerificationModalOpen = true;
                            ShowModalMessage("❌ Code mismatch! Please double check.", true);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                IsVerificationModalOpen = true;
                ShowModalMessage("Verification engine fault: " + ex.Message, true);
            }
        }

        protected void btnCloseModal_Click(object sender, EventArgs e)
        {
            IsVerificationModalOpen = false;
        }

        private string ComputeSha256Hash(string rawData)
        {
            using (SHA256 sha256Hash = SHA256.Create())
            {
                byte[] bytes = sha256Hash.ComputeHash(Encoding.UTF8.GetBytes(rawData));
                StringBuilder builder = new StringBuilder();
                for (int i = 0; i < bytes.Length; i++)
                {
                    builder.Append(bytes[i].ToString("x2"));
                }
                return builder.ToString();
            }
        }

        private bool SendRegistrationEmail(string toEmail, string fullName, string code)
        {
            try
            {
                string fromEmail = ConfigHelper.GetConfig("SmtpFrom");
                string smtpPass = ConfigHelper.GetConfig("SmtpPass");
                string smtpHost = ConfigHelper.GetConfig("SmtpHost", "smtp.gmail.com");
                int smtpPort = int.Parse(ConfigHelper.GetConfig("SmtpPort", "587"));
                bool enableSsl = bool.Parse(ConfigHelper.GetConfig("SmtpEnableSsl", "TRUE"));

                MailMessage mail = new MailMessage(fromEmail, toEmail);
                mail.Subject = "Verify your Kartify Partner Registration";
                mail.Body = string.Format("Hi {0},\n\nThank you for registering to sell on Kartify!\n\nYOUR PARTNER VERIFICATION CODE IS: {1}\n\nPlease input this secure token to finish registering your merchant portfolio.\n\nBest Regards,\nKartify Onboarding Hub.", fullName, code);
                mail.IsBodyHtml = false;

                using (SmtpClient smtp = new SmtpClient(smtpHost, smtpPort))
                {
                    smtp.Credentials = new NetworkCredential(fromEmail, smtpPass);
                    smtp.EnableSsl = enableSsl;
                    smtp.Send(mail);
                }
                return true;
            }
            catch
            {
                return false;
            }
        }

        private void ShowError(string msg)
        {
            lblMsg.Text = msg;
            lblMsg.CssClass = "alert-danger d-block mb-3";
            lblMsg.Visible = true;
        }

        private void ShowModalMessage(string msg, bool isError)
        {
            lblModalMsg.Text = msg;
            lblModalMsg.CssClass = isError ? "alert-danger d-block mb-3" : "alert-success d-block mb-3";
            lblModalMsg.Visible = true;
        }
    }
}
