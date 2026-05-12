using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI;

namespace ecommerce_mlm
{
    public partial class userRewards : System.Web.UI.Page
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
                int uid = GetUserId();
                if (uid > 0)
                {
                    // First, Run live auto-sync to make data 100% fresh and accurate!
                    RunLivePointSync(uid);
                    // Then, render to view.
                    LoadDashboardMetrics(uid);
                    LoadHistoryGrid(uid);
                }
            }
        }

        private int GetUserId()
        {
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

        private void RunLivePointSync(int uid)
        {
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    SqlCommand cmd = new SqlCommand("sp_SyncUserRewards", con);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@UserId", uid);
                    cmd.ExecuteNonQuery();
                }
            }
            catch { }
        }

        private void LoadDashboardMetrics(int uid)
        {
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();
                    string q = @"
                        SELECT 
                            ISNULL(SUM(CASE WHEN Status = 'CREDITED' THEN PointsEarned ELSE 0 END), 0) as Available,
                            ISNULL(SUM(CASE WHEN Status = 'PENDING' THEN PointsEarned ELSE 0 END), 0) as Pending,
                            ISNULL(SUM(CASE WHEN Status IN ('CREDITED', 'EXPIRED') THEN PointsEarned ELSE 0 END), 0) as Lifetime
                        FROM UserRewards WHERE UserId = @uid";
                    SqlCommand cmd = new SqlCommand(q, con);
                    cmd.Parameters.AddWithValue("@uid", uid);
                    SqlDataReader dr = cmd.ExecuteReader();
                    if (dr.Read())
                    {
                        long avail = Convert.ToInt64(dr["Available"]);
                        long pend = Convert.ToInt64(dr["Pending"]);
                        long life = Convert.ToInt64(dr["Lifetime"]);

                        lblTotalPoints.Text = avail.ToString("N0");
                        lblPendingPoints.Text = pend.ToString("N0");
                        lblTotalEarned.Text = life.ToString("N0");

                        // Conversion Logic: 1000 Points = 10 Rupees. (Basically Points / 100)
                        decimal cashVal = (decimal)avail / 100.0m;
                        lblCashValue.Text = cashVal.ToString("0.00");
                    }
                }
            }
            catch { }
        }

        private void LoadHistoryGrid(int uid)
        {
            try
            {
                using (SqlConnection con = new SqlConnection(strcon))
                {
                    string q = "SELECT * FROM UserRewards WHERE UserId = @uid ORDER BY CreatedAt DESC";
                    SqlCommand cmd = new SqlCommand(q, con);
                    cmd.Parameters.AddWithValue("@uid", uid);
                    SqlDataAdapter da = new SqlDataAdapter(cmd);
                    DataTable dt = new DataTable();
                    da.Fill(dt);

                    if (dt.Rows.Count > 0)
                    {
                        rptRewards.DataSource = dt;
                        rptRewards.DataBind();
                        rptRewards.Visible = true;
                        pnlNoRewards.Visible = false;
                    }
                    else
                    {
                        rptRewards.Visible = false;
                        pnlNoRewards.Visible = true;
                    }
                }
            }
            catch { }
        }

        // PUBLIC UI HELPERS ACCESSED BY ASPX

        public string GetPointBadgeClass(string status)
        {
            switch (status.ToUpper())
            {
                case "CREDITED": return "pts-badge pts-earned";
                case "PENDING": return "pts-badge pts-pending";
                case "CANCELLED": return "pts-badge pts-cancelled";
                case "EXPIRED": return "pts-badge pts-expired";
                default: return "pts-badge";
            }
        }

        public string GetFriendlyStatus(string status)
        {
            switch (status.ToUpper())
            {
                case "CREDITED": return "<span style='color:#059669; font-weight:600;'><i class='fas fa-check-circle'></i> Cleared</span>";
                case "PENDING": return "<span style='color:#d97706; font-weight:600;'><i class='fas fa-hourglass-half'></i> Holding</span>";
                case "CANCELLED": return "<span style='color:#94a3b8; font-weight:600;'><i class='fas fa-ban'></i> Reversed</span>";
                case "EXPIRED": return "<span style='color:#64748b; font-weight:600;'><i class='fas fa-calendar-times'></i> Expired</span>";
                default: return status;
            }
        }

        public string GetExpiryHtml(string status, object expDate)
        {
            if (status.ToUpper() == "CREDITED" && expDate != DBNull.Value)
            {
                DateTime dt = Convert.ToDateTime(expDate);
                TimeSpan remaining = dt - DateTime.Now;
                int days = Math.Max(0, (int)remaining.TotalDays);
                return string.Format("<div class='exp-timer'><i class='fas fa-history'></i> {0} days left</div>", days);
            }
            else if (status.ToUpper() == "PENDING")
            {
                return "<span style='font-size:0.75rem; color:#64748b;'>Unlocks 10 days post-delivery</span>";
            }
            return "-";
        }
    }
}
