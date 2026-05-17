using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Security.Cryptography;
using System.Text;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace EcommerceWebsite
{
    public partial class SellerSettings : System.Web.UI.Page
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
                
                // Dynamically build public storefront URL
                lnkPublicStore.NavigateUrl = "~/SellerStore.aspx?id=" + Session["SellerId"].ToString();

                LoadSettings();
            }
        }

        private void LoadSettings()
        {
            try
            {
                int sellerId = Convert.ToInt32(Session["SellerId"]);

                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    string query = "SELECT NotifyEmail, NotifySms, DeletionStatus, DeactivationDate FROM SellerUsers WHERE Id = @id";
                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        cmd.Parameters.AddWithValue("@id", sellerId);
                        using (SqlDataReader dr = cmd.ExecuteReader())
                        {
                            if (dr.Read())
                            {
                                // 1. Load Notifications
                                chkNotifyEmail.Checked = dr["NotifyEmail"] != DBNull.Value ? Convert.ToBoolean(dr["NotifyEmail"]) : false;
                                chkNotifySms.Checked = dr["NotifySms"] != DBNull.Value ? Convert.ToBoolean(dr["NotifySms"]) : false;

                                // 2. Load Deletion Status Workflow
                                string delStatus = dr["DeletionStatus"] != DBNull.Value ? dr["DeletionStatus"].ToString().Trim() : "None";
                                if (delStatus.Equals("Pending", StringComparison.OrdinalIgnoreCase))
                                {
                                    pnlDeleteActive.Visible = false;
                                    pnlDeletePending.Visible = true;
                                    
                                    DateTime deacDt = dr["DeactivationDate"] != DBNull.Value ? Convert.ToDateTime(dr["DeactivationDate"]) : DateTime.Now;
                                    litDeleteDate.Text = deacDt.ToString("dd MMM yyyy - hh:mm tt");
                                }
                                else
                                {
                                    pnlDeleteActive.Visible = true;
                                    pnlDeletePending.Visible = false;
                                    txtDeleteConfirm.Text = "";
                                }
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ShowAlert("An error occurred while loading settings: " + ex.Message, false);
            }
        }

        // ==========================================
        // MODAL STATE TRIGGER BUTTONS
        // ==========================================

        protected void btnOpenPassModal_Click(object sender, EventArgs e)
        {
            HideAllModals();
            pnlPasswordModal.Visible = true;
            txtCurrentPassword.Focus();
        }

        protected void btnOpenNotifyModal_Click(object sender, EventArgs e)
        {
            HideAllModals();
            LoadSettings(); // Sync current state
            pnlNotificationModal.Visible = true;
        }

        protected void btnOpenDeleteModal_Click(object sender, EventArgs e)
        {
            HideAllModals();
            lblDeleteError.Visible = false;
            LoadSettings(); // Sync current state
            pnlDeleteModal.Visible = true;
        }

        protected void btnShipCard_Click(object sender, EventArgs e)
        {
            HideAllModals();
            LinkButton btn = sender as LinkButton;
            if (btn != null)
            {
                litFulfilmentHeader.Text = btn.CommandArgument;
            }
            pnlFulfilmentModal.Visible = true;
        }

        protected void btnCloseModal_Click(object sender, EventArgs e)
        {
            HideAllModals();
        }

        private void HideAllModals()
        {
            pnlPasswordModal.Visible = false;
            pnlNotificationModal.Visible = false;
            pnlDeleteModal.Visible = false;
            pnlFulfilmentModal.Visible = false;
        }

        // ==========================================
        // SUBMIT & UPDATE LOGICS
        // ==========================================

        protected void btnUpdatePassword_Click(object sender, EventArgs e)
        {
            // Keep password modal visible to show validation messages
            pnlPasswordModal.Visible = true;

            string curPass = txtCurrentPassword.Text;
            string newPass = txtNewPassword.Text;
            string confPass = txtConfirmPassword.Text;

            if (string.IsNullOrEmpty(curPass) || string.IsNullOrEmpty(newPass) || string.IsNullOrEmpty(confPass))
            {
                ShowAlert("⚠️ All password fields are required.", false);
                return;
            }

            if (newPass.Length < 6)
            {
                ShowAlert("⚠️ New password must be at least 6 characters long.", false);
                return;
            }

            if (newPass != confPass)
            {
                ShowAlert("⚠️ New passwords do not match. Please verify.", false);
                return;
            }

            try
            {
                int sellerId = Convert.ToInt32(Session["SellerId"]);
                string hashedCur = ComputeSha256Hash(curPass);

                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    
                    // Verify old password
                    string verifySql = "SELECT COUNT(*) FROM SellerUsers WHERE Id = @id AND PasswordHash = @hash";
                    using (SqlCommand cmdV = new SqlCommand(verifySql, con))
                    {
                        cmdV.Parameters.AddWithValue("@id", sellerId);
                        cmdV.Parameters.AddWithValue("@hash", hashedCur);
                        int count = (int)cmdV.ExecuteScalar();
                        if (count == 0)
                        {
                            ShowAlert("⚠️ Current password incorrect. Authorization failed.", false);
                            return;
                        }
                    }

                    // Update to new password
                    string hashedNew = ComputeSha256Hash(newPass);
                    string updateSql = "UPDATE SellerUsers SET PasswordHash = @newHash, UpdatedAt = GETDATE() WHERE Id = @id";
                    using (SqlCommand cmdU = new SqlCommand(updateSql, con))
                    {
                        cmdU.Parameters.AddWithValue("@newHash", hashedNew);
                        cmdU.Parameters.AddWithValue("@id", sellerId);
                        cmdU.ExecuteNonQuery();
                    }
                }

                // Success cleanup
                txtCurrentPassword.Text = "";
                txtNewPassword.Text = "";
                txtConfirmPassword.Text = "";
                pnlPasswordModal.Visible = false; // Hide on success

                ShowAlert("✅ Access password successfully rotated and updated!", true);
            }
            catch (Exception ex)
            {
                ShowAlert("⚠️ Password synchronization failed: " + ex.Message, false);
            }
        }

        protected void btnSavePreferences_Click(object sender, EventArgs e)
        {
            try
            {
                int sellerId = Convert.ToInt32(Session["SellerId"]);
                bool emailPref = chkNotifyEmail.Checked;
                bool smsPref = chkNotifySms.Checked;

                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    string query = "UPDATE SellerUsers SET NotifyEmail = @email, NotifySms = @sms, UpdatedAt = GETDATE() WHERE Id = @id";
                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        cmd.Parameters.AddWithValue("@email", emailPref);
                        cmd.Parameters.AddWithValue("@sms", smsPref);
                        cmd.Parameters.AddWithValue("@id", sellerId);
                        cmd.ExecuteNonQuery();
                    }
                }

                pnlNotificationModal.Visible = false; // Hide on success
                ShowAlert("✅ Notification communication preferences saved!", true);
            }
            catch (Exception ex)
            {
                pnlNotificationModal.Visible = true; // Keep visible to show error
                ShowAlert("⚠️ Failed to update preferences: " + ex.Message, false);
            }
        }

        protected void btnRequestDelete_Click(object sender, EventArgs e)
        {
            pnlDeleteModal.Visible = true; // Keep danger zone modal visible
            string confirmText = txtDeleteConfirm.Text.Trim();
            lblDeleteError.Visible = false;

            if (!confirmText.Equals("DELETE", StringComparison.Ordinal))
            {
                lblDeleteError.Visible = true;
                lblDeleteError.Text = "⚠️ Type 'DELETE' in uppercase to authorize deactivation request.";
                return;
            }

            try
            {
                int sellerId = Convert.ToInt32(Session["SellerId"]);

                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    string query = "UPDATE SellerUsers SET DeletionStatus = 'Pending', DeactivationDate = GETDATE(), UpdatedAt = GETDATE() WHERE Id = @id";
                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        cmd.Parameters.AddWithValue("@id", sellerId);
                        cmd.ExecuteNonQuery();
                    }
                }

                LoadSettings();
                lblDeleteError.Visible = false;
                pnlDeleteModal.Visible = false; // Hide on success deactivation file
                ShowAlert("✅ Account deactivation request successfully submitted. Pending administrative verification.", true);
            }
            catch (Exception ex)
            {
                lblDeleteError.Visible = true;
                lblDeleteError.Text = "⚠️ Account deletion request failed: " + ex.Message;
            }
        }

        protected void btnCancelDelete_Click(object sender, EventArgs e)
        {
            lblDeleteError.Visible = false;
            try
            {
                int sellerId = Convert.ToInt32(Session["SellerId"]);

                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    string query = "UPDATE SellerUsers SET DeletionStatus = 'None', DeactivationDate = NULL, UpdatedAt = GETDATE() WHERE Id = @id";
                    using (SqlCommand cmd = new SqlCommand(query, con))
                    {
                        cmd.Parameters.AddWithValue("@id", sellerId);
                        cmd.ExecuteNonQuery();
                    }
                }

                LoadSettings();
                pnlDeleteModal.Visible = false; // Hide on success cancel
                ShowAlert("✅ Deactivation request cancelled successfully! Store status restored.", true);
            }
            catch (Exception ex)
            {
                pnlDeleteModal.Visible = true; // Keep visible on failure
                lblDeleteError.Visible = true;
                lblDeleteError.Text = "⚠️ Cancellation request failed: " + ex.Message;
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
    }
}
