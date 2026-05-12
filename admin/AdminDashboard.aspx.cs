using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Web.UI;

namespace ecommerce_mlm.admin
{
    public partial class AdminDashboard : Page
    {
        string strcon = ConfigurationManager.ConnectionStrings["MlmDb"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!IsPostBack)
            {
                LoadDashboardMetrics();
            }
        }

        private void LoadDashboardMetrics()
        {
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    
                    // 1. Total Users
                    using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM Users", con)) {
                        litTotalUsers.Text = Convert.ToInt32(cmd.ExecuteScalar()).ToString("N0");
                    }

                    // 2. Gross Revenue
                    using (SqlCommand cmd = new SqlCommand("SELECT ISNULL(SUM(TotalAmount), 0) FROM Orders", con)) {
                        decimal rev = Convert.ToDecimal(cmd.ExecuteScalar());
                        litRevenue.Text = "₹" + rev.ToString("N0");
                    }

                    // 3. Pending Orders
                    using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM Orders WHERE Status = 'Pending'", con)) {
                        litPendingOrders.Text = Convert.ToInt32(cmd.ExecuteScalar()).ToString("N0");
                    }

                    // 4. Registered Products
                    using (SqlCommand cmd = new SqlCommand("SELECT COUNT(*) FROM SellerProducts", con)) {
                        litTotalProducts.Text = Convert.ToInt32(cmd.ExecuteScalar()).ToString("N0");
                    }
                }
            }
            catch (Exception ex) 
            {
                litTotalUsers.Text = "0";
                litRevenue.Text = "₹0";
                litPendingOrders.Text = "0";
                litTotalProducts.Text = "0";
            }
        }
    }
}
