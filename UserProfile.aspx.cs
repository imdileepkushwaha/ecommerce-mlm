using System;
using System.Configuration;
using System.Data.SqlClient;
using System.IO;
using System.Net;
using System.Net.Mail;
using System.Web;
using System.Web.UI;

namespace ecommerce_mlm
{
    public partial class UserProfile : System.Web.UI.Page
    {
        string strcon = ConfigurationManager.ConnectionStrings["MlmDb"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["Username"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            if (!IsPostBack)
            {
                LoadProfileData();
            }
        }

        private void LoadProfileData()
        {
            string user = Session["Username"].ToString();
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    string q = "SELECT * FROM Users WHERE Username = @u";
                    using (SqlCommand cmd = new SqlCommand(q, con))
                    {
                        cmd.Parameters.AddWithValue("@u", user);
                        con.Open();
                        using (SqlDataReader dr = cmd.ExecuteReader())
                        {
                            if (dr.Read())
                            {
                                string fName = dr["FullName"].ToString();
                                string email = dr["Email"].ToString();
                                string mobile = dr["Mobile"].ToString();
                                string dob = dr["Dob"].ToString();
                                string gender = dr["Gender"].ToString();
                                string sId = dr["SponsorId"].ToString();
                                string sName = dr["SponsorName"].ToString();
                                string pImg = dr["ProfileImage"] != DBNull.Value ? dr["ProfileImage"].ToString() : "";
                                string joinedStr = dr["CreatedAt"] != DBNull.Value ? Convert.ToDateTime(dr["CreatedAt"]).ToString("MMM yyyy") : DateTime.Now.ToString("MMM yyyy");
                                
                                bool isEVerified = false;
                                if (dr.GetOrdinal("IsEmailVerified") >= 0) isEVerified = dr["IsEmailVerified"] != DBNull.Value && Convert.ToBoolean(dr["IsEmailVerified"]);
                                
                                bool isMVerified = false;
                                if (dr.GetOrdinal("IsMobileVerified") >= 0) isMVerified = dr["IsMobileVerified"] != DBNull.Value && Convert.ToBoolean(dr["IsMobileVerified"]);

                                // Bind Hero Display
                                litFullNameHero.Text = fName;
                                litUsernameHero.Text = user;
                                litJoinedDate.Text = joinedStr;

                                // Bind Read Only Detail View
                                litReadUsername.Text = user;
                                litReadSponsor.Text = string.Format("{0} ({1})", string.IsNullOrEmpty(sName) ? "Direct" : sName, string.IsNullOrEmpty(sId) ? "N/A" : sId);
                                litReadFullName.Text = string.IsNullOrEmpty(fName) ? "---" : fName;
                                litReadEmail.Text = string.IsNullOrEmpty(email) ? "---" : email;
                                litReadMobile.Text = string.IsNullOrEmpty(mobile) ? "---" : mobile;
                                litReadDob.Text = string.IsNullOrEmpty(dob) ? "Not Set" : dob;
                                litReadGender.Text = string.IsNullOrEmpty(gender) ? "Not Set" : gender;

                                // Verification Badges in View
                                if (isEVerified)
                                    litEmailVerifyBadge.Text = "<span class='badge-verified'><i class='fas fa-check-circle'></i> Verified</span>";
                                else
                                    litEmailVerifyBadge.Text = "";

                                if (isMVerified)
                                    litMobileVerifyBadge.Text = "<span class='badge-verified'><i class='fas fa-check-circle'></i> Verified</span>";
                                else
                                    litMobileVerifyBadge.Text = "";

                                // Bind Form Inputs
                                txtUsername.Text = user;
                                txtSponsorId.Text = string.IsNullOrEmpty(sId) ? "N/A" : sId;
                                txtSponsorName.Text = string.IsNullOrEmpty(sName) ? "Direct" : sName;
                                txtFullName.Text = fName;
                                txtEmail.Text = email;
                                txtMobile.Text = mobile;
                                txtDob.Text = dob;
                                
                                if (ddlGender.Items.FindByValue(gender) != null)
                                    ddlGender.SelectedValue = gender;

                                // Cache originally verified values on textboxes for instant client comparison
                                txtEmail.Attributes["data-original"] = email;
                                txtEmail.Attributes["data-verified"] = isEVerified.ToString().ToLower(); // 'true' or 'false'
                                
                                txtMobile.Attributes["data-original"] = mobile;
                                txtMobile.Attributes["data-verified"] = isMVerified.ToString().ToLower();

                                // Toggle styles instead of server-side Visible so JS can see them
                                if (isEVerified)
                                {
                                    lnkVerifyEmail.Style["display"] = "none";
                                    lblEmailVerified.Style["display"] = "inline-block";
                                }
                                else
                                {
                                    lnkVerifyEmail.Style["display"] = "inline-block";
                                    lblEmailVerified.Style["display"] = "none";
                                }

                                if (isMVerified)
                                {
                                    lnkVerifyMobile.Style["display"] = "none";
                                    lblMobileVerified.Style["display"] = "inline-block";
                                }
                                else
                                {
                                    lnkVerifyMobile.Style["display"] = "inline-block";
                                    lblMobileVerified.Style["display"] = "none";
                                }

                                // Image logic
                                bool exists = false;
                                try { if(!string.IsNullOrWhiteSpace(pImg)) exists = File.Exists(Server.MapPath(pImg)); } catch {}

                                if (exists)
                                    litLargeAvatar.Text = string.Format("<img src=\"{0}\" alt=\"Profile\" />", ResolveUrl(pImg));
                                else
                                    litLargeAvatar.Text = string.Format("<div class=\"avatar-initials\">{0}</div>", GetInitials(fName));
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ShowAlert("danger", "Error loading profile: " + ex.Message);
            }
        }

        protected void btnUpdateProfile_Click(object sender, EventArgs e)
        {
            string user = Session["Username"].ToString();
            string fName = txtFullName.Text.Trim();
            string email = txtEmail.Text.Trim();
            string mobile = txtMobile.Text.Trim();
            string dob = txtDob.Text.Trim();
            string gender = ddlGender.SelectedValue;

            if (string.IsNullOrEmpty(fName) || string.IsNullOrEmpty(email))
            {
                ShowAlert("danger", "Full Name and Email are required fields.");
                return;
            }

            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    // Important: If email or mobile changes, reset their verified flag to false for security!
                    string q = "UPDATE Users SET FullName=@f, Email=@e, Mobile=@m, Dob=@d, Gender=@g WHERE Username=@u";
                    using (SqlCommand cmd = new SqlCommand(q, con))
                    {
                        cmd.Parameters.AddWithValue("@f", fName);
                        cmd.Parameters.AddWithValue("@e", email);
                        cmd.Parameters.AddWithValue("@m", mobile);
                        cmd.Parameters.AddWithValue("@d", dob);
                        cmd.Parameters.AddWithValue("@g", gender);
                        cmd.Parameters.AddWithValue("@u", user);
                        
                        con.Open();
                        int res = cmd.ExecuteNonQuery();
                        if (res > 0)
                        {
                            Session["FullName"] = fName; 
                            ShowAlert("success", "Profile updated successfully!");
                            LoadProfileData(); 
                        }
                        else
                        {
                            ShowAlert("danger", "No record updated.");
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ShowAlert("danger", "Update failed: " + ex.Message);
            }
        }

        protected void lnkVerifyEmail_Click(object sender, EventArgs e)
        {
            string em = txtEmail.Text.Trim();
            if(string.IsNullOrEmpty(em)) { ShowAlert("danger", "Please enter email first."); return; }

            string otp = new Random().Next(100000, 999999).ToString();
            Session["UserOTP"] = otp;
            Session["OTPType"] = "Email";

            bool isSent = SendOTPEmail(em, litFullNameHero.Text, otp);
            if(isSent) {
                TriggerOTPModal(true);
            } else {
                ShowAlert("danger", "SMTP Delivery failed. Dev bypass: " + otp);
                TriggerOTPModal(true);
            }
        }

        protected void lnkVerifyMobile_Click(object sender, EventArgs e)
        {
            string mob = txtMobile.Text.Trim();
            if(string.IsNullOrEmpty(mob)) { ShowAlert("danger", "Please enter mobile number."); return; }
            
            string otp = new Random().Next(100000, 999999).ToString();
            Session["UserOTP"] = otp;
            Session["OTPType"] = "Mobile";

            // Simulating SMS by sending fallback email to the main account
            SendOTPEmail(txtEmail.Text.Trim(), litFullNameHero.Text, otp + " (Sent via Mobile Verification)");
            
            TriggerOTPModal(true);
        }

        protected void btnConfirmOtp_Click(object sender, EventArgs e)
        {
            string entered = txtOtpInput.Text.Trim();
            string actual = Session["UserOTP"] != null ? Session["UserOTP"].ToString() : "";

            if(string.IsNullOrEmpty(actual)) { ShowAlert("danger", "Session expired. Retry verification."); return; }

            if(entered == actual)
            {
                string type = Session["OTPType"].ToString();
                string user = Session["Username"].ToString();
                string colName = type == "Email" ? "IsEmailVerified" : "IsMobileVerified";

                try
                {
                    using (SqlConnection con = new SqlConnection(strcon))
                    {
                        string q = string.Format("UPDATE Users SET {0} = 1 WHERE Username = @u", colName);
                        using (SqlCommand cmd = new SqlCommand(q, con))
                        {
                            cmd.Parameters.AddWithValue("@u", user);
                            con.Open();
                            cmd.ExecuteNonQuery();
                        }
                    }
                    
                    Session.Remove("UserOTP");
                    Session.Remove("OTPType");
                    txtOtpInput.Text = "";

                    ShowAlert("success", string.Format("{0} successfully verified!", type));
                    TriggerOTPModal(false);
                    LoadProfileData();
                }
                catch (Exception ex) { ShowAlert("danger", "DB update failed: " + ex.Message); }
            }
            else
            {
                // Force keep modal open if incorrect
                string script = "document.getElementById('otpMsg').innerText = 'Incorrect verification code. Please try again.'; toggleOtpModal(true);";
                ScriptManager.RegisterStartupScript(this, GetType(), "KeepModalOpen", script, true);
            }
        }

        protected void btnTriggerUpload_Click(object sender, EventArgs e)
        {
            if (fuProfilePic.HasFile)
            {
                try
                {
                    string user = Session["Username"].ToString();
                    string ext = Path.GetExtension(fuProfilePic.FileName).ToLower();
                    string[] allowed = { ".jpg", ".jpeg", ".png", ".gif", ".webp" };
                    
                    bool isOk = false;
                    foreach (string a in allowed) { if(a == ext) isOk = true; }
                    if (!isOk) { ShowAlert("danger", "Invalid format. Use JPG, PNG, WEBP."); return; }

                    string filename = "usr_" + user + "_" + DateTime.Now.Ticks.ToString() + ext;
                    string virtPath = "~/assets/images/profiles/" + filename;
                    string physPath = Server.MapPath(virtPath);

                    fuProfilePic.SaveAs(physPath);

                    using (SqlConnection con = new SqlConnection(strcon))
                    {
                        string q = "UPDATE Users SET ProfileImage = @img WHERE Username = @u";
                        using (SqlCommand cmd = new SqlCommand(q, con))
                        {
                            cmd.Parameters.AddWithValue("@img", virtPath);
                            cmd.Parameters.AddWithValue("@u", user);
                            con.Open();
                            cmd.ExecuteNonQuery();
                        }
                    }
                    ShowAlert("success", "Profile picture changed!");
                    LoadProfileData();
                }
                catch (Exception ex) { ShowAlert("danger", "Upload failed: " + ex.Message); }
            }
        }

        private bool SendOTPEmail(string toEmail, string name, string code)
        {
            try
            {
                string fromEmail = ConfigurationManager.AppSettings["SmtpFrom"];
                string smtpPass = ConfigurationManager.AppSettings["SmtpPass"];
                string smtpHost = ConfigurationManager.AppSettings["SmtpHost"];
                int smtpPort = int.Parse(ConfigurationManager.AppSettings["SmtpPort"]);
                bool enableSsl = bool.Parse(ConfigurationManager.AppSettings["SmtpEnableSsl"]);

                MailMessage mail = new MailMessage(fromEmail, toEmail);
                mail.Subject = "Action Required: Account Identity Verification";
                mail.Body = string.Format("Hello {0},\n\nA request was made to verify this contact channel.\n\nCODE: {1}\n\nKindly input this in the dashboard.", name, code);
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

        private void TriggerOTPModal(bool show)
        {
            string s = string.Format("toggleOtpModal({0});", show.ToString().ToLower());
            ScriptManager.RegisterStartupScript(this, GetType(), "OTPModalToggle", s, true);
        }

        private string GetInitials(string name)
        {
            if (string.IsNullOrWhiteSpace(name)) return "U";
            var words = name.Trim().Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
            if (words.Length == 0) return "U";
            if (words.Length == 1) return words[0].Length > 1 ? words[0].Substring(0, 2).ToUpper() : words[0][0].ToString().ToUpper();
            return (words[0][0].ToString() + words[words.Length - 1][0].ToString()).ToUpper();
        }

        private void ShowAlert(string type, string msg)
        {
            pnlStatus.Visible = true;
            string icon = type == "success" ? "<i class='fas fa-check-circle'></i> " : "<i class='fas fa-exclamation-circle'></i> ";
            pnlStatus.Controls.Clear(); // Clear any old alerts
            pnlStatus.Controls.Add(new LiteralControl(string.Format("<div class=\"alert-toast alert-{0}\">{1} {2}</div>", type, icon, msg)));
        }
    }
}
