using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace EcommerceWebsite
{
    public partial class SellerEarnings : System.Web.UI.Page
    {
        string strcon = ConfigurationManager.ConnectionStrings["MlmDb"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            // Verify double-security
            if (Session["SellerId"] == null)
            {
                Response.Redirect("Login.aspx");
                return;
            }

            // 1. Provision Table Schema
            EnsureSellerPayoutSchema();

            if (!IsPostBack)
            {
                // Clear any leftover state
                Session["WithdrawOtp"] = null;
                Session["WithdrawAmount"] = null;

                // Load initial content
                RefreshWorkspace();
            }
        }

        private void EnsureSellerPayoutSchema()
        {
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    string sql = @"
                        IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'SellerPayoutRequests')
                        BEGIN
                            CREATE TABLE SellerPayoutRequests (
                                Id INT PRIMARY KEY IDENTITY(1,1),
                                SellerId INT NOT NULL,
                                RequestAmount DECIMAL(18, 2) NOT NULL,
                                Status NVARCHAR(50) NOT NULL DEFAULT 'PENDING', -- PENDING, PAID, REJECTED
                                PaymentMethod NVARCHAR(100) NOT NULL DEFAULT 'Bank Transfer',
                                TransactionId NVARCHAR(100) NULL,
                                PaidDate DATETIME NULL,
                                AdminRemarks NVARCHAR(MAX) NULL,
                                CreatedAt DATETIME DEFAULT GETDATE(),
                                ReferenceNumber NVARCHAR(50) NULL
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

        private void RefreshWorkspace()
        {
            int sellerId = Convert.ToInt32(Session["SellerId"]);
            
            // 1. Compute aggregate statistics
            LoadStatistics(sellerId);

            // 2. Fetch tables datasets
            BindDeliveredOrders(sellerId);
            BindWithdrawRequests(sellerId);
        }

        private void LoadStatistics(int sid)
        {
            try
            {
                decimal totalDelivered = 0;
                decimal paidOut = 0;
                decimal pendingWithdraw = 0;
                decimal pipeline = 0;

                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();

                    // Query 1: Total Delivered orders for this seller
                    string deliveredSql = @"
                        SELECT ISNULL(SUM(oi.Quantity * oi.UnitPrice), 0)
                        FROM OrderItems oi
                        JOIN Orders o ON oi.OrderId = o.Id
                        JOIN SellerProducts p ON oi.ProductId = p.Id
                        WHERE p.SellerId = @sid AND o.Status = 'Delivered'";
                    using (SqlCommand cmd = new SqlCommand(deliveredSql, con))
                    {
                        cmd.Parameters.AddWithValue("@sid", sid);
                        totalDelivered = Convert.ToDecimal(cmd.ExecuteScalar());
                    }

                    // Query 2: Paid Out (Settled Payouts)
                    string paidSql = @"
                        SELECT ISNULL(SUM(RequestAmount), 0)
                        FROM SellerPayoutRequests
                        WHERE SellerId = @sid AND Status = 'PAID'";
                    using (SqlCommand cmd = new SqlCommand(paidSql, con))
                    {
                        cmd.Parameters.AddWithValue("@sid", sid);
                        paidOut = Convert.ToDecimal(cmd.ExecuteScalar());
                    }

                    // Query 3: Pending Withdraw
                    string pendingSql = @"
                        SELECT ISNULL(SUM(RequestAmount), 0)
                        FROM SellerPayoutRequests
                        WHERE SellerId = @sid AND Status = 'PENDING'";
                    using (SqlCommand cmd = new SqlCommand(pendingSql, con))
                    {
                        cmd.Parameters.AddWithValue("@sid", sid);
                        pendingWithdraw = Convert.ToDecimal(cmd.ExecuteScalar());
                    }

                    // Query 4: Pipeline (intermediate orders)
                    string pipelineSql = @"
                        SELECT ISNULL(SUM(oi.Quantity * oi.UnitPrice), 0)
                        FROM OrderItems oi
                        JOIN Orders o ON oi.OrderId = o.Id
                        JOIN SellerProducts p ON oi.ProductId = p.Id
                        WHERE p.SellerId = @sid 
                          AND o.Status IN ('Placed', 'Pending', 'Processing', 'Confirmed', 'Shipped', 'Out for delivery')";
                    using (SqlCommand cmd = new SqlCommand(pipelineSql, con))
                    {
                        cmd.Parameters.AddWithValue("@sid", sid);
                        pipeline = Convert.ToDecimal(cmd.ExecuteScalar());
                    }
                }

                // Compute dependent variables
                decimal sellerProfit = totalDelivered; // Delivered forms credited lifetime total
                decimal withdrawable = totalDelivered - paidOut - pendingWithdraw;
                if (withdrawable < 0) withdrawable = 0; // Guard negative thresholds

                // Save to ViewState for validation checks during modals
                ViewState["WithdrawableVal"] = withdrawable;

                // Bind to visual elements
                litDeliveredCredited.Text = totalDelivered.ToString("N0");
                litSellerProfit.Text = sellerProfit.ToString("N0");
                litWithdrawable.Text = withdrawable.ToString("N0");
                litPendingWithdraw.Text = pendingWithdraw.ToString("N0");
                litPaidOut.Text = paidOut.ToString("N0");
                litPipeline.Text = pipeline.ToString("N0");

                // Preview values inside Modal screen
                litModalWithdrawable.Text = withdrawable.ToString("N0");
            }
            catch (Exception ex)
            {
                ShowAlert("alert-danger", "Error loading financial breakdown: " + ex.Message);
            }
        }

        private void BindDeliveredOrders(int sid)
        {
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    string sql = @"
                        SELECT DISTINCT 
                            o.Id,
                            o.OrderRef,
                            o.CreatedAt,
                            (SELECT SUM(oi2.Quantity) 
                             FROM OrderItems oi2 
                             JOIN SellerProducts p2 ON oi2.ProductId = p2.Id 
                             WHERE oi2.OrderId = o.Id AND p2.SellerId = @sid) as SellerItemCount,
                            (SELECT SUM(oi2.UnitPrice * oi2.Quantity) 
                             FROM OrderItems oi2 
                             JOIN SellerProducts p2 ON oi2.ProductId = p2.Id 
                             WHERE oi2.OrderId = o.Id AND p2.SellerId = @sid) as SellerTotalAmount
                        FROM Orders o
                        JOIN OrderItems oi ON o.Id = oi.OrderId
                        JOIN SellerProducts p ON oi.ProductId = p.Id
                        WHERE p.SellerId = @sid AND o.Status = 'Delivered'";

                    using (SqlCommand cmd = new SqlCommand(sql, con))
                    {
                        cmd.Parameters.AddWithValue("@sid", sid);
                        SqlDataAdapter da = new SqlDataAdapter(cmd);
                        DataTable dt = new DataTable();
                        da.Fill(dt);

                        // Apply dynamic memory filters based on user text query
                        string search = txtSearchOrders.Text.Trim();
                        if (!string.IsNullOrEmpty(search))
                        {
                            DataView dv = new DataView(dt);
                            dv.RowFilter = string.Format("OrderRef LIKE '%{0}%' OR Convert(Id, 'System.String') LIKE '%{0}%' OR Convert(SellerTotalAmount, 'System.String') LIKE '%{0}%'", search.Replace("'", "''"));
                            dt = dv.ToTable();
                        }

                        int count = dt.Rows.Count;
                        litDeliveredBadgeCount.Text = count.ToString();
                        litPaginationTotal.Text = count.ToString();
                        litPaginationRange.Text = count > 0 ? "1-" + count : "0-0";

                        if (count > 0)
                        {
                            rptDeliveredOrders.DataSource = dt;
                            rptDeliveredOrders.DataBind();
                            rptDeliveredOrders.Visible = true;
                            phEmptyOrders.Visible = false;
                        }
                        else
                        {
                            rptDeliveredOrders.DataSource = null;
                            rptDeliveredOrders.DataBind();
                            rptDeliveredOrders.Visible = false;
                            phEmptyOrders.Visible = true;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                Response.Write("<script>console.error('Delivered order binding error: " + ex.Message + "');</script>");
            }
        }

        private void BindWithdrawRequests(int sid)
        {
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    string sql = "SELECT * FROM SellerPayoutRequests WHERE SellerId = @sid ORDER BY CreatedAt DESC";
                    using (SqlCommand cmd = new SqlCommand(sql, con))
                    {
                        cmd.Parameters.AddWithValue("@sid", sid);
                        SqlDataAdapter da = new SqlDataAdapter(cmd);
                        DataTable dt = new DataTable();
                        da.Fill(dt);

                        // Apply dynamic text query filter
                        string search = txtSearchWithdraws.Text.Trim();
                        if (!string.IsNullOrEmpty(search))
                        {
                            DataView dv = new DataView(dt);
                            dv.RowFilter = string.Format("ReferenceNumber LIKE '%{0}%' OR Status LIKE '%{0}%' OR Convert(RequestAmount, 'System.String') LIKE '%{0}%' OR PaymentMethod LIKE '%{0}%'", search.Replace("'", "''"));
                            dt = dv.ToTable();
                        }

                        int count = dt.Rows.Count;
                        litWithdrawRequestsBadge.Text = count.ToString();
                        litWithdrawPaginationTotal.Text = count.ToString();
                        litWithdrawPaginationRange.Text = count > 0 ? "1-" + count : "0-0";

                        if (count > 0)
                        {
                            rptWithdrawRequests.DataSource = dt;
                            rptWithdrawRequests.DataBind();
                            rptWithdrawRequests.Visible = true;
                            phEmptyWithdraws.Visible = false;
                        }
                        else
                        {
                            rptWithdrawRequests.DataSource = null;
                            rptWithdrawRequests.DataBind();
                            rptWithdrawRequests.Visible = false;
                            phEmptyWithdraws.Visible = true;
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                Response.Write("<script>console.error('Withdrawals binding failure: " + ex.Message + "');</script>");
            }
        }

        protected string GetWithdrawStatusBadge(object statusObj)
        {
            string status = statusObj != DBNull.Value ? statusObj.ToString().Trim().ToUpper() : "PENDING";
            string cssClass = "earn-table-badge";

            if (status == "PAID")
            {
                cssClass += " badge-delivered"; // Uses clean green background from css
            }
            else if (status == "REJECTED")
            {
                cssClass += " badge-cancelled"; // Uses clean red background from css
            }
            else
            {
                cssClass += " badge-pending"; // Uses clean yellow background from css
            }

            return string.Format("<span class='{0}'>{1}</span>", cssClass, status);
        }

        // --- FILTER TEXTBOX TRIGGERS ---
        protected void txtSearchOrders_TextChanged(object sender, EventArgs e)
        {
            int sellerId = Convert.ToInt32(Session["SellerId"]);
            BindDeliveredOrders(sellerId);
        }

        protected void txtSearchWithdraws_TextChanged(object sender, EventArgs e)
        {
            int sellerId = Convert.ToInt32(Session["SellerId"]);
            BindWithdrawRequests(sellerId);
        }

        // --- WITHDRAW OTP DIALOG MODAL TRIGGERS ---
        protected void btnOpenWithdraw_Click(object sender, EventArgs e)
        {
            lblMsg.Visible = false; // Reset global messages
            int sellerId = Convert.ToInt32(Session["SellerId"]);

            // 1. Fetch Withdrawable Balance
            LoadStatistics(sellerId);
            decimal withdrawable = ViewState["WithdrawableVal"] != null ? (decimal)ViewState["WithdrawableVal"] : 0;

            if (withdrawable < 200)
            {
                ShowAlert("alert-warning", "Minimum limit ₹200. Request cannot be authorized since your withdrawable balance is ₹" + withdrawable.ToString("N0") + ".");
                return;
            }

            // 2. Fetch Bank Details for merchant preview
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    string sql = "SELECT BankName, BankAccountNumber, BankHolderName FROM SellerUsers WHERE Id = @sid";
                    using (SqlCommand cmd = new SqlCommand(sql, con))
                    {
                        cmd.Parameters.AddWithValue("@sid", sellerId);
                        using (SqlDataReader dr = cmd.ExecuteReader())
                        {
                            if (dr.Read())
                            {
                                litModalBankName.Text = dr["BankName"] != DBNull.Value ? dr["BankName"].ToString() : "—";
                                litModalAccNumber.Text = dr["BankAccountNumber"] != DBNull.Value ? dr["BankAccountNumber"].ToString() : "—";
                                litModalHolderName.Text = dr["BankHolderName"] != DBNull.Value ? dr["BankHolderName"].ToString() : "—";
                            }
                            else
                            {
                                litModalBankName.Text = "No bank verified";
                                litModalAccNumber.Text = "—";
                                litModalHolderName.Text = "—";
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                Response.Write("<script>console.error('Bank read failure: " + ex.Message + "');</script>");
            }

            // 3. Display Modal Screen 1 (Amount selection)
            pnlWithdrawModal.Visible = true;
            phModalScreenAmount.Visible = true;
            phModalScreenOtp.Visible = false;
            phModalScreenSuccess.Visible = false;

            txtWithdrawAmount.Text = withdrawable.ToString("0"); // Auto-fill max by default
        }

        protected void btnCloseModal_Click(object sender, EventArgs e)
        {
            pnlWithdrawModal.Visible = false;
            txtWithdrawAmount.Text = "";
            txtOtpInput.Text = "";
            Session["WithdrawOtp"] = null;
            Session["WithdrawAmount"] = null;
            
            // Refresh main interface balances
            RefreshWorkspace();
        }

        protected void btnNextToOtp_Click(object sender, EventArgs e)
        {
            decimal amt = 0;
            if (!decimal.TryParse(txtWithdrawAmount.Text.Trim(), out amt) || amt < 200)
            {
                ShowAlert("alert-danger", "Please enter a valid amount greater than or equal to ₹200.");
                return;
            }

            decimal withdrawable = ViewState["WithdrawableVal"] != null ? (decimal)ViewState["WithdrawableVal"] : 0;
            if (amt > withdrawable)
            {
                ShowAlert("alert-danger", "Insufficient funds. Maximum withdrawable amount is ₹" + withdrawable.ToString("N0"));
                return;
            }

            // Save amount value
            Session["WithdrawAmount"] = amt;
            litOtpTargetAmount.Text = amt.ToString("N0");

            // Generate premium 6-digit dynamic OTP authorization
            string otp = new Random().Next(100000, 999999).ToString();
            Session["WithdrawOtp"] = otp;
            litMockOtpCode.Text = otp; // Pre-filled for demo ease

            // Switch Screen
            phModalScreenAmount.Visible = false;
            phModalScreenOtp.Visible = true;
            phModalScreenSuccess.Visible = false;
            txtOtpInput.Text = "";
        }

        protected void btnBackToAmount_Click(object sender, EventArgs e)
        {
            phModalScreenAmount.Visible = true;
            phModalScreenOtp.Visible = false;
            phModalScreenSuccess.Visible = false;
        }

        protected void btnAuthorizePayout_Click(object sender, EventArgs e)
        {
            string storedOtp = Session["WithdrawOtp"] as string;
            string enteredOtp = txtOtpInput.Text.Trim();

            if (string.IsNullOrEmpty(storedOtp) || enteredOtp != storedOtp)
            {
                // Custom javascript injection alert
                ScriptManager.RegisterStartupScript(this, this.GetType(), "OtpError", "alert('Incorrect verification code. Please check mock credentials and enter again!');", true);
                return;
            }

            decimal amt = Session["WithdrawAmount"] != null ? (decimal)Session["WithdrawAmount"] : 0;
            int sellerId = Convert.ToInt32(Session["SellerId"]);

            if (amt <= 0)
            {
                btnCloseModal_Click(null, null);
                return;
            }

            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();

                    // Insert Payout request
                    string sql = @"
                        INSERT INTO SellerPayoutRequests (SellerId, RequestAmount, Status, PaymentMethod, CreatedAt)
                        VALUES (@sid, @amt, 'PENDING', 'Bank Transfer', GETDATE());
                        SELECT SCOPE_IDENTITY();";

                    int insertId = 0;
                    using (SqlCommand cmd = new SqlCommand(sql, con))
                    {
                        cmd.Parameters.AddWithValue("@sid", sellerId);
                        cmd.Parameters.AddWithValue("@amt", amt);
                        insertId = Convert.ToInt32(cmd.ExecuteScalar());
                    }

                    // Format reference code WRXXXXXX
                    string refNo = "WR" + insertId.ToString("D6");

                    // Update Row with reference code
                    string updateSql = "UPDATE SellerPayoutRequests SET ReferenceNumber = @ref WHERE Id = @id";
                    using (SqlCommand cmdUp = new SqlCommand(updateSql, con))
                    {
                        cmdUp.Parameters.AddWithValue("@ref", refNo);
                        cmdUp.Parameters.AddWithValue("@id", insertId);
                        cmdUp.ExecuteNonQuery();
                    }

                    // Switch modal Screen to success layout
                    litSuccessAmount.Text = amt.ToString("N0");
                    litSuccessRefId.Text = refNo;

                    phModalScreenAmount.Visible = false;
                    phModalScreenOtp.Visible = false;
                    phModalScreenSuccess.Visible = true;

                    // Clean references
                    Session["WithdrawOtp"] = null;
                    Session["WithdrawAmount"] = null;
                }
            }
            catch (Exception ex)
            {
                ShowAlert("alert-danger", "Payout creation routing failed: " + ex.Message);
            }
        }

        private void ShowAlert(string css, string msg)
        {
            lblMsg.Text = msg;
            lblMsg.CssClass = "alert " + css;
            lblMsg.Style["background-color"] = css.Contains("danger") ? "#fef2f2" : css.Contains("warning") ? "#fffbeb" : "#f0fdf4";
            lblMsg.Style["color"] = css.Contains("danger") ? "#991b1b" : css.Contains("warning") ? "#92400e" : "#166534";
            lblMsg.Style["border"] = css.Contains("danger") ? "1px solid #fee2e2" : css.Contains("warning") ? "1px solid #fef3c7" : "1px solid #dcfce7";
            lblMsg.Visible = true;
        }
    }
}
