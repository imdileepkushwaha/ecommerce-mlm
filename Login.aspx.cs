using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Net;
using System.Net.Mail;
using System.Web.UI;

namespace ecommerce_mlm
{
    public partial class Login : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            lblError.Visible = false;
            lblSuccess.Visible = false;

            if (Session["Username"] != null)
            {
                Response.Redirect("Index.aspx");
            }
        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            string username = txtUsername.Text.Trim();
            string password = txtPassword.Text.Trim();
            string userCaptcha = txtCaptcha.Text.Trim();

            // 1. Basic Input Check
            if (string.IsNullOrEmpty(username) || string.IsNullOrEmpty(password) || string.IsNullOrEmpty(userCaptcha))
            {
                ShowError("Please fill in Username, Password, and Captcha.");
                return;
            }

            // 2. Verify Captcha
            if (Session["CaptchaCode"] == null || userCaptcha.ToUpper() != Session["CaptchaCode"].ToString().ToUpper())
            {
                ShowError("Invalid Captcha Code. Please try again.");
                txtCaptcha.Text = ""; // Reset input
                return;
            }

            // 3. Authenticate against DB
            string connStr = ConfigurationManager.ConnectionStrings["MlmDb"].ConnectionString;
            
            using (SqlConnection con = new SqlConnection(connStr))
            {
                using (SqlCommand cmd = new SqlCommand("sp_UserLogin", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@Username", username);
                    cmd.Parameters.AddWithValue("@Password", password);

                    try
                    {
                        con.Open();
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.HasRows)
                            {
                                reader.Read();
                                Session["UserId"] = reader["Id"].ToString();
                                Session["Username"] = reader["Username"].ToString();
                                Session["FullName"] = reader["FullName"].ToString();
                                
                                // Clear captcha so it expires
                                Session["CaptchaCode"] = null; 

                                Response.Redirect("Index.aspx");
                            }
                            else
                            {
                                ShowError("Invalid Username or Password.");
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        ShowError("System Error: " + ex.Message);
                    }
                }
            }
        }

        protected void btnSendCode_Click(object sender, EventArgs e)
        {
            lblModalMsg.Visible = false;
            string identity = txtResetIdentity.Text.Trim();
            if (string.IsNullOrEmpty(identity))
            {
                ShowModalError("Please enter your registered Username or Email.");
                return;
            }

            string connStr = ConfigurationManager.ConnectionStrings["MlmDb"].ConnectionString;
            using (SqlConnection con = new SqlConnection(connStr))
            {
                string query = "SELECT Email, FullName FROM Users WHERE Username = @Identity OR Email = @Identity";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                            cmd.Parameters.AddWithValue("@Identity", identity);
                    try
                    {
                        con.Open();
                        using (SqlDataReader reader = cmd.ExecuteReader())
                        {
                            if (reader.Read())
                            {
                                string targetEmail = reader["Email"].ToString();
                                string targetName = reader["FullName"].ToString();

                                // 1. Generate numeric 6-digit OTP
                                Random rand = new Random();
                                string otpCode = rand.Next(100000, 999999).ToString();

                                // 2. Store identity in Session for subsequent steps
                                Session["PwdResetCode"] = otpCode;
                                Session["PwdResetIdentity"] = targetEmail;

                                // 3. Attempt dispatch
                                bool sent = SendOTPEmail(targetEmail, targetName, otpCode);
                                
                                if (sent) {
                                    mvForgot.SetActiveView(vwStep2);
                                } else {
                                    ShowModalError("Wait! Mail dispatch failed, but valid verification code is: " + otpCode + " (Proceeding to verify)");
                                    mvForgot.SetActiveView(vwStep2);
                                }

                                // FIRE COUNTDOWN TIMER!
                                string sc = string.Format("startResendCountdown('resendTimer', '{0}', 'timeLeft', 120);", lnkResendCode.ClientID);
                                ScriptManager.RegisterStartupScript(this, GetType(), "TriggerTimer", sc, true);
                            }
                            else
                            {
                                ShowModalError("No matching account located.");
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        ShowModalError("System DB Fault: " + ex.Message);
                    }
                }
            }
        }

        protected void lnkResendCode_Click(object sender, EventArgs e)
        {
            lblModalMsg.Visible = false;
            string cachedEmail = Session["PwdResetIdentity"] != null ? Session["PwdResetIdentity"].ToString() : "";

            if (string.IsNullOrEmpty(cachedEmail))
            {
                ShowModalError("Session lost. Return to step 1.");
                mvForgot.SetActiveView(vwStep1);
                return;
            }

            // Redo Send Procedure
            string connStr = ConfigurationManager.ConnectionStrings["MlmDb"].ConnectionString;
            using (SqlConnection con = new SqlConnection(connStr))
            {
                using (SqlCommand cmd = new SqlCommand("SELECT FullName FROM Users WHERE Email = @Mail OR Username = @Mail", con))
                {
                    cmd.Parameters.AddWithValue("@Mail", cachedEmail);
                    try
                    {
                        con.Open();
                        object res = cmd.ExecuteScalar();
                        string name = res != null ? res.ToString() : "User";

                        string newOtp = new Random().Next(100000, 999999).ToString();
                        Session["PwdResetCode"] = newOtp;

                        bool isSent = SendOTPEmail(cachedEmail, name, newOtp);
                        if (isSent) {
                            ShowModalError("Success: A new code was successfully dispatched.");
                        } else {
                            ShowModalError("Resent code failed to mail. Dev mode code: " + newOtp);
                        }

                        // RESTART TIMER
                        string sc2 = string.Format("startResendCountdown('resendTimer', '{0}', 'timeLeft', 120);", lnkResendCode.ClientID);
                        ScriptManager.RegisterStartupScript(this, GetType(), "ReTriggerTimer", sc2, true);
                    }
                    catch (Exception ex) { ShowModalError("Retry DB Error: " + ex.Message); }
                }
            }
        }

        protected void btnVerifyCode_Click(object sender, EventArgs e)
        {
            lblModalMsg.Visible = false;
            string inputCode = txtResetCode.Text.Trim();
            string activeCode = Session["PwdResetCode"] != null ? Session["PwdResetCode"].ToString() : "";

            if (!string.IsNullOrEmpty(activeCode) && inputCode == activeCode)
            {
                // Code matches! Move user to generate new password
                mvForgot.SetActiveView(vwStep3);
            }
            else
            {
                ShowModalError("The security code is incorrect. Check mail again.");
            }
        }

        protected void btnFinalReset_Click(object sender, EventArgs e)
        {
            lblModalMsg.Visible = false;
            string newPass = txtNewPassword.Text.Trim();
            string confirmPass = txtConfirmNewPassword.Text.Trim();
            string validatedUser = Session["PwdResetIdentity"] != null ? Session["PwdResetIdentity"].ToString() : "";

            if (string.IsNullOrEmpty(validatedUser))
            {
                ShowModalError("Session expired. Start reset flow again.");
                return;
            }

            if (string.IsNullOrEmpty(newPass) || newPass.Length < 3)
            {
                ShowModalError("Please define a valid strong password.");
                return;
            }

            if (newPass != confirmPass)
            {
                ShowModalError("Confirmation check failed. Passwords mismatch.");
                return;
            }

            // All good, push update to DB
            string connStr = ConfigurationManager.ConnectionStrings["MlmDb"].ConnectionString;
            using (SqlConnection con = new SqlConnection(connStr))
            {
                string updateSql = "UPDATE Users SET Password = @NewPass WHERE Email = @EmailTarget OR Username = @EmailTarget";
                using (SqlCommand cmd = new SqlCommand(updateSql, con))
                {
                    cmd.Parameters.AddWithValue("@NewPass", newPass);
                    cmd.Parameters.AddWithValue("@EmailTarget", validatedUser);

                    try
                    {
                        con.Open();
                        cmd.ExecuteNonQuery();
                        
                        // Clear safe-trackers
                        Session.Remove("PwdResetCode");
                        Session.Remove("PwdResetIdentity");

                        // Finish successfully
                        mvForgot.SetActiveView(vwStep4);
                    }
                    catch (Exception ex)
                    {
                        ShowModalError("Failed writing to DB: " + ex.Message);
                    }
                }
            }
        }

        private void ShowModalError(string msg)
        {
            lblModalMsg.Text = msg;
            lblModalMsg.Visible = true;
        }

        private bool SendOTPEmail(string toEmail, string fullName, string code)
        {
            try
            {
                string fromEmail = ConfigurationManager.AppSettings["SmtpFrom"];
                string smtpPass = ConfigurationManager.AppSettings["SmtpPass"];
                string smtpHost = ConfigurationManager.AppSettings["SmtpHost"];
                int smtpPort = int.Parse(ConfigurationManager.AppSettings["SmtpPort"]);
                bool enableSsl = bool.Parse(ConfigurationManager.AppSettings["SmtpEnableSsl"]);

                MailMessage mail = new MailMessage(fromEmail, toEmail);
                mail.Subject = code + " is your Kartify verification code";
                mail.Body = string.Format("Hi {0},\n\nWe received your password recovery call.\n\nYOUR VERIFICATION CODE IS: {1}\n\nPlease enter this code to successfully change your password.\n\nStay secure,\nKartify Security Hub.", fullName, code);
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
                return false; // If sending logic fails, returns false so failover logic catches it
            }
        }

        private void ShowError(string msg)
        {
            lblError.Text = msg;
            lblError.Visible = true;
        }
    }
}
