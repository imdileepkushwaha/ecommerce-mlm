using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Net;
using System.Net.Mail;

namespace ecommerce_mlm
{
    public partial class UserSettings : System.Web.UI.Page
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
                LoadUserAddresses();
                LoadUserBankDetails();
                CheckDeletionRequestStatus();
            }
        }

        private void LoadUserAddresses()
        {
            int uId = GetUserId();
            if (uId == 0) return;

            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    string q = "SELECT * FROM Addresses WHERE UserId = @uid ORDER BY IsDefault DESC, CreatedAt DESC";
                    SqlCommand cmd = new SqlCommand(q, con);
                    cmd.Parameters.AddWithValue("@uid", uId);
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    if (dt.Rows.Count > 0)
                    {
                        rptAddresses.DataSource = dt;
                        rptAddresses.DataBind();
                        rptAddresses.Visible = true;
                        pnlNoAddresses.Visible = false;
                    }
                    else
                    {
                        rptAddresses.Visible = false;
                        pnlNoAddresses.Visible = true;
                    }
                }
            }
            catch { }
        }

        private int GetUserId()
        {
            if (Session["Username"] == null) return 0;
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    SqlCommand cmd = new SqlCommand("SELECT Id FROM Users WHERE Username = @u", con);
                    cmd.Parameters.AddWithValue("@u", Session["Username"].ToString());
                    object obj = cmd.ExecuteScalar();
                    return obj != null ? Convert.ToInt32(obj) : 0;
                }
            }
            catch { return 0; }
        }

        // TRIGGER ADD POPUP
        protected void btnAddAddress_Click(object sender, EventArgs e)
        {
            hfSelectedAddrId.Value = "";
            txtFullName.Text = "";
            txtPhone.Text = "";
            txtStreet.Text = "";
            txtCity.Text = "";
            txtState.Text = "";
            txtZip.Text = "";
            ddlTag.SelectedIndex = 0;
            chkIsDefault.Checked = false;
            lblModalMsg.Text = "";
            litModalTitle.Text = "Add New Address";

            pnlAddressModal.Visible = true;
            pnlAddressModal.CssClass = "modal-overlay active"; // Reveal class
            ScriptManager.RegisterStartupScript(this, GetType(), "revealModal", "setTimeout(showDynamicModal, 10);", true);
        }

        // CLOSE POPUP
        protected void btnCloseModal_Click(object sender, EventArgs e)
        {
            pnlAddressModal.Visible = false;
        }

        // SAVE ADDRESS (ADD OR UPDATE)
        protected void btnSaveAddress_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtFullName.Text) || string.IsNullOrWhiteSpace(txtPhone.Text) || string.IsNullOrWhiteSpace(txtStreet.Text))
            {
                lblModalMsg.Text = "Please fill required fields.";
                return;
            }

            int uId = GetUserId();
            if (uId == 0) return;

            bool makeDefault = chkIsDefault.Checked;

            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();

                    // If user selected 'Set Default', remove default status from all other addresses first
                    if (makeDefault)
                    {
                        SqlCommand cmdReset = new SqlCommand("UPDATE Addresses SET IsDefault = 0 WHERE UserId = @uid", con);
                        cmdReset.Parameters.AddWithValue("@uid", uId);
                        cmdReset.ExecuteNonQuery();
                    }

                    string q = "";
                    if (string.IsNullOrEmpty(hfSelectedAddrId.Value))
                    {
                        // INSERT
                        q = @"INSERT INTO Addresses (UserId, FullName, PhoneNumber, StreetAddress, City, State, ZipCode, Tag, IsDefault, CreatedAt)
                              VALUES (@uid, @fn, @pn, @sa, @c, @s, @z, @t, @def, GETDATE())";
                    }
                    else
                    {
                        // UPDATE
                        q = @"UPDATE Addresses SET FullName=@fn, PhoneNumber=@pn, StreetAddress=@sa, City=@c, State=@s, ZipCode=@z, Tag=@t, IsDefault=@def
                              WHERE Id=@aid AND UserId=@uid";
                    }

                    SqlCommand cmd = new SqlCommand(q, con);
                    cmd.Parameters.AddWithValue("@uid", uId);
                    cmd.Parameters.AddWithValue("@fn", txtFullName.Text.Trim());
                    cmd.Parameters.AddWithValue("@pn", txtPhone.Text.Trim());
                    cmd.Parameters.AddWithValue("@sa", txtStreet.Text.Trim());
                    cmd.Parameters.AddWithValue("@c", txtCity.Text.Trim());
                    cmd.Parameters.AddWithValue("@s", txtState.Text.Trim());
                    cmd.Parameters.AddWithValue("@z", txtZip.Text.Trim());
                    cmd.Parameters.AddWithValue("@t", ddlTag.SelectedValue);
                    cmd.Parameters.AddWithValue("@def", makeDefault ? 1 : 0);

                    if (!string.IsNullOrEmpty(hfSelectedAddrId.Value))
                    {
                        cmd.Parameters.AddWithValue("@aid", hfSelectedAddrId.Value);
                    }

                    cmd.ExecuteNonQuery();
                }

                pnlAddressModal.Visible = false; // Close modal
                LoadUserAddresses(); // Refresh grid via UpdatePanel
            }
            catch (Exception ex)
            {
                lblModalMsg.Text = "Error saving: " + ex.Message;
            }
        }

        // REPEATER BUTTON COMMANDS (EDIT / DELETE / SET DEFAULT)
        protected void rptAddresses_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            string addrId = e.CommandArgument.ToString();
            int uId = GetUserId();

            if (e.CommandName == "EditAddr")
            {
                LoadAddressToEdit(addrId, uId);
            }
            else if (e.CommandName == "DeleteAddr")
            {
                DeleteAddress(addrId, uId);
            }
            else if (e.CommandName == "SetDefault")
            {
                SetDefaultAddress(addrId, uId);
            }
        }

        private void LoadAddressToEdit(string aid, int uid)
        {
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    SqlCommand cmd = new SqlCommand("SELECT * FROM Addresses WHERE Id=@aid AND UserId=@uid", con);
                    cmd.Parameters.AddWithValue("@aid", aid);
                    cmd.Parameters.AddWithValue("@uid", uid);
                    SqlDataReader dr = cmd.ExecuteReader();
                    if (dr.Read())
                    {
                        hfSelectedAddrId.Value = dr["Id"].ToString();
                        txtFullName.Text = dr["FullName"].ToString();
                        txtPhone.Text = dr["PhoneNumber"].ToString();
                        txtStreet.Text = dr["StreetAddress"].ToString();
                        txtCity.Text = dr["City"].ToString();
                        txtState.Text = dr["State"].ToString();
                        txtZip.Text = dr["ZipCode"].ToString();
                        
                        string tag = dr["Tag"].ToString().ToUpper();
                        if (ddlTag.Items.FindByValue(tag) != null) ddlTag.SelectedValue = tag;
                        
                        chkIsDefault.Checked = Convert.ToBoolean(dr["IsDefault"]);

                        litModalTitle.Text = "Edit Address";
                        lblModalMsg.Text = "";
                        pnlAddressModal.Visible = true;
                        pnlAddressModal.CssClass = "modal-overlay active";
                        ScriptManager.RegisterStartupScript(this, GetType(), "revealModal", "setTimeout(showDynamicModal, 10);", true);
                    }
                }
            }
            catch { }
        }

        private void DeleteAddress(string aid, int uid)
        {
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    SqlCommand cmd = new SqlCommand("DELETE FROM Addresses WHERE Id=@aid AND UserId=@uid", con);
                    cmd.Parameters.AddWithValue("@aid", aid);
                    cmd.Parameters.AddWithValue("@uid", uid);
                    cmd.ExecuteNonQuery();
                }
                LoadUserAddresses();
            }
            catch { }
        }

        private void SetDefaultAddress(string aid, int uid)
        {
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    // 1. Reset all
                    SqlCommand cmdReset = new SqlCommand("UPDATE Addresses SET IsDefault = 0 WHERE UserId = @uid", con);
                    cmdReset.Parameters.AddWithValue("@uid", uid);
                    cmdReset.ExecuteNonQuery();

                    // 2. Set specific one
                    SqlCommand cmdSet = new SqlCommand("UPDATE Addresses SET IsDefault = 1 WHERE Id = @aid AND UserId = @uid", con);
                    cmdSet.Parameters.AddWithValue("@aid", aid);
                    cmdSet.Parameters.AddWithValue("@uid", uid);
                    cmdSet.ExecuteNonQuery();
                }
                LoadUserAddresses();
            }
            catch { }
        }

        // SHOW PASSWORD MODAL
        protected void btnShowChangePassword_Click(object sender, EventArgs e)
        {
            txtCurrPass.Text = "";
            txtNewPass.Text = "";
            txtConfirmPass.Text = "";
            lblPassMsg.Text = "";
            pnlPasswordModal.Visible = true;
            pnlPasswordModal.CssClass = "modal-overlay active";
            ScriptManager.RegisterStartupScript(this, GetType(), "revealPassModal", "setTimeout(showDynamicModal, 10);", true);
        }

        // CLOSE PASSWORD MODAL
        protected void btnClosePassModal_Click(object sender, EventArgs e)
        {
            pnlPasswordModal.Visible = false;
        }

        // SAVE NEW PASSWORD
        protected void btnSavePassword_Click(object sender, EventArgs e)
        {
            string curr = txtCurrPass.Text.Trim();
            string npass = txtNewPass.Text.Trim();
            string cpass = txtConfirmPass.Text.Trim();

            if (string.IsNullOrEmpty(curr) || string.IsNullOrEmpty(npass))
            {
                lblPassMsg.Text = "All fields required.";
                return;
            }
            if (npass != cpass)
            {
                lblPassMsg.Text = "New passwords don't match.";
                return;
            }
            if (npass.Length < 6)
            {
                lblPassMsg.Text = "Must be at least 6 chars.";
                return;
            }

            string user = Session["Username"].ToString();

            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    // Verify old pass
                    SqlCommand cmdCheck = new SqlCommand("SELECT COUNT(*) FROM Users WHERE Username=@u AND Password=@p", con);
                    cmdCheck.Parameters.AddWithValue("@u", user);
                    cmdCheck.Parameters.AddWithValue("@p", curr);
                    int count = (int)cmdCheck.ExecuteScalar();

                    if (count > 0)
                    {
                        // Update to new
                        SqlCommand cmdUpd = new SqlCommand("UPDATE Users SET Password=@new WHERE Username=@u", con);
                        cmdUpd.Parameters.AddWithValue("@new", npass);
                        cmdUpd.Parameters.AddWithValue("@u", user);
                        cmdUpd.ExecuteNonQuery();

                        // Success Close
                        pnlPasswordModal.Visible = false;
                        ScriptManager.RegisterStartupScript(this, GetType(), "PassSuccess", "alert('Password updated successfully!');", true);
                    }
                    else
                    {
                        lblPassMsg.Text = "Incorrect current password.";
                    }
                }
            }
            catch (Exception ex)
            {
                lblPassMsg.Text = "System error occurred.";
            }
        }

        private void CheckDeletionRequestStatus()
        {
            int uid = GetUserId();
            if (uid == 0) return;

            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM AccountDeleteRequests WHERE UserId=@uid AND Status='PENDING'", con);
                    cmd.Parameters.AddWithValue("@uid", uid);
                    int count = (int)cmd.ExecuteScalar();
                    
                    if (count > 0)
                    {
                        pnlNoRequest.Visible = false;
                        pnlPendingRequest.Visible = true;
                    }
                    else
                    {
                        pnlNoRequest.Visible = true;
                        pnlPendingRequest.Visible = false;
                    }
                }
            }
            catch { }
        }

        // SHOW DELETE MODAL
        protected void btnTriggerDelete_Click(object sender, EventArgs e)
        {
            txtDeleteConfirm.Text = "";
            lblDelMsg.Text = "";
            pnlDeleteModal.Visible = true;
            pnlDeleteModal.CssClass = "modal-overlay active";
            ScriptManager.RegisterStartupScript(this, GetType(), "revealDelModal", "setTimeout(showDynamicModal, 10);", true);
        }

        // CLOSE DELETE MODAL
        protected void btnCloseDelModal_Click(object sender, EventArgs e)
        {
            pnlDeleteModal.Visible = false;
        }

        // INSTEAD OF DELETE, WE INSERT A PENDING REQUEST
        protected void btnFinalDelete_Click(object sender, EventArgs e)
        {
            if (txtDeleteConfirm.Text.Trim().ToUpper() != "DELETE")
            {
                lblDelMsg.Text = "Verification failed. Please type exactly 'DELETE'.";
                return;
            }

            int uid = GetUserId();

            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    // Insert new pending request
                    SqlCommand cmdReq = new SqlCommand("INSERT INTO AccountDeleteRequests (UserId, RequestDate, Status) VALUES (@uid, GETDATE(), 'PENDING')", con);
                    cmdReq.Parameters.AddWithValue("@uid", uid);
                    cmdReq.ExecuteNonQuery();
                }
                pnlDeleteModal.Visible = false;
                CheckDeletionRequestStatus(); // Refresh view toggle
                ScriptManager.RegisterStartupScript(this, GetType(), "ReqSuccess", "alert('Success! Deletion request has been sent to Admin.');", true);
            }
            catch (Exception ex)
            {
                lblDelMsg.Text = "Operational constraint: An error occurred creating request.";
            }
        }

        // CANCEL AN ACTIVE REQUEST
        protected void btnCancelReq_Click(object sender, EventArgs e)
        {
            int uid = GetUserId();
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    SqlCommand cmd = new SqlCommand("UPDATE AccountDeleteRequests SET Status='CANCELLED' WHERE UserId=@uid AND Status='PENDING'", con);
                    cmd.Parameters.AddWithValue("@uid", uid);
                    cmd.ExecuteNonQuery();
                }
                CheckDeletionRequestStatus();
                ScriptManager.RegisterStartupScript(this, GetType(), "CancelSuccess", "alert('Deletion request cancelled successfully.');", true);
            }
            catch { }
        }

        protected void btnLogout_Click(object sender, EventArgs e)
        {
            Session.Clear();
            Session.Abandon();
            HttpCookie authCookie = new HttpCookie(".ASPXAUTH", "");
            authCookie.Expires = DateTime.Now.AddYears(-1);
            Response.Cookies.Add(authCookie);
            Response.Redirect("Login.aspx");
        }
        // ==========================================
        // BANK DETAILS MANAGEMENT
        // ==========================================
        private void LoadUserBankDetails()
        {
            int uid = GetUserId();
            if (uid == 0) return;

            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    string q = "SELECT TOP 1 * FROM UserBankDetails WHERE UserId = @uid";
                    SqlCommand cmd = new SqlCommand(q, con);
                    cmd.Parameters.AddWithValue("@uid", uid);
                    SqlDataReader dr = cmd.ExecuteReader();
                    if (dr.Read())
                    {
                        // Data exists
                        pnlNoBank.Visible = false;
                        pnlBankDisplay.Visible = true;
                        lblDispBankName.Text = dr["BankName"].ToString();
                        lblDispAccNum.Text = "•••• •••• " + dr["AccountNumber"].ToString().Substring(Math.Max(0, dr["AccountNumber"].ToString().Length - 4));
                        lblDispAccHolder.Text = dr["AccountHolderName"].ToString();
                        btnActionBank.Text = "<i class='fas fa-edit'></i> Update";
                    }
                    else
                    {
                        // No Bank Account saved
                        pnlNoBank.Visible = true;
                        pnlBankDisplay.Visible = false;
                        btnActionBank.Text = "<i class='fas fa-plus'></i> Add Account";
                    }
                }
            }
            catch { }
        }

        protected void btnActionBank_Click(object sender, EventArgs e)
        {
            // Reset Visibility
            pnlBankEntryView.Visible = true;
            pnlBankOTPView.Visible = false;
            btnSendBankOTP.Visible = true;
            btnFinalizeBankUpdate.Visible = false;
            txtBankOTP.Text = "";
            lblBankOTPErr.Text = "";

            // Open Modal and pre-fill if exists
            int uid = GetUserId();
            txtBankHolderName.Text = "";
            txtBankName.Text = "";
            txtAccountNumber.Text = "";
            txtIFSC.Text = "";
            txtBranch.Text = "";

            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    SqlCommand cmd = new SqlCommand("SELECT TOP 1 * FROM UserBankDetails WHERE UserId = @uid", con);
                    cmd.Parameters.AddWithValue("@uid", uid);
                    SqlDataReader dr = cmd.ExecuteReader();
                    if (dr.Read())
                    {
                        txtBankHolderName.Text = dr["AccountHolderName"].ToString();
                        txtBankName.Text = dr["BankName"].ToString();
                        txtAccountNumber.Text = dr["AccountNumber"].ToString();
                        txtIFSC.Text = dr["IFSCCode"].ToString();
                        txtBranch.Text = dr["BranchName"].ToString();
                    }
                }
            }
            catch { }

            pnlBankModal.Visible = true;
            pnlBankModal.CssClass = "modal-overlay active";
            ScriptManager.RegisterStartupScript(this, GetType(), "revealBankModal", "setTimeout(showDynamicModal, 10);", true);
        }

        protected void btnCloseBankModal_Click(object sender, EventArgs e)
        {
            pnlBankModal.Visible = false;
        }

        // STEP 1: GENERATE OTP & EMAIL USER
        protected void btnSendBankOTP_Click(object sender, EventArgs e)
        {
            string holder = txtBankHolderName.Text.Trim();
            string bank = txtBankName.Text.Trim();
            string num = txtAccountNumber.Text.Trim();
            string ifsc = txtIFSC.Text.Trim();

            if (string.IsNullOrEmpty(holder) || string.IsNullOrEmpty(num) || string.IsNullOrEmpty(bank) || string.IsNullOrEmpty(ifsc))
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "Alert", "alert('Please fill all mandatory fields.');", true);
                return;
            }

            // 1. Fetch Target Email
            string userEmail = GetUserEmail();
            if (string.IsNullOrEmpty(userEmail))
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "Alert", "alert('Failed to retrieve associated account email.');", true);
                return;
            }

            // 2. Generate Random 6-digit Code
            Random r = new Random();
            string generatedOTP = r.Next(100000, 999999).ToString();

            // 3. Try Send Mail
            bool isSent = SendBankSecurityOTP(userEmail, generatedOTP);
            if (isSent)
            {
                // Store secure reference in viewstate (or better, ephemeral session bound to this attempt)
                ViewState["SecureBankOTP"] = generatedOTP;

                // Switch to Verification View
                pnlBankEntryView.Visible = false;
                pnlBankOTPView.Visible = true;
                btnSendBankOTP.Visible = false;
                btnFinalizeBankUpdate.Visible = true;
                
                // Persist dynamic Modal visible state through postback reload
                pnlBankModal.CssClass = "modal-overlay active";
            }
            else
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "Alert", "alert('Error connecting to mailing subsystem. Please try again later.');", true);
            }
        }

        // STEP 2: VERIFY OTP & COMMIT TO DATABASE
        protected void btnFinalizeBankUpdate_Click(object sender, EventArgs e)
        {
            string userProvided = txtBankOTP.Text.Trim();
            string savedRef = ViewState["SecureBankOTP"] != null ? ViewState["SecureBankOTP"].ToString() : "";

            if (string.IsNullOrEmpty(userProvided) || userProvided != savedRef)
            {
                lblBankOTPErr.Text = "Invalid authorization code. Please re-enter.";
                pnlBankModal.CssClass = "modal-overlay active"; // Ensure it stays open
                return;
            }

            // OTP MATCHED -> PERFORM FINAL DB UPSERT
            int uid = GetUserId();
            string holder = txtBankHolderName.Text.Trim();
            string bank = txtBankName.Text.Trim();
            string num = txtAccountNumber.Text.Trim();
            string ifsc = txtIFSC.Text.Trim();
            string br = txtBranch.Text.Trim();

            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    SqlCommand checkCmd = new SqlCommand("SELECT COUNT(*) FROM UserBankDetails WHERE UserId = @u", con);
                    checkCmd.Parameters.AddWithValue("@u", uid);
                    int exists = (int)checkCmd.ExecuteScalar();

                    string q = exists > 0 
                        ? "UPDATE UserBankDetails SET AccountHolderName=@h, AccountNumber=@n, BankName=@b, IFSCCode=@i, BranchName=@br, UpdatedAt=GETDATE() WHERE UserId=@u"
                        : "INSERT INTO UserBankDetails (UserId, AccountHolderName, AccountNumber, BankName, IFSCCode, BranchName) VALUES (@u, @h, @n, @b, @i, @br)";

                    SqlCommand cmd = new SqlCommand(q, con);
                    cmd.Parameters.AddWithValue("@u", uid);
                    cmd.Parameters.AddWithValue("@h", holder);
                    cmd.Parameters.AddWithValue("@n", num);
                    cmd.Parameters.AddWithValue("@b", bank);
                    cmd.Parameters.AddWithValue("@i", ifsc);
                    cmd.Parameters.AddWithValue("@br", br);
                    cmd.ExecuteNonQuery();
                }

                // Clear reference and Close
                ViewState["SecureBankOTP"] = null;
                pnlBankModal.Visible = false;
                LoadUserBankDetails(); // Refresh visually
                ScriptManager.RegisterStartupScript(this, GetType(), "Success", "alert('Security authorization passed! Bank account details updated.');", true);
            }
            catch (Exception ex)
            {
                ScriptManager.RegisterStartupScript(this, GetType(), "Error", "alert('Unexpected error: " + ex.Message.Replace("'","") + "');", true);
            }
        }

        // -----------------------------------------
        // UTILITY HELPERS FOR SECURITY
        // -----------------------------------------
        private string GetUserEmail()
        {
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    SqlCommand cmd = new SqlCommand("SELECT Email FROM Users WHERE Id = @uid", con);
                    cmd.Parameters.AddWithValue("@uid", GetUserId());
                    object o = cmd.ExecuteScalar();
                    return o != null ? o.ToString() : "";
                }
            }
            catch { return ""; }
        }

        private bool SendBankSecurityOTP(string target, string code)
        {
            try
            {
                string fromMail = ConfigHelper.GetConfig("SmtpFrom");
                string pass = ConfigHelper.GetConfig("SmtpPass");
                string host = ConfigHelper.GetConfig("SmtpHost", "smtp.gmail.com");
                int port = int.Parse(ConfigHelper.GetConfig("SmtpPort", "587"));
                bool ssl = bool.Parse(ConfigHelper.GetConfig("SmtpEnableSsl", "TRUE"));

                MailMessage m = new MailMessage(fromMail, target);
                m.Subject = "CRITICAL: Bank Account Action Authentication";
                m.Body = "Security Authorization Needed\n\nA request was logged to link or modify a financial institution routing within your dashboard.\n\nYour Validation Token: " + code + "\n\nDo not share this.";
                m.IsBodyHtml = false;

                using (SmtpClient cl = new SmtpClient(host, port))
                {
                    cl.Credentials = new NetworkCredential(fromMail, pass);
                    cl.EnableSsl = ssl;
                    cl.Send(m);
                }
                return true;
            }
            catch { return false; }
        }
    }
}
