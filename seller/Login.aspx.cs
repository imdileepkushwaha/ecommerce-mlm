using System;
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
    public partial class SellerLogin : System.Web.UI.Page
    {
        string strcon = ConfigurationManager.ConnectionStrings["MlmDb"].ConnectionString;
        public bool IsForgotModalOpen { get; set; }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                IsForgotModalOpen = false;
                lblMsg.Visible = false;
                lblResetMsg.Visible = false;

                if (Request.QueryString["registered"] == "1")
                {
                    ShowMsg("🎉 Account registered & verified successfully! Access will be active once system administrators complete verification.", false);
                }
            }
        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            lblMsg.Visible = false;
            string email = txtEmail.Text.Trim();
            string password = txtPassword.Text;
            string captchaInput = txtCaptcha.Text.Trim();

            if (string.IsNullOrEmpty(email) || string.IsNullOrEmpty(password) || string.IsNullOrEmpty(captchaInput))
            {
                ShowMsg("Please fill in Email, Password, and Captcha Code.", true);
                return;
            }

            // Captcha Verification Vector
            if (Session["CaptchaCode"] == null || captchaInput.ToUpper() != Session["CaptchaCode"].ToString().ToUpper())
            {
                ShowMsg("Invalid Captcha code. Verification failed.", true);
                txtCaptcha.Text = ""; // Reset input box
                return;
            }

            try
            {
                string hashedInput = ComputeSha256Hash(password);
                
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    string query = "SELECT Id, FullName, Email, IsActive FROM SellerUsers WHERE Email = @e AND PasswordHash = @p";
                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        cmd.Parameters.AddWithValue("@e", email);
                        cmd.Parameters.AddWithValue("@p", hashedInput);
                        
                        using (SqlDataReader dr = cmd.ExecuteReader())
                        {
                            if (dr.Read())
                            {
                                bool active = Convert.ToBoolean(dr["IsActive"]);
                                if (!active)
                                {
                                    ShowMsg("Your merchant portfolio is currently suspended by system administration.", true);
                                    return;
                                }

                                // Store Auth Payload
                                Session["SellerId"] = dr["Id"].ToString();
                                Session["SellerName"] = dr["FullName"].ToString();
                                Session["SellerEmail"] = dr["Email"].ToString();
                                
                                Session["CaptchaCode"] = null; // Expire captcha on success

                                Response.Redirect("Dashboard.aspx");
                            }
                            else
                            {
                                ShowMsg("Invalid merchant credentials provided. Try again.", true);
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ShowMsg("Auth Gateway Fault: " + ex.Message, true);
            }
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

        private void ShowMsg(string msg, bool isError)
        {
            lblMsg.Text = msg;
            lblMsg.CssClass = isError ? "alert alert-danger d-block py-2 mb-3 rounded-3 small" : "alert alert-success d-block py-2 mb-3 rounded-3 small";
            lblMsg.Visible = true;
        }

        private void ShowResetMsg(string msg, bool isError)
        {
            lblResetMsg.Text = msg;
            lblResetMsg.CssClass = isError ? "alert alert-danger d-block py-2 mb-3 rounded-3 small" : "alert alert-success d-block py-2 mb-3 rounded-3 small";
            lblResetMsg.Visible = true;
        }

        // === DYNAMIC PASSWORD RECOVERY SUBSYSTEM ===

        protected void btnSendResetCode_Click(object sender, EventArgs e)
        {
            IsForgotModalOpen = true;
            string resetEmail = txtResetEmail.Text.Trim();

            if (string.IsNullOrEmpty(resetEmail))
            {
                ShowResetMsg("Please enter your registered merchant email.", true);
                return;
            }

            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    string query = "SELECT FullName, Email FROM SellerUsers WHERE Email = @email";
                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        cmd.Parameters.AddWithValue("@email", resetEmail);
                        using (SqlDataReader dr = cmd.ExecuteReader())
                        {
                            if (dr.Read())
                            {
                                string fullName = dr["FullName"].ToString();
                                
                                // 1. Generate numeric code
                                Random rand = new Random();
                                string code = rand.Next(100000, 999999).ToString();

                                // 2. Store temporarily in session
                                Session["SellerResetCode"] = code;
                                Session["SellerResetEmail"] = resetEmail;

                                // 3. Dispatch Email
                                bool mailSent = SendOTPEmail(resetEmail, fullName, code);
                                if (mailSent)
                                {
                                    ShowResetMsg("Verification code successfully dispatched to your mailbox.", false);
                                }
                                else
                                {
                                    // DEV FAILOVER NOTICE
                                    ShowResetMsg("🔔 Dev Mode: Use verification code " + code + " (Mail skipped locally)", false);
                                }
                            }
                            else
                            {
                                ShowResetMsg("No merchant account matches this email address.", true);
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ShowResetMsg("Database Gate Fault: " + ex.Message, true);
            }
        }

        protected void btnVerifyResetCode_Click(object sender, EventArgs e)
        {
            IsForgotModalOpen = true;
            string enteredCode = txtResetCode.Text.Trim();

            if (string.IsNullOrEmpty(enteredCode))
            {
                ShowResetMsg("Please enter the 6-digit verification code.", true);
                return;
            }

            if (Session["SellerResetCode"] == null)
            {
                ShowResetMsg("Session expired. Please request a new code.", true);
                return;
            }

            if (enteredCode == Session["SellerResetCode"].ToString())
            {
                pnlResetPasswordFields.Visible = true;
                ShowResetMsg("Verification Successful! Set your new store access key.", false);
            }
            else
            {
                ShowResetMsg("Invalid verification code. Please try again.", true);
            }
        }

        protected void btnResetPassword_Click(object sender, EventArgs e)
        {
            IsForgotModalOpen = true;
            string p1 = txtResetPassword.Text;
            string p2 = txtConfirmResetPassword.Text;
            string resetEmail = Session["SellerResetEmail"] != null ? Session["SellerResetEmail"].ToString() : null;

            if (string.IsNullOrEmpty(p1) || string.IsNullOrEmpty(p2))
            {
                ShowResetMsg("Please fill in both password boxes.", true);
                return;
            }

            if (p1 != p2)
            {
                ShowResetMsg("Passwords do not match.", true);
                return;
            }

            if (string.IsNullOrEmpty(resetEmail))
            {
                ShowResetMsg("Reset session expired. Restart the recovery loop.", true);
                return;
            }

            try
            {
                string finalHash = ComputeSha256Hash(p1);

                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    string updateQuery = "UPDATE SellerUsers SET PasswordHash = @hash WHERE Email = @email";
                    using (SqlCommand cmd = new SqlCommand(updateQuery, con))
                    {
                        cmd.Parameters.AddWithValue("@hash", finalHash);
                        cmd.Parameters.AddWithValue("@email", resetEmail);
                        
                        cmd.ExecuteNonQuery();

                        // Cleanup Sessions
                        Session.Remove("SellerResetCode");
                        Session.Remove("SellerResetEmail");

                        ShowResetMsg("Store access key successfully synchronized! You can now close this modal and sign in.", false);
                        
                        // Reset visual controls
                        pnlResetPasswordFields.Visible = false;
                        txtResetEmail.Text = "";
                        txtResetCode.Text = "";
                    }
                }
            }
            catch (Exception ex)
            {
                ShowResetMsg("Failed to synchronize password: " + ex.Message, true);
            }
        }

        private bool SendOTPEmail(string toEmail, string fullName, string code)
        {
            try
            {
                string fromEmail = ConfigHelper.GetConfig("SmtpFrom");
                string smtpPass = ConfigHelper.GetConfig("SmtpPass");
                string smtpHost = ConfigHelper.GetConfig("SmtpHost", "smtp.gmail.com");
                int smtpPort = int.Parse(ConfigHelper.GetConfig("SmtpPort", "587"));
                bool enableSsl = bool.Parse(ConfigHelper.GetConfig("SmtpEnableSsl", "TRUE"));

                MailMessage mail = new MailMessage(fromEmail, toEmail);
                mail.Subject = code + " is your Kartify merchant verification code";
                mail.Body = string.Format("Hi {0},\n\nWe received your store password recovery call.\n\nYOUR VERIFICATION CODE IS: {1}\n\nPlease enter this code to successfully change your seller password.\n\nStay secure,\nKartify Security Hub.", fullName, code);
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
                return false; // Local dispatch failures are caught gracefully by calling routine
            }
        }
    }
}
