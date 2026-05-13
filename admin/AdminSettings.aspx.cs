using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;

namespace ecommerce_mlm.admin
{
    public partial class AdminSettings : System.Web.UI.Page
    {
        string strcon = ConfigurationManager.ConnectionStrings["MlmDb"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["AdminId"] == null)
            {
                Response.Redirect("AdminLogin.aspx");
                return;
            }

            // Dynamically provision system configuration schema on first load
            EnsureSystemConfigSchema();

            if (!IsPostBack)
            {
                LoadAdminProfile();
                LoadPlatformConfig();
                LoadStoreCharges();
                LoadSmtpSettings();
                LoadSmsSettings();
                LoadWhatsAppSettings();
                LoadPgSettings();
                LoadMlmSettings();
            }
        }

        private void EnsureSystemConfigSchema()
        {
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    string sqlCheck = "SELECT COUNT(*) FROM sys.tables WHERE name = 'SystemSettings'";
                    SqlCommand cmd = new SqlCommand(sqlCheck, con);
                    int exists = (int)cmd.ExecuteScalar();

                    if (exists == 0)
                    {
                        string sqlCreate = @"
                            CREATE TABLE SystemSettings (
                                ConfigKey NVARCHAR(100) PRIMARY KEY,
                                ConfigValue NVARCHAR(MAX) NOT NULL
                            );
                            INSERT INTO SystemSettings VALUES ('SiteName', 'Elite MLM Engine');
                            INSERT INTO SystemSettings VALUES ('AdminCommission', '10');
                            INSERT INTO SystemSettings VALUES ('SupportEmail', 'support@mlm.com');
                            INSERT INTO SystemSettings VALUES ('MinPayout', '500');
                            INSERT INTO SystemSettings VALUES ('MaintenanceMode', 'FALSE');
                            INSERT INTO SystemSettings VALUES ('PlatformFee', '5');
                            INSERT INTO SystemSettings VALUES ('MinFreeShipping', '1000');
                            INSERT INTO SystemSettings VALUES ('ShippingFee', '25');
                            INSERT INTO SystemSettings VALUES ('SmtpHost', 'smtp.gmail.com');
                            INSERT INTO SystemSettings VALUES ('SmtpPort', '587');
                            INSERT INTO SystemSettings VALUES ('SmtpFrom', '');
                            INSERT INTO SystemSettings VALUES ('SmtpPass', '');
                            INSERT INTO SystemSettings VALUES ('SmtpEnableSsl', 'TRUE');
                            INSERT INTO SystemSettings VALUES ('SmsApiUrl', '');
                            INSERT INTO SystemSettings VALUES ('SmsApiKey', '');
                            INSERT INTO SystemSettings VALUES ('SmsSenderId', '');
                            INSERT INTO SystemSettings VALUES ('WaApiUrl', 'https://graph.facebook.com/v17.0/');
                            INSERT INTO SystemSettings VALUES ('WaAccessToken', '');
                            INSERT INTO SystemSettings VALUES ('WaPhoneId', '');
                            INSERT INTO SystemSettings VALUES ('WaBusinessAccountId', '');
                            INSERT INTO SystemSettings VALUES ('PgProvider', 'Razorpay');
                            INSERT INTO SystemSettings VALUES ('PgEnvironment', 'TEST');
                            INSERT INTO SystemSettings VALUES ('PgKeyId', '');
                            INSERT INTO SystemSettings VALUES ('PgKeySecret', '');
                            INSERT INTO SystemSettings VALUES ('PgMerchantId', '');
                            INSERT INTO SystemSettings VALUES ('MlmDirectReferralPercent', '10');
                            INSERT INTO SystemSettings VALUES ('MlmLevel1Percent', '5');
                            INSERT INTO SystemSettings VALUES ('MlmLevel2Percent', '3');
                            INSERT INTO SystemSettings VALUES ('MlmLevel3Percent', '2');
                            INSERT INTO SystemSettings VALUES ('MlmMinActivationPurchase', '500');
                            INSERT INTO SystemSettings VALUES ('PayoutTdsPercent', '5');
                            INSERT INTO SystemSettings VALUES ('PayoutAdminChargePercent', '5');
                            INSERT INTO SystemSettings VALUES ('PayoutMinWithdrawLimit', '200');
                        ";
                        new SqlCommand(sqlCreate, con).ExecuteNonQuery();
                    }
                    else
                    {
                        // Seeding individual new keys to existing installation securely
                        SeedKey(con, "PlatformFee", "5");
                        SeedKey(con, "MinFreeShipping", "1000");
                        SeedKey(con, "ShippingFee", "25");
                        SeedKey(con, "SmtpHost", "smtp.gmail.com");
                        SeedKey(con, "SmtpPort", "587");
                        SeedKey(con, "SmtpFrom", "");
                        SeedKey(con, "SmtpPass", "");
                        SeedKey(con, "SmtpEnableSsl", "TRUE");
                        SeedKey(con, "SmsApiUrl", "");
                        SeedKey(con, "SmsApiKey", "");
                        SeedKey(con, "SmsSenderId", "");
                        SeedKey(con, "WaApiUrl", "https://graph.facebook.com/v17.0/");
                        SeedKey(con, "WaAccessToken", "");
                        SeedKey(con, "WaPhoneId", "");
                        SeedKey(con, "WaBusinessAccountId", "");
                        SeedKey(con, "PgProvider", "Razorpay");
                        SeedKey(con, "PgEnvironment", "TEST");
                        SeedKey(con, "PgKeyId", "");
                        SeedKey(con, "PgKeySecret", "");
                        SeedKey(con, "PgMerchantId", "");
                        SeedKey(con, "MlmDirectReferralPercent", "10");
                        SeedKey(con, "MlmLevel1Percent", "5");
                        SeedKey(con, "MlmLevel2Percent", "3");
                        SeedKey(con, "MlmLevel3Percent", "2");
                        SeedKey(con, "MlmMinActivationPurchase", "500");
                        SeedKey(con, "PayoutTdsPercent", "5");
                        SeedKey(con, "PayoutAdminChargePercent", "5");
                        SeedKey(con, "PayoutMinWithdrawLimit", "200");
                    }

                    // Ensure stored procedures are initialized successfully
                    EnsureStoredProcedures(con);
                }
            }
            catch { }
        }

        private void EnsureStoredProcedures(SqlConnection con)
        {
            try
            {
                string sqlProcGet = @"
                    IF NOT EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_GetSystemSetting')
                    BEGIN
                        EXEC('CREATE PROCEDURE sp_GetSystemSetting 
                            @ConfigKey NVARCHAR(100)
                        AS
                        BEGIN
                            SET NOCOUNT ON;
                            SELECT ConfigValue FROM SystemSettings WHERE ConfigKey = @ConfigKey;
                        END')
                    END";
                using (SqlCommand cmd = new SqlCommand(sqlProcGet, con))
                {
                    cmd.ExecuteNonQuery();
                }

                string sqlProcSet = @"
                    IF NOT EXISTS (SELECT * FROM sys.objects WHERE type = 'P' AND name = 'sp_UpdateSystemSetting')
                    BEGIN
                        EXEC('CREATE PROCEDURE sp_UpdateSystemSetting 
                            @ConfigKey NVARCHAR(100),
                            @ConfigValue NVARCHAR(MAX)
                        AS
                        BEGIN
                            SET NOCOUNT ON;
                            IF EXISTS (SELECT 1 FROM SystemSettings WHERE ConfigKey = @ConfigKey)
                                UPDATE SystemSettings SET ConfigValue = @ConfigValue WHERE ConfigKey = @ConfigKey;
                            ELSE
                                INSERT INTO SystemSettings (ConfigKey, ConfigValue) VALUES (@ConfigKey, @ConfigValue);
                        END')
                    END";
                using (SqlCommand cmd = new SqlCommand(sqlProcSet, con))
                {
                    cmd.ExecuteNonQuery();
                }
            }
            catch { }
        }

        private void SeedKey(SqlConnection con, string key, string val)
        {
            try
            {
                string sql = "IF NOT EXISTS (SELECT 1 FROM SystemSettings WHERE ConfigKey = @key) INSERT INTO SystemSettings VALUES (@key, @val)";
                using (SqlCommand cmd = new SqlCommand(sql, con))
                {
                    cmd.Parameters.AddWithValue("@key", key);
                    cmd.Parameters.AddWithValue("@val", val);
                    cmd.ExecuteNonQuery();
                }
            }
            catch { }
        }

        private void LoadAdminProfile()
        {
            string adminId = Session["AdminId"].ToString();
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    string sql = "SELECT FullName, Email FROM AdminUsers WHERE Id = @id";
                    using (SqlCommand cmd = new SqlCommand(sql, con))
                    {
                        cmd.Parameters.AddWithValue("@id", adminId);
                        SqlDataReader dr = cmd.ExecuteReader();
                        if (dr.Read())
                        {
                            txtAdminName.Text = dr["FullName"].ToString();
                            txtAdminEmail.Text = dr["Email"].ToString();
                        }
                    }
                }
            }
            catch { }
        }

        private void LoadPlatformConfig()
        {
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    string sql = "SELECT ConfigKey, ConfigValue FROM SystemSettings";
                    using (SqlCommand cmd = new SqlCommand(sql, con))
                    {
                        SqlDataReader dr = cmd.ExecuteReader();
                        while (dr.Read())
                        {
                            string key = dr["ConfigKey"].ToString();
                            string val = dr["ConfigValue"].ToString();

                            if (key == "SiteName") txtSiteName.Text = val;
                            else if (key == "SupportEmail") txtSupportEmail.Text = val;
                            else if (key == "MinPayout") txtMinPayout.Text = val;
                            else if (key == "MaintenanceMode") ddlMaintenance.SelectedValue = val;
                        }
                    }
                }
            }
            catch { }
        }

        private void LoadStoreCharges()
        {
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    string sql = "SELECT ConfigKey, ConfigValue FROM SystemSettings WHERE ConfigKey IN ('PlatformFee', 'AdminCommission', 'MinFreeShipping', 'ShippingFee')";
                    using (SqlCommand cmd = new SqlCommand(sql, con))
                    {
                        SqlDataReader dr = cmd.ExecuteReader();
                        while (dr.Read())
                        {
                            string key = dr["ConfigKey"].ToString();
                            string val = dr["ConfigValue"].ToString();

                            if (key == "PlatformFee") txtPlatformFee.Text = val;
                            else if (key == "AdminCommission") txtAdminCommission.Text = val;
                            else if (key == "MinFreeShipping") txtMinFreeShipping.Text = val;
                            else if (key == "ShippingFee") txtShippingFee.Text = val;
                        }
                    }
                }
            }
            catch { }
        }

        private void LoadSmtpSettings()
        {
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    string sql = "SELECT ConfigKey, ConfigValue FROM SystemSettings WHERE ConfigKey IN ('SmtpHost', 'SmtpPort', 'SmtpFrom', 'SmtpPass', 'SmtpEnableSsl')";
                    using (SqlCommand cmd = new SqlCommand(sql, con))
                    {
                        SqlDataReader dr = cmd.ExecuteReader();
                        while (dr.Read())
                        {
                            string key = dr["ConfigKey"].ToString();
                            string val = dr["ConfigValue"].ToString();

                            if (key == "SmtpHost") txtSmtpHost.Text = val;
                            else if (key == "SmtpPort") txtSmtpPort.Text = val;
                            else if (key == "SmtpFrom") txtSmtpFrom.Text = val;
                            else if (key == "SmtpPass") txtSmtpPass.Text = val;
                            else if (key == "SmtpEnableSsl") ddlSmtpSsl.SelectedValue = val;
                        }
                    }
                }
            }
            catch { }
        }

        private void LoadSmsSettings()
        {
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    string sql = "SELECT ConfigKey, ConfigValue FROM SystemSettings WHERE ConfigKey IN ('SmsApiUrl', 'SmsApiKey', 'SmsSenderId')";
                    using (SqlCommand cmd = new SqlCommand(sql, con))
                    {
                        SqlDataReader dr = cmd.ExecuteReader();
                        while (dr.Read())
                        {
                            string key = dr["ConfigKey"].ToString();
                            string val = dr["ConfigValue"].ToString();

                            if (key == "SmsApiUrl") txtSmsApiUrl.Text = val;
                            else if (key == "SmsApiKey") txtSmsApiKey.Text = val;
                            else if (key == "SmsSenderId") txtSmsSenderId.Text = val;
                        }
                    }
                }
            }
            catch { }
        }

        private void LoadWhatsAppSettings()
        {
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    string sql = "SELECT ConfigKey, ConfigValue FROM SystemSettings WHERE ConfigKey IN ('WaApiUrl', 'WaAccessToken', 'WaPhoneId', 'WaBusinessAccountId')";
                    using (SqlCommand cmd = new SqlCommand(sql, con))
                    {
                        SqlDataReader dr = cmd.ExecuteReader();
                        while (dr.Read())
                        {
                            string key = dr["ConfigKey"].ToString();
                            string val = dr["ConfigValue"].ToString();

                            if (key == "WaApiUrl") txtWaApiUrl.Text = val;
                            else if (key == "WaAccessToken") txtWaAccessToken.Text = val;
                            else if (key == "WaPhoneId") txtWaPhoneId.Text = val;
                            else if (key == "WaBusinessAccountId") txtWaBusinessAccountId.Text = val;
                        }
                    }
                }
            }
            catch { }
        }

        private void LoadPgSettings()
        {
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    string sql = "SELECT ConfigKey, ConfigValue FROM SystemSettings WHERE ConfigKey IN ('PgProvider', 'PgEnvironment', 'PgKeyId', 'PgKeySecret', 'PgMerchantId')";
                    using (SqlCommand cmd = new SqlCommand(sql, con))
                    {
                        SqlDataReader dr = cmd.ExecuteReader();
                        while (dr.Read())
                        {
                            string key = dr["ConfigKey"].ToString();
                            string val = dr["ConfigValue"].ToString();

                            if (key == "PgProvider") ddlPgProvider.SelectedValue = val;
                            else if (key == "PgEnvironment") ddlPgEnv.SelectedValue = val;
                            else if (key == "PgKeyId") txtPgKeyId.Text = val;
                            else if (key == "PgKeySecret") txtPgKeySecret.Text = val;
                            else if (key == "PgMerchantId") txtPgMerchantId.Text = val;
                        }
                    }
                }
            }
            catch { }
        }

        private void LoadMlmSettings()
        {
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    string sql = "SELECT ConfigKey, ConfigValue FROM SystemSettings WHERE ConfigKey LIKE 'Mlm%' OR ConfigKey LIKE 'Payout%'";
                    using (SqlCommand cmd = new SqlCommand(sql, con))
                    {
                        SqlDataReader dr = cmd.ExecuteReader();
                        while (dr.Read())
                        {
                            string key = dr["ConfigKey"].ToString();
                            string val = dr["ConfigValue"].ToString();

                            if (key == "MlmDirectReferralPercent") txtMlmDirect.Text = val;
                            else if (key == "MlmLevel1Percent") txtMlmL1.Text = val;
                            else if (key == "MlmLevel2Percent") txtMlmL2.Text = val;
                            else if (key == "MlmLevel3Percent") txtMlmL3.Text = val;
                            else if (key == "MlmMinActivationPurchase") txtMlmMinAct.Text = val;
                            else if (key == "PayoutTdsPercent") txtPayoutTds.Text = val;
                            else if (key == "PayoutAdminChargePercent") txtPayoutAdminFee.Text = val;
                            else if (key == "PayoutMinWithdrawLimit") txtPayoutMinLimit.Text = val;
                        }
                    }
                }
            }
            catch { }
        }

        protected void btnSaveProfile_Click(object sender, EventArgs e)
        {
            string adminId = Session["AdminId"].ToString();
            string name = txtAdminName.Text.Trim();
            string email = txtAdminEmail.Text.Trim();

            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    string sql = "UPDATE AdminUsers SET FullName = @name, Email = @email WHERE Id = @id";
                    using (SqlCommand cmd = new SqlCommand(sql, con))
                    {
                        cmd.Parameters.AddWithValue("@name", name);
                        cmd.Parameters.AddWithValue("@email", email);
                        cmd.Parameters.AddWithValue("@id", adminId);
                        cmd.ExecuteNonQuery();
                    }
                    Session["AdminName"] = name;
                    Session["AdminEmail"] = email;
                }
                ShowMessage("alert-success", "Administrative Profile successfully modernized.");
            }
            catch (Exception ex)
            {
                ShowMessage("alert-danger", "Profile mutation failed: " + ex.Message);
            }
        }

        protected void btnSavePlatform_Click(object sender, EventArgs e)
        {
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    UpdateConfig(con, "SiteName", txtSiteName.Text.Trim());
                    UpdateConfig(con, "SupportEmail", txtSupportEmail.Text.Trim());
                    UpdateConfig(con, "MinPayout", txtMinPayout.Text.Trim());
                    UpdateConfig(con, "MaintenanceMode", ddlMaintenance.SelectedValue);
                }
                ShowMessage("alert-success", "Core operational settings applied globally.");
            }
            catch (Exception ex)
            {
                ShowMessage("alert-danger", "Failure enforcing global parameters: " + ex.Message);
            }
        }

        protected void btnSaveCharges_Click(object sender, EventArgs e)
        {
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    UpdateConfig(con, "PlatformFee", txtPlatformFee.Text.Trim());
                    UpdateConfig(con, "AdminCommission", txtAdminCommission.Text.Trim());
                    UpdateConfig(con, "MinFreeShipping", txtMinFreeShipping.Text.Trim());
                    UpdateConfig(con, "ShippingFee", txtShippingFee.Text.Trim());
                }
                ShowMessage("alert-success", "Platform charges and fee logic revised universally.");
            }
            catch (Exception ex)
            {
                ShowMessage("alert-danger", "Transaction logic update failure: " + ex.Message);
            }
        }

        protected void btnSaveSmtp_Click(object sender, EventArgs e)
        {
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    UpdateConfig(con, "SmtpHost", txtSmtpHost.Text.Trim());
                    UpdateConfig(con, "SmtpPort", txtSmtpPort.Text.Trim());
                    UpdateConfig(con, "SmtpFrom", txtSmtpFrom.Text.Trim());
                    UpdateConfig(con, "SmtpPass", txtSmtpPass.Text.Trim());
                    UpdateConfig(con, "SmtpEnableSsl", ddlSmtpSsl.SelectedValue);
                }
                ShowMessage("alert-success", "Communications engine routing settings persisted flawlessly.");
            }
            catch (Exception ex)
            {
                ShowMessage("alert-danger", "Email credentials commit failed: " + ex.Message);
            }
        }

        protected void btnSaveSms_Click(object sender, EventArgs e)
        {
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    UpdateConfig(con, "SmsApiUrl", txtSmsApiUrl.Text.Trim());
                    UpdateConfig(con, "SmsApiKey", txtSmsApiKey.Text.Trim());
                    UpdateConfig(con, "SmsSenderId", txtSmsSenderId.Text.Trim());
                }
                ShowMessage("alert-success", "SMS API Gateway thresholds calibrated successfully.");
            }
            catch (Exception ex)
            {
                ShowMessage("alert-danger", "SMS Configuration commit failure: " + ex.Message);
            }
        }

        protected void btnSaveWa_Click(object sender, EventArgs e)
        {
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    UpdateConfig(con, "WaApiUrl", txtWaApiUrl.Text.Trim());
                    UpdateConfig(con, "WaAccessToken", txtWaAccessToken.Text.Trim());
                    UpdateConfig(con, "WaPhoneId", txtWaPhoneId.Text.Trim());
                    UpdateConfig(con, "WaBusinessAccountId", txtWaBusinessAccountId.Text.Trim());
                }
                ShowMessage("alert-success", "WhatsApp Business Cloud credentials integrated dynamically.");
            }
            catch (Exception ex)
            {
                ShowMessage("alert-danger", "WhatsApp Token validation issue: " + ex.Message);
            }
        }

        protected void btnSavePg_Click(object sender, EventArgs e)
        {
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    UpdateConfig(con, "PgProvider", ddlPgProvider.SelectedValue);
                    UpdateConfig(con, "PgEnvironment", ddlPgEnv.SelectedValue);
                    UpdateConfig(con, "PgKeyId", txtPgKeyId.Text.Trim());
                    UpdateConfig(con, "PgKeySecret", txtPgKeySecret.Text.Trim());
                    UpdateConfig(con, "PgMerchantId", txtPgMerchantId.Text.Trim());
                }
                ShowMessage("alert-success", "Payment gateway integration credentials finalized universally.");
            }
            catch (Exception ex)
            {
                ShowMessage("alert-danger", "Payment matrix update failure: " + ex.Message);
            }
        }

        protected void btnSaveMlm_Click(object sender, EventArgs e)
        {
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    UpdateConfig(con, "MlmDirectReferralPercent", txtMlmDirect.Text.Trim());
                    UpdateConfig(con, "MlmLevel1Percent", txtMlmL1.Text.Trim());
                    UpdateConfig(con, "MlmLevel2Percent", txtMlmL2.Text.Trim());
                    UpdateConfig(con, "MlmLevel3Percent", txtMlmL3.Text.Trim());
                    UpdateConfig(con, "MlmMinActivationPurchase", txtMlmMinAct.Text.Trim());
                    UpdateConfig(con, "PayoutTdsPercent", txtPayoutTds.Text.Trim());
                    UpdateConfig(con, "PayoutAdminChargePercent", txtPayoutAdminFee.Text.Trim());
                    UpdateConfig(con, "PayoutMinWithdrawLimit", txtPayoutMinLimit.Text.Trim());
                }
                ShowMessage("alert-success", "MLM commission matrix and payout thresholds locked universally.");
            }
            catch (Exception ex)
            {
                ShowMessage("alert-danger", "Network rules update fault: " + ex.Message);
            }
        }

        private void UpdateConfig(SqlConnection con, string key, string val)
        {
            try
            {
                using (SqlCommand cmd = new SqlCommand("sp_UpdateSystemSetting", con))
                {
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@ConfigKey", key);
                    cmd.Parameters.AddWithValue("@ConfigValue", val);
                    cmd.ExecuteNonQuery();
                }
            }
            catch
            {
                // Safe failback if the stored procedure fails for some reason
                string sqlFallback = "UPDATE SystemSettings SET ConfigValue = @val WHERE ConfigKey = @key";
                using (SqlCommand cmd = new SqlCommand(sqlFallback, con))
                {
                    cmd.Parameters.AddWithValue("@val", val);
                    cmd.Parameters.AddWithValue("@key", key);
                    cmd.ExecuteNonQuery();
                }
            }
        }

        protected void btnUpdatePassword_Click(object sender, EventArgs e)
        {
            string adminId = Session["AdminId"].ToString();
            string oldPass = txtOldPass.Text.Trim();
            string newPass = txtNewPass.Text.Trim();
            string confPass = txtConfirmPass.Text.Trim();

            if (newPass != confPass)
            {
                ShowMessage("alert-danger", "Mismatched confirmation vectors. Please re-align targets.");
                return;
            }

            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    // 1. Verify Old Password
                    string checkSql = "SELECT COUNT(*) FROM AdminUsers WHERE Id = @id AND Password = @pass";
                    SqlCommand checkCmd = new SqlCommand(checkSql, con);
                    checkCmd.Parameters.AddWithValue("@id", adminId);
                    checkCmd.Parameters.AddWithValue("@pass", oldPass);
                    int count = (int)checkCmd.ExecuteScalar();

                    if (count == 0)
                    {
                        ShowMessage("alert-danger", "Original credentials unrecognized. Modification rejected.");
                        return;
                    }

                    // 2. Update Password
                    string updateSql = "UPDATE AdminUsers SET Password = @pass WHERE Id = @id";
                    SqlCommand upd = new SqlCommand(updateSql, con);
                    upd.Parameters.AddWithValue("@pass", newPass);
                    upd.Parameters.AddWithValue("@id", adminId);
                    upd.ExecuteNonQuery();
                }
                ShowMessage("alert-success", "Security protocols refreshed successfully.");
                txtOldPass.Text = ""; txtNewPass.Text = ""; txtConfirmPass.Text = "";
            }
            catch (Exception ex)
            {
                ShowMessage("alert-danger", "Security upgrade interrupted: " + ex.Message);
            }
        }

        private void ShowMessage(string cssClass, string text)
        {
            pnlMsg.CssClass = "alert " + cssClass + " alert-dismissible fade show u-mb-20";
            lblMsg.Text = text;
            pnlMsg.Visible = true;
        }
    }
}
