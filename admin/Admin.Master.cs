using System;
using System.Web.UI;
using System.Configuration;
using System.Data.SqlClient;

namespace ecommerce_mlm.admin
{
    public partial class Admin : MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            // AUTH LOCK
            if (Session["AdminId"] == null || Session["Role"] == null || Session["Role"].ToString() != "Admin")
            {
                Response.Redirect("AdminLogin.aspx");
            }
            else
            {
                if (!IsPostBack)
                {
                    litAdminName.Text = Session["AdminName"] != null ? Session["AdminName"].ToString() : "Administrator";
                    LoadNotificationCounts();
                }
            }
        }

        private void LoadNotificationCounts()
        {
            try {
                string strcon = ConfigurationManager.ConnectionStrings["MlmDb"].ConnectionString;
                using(SqlConnection con = new SqlConnection(strcon)) {
                    con.Open();
                    
                    // Aggregate 1: Pending Account Deletions (User + Seller)
                    string sql = @"SELECT 
                                   (SELECT COUNT(*) FROM AccountDeleteRequests WHERE Status NOT IN ('COMPLETED','CANCELLED','APPROVED')) +
                                   (SELECT COUNT(*) FROM SellerUsers WHERE DeletionStatus IS NOT NULL AND DeletionStatus NOT IN ('None','Approved'))";
                    
                    SqlCommand cmd = new SqlCommand(sql, con);
                    int count = Convert.ToInt32(cmd.ExecuteScalar());
                    
                    if(count > 0) {
                        litDelBadge.Text = string.Format("<span class='nav-count-pill'>{0}</span>", count);
                    }
                }
            } catch { }
        }

        protected void lnkLogout_Click(object sender, EventArgs e)
        {
            Session.Abandon();
            Response.Redirect("AdminLogin.aspx");
        }
    }
}
