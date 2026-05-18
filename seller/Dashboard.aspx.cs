using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace EcommerceWebsite
{
    public partial class SellerDashboard : System.Web.UI.Page
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

            if (!IsPostBack)
            {
                int sellerId = Convert.ToInt32(Session["SellerId"]);
                
                // 1. Block UI access if compliance audit fails
                CheckKycStatus(sellerId);
                
                // 2. Load comprehensive analytics using our high-speed Stored Procedure
                LoadDashboardUnifiedData(sellerId);
            }
        }

        private void CheckKycStatus(int sid)
        {
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    string sql = "SELECT KycStatus FROM SellerUsers WHERE Id = @sid";
                    using (SqlCommand cmd = new SqlCommand(sql, con))
                    {
                        cmd.Parameters.AddWithValue("@sid", sid);
                        object val = cmd.ExecuteScalar();
                        string kyc = (val != null && val != DBNull.Value) ? val.ToString() : "";

                        // Block is visible if KYC is not 100% APPROVED by admin
                        pnlKycBlocker.Visible = !kyc.Equals("Approved", StringComparison.OrdinalIgnoreCase);
                    }
                }
            }
            catch
            {
                pnlKycBlocker.Visible = true; // Fail-safe lock
            }
        }

        /// <summary>
        /// Leverages SQL Stored Procedure 'dbo.GetSellerDashboardMetrics' to fetch
        /// both aggregate analytics and recent orders in a SINGLE database roundtrip!
        /// </summary>
        private void LoadDashboardUnifiedData(int sid)
        {
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    using (SqlCommand cmd = new SqlCommand("dbo.GetSellerDashboardMetrics", con))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;
                        cmd.Parameters.AddWithValue("@SellerId", sid);

                        using (SqlDataAdapter da = new SqlDataAdapter(cmd))
                        {
                            DataSet ds = new DataSet();
                            da.Fill(ds);

                            // === SEGMENT A: ANALYTICS TELEMETRY (TABLE 0) ===
                            if (ds.Tables.Count > 0 && ds.Tables[0].Rows.Count > 0)
                            {
                                DataRow r = ds.Tables[0].Rows[0];
                                
                                litTotalProducts.Text = r["TotalProducts"] != DBNull.Value 
                                                        ? r["TotalProducts"].ToString() 
                                                        : "0";
                                
                                litTotalEarnings.Text = r["TotalEarnings"] != DBNull.Value 
                                                        ? Convert.ToDecimal(r["TotalEarnings"]).ToString("N2") 
                                                        : "0.00";
                                
                                litUnitsSold.Text = r["TotalUnitsSold"] != DBNull.Value 
                                                    ? r["TotalUnitsSold"].ToString() 
                                                    : "0";
                                
                                litPendingOrders.Text = r["PendingOrders"] != DBNull.Value 
                                                        ? r["PendingOrders"].ToString() 
                                                        : "0";
                                
                                // Direct bind to Snapshot card
                                litSnapProducts.Text = litTotalProducts.Text;
                            }

                            // === SEGMENT B: RECENT ORDERS GRID (TABLE 1) ===
                            if (ds.Tables.Count > 1)
                            {
                                DataTable dtOrders = ds.Tables[1];
                                if (dtOrders.Rows.Count > 0)
                                {
                                    rptRecentOrders.DataSource = dtOrders;
                                    rptRecentOrders.DataBind();
                                    rptRecentOrders.Visible = true;
                                    phEmptyState.Visible = false;
                                }
                                else
                                {
                                    rptRecentOrders.Visible = false;
                                    phEmptyState.Visible = true;
                                }
                            }
                            else
                            {
                                rptRecentOrders.Visible = false;
                                phEmptyState.Visible = true;
                            }

                            // 3. Load dynamic snapshot counts
                            LoadSnapshotMetrics(sid);
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                // Fail-safe rendering on analytical breakdown
                rptRecentOrders.Visible = false;
                phEmptyState.Visible = true;
            }
        }

        private void LoadSnapshotMetrics(int sid)
        {
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();

                    // Query 1: All time unique orders for this seller
                    string qAllOrders = @"
                        SELECT COUNT(DISTINCT oi.OrderId) 
                        FROM OrderItems oi 
                        JOIN SellerProducts p ON oi.ProductId = p.Id 
                        WHERE p.SellerId = @sid";
                    using (SqlCommand cmd = new SqlCommand(qAllOrders, con))
                    {
                        cmd.Parameters.AddWithValue("@sid", sid);
                        litSnapAllOrders.Text = cmd.ExecuteScalar().ToString();
                    }

                    // Query 2: Pending/needs confirmation unique orders count
                    string qPendingOrders = @"
                        SELECT COUNT(DISTINCT oi.OrderId) 
                        FROM OrderItems oi 
                        JOIN Orders o ON oi.OrderId = o.Id 
                        JOIN SellerProducts p ON oi.ProductId = p.Id 
                        WHERE p.SellerId = @sid AND o.Status IN ('Placed', 'Pending', 'Processing')";
                    using (SqlCommand cmd = new SqlCommand(qPendingOrders, con))
                    {
                        cmd.Parameters.AddWithValue("@sid", sid);
                        litSnapPending.Text = cmd.ExecuteScalar().ToString();
                    }
                }
            }
            catch
            {
                litSnapAllOrders.Text = "0";
                litSnapPending.Text = "0";
            }
        }

        protected string GetStatusClass(object status)
        {
            if (status == null || status == DBNull.Value) return "badge-pending";
            string s = status.ToString().ToLower();
            
            switch(s)
            {
                case "pending": return "badge-pending";
                case "shipped": return "badge-shipped";
                case "delivered": return "badge-delivered";
                case "cancelled": return "badge-cancelled";
                default: return "badge-pending";
            }
        }
    }
}
