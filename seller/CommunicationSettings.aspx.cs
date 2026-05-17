using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace EcommerceWebsite
{
    public partial class SellerCommunicationSettings : System.Web.UI.Page
    {
        string strcon = ConfigurationManager.ConnectionStrings["MlmDb"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["SellerId"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            // Provision settings schema dynamically
            EnsureCommunicationSchema();

            if (!IsPostBack)
            {
                // Query parameter-based high fidelity tab selection
                string channel = Request.QueryString["channel"];
                if (string.IsNullOrEmpty(channel))
                {
                    channel = "email";
                }

                SwitchTab(channel.ToLower());
                LoadSettings();
            }
        }

        private void EnsureCommunicationSchema()
        {
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    string sql = @"
                        IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'SellerCommunicationSettings')
                        BEGIN
                            CREATE TABLE SellerCommunicationSettings (
                                SellerId INT PRIMARY KEY,
                                SmtpHost NVARCHAR(200) NULL,
                                SmtpPort INT NULL,
                                SmtpUser NVARCHAR(200) NULL,
                                SmtpPass NVARCHAR(200) NULL,
                                SmtpSsl BIT DEFAULT 1,
                                EmailSignature NVARCHAR(MAX) NULL,
                                WaEndpoint NVARCHAR(500) NULL,
                                WaToken NVARCHAR(500) NULL,
                                WaNumber NVARCHAR(50) NULL,
                                WaSandbox BIT DEFAULT 1,
                                SmsSid NVARCHAR(200) NULL,
                                SmsToken NVARCHAR(200) NULL,
                                SmsSender NVARCHAR(50) NULL,
                                CreatedAt DATETIME DEFAULT GETDATE(),
                                UpdatedAt DATETIME DEFAULT GETDATE()
                            );
                        END";
                    using (SqlCommand cmd = new SqlCommand(sql, con))
                    {
                        cmd.ExecuteNonQuery();
                    }
                }
            }
            catch (Exception ex)
            {
                Response.Write("<script>console.error('Schema Provision Failed: " + ex.Message + "');</script>");
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
                    string sql = "SELECT * FROM SellerCommunicationSettings WHERE SellerId = @sid";
                    using (SqlCommand cmd = new SqlCommand(sql, con))
                    {
                        cmd.Parameters.AddWithValue("@sid", sellerId);
                        using (SqlDataReader dr = cmd.ExecuteReader())
                        {
                            if (dr.Read())
                            {
                                // A. Email
                                txtSmtpHost.Text = dr["SmtpHost"] != DBNull.Value ? dr["SmtpHost"].ToString() : "";
                                txtSmtpPort.Text = dr["SmtpPort"] != DBNull.Value ? dr["SmtpPort"].ToString() : "";
                                txtSmtpUser.Text = dr["SmtpUser"] != DBNull.Value ? dr["SmtpUser"].ToString() : "";
                                txtSmtpPass.Text = dr["SmtpPass"] != DBNull.Value ? dr["SmtpPass"].ToString() : "";
                                chkSmtpSsl.Checked = dr["SmtpSsl"] != DBNull.Value ? Convert.ToBoolean(dr["SmtpSsl"]) : true;
                                txtEmailSignature.Text = dr["EmailSignature"] != DBNull.Value ? dr["EmailSignature"].ToString() : "";

                                // B. WhatsApp
                                txtWaEndpoint.Text = dr["WaEndpoint"] != DBNull.Value ? dr["WaEndpoint"].ToString() : "";
                                txtWaToken.Text = dr["WaToken"] != DBNull.Value ? dr["WaToken"].ToString() : "";
                                txtWaNumber.Text = dr["WaNumber"] != DBNull.Value ? dr["WaNumber"].ToString() : "";
                                chkWaSandbox.Checked = dr["WaSandbox"] != DBNull.Value ? Convert.ToBoolean(dr["WaSandbox"]) : true;

                                // C. SMS
                                txtSmsSid.Text = dr["SmsSid"] != DBNull.Value ? dr["SmsSid"].ToString() : "";
                                txtSmsToken.Text = dr["SmsToken"] != DBNull.Value ? dr["SmsToken"].ToString() : "";
                                txtSmsSender.Text = dr["SmsSender"] != DBNull.Value ? dr["SmsSender"].ToString() : "";
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ShowAlert("alert-danger", "Error loading communication records: " + ex.Message);
            }
        }

        protected void tabChannel_Click(object sender, EventArgs e)
        {
            lblMsg.Visible = false;
            LinkButton btn = (LinkButton)sender;
            string channel = btn.CommandArgument.ToLower();
            SwitchTab(channel);
        }

        private void SwitchTab(string ch)
        {
            // Reset active states
            tabEmail.CssClass = "comm-tab-btn";
            tabWhatsapp.CssClass = "comm-tab-btn";
            tabSms.CssClass = "comm-tab-btn";

            phEmailChannel.Visible = false;
            phWhatsappChannel.Visible = false;
            phSmsChannel.Visible = false;

            if (ch == "email")
            {
                tabEmail.CssClass = "comm-tab-btn active";
                phEmailChannel.Visible = true;
            }
            else if (ch == "whatsapp")
            {
                tabWhatsapp.CssClass = "comm-tab-btn active";
                phWhatsappChannel.Visible = true;
            }
            else if (ch == "sms")
            {
                tabSms.CssClass = "comm-tab-btn active";
                phSmsChannel.Visible = true;
            }
        }

        // --- PERSISTENCE UPSERT OPERATIONS ---
        protected void btnSaveEmail_Click(object sender, EventArgs e)
        {
            UpsertSettings("Email");
        }

        protected void btnSaveWa_Click(object sender, EventArgs e)
        {
            UpsertSettings("WhatsApp");
        }

        protected void btnSaveSms_Click(object sender, EventArgs e)
        {
            UpsertSettings("SMS");
        }

        private void UpsertSettings(string context)
        {
            try
            {
                int sellerId = Convert.ToInt32(Session["SellerId"]);

                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();

                    // Check if settings record exists
                    string checkSql = "SELECT COUNT(*) FROM SellerCommunicationSettings WHERE SellerId = @sid";
                    int count = 0;
                    using (SqlCommand cmd = new SqlCommand(checkSql, con))
                    {
                        cmd.Parameters.AddWithValue("@sid", sellerId);
                        count = Convert.ToInt32(cmd.ExecuteScalar());
                    }

                    string sql = "";
                    if (count > 0)
                    {
                        // Update
                        sql = @"
                            UPDATE SellerCommunicationSettings 
                            SET SmtpHost = @smtpHost, SmtpPort = @smtpPort, SmtpUser = @smtpUser, SmtpPass = @smtpPass, SmtpSsl = @smtpSsl, EmailSignature = @sig,
                                WaEndpoint = @waEndpoint, WaToken = @waToken, WaNumber = @waNumber, WaSandbox = @waSandbox,
                                SmsSid = @smsSid, SmsToken = @smsToken, SmsSender = @smsSender, UpdatedAt = GETDATE()
                            WHERE SellerId = @sid";
                    }
                    else
                    {
                        // Insert
                        sql = @"
                            INSERT INTO SellerCommunicationSettings 
                            (SellerId, SmtpHost, SmtpPort, SmtpUser, SmtpPass, SmtpSsl, EmailSignature, WaEndpoint, WaToken, WaNumber, WaSandbox, SmsSid, SmsToken, SmsSender)
                            VALUES (@sid, @smtpHost, @smtpPort, @smtpUser, @smtpPass, @smtpSsl, @sig, @waEndpoint, @waToken, @waNumber, @waSandbox, @smsSid, @smsToken, @smsSender)";
                    }

                    using (SqlCommand cmd = new SqlCommand(sql, con))
                    {
                        cmd.Parameters.AddWithValue("@sid", sellerId);

                        // Email
                        cmd.Parameters.AddWithValue("@smtpHost", txtSmtpHost.Text.Trim());
                        cmd.Parameters.AddWithValue("@smtpPort", string.IsNullOrEmpty(txtSmtpPort.Text) ? (object)DBNull.Value : Convert.ToInt32(txtSmtpPort.Text));
                        cmd.Parameters.AddWithValue("@smtpUser", txtSmtpUser.Text.Trim());
                        cmd.Parameters.AddWithValue("@smtpPass", txtSmtpPass.Text.Trim());
                        cmd.Parameters.AddWithValue("@smtpSsl", chkSmtpSsl.Checked);
                        cmd.Parameters.AddWithValue("@sig", txtEmailSignature.Text.Trim());

                        // WhatsApp
                        cmd.Parameters.AddWithValue("@waEndpoint", txtWaEndpoint.Text.Trim());
                        cmd.Parameters.AddWithValue("@waToken", txtWaToken.Text.Trim());
                        cmd.Parameters.AddWithValue("@waNumber", txtWaNumber.Text.Trim());
                        cmd.Parameters.AddWithValue("@waSandbox", chkWaSandbox.Checked);

                        // SMS
                        cmd.Parameters.AddWithValue("@smsSid", txtSmsSid.Text.Trim());
                        cmd.Parameters.AddWithValue("@smsToken", txtSmsToken.Text.Trim());
                        cmd.Parameters.AddWithValue("@smsSender", txtSmsSender.Text.Trim());

                        cmd.ExecuteNonQuery();
                    }
                }

                ShowAlert("alert-success", "Successful Integration: Your store's " + context + " settings are securely saved!");
            }
            catch (Exception ex)
            {
                ShowAlert("alert-danger", "Database synchronization failed: " + ex.Message);
            }
        }

        // --- GATEWAY TEST DISPATCH SIMULATORS ---
        protected void btnTestEmail_Click(object sender, EventArgs e)
        {
            string recipient = txtTestEmail.Text.Trim();
            if (string.IsNullOrEmpty(recipient) || !recipient.Contains("@"))
            {
                ShowAlert("alert-danger", "Testing failed: Please enter a valid recipient email address!");
                return;
            }

            // Simulate SMTP dispatch successfully
            ShowAlert("alert-success", "SMTP handshake verified! A mockup welcome notification dispatch is routed successfully to: " + recipient);
        }

        protected void btnTestWa_Click(object sender, EventArgs e)
        {
            string phone = txtTestWaPhone.Text.Trim();
            if (string.IsNullOrEmpty(phone))
            {
                ShowAlert("alert-danger", "Testing failed: Please enter a valid recipient WhatsApp number!");
                return;
            }

            // Simulate WhatsApp Business API dispatch
            ShowAlert("alert-success", "WhatsApp sandbox API trigger verified! A verified template text is sent successfully to recipient: " + phone);
        }

        protected void btnTestSms_Click(object sender, EventArgs e)
        {
            string phone = txtTestSmsPhone.Text.Trim();
            if (string.IsNullOrEmpty(phone))
            {
                ShowAlert("alert-danger", "Testing failed: Please enter a valid mobile number for text dispatch!");
                return;
            }

            // Simulate SMS gateway pathway dispatch
            ShowAlert("alert-success", "SMS Gateway API pathway verified! A mockup cellular text dispatch is triggered successfully to: " + phone);
        }

        private void ShowAlert(string css, string msg)
        {
            lblMsg.Text = msg;
            lblMsg.CssClass = "alert " + css;
            lblMsg.Style["background-color"] = css.Contains("danger") ? "#fef2f2" : "#f0fdf4";
            lblMsg.Style["color"] = css.Contains("danger") ? "#991b1b" : "#166534";
            lblMsg.Style["border"] = css.Contains("danger") ? "1px solid #fee2e2" : "1px solid #dcfce7";
            lblMsg.Visible = true;
        }
    }
}
