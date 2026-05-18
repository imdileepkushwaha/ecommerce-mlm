using System;
using System.Data;
using System.Data.SqlClient;
using System.Configuration;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace EcommerceWebsite
{
    public partial class SellerCoupons : System.Web.UI.Page
    {
        private const string SchemaCacheKey = "CouponsSchemaInitialized_v1";
        private string strcon = ConfigurationManager.ConnectionStrings["MlmDb"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            // Security gate
            if (Session["SellerId"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            EnsureCouponsSchemaOnce();

            if (!IsPostBack)
            {
                int sid = Convert.ToInt32(Session["SellerId"]);
                LoadCouponsList(sid);
            }
        }

        /// <summary>Runs DDL once per app pool — avoids lock/timeout on every page view.</summary>
        private void EnsureCouponsSchemaOnce()
        {
            if (Application[SchemaCacheKey] != null) return;

            lock (Application)
            {
                if (Application[SchemaCacheKey] != null) return;
                InitializeCouponsSchema();
                Application[SchemaCacheKey] = true;
            }
        }

        /// <summary>
        /// Auto-deploys Coupons database schema if it doesn't already exist, 
        /// utilizing the active C# application connection context.
        /// </summary>
        private void InitializeCouponsSchema()
        {
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    
                    // 1. Create table if not exists
                    string sqlCreate = @"
                    IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Coupons]') AND type in (N'U'))
                    BEGIN
                        CREATE TABLE [dbo].[Coupons] (
                            [Id] INT IDENTITY(1,1) NOT NULL,
                            [SellerId] INT NOT NULL,
                            [CouponCode] VARCHAR(50) NOT NULL,
                            [DiscountType] VARCHAR(20) NOT NULL, -- 'Percentage' or 'FixedAmount'
                            [DiscountValue] DECIMAL(18, 2) NOT NULL,
                            [MinOrderAmount] DECIMAL(18, 2) NOT NULL DEFAULT 0.00,
                            [MaxDiscountAmount] DECIMAL(18, 2) NULL,
                            [StartDate] DATETIME NOT NULL,
                            [EndDate] DATETIME NOT NULL,
                            [UsageLimit] INT NOT NULL DEFAULT 100,
                            [UsedCount] INT NOT NULL DEFAULT 0,
                            [IsActive] BIT NOT NULL DEFAULT 1,
                            [CreatedAt] DATETIME NOT NULL DEFAULT GETDATE(),
                            CONSTRAINT [PK_Coupons] PRIMARY KEY CLUSTERED ([Id] ASC),
                            CONSTRAINT [FK_Coupons_SellerUsers] FOREIGN KEY ([SellerId]) REFERENCES [dbo].[SellerUsers] ([Id]) ON DELETE CASCADE
                        );
                    END";
                    using (SqlCommand cmd = new SqlCommand(sqlCreate, con))
                    {
                        cmd.CommandTimeout = 120;
                        cmd.ExecuteNonQuery();
                    }

                    EnsureCouponsIndexes(con);

                    // 2. Self-healing migrations for existing Coupons table (Alters columns if missing)
                    string sqlMigrate = @"
                    IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Coupons]') AND type in (N'U'))
                    BEGIN
                        IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Coupons]') AND name = 'SellerId')
                        BEGIN
                            ALTER TABLE [dbo].[Coupons] ADD [SellerId] INT NOT NULL DEFAULT 1;
                        END

                        IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Coupons]') AND name = 'MaxDiscountAmount')
                        BEGIN
                            ALTER TABLE [dbo].[Coupons] ADD [MaxDiscountAmount] DECIMAL(18, 2) NULL;
                        END

                        IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Coupons]') AND name = 'StartDate')
                        BEGIN
                            ALTER TABLE [dbo].[Coupons] ADD [StartDate] DATETIME NOT NULL DEFAULT GETDATE();
                        END

                        IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Coupons]') AND name = 'EndDate')
                        BEGIN
                            ALTER TABLE [dbo].[Coupons] ADD [EndDate] DATETIME NOT NULL DEFAULT DATEADD(year, 1, GETDATE());
                        END

                        IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Coupons]') AND name = 'UsageLimit')
                        BEGIN
                            ALTER TABLE [dbo].[Coupons] ADD [UsageLimit] INT NOT NULL DEFAULT 100;
                        END

                        IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Coupons]') AND name = 'UsedCount')
                        BEGIN
                            ALTER TABLE [dbo].[Coupons] ADD [UsedCount] INT NOT NULL DEFAULT 0;
                        END

                        IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Coupons]') AND name = 'IsActive')
                        BEGIN
                            ALTER TABLE [dbo].[Coupons] ADD [IsActive] BIT NOT NULL DEFAULT 1;
                        END

                        IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Coupons]') AND name = 'CreatedAt')
                        BEGIN
                            ALTER TABLE [dbo].[Coupons] ADD [CreatedAt] DATETIME NOT NULL DEFAULT GETDATE();
                        END
                    END";
                    using (SqlCommand cmd = new SqlCommand(sqlMigrate, con))
                    {
                        cmd.CommandTimeout = 120;
                        cmd.ExecuteNonQuery();
                    }
                }
            }
            catch (Exception ex)
            {
                ShowGlobalAlert("❌ Critical error initializing database schema: " + ex.Message, false);
            }
        }

        private static void EnsureCouponsIndexes(SqlConnection con)
        {
            const string sql = @"
                IF OBJECT_ID(N'[dbo].[Coupons]', N'U') IS NOT NULL
                BEGIN
                    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Coupons_SellerId' AND object_id = OBJECT_ID(N'[dbo].[Coupons]'))
                        CREATE NONCLUSTERED INDEX [IX_Coupons_SellerId] ON [dbo].[Coupons]([SellerId])
                        INCLUDE ([IsActive], [UsedCount], [CreatedAt], [CouponCode], [DiscountType], [DiscountValue], [EndDate], [UsageLimit]);

                    IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = N'IX_Coupons_CouponCode' AND object_id = OBJECT_ID(N'[dbo].[Coupons]'))
                        CREATE NONCLUSTERED INDEX [IX_Coupons_CouponCode] ON [dbo].[Coupons]([CouponCode]);
                END";
            using (SqlCommand cmd = new SqlCommand(sql, con))
            {
                cmd.CommandTimeout = 120;
                cmd.ExecuteNonQuery();
            }
        }

        private static SqlCommand CreateSp(SqlConnection con, string procedureName)
        {
            var cmd = new SqlCommand(procedureName, con);
            cmd.CommandType = CommandType.StoredProcedure;
            cmd.CommandTimeout = 60;
            return cmd;
        }

        private void LoadCouponsList(int sid)
        {
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();

                    using (SqlCommand cmd = CreateSp(con, "sp_Seller_GetCouponsDashboard"))
                    {
                        cmd.Parameters.AddWithValue("@SellerId", sid);
                        using (SqlDataReader dr = cmd.ExecuteReader())
                        {
                            if (dr.Read())
                            {
                                litTotalCoupons.Text = dr["Total"] != DBNull.Value ? dr["Total"].ToString() : "0";
                                litActiveCoupons.Text = dr["Active"] != DBNull.Value ? dr["Active"].ToString() : "0";
                                litTotalRedeemed.Text = dr["TotalUsed"] != DBNull.Value ? dr["TotalUsed"].ToString() : "0";
                            }

                            DataTable dt = new DataTable();
                            if (dr.NextResult())
                            {
                                dt.Load(dr);
                            }

                            if (dt.Rows.Count > 0)
                            {
                                rptCoupons.DataSource = dt;
                                rptCoupons.DataBind();
                                rptCoupons.Visible = true;
                                phEmptyState.Visible = false;
                            }
                            else
                            {
                                rptCoupons.Visible = false;
                                phEmptyState.Visible = true;
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                ShowGlobalAlert("❌ Error fetching coupon list: " + ex.Message, false);
            }
        }

        protected void btnCreateCoupon_Click(object sender, EventArgs e)
        {
            int sid = Convert.ToInt32(Session["SellerId"]);

            // Clear prior states
            hfCouponId.Value = "";
            txtCouponCode.Text = "";
            txtCouponCode.Enabled = true;
            ddlDiscountType.SelectedIndex = 0;
            txtDiscountValue.Text = "";
            txtMinOrderAmount.Text = "0.00";
            txtMaxDiscountAmount.Text = "";
            txtStartDate.Text = DateTime.Today.ToString("yyyy-MM-dd");
            txtEndDate.Text = DateTime.Today.AddMonths(1).ToString("yyyy-MM-dd");
            txtUsageLimit.Text = "100";
            chkIsActive.Checked = true;

            lblModalError.Visible = false;
            litModalTitle.Text = "Create Store Coupon";
            btnSaveCoupon.Text = "Publish Promo Code";

            pnlCouponModal.Visible = true;
            upnlModal.Update();

            // Rebind Repeater to preserve table data in DOM
            LoadCouponsList(sid);
        }

        protected void btnCloseModal_Click(object sender, EventArgs e)
        {
            int sid = Convert.ToInt32(Session["SellerId"]);
            pnlCouponModal.Visible = false;
            upnlModal.Update();

            // Rebind Repeater to preserve table data in DOM
            LoadCouponsList(sid);
        }

        protected void btnSaveCoupon_Click(object sender, EventArgs e)
        {
            int sid = Convert.ToInt32(Session["SellerId"]);
            
            // Preserve coupons list grid across modal postback validations
            LoadCouponsList(sid);

            string code = txtCouponCode.Text.Trim().ToUpper();
            string type = ddlDiscountType.SelectedValue;
            string valStr = txtDiscountValue.Text.Trim();
            string minStr = txtMinOrderAmount.Text.Trim();
            string maxStr = txtMaxDiscountAmount.Text.Trim();
            string startStr = txtStartDate.Text.Trim();
            string endStr = txtEndDate.Text.Trim();
            string limitStr = txtUsageLimit.Text.Trim();
            bool active = chkIsActive.Checked;

            // Form Validations
            if (string.IsNullOrEmpty(code))
            {
                ShowModalError("Please enter a valid coupon code.");
                return;
            }

            decimal discountVal = 0;
            if (!decimal.TryParse(valStr, out discountVal) || discountVal <= 0)
            {
                ShowModalError("Discount value must be a positive decimal number.");
                return;
            }

            if (type == "Percentage" && discountVal > 100)
            {
                ShowModalError("Percentage discount cannot exceed 100%.");
                return;
            }

            decimal minAmt = 0;
            if (!string.IsNullOrEmpty(minStr) && (!decimal.TryParse(minStr, out minAmt) || minAmt < 0))
            {
                ShowModalError("Minimum order amount must be a positive number.");
                return;
            }

            decimal? maxAmt = null;
            if (!string.IsNullOrEmpty(maxStr))
            {
                decimal parsedMax = 0;
                if (decimal.TryParse(maxStr, out parsedMax) && parsedMax >= 0)
                {
                    maxAmt = parsedMax;
                }
                else
                {
                    ShowModalError("Maximum discount cap must be a valid positive number.");
                    return;
                }
            }

            DateTime startDate, endDate;
            if (!DateTime.TryParse(startStr, out startDate))
            {
                ShowModalError("Please specify a valid start date.");
                return;
            }

            if (!DateTime.TryParse(endStr, out endDate))
            {
                ShowModalError("Please specify a valid expiry date.");
                return;
            }

            if (endDate < startDate)
            {
                ShowModalError("Expiry date cannot be prior to start date.");
                return;
            }

            int limit = 100;
            if (!string.IsNullOrEmpty(limitStr) && (!int.TryParse(limitStr, out limit) || limit <= 0))
            {
                ShowModalError("Usage limit must be a positive integer.");
                return;
            }

            // CRITICAL DUPLICATION VERIFICATION ENGINE (GLOBAL MULTI-VENDOR DUPLICACY CHECK)
            int couponId = 0;
            int.TryParse(hfCouponId.Value, out couponId);

            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();

                    using (SqlCommand cmdDup = CreateSp(con, "sp_Seller_IsCouponCodeTaken"))
                    {
                        cmdDup.Parameters.AddWithValue("@CouponCode", code);
                        cmdDup.Parameters.AddWithValue("@ExcludeId", couponId);
                        int dupCount = Convert.ToInt32(cmdDup.ExecuteScalar());
                        if (dupCount > 0)
                        {
                            ShowModalError(string.Format("❌ The code '{0}' has already been registered by another merchant in the marketplace. Coupon codes must be unique globally! Please try a different code.", code));
                            return;
                        }
                    }

                    using (SqlCommand cmdSave = CreateSp(con, "sp_Seller_SaveCoupon"))
                    {
                        cmdSave.Parameters.AddWithValue("@CouponId", couponId);
                        cmdSave.Parameters.AddWithValue("@SellerId", sid);
                        cmdSave.Parameters.AddWithValue("@CouponCode", code);
                        cmdSave.Parameters.AddWithValue("@DiscountType", type);
                        cmdSave.Parameters.AddWithValue("@DiscountValue", discountVal);
                        cmdSave.Parameters.AddWithValue("@MinOrderAmount", minAmt);
                        cmdSave.Parameters.AddWithValue("@MaxDiscountAmount", (object)maxAmt ?? DBNull.Value);
                        cmdSave.Parameters.AddWithValue("@StartDate", startDate);
                        cmdSave.Parameters.AddWithValue("@EndDate", endDate);
                        cmdSave.Parameters.AddWithValue("@UsageLimit", limit);
                        cmdSave.Parameters.AddWithValue("@IsActive", active);
                        cmdSave.ExecuteNonQuery();
                    }
                }

                // UI Success state restoration
                pnlCouponModal.Visible = false;
                ShowGlobalAlert(couponId == 0 ? "✅ Store coupon published successfully!" : "✅ Coupon updated successfully!", true);
                LoadCouponsList(sid);
            }
            catch (Exception ex)
            {
                ShowModalError("Database transaction error: " + ex.Message);
            }
        }

        protected void rptCoupons_ItemCommand(object source, RepeaterCommandEventArgs e)
        {
            int sid = Convert.ToInt32(Session["SellerId"]);
            int cid = Convert.ToInt32(e.CommandArgument);

            if (e.CommandName == "EditCoupon")
            {
                try
                {
                    using (SqlConnection con = new SqlConnection(strcon))
                    {
                        con.Open();
                        using (SqlCommand cmd = CreateSp(con, "sp_Seller_GetCouponById"))
                        {
                            cmd.Parameters.AddWithValue("@CouponId", cid);
                            cmd.Parameters.AddWithValue("@SellerId", sid);
                            using (SqlDataReader dr = cmd.ExecuteReader())
                            {
                                if (dr.Read())
                                {
                                    hfCouponId.Value = dr["Id"].ToString();
                                    txtCouponCode.Text = dr["CouponCode"].ToString();
                                    txtCouponCode.Enabled = false; // Protect coupon codes from mutation during edits
                                    ddlDiscountType.SelectedValue = dr["DiscountType"].ToString();
                                    txtDiscountValue.Text = Convert.ToDecimal(dr["DiscountValue"]).ToString("F2");
                                    txtMinOrderAmount.Text = Convert.ToDecimal(dr["MinOrderAmount"]).ToString("F2");
                                    
                                    txtMaxDiscountAmount.Text = dr["MaxDiscountAmount"] != DBNull.Value 
                                        ? Convert.ToDecimal(dr["MaxDiscountAmount"]).ToString("F2") 
                                        : "";
                                    
                                    txtStartDate.Text = Convert.ToDateTime(dr["StartDate"]).ToString("yyyy-MM-dd");
                                    txtEndDate.Text = Convert.ToDateTime(dr["EndDate"]).ToString("yyyy-MM-dd");
                                    txtUsageLimit.Text = dr["UsageLimit"].ToString();
                                    chkIsActive.Checked = Convert.ToBoolean(dr["IsActive"]);

                                    lblModalError.Visible = false;
                                    litModalTitle.Text = "Modify Coupon Settings";
                                    btnSaveCoupon.Text = "Save Changes";

                                    pnlCouponModal.Visible = true;
                                    upnlModal.Update();
                                }
                            }
                        }
                    }
                    
                    // Rebind Repeater to preserve table data in DOM
                    LoadCouponsList(sid);
                }
                catch (Exception ex)
                {
                    ShowGlobalAlert("❌ Error fetching coupon parameters: " + ex.Message, false);
                }
            }
            else if (e.CommandName == "ToggleCoupon")
            {
                try
                {
                    using (SqlConnection con = new SqlConnection(strcon))
                    {
                        con.Open();
                        using (SqlCommand cmd = CreateSp(con, "sp_Seller_ToggleCoupon"))
                        {
                            cmd.Parameters.AddWithValue("@CouponId", cid);
                            cmd.Parameters.AddWithValue("@SellerId", sid);
                            cmd.ExecuteNonQuery();
                        }
                    }

                    ShowGlobalAlert("✅ Coupon visibility status toggled successfully!", true);
                    LoadCouponsList(sid);
                }
                catch (Exception ex)
                {
                    ShowGlobalAlert("❌ Error toggling coupon status: " + ex.Message, false);
                }
            }
            else if (e.CommandName == "DeleteCoupon")
            {
                try
                {
                    using (SqlConnection con = new SqlConnection(strcon))
                    {
                        con.Open();
                        using (SqlCommand cmd = CreateSp(con, "sp_Seller_DeleteCoupon"))
                        {
                            cmd.Parameters.AddWithValue("@CouponId", cid);
                            cmd.Parameters.AddWithValue("@SellerId", sid);
                            cmd.ExecuteNonQuery();
                        }
                    }

                    ShowGlobalAlert("✅ Coupon code has been permanently deleted.", true);
                    LoadCouponsList(sid);
                }
                catch (Exception ex)
                {
                    ShowGlobalAlert("❌ Database error deleting coupon: " + ex.Message, false);
                }
            }
        }

        // ROW BINDING HELPERS
        public double GetUsagePercent(object used, object limit)
        {
            if (used == null || used == DBNull.Value || limit == null || limit == DBNull.Value) return 0;
            double u = Convert.ToDouble(used);
            double l = Convert.ToDouble(limit);
            if (l <= 0) return 0;
            double pct = (u / l) * 100;
            return pct > 100 ? 100 : pct;
        }

        public string GetStatusBadge(object activeObj, object expiryObj)
        {
            if (activeObj == null || activeObj == DBNull.Value)
            {
                return "<span class='earn-table-badge badge-cancelled' style='padding:4px 8px; background: rgba(148, 163, 184, 0.08); color: #64748b;'>INACTIVE</span>";
            }
            
            bool active = Convert.ToBoolean(activeObj);
            if (!active)
            {
                return "<span class='earn-table-badge badge-cancelled' style='padding:4px 8px; background: rgba(148, 163, 184, 0.08); color: #64748b;'>INACTIVE</span>";
            }

            if (expiryObj == null || expiryObj == DBNull.Value)
            {
                return "<span class='earn-table-badge badge-delivered' style='padding:4px 8px;'>ACTIVE</span>";
            }

            DateTime expiry = Convert.ToDateTime(expiryObj);
            if (expiry < DateTime.Today)
            {
                return "<span class='earn-table-badge badge-cancelled' style='padding:4px 8px;'>EXPIRED</span>";
            }
            else
            {
                return "<span class='earn-table-badge badge-delivered' style='padding:4px 8px;'>ACTIVE</span>";
            }
        }

        public string FormatCouponDate(object dateObj)
        {
            if (dateObj == null || dateObj == DBNull.Value) return "N/A";
            return Convert.ToDateTime(dateObj).ToString("dd MMM yyyy");
        }

        public bool IsCouponActive(object activeObj)
        {
            if (activeObj == null || activeObj == DBNull.Value) return false;
            return Convert.ToBoolean(activeObj);
        }

        private void ShowModalError(string msg)
        {
            lblModalError.Text = msg;
            lblModalError.Visible = true;
            upnlModal.Update();
        }

        private void ShowGlobalAlert(string msg, bool success)
        {
            lblGlobalMsg.Text = msg;
            lblGlobalMsg.Visible = true;
            if (success)
            {
                lblGlobalMsg.Style["background"] = "#ecfdf5";
                lblGlobalMsg.Style["border-left"] = "5px solid #10b981";
                lblGlobalMsg.Style["color"] = "#065f46";
            }
            else
            {
                lblGlobalMsg.Style["background"] = "#fef2f2";
                lblGlobalMsg.Style["border-left"] = "5px solid #ef4444";
                lblGlobalMsg.Style["color"] = "#991b1b";
            }
            upnlMsg.Update();
        }
    }
}
