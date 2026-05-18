using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
using System.Web.Script.Serialization;
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
                LoadDashboard();
            }
        }

        protected void btnRefresh_Click(object sender, EventArgs e)
        {
            LoadDashboard();
        }

        private void LoadDashboard()
        {
            try
            {
                string adminName = Session["AdminName"] != null ? Session["AdminName"].ToString() : "Admin";
                string firstName = adminName.Split(' ')[0];
                litWelcomeName.Text = firstName;
                litDateRange.Text = DateTime.Today.AddDays(-29).ToString("dd MMM yy", CultureInfo.InvariantCulture)
                    + " - " + DateTime.Today.ToString("dd MMM yy", CultureInfo.InvariantCulture);

                using (SqlConnection con = new SqlConnection(strcon))
                {
                    con.Open();

                    int totalUsers = ScalarInt(con, "SELECT COUNT(*) FROM Users");
                    int totalOrders = ScalarInt(con, "SELECT COUNT(*) FROM Orders");
                    int processingQueue = ScalarInt(con, @"SELECT COUNT(*) FROM Orders WHERE Status IN ('Pending','Placed','Processing','Confirmed')");
                    decimal revenue = ScalarDecimal(con, "SELECT ISNULL(SUM(TotalAmount), 0) FROM Orders");
                    int activeSellers = ScalarInt(con, "SELECT COUNT(*) FROM SellerUsers");

                    litBannerUsers.Text = totalUsers.ToString("N0");
                    litBannerOrders.Text = totalOrders.ToString("N0");
                    litBannerProcessing.Text = processingQueue.ToString("N0");

                    litTotalOrders.Text = totalOrders.ToString("N0");
                    litRevenue.Text = "₹" + revenue.ToString("N0", CultureInfo.InvariantCulture);
                    litProcessing.Text = processingQueue.ToString("N0");
                    litTotalUsers.Text = totalUsers.ToString("N0");
                    litActiveSellers.Text = activeSellers.ToString("N0");

                    // Month-over-month trends
                    int ordersThisMonth = ScalarInt(con, @"SELECT COUNT(*) FROM Orders WHERE CreatedAt >= DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1)");
                    int ordersLastMonth = ScalarInt(con, @"SELECT COUNT(*) FROM Orders WHERE CreatedAt >= DATEADD(month, -1, DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1))
                        AND CreatedAt < DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1)");
                    litOrdersTrend.Text = WrapTrend(ordersThisMonth, ordersLastMonth);

                    decimal revThis = ScalarDecimal(con, @"SELECT ISNULL(SUM(TotalAmount),0) FROM Orders WHERE CreatedAt >= DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1)");
                    decimal revLast = ScalarDecimal(con, @"SELECT ISNULL(SUM(TotalAmount),0) FROM Orders WHERE CreatedAt >= DATEADD(month, -1, DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1))
                        AND CreatedAt < DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1)");
                    litRevenueTrend.Text = WrapTrend(revThis, revLast);

                    int usersWithOrders = ScalarInt(con, "SELECT COUNT(DISTINCT UserId) FROM Orders");
                    string usersPct = totalUsers > 0
                        ? string.Format("{0:0}% placed an order", (usersWithOrders * 100.0) / totalUsers)
                        : "0% placed an order";
                    litUsersTrend.Text = "<span class=\"adm-stat-trend adm-trend-up\">" + usersPct + "</span>";

                    int orders7d = ScalarInt(con, "SELECT COUNT(*) FROM Orders WHERE CreatedAt >= DATEADD(day, -6, CAST(GETDATE() AS DATE))");
                    litOrders7dSummary.Text = orders7d + " orders in the last 7 days";
                    litRevenueLifetime.Text = "₹" + revenue.ToString("N0", CultureInfo.InvariantCulture) + " lifetime revenue";

                    BindRecentOrders(con);
                    BindRecentUsers(con);
                    BindNeedsAttention(con);
                    hfChartData.Value = BuildChartJson(con);
                }
            }
            catch
            {
                litWelcomeName.Text = "Admin";
                litTotalOrders.Text = litRevenue.Text = litProcessing.Text = litTotalUsers.Text = litActiveSellers.Text = "0";
                litBannerUsers.Text = litBannerOrders.Text = litBannerProcessing.Text = "0";
            }
        }

        private void BindRecentOrders(SqlConnection con)
        {
            string sql = @"SELECT TOP 6 O.Id, O.OrderRef, O.TotalAmount, O.Status, O.CreatedAt, U.FullName
                FROM Orders O INNER JOIN Users U ON O.UserId = U.Id ORDER BY O.CreatedAt DESC";
            using (SqlDataAdapter da = new SqlDataAdapter(sql, con))
            {
                DataTable dt = new DataTable();
                da.Fill(dt);
                rptRecentOrders.DataSource = dt;
                rptRecentOrders.DataBind();
                phNoRecentOrders.Visible = dt.Rows.Count == 0;
            }
        }

        private void BindRecentUsers(SqlConnection con)
        {
            string sql = "SELECT TOP 5 Id, FullName, Email, CreatedAt FROM Users ORDER BY CreatedAt DESC";
            using (SqlDataAdapter da = new SqlDataAdapter(sql, con))
            {
                DataTable dt = new DataTable();
                da.Fill(dt);
                rptRecentUsers.DataSource = dt;
                rptRecentUsers.DataBind();
                phNoRecentUsers.Visible = dt.Rows.Count == 0;
            }
        }

        private void BindNeedsAttention(SqlConnection con)
        {
            string sql = @"SELECT TOP 5 O.Id, O.OrderRef, O.Status, O.CreatedAt
                FROM Orders O WHERE O.Status IN ('Pending','Placed','Processing','Confirmed')
                ORDER BY O.CreatedAt ASC";
            using (SqlDataAdapter da = new SqlDataAdapter(sql, con))
            {
                DataTable dt = new DataTable();
                da.Fill(dt);
                rptNeedsAttention.DataSource = dt;
                rptNeedsAttention.DataBind();
                phNoAttention.Visible = dt.Rows.Count == 0;
            }
        }

        private string BuildChartJson(SqlConnection con)
        {
            var labels7 = new List<string>();
            var data7 = new List<int>();
            for (int i = 6; i >= 0; i--)
            {
                DateTime d = DateTime.Today.AddDays(-i);
                labels7.Add(d.ToString("ddd", CultureInfo.InvariantCulture));
                data7.Add(0);
            }

            string sql7 = @"SELECT CAST(CreatedAt AS DATE) AS D, COUNT(*) AS Cnt
                FROM Orders WHERE CreatedAt >= DATEADD(day, -6, CAST(GETDATE() AS DATE))
                GROUP BY CAST(CreatedAt AS DATE)";
            using (SqlCommand cmd = new SqlCommand(sql7, con))
            using (SqlDataReader dr = cmd.ExecuteReader())
            {
                while (dr.Read())
                {
                    DateTime d = Convert.ToDateTime(dr["D"]).Date;
                    int idx = (int)(d - DateTime.Today.AddDays(-6)).TotalDays;
                    if (idx >= 0 && idx < 7) data7[idx] = Convert.ToInt32(dr["Cnt"]);
                }
            }

            var revLabels = new List<string>();
            var revData = new List<decimal>();
            for (int i = 5; i >= 0; i--)
            {
                DateTime m = DateTime.Today.AddMonths(-i);
                revLabels.Add(m.ToString("MMM", CultureInfo.InvariantCulture));
                revData.Add(0);
            }

            string sqlRev = @"SELECT YEAR(CreatedAt) AS Y, MONTH(CreatedAt) AS M, ISNULL(SUM(TotalAmount),0) AS Rev
                FROM Orders WHERE CreatedAt >= DATEADD(month, -5, DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1))
                GROUP BY YEAR(CreatedAt), MONTH(CreatedAt)";
            using (SqlCommand cmd = new SqlCommand(sqlRev, con))
            using (SqlDataReader dr = cmd.ExecuteReader())
            {
                while (dr.Read())
                {
                    int y = Convert.ToInt32(dr["Y"]);
                    int m = Convert.ToInt32(dr["M"]);
                    for (int i = 0; i < 6; i++)
                    {
                        DateTime target = DateTime.Today.AddMonths(-5 + i);
                        if (target.Year == y && target.Month == m)
                            revData[i] = Convert.ToDecimal(dr["Rev"]);
                    }
                }
            }

            int delivered = ScalarInt(con, "SELECT COUNT(*) FROM Orders WHERE Status = 'Delivered'");
            int shipped = ScalarInt(con, @"SELECT COUNT(*) FROM Orders WHERE Status IN ('Shipped','Dispatched','Out for delivery','In Transit')");
            int processing = ScalarInt(con, @"SELECT COUNT(*) FROM Orders WHERE Status IN ('Pending','Placed','Processing','Confirmed')");
            int total = ScalarInt(con, "SELECT COUNT(*) FROM Orders");
            int other = Math.Max(0, total - delivered - shipped - processing);

            var payload = new
            {
                orders7Labels = labels7,
                orders7Data = data7,
                revenueLabels = revLabels,
                revenueData = revData,
                statusLabels = new[] { "Delivered", "Shipped", "Processing", "Other" },
                statusData = new[] { delivered, shipped, processing, other },
                statusCounts = new[] { delivered, shipped, processing, other }
            };

            return new JavaScriptSerializer().Serialize(payload);
        }

        private static int ScalarInt(SqlConnection con, string sql)
        {
            using (SqlCommand cmd = new SqlCommand(sql, con))
                return Convert.ToInt32(cmd.ExecuteScalar());
        }

        private static decimal ScalarDecimal(SqlConnection con, string sql)
        {
            using (SqlCommand cmd = new SqlCommand(sql, con))
                return Convert.ToDecimal(cmd.ExecuteScalar());
        }

        private static string FormatTrend(decimal current, decimal previous)
        {
            if (previous == 0)
                return current > 0 ? "+100% from last month" : "0% from last month";
            decimal pct = ((current - previous) / previous) * 100;
            string sign = pct >= 0 ? "+" : "";
            return sign + pct.ToString("0.##", CultureInfo.InvariantCulture) + "% from last month";
        }

        private static string WrapTrend(decimal current, decimal previous)
        {
            string cls = current >= previous ? "adm-trend-up" : "adm-trend-down";
            if (previous == 0 && current == 0) cls = "adm-trend-neutral";
            return string.Format("<span class=\"adm-stat-trend {0}\">{1}</span>", cls, FormatTrend(current, previous));
        }

        public string GetOrderRef(object id, object orderRef)
        {
            if (orderRef != null && orderRef != DBNull.Value && !string.IsNullOrWhiteSpace(orderRef.ToString()))
                return orderRef.ToString();
            return "ORD" + id;
        }

        public string GetStatusPillClass(object status)
        {
            string s = (status ?? "").ToString().ToLowerInvariant();
            if (s.Contains("deliver")) return "adm-pill adm-pill-green";
            if (s.Contains("cancel") || s.Contains("reject")) return "adm-pill adm-pill-red";
            if (s.Contains("ship") || s.Contains("transit") || s.Contains("dispatch")) return "adm-pill adm-pill-blue";
            if (s.Contains("process") || s.Contains("pending") || s.Contains("placed") || s.Contains("confirm"))
                return "adm-pill adm-pill-amber";
            return "adm-pill adm-pill-gray";
        }

        public string FormatOrderDate(object dt)
        {
            if (dt == null || dt == DBNull.Value) return "";
            return Convert.ToDateTime(dt).ToString("dd MMM yyyy", CultureInfo.InvariantCulture);
        }

        public string FormatUserDate(object dt)
        {
            if (dt == null || dt == DBNull.Value) return "";
            return Convert.ToDateTime(dt).ToString("dd MMM yyyy", CultureInfo.InvariantCulture);
        }

        public string GetUserInitials(object name)
        {
            string n = (name ?? "U").ToString().Trim();
            if (string.IsNullOrEmpty(n)) return "U";
            var parts = n.Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries);
            if (parts.Length >= 2) return (parts[0][0].ToString() + parts[1][0]).ToUpperInvariant();
            return n.Substring(0, Math.Min(2, n.Length)).ToUpperInvariant();
        }

        public string FormatAmount(object amt)
        {
            if (amt == null || amt == DBNull.Value) return "₹0";
            return "₹" + Convert.ToDecimal(amt).ToString("N0", CultureInfo.InvariantCulture);
        }
    }
}
