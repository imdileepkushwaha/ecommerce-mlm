using System;
using System.Configuration;
using System.Data.SqlClient;
using System.Text;
using System.Web.UI;

namespace ecommerce_mlm.admin
{
    public partial class Admin : MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["AdminId"] == null || Session["Role"] == null || Session["Role"].ToString() != "Admin")
            {
                Response.Redirect("AdminLogin.aspx");
            }
            else if (!IsPostBack)
            {
                string name = Session["AdminName"] != null ? Session["AdminName"].ToString() : "Administrator";
                litAdminName.Text = name;
                litAdminInitials.Text = GetInitials(name);
                LoadNotificationCounts();
                LoadHeaderNotifications();
            }
        }

        private static string GetInitials(string name)
        {
            if (string.IsNullOrWhiteSpace(name)) return "AD";
            var parts = name.Trim().Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
            if (parts.Length >= 2)
                return (parts[0].Substring(0, 1) + parts[1].Substring(0, 1)).ToUpperInvariant();
            return name.Length >= 2 ? name.Substring(0, 2).ToUpperInvariant() : name.Substring(0, 1).ToUpperInvariant();
        }

        private void LoadNotificationCounts()
        {
            try
            {
                string strcon = ConfigurationManager.ConnectionStrings["MlmDb"].ConnectionString;
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();

                    string sql = @"SELECT 
                                   (SELECT COUNT(*) FROM AccountDeleteRequests WHERE Status NOT IN ('COMPLETED','CANCELLED','APPROVED')) +
                                   (SELECT COUNT(*) FROM SellerUsers WHERE DeletionStatus IS NOT NULL AND DeletionStatus NOT IN ('None','Approved'))";

                    int delCount = Convert.ToInt32(new SqlCommand(sql, con).ExecuteScalar());
                    if (delCount > 0)
                        litDelBadge.Text = string.Format("<span class='nav-count-pill'>{0}</span>", delCount);

                    string sqlKyc = "SELECT COUNT(*) FROM SellerUsers WHERE KycStatus = 'Pending' OR EditRequestStatus IN ('PendingApproval', 'DraftSubmitted')";
                    int kycCount = Convert.ToInt32(new SqlCommand(sqlKyc, con).ExecuteScalar());
                    if (kycCount > 0)
                        litKycBadge.Text = string.Format("<span class='nav-count-pill'>{0}</span>", kycCount);
                }
            }
            catch { }
        }

        private void LoadHeaderNotifications()
        {
            var sb = new StringBuilder();
            int totalAlerts = 0;

            try
            {
                string strcon = ConfigurationManager.ConnectionStrings["MlmDb"].ConnectionString;
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();

                    int kycCount = Convert.ToInt32(new SqlCommand(
                        "SELECT COUNT(*) FROM SellerUsers WHERE KycStatus = 'Pending' OR EditRequestStatus IN ('PendingApproval', 'DraftSubmitted')", con).ExecuteScalar());
                    if (kycCount > 0)
                    {
                        totalAlerts += kycCount;
                        sb.AppendFormat("<a href='KycAudits.aspx' class='hdr-notif-item'><i class='fas fa-id-card'></i><span><strong>{0} KYC request(s)</strong><em>Pending seller verification</em></span></a>", kycCount);
                    }

                    string delSql = @"SELECT 
                        (SELECT COUNT(*) FROM AccountDeleteRequests WHERE Status NOT IN ('COMPLETED','CANCELLED','APPROVED')) +
                        (SELECT COUNT(*) FROM SellerUsers WHERE DeletionStatus IS NOT NULL AND DeletionStatus NOT IN ('None','Approved'))";
                    int delCount = Convert.ToInt32(new SqlCommand(delSql, con).ExecuteScalar());
                    if (delCount > 0)
                    {
                        totalAlerts += delCount;
                        sb.AppendFormat("<a href='AccountDeletions.aspx' class='hdr-notif-item'><i class='fas fa-user-minus'></i><span><strong>{0} deletion request(s)</strong><em>Requires admin review</em></span></a>", delCount);
                    }

                    int procCount = Convert.ToInt32(new SqlCommand(
                        "SELECT COUNT(*) FROM Orders WHERE Status IN ('Pending','Placed','Processing','Confirmed')", con).ExecuteScalar());
                    if (procCount > 0)
                    {
                        totalAlerts += procCount;
                        sb.AppendFormat("<a href='ManageOrders.aspx' class='hdr-notif-item'><i class='fas fa-receipt'></i><span><strong>{0} order(s) processing</strong><em>Awaiting fulfilment</em></span></a>", procCount);
                    }
                }
            }
            catch { }

            if (sb.Length == 0)
                litNotifList.Text = "<div class='hdr-drop-empty'>No new notifications</div>";
            else
                litNotifList.Text = sb.ToString();

            if (totalAlerts > 0)
                litNotifDot.Text = "<span id='hdrNotifDot' class='hdr-notif-dot'></span>";
            else
                litNotifDot.Text = "";
        }

        protected void lnkLogout_Click(object sender, EventArgs e)
        {
            Session.Abandon();
            Response.Redirect("AdminLogin.aspx");
        }
    }
}
