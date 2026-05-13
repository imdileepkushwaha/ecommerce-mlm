using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Net;
using System.Net.Mail;
using System.Web.UI;

namespace ecommerce_mlm
{
    public partial class Register : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            lblMessage.Visible = false;
            lblError.Visible = false;
            lblSponsorError.Visible = false;
        }

        protected void txtSponsorId_TextChanged(object sender, EventArgs e)
        {
            string sponsorId = txtSponsorId.Text.Trim();
            txtSponsorName.Text = "";
            litSponsorStatus.Text = "";

            if (string.IsNullOrEmpty(sponsorId)) return;

            string connStr = ConfigurationManager.ConnectionStrings["MlmDb"].ConnectionString;
            using (SqlConnection con = new SqlConnection(connStr))
            {
                string query = "SELECT FullName FROM Users WHERE Username = @SponsorId";
                using (SqlCommand cmd = new SqlCommand(query, con))
                {
                    cmd.Parameters.AddWithValue("@SponsorId", sponsorId);
                    try
                    {
                        con.Open();
                        object result = cmd.ExecuteScalar();
                        if (result != null)
                        {
                            txtSponsorName.Text = result.ToString();
                            litSponsorStatus.Text = "<i class='fas fa-check-circle status-icon success'></i>";
                        }
                        else
                        {
                            litSponsorStatus.Text = "<i class='fas fa-times-circle status-icon error'></i>";
                            lblSponsorError.Text = "Invalid Sponsor ID. Please double check.";
                            lblSponsorError.Visible = true;
                        }
                    }
                    catch (Exception ex)
                    {
                        lblSponsorError.Text = "Verification Error: " + ex.Message;
                        lblSponsorError.Visible = true;
                    }
                }
            }
        }

        protected void btnRegister_Click(object sender, EventArgs e)
        {
            lblModalMsg.Visible = false;

            // 1. Capture
            string sponsorId = txtSponsorId.Text.Trim();
            string sponsorName = txtSponsorName.Text.Trim();
            string fullName = txtFullName.Text.Trim();
            string dobStr = txtDob.Text.Trim();
            string gender = ddlGender.SelectedValue;
            string email = txtEmail.Text.Trim();
            string mobile = txtMobile.Text.Trim();
            string username = txtUsername.Text.Trim();
            string password = txtPassword.Text.Trim();
            string confirmPassword = txtConfirmPassword.Text.Trim();

            // 2. Basic Validate
            if (string.IsNullOrEmpty(fullName) || string.IsNullOrEmpty(email) || string.IsNullOrEmpty(username) || string.IsNullOrEmpty(password))
            {
                ShowError("Required details are missing.");
                return;
            }
            if (!chkTerms.Checked)
            {
                ShowError("Accept our Terms & Conditions to proceed.");
                return;
            }
            if (password != confirmPassword)
            {
                ShowError("Passwords do not match.");
                return;
            }

            // 3. DB Duplicate and Existence Checks
            string connStr = ConfigurationManager.ConnectionStrings["MlmDb"].ConnectionString;
            using (SqlConnection con = new SqlConnection(connStr))
            {
                string checkQuery = "SELECT COUNT(1) FROM Users WHERE Username = @Username OR Email = @Email";
                using (SqlCommand checkCmd = new SqlCommand(checkQuery, con))
                {
                    checkCmd.Parameters.AddWithValue("@Username", username);
                    checkCmd.Parameters.AddWithValue("@Email", email);
                    try
                    {
                        con.Open();
                        if (Convert.ToInt32(checkCmd.ExecuteScalar()) > 0)
                        {
                            ShowError("Username or Email already in use.");
                            return;
                        }
                    }
                    catch (Exception ex) { ShowError("DB Error: " + ex.Message); return; }
                }
            }

            // 4. Persist to temporary Session Storage for phase-2
            Session["Reg_SponsorId"] = sponsorId;
            Session["Reg_SponsorName"] = sponsorName;
            Session["Reg_FullName"] = fullName;
            Session["Reg_Dob"] = dobStr;
            Session["Reg_Gender"] = gender;
            Session["Reg_Email"] = email;
            Session["Reg_Mobile"] = mobile;
            Session["Reg_Username"] = username;
            Session["Reg_Password"] = password;

            // 5. Generate and dispatch OTP
            string otp = new Random().Next(100000, 999999).ToString();
            Session["Reg_OTP"] = otp;

            bool mailSent = SendOTPEmail(email, fullName, otp);

            // 6. Show Modal Popup & Trigger Countdown via Script Combination
            mvVerify.SetActiveView(vwCodeEntry);
            txtRegCode.Text = "";
            if (!mailSent)
            {
                ShowModalError("Wait! Security code not dispatched, but valid code is: " + otp + " (Developer Mode)");
            }
            
            string scriptCombo = string.Format("toggleRegModal(true); startRegResendCountdown('resendTimerReg', '{0}', 'timeLeftReg', 120);", lnkResendReg.ClientID);
            ScriptManager.RegisterStartupScript(this, this.GetType(), "ActivateVerificationFlow", scriptCombo, true);
        }

        protected void lnkResendReg_Click(object sender, EventArgs e)
        {
            lblModalMsg.Visible = false;
            string targetMail = Session["Reg_Email"] != null ? Session["Reg_Email"].ToString() : "";
            string targetName = Session["Reg_FullName"] != null ? Session["Reg_FullName"].ToString() : "User";

            if (string.IsNullOrEmpty(targetMail))
            {
                ShowModalError("Registration session expired. Re-enter form data.");
                ScriptManager.RegisterStartupScript(this, GetType(), "CloseOnExpire", "toggleRegModal(false);", true);
                return;
            }

            // Generate New Code
            string resendCode = new Random().Next(100000, 999999).ToString();
            Session["Reg_OTP"] = resendCode;

            bool isSent = SendOTPEmail(targetMail, targetName, resendCode);
            if (isSent) {
                ShowModalError("New verification code sent to: " + targetMail);
            } else {
                ShowModalError("Resend failed. Developers bypass code: " + resendCode);
            }

            // Re-trigger countdown
            string reScript = string.Format("startRegResendCountdown('resendTimerReg', '{0}', 'timeLeftReg', 120);", lnkResendReg.ClientID);
            ScriptManager.RegisterStartupScript(this, GetType(), "ReTriggerTimerReg", reScript, true);
        }

        protected void btnVerifyReg_Click(object sender, EventArgs e)
        {
            lblModalMsg.Visible = false;
            string inputCode = txtRegCode.Text.Trim();
            string validCode = Session["Reg_OTP"] != null ? Session["Reg_OTP"].ToString() : "";

            if (string.IsNullOrEmpty(validCode))
            {
                ShowModalError("Session expired, please restart registration.");
                return;
            }

            if (inputCode != validCode)
            {
                ShowModalError("Validation failed. Incorrect code provided.");
                return;
            }

            // CODE VERIFIED! Commit to Database!
            try
            {
                string connStr = ConfigurationManager.ConnectionStrings["MlmDb"].ConnectionString;
                using (SqlConnection con = new SqlConnection(connStr))
                {
                    con.Open();
                    string sql = @"INSERT INTO Users (SponsorId, SponsorName, FullName, Dob, Gender, Email, Mobile, Username, Password, CreatedAt) 
                                  VALUES (@SponsorId, @SponsorName, @FullName, @Dob, @Gender, @Email, @Mobile, @Username, @Password, GETDATE())";

                    using (SqlCommand cmd = new SqlCommand(sql, con))
                    {
                        cmd.Parameters.AddWithValue("@SponsorId", string.IsNullOrEmpty(Session["Reg_SponsorId"].ToString()) ? (object)DBNull.Value : Session["Reg_SponsorId"].ToString());
                        cmd.Parameters.AddWithValue("@SponsorName", string.IsNullOrEmpty(Session["Reg_SponsorName"].ToString()) ? (object)DBNull.Value : Session["Reg_SponsorName"].ToString());
                        cmd.Parameters.AddWithValue("@FullName", Session["Reg_FullName"].ToString());
                        cmd.Parameters.AddWithValue("@Dob", string.IsNullOrEmpty(Session["Reg_Dob"].ToString()) ? (object)DBNull.Value : Session["Reg_Dob"].ToString());
                        cmd.Parameters.AddWithValue("@Gender", string.IsNullOrEmpty(Session["Reg_Gender"].ToString()) ? (object)DBNull.Value : Session["Reg_Gender"].ToString());
                        cmd.Parameters.AddWithValue("@Email", Session["Reg_Email"].ToString());
                        cmd.Parameters.AddWithValue("@Mobile", string.IsNullOrEmpty(Session["Reg_Mobile"].ToString()) ? (object)DBNull.Value : Session["Reg_Mobile"].ToString());
                        cmd.Parameters.AddWithValue("@Username", Session["Reg_Username"].ToString());
                        cmd.Parameters.AddWithValue("@Password", Session["Reg_Password"].ToString());

                        cmd.ExecuteNonQuery();
                    }
                }

                // Done! Clear and advance
                Session.Remove("Reg_OTP");
                ClearForm();
                mvVerify.SetActiveView(vwRegSuccess);
            }
            catch (Exception ex)
            {
                ShowModalError("Critical Write Fault: " + ex.Message);
            }
        }

        private bool SendOTPEmail(string toEmail, string name, string code)
        {
            try
            {
                string fromEmail = ConfigHelper.GetConfig("SmtpFrom");
                string smtpPass = ConfigHelper.GetConfig("SmtpPass");
                string smtpHost = ConfigHelper.GetConfig("SmtpHost", "smtp.gmail.com");
                int smtpPort = int.Parse(ConfigHelper.GetConfig("SmtpPort", "587"));
                bool enableSsl = bool.Parse(ConfigHelper.GetConfig("SmtpEnableSsl", "TRUE"));

                MailMessage mail = new MailMessage(fromEmail, toEmail);
                mail.Subject = "Welcome to Kartify - Verify Account";
                mail.Body = string.Format("Greetings {0},\n\nWe are excited to build with you!\n\nUse the code below to verify your email:\nYOUR CODE: {1}\n\nThanks,\nKartify Onboarding Hub.", name, code);
                mail.IsBodyHtml = false;

                using (SmtpClient smtp = new SmtpClient(smtpHost, smtpPort))
                {
                    smtp.Credentials = new NetworkCredential(fromEmail, smtpPass);
                    smtp.EnableSsl = enableSsl;
                    smtp.Send(mail);
                }
                return true;
            }
            catch { return false; }
        }

        private void ShowError(string msg)
        {
            lblError.Text = msg;
            lblError.Visible = true;
        }

        private void ShowModalError(string msg)
        {
            lblModalMsg.Text = msg;
            lblModalMsg.Visible = true;
        }

        private void ClearForm()
        {
            txtSponsorId.Text = "";
            txtSponsorName.Text = "";
            litSponsorStatus.Text = "";
            txtFullName.Text = "";
            txtDob.Text = "";
            ddlGender.SelectedIndex = 0;
            txtEmail.Text = "";
            txtMobile.Text = "";
            txtUsername.Text = "";
            txtPassword.Text = "";
            txtConfirmPassword.Text = "";
            chkTerms.Checked = false;
        }
    }
}
